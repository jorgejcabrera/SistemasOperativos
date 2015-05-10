#! /bin/bash

verificar(){
	VARNAME=$1
	VAR=$2
	if [ -n "$VAR" ]; then
		echo "Se encontraron Variables que ya han sido inicializadas."
		echo "Es probable que el programa ya se esté ejecutando."
		echo "Si desea iniciar el programa, termine su sesión e ingrese nuevamente."
		sh glog.sh IniPro "La variable de ambiente $VARNAME, ya ha sido inicializada." ERR
		exit 1
	else
		sh glog.sh IniPro "Se verificó que la variable $VARNAME no se encuentra inicializada." INFO
		#echo "$VARNAME is empty"
	fi
}

#Ver si conviene hacer con un for y $1,..,$n
verificar "CONFDIR" $CONFDIR
verificar "BINDIR" $BINDIR
verificar "MAEDIR" $MAEDIR
verificar "NOVEDIR" $NOVEDIR
verificar "RECHDIR" $RECHDIR
verificar "PROCDIR" $PROCDIR
verificar "INFODIR" $INFODIR
verificar "DUPDIR" $DUPDIR
verificar "LOGDIR" $LOGDIR