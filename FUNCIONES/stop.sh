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

#TODO como garantizo que se pueda correr por consola? lo tendria que realizar la instalacion ?
#TODO debe chequear que este corriendo el demonio

#mato al demonio
killall "$1"
echo "mate al demonio"
exit 0