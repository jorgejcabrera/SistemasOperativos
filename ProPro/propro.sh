#!/bin/bash
codeGestion="Alfonsin"

countFiles="$(find ./ACEPDIR/$codeGestion -type f -printf x | wc -c)"

sh glog.sh PROPRO "Inicio de propro \n \t\t\t Cantidad de archivos a procesar: $countFiles" INFO

for completeFileName in `ls ./ACEPDIR/$codeGestion/ | cut -d '_' -f 5 | sort -t - -k 3 -k 2 -k 1`; 
do 
 	completeFileName=$(find ./ACEPDIR/$codeGestion -type f -name "*$completeFileName" | cut -d '/' -f 4)
 	
 	yearNorm=$(echo $completeFileName | cut -d '-' -f 3 | cut -d '.' -f 1)

 	codeNorm=$(echo $completeFileName | cut -d '_' -f 2)

 	fileDocketedName="$yearNorm.$codeNorm"

 	fileAlreadyDocketed=$(find ./PROCDIR/proc/ -type f -name "$completeFileName" | cut -d '/' -f 4)

 	if [ -z $fileAlreadyDocketed ]; then

 		sh glog.sh PROPRO "Archivo a procesar $completeFileName" INFO

 		sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./PROCDIR/proc PROPRO

 	else

 		sh glog.sh PROPRO "Se rechaza el archivo por estar DUPLICADO" WAR

 	fi
 	
 	
 	
done;