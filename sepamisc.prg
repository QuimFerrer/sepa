/* v.1.0 14/11/2013
 * v.2.0 17/02/2016
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


function sDate( d )
	local cDateFrm := Set( 4, "yyyy-mm-dd" )
	local strDate  := If( d != NIL, dtoc(d), dtoc(date()) )
	Set( 4, cDateFrm )
return( strDate )


function Dec2Str(nVal, nLen)
	local strVal
	strVal := str( nVal, nLen +1, 2 )	  // +1 espacio que resta punto decimal
	strVal := strtran( strVal, "." )      // Quitar punto decimal
	strVal := strtran( strVal, " ", "0" ) // Reemplazar espacios por 0
return( strVal )


function IsoDateTime()
return( sDate() +"T"+ time() ) 	  // YYYY-MM-DDThh:mm:ss


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
 local cId, cValue
 local n, nLen
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


/*
	3.9.5.  Características y formas de intercambio de mensajes
	La  forma  y  lugar  de  entrega  de  los  mensajes,  se  pactará  bilateralmente  entre  las  entidades  y  los 
	presentadores.
	Las características y contenido del  mensaje  deberán ajustarse a las reglas del esquema de  adeudos 
	directos SEPA. En el mismo se defin en, entre otras reglas, los caracteres admitidos, que se ajustarán 
	a los siguientes:
	TABLA DE CODIFICACIÓN DE CARACTERES DEL ESTÁNDAR  ISO20022
	A  B  C  D  E  F  G  H  I    J   K   L   M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
	a  b  c  d  e  f  g  h  i   j   k  l   m  n  o  p  q  r  S  t  u  v  w  x  y  z
	0  1  2  3  4  5  6  7  8  9  /  -  ?  :  (  )  .  ,    ‘  +  espacio
	La conversión de caracteres no  válidos de adeudos  a caracteres SEPA  válidos se producirá con la 
	siguiente regla:
	Ñ,ñ  a  N,n
	Ç,ç  a  C,c
	No  obstante,  la  entidad  del  ac reedor  podrá  admitir  el  uso  de  otros  caracteres,  sin  que  pueda 
	garantizarse que los datos no sean convertidos en alguna fase del proceso.
	Además,  hay  cinco  caracteres  que  no  pueden  utilizarse  de  forma  literal  en  ISO  20022,  excepto 
	cuando se utilizan para delimit ar etiquetas, o dentro  de un comentario  o una instrucción de proceso. 
	Cuando se vayan a utilizar en cualquier texto libre, se deben sustituir por su representación ASCII:
	Carácter no permitido en XML   Representación ASCII
	& (ampersand)  &amp;
	< (menor que)  &lt;
	> (mayor que)  &gt;
	“ (dobles comillas)   &quot;
	' (apóstrofe)   &apos;
	Por  razones  técnicas  puede  ser  conveniente  establecer  un  límite  máximo  en  el  número  de 
	operaciones a incluir en cada fichero, que deberá comunicarle su entidad. 
*/
function str2iso2022( cStr )
	
	local i, nPos, cChar
	local cTxt := ""
	local nLen := len(cStr)
	local cPattern := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/-?:().,"

/* Atención. Este archivo tiene que ser guardado con la codificación
 * Windows 1252, en caso contrario, la función at(cChar, cSubPtrn) fallará
 */ 
	local cSubPtrn := [ÇcñÑ&<>"']
	local aReplace := {"C", "C", "N", "N", "&amp;", "&lt;", "&gt;", "&quot;", "&apos;" }

	for i:=1 to nLen
		cChar := substr(cStr, i, 1)
		if empty(cChar)
			cTxt += cChar
		else
			if at(cChar, cPattern) > 0
				cTxt += cChar
			else
				if (nPos := at(cChar, cSubPtrn)) > 0
					cTxt += aReplace[nPos]
				else
					cTxt += '?'
				endif
			endif
		endif
	next
return rtrim( cTxt )