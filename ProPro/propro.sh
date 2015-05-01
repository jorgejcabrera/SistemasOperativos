#!/bin/bash
countFiles="$(find ./ACEPDIR/$codeGestion -type f -printf x | wc -c)"
archivoMaestro="MAEDIR/gestiones.mae"
archivoDeContadores="MAEDIR/tab/axg.tab"
archivoDeEmisores="MAEDIR/emisores.mae"
MAE_GEST=$archivoMaestro
MAE_COUNT_FILE=$archivoDeContadores
MAE_EMISOR=$archivoDeEmisores
codeGestion="Alfonsin"

sh glog.sh PROPRO "Inicio de propro \n \t\t\t Cantidad de archivos a procesar: $countFiles" INFO

RESULT_GEST=$(grep ^$codeGestion\; $MAE_GEST)																				#obtengo de gestiones.mae la linea correspondiente a la gestion a protocolizar	

#PRE: recibe como parametro una fecha con el formato dia-mes-anio
#POST: devuelve 0 si la fecha tiene un formato invalido y 1 si el formato es valido
validateDate () 
{
	#TODO usar regular expresion para validar la fecha
	local date=$1 																											#la fecha tiene forma dia-mes-anio
	local day=$(echo $date | cut -d '-' -f 1)																				#parseo para obtener el dia de la fecha
	local month=$(echo $date | cut -d '-' -f 2) 																			#parseo para obtener el mes de la fecha
	local year=$(echo $date | cut -d '-' -f 3) 																				#parseo para obtener el anio de la fecha

	if [ $day -gt 31 -o $day -lt 1 -o $month -gt 12 -o $month -lt 1 ]; then
		echo 0																												#la fecha no es valida
	else
		echo 1																												#la fecha es valida
	fi
}

#PRE: recibe como parametro la fecha de comienzo y fin de la gestion que se esta procesando, y la fecha que esta en el nombre del archivo
#POST: devuelve 0 si la fecha no esta dentro del periodo de la gestion(invalida), devuelve 1 si la fecha esta dentro de la gestion(valida)
validateDateOnGest () 
{
	#la fecha de inicio de gestion, que es la que esta en gestiones.mae tiene formato dia/mes/anio, pero la fecha que esta
	#en el nombre del archivo a protocolizar tiene formato dia-mes-anio con lo cual se parsean distinto
	local dayBegin=$(echo $1 | cut -d '/' -f 1)			
	local monthBegin=$(echo $1 | cut -d '/' -f 2)
	local yearBegin=$(echo $1 | cut -d '/' -f 3)
	local dayEnd=$(echo $2 | cut -d '/' -f 1)
	local monthEnd=$(echo $2 | cut -d '/' -f 2)
	local yearEnd=$(echo $2 | cut -d '/' -f 3)
	local day=$(echo $3 | cut -d '-' -f 1)
	local month=$(echo $3 | cut -d '-' -f 2)
	local year=$(echo $3 | cut -d '-' -f 3)

	if [ $yearBegin -gt $year -o $yearEnd -lt $year -o \( $yearBegin -eq $year -a $monthBegin -gt $month \) -o \( $yearEnd -eq $year -a $monthEnd -lt $month \) -o \( $monthBegin -eq $month -a $dayBegin -gt $day \) -o \( $monthEnd -eq $month -a $dayEnd -lt $day \) ]; then
		echo 0
	else 
		echo 1
	fi
}

