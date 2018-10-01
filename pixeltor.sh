#!/usr/bin/env bash
typeset -r RED=$'\e[31m' CYAN=$'\e[36m' GREEN=$'\e[32m' \
	BOLD=$'\e[1m' ITALIC=$'\e[3m' \
	END=$'\e[0m' SCRIPT="${0##*/}";
typeset ARCHIVO="$(date +"pixeltor_%a-%b-%d_%H-%M-%S.sh")" R_ARCHIVO="${SCRIPT%.*}.rec" D_ARCHIVO="${SCRIPT%.*}.log";
typeset -i M_COLS COLUMNAS M_FILAS FILAS REDO_PICKER;
typeset OPCION PICKER=15;

if [[ "$LANG" =~ "es" ]]; then
	STRING_1(){ echo -e "Prueba '$BOLD$0 -h$END' para más información." 2> /dev/null; };
	STRING_2(){ echo -e "Tú necesitas gnome-terminal para esta opción. También pudes configurar tu terminal en el script."; };
	STRING_3(){ echo -e "${RED}No se pudo generar el archivo para grabar.$END"; };
	STRING_4(){ read -rep "$(echo -e "$CYAN${BOLD}Escribe la ruta completa en donde quieres guardar tu archivo: $END")" -i "$HOME/$R_ARCHIVO" R_ARCHIVO; };
	STRING_5(){ which ttyrec 1> /dev/null || notify-send "Dependencia incumplida." "La opción -r requiere de «ttyrec»"; };
	STRING_6(){ echo -e "${RED}El archivo de depuración no se pudo generar.$END"; };
	STRING_7(){ read -rep "$(echo -e "$CYAN${BOLD}Escribe la ruta completa en donde quieres guardar tu archivo: $END")" -i "$HOME/$D_ARCHIVO" D_ARCHIVO; };
	STRING_8(){ notify-send -i "emblem-ok-symbolic" -u "normal" "Depuración activada" "El registro de «$SCRIPT» se guarda en «$D_ARCHIVO»"; };
	STRING_9(){ echo -e "\n${GREEN}Coordenada «$BOLD$OPCION$END${GREEN}» marcada (Color no. $PICKER).$END"; };
	STRING_10(){ echo -e "\n${GREEN}Coordenada «$BOLD$OPCION$END${GREEN}» desmarcada.$END"; };
	STRING_11(){ read -rep "$(echo -e "$CYAN${BOLD}Número del color:$END ")" -i $REDO_PICKER PICKER; };
	STRING_12(){ echo -e "${RED}Sólo se aceptan números del 0 al 255.$END"; };
	STRING_13(){ echo -e "${RED}\nNo se pudo generar el archivo.$END"; };
	STRING_14(){ read -rep "$(echo -e "$CYAN${BOLD}Escribe la ruta completa en donde quieres guardar tu archivo: $END")" -i "$HOME/${ARCHIVO##*/}" ARCHIVO; };
	STRING_15(){ echo -e "\n${GREEN}Archivo «$ARCHIVO» generado.$END"; };
	STRING_16(){ echo -e "\n${RED}La opción «$OPCION» no existe.$END"; };
	STRING_17(){ echo -e "\n\nColor seleccionado: \e[48;5;${PICKER:=15}m\x20\x20\e[m"; };
	STRING_18(){ echo -e "\n${RED}La coordenada «$OPCION» no existe.$END"; };
	STRING_19(){ echo -e "${RED}Sólo NÚMEROS mayores a 0 y menores que $M_COLS son aceptados.$END"; };
	STRING_20(){ echo -e "${RED}Sólo NÚMEROS mayores a 0 son aceptados.$END"; };
	STRING_21(){ echo -e "\nEscriba una de las opciones:\n"; };
	STRING_22(){ echo -e "\tx,y) Marcar(:) Desmarcar(_)."; };
	STRING_23(){ echo -e "\t h ) Ayuda."; };
	STRING_24(){ echo -e "\t p ) Escoger color."; };
	STRING_25(){ echo -e "\t s ) Guardar."; };
	STRING_26(){ echo -e "\t q ) Salir.\n"; };
