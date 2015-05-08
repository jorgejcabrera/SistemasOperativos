#!/bin/bash

EXIT=0
SLEEP=10
MSG_FILE_ACCEPTED=" es válido y ha sido aceptado"
MSG_FILE_REJECTED=" no es válido y ha sido rechazado."
MAEDIR="/home/facundo/Escritorio/BBB/RecPro/MAEDIR" #PARA PRUEBAS UNICAMENTE
NOVEDIR="/home/facundo/Escritorio/BBB/RecPro/NOVEDIR" #PARA PRUEBAS UNICAMENTE
ACEPDIR="/home/facundo/Escritorio/BBB/RecPro/ACEPDIR" #PARA PRUEBAS UNICAMENTE
RECHDIR="/home/facundo/Escritorio/BBB/RecPro/RECHDIR" #PARA PRUEBAS UNICAMENTE
ARCH_MAE_GEST="/gestiones.mae"
ARCH_MAE_NORM="/normas.mae"
ARCH_MAE_EMI="/emisores.mae"
MAE_GEST="$MAEDIR$ARCH_MAE_GEST"
MAE_NORM="$MAEDIR$ARCH_MAE_NORM"
MAE_EMI="$MAEDIR$ARCH_MAE_EMI"

#Verifica que el archivo tenga formato válido y no esté vacío
checkFormatoArchivo(){
	TYPE=`file --mime-type "$PATH_ARCH"`
	TEXT="text"
	EMPTY="empty"
	if echo "$TYPE" | grep -q -i "$TEXT"; then #Se verifica que sean archivos de texto
		#Se verifica cantidad de "_" y que no comience ni termine el nombre del archivo en ese caracter.
		CANT_GUION_BAJO=`grep -o "_" <<<$ARCHIVO | wc -l`
		if [ $CANT_GUION_BAJO != 4 -o ${ARCHIVO:0:1} == "_" -o ${ARCHIVO: -5} == "_.txt" ]; then
			sh glog.sh RecPro "El nombre del archivo $ARCHIVO no es válido." ERR
			sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
			sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
			continue
		fi
	else
		if echo "$TYPE" | grep -q -i "$EMPTY"; then #Se verifica que el archivo no esté vacío
			sh glog.sh RecPro "El archivo $ARCHIVO está vacío." ERR
			sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
			sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
			continue
		else
			sh glog.sh RecPro "El archivo $ARCHIVO no tiene formato de texto." ERR
			sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
			sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
			continue
		fi
	fi
}

#Verifica que el código de gestión tenga formato válido
checkGestion(){
	COD_GESTION="$1"
	PATH_ARCH="$2"
	ARCHIVO="$3"
	ES_GESTION='^([a-zA-Z])+([a-zA-Z\ ])+([0-9])?$'
	if ! [[ $COD_GESTION =~ $ES_GESTION ]]; then
		sh glog.sh RecPro "El código de gestión del archivo $ARCHIVO no es válido." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
}

#Verifica que el código de norma tenga formato válido
checkNorma(){
	COD_NORMA=$1
	PATH_ARCH="$2"
	ARCHIVO="$3"
	ES_NORMA='^[A-Z][A-Z][A-Z]$'
	if ! [[ $COD_NORMA =~ $ES_NORMA ]]; then
		sh glog.sh RecPro "El código de norma del archivo $ARCHIVO no es válido." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
}

#Verifica que el código de emisor tenga formato válido
checkEmisor(){
	COD_EMISOR=$1
	PATH_ARCH="$2"
	ARCHIVO="$3"
	ES_NUMERO='^([0-9])+$'
	if ! [[ $COD_EMISOR =~ $ES_NUMERO ]]; then
		sh glog.sh RecPro "El código de emisor del archivo $ARCHIVO no es válido." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
}

#Verifica que el número de archivo tenga formato válido
checkNroArchivo(){
	NRO_ARCHIVO=$1
	PATH_ARCH="$2"
	ARCHIVO="$3"
	ES_NUMERO='^([0-9])+$'
	if ! [[ $NRO_ARCHIVO =~ $ES_NUMERO ]]; then
		sh glog.sh RecPro "El número del archivo $ARCHIVO no es válido." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
}

#Verifica que la fecha tenga formato válido
checkFecha(){
	FECHA=$1
	PATH_ARCH="$2"
	ARCHIVO="$3"
	ES_FECHA='^[0-3][0-9]-[0-1][0-9]-[0-2][0-9][0-9][0-9]$'
	if ! [[ $FECHA =~ $ES_FECHA ]]; then
		sh glog.sh RecPro "La fecha del archivo $ARCHIVO no es válida." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
}

#Verifica que el código de gestión esté en el archivo gestiones.mae
checkGestionExistente(){
	GREP_RETURN=$1
	PATH_ARCH="$2"
	ARCHIVO="$3"
	if [[ $GREP_RETURN != 0 ]]; then
		sh glog.sh RecPro "El código de gestión del archivo $ARCHIVO no se encuentra en el archivo gestiones.mae." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
}

