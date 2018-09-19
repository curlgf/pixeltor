#!/usr/bin/env bash
typeset -r RED=$'\e[31m' CYAN=$'\e[36m' GREEN=$'\e[32m' BOLD=$'\e[1m' \
	INVERT=$'\e[7m' ITALIC=$'\e[3m' UNDERLINE=$'\e[4m' \
	END=$'\e[0m' SCRIPT="${0##*/}";
typeset -i M_COLS COLUMNAS M_FILAS FILAS REDO_PICKER;
typeset OPCION PICKER ARCHIVO;

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

CLEAR() {
	clear && printf "\ec\e[3J";
}

EJEMPLO_DE_USO(){
	if [[ ${USER-$(whoami)} = "root" ]]; then
		typeset -l SIGNO="#" RUTA=${PWD//\/root/\~} COLOR=$RED
	fi

	echo -e "$BOLD${COLOR:-$GREEN}$USER@$HOSTNAME$END:$BOLD$BLUE${RUTA:-${PWD//\/home\/$USER/\~}}$END${SIGNO:-"$"}\x20$1\r"
}

GRAFICAR() {
	CLEAR;
	printf "\n    "; # Separación del lado izq. antes de los no. de las columnas.
	# N representa el no. de las columnas
	for (( N = 1; N <= COLUMNAS; N++ )); do
		printf "$BOLD$CYAN%-3s$END" "$N";
	done
	# N representa el no. de las filas
	for (( N = 1; N <= FILAS; N++ )); do
		printf "$BOLD$CYAN\n%3s$END" "$N";

		for (( COLUMNA = 0; COLUMNA < COLUMNAS; COLUMNA++ )); do
			printf " %b" "$(eval "printf \${ARRAY_$N[$COLUMNA]}")";
		done
	done

	echo -e "\n\nColor seleccionado: \e[48;5;${PICKER:=15}m\x20\x20\e[m";
}

SAVE_FILE() {
	printf '#!/usr/bin/env bash'$'\n''echo -e "' > "$1";

	for (( NO_FILA = 1; NO_FILA <= FILAS; NO_FILA++ )); do
		(for (( NO_COLUMNA = 0; NO_COLUMNA < COLUMNAS; NO_COLUMNA++ )); do
			printf "%s" "$(eval "echo -n \${ARRAY_$NO_FILA[$NO_COLUMNA]//\[\]/\\\x20\\\x20}")";
		done) >> "$1";

		echo -n '\n'  >> "$1";
	done; echo '"' >> "$1";

	if [[ ! -f "$1" ]]; then
		return 1
	fi
}

# Precodigo --------------------------------------------------------------------
trap IMPREVISTO INT SIGINT SIGTERM ABRT HUP TERM QUIT							# Regreso cuando se cancela con «CTRL + C»
typeset PARAMETROS="$*"															# Variable con los parámetros establecidos en la consola

while getopts "dhr" OPCION; do
	case $OPCION in
		d)	DEBUG=true
			;;
		h)
			printf '\e[8;19;159t';
			CLEAR;
			SOBRE_EL_USO;
			exit 0
			;;
		r)	RECORD=true
			;;
		\?)
			echo -e "Try '$BOLD$0 -h$END' for more information." 2> /dev/null;	## String
			exit 1
			;;
		:)
			echo -e "Try '$BOLD$0 -h$END' for more information." 2> /dev/null;	## String
			exit 1
			;;
	esac
done

if ${RECORD:=false}; then														# Si la opción de grabar está activada
	if [[ $(which ttyrec) ]] && ! killall -0 ttyrec 2> /dev/null; then			# Si no está instalado ttyrec o se está ejecutando este parámetro no sirve
		typeset R_ARCHIVO="${SCRIPT%.*}.rec";

		( gnome-terminal -- ttyrec "$R_ARCHIVO" -e "$0 $PARAMETROS" ) 2> /dev/null || {
			SALIDA=$?;
			echo -e "You need gnome-terminal for this option. You can also configure your terminal in the script.";	## String
			exit $SALIDA;
		}

		while [[ ! -f "$R_ARCHIVO" ]]; do
			echo -e "${RED}Record file could not be generated.$END";			## String
			read -rep "$(echo -e "$CYAN${BOLD}Type the full path to where you want your file to be saved: $END")" -i "$HOME/$R_ARCHIVO" R_ARCHIVO;	## String

			mkdir -p "${R_ARCHIVO%/*}" 2> /dev/null;							# Trata de crear los directorios de la ruta, de ser necesario.
			(: > "$R_ARCHIVO") > /dev/null 2>&1;
			[[ ! -f "$R_ARCHIVO" ]] && { unset R_ARCHIVO; continue; };

			( gnome-terminal -- ttyrec "$R_ARCHIVO" -e "$0 $PARAMETROS" "$ARCHIVO" ) 2> /dev/null && break;
		done

		EJEMPLO_DE_USO "${BOLD}ttyplay ${R_ARCHIVO}$END";
		exit 0;
	else
		which ttyrec 1> /dev/null || notify-send "Dependencia incumplica" "La opción -r requiere de «ttyrec»";	## String
	fi
fi

