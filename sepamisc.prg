/* v.1.0 14/11/2013
 * Funciones misceláneas de apoyo a formatos SEPA
 * (c) Joaquim Ferrer Godoy <quim_ferrer@yahoo.es>
 */

#define CRLF chr(13)+chr(10)

function cTime()
	local strTime := time()
	strTime := substr(strTime,1,2) + substr(strTime,4,2) + substr(strTime,7,2)
return strTime


function fDate( d )
	local cDateFrm := Set( 4, "yyyy/mm/dd" )
	local strDate  := If( d != NIL, dtos(d), dtos(date()) )
	Set( 4, cDateFrm )
return( strDate )


function Dec2Str(nVal, nLen)
	local strVal
	strVal := str( nVal, nLen +1, 2 )	  // +1 espacio que resta punto decimal
	strVal := strtran( strVal, "." )      // Quitar punto decimal
	strVal := strtran( strVal, " ", "0" ) // Reemplazar espacios por 0
return( strVal )


function OutFile(nHandle, a)
	local strRec := ""
	aeval( a, {|e|  strRec += e } )
	fwrite(nHandle, strRec + CRLF)
return NIL


function Id_Name( cCountry, cCode, cNif )
/*
Identificador del Presentador / Acreedor
Este identificador es una referencia con un máximo de 35 caracteres que contiene los siguientes elementos:
	a) Código del país3: (Posiciones 1ª y 2ª)
	Código ISO 3166 del país que ha emitido el identificador nacional del acreedor. “ES” en el caso español.

	b) Dígitos de control: (Posiciones 3ª y 4ª)
	Código que hace referencia a los componentes a y d. Para su cálculo se requiere la siguiente operación:
	• Excluir las posiciones 5 a 7 de esta referencia
	• Entre las posiciones 8 y 35, eliminar todos los espacios y caracteres no alfanuméricos. Esto es: “/ - ? : ( ) . , ' +”.
	• Añadir el código ISO del país, y ‘00’ a la derecha, y
	• Convertir las letras en dígitos, de acuerdo a la tabla de conversión 1
	• Aplicar el sistema de dígitos de control MOD 97-10.
		A=10, B=11... Z=35 

	c) Código comercial del Acreedor (Sufijo): (Posiciones 5 a 7) Número de tres cifras comprendido entre 000 y 999. 
	Contiene información necesaria en la relación entre la entidad del acreedor y el acreedor y permite al acreedor identificar 
	diferentes líneas comerciales o servicios.

	d) Identificación del Acreedor específica de cada país: (Posiciones 8 a 35) Para los acreedores españoles, se indicará 
	el NIF o NIE del acreedor utilizando para ello las posiciones 8 a 16.
*/
 local cId, n, nLen
 local cAlgorithm := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	cId  := ""
	nLen := len( cNif )
	for n:= 1 to nLen
		cValue := substr( cNif, n, 1 )
		if isDigit(cValue)
		   cId += cValue
		else
		   cId += str( at( cValue, cAlgorithm ) +9, 2, 0 )
		endif
	next

	cId += str( at( substr(cCountry,1,1), cAlgorithm ) +9, 2, 0 )
	cId += str( at( substr(cCountry,2,1), cAlgorithm ) +9, 2, 0 )
	cId += "00"
 	cId := cCountry + strzero(98 - ( val(cId) % 97 ), 2) + cCode + cNif
return padR(cId, 35)


function Id_File( cRef )
/*
Identificación del fichero: referencia que asigna el presentador al fichero, para su envío a la entidad receptora. 
Esta referencia se estructurará de la siguiente manera, tomando los datos generados por el ordenador del presentador 
en el momento de la creación del fichero: 
	 Indicador del tipo de mensaje (3 caracteres) -> PRE Fichero de Presentación de adeudos 
	 AAAAMMDD (año, mes y día) = (8 caracteres) 
	 HHMMSSmmmmm (hora minuto segundo y 5 posiciones de milisegundos = 11 caracteres) 
	 Referencia identificativa que asigne el presentador (13 caracteres) 
*/
	local cId 
	cId := "PRE" + fDate() + cTime() + strzero( seconds(), 5 ) + cRef
return padR(cId, 35)