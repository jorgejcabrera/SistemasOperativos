#!/bin/bash
#Glog
#Parametro1 (obligatorio):comando (nombre del comando o funcion que genera el mensaje)
#Parametro2 (obligatorio): mensaje
#Parametro3 (opcional):tipo de mensaje [INFO,WAR,ERR]

#FALTA HACER QUE SI ES DEL INSTALADOR LO LOGUEA EN OTRO LADO (PONERLE LOS DIRECTORIOS CDO ESTE TERMINADO EL INSTALADOR)

#VALIDAMOS QUE EL SCRIPT RECIBA 2 O 3 PARAMETROS
log="InsPro.log"

if [ $# -gt 3 ] || [ $# -lt 2 ]; then
	echo "No se pudo loguear mensaje, cantidad de parametros incorrecta: $# " >> log
	exit
fi

#VALIDAMOS QUE EL TERCER PARAMETRO SEA DEL TIPO INFO,WAR,ERR
if [ ! $3 ]; then # no existe el tercer parametro
	echo "Tipo de mensaje no ingresado: Se toma el valor por defautl [INFO]" >> log
	tipoMensaje="INFO"
else # existe el tercer parametro
	if [ $3 = "INFO" ] || [ $3 = "WAR" ] || [ $3 = "ERR" ]; then
		tipoMensaje=$3
	else
		echo "Tipo de mensaje invalido: Se toma el valor por defautl [INFO]" >> log
		tipoMensaje="INFO"	
	fi
fi

#FALTA HACER QUE NO SEA UN LOG INFINITO

#Escribo el archivo
fecha=`date +"%X %x"`
comando=$1
mensaje=$2
echo $fecha $USER $comando $mensaje $tipoMensaje >> log
