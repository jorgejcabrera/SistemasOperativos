#!/usr/bin/perl
#
########################################################
#          SSOO Grupo 05 - $year, 1° Cuatrimestre      #
#                       Comando InfPro.pl              #
########################################################

# Levanto las variables de ambiente.
if ( !exists $ENV{"MAEDIR"} ) {

	#if (! (-e $CONFDIR."InsPro.conf")){
	print "El sistema no se halla inicializado.\n";
	exit;
}

if (&validoInstancias) {
	print "No puede ejecutarse mas de una instancia del InfPro a la vez\n";
	exit;
}
$CONFDIR     = $ENV{CONFDIR} . "/";
$BINDIR      = $ENV{BINDIR} . "/";
$MAEDIR      = $ENV{MAEDIR} . "/";
$PROCDIR     = $ENV{PROCDIR} . "/";
$INFODIR     = $ENV{INFODIR} . "/";
$ANIOINICIAL = 1946;
my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);
$year += 1900;

# Cargo archivos maestros para utilizarlos luego.
%TiposNorma = &cargoTiposNorma;
%Gestiones  = &cargoGestiones;
%Emisores   = &cargoEmisores;

sub realizoConsulta {

	# Primero llamo a los modulos de los filtros.
	local $filtroTiposNorma  = &filtroNorma;
	local @filtroAnios       = &filtroAnio;
	local @nroNorma          = &filtroNroNorma;
	local $gestion           = &filtroGestion;
	local $emisor            = &filtroEmisor;
	local @elementosConsulta = ();
	&procesoConsulta;
	&muestroPantallaConsulta;

	if ($w) {
		&escriboResultadoConsulta;
	}
}

sub procesoDirectorioConsulta {
	my ($directorio) = $_[0];
	my $archivo;

	# Abrimos el directorio y tomamos lo que hay
	opendir( CURDIR, $directorio ) or return;
	my @archivos = readdir(CURDIR);
	closedir(CURDIR);
	foreach $archivo (@archivos) {

		# Omito . y ..
		next if ( ( $archivo eq "." ) or ( $archivo eq ".." ) );
		my $newdir = $directorio . "/" . $archivo;
		if ( -f $newdir ) {
			my @tmp = split( /\./, $archivo );

			#Aplico filtros de codigo de Norma y de Periodo de anios.
			next
			  if (  ( $filtroTiposNorma ne "" )
				and ( $tmp[1] ne $filtroTiposNorma ) );
			next if ( &validoAnios( $tmp[0] ) == 0 );
			&procesoArchivoConsulta($newdir);

		}
	}
}

sub procesoPROCDIRConsulta {
	my ($directorio) = $_[0];
	my $archivo;

	# Abrimos el directorio y tomamos lo que hay
	opendir( CURDIR, $directorio ) or return;
	my @archivos = readdir(CURDIR);
	closedir(CURDIR);
	foreach $archivo (@archivos) {

		# Omito . y ..
		next if ( ( $archivo eq "." ) or ( $archivo eq ".." ) );
		my $newdir = $directorio . "/" . $archivo;
		if ( -d $newdir ) {

			# Aca me fijo el filtro de gestion
			next if ( ( $gestion ne "" ) and ( $archivo ne $gestion ) );
			&procesoDirectorioConsulta($newdir);
		}
	}
}

sub procesoConsulta {
	local %hashTemp = ();
	&procesoPROCDIRConsulta( substr $PROCDIR, 0, -1 );

	#junto todos los arrays, ordenando por peso
	foreach $key ( sort { $b <=> $a } keys %hashTemp ) {
		push @elementosConsulta, @{ $hashTemp{$key} };
	}
}

sub procesoArchivoConsulta {
	my ($nombreArchivo) = @_;
	open( FILE, $nombreArchivo );
	my @emptyArray = ();
	my $linea;
	my $c = 0;
	while ( $linea = <FILE> ) {
		chomp($linea);

		# Id_Registro
		$c++;

	# Si un registro no registra ocurrencias con la clave, no se tiene en cuenta
		my $peso = -1;
		@registro = split( ";", $linea );

		# Valido Emisor de acuerdo al filtro de emisor
		next if ( ( $emisor ne "" ) and ( $registro[2] ne $emisor ) );

		# Valido Rango de Nro de norma de acuerdo al filtro
		next if ( &validoNroNorma( $registro[4] ) == 0 );
		if ( $claveBusqueda ne "" ) {

		 # Si tengo clave de busqueda, entonces busco la cantidad de ocurrencias
			$peso =
			  &cuentoOcurrencias( $registro[6], $claveBusqueda ) * 10 +
			  &cuentoOcurrencias( $registro[7], $claveBusqueda );
		}
		else {

	  # Si no tengo clave de busqueda, todos los elementos tienen el mismo valor
			$peso = 1;
		}

# Si es un registro que debo grabar, entonces lo grabo en un hash temporal en el que
# tengo para cada peso un array de ocurrencias
		if ( $peso > 0 ) {
			my %regtemp = ();
			$regtemp{Cod_Norma}   = $registro[1];
			$regtemp{Cod_Emisor}  = $registro[2];
			$regtemp{Nro_Norma}   = $registro[4];
			$regtemp{Cod_Gestion} = $registro[0];
			$regtemp{Anio_Norma}  = $registro[5];
			$regtemp{Fecha_Norma} = $registro[3];
			$regtemp{Causante}    = $registro[6];
			$regtemp{Extracto}    = $registro[7];
			$regtemp{Id_Registro} = $c;
			$regtemp{Peso}        = $peso;

# Si ya tengo un array para ese peso, pusheo el elemento. Sino, creo el array y luego pusheo.
			if ( !exists $hashTemp{$peso} ) {
				$hashTemp{$peso} = [@emptyArray];
			}
			push @{ $hashTemp{$peso} }, {%regtemp};
		}
	}
	close FILE;
}

