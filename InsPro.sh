#!/bin/bash
GRUPO=$PWD
CONFDIR=$PWD/conf

#1 LOGUEAMOS EL COMIENZO DE EJECUCION
sh glog.sh InsPro "Inicio de ejecucion de InsPro" INFO
echo "Inicio de ejecucion de InsPro"
sh glog.sh InsPro "Directorio Predefinido de Configuracion: $CONFDIR" INFO
echo "Directorio Predefinido de Configuracion: $CONFDIR"
sh glog.sh InsPro "Log de la instalacion: $CONFDIR" INFO
echo "Log de la instalacion: $CONFDIR"



#MEMORIA DEL SCRIPT
if [ -f memoryFile ]; then
	if [ $(grep -r "BINDIR" memoryFile) ]; then
		BINDIR=$(grep -r "BINDIR" memoryFile)
		BINDIR=${BINDIR:7}
	else
		BINDIR=$GRUPO/bin  #defaultvalue
	fi

	if [ $(grep -r "MAEDIR" memoryFile) ]; then
		MAEDIR=$(grep -r "MAEDIR" memoryFile)
		MAEDIR=${MAEDIR:7}
	else
		MAEDIR=$GRUPO/mae  #defaultvalue
	fi

	if [ $(grep -r "NOVEDIR" memoryFile) ]; then
		NOVEDIR=$(grep -r "NOVEDIR" memoryFile)
		NOVEDIR=${NOVEDIR:8}
	else
		NOVEDIR=$GRUPO/novedades  #defaultvalue
	fi

	if [ $(grep -r "DATASIZE" memoryFile) ]; then
		DATASIZE=$(grep -r "DATASIZE" memoryFile)
		DATASIZE=${DATASIZE:9}
	else
		declare -i DATASIZE=100  #defaultvalue
	fi

	if [ $(grep -r "ACEPDIR" memoryFile) ]; then
		ACEPDIR=$(grep -r "ACEPDIR" memoryFile)
		ACEPDIR=${ACEPDIR:8}
	else
		ACEPDIR=$GRUPO/a_protocolizar #defaultvalue
	fi

	if [ $(grep -r "RECHDIR" memoryFile) ]; then
		RECHDIR=$(grep -r "RECHDIR" memoryFile)
		RECHDIR=${RECHDIR:8}
	else
		RECHDIR=$GRUPO/rechazados  #defaultvalue
	fi

	if [ $(grep -r "PROCDIR" memoryFile) ]; then
		PROCDIR=$(grep -r "PROCDIR" memoryFile)
		PROCDIR=${PROCDIR:8}
	else
		PROCDIR=$GRUPO/protocolizados #defaultvalue
	fi

	if [ $(grep -r "INFODIR" memoryFile) ]; then
		INFODIR=$(grep -r "INFODIR" memoryFile)
		INFODIR=${INFODIR:8}
	else
		INFODIR=$GRUPO/informes  #defaultvalue
	fi

	if [ $(grep -r "DUPDIR" memoryFile) ]; then
		DUPDIR=$(grep -r "DUPDIR" memoryFile)
		DUPDIR=${DUPDIR:7}
	else
		DUPDIR=/dup  #defaultvalue
	fi

	if [ $(grep -r "LOGDIR" memoryFile) ]; then
		LOGDIR=$(grep -r "LOGDIR" memoryFile)
		LOGDIR=${LOGDIR:7}
	else
		LOGDIR=$GRUPO/log  #defaultvalue
	fi

	if [ $(grep -r "LOGSIZE" memoryFile) ]; then
		LOGSIZE=$(grep -r "LOGSIZE" memoryFile)
		LOGSIZE=${LOGSIZE:8}
	else
		LOGSIZE=400  #defaultvalue
	fi
else 
	BINDIR=$GRUPO/bin
	MAEDIR=$GRUPO/mae
	NOVEDIR=$GRUPO/novedades
	DATASIZE=100
	ACEPDIR=$GRUPO/a_protocolizar
	RECHDIR=$GRUPO/rechazados
	PROCDIR=$GRUPO/protocolizados
	INFODIR=$GRUPO/informes
	DUPDIR=/dup
	LOGDIR=$GRUPO/log
	LOGSIZE=400
	echo -e "BINDIR=$BINDIR\nMAEDIR=$MAEDIR\nNOVEDIR=$NOVEDIR\nDATASIZE=$DATASIZE\nACEPDIR=$ACEPDIR\nRECHDIR=$RECHDIR\nPROCDIR=$PROCDIR\nINFODIR=$INFODIR\nDUPDIR=$DUPDIR\nLOGDIR=$LOGDIR\nLOGSIZE=$LOGSIZE\n" > memoryFile;
