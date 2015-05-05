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
#   Parámetro 2 (obligatorio): Directorio destino
#   Parámetro 3 (opcional): comando que la invoca
#

GRUPO=/home/nico/SistemasOperativos #TODO debe ser la var de conf.
DUPDIR=$GRUPO/Duplicados  #TODO debe ser la var de conf.
CONFDIR=$GRUPO/conf #TODO debe ser la var de conf.

#No pueden ser menos de 2 ni mas de 3 parametros
if [ $# -gt 3 -o $# -lt 2 ]; then
	sh glog.sh MOVER "Cantidad de parametros inválida" ERR
	exit 1
fi

log="$3"
rutadestino="${2%/*}"
ardestino="${2##*/}"
arorigen="${1##*/}"

#Chequear que los primeros dos argumentos sean directorios validos
if [ ! -f "$1" ];then #Chequeo si $1 es un archivo
	sh glog.sh MOVER "El origen no existe" ERR
	exit 2
fi

if [ ! -d "$rutadestino" ]; then #Chequeo si el directorio del destino existe
        echo "destino no existe"
		sh glog.sh MOVER "El directorio destino no existe" ERR
	exit 3
else
        rutadestino=$(echo "./$rutadestino")
        ardestino="$1"
fi

#Chequear si origen y destino son distintos
if [ "$1" = "$2" ]; then
		sh glog.sh MOVER "No se hizo nada porque el origen es igual al destino" ERR
		exit 4
fi

#Chequeo si hay duplicados
cd $GRUPO
NOMBREARCHIVO=$( find $1 | sed 's/.*\///') #Busca el archivo en el path origen y luego despeja el nombre del mismo
cd "$2"
if [ -f "$NOMBREARCHIVO" ]; then # Si encuentro el archivo en destino
	mv "$GRUPO/$1" "$DUPDIR" # Muevo el archivo a DUPDIR
	NUMEROSECUENCIA=$( cat $CONFDIR/InsPro.conf | grep 'NUMEROSECUENCIA' | sed 's/NUMEROSECUENCIA=//' ) # Busco el N de secuencia en el archivo de conf
	echo $NUMEROSECUENCIA
	NUEVONOMBRE=$NOMBREARCHIVO"."$NUMEROSECUENCIA
	echo $NUEVONOMBRE
	mv $DUPDIR"/"$NOMBREARCHIVO $NUEVONOMBRE
	$(cat $CONFDIR/InsPro.conf | sed 's/NUMEROSECUENCIA='$NUMEROSECUENCIA'/NUMEROSECUENCIA='$(expr $NUMEROSECUENCIA + 001)'/' > $CONFDIR/InsPro.conf)
	exit 5
fi

mv "$1" "$2"
sh glog.sh MOVER "Archivo $1 movido correctamente" INFO

exit 0
