#!/bin/bash
# Comando "stop"
# 
# Parametro 1
# demonio a detener

#Debe ser un solo parametro
if [ $# -gt 1 -o $# -lt 1 ]; then
	echo "Cantidad de parametros inválida"
	exit 1
fi

#El demonio debe estar corriendo
DEAMONID=$(pgrep $1)
if [ -z "$DEAMONID" ]; then #Si el demonio no tiene ID (no esta corriendo)
	echo "El demonio no se encuentra corriendo"
	exit 1
fi

#mato al demonio
kill $DEAMONID
echo "mate al demonio"
exit 0
