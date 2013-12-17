/* v.1.0 14/11/2013
 * AEB 19.44 Adeudos Directos Versión 2.0 RB SEPA B2B Direct Debit
 * Valido para periodo transitorio Noviembre 2010 / Enero 2016
 * (c) Joaquim Ferrer Godoy <quim_ferrer@yahoo.es>
 *
 * Notas:
 * Version para CA-Clipper/Harbour, 'casi en pseudo-codigo', para adaptar 
 * facilmente a otros paradigmas (OOPS, arrays asociativos, etc.) o lenguajes
 * de programación.
 * Las variables no declaradas se pueden sustituir por campos de base de datos
 */

#include "fileio.ch"

function main()

	local cFile   := "test1944.txt"
	local nHandle := fcreate( cFile, FO_READWRITE + FO_EXCLUSIVE )
	local nError  := ferror()

	if nError != 0
	   qout( "No es posible crear fichero" )
	else
	   GenFile(nHandle)
	   fclose(nHandle)
   	   qout( cFile +" creado con exito" )
	endif

return nError


static function GenFile(nHandle)

	local a
	local nTotImporte := 0
	local nRegistros  := 0

	Norma 			:= '19445'
	Sufijo 		 	:= "000"									// Facilitado por el Banco, codifica sus productos internos

	pres_Entidad  	:= '0081'
	pres_Oficina 	:= '1234'
	pres_Referencia := 'REMESA0000123'							// Texto libre para referencia del presentador
	pres_Nombre		:= "NOMBRE DEL PRESENTADOR, S.L."
	pres_Pais		:= "ES"
	pres_Nif	 	:= "W9614457A"

	acre_Nombre		:= "NOMBRE DEL ACREEDOR, S.L."
	acre_Direcc	 	:= "CALLE DEL ACREEDOR, 1234"
	acre_Ciudad	 	:= "12345 CIUDAD DEL ACREEDOR"
	acre_Provin	 	:= "PROVINCIA DEL ACREEDOR"
	acre_Pais		:= "ES"
	acre_Nif	 	:= "E77846772"
	acre_Cta 		:= 'ES7600811234461234567890'
																// FNAL Último adeudo de varios FRST Primer adeudo de varios 
	deut_Adeudo 	:= 'OOFF'									// OOFF Unico pago RCUR Adeudo de varios que no es FNAL ni FRST
	deut_Categoria	:= ''										// Opcional segun tabla de categorias de proposito
	deut_Referencia := 'RECIBO002401'							// Referencia unica para identificacion del recibo
	deut_RMandato 	:= hb_md5("002050")					 		// Ref.unica orden domiciliación. Utilizar hash, p.e., codigo cliente
	deut_DMandato 	:= ctod('05-20-2013') 						// Fecha orden domiciliación o mandato	
	deut_Nombre 	:= 'NOMBRE DEL DEUDOR, S.L.'
	deut_Direcc 	:= 'CALLE DEL DEUDOR, 432'
	deut_Ciudad 	:= '65490 CIUDAD DEL DEUDOR'
	deut_Provin     := 'PROVINCIA DEL DEUDOR'
	deut_Pais		:= "ES"
	deut_Nif 		:= '12345678Z'								// Regla de uso en la comunidad española: figurará NIF o NIE del deudor
	deut_Cta 		:= 'ES0321001234561234567890'
	deut_BIC 		:= 'CAIXESBBXXX'
	deut_Importe 	:= 123.45
	deut_Plazo		:= ctod('12-20-2013')
	deut_Tipo 		:= '' 										// Opcional, tipo de persona 1=Juridica 2=Fisica 
	deut_Emisor 	:= ''										// Opcional, solo si se usa deut_Tipo
	deut_IdCta 		:= 'A'										// A=IBAN B=CCC
	deut_Proposito  := ''										// Opcional, 4 digitos segun tabla ISO 20022 UNIFI
	deut_Concepto   := 'CONCEPTO DEL ADEUDO FRA.1234'			// Opcional, Información definida por el acreedor y que la entidad del
																// deudor debe comunicar al deudor cuando adeude la cuenta de su cliente.
	/*
	---------------------------------------------------
	CABECERA DE PRESENTADOR
	---------------------------------------------------
	*/

	a := array(10)
																// N.Descipcion OB=Obligatorio OP=Opcional Tipo   	Len 	Posiciones
	a[  1] = padR('01', 2)										// 1 Código de Registro 			OB Numérico 	Len=2 	Pos:01-02
	a[  2] = padR(Norma, 5) 									// 2 Versión del Cuaderno			OB Numérico 	Len=5 	Pos:03-07 
	a[  3] = padR('001', 3)										// 3 Número de Dato 				OB Numérico 	Len=3 	Pos:08-10 
	a[  4] = Id_Name(pres_Pais, Sufijo, pres_Nif)				// 4 Identificador del Presentador 	OB Alfanumérico Len=35 	Pos:11-45 
	a[  5] = padR(pres_Nombre, 70) 								// 5 Nombre del Presentador 		OB Alfanumérico Len=70  Pos:46-115    
	a[  6] = padR(fDate(), 8)									// 6 Fecha de creación del fichero 	OB Numérico		Len=8 	Pos:116-123 
	a[  7] = Id_File(pres_Referencia)						  	// 7 Id. del fichero 				OB Alfanumérico Len=35 	Pos:124-158 
	a[  8] = padR(pres_Entidad, 4)								// 8 Entidad receptora 				OB Numérico 	Len=4	Pos:159-162 
	a[  9] = padR(pres_Oficina, 4)								// 9 Oficina receptora 				OB Numérico 	Len=4 	Pos:163-166 
	a[ 10] = padR('', 434)										// 10 Libre 						OB Alfanumérico	Len=434 Pos:167-600 

	OutFile(nHandle, a)

	/*
	---------------------------------------------------
	REGISTRO DE CABECERA DE ACREEDOR POR FECHA DE COBRO
	---------------------------------------------------
	*/
