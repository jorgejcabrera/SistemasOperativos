Funciones para la ejecución del Sistema SisProG:

+------------------------+
|                        |
|        IniPro          |
|                        |
+------------------------+ 

	IniPro se ejecutará manualmente, preparando el ambiente.

+------------------------+
|                        |
|        RecPro          |
|                        |
+------------------------+    

	IniPro preguntará si se desea iniciar RecPro, en caso negativo, se podrá iniciar RecPro por linea de comandos mediante la función 		start de la siguiente forma: 
		> ./start.sh RecPro.sh 

	De igual manera, en cualquier momento se podrá detener el demonio mediante la función stop:
		> ./stop.sh RecPro.sh 

+------------------------+
|                        |
|        ProPro          |
|                        |
+------------------------+    

	Se supuso que el contenidos de los registros de los archivos usados es el siguiente		
		
		1) emisores.mae : Cod_Emisor;Emisor;Cod_Firma Externo
		
		2) normas.mae : Cod_Norma;Norma Externo
		
		3) gestiones.mae : Cod_Gestion;Fecha_Desde;Fecha_Hasta;Descripcion;AutoNumera

		4) nxe.tab : Cod_Norma;Cod_Emisor

		5) axg.tab : Id_contador;Cod_Gestion;Anio;Cod_Emisor;Cod_Norma;Numero;Usuario;Fecha_de_última_actualización
	
		6) archivos a protocolizar :
		Fecha_Norma;Nro_Norma;Causante;Extracto;Cod_Tema;Expediente;IdExpediente;Anio;Cod_Firma;Id_Registro

		Para el correcto funcionamiento del ProPro los registros deben respetar el formato descrito arriba.

+------------------------+
|                        |
|        InfPro          |
|                        |
+------------------------+  

	InfPro cuenta con un comando de ayuda, donde se encontrará todo lo necesario para utilizar InfPro. Para recibir la ayuda del mismo 		debe escribir por linea de comando:
		> InfPro -a



