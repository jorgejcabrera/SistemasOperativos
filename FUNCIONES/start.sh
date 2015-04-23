#!/bin/bash
GRUPO=/home/nico/SistemasOperativos
#GRUPO=../SistemasOperativos
# Comando "start"
# 
# Parametro 1
# demonio a arrancar

#Debe ser un solo parametro
if [ $# -gt 1 -o $# -lt 1 ]; then
	echo "Cantidad de parametros inválida"
	sh glog.sh START "Cantidad de parametros inválida" ERR
	exit 1
fi

#Chequeo que esten inicializadas las variables de ambiente
#TODO hacer esto cuando este implementado el INIPRO

#TODO como garantizo que se pueda correr por consola? lo tendria que realizar la instalacion ?
#TODO como hago para que el script se de cuenta si fue invocado por consola o por otro script ?


#El demonio no debe estar corriendo previamente
CORRIENDO=$(ps aux | grep R.*/$1$)
if ! [ -z "$CORRIENDO" ]; then
	echo "El demonio ya se encuentra corriendo"
	sh glog.sh START "El demonio ya se encuentra corriendo" ERR
	exit 1
fi

#Debe existir el demonio
#TODO QUE BUSQUE EN TODOS LOS DIRECTORIOS, SOLO BUSCA EN EL ACTUAL
if [ ! -f "$1" ]; then
	echo "Funcion inexistente"
	sh glog.sh START "Funcion inexistente" ERR
	exit 1
fi

#Arranco el demonio
"./$1" & 
echo "Arranco el demonio"
sh glog.sh START "Arranco el demonio" INFO

exit 0
