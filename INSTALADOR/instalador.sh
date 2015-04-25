#!/bin/bash
GRUPO=/home/mariagustina/SISOP/SISTEMASOPERATIVOS/TP/grupo05
CONFDIR=/home/mariagustina/SISOP/SISTEMASOPERATIVOS/TP/grupo05/conf
#CONFDIR=../grupo05/conf
instalacionConfirmada="No"
BINDIR=$GRUPO/bin
MAEDIR=$GRUPO/mae
NOVEDIR=$GRUPO/novedades
declare -i DATASIZE=100
ACEPDIR=$GRUPO/a_protocolizar
RECHDIR=$GRUPO/rechazados
PROCDIR=$GRUPO/protocolizados
INFODIR=$GRUPO/informes
DUPDIR=/dup
LOGDIR=$GRUPO/log
LOGSIZE=400

#1 LOGUEAMOS EL COMIENZO DE EJECUCION
sh glog.sh INSTALADOR "Inicio de ejecucion de InsPro" INFO
sh glog.sh INSTALADOR "Directorio Predefinido de Configuracion: $CONFDIR" INFO
sh glog.sh INSTALADOR "Log de la instalacion: $CONFDIR" INFO

#2 DETECTAR SI EL PAQUETE SISPROG O ALGUNO DE SUS COMPONENTES YA ESTA INSTALADO
CONFIGFILE="$CONFDIR/InsPro.conf"
if [ -f $CONFIGFILE ]; then
	sh glog.sh INSTALADOR "existe el archivo InsPro.conf, asumimos que el paquete ya fue instalado" WAR
	sh verifInstalacion.sh $BINDIR $MAEDIR $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR $INFODIR $DUPDIR $LOGDIR
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
	while [ $instalacionConfirmada = "No" ]; do
		#6 DEFINIMOS EL DIRECTORIO DE INSTALACION DE LOS EJECUTABLES
		echo "Defina el directorio de instalacion de los ejecutables ($BINDIR):"; 		
		read directorioInstalacion
		binDefault=$BINDIR
		if ! [ -z $directorioInstalacion ] ; then
			BINDIR=$GRUPO/$directorioInstalacion
		fi
		sh glog.sh INSTALADOR "Defina el directorio de instalacion de los ejecutables ($binDefault) $BINDIR" INFO

		#7 DEFINIMOS EL DIRECTORIO DE INSTALACION DE LOS ARCHIVOS MAESTROS Y TABLAS
		echo "Defina el Directorio de instalacion para maestros y tablas ($MAEDIR):";		
		read directorioMae
		maeDefault=$MAEDIR
		if ! [ -z $directorioMae ] ; then
			MAEDIR=$GRUPO/$directorioMae
		fi
		sh glog.sh INSTALADOR "Defina el Directorio de instalacion para maestros y tablas ($maeDefault): $MAEDIR" INFO

		#8 DEFINIMOS EL DIRECTORIO DE INPUT DEL PROCESO RecPro
		echo "Defina el Directorio de recepcion de documentos para protocolizacion ($NOVEDIR):";
		read directorioNovedades
		noveDefault=$NOVEDIR
		if ! [ -z $directorioNovedades ] ; then
			NOVEDIR=$GRUPO/$directorioNovedades
		fi
		sh glog.sh INSTALADOR "Defina el Directorio de recepcion de documentos para protocolizacion ($noveDefault): $NOVEDIR" INFO

		#9 DEFINIMOS EL ESPACIO MINIMO LIBRE PARA EL ARRIBO DE ARCHIVOS DE NOVEDADES
		echo "Defina espacio minimo libre para el arribo de estas novedades en Mbytes ($DATASIZE): ";
		read dataIngresada
		dataDefault=$DATASIZE
		if ! [ -z $dataIngresada ] ; then
			DATASIZE=$dataIngresada
		fi
		sh glog.sh INSTALADOR "Defina espacio minimo libre para el arribo de estas novedades en Mbytes ($dataDefault): $DATASIZE" INFO

		#10 VERIFICAR ESPACIO EN DISCO
		DISCSIZE=$(df -B1024 "$GRUPO" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';');
		#DISCSIZE=$(echo "scale=0 ; $DATASIZE/1024" | bc -l); #lo paso
		let $DISCSIZE/1024;
		echo $DISCSIZE
		#FALTA ESTE PASO!!!!!! (BUSCAR BIEN COMO PASAR A MB Y VALIDAR)

		#11 DEFINIR EL DIRECTORIO DE INPUT DEL PROCESO ProPro
		echo "Defina el directorio de grabacion de las Novedades aceptadas ($ACEPDIR): ";
		read directorioAprotocolizar
		acepDefault=$ACEPDIR
		if ! [ -z $directorioAprotocolizar ] ; then
			ACEPDIR=$GRUPO/$directorioAprotocolizar
		fi
		sh glog.sh INSTALADOR "Defina el directorio de grabacion de las Novedades aceptadas ($acepDefault): $ACEPDIR" INFO

		#12 DEFINIR REPOSITORIO DE ARCHIVOS RECHAZADOS
		echo "Dedina el directorio de grabacion de Archivos rechazados ($RECHDIR): ";
		read directorioRechazados
		rechDefault=$RECHDIR
		if ! [ -z $directorioRechazados ] ; then
			RECHDIR=$GRUPO/$directorioRechazados
		fi
		sh glog.sh INSTALADOR "Defina el directorio de grabación de Archivos rechazados 
	($rechDefault): $RECHDIR" INFO

		#13 DEFINIR EL DIRECTORIO DE OUTPUT DEL PROCESO ProPro
		echo "Defina el Directorio de grabacion de los documentos protocolizados ($PROCDIR):";
		read directorioProtocolizados
		procDefault=$PROCDIR
		if ! [ -z $directorioProtocolizados ] ; then
			PROCDIR=$GRUPO/$directorioProtocolizados
		fi
		sh glog.sh INSTALADOR "Defina el Directorio de grabacion de los documentos protocolizados ($procDefault): $PROCDIR" INFO

		#14 DEFINIR EL DIRECTORIO DE TRABAJO PRINCIPAL DEL PROCESO InfPro
		echo "Defina el Directorio de grabacion de los informes de salida ($INFODIR):";
		read directorioInformes
		infoDefault=$INFODIR
		if ! [ -z $directorioInformes ] ; then
			INFODIR=$GRUPO/$directorioInformes
		fi
		sh glog.sh INSTALADOR "Defina el Directorio de grabacion de los informes de salida ($infoDefault): $INFODIR" INFO
		
		#15 DEFINIR EL NOMBRE PARA EL REPOSITORIO DE DUPLICADOS
		echo "Defina el nombre para el repositorio de archivos duplicados($DUPDIR): ";
		read nombreDuplicados
		dupDefault=$DUPDIR
		#FALTA VALIDAR QUE SEA UN NOMBRE SOLO SIMPLE
		if ! [ -z $nombreDuplicados ] ; then
			DUPDIR=$nombreDuplicados
		fi
		sh glog.sh INSTALADOR "Defina el nombre para el repositorio de archivos duplicados($dupDefault): $INFODIR" INFO
	
		#16 DEFINIR EL NOMBRE DEL DIRECTORIO PARA DEPOSITAR LOS LOGS DE EJECUCION DE LOS COMANDOS
		echo "Defina el directorio de logs ($LOGDIR): ";
		read directorioLog
		logDefault=$LOGDIR
		if ! [ -z $directorioLog ] ; then
			LOGDIR=$GRUPO/$directorioLog
		fi
		sh glog.sh INSTALADOR "Defina el directorio de logs ($logDefault): $LOGDIR" INFO

		#17 DEFINIR EL TAMANO MAXIMO PARA LOS ARCHIVOS DE LOG
		echo "Defina el tamano maximo para cada archivo de log en Kbytes ($LOGSIZE): ";
		read tamanoMaximo
		tamanoDefault=$LOGSIZE
		if ! [ -z $tamanoMaximo ] ; then
			LOGSIZE=$tamanoMaximo
		fi
		sh glog.sh INSTALADOR "Defina el tamano maximo para cada archivo de log en Kbytes ($tamanoDefault): $LOGSIZE" INFO

		#18 MOSTRAR ESTRUCTURA DE DIRECTORIOS RESULTANTE Y LOS VALORES DE LOS PARAMETROS CONFIGURADOS
		#FALTA PARTE DE LISTAR ARCHIVOS, QUE ARCHIVOS????
		clear
		msgMostrar="TP SO7508 Primer Cuatrimestre 2015. Tema G Copyright © Grupo 05 \nDirectorio de Configuracion: $CONFDIR (mostrar path y listar archivos) \nDirectorio de Ejecutables: $BINDIR (mostrar path y listar archivos) \nDirectorio de Maestros y Tablas: $MAEDIR (mostrar path y listar archivos) \nDirectorio de recepción de documentos para protocolización: $NOVEDIR \nEspacio mínimo libre para arribos: $DATASIZE Mb \nDirectorio de Archivos Aceptados: $ACEPDIR \nDirectorio de Archivos Rechazados: $RECHDIR\nDirectorio de Archivos Protocolizados: $PROCDIR \nDirectorio para informes y estadísticas: $INFODIR \nNombre para el repositorio de duplicados: $DUPDIR \nDirectorio para Archivos de Log: $LOGDIR (mostrar path y listar archivos) \nTamaño máximo para los archivos de log del sistema: $LOGSIZE Kb \nEstado de la instalación: LISTA \nInicia la instalación? (Si – No)."
		echo -e $msgMostrar;
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

		sh glog.sh INSTALADOR $msgMostrar INFO	

		if [ $instalacionConfirmada = "Si" ] ; then
			sh instalar.sh $BINDIR $MAEDIR $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR $INFODIR $LOGDIR
		else
			echo "Usted ha rechazado la instalacion, volveremos a definir todas las estructuras de directorio"
			sh glog.sh INSTALADOR "Usted ha rechazado la instalacion, volveremos a definir todas las estructuras de directorio" ERR
			clear
		fi
	done
fi