# Escribo a disco los resultados de una consulta
sub escriboResultadoConsulta {
	my $nombreArchivo = &proxNomResu;
	open( ARCH, ">$INFODIR" . $nombreArchivo );
	foreach (@elementosConsulta) {
		%elementoConsulta = %{$_};

		#Imprimo por archivo un elemento
		print ARCH $elementoConsulta{Cod_Norma} . ";";
		print ARCH $elementoConsulta{Cod_Emisor} . ";";
		print ARCH $Emisores{ $elementoConsulta{Cod_Emisor} }{Emisor} . ";";
		print ARCH $elementoConsulta{Nro_Norma} . ";";
		print ARCH $elementoConsulta{Anio_Norma} . ";";
		print ARCH $elementoConsulta{Cod_Gestion} . ";";
		print ARCH $elementoConsulta{Fecha_Norma} . ";";
		print ARCH $elementoConsulta{Causante} . ";";
		print ARCH $elementoConsulta{Extracto} . ";";
		print ARCH $elementoConsulta{Id_Registro};
		print ARCH "\n";
	}
	close(ARCH);
	print "El nombre del archivo de consulta generado es "
	  . $nombreArchivo . "\n";
}

# Escribo por pantalla los resultados de una consulta
sub muestroPantallaConsulta {
	foreach (@elementosConsulta) {
		%elementoConsulta = %{$_};

		#Imprimo por archivo un elemento
		print $elementoConsulta{Cod_Norma} . " ";
		print $Emisores{ $elementoConsulta{Cod_Emisor} }{Emisor} . "(";
		print $elementoConsulta{Cod_Emisor} . ") ";
		print $elementoConsulta{Nro_Norma} . "/ ";
		print $elementoConsulta{Anio_Norma} . " ";
		print $elementoConsulta{Cod_Gestion} . " ";
		print $elementoConsulta{Fecha_Norma} . " ";
		print $elementoConsulta{Peso} . "\n";
		print $elementoConsulta{Causante} . "\n";
		print $elementoConsulta{Extracto} . "\n";
	}
}

sub realizoInforme {

	# Primero llamo a los modulos de los filtros.
	local $filtroTiposNorma = &filtroNorma;
	local @filtroAnios      = &filtroAnio;
	local @nroNorma         = &filtroNroNorma;
	local $gestion          = &filtroGestion;
	local $emisor           = &filtroEmisor;
	local %elementosInforme = ();
	&procesoInforme;

	&muestroPantallaInforme;

	if ($w) {
		&escriboResultadoInforme;
	}
}

#Informe, si no ingreso lista de archivos de resultados
sub procesoDirectorioInformeCompleto {
	my ($directorio) = substr $INFODIR, 0, -1;
	my $archivo;

	# Abrimos el directorio y tomamos lo que hay
	opendir( CURDIR, $directorio ) or return;
	my @archivos = readdir(CURDIR);
	closedir(CURDIR);
	foreach $archivo (@archivos) {

		# Omito . y ..
		next if ( ( $archivo eq "." ) or ( $archivo eq ".." ) );
		next if ( $archivo !~ "^resultado" );
		my $newdir = $directorio . "/" . $archivo;
		if ( -f $newdir ) {
			my @tmp = split( /\./, $archivo );

			#Aplico filtros de codigo de Norma y de Periodo de anios.
			&procesoArchivoInforme($newdir);

		}
	}
}

#Informe limitado a listado de resultados
sub procesoDirectorioInformeListado {
	my ($directorio) = substr $INFODIR, 0, -1;
	my $archivo;
	foreach (@listaResultados) {
		my $newdir = $directorio . "/" . $_;
		&procesoArchivoInforme($newdir);
	}
}

sub procesoInforme {
	local %hashTemp = ();
	my $cantClaves = @listaResultados;
	if ( $cantClaves == 0 ) {
		&procesoDirectorioInformeCompleto;
	}
	else {
		&procesoDirectorioInformeListado;
	}

	#junto todos los arrays, ordenando por peso
	foreach $key ( sort { $b <=> $a } keys %hashTemp ) {
		foreach ( keys %{ $hashTemp{$key} } ) {
			my %temp      = %{ $hashTemp{$key}{$_} };
			my $fechaTemp = &fecha_comparable( $temp{Fecha_Norma} );
			$elementosInforme{ $fechaTemp
				  . $temp{Cod_Norma}
				  . $temp{Nro_Norma} } = \%temp;
		}
	}

}

