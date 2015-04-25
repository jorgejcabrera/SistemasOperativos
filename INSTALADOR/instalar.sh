#!/bin/bash
GRUPO=/home/mariagustina/SISOP/SISTEMASOPERATIVOS/TP/grupo05
CONFDIR=/home/mariagustina/SISOP/SISTEMASOPERATIVOS/TP/grupo05/conf
BINDIR=$1
MAEDIR=$2
NOVEDIR=$3
ACEPDIR=$4
RECHDIR=$5
PROCDIR=$6
INFODIR=$7
LOGDIR=$8

#19 CONFIRMAR INICIO DE INSTALACION
echo "Iniciando Instalacion. Esta Ud. seguro? (Si-No)";
read instalacionConfirmada
valida=0
if [ $instalacionConfirmada = "Si" ] || [ $instalacionConfirmada = "No" ] ; then
	valida=1
fi
while [ $valida = 0 ]; do
	echo "Respuesta: $instalacionConfirmada , Usted no ha ingresado una respuesta valida, por favor indique Si o No respetando mayusculas y minusculas: "
	read instalacionConfirmada
	if [ $instalacionConfirmada = "Si" ] || [ $instalacionConfirmada = "No" ] ; then
		valida=1
	fi
done
sh glog.sh INSTALADOR "Iniciando Instalacion. Esta Ud. seguro? (Si-No) $confirmarInstalacion" INFO

if [ $instalacionConfirmada = "Si" ] ; then
	echo "Creando Estructuras de directorio. . . ."
	sh glog.sh INSTALADOR "Creando Estructuras de directorio. . . ." INFO			
	
	if ! [ -d $BINDIR ]; then
		mkdir $BINDIR
	fi

#PROBAR BIEN ESTO
	if ! [ -d $MAEDIR ]; then
		mkdir $MAEDIR
		
	elif ! [ -d $MAEDIR/tab ]; then
		mkdir $MAEDIR/tab
	
	elif ! [ -d $MAEDIR/tab/ant ]; then
		mkdir $MAEDIR/tab/ant
	fi
	
	if ! [ -d $NOVEDIR ]; then
		mkdir $NOVEDIR
	fi

	if ! [ -d $ACEPDIR ]; then
		mkdir $ACEPDIR
	fi

	if ! [ -d $RECHDIR ]; then
		mkdir $RECHDIR
	fi

#PROBAR BIEN ESTO
	if ! [ -d $PROCDIR ]; then
		mkdir $PROCDIR
	elif ! [ -d $PROCDIR/proc ]; then
		mkdir $PROCDIR/proc
	fi

	if ! [ -d $INFODIR ]; then
		mkdir $INFODIR
	fi	

	if ! [ -d $LOGDIR ]; then
		mkdir $LOGDIR
	fi	
	
	#FALTA 20.2 A 20.6
	exit
else
	echo "INSTALACION CANCELADA"
	sh glog.sh INSTALADOR "INSTALACION CANCELADA" WARR
	exit
fi
