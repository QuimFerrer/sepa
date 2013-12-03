/* v.1.0 13/11/2013
 * AEB 34.14 Versi�n 4.0 RB SEPA Credit Transfer
 * Ordenes en fichero para emision de transferencias y cheques en euros
 * Valido para periodo transitorio Noviembre 2010 / Enero 2016
 * (c) Joaquim Ferrer Godoy <quim_ferrer@yahoo.es>
 *
 * Notas:
 * Version para CA-Clipper/Harbour, 'casi en pseudo-codigo', para adaptar 
 * facilmente a otros paradigmas (OOPS, arrays asociativos, etc.) o lenguajes
 * de programaci�n.
 * Las variables ord_XXX y ben_XXX se pueden sustituir por campos de base de datos
 */

#include "fileio.ch"

function main()
	
	local cFile   := "test3414.txt"
	local nHandle := fcreate( cFile, FO_READ + FO_EXCLUSIVE )
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

	Norma 		 := '34145'
	Sufijo 		 := "000"							// Facilitado por el Banco, codifica sus productos internos

	ord_Nif		 := "B12345678"
	ord_Dexec	 := date() +3 						// Enviar a la entidad, 3 dias habiles antes de ejecucion
	ord_IdCta	 := "A"								// Id. de la Cuenta del Ordenante : A=IBAN  B=CCC
	ord_Cta 	 := "ES0321001234561234567890"
	ord_Cargo	 := "1"								// 0=Cargo total operaciones 1=Un cargo por operacion
	ord_Nombre	 := "NOMBRE DEL ORDENANTE, S.L."
	ord_Direcc	 := "CALLE DEL ORDENANTE, 1234"
	ord_Ciudad	 := "1234 CIUDAD DEL ORDENANTE"
	ord_Provin	 := "PROVINCIA DEL ORDENANTE"
	ord_Pais	 := "ES"

	ben_Ref		 := "NOMINA112013"					// C�digo identificativo para el ordenante de cada transferencia presentada
	ben_IdCta	 := "A"								// Id. de la Cuenta del Beneficiario : A=IBAN  B=CCC
	ben_Cta 	 := "ES0321001234561234567890"
	ben_Importe	 := 156.25 							// Las 2 utimas posiciones, parte decimal								
	ben_Gastos	 := "3"								// 3 = Gastos compartidos (SHA)
	ben_BIC		 := 'CAIXESBBXXX'
	ben_Nombre	 := "NOMBRE DEL BENEFICIARIO, S.L."
	ben_Direcc	 := "CALLE DEL BENEFICIARIO, 1234"
	ben_Ciudad	 := "1234 CIUDAD DEL BENEFICIARIO"
	ben_Provin	 := "PROVINCIA DEL BENEFICIARIO"
	ben_Pais	 := "ES"
	ben_Concepto := 'NOMINA MENSUAL'
	ben_Type	 := "SALA"							// Obligatorio para transferencias estatales : SALA=Nomina  PENS=Pension
	ben_Purpose	 := "NETT"

	/*
	------------------------------
	REGISTRO DE CABECERA ORDENANTE
	------------------------------
	2) ORD = Ordenes de Transferencias y Cheques
	*/

	a := array(17)
													// N.Descipcion 	OB=Obligatorio OP=Opcional Tipo   Len Posiciones
	a[  1]	= padR('01', 2) 						// 1 C�digo de Registro 					OB Num�rico 2 01-02
	a[  2]	= padR('ORD', 3) 						// 2 C�digo de Operaci�n 					OB Alfanum�rico 3 03-05
	a[  3]	= padR(Norma, 5)						// 3 Versi�n Cuaderno 						OB Num�rico 5 06-10
	a[  4]	= padR('001', 3)						// 4 N�mero de Dato 						OB Num�rico 3 11-13
	a[  5]	= padR(ord_Nif, 9)	 					// 5 Identificaci�n del Ordenante: NIF 		OB Alfanum�rico 9 14-22
	a[  6]	= padR(Sufijo, 3)						// 6 Identificaci�n del Ordenante: Sufijo 	OB Alfanum�rico 3 23-25
	a[  7]	= padR(fDate(), 8) 						// 7 Fecha de Creaci�n del Fichero 			OB Num�rico 8 26-33
	a[  8]	= padR(fDate(ord_Dexec), 8)				// 8 Fecha de Ejecuci�n �rdenes (AT-07)* 	OB Num�rico 8 34-41
	a[  9]	= padR(ord_IdCta, 1)					// 9 Id. de la Cuenta del Ordenante			OB Alfanum�rico 1 42-42
	a[ 10]	= padR(ord_Cta, 34)					 	//10 Cuenta del Ordenante (AT-01) 			OB Alfanum�rico 34 43-76
	a[ 11]	= padR(ord_Cargo, 1)					//11 Detalle del Cargo 						OB Num�rico 1 77-77
	a[ 12] 	= padR(ord_Nombre, 70)					//12 Nombre del Ordenante (AT-02) 			OB Alfanum�rico 70 78-147
	a[ 13]	= padR(ord_Direcc, 50)		 			//13 Direcci�n del Ordenante (AT-03) 		OP Alfanum�rico 50 148-197
	a[ 14] 	= padR(ord_Ciudad, 50)					//14 Direcci�n del Ordenante (AT-03) 		OP Alfanum�rico 50 198-247
	a[ 15]	= padR(ord_Provin, 40)	 				//15 Direcci�n del Ordenante (AT-03) 		OP Alfanum�rico 40 248-287
	a[ 16]	= padR(ord_Pais, 2)						//16 Pa�s del Ordenante (AT-03) 			OP Alfanum�rico 2 288-289
	a[ 17]	= padR('', 311)							//17 Libre 									OB Alfanum�rico 311 290-600

	OutFile(nHandle, a)

	/*
	------------------------------
	REGISTRO DE CABECERA
	------------------------------
	*/

	a := array(6)
													// N.Descipcion 	OB=Obligatorio OP=Opcional Tipo   Len Posiciones
	a[  1]	= padR('02', 2) 						// 1 C�digo de Registro 					OB Num�rico 2 01-02
	a[  2]	= padR('SCT', 3) 						// 2 C�digo de Operaci�n 					OB Alfanum�rico 3 03-05
	a[  3]	= padR(Norma, 5) 						// 3 Versi�n Cuaderno 						OB Num�rico 5 06-10
	a[  4]	= padR(ord_Nif, 9)		 				// 4 Identificaci�n del Ordenante: NIF 		OB Alfanum�rico 9 11-19
	a[  5]	= padR(Sufijo, 3)						// 5 Identificaci�n del Ordenante: Sufijo 	OB Alfanum�rico 3 20-22
	a[  6]	= padR('', 578)							// 6 Libre 									OB Alfanum�rico 578 23-600 

	OutFile(nHandle, a)

	/*
	------------------------------
	REGISTROS DE BENEFICIARIO
	------------------------------
	*/
