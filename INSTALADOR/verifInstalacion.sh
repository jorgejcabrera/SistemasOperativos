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
DUPDIR=$8
LOGDIR=$9

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

if [ $completa = 1 ]; then
	echo -e $msgMostrar;
	echo "Estado de la instalación: COMPLETA"
	echo "Proceso de instalacion Cancelado."
	exit
elif [ $completa = 0 ]; then
	echo -e $msgMostrar;
	echo "Estado de la instalación: INCOMPLETA"
	echo "Componentes Faltantes: $faltantes"
	sh instalar.sh $BINDIR $MAEDIR $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR $INFODIR $LOGDIR
fi
