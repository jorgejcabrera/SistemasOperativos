EXIT=0
SLEEP=600
MSG_FILE_ACCEPTED="El archivo es válido. Ha sido movido al directorio de archivos aceptados."
MSG_FILE_REJECTED="El archivo no es válido. Ha sido movido al directorio archivos rechazados."
MAEDIR="/home/facundo/Escritorio/Pruebas/Maestros" #PARA PRUEBAS UNICAMENTE
NOVEDIR="/home/facundo/Escritorio/Pruebas/Novedades" #PARA PRUEBAS UNICAMENTE
ACEPDIR="/home/facundo/Escritorio/Pruebas/Aceptados" #PARA PRUEBAS UNICAMENTE
RECHDIR="/home/facundo/Escritorio/Pruebas/Rechazados" #PARA PRUEBAS UNICAMENTE
ARCH_MAE_GEST="/gestiones.mae"
ARCH_MAE_NORM="/normas.mae"
ARCH_MAE_EMI="/emisores.mae"
MAE_GEST=$MAEDIR$ARCH_MAE_GEST
MAE_NORM=$MAEDIR$ARCH_MAE_NORM
MAE_EMI=$MAEDIR$ARCH_MAE_EMI

#Se verifica si NOVEDIR tiene archivos
while [ !$EXIT ]
do
	CANT_CICLOS=$((CANT_CICLOS + 1))
	sh glog.sh RecPro "Ciclo nro. $CANT_CICLOS" INFO
	while [ `ls "$NOVEDIR" | wc -l` -gt 0 ]
	do
		ARCHIVO=`ls "$NOVEDIR" | head -n 1` #Se obtiene el primer archivo de la lista
		PATH_ARCH=$NOVEDIR\/$ARCHIVO #Se obtiene su path
		if [ ${ARCHIVO: -4} == ".txt" ] #Se verifica que sean archivos de texto (.txt)
		then
			#Se verifica cantidad de "_" y que no comience ni termine el nombre del archivo en ese caracter.
			CANT_GUION_BAJO=`grep -o "_" <<<"$ARCHIVO" | wc -l`
			if [ $CANT_GUION_BAJO != 4 -o ${ARCHIVO:0:1} == "_" -o ${ARCHIVO: -5} == "_.txt" ]
			then
				sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
				sh glog.sh RecPro "El nombre del archivo $ARCHIVO no es válido." ERR
				sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
			else
				#Parseo del nombre del archivo
				COD_GESTION=$( cut -d '_' -f 1 <<< "$ARCHIVO" )
				COD_NORMA=$( cut -d '_' -f 2 <<< "$ARCHIVO" )
				COD_EMISOR=$( cut -d '_' -f 3 <<< "$ARCHIVO" )
				NRO_ARCHIVO=$( cut -d '_' -f 4 <<< "$ARCHIVO" )
				FECHA=$( cut -d '_' -f 5 <<< "$ARCHIVO" )
				FECHA=$( cut -d '.' -f 1 <<< "$FECHA" )

				ES_GESTION='+([A-Z])*([a-z])?([0-9])'
				ES_NUMERO='+([0-9])'
				ES_NORMA='[A-Z][A-Z][A-Z]'
				ES_FECHA='[0-3][0-9]-[0-1][0-9]-[0-2][0-9][0-9][0-9]'
				if [[ $COD_GESTION != $ES_GESTION ]]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "El código de gestión del archivo $ARCHIVO no es válido." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi
				if [[ $COD_NORMA != $ES_NORMA ]]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "El código de norma del archivo $ARCHIVO no es válido." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi
				if [[ $COD_EMISOR != $ES_NUMERO ]]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "El código de emisor del archivo $ARCHIVO no es válido." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi
				if [[ $NRO_ARCHIVO != $ES_NUMERO ]]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "El número del archivo $ARCHIVO no es válido." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi
				if [[ $FECHA != $ES_FECHA ]]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "La fecha del archivo $ARCHIVO no es válida." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi

				#Se verifica que el codigo de gestion este en el arhivo gestiones.mae
				RESULT_GEST=$(grep ^$COD_GESTION\; $MAE_GEST)
				GREP_RETURN=$?
				if [[ $GREP_RETURN != 0 ]]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "El código de gestión del archivo $ARCHIVO no se encuentra en el archivo gestiones.mae." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi

				#Se verifica que el codigo de norma este en el arhivo normas.mae
				grep -q ^$COD_NORMA\; $MAE_NORM
				GREP_RETURN=$?
				if [[ $GREP_RETURN != 0 ]]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "El código de norma del archivo $ARCHIVO no se encuentra en el archivo normas.mae." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi

				#Se verifica que el codigo de emisor este en el arhivo emisores.mae
				grep -q ^$COD_EMISOR\; $MAE_EMI
				GREP_RETURN=$?
				if [[ $GREP_RETURN != 0 ]]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "El código de emisor del archivo $ARCHIVO no se encuentra en el archivo emisores.mae." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi

				#Se verifica que la fecha este dentro de un rango valido
				FECHA_INICIO=$( cut -d ';' -f 2 <<< "$RESULT_GEST" )
				FECHA_FIN=$( cut -d ';' -f 3 <<< "$RESULT_GEST" )
		
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

				#Comparacion de las fechas
				if [ $ANIO_INICIO -gt $ANIO_ARCH -o $ANIO_FIN -lt $ANIO_ARCH ]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "La fecha del archivo $ARCHIVO está fuera de rango." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi
				if [ \( $ANIO_INICIO -eq $ANIO_ARCH -a $MES_INICIO -gt $MES_ARCH \) -o \( $ANIO_FIN -eq $ANIO_ARCH -a $MES_FIN -lt $MES_ARCH \) ]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "La fecha del archivo $ARCHIVO está fuera de rango." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi
				if [ \( $MES_INICIO -eq $MES_ARCH -a $DIA_INICIO -gt $DIA_ARCH \) -o \( $MES_FIN -eq $MES_ARCH -a $DIA_FIN -lt $DIA_ARCH \) ]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "La fecha del archivo $ARCHIVO está fuera de rango." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi

				#Se verifica que el archivo no esté vacío
				[ -s $PATH_ARCH ]
				EMPTY_RETURN=$?
				if [[ $EMPTY_RETURN -eq 1 ]]
				then
					sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
					sh glog.sh RecPro "El archivo $ARCHIVO está vacío." ERR
					sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
					continue
				fi

				#El archivo es válido, entonces se mueve a la carpeta corresponiente
				#Se verifica que la carpeta con el nombre de emisor exista y sino se crea en ACEPDIR
				ACEPDIR_AUX=$ACEPDIR\/$COD_GESTION
				[ -e $ACEPDIR_AUX ]
				ACCEPT_RETURN=$?
				if [[ $ACCEPT_RETURN -eq 1 ]]
				then
					mkdir $ACEPDIR_AUX
					sh glog.sh RecPro "Se ha creado una nueva carpeta llamada $COD_GESTION en el directorio $ACEPDIR." INFO
					sh glog.sh RecPro "Archivo $ARCHIVO aceptado y almacenado en el subdirectorio $COD_GESTION de $ACEPDIR." INFO
					sh mover.sh "$PATH_ARCH" "$ACEPDIR_AUX" RecPro
					sh glog.sh RecPro "$MSG_FILE_ACCEPTED" INFO
				else
					sh mover.sh "$PATH_ARCH" "$ACEPDIR_AUX" RecPro
					sh glog.sh RecPro "$MSG_FILE_ACCEPTED" INFO
				fi


				#FALTA CHEQUEO DE FECHA (desde-hasta)
			fi
		else
			sh mover.sh "$PATH_ARCH" "$RECHDIR" RecPro
			sh glog.sh RecPro "El archivo $ARCHIVO no tiene formato de texto." ERR
			sh glog.sh RecPro "$MSG_FILE_REJECTED" ERR
		fi
	done
	#Se invoca a ProPro 
	PROGRAMA="ProPro.sh"
	if ps ax | grep -v grep | grep -q $PROGRAMA
	then
		#sh ProPro.sh #Ver que parametros pasarle
		sh glog.sh RecPro "Invocación de ProPro pospuesta para el siguiente ciclo" INFO
	else
		PID=$(pgrep -f $PROGRAMA)
		sh glog.sh RecPro "ProPro corriendo bajo el no.: $PID" INFO
	fi
	sleep $SLEEP #Pausa el daemon por SLEEP segundos
done