/* --> bucle para multiples ordenes */
	a := array(20)
													// N.Descipcion 	OB=Obligatorio OP=Opcional Tipo   Len Posiciones
	a[  1]	= padR('03', 2) 						// 1 C�digo de Registro 					OB Num�rico 2 01-02
	a[  2]	= padR('SCT', 3) 						// 2 C�digo de Operaci�n 					OB Alfanum�rico 3 03-05
	a[  3]	= padR(Norma, 5)	 					// 3 Versi�n Cuaderno 						OB Num�rico 5 06-10
	a[  4]	= padR('002', 3) 						// 4 N�mero de Dato 						OB Num�rico 3 11-13
	a[  5]	= padR(ben_Ref, 35) 					// 5 Referencia del Ordenante (AT-41) 		OP Alfanum�rico 35 14-48
	a[  6]	= padR(ben_IdCta, 1)					// 6 Id. de la Cuenta del Beneficiario 		OB Alfanum�rico 1 49-49
	a[  7]	= padR(ben_Cta, 34) 					// 7 Cuenta del Beneficiario (AT-20) 		OB Alfanum�rico 34 50-83
	a[  8]	= Dec2Str(ben_Importe, 11) 				// 8 Importe de Transferencia (AT-04)		OB Num�rico 11 84-94
	a[  9]	= padR(ben_Gastos, 1)					// 9 Clave de Gastos 						OB Num�rico 1 95-95
	a[ 10]	= padR(ben_BIC, 11)						//10 BIC Entidad del Beneficiario (AT-23) 	OB Alfanum�rico 11 96-106
	a[ 11]	= padR(ben_Nombre, 70)					//11 Nombre del Beneficiario (AT-21) 		OB Alfanum�rico 70 107-176
	a[ 12]	= padR(ben_Direcc, 50)		 			//12 Direcci�n del Beneficiario (AT-22) 	OP Alfanum�rico 50 177-226
	a[ 13]	= padR(ben_Ciudad, 50)					//13 Direcci�n del Beneficiario (AT-22) 	OP Alfanum�rico 50 227-276
	a[ 14]	= padR(ben_Provin, 40)	 				//14 Direcci�n del Beneficiario (AT-22) 	OP Alfanum�rico 40 277-316
	a[ 15]	= padR(ben_Pais, 2)						//15 Pa�s del Beneficiario (AT-22) 			OP Alfanum�rico 2 317-318
	a[ 16]	= padR(ben_Concepto, 140)	 			//16 Concepto del Ordenante al Beneficiario OP Alfanum�rico 140 319-458
	a[ 17]	= padR('', 35) 							//17 Referencia para el Beneficiario 		OP Alfanum�rico 35 459-493
	a[ 18]	= padR(ben_Type, 4) 					//18 Tipo de Transferencia (AT-45) 			OP Alfanum�rico 4 494-497
	a[ 19]	= padR(ben_Purpose, 4)					//19 Prop�sito de la Transferencia (AT-44) 	OP Alfanum�rico 4 498-501
	a[ 20]	= padR('', 99)							//20 Libre 									OB Alfanum�rico 99 502-600                                                                                                                                                

	OutFile(nHandle, a)

	nTotImporte += ben_Importe
	nRegistros  += 1
