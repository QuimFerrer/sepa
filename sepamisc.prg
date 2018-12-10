/* v.1.0 14/11/2013
 * v.2.0 17/02/2016
 * Funciones miscel�neas de apoyo a formatos SEPA
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
Este identificador es una referencia con un m�ximo de 35 caracteres que contiene los siguientes elementos:
	a) C�digo del pa�s3: (Posiciones 1� y 2�)
	C�digo ISO 3166 del pa�s que ha emitido el identificador nacional del acreedor. �ES� en el caso espa�ol.

	b) D�gitos de control: (Posiciones 3� y 4�)
	C�digo que hace referencia a los componentes a y d. Para su c�lculo se requiere la siguiente operaci�n:
	� Excluir las posiciones 5 a 7 de esta referencia
	� Entre las posiciones 8 y 35, eliminar todos los espacios y caracteres no alfanum�ricos. Esto es: �/ - ? : ( ) . , ' +�.
	� A�adir el c�digo ISO del pa�s, y �00� a la derecha, y
	� Convertir las letras en d�gitos, de acuerdo a la tabla de conversi�n 1
	� Aplicar el sistema de d�gitos de control MOD 97-10.
		A=10, B=11... Z=35 

	c) C�digo comercial del Acreedor (Sufijo): (Posiciones 5 a 7) N�mero de tres cifras comprendido entre 000 y 999. 
	Contiene informaci�n necesaria en la relaci�n entre la entidad del acreedor y el acreedor y permite al acreedor identificar 
	diferentes l�neas comerciales o servicios.

	d) Identificaci�n del Acreedor espec�fica de cada pa�s: (Posiciones 8 a 35) Para los acreedores espa�oles, se indicar� 
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
	3.9.5.  Caracter�sticas y formas de intercambio de mensajes
	La  forma  y  lugar  de  entrega  de  los  mensajes,  se  pactar�  bilateralmente  entre  las  entidades  y  los 
	presentadores.
	Las caracter�sticas y contenido del  mensaje  deber�n ajustarse a las reglas del esquema de  adeudos 
	directos SEPA. En el mismo se defin en, entre otras reglas, los caracteres admitidos, que se ajustar�n 
	a los siguientes:
	TABLA DE CODIFICACI�N DE CARACTERES DEL EST�NDAR  ISO20022
	A  B  C  D  E  F  G  H  I    J   K   L   M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
	a  b  c  d  e  f  g  h  i   j   k  l   m  n  o  p  q  r  S  t  u  v  w  x  y  z
	0  1  2  3  4  5  6  7  8  9  /  -  ?  :  (  )  .  ,    �  +  espacio
	La conversi�n de caracteres no  v�lidos de adeudos  a caracteres SEPA  v�lidos se producir� con la 
	siguiente regla:
	�,�  a  N,n
	�,�  a  C,c
	No  obstante,  la  entidad  del  ac reedor  podr�  admitir  el  uso  de  otros  caracteres,  sin  que  pueda 
	garantizarse que los datos no sean convertidos en alguna fase del proceso.
	Adem�s,  hay  cinco  caracteres  que  no  pueden  utilizarse  de  forma  literal  en  ISO  20022,  excepto 
	cuando se utilizan para delimit ar etiquetas, o dentro  de un comentario  o una instrucci�n de proceso. 
	Cuando se vayan a utilizar en cualquier texto libre, se deben sustituir por su representaci�n ASCII:
	Car�cter no permitido en XML   Representaci�n ASCII
	& (ampersand)  &amp;
	< (menor que)  &lt;
	> (mayor que)  &gt;
	� (dobles comillas)   &quot;
	' (ap�strofe)   &apos;
	Por  razones  t�cnicas  puede  ser  conveniente  establecer  un  l�mite  m�ximo  en  el  n�mero  de 
	operaciones a incluir en cada fichero, que deber� comunicarle su entidad. 
*/
function str2iso2022( cStr )
	
	local i, nPos, cChar
	local cTxt := ""
	local nLen := len(cStr)
	local cPattern := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789/-?:().,"

/* Atenci�n. Este archivo tiene que ser guardado con la codificaci�n
 * Windows 1252, en caso contrario, la funci�n at(cChar, cSubPtrn) fallar�
 */ 
	local cSubPtrn := [�c��&<>"']
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