#!/bin/bash
codeGestion="Alfonsin"

verifyValidDate () 
{

	local date=$1

	local day=$(echo $date | cut -d '-' -f 1)
	
	local month=$(echo $date | cut -d '-' -f 2)
	
	local year=$(echo $date | cut -d '-' -f 3)

	if [ $day -gt 31 -o $day -lt 1 -o $month -gt 12 -o $month -lt 1 ]; then
		echo 0
	else
		echo 1
	fi
}

countFiles="$(find ./ACEPDIR/$codeGestion -type f -printf x | wc -c)"

sh glog.sh PROPRO "Inicio de propro \n \t\t\t Cantidad de archivos a procesar: $countFiles" INFO

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

 			echo $validDate
 			
 			#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./PROCDIR/proc PROPRO

 		else

 			sh glog.sh PROPRO "Se rechaza el archivo. Emisor no habilitado en este tipo de norma" ERR
 		
 			#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
 		fi

 	else

 		sh glog.sh PROPRO "Se rechaza el archivo por estar DUPLICADO" ERR

 	fi
 	
done;

