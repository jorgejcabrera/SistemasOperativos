#!/bin/bash
# Comando "stop"
# 
# Parametro 1
# demonio a detener
#TODO que el iniciador permita que stop pueda ser corrido por linea de comando

#Debe ser un solo parametro
if [ $# -gt 1 -o $# -lt 1 ]; then
	echo "Cantidad de parametros inválida"
	exit 1
fi

#El demonio debe estar corriendo
CORRIENDO=$(ps aux | grep .*/$1$)
if [ -z "$CORRIENDO" ]; then
	echo "El demonio no se encuentra corriendo"
	exit 1
fi

#mato al demonio
killall "$1"
echo "mate al demonio"
exit 0
