#!/bin/bash

#Glog
#Parametro1 (obligatorio):comando
#Parametro2 (obligatorio): mensaje
#Parametro3 (opcional):tipo de mensaje [INFO,WAR,ERR]


#---------------VARIABLES---------------#
CONFDIR=$PWD/conf
COMANDO=$(echo "$1" | tr '[:lower:]' '[:upper:]') # Paso el comando a mayusculas para unificar grabacion en log y nombre del ARCHIVO.log
NAMEFILELOG=$(echo "$1" | tr '[:lower:]' '[:upper:]') # Paso el comando a mayusculas para unificar grabacion en log y nombre del ARCHIVO.log
MENSAJE=$2
TIPOMENSAJE=$3
FECHA=`date +"%X %x"`
MSGLOG="Log Excedido para poder controlar que se está realizando este trabajo."
if [ -n "$LOGSIZE" ]; then
	LOGBORRARHH=$(expr $LOGSIZE - 49) #Borra hasta la linea n-1
fi


#---------------FUNCIONES---------------#
fatherOfFunction(){
	PPNAME=`ps -fp $PPID | awk "/$PPID/"' { print $9 } ' | sed 's/.*\///' | sed 's/.sh//' | tr '[:lower:]' '[:upper:]'`
if [ "$PPNAME" = "MOVER" ] || [ "$PPNAME" = "START" ]; then
		PPID=`ps -fp $PPID | awk "/$PPID/"' { print $3 } '` #Obtengo el ID del padre
		PPNAME=`ps -fp $PPID | awk "/$PPID/"' { print $9 } ' | sed 's/.*\///' | sed 's/.sh//' | tr '[:lower:]' '[:upper:]'` 	#Obtengo el nombre del padre del padre
	fi
	if [ "$PPNAME" = "INSTALAR" ]; then
		PPID=`ps -fp $PPID | awk "/$PPID/"' { print $3 } '` #Obtengo el ID del padre
		PPNAME=`ps -fp $PPID | awk "/$PPID/"' { print $9 } ' | sed 's/.*\///' | sed 's/.sh//' | tr '[:lower:]' '[:upper:]'` 	#Obtengo el nombre del padre del padre del padre
	fi
	NAMEFILELOG=$PPNAME
}

logInPlace(){
	#Valido que el tercer parametro sea del tipo INFO,WAR,ERR
	if [ -z "$TIPOMENSAJE" ]; then	
		TIPOMENSAJE="INFO"
	fi

	if [ "$COMANDO" = "MOVER" -o "$COMANDO" = "START" ]; then
		fatherOfFunction
	fi	
	if [ "$COMANDO" = "INSPRO" ] || [ "$NAMEFILELOG" = "INSPRO" ]; then
		NAMEFILELOG="INSPRO"
		COMANDO="INSPRO"
		echo $FECHA $USER $COMANDO $TIPOMENSAJE $MENSAJE  >> "$CONFDIR"/$NAMEFILELOG.log
	else
		echo $FECHA $USER $COMANDO $TIPOMENSAJE $MENSAJE  >> "$LOGDIR"/$NAMEFILELOG.log
	fi
}

#---------------CODIGO---------------#

#---------------Valido que el script reciba 2 o a lo sumo 3 parametros---------------#
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
	echo "No se pudo loguear mensaje, cantidad de parametros incorrecta: $# "
	exit
fi


#---------------Evito que sea un log infinito, cuando llega a LOGSIZE trunca las primeras LOGBORRARHH-1 lineas---------------#
if [ "$COMANDO" = "MOVER" -o "$COMANDO" = "START" ]; then
	fatherOfFunction
fi	
LOGDIRSIZE=$(wc -l $LOGDIR/"$NAMEFILELOG".log 2> /dev/null | sed 's/ \/.*//') #Cantidad de lineas del log del parametro 1
if [ -n "$LOGDIRSIZE" ] && [ -n "$LOGSIZE" ]; then
	if [ "$LOGDIRSIZE" -ge "$LOGSIZE" ]; then # Si alcanzo el maximo de lineas
		sed -i '1,'$LOGBORRARHH' d' $LOGDIR/$NAMEFILELOG.log #Borro  desde la linea 1 hasta la linea LOGBORRARHH en el log correspondiente
	echo $FECHA $USER "LOG" "INFO" $MSGLOG >> $LOGDIR/$NAMEFILELOG.log
	fi
fi
	

#---------------Logueo en el lugar correspondiente---------------#
logInPlace 

exit 0
