#!/bin/bash

#Mensajes Varios
ERRORINSTALL="El programa no se ha instalado correctamente. Intente realizar la instalación nuevamente. Consulte el archivo README.txt para mas informacion."
MSGVARSINI="El programa no ha podido realizar la inicialización correctamente. Vuelva a instalar el programa. Consulte el archivo README.txt para mas informacion."

if [ "$SYS_STATUS" = "INICIALIZADO" ]; then
	echo "El programa ya se ha iniciado."
	echo "Desea ejecutar RecPro.sh? (S/N)"
	read response
	if [ "$response" = "S" ] || [ "$response" = "s" ]; then
		echo "Se ejecutará la función RecPro."
		start.sh RecPro.sh
	fi	
	echo "Fin IniPro.sh"
	return 0
fi

if [ "$SYS_STATUS" = "ERROR" ]; then
	echo $ERRORINSTALL
	return 1
fi

echo "Inicializando sistema... "
#Obtengo el PATH completo del archivo de Configuración ( InsPro.conf )
SCRIPT=$(readlink -f "$BASH_SOURCE")
SCRIPTPATH=$(dirname "$SCRIPT")
PARENTDIR=${SCRIPTPATH%/bin*}
CONFDIR="$PARENTDIR/conf"
CONFIGFILE="$CONFDIR/InsPro.conf"

#Verifico que CONFDIR sea un Directorio
if [ ! -d "$CONFDIR" ]; then
	echo $ERRORINSTALL
	echo "CONFDIR is not DIR"
	SYS_STATUS="ERROR"
	return 1
fi

chmod 774 "$CONFDIR"

#Verifico que CONFIGFILE sea un Archivo
if [ ! -f "$CONFIGFILE" ]; then
	echo $ERRORINSTALL
	echo "CONFIGFILE is not FILE"
	SYS_STATUS="ERROR"
	return 1
fi

chmod 774 "$CONFIGFILE"

# Check LOGDIR is empty
if [ -n "$LOGDIR" ]; then
	echo $MSGVARSINI
	echo "La variable de ambiente LOGDIR, ya ha sido inicializada."		
	SYS_STATUS="ERROR"
	return 1
fi

# Charge LOGDIR
LOGDIR=$(grep "LOGDIR" $CONFIGFILE | cut -d "=" -f 2)

# Check LOGDIR is DIR
if [ ! -d "$LOGDIR" ]; then
	echo $ERRORINSTALL
	echo "LOGDIR is not DIR"
	SYS_STATUS="ERROR"
	return 1
fi

chmod 774 "$LOGDIR"

echo "Se ha configurado el directorio LOG."

export LOGDIR

#Charge BINDIR
BINDIR=$(grep "BINDIR" $CONFIGFILE | cut -d "=" -f 2)

#Check BINDIR is DIR
if [ ! -d "$BINDIR" ]; then
	echo $ERRORINSTALL
	echo "BINDIR is not DIR"
	SYS_STATUS="ERROR"
	return 1
fi

chmod 774 "$BINDIR"

echo "Se ha configurado el directorio BIN."
PATH="$PATH:$BINDIR"
echo "Se ha seteado el PATH."

#Charge GLOG
GLOG="$BINDIR/glog.sh"
NAMEGLOG="glog.sh"

#Check GLOG is FILE
if [ ! -f "$GLOG" ]; then
	echo $ERRORINSTALL
	SYS_STATUS="ERROR"
	return 1
fi

# Check GLOG.sh have permissions
if ! [ -x $GLOG ]; then
	chmod 777 $GLOG
	if ! [ -x $GLOG ]; then
		echo "No se pudo dar permisos de ejecución al archivo $GLOG. Se corta la inicializacion del sistema."
		SYS_STATUS="ERROR"
		return 1
	fi
	glog.sh IniPro "Inicializando Sistema..." INFO
fi

echo "El Log ha sido configurado."

# Check Vars Initialized: Verifico que las variables de ambiente no se encuentren inicializadas para la sesión actual. Con Logger
checkVarIni(){
	VARNAME=$1
	VAR=$2
	if [ -n "$VAR" ]; then
		echo $MSGVARSINI
		glog.sh IniPro "La variable de ambiente $VARNAME, ya ha sido inicializada." ERR
		SYS_STATUS="ERROR"
		return 1
	else
		glog.sh IniPro "Se verificó que la variable $VARNAME no se encuentra inicializada." INFO
	fi
}

checkVarIni "LOGSIZE" $LOGSIZE
checkVarIni "MAEDIR" $MAEDIR
checkVarIni "NOVEDIR" $NOVEDIR
checkVarIni "ACEPDIR" $ACEPDIR
checkVarIni "RECHDIR" $RECHDIR
checkVarIni "PROCDIR" $PROCDIR
checkVarIni "INFODIR" $INFODIR
checkVarIni "DUPDIR" $DUPDIR
checkVarIni "GRUPO" $GRUPO