sub procesoArchivoInforme {
	my ($nombreArchivo) = @_;
	open( FILE, $nombreArchivo );
	my @emptyArray = ();
	my $linea;
	my $c = 0;
	while ( $linea = <FILE> ) {
		chomp($linea);

	# Si un registro no registra ocurrencias con la clave, no se tiene en cuenta
		my $peso = -1;
		@registro = split( ";", $linea );

		# Valido Emisor de acuerdo al filtro de emisor
		next
		  if (  ( $filtroTiposNorma ne "" )
			and ( $registro[0] ne $filtroTiposNorma ) );
		next if ( ( $emisor  ne "" ) and ( $registro[2] ne $emisor ) );
		next if ( ( $gestion ne "" ) and ( $registro[5] ne $gestion ) );
		next if ( &validoAnios( $registro[4] ) == 0 );
		next if ( &validoNroNorma( $registro[3] ) == 0 );

		# Valido Rango de Nro de norma de acuerdo al filtro
		if ( $claveBusqueda ne "" ) {

		 # Si tengo clave de busqueda, entonces busco la cantidad de ocurrencias
			$peso =
			  &cuentoOcurrencias( $registro[7], $claveBusqueda ) * 10 +
			  &cuentoOcurrencias( $registro[8], $claveBusqueda );
		}
		else {

	  # Si no tengo clave de busqueda, todos los elementos tienen el mismo valor
			$peso = 1;
		}

# Si es un registro que debo grabar, entonces lo grabo en un hash temporal en el que
# tengo para cada peso un array de ocurrencias
		if ( $peso > 0 ) {
			my %regtemp = ();
			$regtemp{Cod_Norma}   = $registro[0];
			$regtemp{Emisor}      = $registro[1];
			$regtemp{Cod_Emisor}  = $registro[2];
			$regtemp{Nro_Norma}   = $registro[3];
			$regtemp{Cod_Gestion} = $registro[4];
			$regtemp{Anio_Norma}  = $registro[5];
			$regtemp{Fecha_Norma} = $registro[6];
			$regtemp{Causante}    = $registro[7];
			$regtemp{Extracto}    = $registro[8];
			$regtemp{Id_Registro} = $registro[9];
			$regtemp{Peso}        = $peso;
			$id_Registro =
			    $regtemp{Cod_Gestion}
			  . $regtemp{Anio_Norma}
			  . $regtemp{Cod_Norma}
			  . $regtemp{Id_Registro};

# Si ya tengo un array para ese peso, pusheo el elemento. Sino, creo el array y luego pusheo.
			if ( !exists $hashTemp{$peso} ) {
				$hashTemp{$peso} = {};
			}
			if ( !exists $hashTemp{$peso}{$id_Registro} ) {
				$hashTemp{$peso}{$id_Registro} = {%regtemp};
			}
		}
	}
	close FILE;
}

# Escribo por pantalla los resultados de una consulta
sub muestroPantallaInforme {
	foreach $key ( sort { $b cmp $a } keys %elementosInforme ) {
		my %elementoConsulta = %{ $elementosInforme{$key} };

		#Imprimo por archivo un elemento
		print $elementoConsulta{Cod_Norma} . " ";
		print $Emisores{ $elementoConsulta{Cod_Emisor} }{Emisor} . "(";
		print $elementoConsulta{Cod_Emisor} . ") ";
		print $elementoConsulta{Nro_Norma} . "/ ";
		print $elementoConsulta{Anio_Norma} . " ";
		print $elementoConsulta{Cod_Gestion} . " ";
		print $elementoConsulta{Fecha_Norma} . " ";
		print $elementoConsulta{Peso} . "\n";
		print $elementoConsulta{Causante} . "\n";
		print $elementoConsulta{Extracto} . "\n";
	}
}

# Escribo a disco los resultados de una consulta
sub escriboResultadoInforme {
	my $nombreArchivo = &proxNomInf;
	open( ARCH, ">$INFODIR" . $nombreArchivo );

	foreach $key ( sort { $b cmp $a } keys %elementosInforme ) {
		my %elementoConsulta = %{ $elementosInforme{$key} };

		#Imprimo por archivo un elemento
		print ARCH $elementoConsulta{Cod_Norma} . ";";
		print ARCH $elementoConsulta{Cod_Emisor} . ";";
		print ARCH $elementoConsulta{Emisor} . ";";
		print ARCH $elementoConsulta{Nro_Norma} . ";";
		print ARCH $elementoConsulta{Anio_Norma} . ";";
		print ARCH $elementoConsulta{Cod_Gestion} . ";";
		print ARCH $elementoConsulta{Fecha_Norma} . ";";
		print ARCH $elementoConsulta{Causante} . ";";
		print ARCH $elementoConsulta{Extracto} . ";";
		print ARCH $elementoConsulta{Id_Registro};
		print ARCH "\n";
	}
	close(ARCH);
	print "El nombre del archivo de consulta generado es "
	  . $nombreArchivo . "\n";
}

