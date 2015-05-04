#!/bin/bash
GRUPO=/home/mariagustina/SISOP/SISTEMASOPERATIVOS/TP/grupo05
CONFDIR=/home/mariagustina/SISOP/SISTEMASOPERATIVOS/TP/grupo05/conf
DATADIR=/home/mariagustina/SISOP/SISTEMASOPERATIVOS/TP/grupo05/datos
BINDIR=$1
MAEDIR=$2
NOVEDIR=$3
ACEPDIR=$4
RECHDIR=$5
PROCDIR=$6
INFODIR=$7
LOGDIR=$8
DATASIZE=$9
DUPDIR=$10 
LOGSIZE=$11

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

	if ! [ -d $MAEDIR ]; then
		mkdir $MAEDIR
	
	fi

	if ! [ -d $MAEDIR/tab ]; then
		mkdir $MAEDIR/tab
	fi
	
	if ! [ -d $MAEDIR/tab/ant ]; then
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

	if ! [ -d $PROCDIR ]; then
		mkdir $PROCDIR
	fi

	if ! [ -d $PROCDIR/proc ]; then
		mkdir $PROCDIR/proc
	fi

	if ! [ -d $INFODIR ]; then
		mkdir $INFODIR
	fi	

	if ! [ -d $LOGDIR ]; then
		mkdir $LOGDIR
	fi	
	
	#20.02 MOVER LOS ARCHIVOS MAESTROS AA MAEDIR Y LAS TABLAS AL DIRECTORIO MAEDIR/tab
	echo "Instalando Archivos Maestros y tablas"
	sh glog.sh INSTALADOR "Instalando Archivos Maestros y tablas" INFO
#SUPONGO QUE LOS QUE NO SON TABLAS NI MAESTROS SON ARCHIVOS DE NOVEDADES	

	for archivoOrigen in $DATADIR/*.mae;
	do
		sh mover.sh $archivoOrigen $MAEDIR
	done

	for archivoOrigen in $DATADIR/*.tab;
	do
		sh mover.sh $archivoOrigen $MAEDIR/tab
	done
	
	for archivoOrigen in $DATADIR/*;
	do
		sh mover.sh $archivoOrigen $NOVEDIR
	done

	#FALTA 20.03 MOVER LOS EJECUTABLES Y FUNCIONES AL DIRECTORIO BINDIR (verificarlo cuando este todo)
	echo "Instalando Archivos Programas y funciones"
	sh glog.sh INSTALADOR "Instalando Archivos Programas y funciones" INFO	
	sh mover.sh IniPro $BINDIR
	sh mover.sh RecPro $BINDIR
	sh mover.sh ProPro $BINDIR
	sh mover.sh InfPro $BINDIR
	#sh mover.sh mover.sh $BINDIR VER ESTO
	sh mover.sh Glog $BINDIR
	sh mover.sh Stop $BINDIR
	sh mover.sh Start $BINDIR
	sh mover.sh SisProG $BINDIR
	
	#20.04 ACTUALIZAR EL ARCHIVO DE CONFIGURACION InsPro.conf
	#FORMATO DE ARCHIVO: VARIABLE=VALOR=USUARIO=FECHA
	fecha=`date +"%X %x"`
	quienSoy=$(whoami)	
	msgMostrar="GRUPO=$GRUPO=$quienSoy=$fecha\nCONFDIR=$CONFDIR=$quienSoy=$fecha\nBINDIR=$BINDIR=$quienSoy=$fecha\nMAEDIR=$MAEDIR=$quienSoy=$fecha\nNOVEDIR=$NOVEDIR=$quienSoy=$fecha\nDATAZISE=$DATASIZE=$quienSoy=$fecha\nACEPDIR=$ACEPDIR=$quienSoy=$fecha\nRECHDIR=$RECHDIR=$quienSoy=$fecha\nPROCDIR=$PROCDIR=$quienSoy=$fecha\nINFODIR=$INFODIR=$quienSoy=$fecha\nDUPDIR=$DUPDIR=$quienSoy=$fecha\nLOGDIR=$LOGDIR=$quienSoy=$fecha\nLOGSIZE=$LOGSIZE=$quienSoy=$fecha\n"
	echo $msgMostrar > $CONFDIR/InsPro.conf;

	echo "Actualizando la configuracion del sistema"
	sh glog.sh INSTALADOR "Actualizando la configuracion del sistema" INFO

	#20.05 NO HAY ARCHIVOS TEMPORALES
	#20.06 MOSTRAR MSJ DE FIN DE INSTALACION
	echo "Instalacion CONCLUIDA"
	sh glog.sh INSTALADOR "Instalacion CONCLUIDA" INFO
	exit
else
	echo "INSTALACION CANCELADA"
	sh glog.sh INSTALADOR "INSTALACION CANCELADA" WAR
	exit
fi