if ${DEBUG:=false}; then														# Si la opción -d está activada crea archivo de depuración
	typeset D_ARCHIVO="${SCRIPT%.*}.log";

	(: > "$D_ARCHIVO") > /dev/null 2>&1 || {
		while :; do
			echo -e "${RED}Debug file could not be generated.$END";				## String
			read -rep "$(echo -e "$CYAN${BOLD}Type the full path to where you want your file to be saved: $END")" -i "$HOME/$D_ARCHIVO" D_ARCHIVO;	## String

			mkdir -p "${D_ARCHIVO%/*}" 2> /dev/null;							# Trata de crear los directorios de la ruta, de ser necesario.
			(: > "$D_ARCHIVO") > /dev/null 2>&1 || unset D_ARCHIVO;
			[[ -f "$D_ARCHIVO" ]] && break;
		done
	}

	exec 5> "$D_ARCHIVO";														# Se crea en esta parte para que no muestre el "precódigo"
	BASH_XTRACEFD="5";
	notify-send -i "emblem-ok-symbolic" -u "normal" "Debugging enabled" "The logs of «$SCRIPT» will be stored in «$D_ARCHIVO»";	## String
	( gnome-terminal -- watch -tn .1 "tail -n20 "$D_ARCHIVO"" ) 2> /dev/null
	set -x
fi



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
	[[ $M_FILAS = 0 ]] && unset M_FILAS || M_FILAS=$((M_FILAS -14));

	read -rep "$(echo -e "$CYAN${BOLD}Numero de filas (HORIZONTAL):$END ")" -i ${M_FILAS:-""} FILAS;

	if [[ $FILAS =~ ^[0-9]+$ && $FILAS -gt 0 ]]; then
		break;
	fi

	echo -e "${RED}Only NUMBERS greater than 0 are accepted.$END";
	unset FILAS;
done
# Crea N arrays dados por la variable FILAS. A cada array se le asigna 01..N elementos dados por COLUMNAS
for (( N_FILA = 1; N_FILA <= FILAS; N_FILA++ )); do
	eval "typeset -a ARRAY_${N_FILA}=($(printf "%s" "$(eval "echo {01..$COLUMNAS}")"))";

	for (( N_COLUMNA = 0; N_COLUMNA < COLUMNAS; N_COLUMNA++ )); do
		eval "typeset -a ARRAY_${N_FILA}[$N_COLUMNA]=\"[]\"";
	done
done

GRAFICAR;

while :; do
	echo -e "\nType according to option:\n";
	echo -e "\tx,y) Check(:) Uncheck(_).";
	echo -e "\t H ) Help.";
	echo -e "\t P ) Pick color.";
	echo -e "\t S ) Save.";
	echo -e "\t Q ) Quit.\n";

	read -ep "$(echo -e "$CYAN$BOLD >>>$END ")" OPCION;

	if [[ $OPCION =~ ^[0-9]+[-_:.][0-9]+$ ]]; then
		if  ! [[ ${OPCION%[-_:.]*} -gt 0 && ${OPCION%[-_:.]*} -le $COLUMNAS ]] || ! [[ ${OPCION#*[-_:.]} -gt 0 && ${OPCION#*[-_:.]} -le $FILAS ]]; then
			GRAFICAR;
			echo -e "\n${RED}Coordinate «$OPCION» does not exist.$END";			## Strimg
		else
			if [[ ${OPCION//[0-9]/} =~ [:.] ]]; then
				eval "typeset -a ARRAY_${OPCION#*[:.]}[$((${OPCION%[:.]*}-1))]=\"\e[48;5;${PICKER}m\x20\x20\e[m\"";
				GRAFICAR;
				echo -e "\n${GREEN}Coordinate «$BOLD$OPCION$END${GREEN}» marked (Color no. $PICKER).$END";	## String
			elif [[ ${OPCION//[0-9]/} =~ [-_] ]]; then
				eval "typeset -a ARRAY_${OPCION#*[-_]}[$((${OPCION%[-_]*}-1))]=\"[]\"";
				GRAFICAR;
				echo -e "\n${GREEN}Coordinate «$BOLD$OPCION$END${GREEN}» unmarked.$END";	## String
			fi
		fi
	elif [[ $OPCION =~ ^[qQ]|[eE][xX][iI][tT]$ ]]; then
		CLEAR; exit 0
	elif [[ $OPCION =~ ^[pP]$ ]]; then
		printf '\e[8;18;145t';	# Se asegura que la terminal tenga cierto tamaño.
		CLEAR; echo;

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

		REDO_PICKER="$PICKER";	# Guarda el color antes de cambiarlo

		while :; do
			read -rep "$(echo -e "$CYAN${BOLD}Color number:$END ")" -i $REDO_PICKER PICKER;	## String

			if [[ $PICKER =~ ^[0-9]+$ && $PICKER -ge 0 && $PICKER -le 255 ]]; then
				break
			elif [[ $PICKER =~ ^[qQ]$ ]]; then
				PICKER="$REDO_PICKER"
				break
			fi

			echo -e "${RED}Only numbers from 0 to 255 are accepted.$END";		## String
			unset PICKER;
		done

		GRAFICAR
	elif [[ $OPCION =~ ^[Ss]$ ]]; then
		GRAFICAR;

		ARCHIVO="$(date +"PixelArt_%a-%b-%d_%H-%M-%S.sh")";

		SAVE_FILE "$ARCHIVO" 2> /dev/null || {
			while :; do
				echo -e "${RED}\nFile could not be generated.$END";				## String
				read -rep "$(echo -e "$CYAN${BOLD}Type the full path to where you want your file to be saved: $END")" -i "$HOME/${ARCHIVO##*/}" ARCHIVO;	## String

				mkdir -p "${ARCHIVO%/*}" 2> /dev/null || continue;
				SAVE_FILE "$ARCHIVO" && break;
			done
		}

		echo -e "\n${GREEN}File «$ARCHIVO» generated.$END";						## String
	elif [[ "$OPCION" == * ]]; then
		GRAFICAR;
		echo -e "\n${RED}Option «$OPCION» does not exist.$END";					## String
	fi
done