sub realizoEstadistica {

	# Primero llamo a los modulos de los filtros.
	local @filtroAnios    = &filtroAnio;
	local $gestion        = &filtroGestion;
	local %elementosEstad = ();
	&procesoDirectorioEstad;
	&muestroPantallaEstad;

	if ($w) {
		&escriboResultadoEstad;
	}

}

sub procesoDirectorioEstad {
	local ( $dirGestion, $anio, $tipoNorma, $newdir );
	$dir = substr $PROCDIR, 0, -1;

	# Abrimos el directorio y tomamos lo que hay
	opendir( CURDIR, $dir ) or return;
	my @archivos = readdir(CURDIR);
	closedir(CURDIR);
	foreach $dirGestion (@archivos) {

		# Omito . y ..
		next if ( ( $dirGestion eq "." ) or ( $dirGestion eq ".." ) );
		next if ( ( $gestion ne "" ) and ( $dirGestion ne $gestion ) );
		$newdir = $dir . "/" . $dirGestion;
		if ( -d $newdir ) {

			# Aca me fijo el filtro de gestion
			&procesoGestionEstad($dirGestion);
		}
	}
}

sub procesoGestionEstad {
	local $Gestion = $_[0];
	local ( $anio, $tipoNorma, %gestion );
	%gestion = (
		Gestion => $Gestiones{$Gestion}{Descripcion},
		Anios   => {}
	);
	my $dir = substr( $PROCDIR, 0, -1 ) . "/" . $Gestion;
	$fechaGestion = &fecha_comparable( $Gestiones{$Gestion}{Fecha_Desde} );

	# Abrimos el directorio de la gestion
	opendir( CURDIR, $dir ) or return;
	my @archivosGestion = readdir(CURDIR);
	closedir(CURDIR);
	foreach $archivoGestion (@archivosGestion) {

		# Omito . y ..
		next
		  if ( ( $archivoGestion eq "." )
			or ( $archivoGestion eq ".." ) );
		my $newdir = $PROCDIR . $Gestion . "/" . $archivoGestion;

		if ( -f $newdir ) {
			( $anio, $tipoNorma ) = split( /\./, $archivoGestion );

			#Aplico filtro Periodo de anios.
			next if ( &validoAnios($anio) == 0 );
			next
			  if (  ( $tipoNorma ne "CON" )
				and ( $tipoNorma ne "RES" )
				and ( $tipoNorma ne "DIS" ) );
			if ( !( exists $gestion{Anios}{$anio} ) ) {
				$gestion{Anios}{$anio} = {
					RES      => 0,
					CON      => 0,
					DIS      => 0,
					Emisores => {}
				};
			}
			&procesoArchivoGestionEstad($newdir);
		}

	}
	$elementosEstad{$fechaGestion} = \%gestion;
}

# Escribo a disco los resultados de una Estad
sub escriboResultadoEstad {
	my $nombreArchivo = &proxNomEstad;
	open( ARCH, ">$INFODIR" . $nombreArchivo );
	foreach $id ( sort keys %elementosEstad ) {
		my %gestion = %{ $elementosEstad{$id} };
		foreach $anio ( sort keys( %{ $gestion{Anios} } ) ) {
			print ARCH "Gestion:" . $elementosEstad{$id}{Gestion} . " ";
			print ARCH "Año:" . $anio . " ";
			print ARCH "Emisores:"
			  . join( ",", keys( %{ $gestion{Anios}{$anio}{Emisores} } ) )
			  . "\n";

			print ARCH "Cantidad de resoluciones:"
			  . $gestion{Anios}{$anio}{RES} . "\n";
			print ARCH "Cantidad de disposiciones:"
			  . $gestion{Anios}{$anio}{DIS} . "\n";
			print ARCH "Cantidad de convenios:"
			  . $gestion{Anios}{$anio}{CON} . "\n";
		}
	}
	close(ARCH);
	print "El nombre del archivo de estadisticas generado es "
	  . $nombreArchivo . "\n";
}

# Escribo por pantalla los resultados de una Estad
sub muestroPantallaEstad {
	foreach $id ( sort keys %elementosEstad ) {
		my %gestion = %{ $elementosEstad{$id} };
		foreach $anio ( sort keys( %{ $gestion{Anios} } ) ) {
			print "Gestion:" . $elementosEstad{$id}{Gestion} . " ";
			print "Año:" . $anio . " ";
			print "Emisores:"
			  . join( ",", keys( %{ $gestion{Anios}{$anio}{Emisores} } ) )
			  . "\n";

			print "Cantidad de resoluciones:"
			  . $gestion{Anios}{$anio}{RES} . "\n";
			print "Cantidad de disposiciones:"
			  . $gestion{Anios}{$anio}{DIS} . "\n";
			print "Cantidad de convenios:" . $gestion{Anios}{$anio}{CON} . "\n";
		}
	}
}

