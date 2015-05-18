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

DESTINO=$2
PATHDESTINO="${2%/*}"
PATHORIGEN="${1%/*}"
ARORIGEN="${1##*/}"

#No pueden ser menos de 2 ni mas de 3 parametros
if [ $# -gt 3 -o $# -lt 2 ]; then
	sh glog.sh MOVER "Cantidad de parametros inválida" ERR
	exit 1
fi

#Chequear que los primeros dos argumentos sean directorios validos
if [ ! -f "$1" ];then #Chequeo si $1 es un archivo
	sh glog.sh MOVER "El origen no existe" ERR
	exit 2
fi

if [ ! -d "$PATHDESTINO" ]; then #Chequeo si el directorio del destino existe
	sh glog.sh MOVER "El directorio destino no existe" ERR
	exit 3
fi

#Chequear si origen y destino son distintos
if [ "$PATHORIGEN" = "$DESTINO" ]; then
		sh glog.sh MOVER "No se hizo nada porque el origen es igual al destino" ERR
		exit 4
fi

#Chequeo si hay duplicados
if [ -d "$DESTINO" ]; then
	DUPLICADO=$(find "$DESTINO" -maxdepth 1 -name "$ARORIGEN")
	if [ -n "$DUPLICADO" ]; then # Si encuentro el archivo en destino
		sh glog.sh MOVER "El archivo origen ya existe en destino, se mueve a $DUPDIR" WAR
		mv "$1" "$DUPDIR" # Muevo el archivo a DUPDIR
		NUMEROSECUENCIA=$( cat $CONFDIR/InsPro.conf | grep 'NUMEROSECUENCIA' | sed 's/NUMEROSECUENCIA=//' ) # 			Busco el N de secuencia en el archivo de conf
		NUEVONOMBRE=$ARORIGEN"."$NUMEROSECUENCIA
		mv "$DUPDIR/$ARORIGEN" "$DUPDIR/$NUEVONOMBRE"
		NEWNUMSECUENCIA=$(expr $NUMEROSECUENCIA + 001)
		if [ 10 -le "$NEWNUMSECUENCIA" ] && [ "$NEWNUMSECUENCIA" -le 99 ]; then
			NEWNUMSECUENCIA="0$NEWNUMSECUENCIA"
			echo "LALLA"
		else
			if [ "$NEWNUMSECUENCIA" -le 10 ]; then
				NEWNUMSECUENCIA="00$NEWNUMSECUENCIA"
			fi
		fi					
		$(sed -i 's/NUMEROSECUENCIA='$NUMEROSECUENCIA'/NUMEROSECUENCIA='$NEWNUMSECUENCIA'/' $CONFDIR/InsPro.conf)
		exit 5
	fi
fi

mv "$1" "$DESTINO"
sh glog.sh MOVER "Archivo $1 movido correctamente" INFO

exit 0
