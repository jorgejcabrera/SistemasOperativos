#!/bin/bash
codeGestion="Alfonsin"
countFiles="$(find ./ACEPDIR/$codeGestion -type f -printf x | wc -c)"
archivoMaestro="MAEDIR/gestiones.mae"
archivoDeContadores="MAEDIR/tab/axg.tab"
archivoDeEmisores="MAEDIR/emisores.mae"
MAE_GEST=$archivoMaestro
MAE_COUNT_FILE=$archivoDeContadores
MAE_EMISOR=$archivoDeEmisores

sh glog.sh PROPRO "Inicio de propro \n \t\t\t Cantidad de archivos a procesar: $countFiles" INFO

RESULT_GEST=$(grep ^$codeGestion\; $MAE_GEST)														#obtengo de gestiones.mae la linea correspondiente a la gestion a protocolizar	

#PRE: recibe como parametro una fecha con el formato dia-mes-anio
#POST: devuelve 0 si la fecha tiene un formato invalido y 1 si el formato es valido
validateDate () 
{
	#TODO usar regular expresion para validar la fecha
	local dateFromFileName=$1 																		#la fecha tiene forma dia-mes-anio
	local day=$(echo $dateFromFileName | cut -d '-' -f 1)											#parseo para obtener el dia de la fecha
	local month=$(echo $dateFromFileName | cut -d '-' -f 2) 										#parseo para obtener el mes de la fecha
	local year=$(echo $dateFromFileName | cut -d '-' -f 3) 											#parseo para obtener el anio de la fecha

	if [ $day -gt 31 -o $day -lt 1 -o $month -gt 12 -o $month -lt 1 ]; then
		echo 0																						#la fecha no es valida
	else
		echo 1																						#la fecha es valida
	fi
}

#PRE: recibe como parametro la fecha de comienzo y fin de la gestion que se esta procesando, y la fecha que esta en el nombre del archivo
#POST: devuelve 0 si la fecha no esta dentro del periodo de la gestion(invalida), devuelve 1 si la fecha esta dentro de la gestion(valida)
validateDateOnGest () 
{
	#la fecha de inicio de gestion, que es la que esta en gestiones.mae tiene formato dia/mes/anio, pero la fecha que esta
	#en el nombre del archivo a protocolizar tiene formato dia-mes-anio con lo cual se parsean distinto
	local dateBeginning=$(echo $RESULT_GEST | cut -d ';' -f 2)										#obtengo la fecha de comienzo de la gesiton que se esta por protocolizar
 	local dateEnded=$(echo $RESULT_GEST | cut -d ';' -f 3)											#obtengo la fecha de finalizacion de la gestion que se esta por protocolizar

	local dayBegin=$(echo $dateBeginning | cut -d '/' -f 1)			
	local monthBegin=$(echo $dateBeginning | cut -d '/' -f 2)
	local yearBegin=$(echo $dateBeginning | cut -d '/' -f 3)
	local dayEnd=$(echo $dateEnded | cut -d '/' -f 1)
	local monthEnd=$(echo $dateEnded | cut -d '/' -f 2)
	local yearEnd=$(echo $dateEnded | cut -d '/' -f 3)
	local day=$(echo $1 | cut -d '-' -f 1)
	local month=$(echo $1 | cut -d '-' -f 2)
	local year=$(echo $1 | cut -d '-' -f 3)

	if [ $yearBegin -gt $year -o $yearEnd -lt $year -o \( $yearBegin -eq $year -a $monthBegin -gt $month \) -o \( $yearEnd -eq $year -a $monthEnd -lt $month \) -o \( $monthBegin -eq $month -a $dayBegin -gt $day \) -o \( $monthEnd -eq $month -a $dayEnd -lt $day \) ]; then
		echo 0
	else 
		echo 1
	fi
}