if [ "$SYS_STATUS" = "ERROR" ]; then
	echo "Se termina la inicialización del sistema erróneamente."	
	return 1
fi

#Seteo las variables de directorios desde el archivo de Configuración ( InsPro.conf )
GRUPO=$(grep "GRUPO" $CONFIGFILE | cut -d "=" -f 2)
MAEDIR=$(grep "MAEDIR" $CONFIGFILE | cut -d "=" -f 2)
NOVEDIR=$(grep "NOVEDIR" $CONFIGFILE | cut -d "=" -f 2)
ACEPDIR=$(grep "ACEPDIR" $CONFIGFILE | cut -d "=" -f 2)
RECHDIR=$(grep "RECHDIR" $CONFIGFILE | cut -d "=" -f 2)
PROCDIR=$(grep "PROCDIR" $CONFIGFILE | cut -d "=" -f 2)
INFODIR=$(grep "INFODIR" $CONFIGFILE | cut -d "=" -f 2)
DUPDIR=$(grep "DUPDIR" $CONFIGFILE | cut -d "=" -f 2)
LOGSIZE=$(grep "LOGSIZE" $CONFIGFILE | cut -d "=" -f 2)

#Funciones Varias
isDir(){
	VAR=$1
	if [ ! -d "$VAR" ]; then
		echo "ERROR: no es DIR $VAR"
		SYS_STATUS="ERROR"
		return 1
	fi
}

isFile(){
	VAR=$1
	if [ ! -f "$VAR" ]; then
		echo "ERROR: no es FILE $VAR"
		SYS_STATUS="ERROR"		
		return 1
	fi
}

# Check Install: Verifico que la instalación esté completa ( que no falte ningún archivo ni directorio )
isFile "$BINDIR/mover.sh"
chmod 777 "$BINDIR/mover.sh"
isFile "$BINDIR/propro.sh"
chmod 777 "$BINDIR/propro.sh"
isFile "$BINDIR/RecPro.sh"
chmod 777 "$BINDIR/RecPro.sh"
isFile "$BINDIR/start.sh"
chmod 777 "$BINDIR/start.sh"
isFile "$BINDIR/stop.sh"
chmod 777 "$BINDIR/stop.sh"

isDir "$MAEDIR"
chmod 774 "$MAEDIR"
isFile "$MAEDIR/emisores.mae"
chmod 774 "$MAEDIR/emisores.mae"
isFile "$MAEDIR/normas.mae"
chmod 774 "$MAEDIR/normas.mae"
isFile "$MAEDIR/gestiones.mae"
chmod 774 "$MAEDIR/gestiones.mae"
isFile "$MAEDIR/tab/nxe.tab"
chmod 774 "$MAEDIR/tab/nxe.tab"
isFile "$MAEDIR/tab/axg.tab"
chmod 774 "$MAEDIR/tab/axg.tab"

isDir "$NOVEDIR"
chmod 774 "$NOVEDIR"
isDir "$ACEPDIR"
chmod 774 "$ACEPDIR"
isDir "$RECHDIR"
chmod 774 "$RECHDIR"
isDir "$PROCDIR"
chmod 774 "$PROCDIR"
isDir "$INFODIR"
chmod 774 "$INFODIR"
isDir "$LOGDIR"
chmod 774 "$LOGDIR"

if [ "$SYS_STATUS" = "ERROR" ]; then
	echo "$ERRORINSTALL"
	echo "Se termina la inicialización del sistema erróneamente."
	glog.sh IniPro "Se prudujo un error en la instalación. No se encuentran los archivos o directorios necesarios para la ejecución. Se debe volver a instalar el programa." ERR
	return 1
fi

# Check Permisos
for var in $BINDIR/*
do
	if ! [ -x $var ]; then
		chmod +x $var
		if ! [ -x $var ]; then
			echo "No se pudo dar permisos de ejecución al archivo $var"
			echo $ERRORINSTALL
			glog.sh IniPro "No se pudo dar permisos de ejecución al archivo $var" ERR
			SYS_STATUS="ERROR"
			return 1
		fi
	fi
done

#for var in $PARENTDIR/*
#do
#	chmod -R 777 $var
#		echo $var
#done

export CONFDIR
export LOGDIR
export BINDIR
export GLOG
export NAMEGLOG
export ACEPDIR
export MAEDIR
export NOVEDIR
export RECHDIR
export PROCDIR
export INFODIR
export DUPDIR
export GRUPO
export LOGSIZE

SYS_STATUS="INICIALIZADO"
export SYS_STATUS

echo "Inicialización finalizada."
echo "Desea ejecutar RecPro.sh? (S/N)"
read response
if [ "$response" = "S" ] || [ "$response" = "s" ]; then
	echo "Se ejecutará la función RecPro."
	start.sh RecPro.sh
fi
echo "Fin IniPro.sh"
return 0

