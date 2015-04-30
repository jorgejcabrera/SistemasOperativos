#!/bin/bash

#Glog
#Parametro1 (obligatorio):comando (nombre del comando o funcion que genera el mensaje)
#Parametro2 (obligatorio): mensaje
#Parametro3 (obligatorio): Modulo que lo llama
#Parametro4 (opcional):tipo de mensaje [INFO,WAR,ERR]

LOGSIZE=100
LOGBORRARHH=51 #Borra hasta la linea n-1

#TODO FALTA HACER QUE SI ES DEL INSTALADOR LO LOGUEA EN OTRO LADO (PONERLE LOS DIRECTORIOS CDO ESTE TERMINADO EL INSTALADOR)
#LOG="InsPro.log"
#if [ $3 = "InsPro" ]; then
#TODO DONDE LOGEA EL INSTALADOR ???????	

#VALIDAMOS QUE EL SCRIPT RECIBA 3 O 4 PARAMETROS
if [ $# -gt 4 ] || [ $# -lt 3 ]; then
	echo "No se pudo loguear mensaje, cantidad de parametros incorrecta: $# " >> LOG
	exit
fi


#VALIDAMOS QUE EL CUARTO PARAMETRO SEA DEL TIPO INFO,WAR,ERR
if [ ! $4 ]; then # no existe el cuarto parametro
	echo "Tipo de mensaje no ingresado: Se toma el valor por defautl [INFO]" >> LOG
	tipoMensaje="INFO"
else # existe el cuarto parametro
	if [ $4 = "INFO" ] || [ $4 = "WAR" ] || [ $4 = "ERR" ]; then
		tipoMensaje=$4
	else
		echo "Tipo de mensaje invalido: Se toma el valor por defautl [INFO]" >> LOG
		tipoMensaje="INFO"	
	fi
fi

#Evito que sea un log infinito, cuando llega a LOGSIZE trunca las primeras LOGBORRARHH-1 lineas
cd ..   # vuelvo un directorio atras
LOGDIRSIZE=$(wc -l LOGDIR/$3 | sed 's/ LOGDIR\/'$3'//') #Cantidad de lineas del log del parametro 3
if [ $LOGDIRSIZE -ge $LOGSIZE ]; then # Si alcanzo el maximo de lineas
	sed -i '1,'$LOGBORRARHH' d' LOGDIR/$3 #Borro  desde la linea 1 hasta la linea LOGBORRARHH en el log correspondiente
fi
	

#Escribo el archivo
fecha=`date +"%X %x"`
comando=$1
mensaje=$2
#cd ..   # vuelvo un directorio atras
echo $fecha $USER $comando $tipoMensaje $mensaje  >> LOGDIR/$3 #TODO El path de logs debe ser determinado x la variable de configuracion LOGDIR

exit 0
