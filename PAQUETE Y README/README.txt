Pasos a seguir para instalar el software:

1) Copiar el archivo TPSisOp.zip en un directorio de su PC . Dicho directorio lo llamaremos "<DirInstalacion>" de ahora en mas

2) Descomprimir TPSistemasOp.tgz en el direcotrio que lo copio.

3)La accion 2 le generara la siguiente estructura de directorio
    <DirInstalacion>    |
		     	|-grupo05 |
			          |-InsPro.sh
				  |-verifInstalacion.sh
				  |-instalar.sh

 +---------------------------------------------------------------------------------------------+
 | IMPORTANTE: Es necesario que esta estructura este creada para poder realizar la instalación.|
 |	      Cualquier archivo o directorio faltante no permitira continuar la instalación    |
 +---------------------------------------------------------------------------------------------+

4)  +-----------------------------------------------------------------------------------------------------------+
    | IMPORTANTE:La instalacion debe realizarse en el mismo lugar donde se encuentran los archivos              |
    |	         InsPro.sh, verifInstalcion.sh y instalar.sh, (<DirInstalacion>/grupo05)			|
    |	         Si no se situa puede haber errores de directorios    						|
    +-----------------------------------------------------------------------------------------------------------+
 

5) Dirijase al directorio <DirInstalacion>/grupo05 y ejecute el comando "bash InsPro.sh" desde una consola, aqui comienza
el proceso de instalacion. El instalador lo ira guiando paso por paso para poder instalar el programa de manera exitosa.


Consideraciones para el ProPro

	-Se supuso que el contenidos de los registros de los archivos usados es el siguiente		
		
		1) emisores.mae : Cod_Emisor;Emisor;Cod_Firma Externo
		
		2) normas.mae : Cod_Norma;Norma Externo
		
		3) gestiones.mae : Cod_Gestion;Fecha_Desde;Fecha_Hasta;Descripcion;AutoNumera

		4) nxe.tab : Cod_Norma;Cod_Emisor
_
		5) axg.tab : Id_contador;Cod_Gestion;Anio;Cod_Emisor;Cod_Norma;Numero;Usuario;Fecha_de_última_actualización
	
		6) archivos a protocolizar : Fecha_Norma;Nro_Norma;Causante;Extracto;Cod_Tema;Expediente;IdExpediente;Anio;Cod_Firma;Id_Registro

	Para el correcto funcionamiento del ProPro los registros deben respetar el formato descrito arriba.