protocolize ()
{
	local yearNormFromFileName=$(echo $completeFileName | cut -d '-' -f 3 | cut -d '.' -f 1)		#obtengo el año que esta en el nombre del archivo
	local fileDocketedName="$yearNormFromFileName.$codeNorm"										#concateno el año de la norma con el codigo de norma para generar el nombre del archivo a protocolizar
	cat ACEPDIR/$codeGestion/$completeFileName | while read line; do
		local Fecha_Norma=$(echo "$line" | cut -d ';' -f 1)
		local Nro_Norma=$(echo "$line" | cut -d ';' -f 2)
		local Anio_Norma=$(echo $Fecha_Norma | cut -d '/' -f 3)
		local Causante=$(echo "$line" | cut -d ';' -f 3)
		Extracto=$(echo "$line" | cut -d ';' -f 4)
		local Cod_Tema=$(echo "$line" | cut -d ';' -f 5)
		local ExpedienteId=$(echo "$line" | cut -d ';' -f 6)
		local ExpedienteAnio=$(echo "$line" | cut -d ';' -f 7)
		local Cod_Firma=$(echo "$line" | cut -d ';' -f 7)
		local Id_Registro=$(echo "$line" | cut -d ';' -f 8)";"
		if [ $typeGest -eq 1 ]; then																#si vamos a protocolizar un registro corriente el numero de norma es distinto
			Nro_Norma=$1
			completeFileName=""
			Id_Registro=$(echo "$line" | cut -d ';' -f 1)
		fi
		echo "$codeGestion;$codeNorm;$codeEmisor;$Fecha_Norma;$Nro_Norma;$Anio_Norma;$Causante;$Extracto;$Cod_Tema;$ExpedienteId;$ExpedienteAnio;$Cod_Firma;$Id_Registro$completeFileName" >> $fileDocketedName
		done
}

processHistoricalRegister ()
{	
	echo "8"
	if [ $numberNorm -lt 0 ]; then																		#si el numero de norma es menor a 0 es invalido			
		echo "9"
		sh glog.sh PROPRO "El numero de norma $numberNorm es invalido. Se rechaza el archivo" ERR
		#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
		continue
	else
		echo "10"
		echo "protocolizando registro historico"
		protocolize																						#el numero de norma es mayor a 0 y se considera valido
	fi
}

processCurrentRegister ()
{
	codFirma=$(grep "^$codeEmisor" $MAE_EMISOR | cut -d ';' -f 3)											#obtengo el codigo de firma correspondiente al codigo de emisor en el nombre del archivo												
	codFirmaIntoFile=$(head -n 1 "ACEPDIR/$codeGestion/$completeFileName" | grep $codFirma | cut -d ';' -f 8) #busco el codigo de firma dentro del archivo
 	#echo "8"
 	if [ -z $codFirmaIntoFile ]; then
 		codFirmaIntoFile="valorPorDefecto"																	#le clavo un valor por defecto a la variable para que no me moleste en el if cuando comparo el valor de ambas variables
 	fi
 	#echo "9"
	if [ ! -z $codFirma ] && [ ! -z $codFirmaIntoFile ] && [ $codFirma != $codFirmaIntoFile ]; then			#el codigo de norma es invalido
		#echo "10"
		sh glog.sh PROPRO "El numero de firma es invalido. Se rechaza el archivo"
		#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
		continue
	else
		echo "protocolizando registro actual"
		protocolize $numberNorm
	fi
}

increaseCouter ()
{
	local idContador=$(echo $completeLineWithNumberNorm | cut -d ';' -f 1)
	local Cod_Gestion=$(echo $completeLineWithNumberNorm | cut -d ';' -f 2)
	local Anio=$(echo $completeLineWithNumberNorm | cut -d ';' -f 3)
	local Cod_Emisor=$(echo $completeLineWithNumberNorm | cut -d ';' -f 4)
	local Cod_Norma=$(echo $completeLineWithNumberNorm | cut -d ';' -f 5)
	local Numero=$(echo $completeLineWithNumberNorm | cut -d ';' -f 6)
	local incrementCounter=`expr $Numero + 1`
	numberNorm=$incrementCounter																			#tomamos como numero de norma el contador incrementado
	local Usuario=$(echo $completeLineWithNumberNorm | cut -d ';' -f 7)
	
	sh mover.sh $MAE_COUNT_FILE MAEDIR/tab/ant/
	sh glog.sh MOVER "Tabla de contadores preservada antes de su modificación" INFO
	cp MAEDIR/tab/ant/axg.tab $MAE_COUNT_FILE
	
	sed -i "s/$idContador;$Cod_Gestion;$Anio;$Cod_Emisor;$Cod_Norma;$Numero;$Usuario/$idContador;$Cod_Gestion;$Anio;$Cod_Emisor;$Cod_Norma;$incrementCounter;$Usuario/g" $MAE_COUNT_FILE
}

