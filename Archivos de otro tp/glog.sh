#!/bin/bash

# Comando "glog"

# Output
# 	Archivo de log
#
# Opciones y Parámetros
#	Parámetro 1 (obligatorio): comando
#	Parámetro 2 (opcional): tipo de mensaje
#	Parámetro 3 (obligatorio): mensaje

# No pueden ser más de 3 ni menos de 2 parámetros

if [ $# -gt 3 -o $# -lt 2 ]
then
	./glog.sh glog es "$1: Cantidad de parámetros inválida."
	exit 1
fi

# Si es del instalador va en otro lado
if [ -z $LOGDIR ]
then
	logdir="../log"
else
	logdir="$GRUPO/$LOGDIR"
fi

# Que la dirección no sea un archivo

if [ -f $logdir ]
then
	./glog.sh glog es "$1: La dirección del directorio de destino es un archivo."
	exit 1
fi

# Si no existe lo crea.
if [ ! -d $logdir ]
then
	mkdir $logdir
fi

log=$logdir/$1.log

# Si el archivo no existe lo crea
touch $log  

tipoMensaje="  "
mensaje=""

# Si hay dos parámetros no tengo tipo de mensaje

if [ $# -eq 2 ]
then
	mensaje=$2
fi

# Si hay tres parámetros tengo tipo

if [ $# -eq 3 ]
then
	tipoMensaje=$(echo $2 | tr "[:lower:]" "[:upper:]")
	mensaje=$3
fi

# Si el tipo de mensaje es inválido lo pone en el log del glog
if [ $tipoMensaje != i -a $tipoMensaje != I -a $tipoMensaje != w -a $tipoMensaje != W -a $tipoMensaje != e -a $tipoMensaje != E -a $tipoMensaje != es -a $tipoMensaje != ES ]
then
	tipoMensaje="  "
	./glog.sh glog w "$1: Tipo de error inválido."
else
	if [ $tipoMensaje != es -a $tipoMensaje != ES ]
	then
		tipoMensaje=$tipoMensaje" "
		
	fi
fi

unaCadena=$tipoMensaje/

tamanioArchivo=`stat -c%s $log`

# Si el tamaño es menor a $maxlog y no es instalacion puede haber que recortar
if [ $MAXLOG ]
then
	if [ $tamanioArchivo -eq $MAXLOG ] || [ $tamanioArchivo -gt $MAXLOG ]
	then
		# Lo paso a un archivo nuevo, borro el viejo y renombro
		lineas=`wc -l $log | cut -d ' ' -f 1`
		if [ $lineas -gt 50 ]
		then
			logtemp=$log.temp
			touch $logtemp
			tail -q -n 50 $log > $logtemp
			rm $log
			mv $logtemp $log
		fi
	fi
fi
# Escribo el archivo
fecha=`date +"%X %x"`
echo "$fecha $1 $tipoMensaje $mensaje" >> $log

exit 0 