sub procesoArchivoGestionEstad {
	my ($nombreArchivo) = @_;
	open( FILE, $nombreArchivo );
	while ( $linea = <FILE> ) {
		chomp($linea);
		my @tmp = split( ";", $linea );
		my $emisor = $Emisores{ $tmp[2] }{Emisor};
		$gestion{Anios}{$anio}{Emisores}{$emisor}++;
		$gestion{Anios}{$anio}{$tipoNorma}++;
	}
	close FILE;
}

# Proceso los argumentos ingresados al sistema
# Presupone que existe una lista con las claves, y las variables $i, $e, $c
# No devuelve ningun valor
sub procesoArgumentos() {
	@argumentos = split( " ", $_[0] );
	$largo = @argumentos;
	for ( my $cont = 0 ; $cont < $largo ; $cont++ ) {
		if ( $argumentos[$cont] eq "-a" ) {
			&mostrarAyuda();
		}
		if ( $argumentos[$cont] eq "-w" ) {
			$w = 1;
			next;
		}
		if ( ( $argumentos[$cont] eq "-e" ) or ( $argumentos[$cont] eq "-we" ) )
		{
			if ( $argumentos[$cont] eq "-we" ){
				$w=1;
			}
			$e = 1;
			next;
		}
		if ( ( $argumentos[$cont] eq "-c" ) or ( $argumentos[$cont] eq "-wc" ) )
		{
			if ( $argumentos[$cont] eq "-wc" ){
				$w=1;
			}
			$c = 1;
			$cont++;
			# Guardo la clave de Busqueda
			if (    ( $cont < $largo )
				and ( (substr $argumentos[$cont], 0, 1 )ne "-" ) )
			{
				$claveBusqueda = $argumentos[$cont];
				$cont++;
			}
			$cont--;
			next;
		}
		if ( ( $argumentos[$cont] eq "-i" ) or ( $argumentos[$cont] eq "-wi" ) )
		{
			if ( $argumentos[$cont] eq "-wi" ){
				$w=1;
			}
			$i = 1;
			$cont++;

			# Cargo la lista de archivos a procesar
			while ( ( $cont < $largo )
				and ( ( (substr $argumentos[$cont], 0, 1) ne "-" ) ) )
			{
				push @listaResultados, $argumentos[$cont];
				$cont++;
			}
			$cont--;
			next;
			}
		return $cadena = "";
	}

}

# Me devuelve el nombre del proximo archivo de Resultados. Revisa automaticamente en el
# directorio de informes.
sub proxNomResu {
	my ( @array, $temp1, @tempArray, $var, $largo );
	my ($ultimo) = 0;    # No tengo estadisticas, entonces sera la primera.
	@array = `ls -1 $INFODIR | sort -r | grep resultado_ | sed 's/_0*/_/'`;
	$largo = @array;
	if ( $largo != 0 ) {
		$temp1 = $array[0];
		$ultimo = substr $temp1, 10;
	}
	$ultimo++;
	$retval = "resultado_" . &convNumInf($ultimo);
}

# Me devuelve el nombre del proximo archivo de Informe. Revisa automaticamente en el
# directorio de informes.
sub proxNomInf {
	my ( @array, $temp1, @tempArray, $var, $largo );
	my ($ultimo) = 0;    # No tengo estadisticas, entonces sera la primera.
	@array = `ls -1 $INFODIR | sort -r | grep informe_ | sed 's/_0*/_/'`;
	$largo = @array;
	if ( $largo != 0 ) {
		$temp1 = $array[0];
		$ultimo = substr $temp1, 8;
	}
	$ultimo++;
	$retval = "informe_" . &convNumInf($ultimo);
}

# Me devuelve el nombre del proximo archivo de estadisticas. Revisa automaticamente en el
# directorio de informes.
sub proxNomEstad {
	my ( @array, $temp1, @tempArray, $var, $largo );
	my ($ultimo) = 0;    # No tengo estadisticas, entonces sera la primera.
	@array = `ls -1 $INFODIR | sort -r | grep estadisticas_ | sed 's/_0*/_/'`;
	$largo = @array;
	if ( $largo != 0 ) {
		$temp1 = $array[0];
		$ultimo = substr $temp1, 13;
	}
	$ultimo++;
	$retval = "estadistica_" . &convNumInf($ultimo);
}

# Convierte el numero del ultimo informe/resultado/estadistica al formato XXX para escribir el
# archivo.
#Recibe: numero
sub convNumInf {
	my ($temp);
	my ($val) = @_;
	if ( $val < 10 ) {
		$temp = sprintf "00%1.0f", $val;
	}
	elsif ( $val < 100 ) {
		$temp = sprintf "0%2.0f", $val;
	}
	else {
		$temp = sprintf "%3.0f", $val;
	}
	$retval = $temp;
}

