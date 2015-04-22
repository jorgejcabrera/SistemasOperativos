#!/bin/bash
GRUPO=/home/nico/SistemasOperativos
#GRUPO=../SistemasOperativos
# Comando "start"
# 
# Parametro 1
# demonio a arrancar

#Debe ser un solo parametro
if [ $# -gt 2 -o $# -lt 1 ]; then
	echo "Cantidad de parametros inválida"
	exit 1
fi

#El demonio no debe estar corriendo previamente
#TODO arreglar esto, por terminal funciona correctamente
#if [ "ps aux | grep "	"R.*/""$1$" ]; then
#	echo "El demonio ya se encuentra corriendo"
#	exit 1
#fi

#Debe existir el demonio
#TODO QUE BUSQUE EN TODOS LOS DIRECTORIOS, SOLO BUSCA EN EL ACTUAL

if [ ! -f "$1" ]; then
	echo "Funcion inexistente"
	exit 1
fi

#Arranco el demonio
"./$1" & 
echo "Arranco el demonio"
exit 0
