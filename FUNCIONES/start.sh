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
	else sh glog.sh "$1" "$2" "$3" # PATH_LOG ??
	fi
}

#Debe ser un solo parametro
if [ $# -ne 1 ]; then
	darSalidaCorrespondiente START "Cantidad de parametros inválida" ERR 
	exit 1
fi

#Chequeo que esten inicializadas las variables de ambiente
#TODO hacer esto cuando este implementado el INIPRO
#TODO Que el iniciador permita que start pueda ser corrido por linea de comando

#El demonio no debe estar corriendo previamente
CORRIENDO=$(ps aux | grep R.*/$1$)
if ! [ -z "$CORRIENDO" ]; then
	darSalidaCorrespondiente START "El demonio ya se encuentra corriendo" ERR 
	exit 1
fi

#Debe existir el demonio
PATH_DAEMON=$(find . -name *$1)
if [ -z "$PATH_DAEMON" ]; then
	darSalidaCorrespondiente START "Funcion inexistente" ERR 
	exit 1
else 	"$PATH_DAEMON" & #Arranco el demonio
	darSalidaCorrespondiente START "Arranco el demonio" INFO 
fi

exit 0