#Obtengo el listado de Emisores en un array de hashes
# Debo tener un array definido con el nombre Emisores
# Regresa HASH de emisores
sub cargoEmisores {
	my %Emisores;
	open( ARCH, $MAEDIR . "emisores.mae" )
	  || die "No se pudo encontrar el archivo de maestros Emisores";
	while (<ARCH>) {
		my @regTemp = split( ";", $_ );
		my %tempEmisores = ();
		$tempEmisores{Emisor}    = $regTemp[1];
		$tempEmisores{Cod_Firma} = $regTemp[2];
		$tempEmisores{Externo}   = $regTemp[3];
		$Emisores{ $regTemp[0] } = \%tempEmisores;
	}
	close(ARCH);
	return %Emisores;
}

#Obtengo el listado de Gestiones en un array de hashes
# Debo tener un hash definido con el nombre Gestiones
# Regresa HASH de gestiones
sub cargoGestiones {
	my %Gestiones;
	open( ARCH, $MAEDIR . "gestiones.mae" )
	  || die "No se pudo encontrar el archivo de maestros Gestiones";
	while (<ARCH>) {
		my @regTemp = split( ";", $_ );
		my %tempGestiones = ();
		$tempGestiones{Fecha_Desde} = $regTemp[1];
		$tempGestiones{Fecha_Hasta} = $regTemp[2];
		$tempGestiones{Descripcion} = $regTemp[3];
		$tempGestiones{AutoNumera}  = $regTemp[4];
		$Gestiones{ $regTemp[0] }   = \%tempGestiones;
	}
	close(ARCH);
	return %Gestiones;
}

#Obtengo el listado de Normas en un array de hashes
# Debo tener un hash definido con el nombre TiposNorma
# Regresa HASH de TiposNorma
sub cargoTiposNorma {
	my %TiposNorma;
	open( ARCH, $MAEDIR . "normas.mae" )
	  || die "No se pudo encontrar el archivo de maestros Normas";
	while (<ARCH>) {
		my @regTemp = split( ";", $_ );
		my %tempNormas = ();
		$tempNormas{Norma}         = $regTemp[1];
		$tempNormas{Externo}       = $regTemp[2];
		$TiposNorma{ $regTemp[0] } = \%tempNormas;
	}
	close(ARCH);
	return %TiposNorma;
}

# Ingreso el filtro para las normas
sub filtroNorma {

	# Va a ejecutarse el ciclo hasta que se ingrese un codigo de norma valido
	while (1) {
		$cadena = "";
		print "Ingrese  el codigo de norma por el que desea filtrar: ";
		$cadena = <STDIN>;
		chomp($cadena);
		if ( ( exists $TiposNorma{$cadena} ) || ( $cadena eq "" ) ) {
			last;
		}
		else {
			print
			  "El codigo de norma ingresada no existe, intentelo nuevamente\n";
		}
	}
	$retval = $cadena;
}

# Ingreso el filtro para los Emisores
sub filtroEmisor {
	$bandera = 1;

	# Va a ejecutarse el ciclo hasta que se ingrese un codigo de emisor valido
	while (1) {
		$cadena = "";
		print "Ingrese  el codigo de emisor por el que desea filtrar: ";
		$cadena = <STDIN>;
		chomp($cadena);
		if ( ( exists $Emisores{$cadena} ) || ( $cadena eq "" ) ) {
			last;
		}
		else {
			print
			  "El codigo de emisor ingresado no existe, intentelo nuevamente\n";
		}
	}
	$retval = $cadena;
}

# Ingreso el filtro para las gestiones
sub filtroGestion {
	$bandera = 1;

	# Va a ejecutarse el ciclo, hasta que se ingrese un codigo de gestion valido
	while (1) {
		$cadena = "";
		print "Ingrese el codigo de gestion por el que desea filtrar: ";
		$cadena = <STDIN>;
		chomp($cadena);
		if ( ( exists $Gestiones{$cadena} ) || ( $cadena eq "" ) ) {
			last;
		}
		else {
			print "El codigo de gestion no existe, intentelo nuevamente\n";
		}
	}
	$retval = $cadena;
}

