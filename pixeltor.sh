#!/usr/bin/env bash
declare -r RED=$'\e[31m'; B_RED=$'\e[41m'; CYAN=$'\e[36m'; B_CYAN=$'\e[46m' \
	BLUE=$'\e[34m';	 B_BLUE=$'\e[44m'; GREEN=$'\e[32m'; B_GREEN=$'\e[42m' \
	BLACK=$'\e[30m'; B_BLACK=$'\e[40m'; WHITE=$'\e[37m'; B_WHITE=$'\e[47m' \
	PURPLE=$'\e[35m'; B_PURPLE=$'\e[45m'; YELLOW=$'\e[33m'; B_YELLOW=$'\e[43m' \
	BOLD=$'\e[1m'; HIDE=$'\e[8m'; STROKE=$'\e[9m' \
	INVERT=$'\e[7m'; ITALIC=$'\e[3m'; UNDERLINE=$'\e[4m' \
	END=$'\e[0m'; SCRIPT="${0##*/}";

alias clear='clear && printf "\ec\e[3J"'

IMPREVISTO(){
	echo -e "\r${SCRIPT}: has stopped.                      "
	exit 1
}
SOBRE_EL_USO(){
	echo -e "${BOLD}SINOPSIS$END"
	echo -e "\t$SCRIPT [Opciones]"
	echo

	echo -e "${BOLD}DESCRIPCIÓN$END"
	echo -e "\t$BOLD$SCRIPT$END Es un pequeño script para aquellos fanáticos del pixelart en terminales. Sin ninguna dependencia más allá del interprete BASH (esto"
	echo -e "\tsuponiendo que no use ninguna opción). Escrito para ser usado en una terminal moderna con entrono Gnome, sin embargo el uso en consola u otra terminal"
	echo -e "\tes posible, lo mismo para otro entrono. Quizá deba echar un ojo al código de querer modificar."
	echo
	echo -e "\tEn la ejecución sólo puede crear una cuadricula en los limites de: 1×1 a 100×100, pudiendo ser 1 o 100."
	echo -e "\tAl escoger un color usted cuenta con 256 (0-255) disponibles, pero solamente en terminales \"modernas\" podrá ver todos. Se recomienda sólo usar los"
	echo -e "\tprimeros 16 (0-15) si quiere mayor compatibilidad en todas las terminales."
	echo

	echo -e "${BOLD}OPCIONES$END"
	echo -e "\t$BOLD-d$END\tMuestra y genera un archivo con la depuración de este script."
	echo -e "\t$BOLD-h$END\tPara mostrar las opciones de ayuda (estás en esta opción)."
	echo -e "\t$BOLD-r$END\tTransfiere la ejecución a otra terminal mientras lo graba con ${ITALIC}ttyrec$END."

	echo -e "${BOLD}AUTOR$END"
}
GRAFICAR() {
	printf "    " # Separación del lado izq. antes de los no. de las columnas.
	# N representa el no. de las columnas
	for (( N = 1; N <= COLUMNAS; N++ )); do
		printf "$BOLD$CYAN%-3s$END" "$N"
	done
	# N representa el no. de las filas
	for (( N = 1; N <= FILAS; N++ )); do
		printf "$BOLD$CYAN\n%3s$END" "$N"
		for (( COLUMNA = 0; COLUMNA < COLUMNAS; COLUMNA++ )); do
			printf " %b" "$(eval "printf \${ARRAY_$N[$COLUMNA]}")"
		done
	done

	echo -e "\n\nColor seleccionado: \e[48;5;${PICKER:=15}m\x20\x20\e[m"
}
# Precodigo --------------------------------------------------------------------
trap IMPREVISTO INT SIGINT SIGTERM ABRT HUP TERM QUIT							# Regreso cuando se cancela con «CTRL + C»
PARAMETROS="$*"																	# Variable con los parámetros establecidos en la consola
while getopts "dhr" OPCION; do
	case $OPCION in
		d)	DEBUG=true
			;;
		h)
			printf '\e[8;19;159t'; clear
			SOBRE_EL_USO
			exit 0
			;;
		r)	RECORD=true
			;;
		\?)
			echo -e "Pruebe '$BOLD$0 -h$END' para más información." 2> /dev/null
			exit 1
			;;
		:)
			echo -e "Pruebe '$BOLD$0 -h$END' para más información." 2> /dev/null
			exit 1
			;;
	esac
