#!/bin/bash
# Comando "mover"
# 
# Input
#   Archivo definido en el parámetro 1
# Output
#   Archivo definido en el parámetro 2
#   Archivo de Log del comando que la invoca (si corresponde)
# Opciones y Parámetros
#   Parámetro 1 (obligatorio): archivo origen
#   Parámetro 2 (obligatorio): archivo destino
#   Parámetro 3 (opcional): comando que la invoca
#

#No pueden ser menos de 2 ni mas de 3 parametros
if [ $# -gt 3 -o $# -lt 2 ]; then
	echo "Cantidad de parametros inválida"
	exit 1
fi

log="$3"
rutadestino="${2%/*}"
ardestino="${2##*/}"
arorigen="${1##*/}"

#Chequear que los primeros dos argumentos sean directorios validos
if [ ! -f "$1" ];then #Chequeo si $1 es un archivo
	if [ $# -eq 3 ]; then
		sh glog.sh MOVER "El origen no existe" ERR
	fi
	exit 2
fi

if [ ! -d "$rutadestino" ]; then #Chequeo si el directorio del destino existe
        echo "destino no existe"
	if [ $# -eq 3 ]; then
		sh glog.sh MOVER "El directorio destino no existe" ERR
	fi
	exit 3
else
        rutadestino=$(echo "./$rutadestino")
        ardestino="$1"
fi

#Chequear si origen y destino son distintos
if [ "$1" = "$2" ]; then
		sh glog.sh MOVER "No se hizo nada porque el origen es igual al destino" ERR
fi

mv "$1" "$2"
if [ $# -eq 3 ]; then
		sh glog.sh MOVER "Archivo $arorigen movido correctamente" INFO
fi
exit 0