#Verifica que el código de norma esté en el archivo normas.mae
checkNormaExistente(){
	GREP_RETURN=$1
	PATH_ARCH="$2"
	ARCHIVO="$3"
	if [[ $GREP_RETURN != 0 ]]; then
		sh glog.sh RecPro "El código de norma del archivo $ARCHIVO no se encuentra en el archivo normas.mae." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
}

#Verifica que el código de emisor esté en el archivo emisores.mae
checkEmisorExistente(){
	GREP_RETURN=$1
	PATH_ARCH="$2"
	ARCHIVO="$3"
	if [[ $GREP_RETURN != 0 ]]; then
		sh glog.sh RecPro "El código de emisor del archivo $ARCHIVO no se encuentra en el archivo emisores.mae." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
}

#Verifica que la fecha sea real
checkFechaValida(){
	DIA=$1
	MES=$2
	ANIO=$3
	PATH_ARCH="$4"
	ARCHIVO="$5"
	VALIDA=1;
	case $MES in
		01)
		if [ $DIA -gt 31 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		02)
		if [ $(($ANIO % 4)) -eq 0 ]; then
			if [ $DIA -gt 29 -o $DIA -lt 1 ]; then
				VALIDA=0;
			fi
		else
			if [ $DIA -gt 28 -o $DIA -lt 1 ]; then
				VALIDA=0;
			fi
		fi
		;;
		03)
		if [ $DIA -gt 31 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		04)
		if [ $DIA -gt 30 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		05)
		if [ $DIA -gt 31 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		06)
		if [ $DIA -gt 30 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		07)
		if [ $DIA -gt 31 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		08)
		if [ $DIA -gt 31 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		09)
		if [ $DIA -gt 30 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		10)
		if [ $DIA -gt 31 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		11)
		if [ $DIA -gt 30 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		12)
		if [ $DIA -gt 31 -o $DIA -lt 1 ]; then
			VALIDA=0;
		fi
		;;
		*)
			VALIDA=0;
		;;
	esac

	if [ $VALIDA -eq 0 ]; then
		sh glog.sh RecPro "La fecha del archivo $ARCHIVO no es válida." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue;
	fi
}

#Verifica que la fecha esté dentro de un rango válido
checkRangoFecha(){
	FECHA=$1
	PATH_ARCH="$2"
	ARCHIVO="$3"
	RESULT_GEST="$4"
	FECHA_INICIO=$( cut -d ';' -f 2 <<< "$RESULT_GEST" )
	FECHA_FIN=$( cut -d ';' -f 3 <<< "$RESULT_GEST" )

	#Se verifica que FECHA_FIN no sea nula. Si lo es, se carga la fecha del sistema
	ES_FECHA='^[0-3][0-9]/[0-1][0-9]/[0-2][0-9][0-9][0-9]$'
	if ! [[ $FECHA_FIN =~ $ES_FECHA ]]; then
		FECHA_FIN="$(date +'%d/%m/%Y')"
	fi

	#Parseo de las fechas
	DIA_INICIO=$( cut -d '/' -f 1 <<< "$FECHA_INICIO" )
	MES_INICIO=$( cut -d '/' -f 2 <<< "$FECHA_INICIO" )
	ANIO_INICIO=$( cut -d '/' -f 3 <<< "$FECHA_INICIO" )
	DIA_FIN=$( cut -d '/' -f 1 <<< "$FECHA_FIN" )
	MES_FIN=$( cut -d '/' -f 2 <<< "$FECHA_FIN" )
	ANIO_FIN=$( cut -d '/' -f 3 <<< "$FECHA_FIN" )
	DIA_ARCH=$( cut -d '-' -f 1 <<< "$FECHA" )
	MES_ARCH=$( cut -d '-' -f 2 <<< "$FECHA" )
	ANIO_ARCH=$( cut -d '-' -f 3 <<< "$FECHA" )

	#Se verifica que la fecha del archivo exista
	checkFechaValida $DIA_ARCH $MES_ARCH $ANIO_ARCH "$PATH_ARCH" "$ARCHIVO"

	#Comparacion de las fechas
	if [ $ANIO_INICIO -gt $ANIO_ARCH -o $ANIO_FIN -lt $ANIO_ARCH ]; then
		sh glog.sh RecPro "La fecha del archivo $ARCHIVO está fuera de rango." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
	if [ \( $ANIO_INICIO -eq $ANIO_ARCH -a $MES_INICIO -gt $MES_ARCH \) -o \( $ANIO_FIN -eq $ANIO_ARCH -a $MES_FIN -lt $MES_ARCH \) ]; then
		sh glog.sh RecPro "La fecha del archivo $ARCHIVO está fuera de rango." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
	if [ \( $ANIO_INICIO -eq $ANIO_ARCH -a $MES_INICIO -eq $MES_ARCH -a $DIA_INICIO -gt $DIA_ARCH \) -o \( $ANIO_FIN -eq $ANIO_ARCH -a $MES_FIN -eq $MES_ARCH -a $DIA_FIN -lt $DIA_ARCH \) ]; then
		sh glog.sh RecPro "La fecha del archivo $ARCHIVO está fuera de rango." ERR
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_REJECTED" ERR
		sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
		continue
	fi
}

