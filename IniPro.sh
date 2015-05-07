#! /bin/bash

#sh verifAmbIni.sh
RET_VALUE=$?
if [ "$RET_VALUE" -eq 1 ]; then
	echo "Finaliza la Ejecución de IniPro. Codigo de Error: $RET_VALUE"
	exit $RET_VALUE
fi

VARPATH=$PWD #Toma el path corriente

CONFFILE="$VARPATH/conf/InsPro.conf"
echo $CONFFILE

BINDIR=$(grep "BINDIR" $CONFFILE | cut -d "=" -f 2)
echo $BINDIR

BINDIR="$VARPATH/bin"

MAEDIR="$VARPATH/Maestros y Tablas"
NOVEDIR="$VARPATH/Novedades"
ACEPDIR="$VARPATH/Aceptados"
RECHDIR="$VARPATH/Rechazados"
PROCDIR="$VARPATH/Protocolizados"
INFODIR="$VARPATH/Informes"
DUPDIR="$VARPATH/Duplicados"
LOGDIR="$VARPATH/Logs"

#sh verifInstalacion.sh


