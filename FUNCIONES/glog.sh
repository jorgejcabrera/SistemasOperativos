#!/bin/bash

#************Glog
#************Parametro1 (obligatorio):comando (nombre del comando o funcion que genera el mensaje)
#************Parametro2 (obligatorio): mensaje
#************Parametro3 (opcional):tipo de mensaje [INFO,WAR,ERR]

LOGSIZE=100
LOGBORRARHH=51 #Borra hasta la linea n-1

#Evito que sea un log infinito, cuando llega a LOGSIZE trunca las primeras LOGBORRARHH-1 lineas
LOGDIRSIZE=$(wc -l LOGDIR/"$1".log 2> /dev/null | sed 's/ LOGDIR\/'$1'.log//') #Cantidad de lineas del log del parametro 1
if [ $LOGDIRSIZE ]; then
	if [ $LOGDIRSIZE -ge $LOGSIZE ]; then # Si alcanzo el maximo de lineas
		sed -i '1,'$LOGBORRARHH' d' LOGDIR/$1.log #Borro  desde la linea 1 hasta la linea LOGBORRARHH en el log correspondiente
#Logueo en el lugar correspondiente
		fecha=`date +"%X %x"`
		comando=$1
		mensaje="Log excedido para poder controlar que se esta realizando este trabajo."
		tipoMensaje="INFO"
		if [ $1 = "InsPro" ]; then
			echo $fecha $USER $comando $tipoMensaje $mensaje  >> CONFDIR/InsPro.log
		else 
			echo $fecha $USER $comando $tipoMensaje $mensaje  >> LOGDIR/$1.log #TODO El path de logs debe ser determinado x la variable de configuracion LOGDIR
		fi
	fi
fi

#Valido que el script reciba 2 o a lo sumo 3 parametros
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
	echo "No se pudo loguear mensaje, cantidad de parametros incorrecta: $# " >> LOG
	exit
fi

#Valido que el tercer parametro sea del tipo INFO,WAR,ERR
if [ ! $3 ]; then # si no existe el tercer parametro, entonces
	echo "Tipo de mensaje no ingresado: Se toma el valor por defautl [INFO]" >> LOG
	tipoMensaje="INFO"
else # si existe el tercer parametro, entonces
	if [ $3 = "INFO" ] || [ $3 = "WAR" ] || [ $3 = "ERR" ]; then
		tipoMensaje=$3
	else
		echo "Tipo de mensaje invalido: Se toma el valor por defautl [INFO]" >> LOG
		tipoMensaje="INFO"	
	fi
fi
	
#Escribo el archivo
fecha=`date +"%X %x"`
comando=$1
mensaje=$2

#Logueo en el lugar correspondiente
if [ $1 = "InsPro" ]; then
	echo $fecha $USER $comando $tipoMensaje $mensaje  >> CONFDIR/InsPro.log
else	
	if [ $1 = "MOVER" ]; then # TODO or START
		GPPID=`ps -fp $PPID | awk "/$PPID/"' { print $9 } ' | sed 's/.\///' | sed 's/.sh//' | tr [:lower:] [:upper:]`
		echo $fecha $USER $comando $tipoMensaje $mensaje  >> LOGDIR/$GPPID.log	
	else	
		echo $fecha $USER $comando $tipoMensaje $mensaje  >> LOGDIR/$1.log #TODO ElPath d log debe determinarse x la var de conf LOGDIR
	fi
fi

exit 0