#Verifica que la carpeta con el nombre de emisor exista y sino se crea en ACEPDIR
checkCarpetaExistente(){
	COD_GESTION="$1"
	PATH_ARCH="$2"
	ARCHIVO="$3"
	ACEPDIR_AUX="$ACEPDIR/$COD_GESTION"
	[ -e "$ACEPDIR_AUX" ]
	ACCEPT_RETURN=$?
	if [[ $ACCEPT_RETURN -eq 1 ]]
	then
		mkdir "$ACEPDIR_AUX"
		sh glog.sh RecPro "Se ha creado una nueva carpeta llamada $COD_GESTION en el directorio $ACEPDIR." INFO
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_ACCEPTED" INFO
		sh mover.sh "$PATH_ARCH" "$ACEPDIR_AUX" RecPro
	else
		sh glog.sh RecPro "$ARCHIVO $MSG_FILE_ACCEPTED" INFO
		sh mover.sh "$PATH_ARCH" "$ACEPDIR_AUX" RecPro
	fi
}

#Invoca a ProPro
invocarProPro(){
	#Si hay archivos en los subdirectorios de ACEPDIR, intenta invocar a ProPro
	ls "$ACEPDIR" | while read line; do
		if [ `ls "$ACEPDIR/$line" | wc -l` -gt 0 ]; then
			PROGRAMA="propro.sh"
			if ps ax | grep -v grep | grep -q $PROGRAMA
			then
				sh glog.sh RecPro "Invocación de ProPro pospuesta para el siguiente ciclo" INFO
			else
				bash propro.sh &
				wait $!
				CORRECTO=$?
				if [ $CORRECTO -eq 0 ]; then
					PID=$!
					sh glog.sh RecPro "ProPro corriendo bajo el no.: $PID" INFO
				else
					echo "Ocurrió un inconveniente al invocar a ProPro."
				fi
			fi	
			break;
		fi
	done
}

#Se verifica si NOVEDIR tiene archivos
while [ !$EXIT ]
do
	CANT_CICLOS=$((CANT_CICLOS + 1))
	sh glog.sh RecPro "Ciclo nro. $CANT_CICLOS" INFO
	while [ `ls "$NOVEDIR" | wc -l` -gt 0 ]
	do
		ARCHIVO=`ls "$NOVEDIR" | head -n 1` #Se obtiene el primer archivo de la lista
		PATH_ARCH=$NOVEDIR\/$ARCHIVO #Se obtiene su path

		#Se verifica el formato del archivo y que no esté vacío
		checkFormatoArchivo $PATH_ARCH $ARCHIVO

		#Parseo del nombre del archivo
		COD_GESTION=$( cut -d '_' -f 1 <<< "$ARCHIVO" )
		COD_NORMA=$( cut -d '_' -f 2 <<< "$ARCHIVO" )
		COD_EMISOR=$( cut -d '_' -f 3 <<< "$ARCHIVO" )
		NRO_ARCHIVO=$( cut -d '_' -f 4 <<< "$ARCHIVO" )
		FECHA=$( cut -d '_' -f 5 <<< "$ARCHIVO" | cut -d '.' -f 1 )
		checkGestion "$COD_GESTION" "$PATH_ARCH" "$ARCHIVO"
		checkNorma $COD_NORMA "$PATH_ARCH" "$ARCHIVO"
		checkEmisor $COD_EMISOR "$PATH_ARCH" "$ARCHIVO"
		checkNroArchivo $NRO_ARCHIVO "$PATH_ARCH" "$ARCHIVO"
		checkFecha $FECHA "$PATH_ARCH" "$ARCHIVO"

		#Se verifica que el código de gestión esté en el archivo gestiones.mae
		RESULT_GEST=$(grep ^"$COD_GESTION\;" $MAE_GEST)
		GREP_RETURN=$?
		checkGestionExistente $GREP_RETURN "$PATH_ARCH" "$ARCHIVO"

		#Se verifica que el codigo de norma este en el arhivo normas.mae
		grep -q ^$COD_NORMA\; $MAE_NORM
		GREP_RETURN=$?
		checkNormaExistente $GREP_RETURN "$PATH_ARCH" "$ARCHIVO"

		#Se verifica que el codigo de emisor este en el arhivo emisores.mae
		grep -q ^$COD_EMISOR\; $MAE_EMI
		GREP_RETURN=$?
		checkEmisorExistente $GREP_RETURN "$PATH_ARCH" "$ARCHIVO"

		#Se verifica que la fecha esté dentro de un rango válido
		checkRangoFecha $FECHA "$PATH_ARCH" "$ARCHIVO" "$RESULT_GEST"

		#El archivo es válido, entonces se mueve a la carpeta corresponiente
		#Se verifica que la carpeta con el nombre de emisor exista y sino se crea en ACEPDIR
		checkCarpetaExistente "$COD_GESTION" "$PATH_ARCH" "$ARCHIVO"

	done

	#Se invoca a ProPro en caso de ser necesario
	invocarProPro

	sleep $SLEEP #Pausa el daemon por SLEEP segundos
done