done

shift $((OPTIND-1))

if [[ ${RECORD:=false} = true ]]; then											# Si la opción de grabar está activada
	if [[ $(which ttyrec) ]] && ! killall -0 ttyrec 2> /dev/null; then			# Si no está instalado ttyrec o se está ejecutando este parámetro no sirve
		gnome-terminal -- ttyrec ${SCRIPT%.*}.rec -e "$0 $PARAMETROS"
		EJEMPLO_DE_USO "${BOLD}ttyplay ${SCRIPT%.*}.rec$END"
		exit 0
	fi
fi

if [[ ${DEBUG:=false} = true ]]; then											# Si la opción -d está activada crea archivo de depuración
	exec 5> "${SCRIPT%.*}.log"													# Se crea en esta parte para que no muestre el "precódigo"
	BASH_XTRACEFD="5"
	notify-send -i "emblem-ok-symbolic" -u "normal" "Depuración activada" "La depuración se guarda en el archivo '${SCRIPT%.*}.log'"
	gnome-terminal -- watch -tn .1 "tail -n20 "${SCRIPT%.*}.log""
	set -x
fi

typeset -i M_COLS COLUMNAS M_FILAS FILAS;

while :; do
	M_COLS=$(tput cols);
	[[ $M_COLS = 0 ]] && M_COLS=50 || M_COLS=$(((M_COLS -4)/3));

	read -rep "$(echo -e "$CYAN${BOLD}Numero de columnas (VERTICAL):$END ")" -i $M_COLS COLUMNAS;

	if [[ $COLUMNAS =~ ^[0-9]+$ && $COLUMNAS -gt 0 && $COLUMNAS -le $M_COLS ]]; then
		break;
	fi

	echo -e "${RED}Only NUMBERS greater than 0 and less than $M_COLS are accepted.$END";
	unset COLUMNAS;
done

while :; do
	M_FILAS=$(tput lines);
	[[ $M_FILAS = 0 ]] && unset M_FILAS || M_FILAS=$((M_FILAS -12));

	read -rep "$(echo -e "$CYAN${BOLD}Numero de filas (HORIZONTAL):$END ")" -i ${M_FILAS:-""} FILAS;

	if [[ $FILAS =~ ^[0-9]+$ && $FILAS -gt 0 ]]; then
		break;
	fi

	echo -e "${RED}Only NUMBERS greater than 0 are accepted.$END";
	unset FILAS;
done
# Crea N arrays dados por la variable FILAS. A cada array se le asigna 01..N elementos dados por COLUMNAS
for (( N_FILA = 1; N_FILA <= FILAS; N_FILA++ )); do
	eval "declare -a ARRAY_${N_FILA}=($(printf "%s" "$(eval "echo {01..$COLUMNAS}")"))"

	for (( N_COLUMNA = 0; N_COLUMNA < COLUMNAS; N_COLUMNA++ )); do
		eval "declare -a ARRAY_${N_FILA}[$N_COLUMNA]=\"[]\""
	done
done

clear; echo; GRAFICAR