/* --> bucle para multiples ordenes */
	a := array(12)

	a[  1] = padR('02', 2)										// 1 Código de Registro 			OB Numérico 	Len=2 	Pos:01-02
	a[  2] = padR(Norma, 5) 									// 2 Versión del Cuaderno			OB Numérico 	Len=5 	Pos:03-07 
	a[  3] = padR('002', 3)										// 3 Número de Dato 				OB Numérico 	Len=3 	Pos:08-10 
	a[  4] = Id_Name(acre_Pais, Sufijo, acre_Nif)				// 4 Identificador del Acreedor	 	OB Alfanumérico Len=35 	Pos:11-45 
	a[  5] = padR(fDate(deut_Plazo), 8)							// 5 Fecha de cobro					OB Numérico		Len=8 	Pos:46-53 
	a[  6] = padR(acre_Nombre, 70)								// 6 Nombre del Acreedor			OB Alfanumérico Len=70  Pos:54-123 
	a[  7] = padR(acre_Direcc, 50)								// 7 Dirección Acreedor 			OP Alfanumérico Len=50  Pos:124-173 
	a[  8] = padR(acre_Ciudad, 50)  							// 8 CP + Ciudad del Acreedor 		OP Alfanumérico Len=50  Pos:174-223                                 
	a[  9] = padR(acre_Provin, 40)        						// 9 Provincia del Acreedor			OP Alfanumérico Len=40  Pos:224-263                       
	a[ 10] = padR(acre_Pais, 2)									// 10 Código ISO 3166 pais Acreedor OP Alfanumérico Len=2 	Pos:264-265 
	a[ 11] = padR(acre_Cta, 34) 								// 11 Cuenta del Acreedor 			OB Alfanumérico Len=34 	Pos:266-299 
	a[ 12] = padR('', 301)										// 12 Libre 						OB Alfanumérico Len=301 Pos:300-600 

	OutFile(nHandle, a)

	/*
	-------------------------------------------------------------
	REGISTRO 1º INDIVIDUAL OBLIGATORIO
	-------------------------------------------------------------
	*/

	a := array(23)

	a[  1] = padR('03', 2)										//  1 Código de Registro 			OB Numérico 	Len=2 	Pos:01-02
	a[  2] = padR(Norma, 5) 									//  2 Versión del Cuaderno			OB Numérico 	Len=5 	Pos:03-07 
	a[  3] = padR('003', 3)										//  3 Número de Dato 				OB Numérico 	Len=3 	Pos:08-10 
	a[  4] = padR(deut_Referencia, 35)							//  4 Referencia del adeudo 		OB Alfanumérico Len=35 	Pos:11-45 
	a[  5] = padR(deut_RMandato, 35) 							//  5 Referencia única del mandato  OB Alfanumérico Len=35 	Pos:46-80                      
	a[  6] = padR(deut_Adeudo, 4)								//  6 Tipo de adeudo				OB Alfanumérico Len=4 	Pos:81-84 
	a[  7] = padR(deut_Categoria, 4)							//  7 Categoría de propósito 		OP Alfanumérico Len=4	Pos:85-88 
	a[  8] = Dec2Str(deut_Importe, 11)							//  8 Importe del adeudo	 		OB Numérico		Len=11 	Pos:89-99
	a[  9] = padR(fDate(deut_DMandato), 8)						//  9 Fecha de firma del mandato	OB Numérico 	Len=8 	Pos:100-107
	a[ 10] = padR(deut_BIC, 11)									// 10 Entidad del Deudor			OB Alfanumérico Len=11 	Pos:108-118 
	a[ 11] = padR(deut_Nombre, 70) 								// 11 Nombre del Deudor 			OB Alfanumérico Len=70 	Pos:119-188
	a[ 12] = padR(deut_Direcc, 50) 								// 12 Dirección Deudor 				OP Alfanumérico Len=50 	Pos:189-238 
	a[ 13] = padR(deut_Ciudad, 50) 								// 13 CP + Ciudad del Deudor 		OP Alfanumérico Len=50 	Pos:239-288 
	a[ 14] = padR(deut_Provin, 40)								// 14 Provincia del Deudor 			OP Alfanumérico Len=40 	Pos:289-328 
	a[ 15] = padR(deut_Pais, 2)  								// 15 Codigo ISO 3166 pais Deudor 	OP Alfanumérico Len=2 	Pos:329-330 
	a[ 16] = padR(deut_Tipo, 1) 								// 16 Tipo Identificación Deudor 	OP Numérico 	Len=1 	Pos:331 
	a[ 17] = padR(deut_Nif, 36)									// 17 Identificación del Deudor 	OP Alfanumérico Len=36 	Pos:332-367 
	a[ 18] = padR(deut_Emisor, 35) 								// 18 Id.del Deudor Emisor Código 	OP Alfanumérico Len=35 	Pos:368-402 
	a[ 19] = padR(deut_IdCta, 1)								// 19 Id.de la cuenta del Deudor 	OB Alfanumérico Len=1 	Pos:403 
	a[ 20] = padR(deut_Cta, 34) 								// 20 Cuenta del Deudor 			OB Alfanumérico Len=34 	Pos:404-437
	a[ 21] = padR('', 4) 										// 21 Propósito del adeudo 			OP Alfanumérico Len=4 	Pos:438-441 
	a[ 22] = padR(deut_Concepto, 140) 							// 22 Concepto						OP Alfanumérico Len=140 Pos:442-581 
	a[ 23] = padR('', 19) 										// 23 Libre 						OB Alfanumérico Len=19 	Pos:582-600

	OutFile(nHandle, a)

	nTotImporte += deut_Importe
	nRegistros  += 1

	/*
	---------------------------------------------------
	REGISTROS DE TOTALES DE ACREEDOR POR FECHA DE COBRO
	---------------------------------------------------
	*/

	a := array(7)

	a[  1] = padR('04', 2)										// 1 Código de Registro 			OB Numérico 	Len=2 	Pos:01-02
	a[  2] = Id_Name(acre_Pais, Sufijo, acre_Nif)				// 2 Identificador del Acreedor	 	OB Alfanumérico Len=35 	Pos:03-37  
	a[  3] = padR(fDate(deut_Plazo), 8)							// 3 Fecha de cobro					OB Numérico		Len=8 	Pos:38-45 
	a[  4] = Dec2Str(nTotImporte, 17)							// 4 Total de Importes				OB Numérico		Len=17 	Pos:46-62
	a[  5] = strzero(nRegistros, 8)								// 5 Número de Adeudos 				OB Numérico 	Len=8 	Pos:63-70 
	a[  6] = strzero(nRegistros +2, 10)							// 6 Total de Registros 			OB Numérico 	Len=10 	Pos:71-80
	a[  7] = padR('', 520) 										// 7 Libre 							OB Alfanumérico Len=520 Pos:81-600

	OutFile(nHandle, a)