for completeFileName in `ls ./ACEPDIR/$codeGestion/ | cut -d '_' -f 5 | sort -t - -k 3 -k 2 -k 1`; do 
 	
 	completeFileName=$(find ./ACEPDIR/$codeGestion -type f -name "*$completeFileName" | cut -d '/' -f 4)
 	fileAlreadyDocketed=$(find ./PROCDIR/proc/ -type f -name "$completeFileName" | cut -d '/' -f 4)								#me fijo si el archivo ya fue protocolizado
 	if [ -z $fileAlreadyDocketed ]																								#si el archivo no fue protocolizado, el find no nos retorna nada, y el string esta vacio
 	then

 		sh glog.sh PROPRO "Archivo a procesar $completeFileName" INFO
 		codeNorm=$(echo $completeFileName | cut -d '_' -f 2)																	#obtengo el codigo de norma del nombre del archivo
 		codeEmisor=$(echo  $completeFileName | cut -d '_' -f 3)																	#obtengo el codigo de emisor del nombre del archivo
 		existCodeNormAndCodEmisorCombination=$(find ./MAEDIR/tab/nxe.tab -type f -print | xargs grep "$codeNorm;$codeEmisor")	#me fijo si existe la combinacion de codigo de norma y emisor en la tabla nxe
 		if [ ! -z $existCodeNormAndCodEmisorCombination ]; then																	#si existe la combinacion, levanta la linea entera y el string no esto vacio

 			yearNorm=$(echo $completeFileName | cut -d '-' -f 3 | cut -d '.' -f 1)												#obtengo el año que esta en el nombre del archivo
 			fileDocketedName="$yearNorm.$codeNorm"																				#concateno el año de la norma con el codigo de norma para generar el nombre del archivo a protocolizar
 			date=$(echo $completeFileName | cut -d '_' -f 5 | cut -d '.' -f 1)
 			if [ $(validateDate $date) -eq 1 ]; then																			#me fijo si la fecha en el nombre del archivo a protocolizar es valida
 				
 				dateBegin=$(echo $RESULT_GEST | cut -d ';' -f 2)																#obtengo la fecha de comienzo de la gesiton
 				dateEnd=$(echo $RESULT_GEST | cut -d ';' -f 3)																	#obtengo la fecha de finalizacion de la gestion
 				if [ $(validateDateOnGest $dateBegin $dateEnd $date) -eq 1 ]; then												#me fijo si la fecha esta dentro del rango de la gestion												

 					typeGest=$(echo $RESULT_GEST | cut -d ';' -f 5)																#me fijo que tipo de gestion es, si es la actual, me devuelve 1 sino es un registro historico y me devuelve 0
 					if [ $typeGest -eq 0 ]; then																				#proceso un tipo de registro historico: tengo que validarlo
 						
 						resultNumberNorm=$(grep "\<$codeGestion.*\<$codeNorm" $MAE_COUNT_FILE)									#obtengo de la tabla de contadores por año de gestion la linea correspondiente al codigo de gestion y codigo de norma
 						if [ ! -z $resultNumberNorm ]; then																		#puede ocurrir que no se encuntre la linea que combina el codigo de norma y gestion y en ese caso el string estaria vacio
 							numberNorm=$(echo $resultNumberNorm | cut -d ';' -f 6)												#parseo la linea para quedarme solo con el numero de norma
 							typeRegister=$(echo $RESULT_GEST | cut -d ';' -f 5)													#me fijo si es un archivo historico y corriente obteniendo el campo autoenumera de gestiones.mae
 							codFirma=$(grep "^$codeEmisor" $MAE_EMISOR | cut -d ';' -f 3)										#obtengo el codigo de firma correspondiente al codigo de emisor en el nombre del archivo												
 							codFirmaIntoFile=$(head -n 1 "ACEPDIR/$codeGestion/$completeFileName" | grep $codFirma | cut -d ';' -f 8) #busco el codigo de firma dentro del archivo
 							echo $completeFileName
 							echo $codFirmaIntoFile

 							if [ $numberNorm -lt 0 -a $typeRegister -eq 0 ]; then												#si el numero de norma es menor a 0 es invalido
 								sh glog.sh PROPRO "El numero de norma $numberNorm es invalido. Se rechaza el archivo" ERR
 								#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
 								continue
 							#else
 																																#el numero de norma es mayor a 0 y se considera valido
 							fi
 						fi
 					fi																				
 					#sh glog.sh PROPRO "La fecha $date está dentro del rango de la gestion $codeGestion" INFO
 					#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./PROCDIR/proc PROPRO
 				else
 					sh glog.sh PROPRO "La fecha $date está fuera del rango de la gestion $codeGestion" ERR
					sh glog.sh PROPRO "Archivo $completeFileName rechazado" ERR
					#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
					continue
 				fi 			
 			else
 				sh glog.sh PROPRO "La fecha $date tiene un formato invalido. Se rechaza el archivo" ERR							#la fecha tiene un formato invalido: loggeamos el evento
 				#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO 											#rechazamos el archivo moviendolo a ./RECHDIR
 				continue
 			fi
 		else
 			sh glog.sh PROPRO "Emisor $codeEmisor no habilitado para la norma $codeNorm. Se rechaza el archivo" ERR
 			#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
 			continue
 		fi
 	else
 		sh glog.sh PROPRO "Se rechaza el archivo $completeFileName por estar DUPLICADO" ERR										#el archivo que se recibe como parametro ya fue protocolizado
 		#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO 													#rechazamos el archivo moviendolo a ./RECHDIR
 		continue
 	fi
done;

