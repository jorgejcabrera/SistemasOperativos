#!/bin/bash
input="/ACEPDIR/Alfonsin/"
countFiles="$(find ./ACEPDIR/Alfonsin -type f -printf x | wc -c)"

 sh glog.sh PROPRO "inicio de PROPRO \n \t\t\t Cantidad de archivos a procesar: <$countFiles>" INFO