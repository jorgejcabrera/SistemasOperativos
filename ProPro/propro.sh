#!/bin/bash
countFiles="$(find ./ACEPDIR/Alfonsin -type f -printf x | wc -c)"
sh glog.sh PROPRO "Inicio de propro \n \t\t\t Cantidad de archivos a procesar: $countFiles" INFO
for filename in `ls ./ACEPDIR/Alfonsin/ | cut -d '_' -f 5 | sort -t - -k 3 -k 2 -k 1`; 
do 
	#protocolizar cada archivo
 	currentFileName=$(find ./ACEPDIR/Alfonsin -type f -name "*$filename")
 	resultado=$( echo $currentFileName | cut -d '/' -f 4 )
 	sh glog.sh PROPRO "Archivo a procesar $resultado"
done;