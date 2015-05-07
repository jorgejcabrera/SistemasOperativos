#! /bin/bash

#1 verificar archivos MAEDIR

isDir(){
	VAR=$1
	if [ ! -d "$VAR" ]; then
		echo "#Indicar Pasos Instalación"
		return 1
	else
		return 0
	fi
}

isFile(){
	VAR=$1
	if [ ! -f "$VAR" ]; then
		echo "#Indicar Pasos Instalación"	
		return 1
	else
		return 0
	fi
}

isDir "$CONFDIR"
isFile "$CONFDIR/InsPro.conf"

isDir "$BINDIR"
isFile "$BINDIR/InsPro.sh"
isFile "$BINDIR/IniPro/IniPro.sh"
isFile "$BINDIR/RecPro.sh"
ifFile "$BINDIR/ProPro.sh"
ifFile "$BINDIR/InfPro.sh"
ifFile "$BINDIR/Stop.sh"
ifFile "$BINDIR/Start.sh"
ifFile "$BINDIR/glog.sh"
ifFile "$BINDIR/mover.sh"

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
isDir "$DUPDIR"
isDir "$LOGDIR"
