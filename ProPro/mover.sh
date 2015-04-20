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
		glog.sh $log E "(Mover) El origen no existe"
	fi
	exit 2
fi

if [ ! -d "$rutadestino" ]; then #Chequeo si el directorio del destino existe
        echo "destino no existe"
	if [ $# -eq 3 ]; then
		glog.sh $log E "(Mover) El directorio destino no existe"
	fi
	exit 3
else
        rutadestino=$(echo "./$rutadestino")
        ardestino="$1"
fi

#Chequear si origen y destino son distintos
if [ "$1" == "$2" ]; then
	if [ $# -eq 3 ]; then
		glog.sh $log I "(Mover) No se hizo nada porque el origen es igual al destino"
	fi
	exit 0
fi

#Chequear si el archivo destino ya existe en el directorio destino
if [ -f ./$rutadestion/$ardestino ]; then #Archivo duplicado
	if [ ! -d "$rutadestino/dup" ]; then
		mkdir "$rutadestino/dup"
	fi
	#Veo si no existe ya un archivo en dup con el mismo nombre y segun la extension aumentar el nnn
	nnn=$(ls "$rutadestino/dup" | grep "^$ardestino.[0-9]\{1,3\}$" | sort -r | sed s/$ardestino.// | head -n 1)
	if [ "$nnn" == "" ]; then #por si todavia no habia ninguna copia del archivo en dup
		nnn=0
	fi
	if [ "$nnn" == "999" ]; then #el numero nnn tiene un rango de 1 a 999
		glog.sh $log E "(Mover) No se pudo copiar, demasiados archivos duplicados"
		exit 4
	fi
	nnn=$(echo $nnn + 1 | bc -l) #sumo 1 al numero de secuencia
	mv "$1" "$rutadestino/dup/$ardestino.$nnn"
	if [ $# -eq 3 ]; then
		glog.sh $log I "(Mover) Archivo $ardestino duplicado, movido a $rutadestino/dup"
	fi
else
	mv "$1" "$2"
	if [ $# -eq 3 ]; then
		glog.sh $log I "(Mover) Archivo $origen movido correctamente"
	fi
fi
exit 0
