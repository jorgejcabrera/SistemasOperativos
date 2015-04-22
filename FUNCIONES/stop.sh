#!/bin/bash
# Comando "stop"
# 
# Parametro 1
# demonio a detener

#Debe ser un solo parametro
if [ $# -gt 2 -o $# -lt 1 ]; then
	echo "Cantidad de parametros inválida"
	exit 1
fi

#mato al demonio
killall "$1"
echo "mate al demonio"
exit 0