while :; do
	echo -e "\nElige una opción:\n"
	echo -e "\tV,H) Marcar(:) Desmarcar(_) dada la «COLUMNA,FILA»"
	echo -e "\t P ) Elegir color."
	echo -e "\t S ) Guardar."
	echo -e "\t Q ) Salir.\n"

	read -ep "$(echo -e "$CYAN$BOLD >>>$END ")" OPCION

	if [[ $OPCION =~ ^[0-9]+[-_:.][0-9]+$ ]]; then
		if  ! [[ ${OPCION%[-_:.]*} -gt 0 && ${OPCION%[-_:.]*} -le $COLUMNAS ]] || ! [[ ${OPCION#*[-_:.]} -gt 0 && ${OPCION#*[-_:.]} -le $FILAS ]]; then
			clear; echo; GRAFICAR
			echo -e "\n${RED}Error: la coordenada «$OPCION» no existe.$END"
		else
			if [[ ${OPCION//[0-9]/} =~ [:.] ]]; then
				eval "declare -a ARRAY_${OPCION#*[:.]}[$((${OPCION%[:.]*}-1))]=\"\e[48;5;${PICKER}m\x20\x20\e[m\""
				clear; echo; GRAFICAR
				echo -e "\n${GREEN}Coordenada «$BOLD$OPCION$END» ${GREEN}marcada (Color no. $PICKER).$END"
			elif [[ ${OPCION//[0-9]/} =~ [-_] ]]; then
				eval "declare -a ARRAY_${OPCION#*[-_]}[$((${OPCION%[-_]*}-1))]=\"[]\""
				clear; echo; GRAFICAR
				echo -e "\n${GREEN}Coordenada «$BOLD$OPCION$END» ${GREEN}desmarcada.$END"
			fi
		fi
	elif [[ $OPCION =~ ^[qQ]|[eE][xX][iI][tT]$ ]]; then
		clear; exit 0
	elif [[ $OPCION =~ ^[pP]$ ]]; then
		printf '\e[8;18;145t'; clear; echo

		for COLOR_LOCAL in {0..15}; do
			printf " \e[7m\e[38;5;${COLOR_LOCAL}m%3s\e[m\e[00m" $COLOR_LOCAL
		done

		for COLUMNA in 16 52 88 124 160 196 232; do
			printf "\n\n"

			for FILA in {0..35}; do
				let "COLOR = COLUMNA+FILA"

				if [[ $COLOR -eq 256 ]]; then
					echo; break
				else
					printf " \e[7m\e[38;5;${COLOR}m%3s\e[m\e[00m" $COLOR
				fi
			done
		done; echo

		while :; do
			REDO_PICKER="$PICKER"
			read -rep "$(echo -e "$CYAN${BOLD}Numero del color:$END ")" PICKER

			if [[ $PICKER =~ ^[0-9]+$ && $PICKER -ge 0 && $PICKER -le 255 ]]; then
				break
			elif [[ $PICKER =~ ^[qQ]$ ]]; then
				PICKER="$REDO_PICKER"
				break
			fi

			echo -e "${RED}Error: Sólo se aceptan NÚMEROS de 0 a 255.$END"; unset PICKER
		done

		clear; echo; GRAFICAR
	elif [[ $OPCION =~ ^[Ss]$ ]]; then
		clear; echo; GRAFICAR

		ARCHIVO="$(date +"PixelArt_%a-%b-%d_%H-%M-%S.sh")"

		echo -n '#!/usr/bin/env bash'$'\n''echo -e "' > "$ARCHIVO"

		for (( NO_FILA = 1; NO_FILA <= FILAS; NO_FILA++ )); do
			(for (( NO_COLUMNA = 0; NO_COLUMNA < COLUMNAS; NO_COLUMNA++ )); do
				printf "%s" "$(eval "echo -n \${ARRAY_$NO_FILA[$NO_COLUMNA]//\[\]/\\\x20\\\x20}")"
			done) >> "$ARCHIVO"
			echo -n '\n'  >> "$ARCHIVO"
		done; echo '"' >> "$ARCHIVO"

		if [[ -f "$ARCHIVO" ]]; then
			echo -e "\n${GREEN}Archivo «$ARCHIVO» generado.$END"
		else
			echo -e "${RED}Error: El archivo «$ARCHIVO» no sé pudo crear, revise los permisos del directorio.$END"
		fi
	elif [[ "$OPCION" == * ]]; then
		clear; echo; GRAFICAR
		echo -e "\n${RED}Error: la opción «$OPCION» no existe.$END"
	fi
done
