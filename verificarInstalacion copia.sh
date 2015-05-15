#!/bin/bash
GRUPO=$PWD
CONFDIR=$PWD/conf
DATADIR=$PWD/datos
BINDIR=$1
MAEDIR=$2
NOVEDIR=$3
ACEPDIR=$4
RECHDIR=$5
PROCDIR=$6
INFODIR=$7
DUPDIR=$8
LOGDIR=$9
DATASIZE=$10
LOGSIZE=$11

#verificar internas
completa=1
if ! [ -d $BINDIR ]; then
	binFaltante="BINDIR"
	completa=0
fi

#PROBAR BIEN ESTO
if ! [ -d $MAEDIR ]; then
	maeFaltante="MAEDIR"
	completa=0
fi
if ! [ -d $MAEDIR/tab ]; then
	maeFaltante="MAEDIR"
	completa=0
fi
if ! [ -d $MAEDIR/tab/ant ]; then
	maeFaltante="MAEDIR"
	completa=0
fi

if ! [ -d $NOVEDIR ]; then
	noveFaltante="NOVEDIR"
	completa=0
fi

if ! [ -d $ACEPDIR ]; then
	acepFaltante="ACEPDIR"
	completa=0
fi

if ! [ -d $RECHDIR ]; then
	rechFaltante="RECHDIR"
	completa=0
fi

#PROBAR BIEN ESTO
if ! [ -d $PROCDIR ]; then
	procFaltante="PROCDIR"
	completa=0
fi

if ! [ -d $PROCDIR/proc ]; then
	procFaltante="PROCDIR"
	completa=0
fi

if ! [ -d $LOGDIR ]; then
	logFaltante="LOGDIR"
	completa=0
fi

faltantes=$binFaltante" "$maeFaltante" "$noveFaltante" "$acepFaltante" "$rechFaltante" "$procFaltante" "$dupFaltante" "$logFaltante

msgMostrar="TP SO7508 Primer Cuatrimestre 2015. Tema G Copyright © Grupo 05 \nDirectorio de Configuracion: $CONFDIR (mostrar path y listar archivos) \nDirectorio de Ejecutables: $BINDIR (mostrar path y listar archivos) \nDirectorio de Maestros y Tablas: $MAEDIR (mostrar path y listar archivos) \nDirectorio de recepción de documentos para protocolización: $NOVEDIR \nDirectorio de Archivos Aceptados: $ACEPDIR \nDirectorio de Archivos Rechazados: $RECHDIR \nDirectorio de Archivos Protocolizados: $PROCDIR \nDirectorio para informes y estadísticas: $INFODIR \nNombre para el repositorio de duplicados: $DUPDIR \nDirectorio para Archivos de Log: $LOGDIR (mostrar path y listar archivos)"

#FALTA 20.04 ACTUALIZAR EL ARCHIVO DE CONFIGURACION InsPro.conf
#FORMATO DE ARCHIVO: VARIABLE=VALOR=USUARIO=FECHA
fecha=`date +"%X %x"`
quienSoy=$(whoami)	
msgGrabar="GRUPO=$GRUPO=$quienSoy=$fecha\nCONFDIR=$CONFDIR=$quienSoy=$fecha\nBINDIR=$BINDIR=$quienSoy=$fecha\nMAEDIR=$MAEDIR=$quienSoy=$fecha\nNOVEDIR=$NOVEDIR=$quienSoy=$fecha\nDATAZISE=$DATASIZE=$quienSoy=$fecha\nACEPDIR=$ACEPDIR=$quienSoy=$fecha\nRECHDIR=$RECHDIR=$quienSoy=$fecha\nPROCDIR=$PROCDIR=$quienSoy=$fecha\nINFODIR=$INFODIR=$quienSoy=$fecha\nDUPDIR=$DUPDIR=$quienSoy=$fecha\nLOGDIR=$LOGDIR=$quienSoy=$fecha\nLOGSIZE=$LOGSIZE=$quienSoy=$fecha\n"
echo $msgGrabar > $CONFDIR/InsPro.conf;

if [ $completa = 1 ]; then
	echo -e $msgMostrar;
	echo "Actualizando la configuracion del sistema"
	sh glog.sh InsPro "Actualizando la configuracion del sistema" INFO
	echo "Estado de la instalación: COMPLETA"
	sh glog.sh InsPro "Estado de la instalación: COMPLETA" WAR
	echo "Proceso de instalacion Cancelado."
	sh glog.sh InsPro "Proceso de instalacion Cancelado." WAR
	exit
elif [ $completa = 0 ]; then
	echo -e $msgMostrar;
	echo "Estado de la instalación: INCOMPLETA"
	sh glog.sh InsPro "Estado de la instalación: INCOMPLETA" WAR
	echo "Componentes Faltantes: $faltantes"
	sh glog.sh InsPro "Componentes Faltantes: $faltantes" WAR
	sh instalar.sh $BINDIR $MAEDIR $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR $INFODIR $LOGDIR $DATASIZE $DUPDIR $LOGSIZE
fi
