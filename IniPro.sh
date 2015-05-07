#!/bin/bash

#Mensajes Varios
ERRORINSTALL="El programa no se ha instalado correctamente. Ejecute InsPro.sh y vuelva a intentarlo. Consulte README.txt para mas informacion."
MSGVARSINI="	Se encontraron Variables que ya han sido inicializadas. 
		Es probable que el programa ya se esté ejecutando."

echo "Inicializando sistema... "

#Obtengo el PATH completo del archivo de Configuración ( InsPro.conf )
SCRIPT=$(readlink -f "$BASH_SOURCE")
SCRIPTPATH=$(dirname "$SCRIPT")
PARENTDIR=${SCRIPTPATH%/bin*}
CONFDIR="$PARENTDIR/conf"
CONFIGFILE="$CONFDIR/InsPro.conf"

SYS_STATUS="OK"

#Verifico que CONFDIR sea un Directorio
if [ ! -d "$CONFDIR" ]; then
	echo $ERRORINSTALL
	echo "CONFDIR is not DIR"
	SYS_STATUS="ERROR"
	return 1
fi

#Verifico que CONFIGFILE sea un archivo
if [ ! -f "$CONFIGFILE" ]; then
	echo $ERRORINSTALL
	echo "CONFIGFILE is not FILE"
	SYS_STATUS="ERROR"
	return 1
fi

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
	chmod +x $GLOG
	if ! [ -x $GLOG ]; then
		echo "No se pudo dar permisos de ejecución al archivo $GLOG. Se corta la inicializacion del sistema."
		SYS_STATUS="ERROR"
		return 1
	fi
	echo "El Log ha sido configurado."
	sh $NAMEGLOG IniPro "Inicializando Sistema..." INFO
fi


# Check Vars Initialized: Verifico que las variables de ambiente no se encuentren inicializadas para la sesión actual. Con Logger
checkVarIni(){
	VARNAME=$1
	VAR=$2
	if [ -n "$VAR" ]; then
		echo $MSGVARSINI
		sh "$NAMEGLOG" IniPro "La variable de ambiente $VARNAME, ya ha sido inicializada." ERR
		SYS_STATUS="ERROR"
		return 1
	else
		sh "$NAMEGLOG" IniPro "Se verificó que la variable $VARNAME no se encuentra inicializada." INFO
	fi
}

checkVarIni "MAEDIR" $MAEDIR
checkVarIni "NOVEDIR" $NOVEDIR
checkVarIni "ACEPDIR" $ACEPDIR
checkVarIni "RECHDIR" $RECHDIR
checkVarIni "PROCDIR" $PROCDIR
checkVarIni "INFODIR" $INFODIR
checkVarIni "DUPDIR" $DUPDIR

if [ "$SYS_STATUS" = "ERROR" ]; then
	echo "Se termina la inicialización del sistema erróneamente."	
	return 1
fi

#Seteo las variables de directorios desde el archivo de Configuración ( InsPro.conf )
MAEDIR=$(grep "MAEDIR" $CONFIGFILE | cut -d "=" -f 2)
NOVEDIR=$(grep "NOVEDIR" $CONFIGFILE | cut -d "=" -f 2)
ACEPDIR=$(grep "ACEPDIR" $CONFIGFILE | cut -d "=" -f 2)
RECHDIR=$(grep "RECHDIR" $CONFIGFILE | cut -d "=" -f 2)
PROCDIR=$(grep "PROCDIR" $CONFIGFILE | cut -d "=" -f 2)
INFODIR=$(grep "INFODIR" $CONFIGFILE | cut -d "=" -f 2)
DUPDIR=$(grep "DUPDIR" $CONFIGFILE | cut -d "=" -f 2)

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
isFile "$BINDIR/demonioInfinito.sh"
isFile "$BINDIR/mover.sh"
isFile "$BINDIR/propro.sh"
isFile "$BINDIR/RecPro.sh"
isFile "$BINDIR/start.sh"
isFile "$BINDIR/stop.sh"

isDir "$MAEDIR"
isFile "$MAEDIR/emisores.mae"
isFile "$MAEDIR/normas.mae"
isFile "$MAEDIR/gestiones.mae"
isFile "$MAEDIR/tab/nxe.tab"
isFile "$MAEDIR/tab/axg.tab"

isDir "$NOVEDIR"
isDir "$ACEPDIR"
isDir "$RECHDIR"
isDir "$PROCDIR"
isDir "$INFODIR"
isDir "$LOGDIR"

if [ "$SYS_STATUS" = "ERROR" ]; then
	echo "Se termina la inicialización del sistema erróneamente."	
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


SYS_STATUS="INICIALIZADO"

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
export SYS_STATUS

echo "Desea ejecutar RecPro.sh? (S/N)"
read response
if [ "$response" = "S" ]; then
	bash "$BINDIR/RecPro.sh"
fi
echo "Fin IniPro.sh"
return 0

