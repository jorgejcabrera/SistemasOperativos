#!/bin/bash
countFiles="$(find ./ACEPDIR/Alfonsin -type f -printf x | wc -c)"
sh glog.sh PROPRO "Inicio de propro \n \t\t\t Cantidad de archivos a procesar: $countFiles" INFO
codGestion="Alfonsin"
for filename in `ls ./ACEPDIR/Alfonsin/ | cut -d '_' -f 5 | sort -t - -k 3 -k 2 -k 1`; 
do 
	#protocolizar cada archivo
 	fileName=$(find ./ACEPDIR/$codGestion -type f -name "*$filename")
 	anioGestion=$(ls $fileName | cut -d '-' -f 3 | cut -d '.' -f 1)
 	currentFileName=$( echo $fileName | cut -d '/' -f 4 )
 	sh glog.sh PROPRO "Archivo a procesar $currentFileName" INFO
done;