/* <-- bucle para multiples ordenes */

	/*
	------------------------------
	REGISTRO DE TOTALES
	------------------------------
	5) Total de registros : Suma 2 registros (01 02) + todos los registros 03
	*/

	a := array(6)
													// N.Descipcion 	OB=Obligatorio OP=Opcional Tipo   Len Posiciones
	a[  1]	= padR('04', 2)							// 1 C�digo de Registro 					OB Num�rico 2 01-02
	a[  2]	= padR('SCT', 3)						// 2 C�digo de Operaci�n 					OB Alfanum�rico 3 03-05
	a[  3]	= Dec2Str(nTotImporte, 17)				// 3 Total de Importes 						OB Num�rico 17 06-22
	a[  4]	= strzero(nRegistros, 8)				// 4 N�mero de Registros 					OB Num�rico 8 23-30
	a[  5]	= strzero(nRegistros +2, 10)			// 5 Total de Registros 					OB Num�rico 10 31-40
	a[  6]	= padR('', 560)							// 6 Libre 									OB Alfanum�rico 560 41-600 

	OutFile(nHandle, a)

	/*
	------------------------------
	REGISTRO DE TOTALES GENERAL                                                                                                               
	------------------------------
	2)
		ORD = �rdenes de Transferencia y de Emisi�n de Cheques
		SCT = Transferencias SEPA
		OTR = Otras Transferencias
		CHQ = Cheques Bancarios / N�mina

	5)  Total de registros : Suma 4 registros (01 02 04 99) + todos los registros 03

		Nota para campo Importes General :
		Total de importes general = suma de los totales de importes en euros (campo 3) de los registros de
		totales (c�digos de registro 04). Si no se mezclan ordenes de transferencia con emision de cheques,
		el importe Total General se corresponde al de total importes registro 04. En caso contrario, establecer
		acumulador distinto para el total general.
	*/

	a := array(6)
													// N.Descipcion 	OB=Obligatorio OP=Opcional Tipo   		Len Posiciones
	a[  1]	= padR('99', 2)							// 1 C�digo de Registro 					OB Num�rico 	2 	01-02
	a[  2]	= padR('ORD', 3)						// 2 C�digo de Operaci�n 					OB Alfanum�rico 3 	03-05
	a[  3]	= Dec2Str(nTotImporte, 17)				// 3 Total de Importes General				OB Num�rico 	17 	06-22
	a[  4]	= strzero(nRegistros, 8)				// 4 N�mero de Registros 					OB Num�rico 	8 	23-30
	a[  5]	= strzero(nRegistros +4, 10)			// 5 Total de Registros 					OB Num�rico 	10 	31-40
	a[  6]	= padR('', 560)							// 6 Libre 									OB Alfanum�rico 560 41-600 

	OutFile(nHandle, a)

return NIL