# Ingreso el filtro para los periodos
sub filtroAnio {
	my @anios = ();

	# El ciclo se ejecutara mientras el periodo ingresado no sea valido
	while (1) {
		@anios  = ();
		$cadena = "";
		print "Ingrese el periodo a buscar(AñoIncial-AñoFinal): ";
		$cadena = <STDIN>;
		chomp($cadena);

		#Si no ingrese periodo, entonces busco todo
		if ( $cadena eq "" ) {
			last;
		}
		@anios = split( "-", $cadena );

	   # Aqui valido que no se haya ingresado mas valores de los que corresponde
		if ( @anios > 2 ) {
			print
"El rango se ingreso incorrectamente( debe ser entre 2 anios), por favor ingreselo nuevamente \n";
			print
"El rango puede ser vacio, un unico año o un rango indentificado por los \n";
			print
"dos valores separados por un guion(-). El año debe estar el rango de años\n";
			print "validos($ANIOINICIAL - $year)\n";
		}
		elsif ( @anios == 1 ) {

# valido que se haya ingresado un año valido(numero y entre los periodos validos)
			my ($valor) = @anios;
			if (   ( $valor =~ /^\d+$/ )
				&& ( $valor >= $ANIOINICIAL )
				&& ( $valor <= $year ) )
			{
				last;
			}
			print
"El anio ingresado no contiene un anio valido, por favor ingreselo nuevamente \n";
			print
"El rango puede ser vacio, un unico año o un rango indentificado por los \n";
			print
"dos valores separados por un guion(-). El año debe estar el rango de años\n";
			print "validos($ANIOINICIAL - $year)\n";
		}
		else {

			# valido que se haya ingresado un periodo valido
			my ( $valor1, $valor2 ) = @anios;
			if (   ( $valor1 =~ /^\d+$/ )
				&& ( $valor2 =~ /^\d+$/ )
				&& ( $valor1 >= $ANIOINICIAL )
				&& ( $valor1 <= $year )
				&& ( $valor2 >= $ANIOINICIAL )
				&& ( $valor2 <= $year )
				&& ( $valor1 <= $valor2 ) )
			{
				last;
			}
			print
"El periodo ingresado es incorrecto( los valores deben estar ordenados cronologicamente, \n";
			print
"ser numero y estar dentro del rango de años validos($ANIOINICIAL - $year), ingresolo nuevamente \n";
			print
"El rango puede ser vacio, un unico numero o un rango indentificado por los \n";
			print "dos valores separados por un guion(-)\n";
		}
	}
	return @anios;
}

# Ingreso el filtro para los rangos de numero de norma
sub filtroNroNorma {
	my @nroNorma;

	#El ciclo se ejecuta mientras no se ingrese un numero de norma valido.
	while (1) {
		@nroNorma = ();
		$cadena   = "";
		print
"Ingrese el rango de numero de Norma  a buscar(Nro Incial-NroFinal): ";
		$cadena = <STDIN>;
		chomp($cadena);

		#Si no ingrese periodo, entonces busco todo
		if ( $cadena eq "" ) {
			last;
		}
		@nroNorma = split( "-", $cadena );
		if ( @nroNorma > 2 ) {
			print
"El rango se ingreso incorrectamente(Se ingresaron mas de 2 valores para el rango), intentelo nuevamente\n";
			print
"El rango puede ser vacio, un unico numero o un rango indentificado por los \n";
			print "dos valores separados por un guion(-)\n";
		}
		elsif ( @nroNorma == 1 ) {

			# valido que se haya ingresado un numero valido
			my ($valor) = @nroNorma;
			if ( $valor =~ /^\d+$/ ) {
				last;
			}
			print
"El rango se ingreso incorrectamente( no se ingreso un número correcto), intentelo nuevamente\n";
			print
"El rango puede ser vacio, un unico numero o un rango indentificado por los \n";
			print "dos valores separados por un guion(-)\n";
		}
		else {

			# valido que se haya ingresado un periodo valido
			my ( $valor1, $valor2 ) = @nroNorma;
			if (   ( $valor1 =~ /^\d+$/ )
				&& ( $valor2 =~ /^\d+$/ )
				&& ( $valor1 <= $valor2 ) )
			{
				last;
			}
			print
"El rango se ingreso incorrectamente(Los valores deben ser numericos y estar ordenados de menor a mayor), intentelo nuevamente\n";
			print
"El rango puede ser vacio, un unico numero o un rango indentificado por los \n";
			print "dos valores separados por un guion(-)\n";
		}
	}
	return @nroNorma;
}

# Me Si la lista de resultados es la correcta
# Recibe una lista de cadenas
sub validoListaResultados {
	my $ret = 0;
	foreach $resultado (@_) {
		if ( !&existeResultado($resultado) ) {
			print "El archivo $resultado no existe\n";
			$ret = 1;
		}
	}
	$retval = ( $ret == 0 );
}

# Me devuelve si existe el archivo de resultado ingresado.
# Recibe una cadena con el nombre de archivo
sub existeResultado {
	my ($resultado) = @_;
	my $ret = 0;
	my (@array);
	@array  = `ls -1 $INFODIR | grep $resultado`;
	$retval = ( @array == 1 );
}

# Cuenta las ocurrencias en una $cadena de una determinada $clave
sub cuentoOcurrencias {
	my ( $cadena, $clave ) = @_;
	my $cant = 0;
	while ( $cadena =~ /$clave/g ) {
		$cant++;
	}
	return $cant;
}

#A partir de un anio, me fijo si esta dentro de los filtros ingresados para la consulta
sub validoAnios {
	my ($anio) = @_;
	if ( @filtroAnios == 0 ) {
		return 1;
	}
	elsif ( @filtroAnios == 1 ) {
		if ( $anio == $filtroAnios[0] ) {
			return 1;
		}
	}
	else {
		if (    ( $anio >= $filtroAnios[0] )
			and ( $anio <= $filtroAnios[1] ) )
		{
			return 1;
		}
	}
	return 0;
}

#A partir de un nro de Norma, me fijo si esta dentro de los filtros ingresados para la consulta
sub validoNroNorma {
	my ($nro) = @_;
	if ( @nroNorma == 0 ) {
		return 1;
	}
	elsif ( @nroNorma == 1 ) {
		return ( $nro == $nroNorma[0] );
	}
	else {
		return ( ( $nro >= $nroNorma[0] ) and ( $nro <= $nroNorma[1] ) );
	}
}

