#!/bin/bash
archivoMaestro="$MAEDIR/gestiones.mae"
archivoDeContadores="$MAEDIR/tab/axg.tab"
archivoDeEmisores="$MAEDIR/emisores.mae"
archivoDeNormasPorEmisor="$MAEDIR/tab/nxe.tab"
MAE_GEST=$archivoMaestro
MAE_COUNT_FILE=$archivoDeContadores
MAE_TRANSMITTER=$archivoDeEmisores
MAE_NORM_BY_TRANSMITTER=$archivoDeNormasPorEmisor
FILE_HISTORY=$historialDeArchivos

#PRE: recibe como parametro una fecha con el formato dia-mes-anio
#POST: devuelve 0 si la fecha tiene un formato invalido y 1 si el formato es valido
validateDate () 
{
	local day=$(echo $dateFromRegister | cut -d '/' -f 1)										#parseo para obtener el dia de la fecha
	local month=$(echo $dateFromRegister | cut -d '/' -f 2) 									#parseo para obtener el mes de la fecha
	local year=$(echo $dateFromRegister | cut -d '/' -f 3)
	local format=$(echo grep -o "/" "$dateFromRegister" | wc -l) 										#parseo para obtener el anio de la fecha
	if [ $day -gt 31 -o $day -lt 1 -o $month -gt 12 -o $month -lt 1 -a $format -eq 2 ]; then
		echo 0																					#la fecha no es valida
		return
	else
		echo 1																					#la fecha es valida
		return
	fi
}

#PRE: recibe como parametro la fecha de comienzo y fin de la gestion que se esta procesando, y la fecha que esta en el nombre del archivo
#POST: devuelve 0 si la fecha no esta dentro del periodo de la gestion(invalida), devuelve 1 si la fecha esta dentro de la gestion(valida)
validateDateOnGest () 
{
	#la fecha de inicio de gestion, que es la que esta en gestiones.mae tiene formato dia/mes/anio, pero la fecha que esta
	#en el nombre del archivo a protocolizar tiene formato dia-mes-anio con lo cual se parsean distinto
	local dateBeginning=$(echo $RESULT_GEST | cut -d ';' -f 2)									#obtengo la fecha de comienzo de la gesiton que se esta por protocolizar
 	local dateEnded=$(echo $RESULT_GEST | cut -d ';' -f 3)										#obtengo la fecha de finalizacion de la gestion que se esta por protocolizar
	local dayBegin=$(echo $dateBeginning | cut -d '/' -f 1)			
	local monthBegin=$(echo $dateBeginning | cut -d '/' -f 2)
	local yearBegin=$(echo $dateBeginning | cut -d '/' -f 3)
	local dayEnd=$(echo $dateEnded | cut -d '/' -f 1)
	local monthEnd=$(echo $dateEnded | cut -d '/' -f 2)
	local yearEnd=$(echo $dateEnded | cut -d '/' -f 3)
	local dayFromRegister=$(echo $dateFromRegister | cut -d '/' -f 1)
	local monthFromRegister=$(echo $dateFromRegister | cut -d '/' -f 2)
	local yearFromRegister=$(echo $dateFromRegister | cut -d '/' -f 3)

	if [ $typeGest -eq 0 ]; then																	#valido la fecha para un registro historico
		if [ $yearFromRegister -gt $yearEnd -o $yearFromRegister -lt $yearBegin ]; then
			echo 0																					#la fecha no esta dentro del periodo de la gestion
			return
		elif [ $yearBegin -eq $yearFromRegister -a $monthFromRegister -lt $monthBegin ]; then
			echo 0																					#la fecha no esta dentro del periodo de la gestion
			return
		elif [ $yearEnd -eq $yearFromRegister -a $monthFromRegister -gt $monthEnd ]; then
			echo 0																					#la fecha no esta dentro del periodo de la gestion
			return
		elif [ $monthBegin -eq $monthFromRegister -a $yearBegin -eq $yearFromRegister -a $dayBegin -gt $dayFromRegister ]; then
			echo 0																					#la fecha no esta dentro del periodo de la gestion
			return
		elif [ $monthEnd -eq $monthFromRegister -a $yearEnd -eq $yearFromRegister -a $dayEnd -lt $dayFromRegister ]; then
			echo 0
			return
		else
			echo 1 																					#la fecha esta dentro del periodo de la gestion
			return
		fi
	elif [ $typeGest -eq 1 ]; then
		if [ $yearFromRegister -lt $yearBegin ]; then
			echo 0
			return
		elif [ $yearBegin -eq $yearFromRegister -a $monthFromRegister -lt $monthBegin ]; then
			echo 0
			return
		elif [ $monthBegin -eq $monthFromRegister -a $yearBegin -eq $yearFromRegister -a $dayBegin -gt $dayFromRegister ]; then
			echo 0
			return
		else
			echo 1
			return
		fi
	elif [ $typeGest -gt 1 ]; then
		echo 0
		return	
	fi
}

