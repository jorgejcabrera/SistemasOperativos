#!/bin/bash

archivoMaestro="MAEDIR/gestiones.mae"

MAE_GEST=$archivoMaestro

codeGestion="Alfonsin"

verifyValidDate () 
{
	#TODO usar regular expresion para 

	local date=$1

	local day=$(echo $date | cut -d '-' -f 1)
	
	local month=$(echo $date | cut -d '-' -f 2)
	
	local year=$(echo $date | cut -d '-' -f 3)

	if [ $day -gt 31 -o $day -lt 1 -o $month -gt 12 -o $month -lt 1 ]; then
		echo 0	#la fecha es invalida
	else
		echo 1	#la fecha es valida
	fi
}

verifyValidDateGest () 
{
	local dayBegin=$(echo $1 | cut -d '/' -f 1)

	local monthBegin=$(echo $1 | cut -d '/' -f 2)

	local yearBegin=$(echo $1 | cut -d '/' -f 3)

	local dayEnd=$(echo $2 | cut -d '/' -f 1)

	local monthEnd=$(echo $2 | cut -d '/' -f 2)

	local yearEnd=$(echo $2 | cut -d '/' -f 3)

	local day=$(echo $3 | cut -d '-' -f 1)

	local month=$(echo $3 | cut -d '-' -f 2)

	local year=$(echo $3 | cut -d '-' -f 3)

	#Comparacion de las fechas

	if [ $yearBegin -gt $year -o $yearEnd -lt $year -o \( $yearBegin -eq $year -a $monthBegin -gt $month \) -o \( $yearEnd -eq $year -a $monthEnd -lt $month \) -o \( $monthBegin -eq $month -a $dayBegin -gt $day \) -o \( $monthEnd -eq $month -a $dayEnd -lt $day \) ]; then
		echo 0
		break
	fi
	echo 1
}

countFiles="$(find ./ACEPDIR/$codeGestion -type f -printf x | wc -c)"

sh glog.sh PROPRO "Inicio de propro \n \t\t\t Cantidad de archivos a procesar: $countFiles" INFO

RESULT_GEST=$(grep ^$codeGestion\; $MAE_GEST)

for completeFileName in `ls ./ACEPDIR/$codeGestion/ | cut -d '_' -f 5 | sort -t - -k 3 -k 2 -k 1`; do 
 	
 	completeFileName=$(find ./ACEPDIR/$codeGestion -type f -name "*$completeFileName" | cut -d '/' -f 4)

 	fileAlreadyDocketed=$(find ./PROCDIR/proc/ -type f -name "$completeFileName" | cut -d '/' -f 4)

 	if [ -z $fileAlreadyDocketed ]; then

 		sh glog.sh PROPRO "Archivo a procesar $completeFileName" INFO

 		codeNorm=$(echo $completeFileName | cut -d '_' -f 2)

 		codeEmisor=$(echo  $completeFileName | cut -d '_' -f 3)

 		existCodeNormAndCodEmisorCombination=$(find ./MAEDIR/tab/nxe.tab -type f -print | xargs grep "$codeNorm;$codeEmisor")

 		if [ ! -z $existCodeNormAndCodEmisorCombination ]; then

 			yearNorm=$(echo $completeFileName | cut -d '-' -f 3 | cut -d '.' -f 1)

 			fileDocketedName="$yearNorm.$codeNorm"

 			date=$(echo $completeFileName | cut -d '_' -f 5 | cut -d '.' -f 1)

 			validDate=$(verifyValidDate $date)

 			if [ $validDate -eq 1 ]; then
 				
 				firstDate=$(echo $RESULT_GEST | cut -d ';' -f 2)

 				secondDate=$(echo $RESULT_GEST | cut -d ';' -f 3)

 				verifyValidDateGest=$(verifyValidDateGest $firstDate $secondDate $date)

 				if [ $verifyValidDateGest -eq 1 ]; then

 					sh glog.sh PROPRO "la fecha es es valida, corresponde al codigo de gestion" INFO
 			
 					#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./PROCDIR/proc PROPRO

 				else
 					sh glog.sh PROPRO "La fecha del archivo está fuera de rango." ERR
					sh glog.sh PROPRO "archivo rechazado" ERR
					#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
					continue
 				fi
 			
 			else
 				sh glog.sh PROPRO "Se rechaza el archivo por tener fecha invalida" ERR
 				#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
 				continue
 			fi

 		else

 			sh glog.sh PROPRO "Se rechaza el archivo. Emisor no habilitado en este tipo de norma" ERR
 			#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
 			continue
 		fi

 	else
 		sh glog.sh PROPRO "Se rechaza el archivo por estar DUPLICADO" ERR
 		continue
 	fi
 	
done;