else
	STRING_1(){ echo -e "Try '$BOLD$0 -h$END' for more information." 2> /dev/null; };
	STRING_2(){ echo -e "You need gnome-terminal for this option. You can also configure your terminal in the script."; };
	STRING_3(){ echo -e "${RED}Record file could not be generated.$END"; };
	STRING_4(){ read -rep "$(echo -e "$CYAN${BOLD}Type the full path to where you want your file to be saved: $END")" -i "$HOME/$R_ARCHIVO" R_ARCHIVO; };
	STRING_5(){ which ttyrec 1> /dev/null || notify-send "Unfulfilled dependency" "The -r option requires «ttyrec»"; };
	STRING_6(){ echo -e "${RED}Debug file could not be generated.$END"; };
	STRING_7(){ read -rep "$(echo -e "$CYAN${BOLD}Type the full path to where you want your file to be saved: $END")" -i "$HOME/$D_ARCHIVO" D_ARCHIVO; };
	STRING_8(){ notify-send -i "emblem-ok-symbolic" -u "normal" "Debugging enabled" "The logs of «$SCRIPT» will be stored in «$D_ARCHIVO»"; };
	STRING_9(){ echo -e "\n${GREEN}Coordinate «$BOLD$OPCION$END${GREEN}» marked (Color no. $PICKER).$END"; };
	STRING_10(){ echo -e "\n${GREEN}Coordinate «$BOLD$OPCION$END${GREEN}» unmarked.$END"; };
	STRING_11(){ read -rep "$(echo -e "$CYAN${BOLD}Color number:$END ")" -i $REDO_PICKER PICKER; };
	STRING_12(){ echo -e "${RED}Only numbers from 0 to 255 are accepted.$END"; };
	STRING_13(){ echo -e "${RED}\nFile could not be generated.$END"; };
	STRING_14(){ read -rep "$(echo -e "$CYAN${BOLD}Type the full path to where you want your file to be saved: $END")" -i "$HOME/${ARCHIVO##*/}" ARCHIVO; };
	STRING_15(){ echo -e "\n${GREEN}File «$ARCHIVO» generated.$END"; };
	STRING_16(){ echo -e "\n${RED}Option «$OPCION» does not exist.$END"; };
	STRING_17(){ echo -e "\n\nSelected color: \e[48;5;${PICKER}m\x20\x20\e[m"; };
	STRING_18(){ echo -e "\n${RED}Coordinate «$OPCION» does not exist.$END"; };
	STRING_19(){ echo -e "${RED}Only NUMBERS greater than 0 and less than $M_COLS are accepted.$END"; };
	STRING_20(){ echo -e "${RED}Only NUMBERS greater than 0 are accepted.$END"; };
	STRING_21(){ echo -e "\nType according to option:\n"; };
	STRING_22(){ echo -e "\tx,y) Check(:) Uncheck(_)."; };
	STRING_23(){ echo -e "\t h ) Help."; };
	STRING_24(){ echo -e "\t p ) Pick color."; };
	STRING_25(){ echo -e "\t s ) Save."; };
	STRING_26(){ echo -e "\t q ) Quit.\n"; };
fi

IMPREVISTO(){
	echo -e "\r${SCRIPT}: has stopped.                      "
	exit 1
}