protocolize ()
{
	local currentLine="$1"
	local Fecha_Norma=$(echo $currentLine | cut -d ';' -f 1)
	local Nro_Norma=$(echo $currentLine | cut -d ';' -f 2)
	Causante=$(echo $currentLine | cut -d ';' -f 3)
	Extracto=$(echo $currentLine | cut -d ';' -f 4)
	Cod_Tema=$(echo $currentLine | cut -d ';' -f 5)
	local ExpedienteId=$(echo $currentLine | cut -d ';' -f 6)
	local ExpedienteAnio=$(echo $currentLine | cut -d ';' -f 7)
	local Cod_Firma=$(echo $currentLine | cut -d ';' -f 8)
	local Id_Registro=$(echo $currentLine | cut -d ';' -f 9)
	local Fuente="$completeFileName"
	local Anio_Norma=$(echo $Fecha_Norma | cut -d '/' -f 3)	
	if [ $typeGest -eq 1 ]; then																#si vamos a protocolizar un registro corriente el numero de norma es distinto
		Nro_Norma="$2"
	fi
	if [ $typeGest -eq 0 ]; then		
		echo "$codeGestion;$codeNorm;$codeEmisor;$Fecha_Norma;$Nro_Norma;$Anio_Norma;$Causante;$Extracto;$Cod_Tema;$ExpedienteId;$ExpedienteAnio;$Cod_Firma;$Id_Registro;$completeFileName" >> "$PROCDIR/$codeGestion/$Anio_Norma.$codeNorm"
	else
		echo "$codeGestion;$codeNorm;$codeEmisor;$Fecha_Norma;$Nro_Norma;$Anio_Norma;$Causante;$Extracto;$Cod_Tema;$ExpedienteId;$ExpedienteAnio;$Cod_Firma;$Id_Registro" >> "$PROCDIR/$codeGestion/$Anio_Norma.$codeNorm"
	fi
}

processCurrentRegister ()
{
	local currentLine="$1"
	currentYear=$(date +'%Y')
	completeLineWithNumberNorm=$(grep "$codeCurrentGest;$currentYear;$codeEmisor;$codeNorm" $MAE_COUNT_FILE)	#obtengo de axg.tab la linea correspondiente al codigo de gestion y codigo de norma
	if [ ! -z $completeLineWithNumberNorm ]; then												#puede ocurrir que no se encuntre la linea que combina el codigo de norma y gestion y en ese caso el string estaria vacio
		increaseCouter
	else
		createCounter
	fi
	protocolize "$currentLine" "$numberNorm"
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
	numberNorm="$incrementCounter"																		#tomamos como numero de norma el contador incrementado
	local Usuario=$(echo $completeLineWithNumberNorm | cut -d ';' -f 7)
	completeTime=`date +"%H-%M-%S"`
	local fileNameToMove="$MAEDIR/tab/ant/$completeTime-$completeFileName"	
	mover.sh $MAE_COUNT_FILE $fileNameToMove
	glog.sh MOVER "Tabla de contadores preservada antes de su modificación" INFO
	cp $fileNameToMove $MAE_COUNT_FILE	
	sed -i "s/$idContador;$Cod_Gestion;$Anio;$Cod_Emisor;$Cod_Norma;$Numero;$Usuario/$idContador;$Cod_Gestion;$Anio;$Cod_Emisor;$Cod_Norma;$incrementCounter;$Usuario/g" $MAE_COUNT_FILE
}

createCounter ()
{
	local lastLineInFile=`tail -1 $MAE_COUNT_FILE`														#obtengo el ultimo registro de la tabla axg.tab
	local lastIdContador=$(echo $lastLineInFile | cut -d ';' -f 1)
	local newIdContador=`expr $lastIdContador + 1`
	local currentDate=`date +%d/%m/%Y`
	local userName=`echo $USER`
	completeTime=`date +"%H-%M-%S"`
	local fileNameToMove="$MAEDIR/tab/ant/$completeTime-$completeFileName"
	numberNorm="1"
	mover.sh $MAE_COUNT_FILE $fileNameToMove
	glog.sh MOVER "Tabla de contadores preservada antes de su modificación" INFO
	cp $fileNameToMove $MAE_COUNT_FILE
	echo "$newIdContador;$codeGestion;$currentYear;$codeEmisor;$codeNorm;$numberNorm;$userName;$currentDate" >> $MAE_COUNT_FILE
}

