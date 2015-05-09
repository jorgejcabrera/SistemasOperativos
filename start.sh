#!/bin/bash
# Comando "start"
# 
# Parametro 1
# demonio a arrancar

#Me fijo si fue invocado desde linea de comandos o desde otro script
darSalidaCorrespondiente(){
	PADRE=$(ps -o stat= -p $PPID)
	if [ "$PADRE" == "Ss" ]; then
	echo "$2"
	else sh glog.sh "$1" "$2" "$3"
	fi
}

check(){
	VAR=$1
	if [ -z "$VAR" ]; then
		darSalidaCorrespondiente START "No esta inicializado el ambiente" ERR
		exit 1
	fi
}

#Debe ser un solo parametro
if [ $# -ne 1 ]; then
	darSalidaCorrespondiente START "Cantidad de parametros inválida" ERR 
	exit 1
fi

#Chequeo que esten inicializadas las variables de ambiente
check $CONFDIR
check $BINDIR
check $MAEDIR
check $NOVEDIR
check $RECHDIR
check $PROCDIR
check $INFODIR
check $DUPDIR
check $LOGDIR

#El demonio no debe estar corriendo previamente
CORRIENDO=$(pgrep $1)
if [ -n "$CORRIENDO" ]; then
	darSalidaCorrespondiente START "El demonio ya se encuentra corriendo" ERR
	exit 1
fi

#Debe existir el demonio
PATH_DAEMON=$(find . -name *$1)
if [ -z "$PATH_DAEMON" ]; then
	darSalidaCorrespondiente START "Funcion inexistente" ERR 
	exit 1
else 	darSalidaCorrespondiente START "Arranco el demonio" INFO 
	"$PATH_DAEMON" &
fi

exit 0