L_MIN() {
	# Retorna la longitud máxima que que puede tener un string «$2» sin romper palabras con respecto a una longitud dada «$1»
	typeset LT=$1 I=1;	# Longitud temporal. Es la longitud máxima que puede tener

	while [[ ${2:$((LT-I)):1} != " " ]]; do
		((I++));
		if [[ $I -eq ${#2} ]]; then # Cuando se recorre toda la palabra y no hay espacios está se rompe
			I=1;
			break;
		fi
	done

	return $(($1-I));
}

WRAP_TEXT() { # String, prefix, lenprefix
	typeset CADENA="$1" LONGITUD DELIMITADOR;

	LONGITUD=$(($(tput cols)-${3:-${#2}})) > /dev/null 2>&1 || { printf '\e[8;19;100t'; LONGITUD=$((100-${3:-${#2}})); };
	DELIMITADOR="$2";

	while [[ ${#CADENA} -ge ${LONGITUD} ]]; do
		# Mientras el primer carácter de CADENA sea un espacio se irá recorriendo hasta que no lo sea
		while [[ ${CADENA:0:1} = " " ]]; do
			CADENA="${CADENA:1}";
		done

		L_MIN $LONGITUD "$CADENA"; LMIN=$?;

		echo "${DELIMITADOR%%:*}${CADENA:0:$LMIN}";

		CADENA="${CADENA:$LMIN}";
		DELIMITADOR="${DELIMITADOR#*:}";
	done

	if [[ ${#CADENA} -gt 0 ]]; then
		while [[ ${CADENA:0:1} = " " ]]; do
			CADENA="${CADENA:1}";
		done

		echo "${DELIMITADOR%%:*}$CADENA";
	fi
}

HOW_TO_USE() {
	echo -e "${BOLD}SYNOPSIS$END";
	echo -e "\t$SCRIPT [Options]";
	echo;

	echo -e "${BOLD}DESCRIPTION$END";
	WRAP_TEXT "$BOLD$SCRIPT$END It's a simple script for those pixelart fanatics in terminals. It has no dependencies at all beyond the simple interpreter bash. Execute and let your artistic talents fly!" $'\t' 8;
	echo;

	WRAP_TEXT "To mark a coordinate, insert the value of x (column) separated by «:» followed by the coordinate y (row)." $'\t' 8;
	WRAP_TEXT "To deselect a coordinate, insert the value of x (column) separated by «_» followed by the coordinate y (row)." $'\t' 8;
	WRAP_TEXT "To mark/unmark an axis you can use the "*" character instead of entering a number." $'\t' 8
	echo;
	WRAP_TEXT "To select a color just enter the corresponding number in the chart, the first 16 (0-15) are customized by your terminal. You can also cancel this option by entering «q»." $'\t' 8

	echo -e "${BOLD}OPTIONS$END";
	WRAP_TEXT "Generates a .log file with the execution information. If you use Gnome it shows you this in another terminal in real time." $'\t'"${BOLD}-d$END"$'\t':$'\t'$'\t' 16;
	WRAP_TEXT "Shows help and options of the script." $'\t'"${BOLD}-h$END"$'\t':$'\t'$'\t' 16;
	WRAP_TEXT "Transfers the execution to another terminal while recording it using ${ITALIC}ttyrec$END. If you do not use ${ITALIC}gnome-terminal$END you will have to configure the script to work with your terminal." $'\t'"${BOLD}-r$END"$'\t':$'\t'$'\t' 16;
	echo -e "${BOLD}AUTHOR$END";
	WRAP_TEXT "Written in its entirety by @ureli (in Github) 2018." $'\t' 8;
}


SOBRE_EL_USO(){
	echo -e "${BOLD}SINOPSIS$END";
	echo -e "\t$SCRIPT [Opciones]";
	echo;

	echo -e "${BOLD}DESCRIPCIÓN$END";
	WRAP_TEXT "$BOLD$SCRIPT$END Es un simple script para aquellos fanáticos del pixelart en terminales. No tiene dependencias en lo absoluto más allá del simple interprete bash. Ejecute y ¡deje volar su imaginación." $'\t' 8;
	echo;

	WRAP_TEXT "Para marcar una coordenada se tiene que insertar el valor de x (columna) separado por «:» seguido por la coordenada y (fila)." $'\t' 8;
	WRAP_TEXT "Para desmarcar una coordenada se tiene que insertar el valor de x (columna) separado por «_» seguido por la coordenada y (fila)." $'\t' 8;
	WRAP_TEXT "Para marcar/desmarcar un eje puede usar el carácter «*» en vez de introducir un número." $'\t' 8;
	echo;
	WRAP_TEXT "Para seleccionar un color sólo introduzca el número correspondiente en el gráfico, los primeros 16 (0-15) son personalizados por su terminal. También puede cancelar esta opción introduciendo «q»." $'\t' 8

	echo -e "${BOLD}OPCIONES$END";
	WRAP_TEXT "Genera un archivo .log con con la información de la ejecución. Si usa Gnome le muestra esto en otra terminal en tiempo real." $'\t'"${BOLD}-d$END"$'\t':$'\t'$'\t' 16;
	WRAP_TEXT "Muestra ayuda y opciones del script." $'\t'"${BOLD}-h$END"$'\t':$'\t'$'\t' 16;
	WRAP_TEXT "Transfiere la ejecución a otra terminal mientras lo graba usando ${ITALIC}ttyrec$END. Si no usa la terminal de Gnome tendrá que configurar el script para que funcione con su terminal." $'\t'"${BOLD}-r$END"$'\t':$'\t'$'\t' 16;
	echo -e "${BOLD}AUTOR$END";
	WRAP_TEXT "Escrito en su totalidad por @ureli (en Github) 2018." $'\t' 8;
}

CLEAR() {
	clear && printf "\ec\e[3J";
}

EJEMPLO_DE_USO(){
	if [[ ${USER-$(whoami)} = "root" ]]; then
		typeset SIGNO="#" RUTA=${PWD//\/root/\~} COLOR=$RED;
	fi

	echo -e "$BOLD${COLOR:-$GREEN}$USER@$HOSTNAME$END:$BOLD$BLUE${RUTA:-${PWD//\/home\/$USER/\~}}$END${SIGNO:-"$"}\x20$1\r";
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
		printf " %b" "$(eval "echo \${ARRAY_$N[*]}")";
	done

	STRING_17;
}

SAVE_FILE() {
	printf '#!/usr/bin/env bash'$'\n''echo -e "' > "$1";

	for (( NO_FILA = 1; NO_FILA <= FILAS; NO_FILA++ )); do
		(for (( NO_COLUMNA = 0; NO_COLUMNA < COLUMNAS; NO_COLUMNA++ )); do
			printf "%s" "$(eval "echo -n \${ARRAY_$NO_FILA[$NO_COLUMNA]//\[\]/\\\x20\\\x20}")";
		done) >> "$1";

		((NO_FILA != FILAS)) && echo -n '\n' >> "$1";
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
			CLEAR;

			if [[ "$LANG" =~ "es" ]]; then
				SOBRE_EL_USO;
			else
				HOW_TO_USE;
			fi

			exit 0
			;;
		r)	RECORD=true
			;;
		\?)
			STRING_1;
			exit 1
			;;
		:)
			STRING_1;
			exit 1
			;;
	esac
done

if ${RECORD:=false}; then														# Si la opción de grabar está activada
	if [[ $(which ttyrec) ]] && ! killall -0 ttyrec 2> /dev/null; then			# Si no está instalado ttyrec o se está ejecutando este parámetro no sirve

		( gnome-terminal -- ttyrec "$R_ARCHIVO" -e "$0 $PARAMETROS" ) 2> /dev/null || {
			SALIDA=$?;
			STRING_2;
			exit $SALIDA;
		}

		while [[ ! -f "$R_ARCHIVO" ]]; do
			STRING_3;
			STRING_4;

			mkdir -p "${R_ARCHIVO%/*}" 2> /dev/null;							# Trata de crear los directorios de la ruta, de ser necesario.
			(: > "$R_ARCHIVO") > /dev/null 2>&1;
			[[ ! -f "$R_ARCHIVO" ]] && { unset R_ARCHIVO; continue; };

			( gnome-terminal -- ttyrec "$R_ARCHIVO" -e "$0 $PARAMETROS" "$ARCHIVO" ) 2> /dev/null && break;
		done

		EJEMPLO_DE_USO "${BOLD}ttyplay ${R_ARCHIVO}$END";
		exit 0;
	else
		STRING_5;
	fi
fi

if ${DEBUG:=false}; then														# Si la opción -d está activada crea archivo de depuración
	(: > "$D_ARCHIVO") > /dev/null 2>&1 || {
		while :; do
			STRING_6;
			STRING_7;

			mkdir -p "${D_ARCHIVO%/*}" 2> /dev/null;							# Trata de crear los directorios de la ruta, de ser necesario.
			(: > "$D_ARCHIVO") > /dev/null 2>&1 || unset D_ARCHIVO;
			[[ -f "$D_ARCHIVO" ]] && break;
		done
	}

	exec 5> "$D_ARCHIVO";														# Se crea en esta parte para que no muestre el "precódigo"
	BASH_XTRACEFD="5";
	STRING_8;
	( gnome-terminal -- watch -tn .1 "tail -n20 "$D_ARCHIVO"" ) 2> /dev/null
	set -x
fi
# Cdóigo -----------------------------------------------------------------------
which tput > /dev/null 2>&1 && M_COLS=$((($(tput cols)-4)/3));

while :; do
	[[ -z $M_COLS || $M_COLS -le 0 ]] && M_COLS=32;

	read -rep "$(echo -e "$CYAN${BOLD}Numero de columnas (VERTICAL):$END ")" -i $M_COLS COLUMNAS;

	which tput > /dev/null 2>&1 && M_COLS=$((($(tput cols)-4)/3));

	if [[ $COLUMNAS =~ ^[0-9]+$ && $COLUMNAS -gt 0 && $COLUMNAS -le $M_COLS ]]; then
		break;
	fi

	STRING_19;
	unset COLUMNAS;
done

while :; do
	which tput > /dev/null 2>&1 && M_FILAS=$(($(tput lines) -15))
	[[ $M_FILAS -le 0 ]] && unset M_FILAS;

	read -rep "$(echo -e "$CYAN${BOLD}Numero de filas (HORIZONTAL):$END ")" -i ${M_FILAS:-""} FILAS;

	if [[ $FILAS =~ ^[0-9]+$ && $FILAS -gt 0 ]]; then
		break;
	fi

	STRING_20;
	unset FILAS;
done
# Crea N arrays dados por la variable FILAS. A cada array se le asigna 01..N elementos dados por COLUMNAS
for (( N_FILA = 1; N_FILA <= FILAS; N_FILA++ )); do
	eval "typeset -a ARRAY_${N_FILA}=($(printf "%s" "$(eval "echo {01..$COLUMNAS}")"))";

	for (( N_COLUMNA = 0; N_COLUMNA < COLUMNAS; N_COLUMNA++ )); do
		eval "typeset -a ARRAY_${N_FILA}[$N_COLUMNA]=\"[]\"";
	done
done

printf '\e[8;%s;%st' $((FILAS+15)) $(((COLUMNAS*3)+4)); GRAFICAR;

while :; do
	STRING_21;
	STRING_22;
	STRING_23;
	STRING_24;
	STRING_25;
	STRING_26;

	read -ep "$(echo -e "$CYAN$BOLD >>>$END ")" OPCION;

	if [[ "$OPCION" =~ ^[0-9*]+[-_:.][0-9*]+$ ]]; then
		if  ! [[ "${OPCION%[-_:.]*}" = '*' || ( ${OPCION%[-_:.]*} -gt 0 && ${OPCION%[-_:.]*} -le $COLUMNAS ) ]] || \
			! [[ "${OPCION#*[-_:.]}" = '*' || (${OPCION#*[-_:.]} -gt 0 && ${OPCION#*[-_:.]} -le $FILAS) ]]; then
			GRAFICAR;
			STRING_18;
		else
			case "${OPCION//[0-9]/}" in
				*[:.]*)
					if [[ "${OPCION//[0-9]/}" =~ ^\*.\*$ ]]; then
						for (( N_FILA = 1; N_FILA <= FILAS; N_FILA++ )); do
							eval "ARRAY_${N_FILA}=($(printf "%s" "$(eval "echo {01..$COLUMNAS}")"))";

							for (( N_COLUMNA = 0; N_COLUMNA < COLUMNAS; N_COLUMNA++ )); do
								eval "ARRAY_${N_FILA}[$N_COLUMNA]=\"\e[48;5;${PICKER}m\x20\x20\e[m\"";
							done
						done
					elif [[ "${OPCION//[0-9]/}" =~ ^\* ]]; then
						for ((I=0;I<$COLUMNAS;I++));do
							eval "ARRAY_${OPCION#*[:.]}[$I]=\"\e[48;5;${PICKER}m\x20\x20\e[m\"";
						done
					elif [[ "${OPCION//[0-9]/}" =~ \*$ ]]; then
						for ((I=1;I<=$FILAS;I++));do
							eval "ARRAY_$I[$((${OPCION%[:.]*}-1))]=\"\e[48;5;${PICKER}m\x20\x20\e[m\"";
						done
					else
						eval "ARRAY_${OPCION#*[:.]}[$((${OPCION%[:.]*}-1))]=\"\e[48;5;${PICKER}m\x20\x20\e[m\"";
					fi

					GRAFICAR;
					STRING_9;
					;;
				*[-_]*)
					if [[ "${OPCION//[0-9]/}" =~ ^\*.\*$ ]]; then
						for (( N_FILA = 1; N_FILA <= FILAS; N_FILA++ )); do
							eval "ARRAY_${N_FILA}=($(printf "%s" "$(eval "echo {01..$COLUMNAS}")"))";

							for (( N_COLUMNA = 0; N_COLUMNA < COLUMNAS; N_COLUMNA++ )); do
								eval "ARRAY_${N_FILA}[$N_COLUMNA]=\"[]\"";
							done
						done
					elif [[ "${OPCION//[0-9]/}" =~ ^\* ]]; then
						for ((I=0;I<$COLUMNAS;I++));do
							eval "ARRAY_${OPCION#*[-_]}[$I]=\"[]\"";
						done
					elif [[ "${OPCION//[0-9]/}" =~ \*$ ]]; then
						for ((I=1;I<=$FILAS;I++));do
							eval "ARRAY_$I[$((${OPCION%[-_]*}-1))]=\"[]\"";
						done
					else
						eval "ARRAY_${OPCION#*[-_]}[$((${OPCION%[-_]*}-1))]=\"[]\"";
					fi

					GRAFICAR;
					STRING_10;
					;;
			esac
		fi
	elif [[ $OPCION =~ ^[hH]$ ]]; then
		less -R <<< $(SOBRE_EL_USO);
		GRAFICAR
	elif [[ $OPCION =~ ^[qQ]|[eE][xX][iI][tT]$ ]]; then
		CLEAR; exit 0
	elif [[ $OPCION =~ ^[pP]$ ]]; then
		printf '\e[8;%s;145t' "$((FILAS+15))";	# Se asegura que la terminal tenga cierto tamaño.
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

		REDO_PICKER=$PICKER;	# Guarda el color antes de cambiarlo

		while :; do
			STRING_11;

			if [[ $PICKER =~ ^[0-9]+$ && $PICKER -ge 0 && $PICKER -le 255 ]]; then
				break
			elif [[ $PICKER =~ ^[qQ]$ ]]; then
				PICKER="$REDO_PICKER"
				break
			fi

			STRING_12;
			unset PICKER;
		done

		GRAFICAR
	elif [[ $OPCION =~ ^[Ss]$ ]]; then
		GRAFICAR;

		SAVE_FILE "$ARCHIVO" 2> /dev/null || {
			while :; do
				STRING_13;
				STRING_14;

				mkdir -p "${ARCHIVO%/*}" 2> /dev/null || continue;
				SAVE_FILE "$ARCHIVO" && break;
			done
		}

		STRING_15;
	elif [[ "$OPCION" == * ]]; then
		GRAFICAR;
		STRING_16;
	fi
done