createCounter ()
{
	local lastLineInFile=`tail -1 $MAE_COUNT_FILE`
	local lasIdContador
	echo $lastLineInFile
	local auxNumberNorm=`expr $auxNumberNorm + 1`
	#completeLineWithNumberNorm=$($auxNumberNorm;$codeGestion;$currentYear;$codeEmisor;$codeNorm;$auxNumberNorm;;)
}

createAllDirectories ()
{
	echo "esta funcion se fija si existen todos los directorios que se van a usar si alguno no existe lo crea"
}
auxNumberNorm="0"
for completeFileName in `ls ./ACEPDIR/$codeGestion/ | cut -d '_' -f 5 | sort -t - -k 3 -k 2 -k 1`; do 
 	
 	completeFileName=$(find ./ACEPDIR/$codeGestion -type f -name "*$completeFileName" | cut -d '/' -f 4)
 	fileAlreadyDocketed=$(find ./PROCDIR/proc/ -type f -name "$completeFileName" | cut -d '/' -f 4)			#me fijo si el archivo ya fue protocolizado
 	#echo "1"
 	if [ -z $fileAlreadyDocketed ]; then																	#si el archivo no fue protocolizado, el find no nos retorna nada, y el string esta vacio

 		sh glog.sh PROPRO "Archivo a procesar $completeFileName" INFO
 		codeNorm=$(echo $completeFileName | cut -d '_' -f 2)																	
 		codeEmisor=$(echo  $completeFileName | cut -d '_' -f 3)																	
 		existCodeNormAndCodEmisorCombination=$(find ./MAEDIR/tab/nxe.tab -type f -print | xargs grep "$codeNorm;$codeEmisor")	#me fijo si existe la combinacion de codigo de norma y emisor en la tabla nxe
 		#echo "2"
 		if [ ! -z $existCodeNormAndCodEmisorCombination ]; then												#si existe la combinacion, levanta la linea entera y el string no esto vacio

 			dateFromFileName=$(echo $completeFileName | cut -d '_' -f 5 | cut -d '.' -f 1)
 			#echo "3"
 			if [ $(validateDate $dateFromFileName) -eq 1 ]; then																 				
 				#echo "4"
 				if [ $(validateDateOnGest $dateFromFileName) -eq 1 ]; then									#me fijo si la fecha esta dentro del rango de la gestion												

 					typeGest=$(echo $RESULT_GEST | cut -d ';' -f 5)											#me fijo que tipo de gestion es, si es la actual, me devuelve 1 sino es un registro historico y me devuelve 0
 					currentYear=$(date +'%Y')
 					completeLineWithNumberNorm=$(grep "$codeGestion;$currentYear;$codeEmisor;$codeNorm" $MAE_COUNT_FILE)		#obtengo de axg.tab la linea correspondiente al codigo de gestion y codigo de norma
 					if [ ! -z $completeLineWithNumberNorm ]; then															#puede ocurrir que no se encuntre la linea que combina el codigo de norma y gestion y en ese caso el string estaria vacio
 						increaseCouter
 					else
 						createCounter
 					fi
 					#echo "5" 					
 					if [ $typeGest -eq 0 ]; then															#proceso tipo de registro historico						
 						echo "6"
 						processHistoricalRegister
 					elif [ $typeGest -eq 1 ]; then															#proceso tipo de archivo corriente
 						echo "7"
 						processCurrentRegister
 					fi																				
 					#sh glog.sh PROPRO "La fecha $dateFromFileName está dentro del rango de la gestion $codeGestion" INFO
 					#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./PROCDIR/proc PROPRO
 				else
 					sh glog.sh PROPRO "La fecha $dateFromFileName está fuera del rango de la gestion $codeGestion" ERR
					sh glog.sh PROPRO "Archivo $completeFileName rechazado" ERR
					#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO
					continue
 				fi 			
 			else
 				sh glog.sh PROPRO "La fecha $dateFromFileName tiene un formato invalido. Se rechaza el archivo" ERR		#la fecha tiene un formato invalido: loggeamos el evento
 				#sh mover.sh ./ACEPDIR/$codeGestion/$completeFileName ./RECHDIR PROPRO 									#rechazamos el archivo moviendolo a ./RECHDIR
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