/* <-- bucle para multiples ordenes */

	/*
	---------------------------------------------------
	REGISTROS DE TOTALES DE ACREEDOR
	---------------------------------------------------
	*/

	a := array(6)

	a[  1] = padR('05', 2)										// 1 Código de Registro 			OB Numérico 	Len=2 	Pos:01-02
	a[  2] = Id_Name(acre_Pais, Sufijo, acre_Nif)				// 2 Identificador del Acreedor	 	OB Alfanumérico Len=35 	Pos:03-37  
	a[  3] = Dec2Str(nTotImporte, 17) 							// 3 Total de Importes				OB Numérico		Len=17 	Pos:38-54 
	a[  4] = strzero(nRegistros, 8) 							// 4 Número de Adeudos 				OB Numérico 	Len=8 	Pos:55-62 
	a[  5] = strzero(nRegistros +3, 10)							// 5 Total de Registros 			OB Numérico 	Len=10 	Pos:63-72
	a[  6] = padR('', 528)										// 6 Libre 							OB Alfanumérico Len=528	Pos:73-600

	OutFile(nHandle, a)

	/*
	---------------------------------------------------
	REGISTRO DE TOTALES GENERAL
	---------------------------------------------------
	*/

	a := array(5)

	a[  1] = padR('99', 2)										// 1 Código de Registro 			OB Numérico 	Len=2 	Pos:01-02
	a[  2] = Dec2Str(nTotImporte, 17) 							// 2 Total de Importes				OB Numérico		Len=17 	Pos:03-19 
	a[  3] = strzero(nRegistros, 8)								// 3 Número de Adeudos 				OB Numérico 	Len=8 	Pos:20-27 
	a[  4] = strzero(nRegistros +5, 10)							// 4 Total de Registros 			OB Numérico 	Len=10 	Pos:28-37
	a[  5] = padR('', 563) 										// 5 Libre 							OB Alfanumérico Len=563 Pos:38-600

	OutFile(nHandle, a)

return NIL