#PRE: se supone que los archivos maestros estan cargados con lo cual no es necesario verificar la existencia de esos archivos
#lo mismo ocurre con los el directorio ACEPDIR, se supone que llamaremos a propro para protocolizar los archivos que alli se
#encuentran con lo cual tampoco es necesario su creacion
createAllDirectories ()
{
	if [ ! -d "$PROCDIR" ]; then
		mkdir $PROCDIR
	fi
	if [ ! -d "$RECHDIR" ]; then
		mkdir $RECHDIR
	fi
	if [ ! -d "$PROCDIR/proc" ]; then
		mkdir $PROCDIR/proc
	fi
	if [ ! -d "$LOGDIR" ]; then
		mkdir $LOGDIR
	fi
}

#POST: la funcion movera el archivo que se intentaba protocolizar a la carpeta RECHDIR informando sobre los motivos
#del evento.
rejectFile ()
{
	local reasonForRejection="$1"
	local completeLocalFileName="$completeFileName-$2"
	glog.sh PROPRO "$reasonForRejection" ERR
	glog.sh PROPRO "Archivo $completeFileName rechazado" ERR
	mover.sh $ACEPDIR/$codeGestion/$completeFileName $RECHDIR/$completeLocalFileName PROPRO
}

rejectRegister ()
{
	local currentLine="$1"
	local reasonForRejectRegister="$2"
	local motivo="$2"
	local Fecha_Norma=$(echo $currentLine | cut -d ';' -f 1)
	local Nro_Norma=$(echo $currentLine | cut -d ';' -f 2)
	Causante=$(echo $currentLine | cut -d ';' -f 3)
	Extracto=$(echo $currentLine | cut -d ';' -f 4)
	Cod_Tema=$(echo $currentLine | cut -d ';' -f 5)
	local ExpedienteId=$(echo $currentLine | cut -d ';' -f 6)
	local ExpedienteAnio=$(echo $currentLine | cut -d ';' -f 7)
	local Cod_Firma=$(echo $currentLine | cut -d ';' -f 8)
	local Id_Registro=$(echo $currentLine | cut -d ';' -f 9)
	local Fuente="$completeFileName"
	glog.sh PROPRO "Se rechaza el registro: $reasonForRejectRegister" INFO
	echo "$motivo;$Fecha_Norma;$Nro_Norma;$Causante;$Extracto;$Cod_Tema;$ExpedienteId;$ExpedienteAnio;$Cod_Firma;$Id_Registro;$Fuente" >> $PROCDIR/$codeGestion.rech
}

processRegister ()
{
	line="$1"
	dateFromRegister=$(echo $line | cut -d ';' -f 1)
	if [ $(validateDate) -eq 1 ]; then
		if [ $(validateDateOnGest) -eq 1 ]; then
			Cod_Tema=""
			Causante=""
			Extracto=""
			if [ $typeGest -eq 1 ]; then											#se tratra de una gestion corriente
				codSignatureIntoFile=$(echo $line | cut -d ';' -f 8) 				#busco el codigo de firma dentro del archivo
				if [ $codSignature != $codSignatureIntoFile ]; then					#el codigo de firma es invalido
					rejectRegister "$line" "codigo de firma invalido"
				else 
					processCurrentRegister "$line"
				fi
			elif [ $typeGest -eq 0 ]; then											#se trata de una gestion historica
				numberNorm=$(echo $line | cut -d ';' -f 2)
				if [ $numberNorm -lt 0 ]; then										#si el numero de norma es menor a 0 es invalido																		#si el numero de norma es menor a 0 es invalido			
					rejectRegister "$line" "El numero de norma invalido"
				else 
					protocolize	"$line"												#el numero de norma es mayor a 0 y se considera valido
				fi
			fi
		else
			rejectRegister "$line" "fecha fuera del rango de la gestion"
		fi
	else
		rejectRegister "$line" "fecha invalida"
	fi
}

