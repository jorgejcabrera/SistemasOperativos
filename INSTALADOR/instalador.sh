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
fi