fi

instalacionConfirmada="No"

#2 DETECTAR SI EL PAQUETE SISPROG O ALGUNO DE SUS COMPONENTES YA ESTA INSTALADO
CONFIGFILE="$CONFDIR/InsPro.conf"
if [ -f $CONFIGFILE ]; then
	sh glog.sh InsPro "existe el archivo InsPro.conf, asumimos que el paquete ya fue instalado" WAR
	sh verificarInstalacion.sh $BINDIR $MAEDIR $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR $INFODIR $DUPDIR $LOGDIR $DATASIZE $LOGSIZE
else
	sh glog.sh InsPro "no existe el archivo InsPro.conf, asumimos que el paquete no fue instalado" INFO
	
	#5 CHEQUEAMOS QUE PERL ESTE INSTALADO
	sh glog.sh InsPro "Verificando versión de Perl instalada...." INFO
	echo "Verificando versión de Perl instalada...."
        PERLV=$(perl -v | grep 'v[0-9]\.[0-9]\+\.[0-9]*' -o); #obtengo la version de perl
	numPERLV=$(echo $PERLV | cut -d"." -f1 | sed 's/^v\([0-9]\)$/\1/'); #obtengo el primer numero
	#si perlv no existe o es menor a 5 mando error
	if [ -z "$numPERLV" ] || [ $numPERLV -lt 5 ] ; then
		msgPerl="Para instalar el TP es necesario contar con Perl 5 o superior. Efectue su insalacion e intentelo nuevamente. Proceso de Instalacion cancelado."
		echo InsPro $msgPerl ERR;
		sh glog.sh InsPro InsPro $msgPerl ERR;
		exit 3;
	else
		echo "Perl Version:$PERLV";
		sh glog.sh InsPro "PERL instalado. Version:$PERLV";
	fi
	while [ $instalacionConfirmada = "No" ]; do
		#6 DEFINIMOS EL DIRECTORIO DE INSTALACION DE LOS EJECUTABLES
		echo "Defina el directorio de instalacion de los ejecutables ($BINDIR):"; 		
		read directorioInstalacion		
		binDefault=$BINDIR
		if ! [ -z $directorioInstalacion ] ; then
			BINDIR=$GRUPO/$directorioInstalacion
			if [ $directorioInstalacion = "conf" ] || [ $directorioInstalacion = "datos" ] ; then
				BINDIR=$binDefault
				echo "No se pueden ingresar los directorios conf y datos, estan reservados por el programa, se tomara el valor por default"
			fi
		fi
		sed -i "s|BINDIR=$binDefault|BINDIR=$BINDIR|g" memoryFile
		sh glog.sh InsPro "Defina el directorio de instalacion de los ejecutables ($binDefault) $BINDIR" INFO

		#7 DEFINIMOS EL DIRECTORIO DE INSTALACION DE LOS ARCHIVOS MAESTROS Y TABLAS
		echo "Defina el Directorio de instalacion para maestros y tablas ($MAEDIR):";		
		read directorioMae
		maeDefault=$MAEDIR
		if ! [ -z $directorioMae ] ; then
			MAEDIR=$GRUPO/$directorioMae
			if [ $directorioMae = "conf" ] || [ $directorioMae = "datos" ] ; then
				MAEDIR=$maeDefault
				echo "No se pueden ingresar los directorios conf y datos, estan reservados por el programa se tomara el valor por default"
			fi
		fi
		sed -i "s|MAEDIR=$maeDefault|MAEDIR=$MAEDIR|g" memoryFile
		sh glog.sh InsPro "Defina el Directorio de instalacion para maestros y tablas ($maeDefault): $MAEDIR" INFO

		#8 DEFINIMOS EL DIRECTORIO DE INPUT DEL PROCESO RecPro
		echo "Defina el Directorio de recepcion de documentos para protocolizacion ($NOVEDIR):";
		read directorioNovedades
		noveDefault=$NOVEDIR
		if ! [ -z $directorioNovedades ] ; then
			NOVEDIR=$GRUPO/$directorioNovedades
			if [ $directorioNovedades = "conf" ] || [ $directorioNovedades = "datos" ] ; then
				NOVEDIR=$noveDefault
				echo "No se pueden ingresar los directorios conf y datos, estan reservados por el programa, se tomara el valor por default"
			fi
		fi
		sed -i "s|NOVEDIR=$noveDefault|NOVEDIR=$NOVEDIR|g" memoryFile
		sh glog.sh InsPro "Defina el Directorio de recepcion de documentos para protocolizacion ($noveDefault): $NOVEDIR" INFO

		#9 DEFINIMOS EL ESPACIO MINIMO LIBRE PARA EL ARRIBO DE ARCHIVOS DE NOVEDADES
		echo "Defina espacio minimo libre para el arribo de estas novedades en Mbytes ($DATASIZE): ";
		read dataIngresada
		dataDefault=$DATASIZE		
		if ! [ -z $dataIngresada ] ; then
			DATASIZE=$dataIngresada
		fi
		sed -i "s|DATASIZE=$dataDefault|DATASIZE=$DATASIZE|g" memoryFile
		sh glog.sh InsPro "Defina espacio minimo libre para el arribo de estas novedades en Mbytes ($dataDefault): $DATASIZE" INFO
		#10 VERIFICAR ESPACIO EN DISCO
		DISCSIZE=$(df -B1024 "$GRUPO" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';');
		milion=1000
		DISCSIZE=$(expr $DISCSIZE / $milion)
		while [ $DATASIZE -gt $DISCSIZE ]; do
			echo "El espacio minimo definido para el arribo de novedades es mayor al espacio que hay en disco, por favor defina un espacio mas chico"
			read dataIngresada
			sed -i "s|DATASIZE=$DATASIZE|DATASIZE=$dataIngresada|g" memoryFile
			if ! [ -z $dataIngresada ] ; then
				DATASIZE=$dataIngresada
			fi
		done

		#11 DEFINIR EL DIRECTORIO DE INPUT DEL PROCESO ProPro
		echo "Defina el directorio de grabacion de las Novedades aceptadas ($ACEPDIR): ";
		read directorioAprotocolizar
		acepDefault=$ACEPDIR
		if ! [ -z $directorioAprotocolizar ] ; then
			ACEPDIR=$GRUPO/$directorioAprotocolizar
			if [ $directorioAprotocolizar = "conf" ] || [ $directorioAprotocolizar = "datos" ] ; then
				ACEPDIR=$acepDefault
				echo "No se pueden ingresar los directorios conf y datos, estan reservados por el programa, se tomara el valor por default"
			fi
		fi
		sed -i "s|ACEPDIR=$acepDefault|ACEPDIR=$ACEPDIR|g" memoryFile
		sh glog.sh InsPro "Defina el directorio de grabacion de las Novedades aceptadas ($acepDefault): $ACEPDIR" INFO

		#12 DEFINIR REPOSITORIO DE ARCHIVOS RECHAZADOS
		echo "Dedina el directorio de grabacion de Archivos rechazados ($RECHDIR): ";
		read directorioRechazados
		rechDefault=$RECHDIR
		if ! [ -z $directorioRechazados ] ; then
			RECHDIR=$GRUPO/$directorioRechazados
			if [ $directorioRechazados = "conf" ] || [ $directorioRechazados = "datos" ] ; then
				RECHDIR=$rechDefault
				echo "No se pueden ingresar los directorios conf y datos, estan reservados por el programa, se tomara el valor por default"
			fi
		fi
		sed -i "s|RECHDIR=$rechDefault|RECHDIR=$RECHDIR|g" memoryFile
		sh glog.sh InsPro "Defina el directorio de grabación de Archivos rechazados 
	($rechDefault): $RECHDIR" INFO

		#13 DEFINIR EL DIRECTORIO DE OUTPUT DEL PROCESO ProPro
		echo "Defina el Directorio de grabacion de los documentos protocolizados ($PROCDIR):";
		read directorioProtocolizados
		procDefault=$PROCDIR
		if ! [ -z $directorioProtocolizados ] ; then
			PROCDIR=$GRUPO/$directorioProtocolizados
			if [ $directorioProtocolizados = "conf" ] || [ $directorioProtocolizados = "datos" ] ; then
				PROCDIR=$procDefault
				echo "No se pueden ingresar los directorios conf y datos, estan reservados por el programa, se tomara el valor por default"
			fi
		fi
		sed -i "s|PROCDIR=$procDefault|PROCDIR=$PROCDIR|g" memoryFile
		sh glog.sh InsPro "Defina el Directorio de grabacion de los documentos protocolizados ($procDefault): $PROCDIR" INFO

		#14 DEFINIR EL DIRECTORIO DE TRABAJO PRINCIPAL DEL PROCESO InfPro
		echo "Defina el Directorio de grabacion de los informes de salida ($INFODIR):";
		read directorioInformes
		infoDefault=$INFODIR
		if ! [ -z $directorioInformes ] ; then
			INFODIR=$GRUPO/$directorioInformes
			if [ $directorioInformes = "conf" ] || [ $directorioInformes = "datos" ] ; then
				INFODIR=$infoDefault
				echo "No se pueden ingresar los directorios conf y datos, estan reservados por el programa, se tomara el valor por default"
			fi
		fi
		sed -i "s|INFODIR=$infoDefault|INFODIR=$INFODIR|g" memoryFile
		sh glog.sh InsPro "Defina el Directorio de grabacion de los informes de salida ($infoDefault): $INFODIR" INFO
		
		#15 DEFINIR EL NOMBRE PARA EL REPOSITORIO DE DUPLICADOS
		echo "Defina el nombre para el repositorio de archivos duplicados($DUPDIR): ";
		read nombreDuplicados
		dupDefault=$DUPDIR
		if ! [ -z $nombreDuplicados ] || [[ $nombreDuplicados =~ ^[a-zA-Z] ]] ; then
			DUPDIR=$nombreDuplicados
			if [ $nombreDuplicados = "conf" ] || [ $nombreDuplicados = "datos" ] ; then
				DUPDIR=$dupDefault
				echo "No se pueden ingresar los directorios conf y datos, estan reservados por el programa, se tomara el valor por default"
			fi
		fi
		sed -i "s|DUPDIR=$dupDefault|DUPDIR=$DUPDIR|g" memoryFile
		sh glog.sh InsPro "Defina el nombre para el repositorio de archivos duplicados($dupDefault): $DUPDIR" INFO
	
		#16 DEFINIR EL NOMBRE DEL DIRECTORIO PARA DEPOSITAR LOS LOGS DE EJECUCION DE LOS COMANDOS
		echo "Defina el directorio de logs ($LOGDIR): ";
		read directorioLog
		logDefault=$LOGDIR
		if ! [ -z $directorioLog ] ; then
			LOGDIR=$GRUPO/$directorioLog
			if [ $directorioLog = "conf" ] || [ $directorioLog = "datos" ] ; then
				LOGDIR=$logDefault
				echo "No se pueden ingresar los directorios conf y datos, estan reservados por el programa, se tomara el valor por default"
			fi
		fi
		sed -i "s|LOGDIR=$logDefault|LOGDIR=$LOGDIR|g" memoryFile
		sh glog.sh InsPro "Defina el directorio de logs ($logDefault): $LOGDIR" INFO

		#17 DEFINIR EL TAMANO MAXIMO PARA LOS ARCHIVOS DE LOG
		echo "Defina el tamano maximo para cada archivo de log en Kbytes ($LOGSIZE): ";
		read tamanoMaximo
		tamanoDefault=$LOGSIZE
		if ! [ -z $tamanoMaximo ] ; then
			LOGSIZE=$tamanoMaximo
		fi
		sed -i "s|LOGSIZE=$tamanoDefault|LOGSIZE=$LOGSIZE|g" memoryFile
		sh glog.sh InsPro "Defina el tamano maximo para cada archivo de log en Kbytes ($tamanoDefault): $LOGSIZE" INFO

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

		sh glog.sh InsPro $msgMostrar INFO	

		if [ $instalacionConfirmada = "Si" ] ; then
			sh instalar.sh $BINDIR $MAEDIR $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR $INFODIR $LOGDIR $DATASIZE $DUPDIR $LOGSIZE
		else
			echo "Usted ha rechazado la instalacion, volveremos a definir todas las estructuras de directorio"
			sh glog.sh InsPro "Usted ha rechazado la instalacion, volveremos a definir todas las estructuras de directorio" ERR
			clear
		fi
	done
fi