# escribo la fecha en un formato Comparable
sub fecha_comparable {
	my ($fecha) = @_;
	my ( $D, $M, $Y ) = $fecha =~ m{^([0-9]{2})/([0-9]{2})/([0-9]{4})};
	return "$Y$M$D";
}

# Chequeo que no haya mas de una instancia corriendo
sub validoInstancias {
	@array = `ps -ef | grep InfPro`;
	$largo = 0;
	foreach (@array) {
		@tmp = split( " ", $_ );
		if ( ( $$ == $tmp[1] ) or ( $$ == $tmp[2] ) or ( $_ =~ /grep/ ) ) {
			next;
		}
		print $_. "\n";
		$largo++;
	}
	return ( $largo != 0 );
}

#     Imprime la ayuda de la función.
sub mostrarAyuda() {
	system(clear);
	print " Descripción:\n";
	print
	  " Parte del sistema SisProG. Nos permite realizar consultas sobre los\n";
	print
	  " documentos protocolizados y emitir informes y/o  estadísticas sobre\n";
	print
	  " ellos. Los resultados se emitiran por salida stdout,  y podran  ser\n";
	print " generados a archivo.\n";
	print "\n";
	print " Argumentos:\n";
	print " -a\n";
	print "    muestra la ayuda.\n";
	print " -w\n";
	print "    indica que la consulta se escribira a archivo\n";
	print " -c\n";
	print
	  "    se realizara una consulta sobre los documentos protocolizados.\n";
	print "    Para la consulta se podran realizar los siguientes filtros:\n";
	print "      - Filtro por tipo de norma (todas, una)\n";
	print
"      - Filtro por año. Para ingresar un año en particular (todos, rango de años)\n";
	print
"         * Para ingresar un año en particular se ingresa este completo( 4 digitos).\n";
	print
"         * Para ingresar un rango, se ingresan los años separados por un guión(-),\n";
	print
"           ambos deben estar en formato de 4 dígitos y ordenados cronologicamente\n";
	print
	  "         * En el caso que se desee observar todos, no ingresa nada\n";
	print "      - Filtro por numero de norma (todas, rango de números)\n";
	print "         * Para ingresar un número en particular.\n";
	print
"         * Para ingresar un rango, se ingresan los números separados por un guión(-),\n";
	print "           ambos deben estar ordenados crecientemente\n";
	print
	  "         * En el caso que se desee observar todos, no ingresa nada\n";
	print "      - Filtro por gestión (todas, una)\n";
	print "      - Filtro por emisor (todos, uno\n";
	print " -i\n";
	print
"    genera un informe a partir de los resultados de estadisticas anteriores.\n";
	print
"    Puede ir en conjunto con el parámetro -c para ingresar claves y filtros para\n";
	print "    la búsqueda.\n";
	print " -e\n";
	print "    genera estadisticas a sobre los documentos protocolizados.\n";
	print "    Para la consulta se podran realizar los siguientes filtros:\n";
	print
"      - Filtro por año. Para ingresar un año en particular (todos, rango de años)\n";
	print
"         * Para ingresar un año en particular se ingresa este completo( 4 digitos).\n";
	print
"         * Para ingresar un rango, se ingresan los años separados por un guión(-),\n";
	print
"           ambos deben estar en formato de 4 dígitos y ordenados cronologicamente\n";
	print
	  "         * En el caso que se desee observar todos, no ingresa nada\n";
	print "      - Filtro por gestión (todas, una)\n";
	print " \n";
	print " El parámetro -e no puede ir junto con los parámetros -c o -i.\n";
	print "\n";
}

sub main {
	local ( $e, $i, $w, $c, @listaResultados, $claveBusqueda );

	my $cadena = "";
	my $error  = 0;

	while (1) {

		if ($error) {
			print "No se ingresaron los parametros correctos\n";
		}

		# Blanqueo las variables del comando.
		$error           = 0;
		$i               = 0;
		$e               = 0;
		$c               = 0;
		$w               = 0;
		@listaResultados = ();
		$claveBusqueda   = "";
		print "Ingrese la consulta a realizar(q para salir, -a para ayuda): ";
		$cadena = <STDIN>;

		system(clear);
		chomp($cadena);

		if ( $cadena eq "q" ) {
			last;
		}
		&procesoArgumentos($cadena);
		if ( ( $e + $i ) > 1 ) {
			print "No se pueden seleccionar estadistica junto con informe\n";

			next;
		}
		if ( ( $e + $c ) > 1 ) {
			print "No se pueden seleccionar estadistica junto con consulta\n";
			next;
		}
		if ( $e == 1 ) {
			&realizoEstadistica;
		}
		elsif ( $i == 1 ) {
			&realizoInforme;
		}
		elsif ( $c == 1 ) {
			&realizoConsulta;
		}
		else {
			$error = 1;
		}

	}

	exit;
}

main();