#POST: procesa todos los registros del archivo que se esta protocolizando
processRegisterFromCurrentFile ()
{
	local numberLines=$(cat $ACEPDIR/$codeGestion/$completeFileName | wc -l)
	numberLines=$((numberLines+1))
	if [ $numberLines -gt 1 ]; then
		cat $ACEPDIR/$codeGestion/$completeFileName | while read line; do
			if [ $(echo $line | grep -o ";" | wc -l) -eq 8 ]; then
				processRegister "$line"
			else
				rejectRegister "$line" "la cantidad de campos en el registro es incorrecta"
			fi
		done;
	else
		line=$(cat $ACEPDIR/$codeGestion/$completeFileName)								#meti esta negrada porque con el while si el archivo tiene una linea se la salta
		if [ $(echo $line | grep -o ";" | wc -l) -eq 8 ]; then
			processRegister "$line"
		else
			rejectRegister "$line" "la cantidad de campos en el registro es incorrecta"
		fi
	fi
	mover.sh $ACEPDIR/$codeGestion/$completeFileName $PROCDIR/proc
	glog.sh MOVER "Se movió el archivo $completeFileName con éxito" INFO	
}


codeCurrentGest=$(tail -n -1 $MAEDIR/gestiones.mae | cut -d ';' -f 1)
countFiles=$(find $ACEPDIR/ -type f | wc -l)
glog.sh PROPRO "Inicio de propro. Cantidad de archivos a procesar: $countFiles" INFO
countRejectFile=0
countProcessFile=0
createAllDirectories
cat $MAEDIR/gestiones.mae | while read line; do
	codeGestion=$(echo $line | cut -d ';' -f 1)
	RESULT_GEST=$(grep ^$codeGestion\; $MAE_GEST)										#obtengo de gestiones.mae la linea correspondiente a la gestion a protocolizar	

	if [ -d $ACEPDIR/$codeGestion ]; then
		if [ ! -d $PROCDIR/$codeGestion ]; then
			mkdir $PROCDIR/$codeGestion
		fi
		for completeFileName in `ls $ACEPDIR/$codeGestion/ | cut -d '_' -f 5 | sort -t - -k 3 -k 2 -k 1`; do  	
		 	completeFileName=$(find $ACEPDIR/$codeGestion -type f -name "*$completeFileName")
 			completeFileName=`basename $completeFileName` 			
 			echo "protocolizando $completeFileName"
		 	fileAlreadyDocketed=$(find $PROCDIR/proc -type f -name "$completeFileName")						#me fijo si el archivo ya fue protocolizado
		 	completeTime=`date +"%H-%M-%S"`
		 	if [ -z $fileAlreadyDocketed ]; then															#si el archivo no fue protocolizado, el find no nos retorna nada, y el string esta vacio
		 		glog.sh PROPRO "Protocolizando $completeFileName" INFO
		 		codeNorm=$(echo $completeFileName | cut -d '_' -f 2)																	
		 		codeEmisor=$(echo  $completeFileName | cut -d '_' -f 3)															
		 		existCodeNormAndCodEmisorCombination=$(find $MAE_NORM_BY_TRANSMITTER -type f -print | xargs grep "$codeNorm;$codeEmisor")	#me fijo si existe la combinacion de codigo de norma y emisor en la tabla nxe
		 		if [ ! -z $existCodeNormAndCodEmisorCombination ]; then										#si existe la combinacion, levanta la linea entera y el string no esto vacio
					typeGest=$(echo $RESULT_GEST | cut -d ';' -f 5)											#me fijo que tipo de gestion es, si es la actual, me devuelve 1 sino es un registro historico y me devuelve 0
					codSignature=$(grep "^$codeEmisor" $MAE_TRANSMITTER | cut -d ';' -f 3)					#obtengo el codigo de firma correspondiente al codigo de emisor en el nombre del archivo												
					countProcessFile=$((countProcessFile+1))
					processRegisterFromCurrentFile
		 		else
		 			countRejectFile=$((countRejectFile+1))
		 			rejectFile "Emisor $codeEmisor no habilitado para la norma $codeNorm" "$completeTime"
		 		fi	
		 	else
		 		countRejectFile=$((countRejectFile+1))
		 		rejectFile "Se rechaza el archivo $completeFileName por estar DUPLICADO" "$completeTime"					#rechazamos el archivo moviendolo a ./RECHDIR
		 	fi
		done;
	fi
	if [ "$codeGestion" = "$codeCurrentGest" ]; then														#como se procesa por orden coronologico si la gestion procesada es igual a la corriente, loggeamos todo
		glog.sh PROPRO "Se procesaron $countProcessFile archivos" INFO
		glog.sh PROPRO "Se rechazaron $countRejectFile archivos" INFO
	fi
done;
glog.sh PROPRO "Fin de propro" INFO

