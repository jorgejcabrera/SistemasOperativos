#!/bin/bash
GRUPO=/home/mariagustina/SISOP/SISTEMASOPERATIVOS/TP/grupo05
CONFDIR=/home/mariagustina/SISOP/SISTEMASOPERATIVOS/TP/grupo05/conf
#CONFDIR=../grupo05/conf

#1 LOGUEAMOS EL COMIENZO DE EJECUCION
sh glog.sh INSTALADOR "Inicio de ejecucion de InsPro" INFO
sh glog.sh INSTALADOR "Directorio Predefinido de Configuracion: $CONFDIR" INFO
sh glog.sh INSTALADOR "Log de la instalacion: $CONFDIR" INFO

#2 DETECTAR SI EL PAQUETE SISPROG O ALGUNO DE SUS COMPONENTES YA ESTA INSTALADO
CONFIGFILE="$CONFDIR/InsPro.conf"
if [ -f $CONFIGFILE ]; then
	sh glog.sh INSTALADOR "existe el archivo InsPro.conf, asumimos que el paquete ya fue instalado" WAR
	#Seguir proceso: verificar si la instalacion esta completa
else
	sh glog.sh INSTALADOR "no existe el archivo InsPro.conf, asumimos que el paquete no fue instalado" INFO
	
	#5 CHEQUEAMOS QUE PERL ESTE INSTALADO
	sh glog.sh INSTALADOR "Verificando versión de Perl instalada...." INFO
	echo "Verificando versión de Perl instalada...."
        PERLV=$(perl -v | grep 'v[0-9]\.[0-9]\+\.[0-9]*' -o); #obtengo la version de perl
	numPERLV=$(echo $PERLV | cut -d"." -f1 | sed 's/^v\([0-9]\)$/\1/'); #obtengo el primer numero
	#si perlv no existe o es menor a 5 mando error
	if [ -z "$numPERLV" ] || [ $numPERLV -lt 5 ] ; then
		msgPerl="Para instalar el TP es necesario contar con Perl 5 o superior. Efectue su insalacion e intentelo nuevamente. Proceso de Instalacion cancelado."
		echo INSTALADOR $msgPerl ERR;
		sh glog.sh INSTALADOR INSTALADOR $msgPerl ERR;
		exit 3;
	else
		echo "Perl Version:$PERLV";
		sh glog.sh INSTALADOR "PERL instalado. Version:$PERLV";
	fi
	
	#6 DEFINIMOS EL DIRECTORIO DE INSTALACION DE LOS EJECUTABLE
	echo "Defina el directorio de instalacion de los ejecutables ($GRUPO/bin):"; 
	read directorioInstalacion
	if [ -z $directorioInstalacion ] ; then
		directorioInstalacion="bin"
	fi
	BINDIR=$GRUPO/$directorioInstalacion
	sh glog.sh INSTALADOR "Se ha definido el directorio de instalacion de los ejecutables: $BINDIR" INFO

	#7 DEFINIMOS EL DIRECTORIO DE INSTALACION DE LOS ARCHIVOS MAESTROS Y TABLAS
	echo "Defina el Directorio de instalacion para maestros y tablas ($GRUPO/mae):";
	read directorioMae
	if [ -z $directorioMae ] ; then
		directorioMae="mae"
	fi
	MAEDIR=$GRUPO/$directorioMae
	sh glog.sh INSTALADOR "Se ha definido el directorio de instalacion para maestros y tablas : $MAEDIR" INFO

	#8 DEFINIMOS EL DIRECTORIO DE INPUT DEL PROCESO RecPro
	echo "Defina el Directorio de recepcion de documentos para protocolizacion ($GRUPO/novedades):";
	read directorioNovedades
	if [ -z $directorioNovedades ] ; then
		directorioNovedades="novedades"
	fi
	NOVEDIR=$GRUPO/$directorioNovedades
	sh glog.sh INSTALADOR "Se ha definido el directorio de recepcion de documentos para protocolizacion : $NOVEDIR" INFO
	mkdir directorioNovedades

	#9 DEFINIMOS EL ESPACIO MINIMO LIBRE PARA EL ARRIBO DE ARCHIVOS DE NOVEDADES
	echo "Defina espacio minimo libre para el arribo de estas novedades en Mbytes (100): "
	read DATASIZE
	if [ -z $DATASIZE ] ; then
		DATASIZE=100
	fi
	sh glog.sh INSTALADOR "Se ha definido el directorio de recepcion de documentos para protocolizacion : $DATASIZE" INFO

	#10 VERIFICAR ESPACIO EN DISCO

fi
