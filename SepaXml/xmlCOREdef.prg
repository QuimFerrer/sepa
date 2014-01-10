/* v.1.0 31/12/2013
 * SEPA Core Direct Debit Versión 6.0 RB Noviembre 2012
 * Adeudos Directos SEPA ESQUEMA BÁSICO (pain.008.001.02) 
 * Para lenguaje Harbour - http://harbour-project.org
 * (c) Joaquim Ferrer Godoy <quim_ferrer@yahoo.es>
 *
 * Notas :
 * (1) TRUE = Un apunte en cuenta por la suma de los importes de todas las operaciones del mensaje.
 *	   FALSE= Un apunte en cuenta por cada una de las operaciones incluidas en el mensaje.
 * (2) FNAL=Último adeudo de una serie de adeudos recurrentes.
 *     FRST=Primer adeudo de una serie de adeudos recurrentes.
 *	   OOFF=Adeudo correspondiente a una operación con un único pago(*).
 *	   RCUR=Adeudo de una serie de adeudos recurrentes, cuando no se trata ni del primero ni del último.
 *		(*) Para este tipo de operaciones el mandato y su referencia deben ser únicos y no pueden utilizarse para operaciones 
 *		puntuales posteriores. Si siempre se factura a los mismos clientes, aunque varie el importe de los adeudos y la periodicidad
 *		de los mismos, es necesario utilizar el tipo de adeudo recurrente si se utiliza la misma referencia, creando para cada 
 *		cliente deudor un solo mandato que ampare todos los adeudos que se emitan. 
 *		El primer adeudo deberá ser FRST y los siguientes RCUR.
 * (3) Esta etiqueta sólo debe usarse cuando un mismo número de cuenta cubra diferentes divisas y el presentador 
 * 	   necesite identificar en cuál de estas divisas debe realizarse el asiento sobre su cuenta.
 * (4) Regla de uso: Solamente se admite el código ‘SLEV’
 * (5) La etiqueta ‘Cláusula de gastos’ puede aparecer, bien en el nodo ‘Información del pago’ (2.0), bien en el 
 * 	   nodo ‘Información de la operación de adeudo directo’ (2.28), pero solamente en uno de ellos. 
 * 	   Se recomienda que se recoja en el bloque ‘Información del pago’ (2.0).
 * (6) Regla de uso: Para el sistema de adeudos SEPA se utilizará exclusivamente la etiqueta “Otra” estructurada 
 *	   según lo definido en el epígrafe “Identificador del presentador” de la sección 3.3 del cuaderno.
 */

#include "hbmxml.ch"

#define CRLF chr(13)+chr(10)

#define ENTIDAD_JURIDICA	0
#define ENTIDAD_FISICA		1
#define ENTIDAD_OTRA		2

static aItems := {}
static aData  := {=>}

//--------------------------------------------------------------------------------------//

function main()

	local cDocType, cFileOut
  	local hXmlDoc, hDoc
  	local aCreditor := {=>}

	cDocType 	:= "pain.008.001.02"
	cFileOut 	:= "testSepa.xml"
	hXmlDoc  	:= mxmlNewXML()
  	hDoc 	 	:= mxmlNewElement(hXmlDoc, "Document")

	mxmlElementSetAttr( hDoc, "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance" )
	mxmlElementSetAttr( hDoc, "xmlns","urn:iso:std:iso:20022:tech:xsd:"+ cDocType )

	aCreditor["Id"] 		:= "NL64ZZZ321096320000"			// Identificación 
	aCreditor["Prtry"] 		:= "SEPA"				 			// Propietario 

	aData[ "MsgId"        ] := "MFISH-20131021195435-wzkR23K" 	// Identificación del mensaje
	aData[ "CreDtTm"      ] := "2013-10-21T19:54:35" 			// Fecha y hora de creación

	/* Variables contador */
	NbOfTxs 				:= "1" 								// Número de operaciones 
	CtrlSum 				:= "100.00" 						// Control de suma total importes

	aData[ "PmtInfId"      ] := "M20131021195-wzkR23K-1" 		// Identificación de la información del pago 
	aData[ "PmtMtd"        ] := "DD" 							// Método de pago Regla de uso: Solamente se admite el código ‘DD’
	aData[ "BtchBookg"     ] := "TRUE" 							// Indicador de apunte en cuenta (1)

	/* Variables contador */
	NbOfTxs 				:= "1" 								// Número de operaciones 
	CtrlSum 				:= "100.00" 						// Control de suma total importes

	aData["SeqTp"          	] := "RCUR" 						// Tipo de secuencia (2)
	aData["PurpCode"		] := "" 							// Código 
	aData["PurpProprietary"	] := "" 							// Propietario
	aData["ReqdColltnDt"   	] := "2013-10-21"					// Fecha de cobro
	aData["CreditorName"   	] := "NOMBRE DEL ACREEDOR" 			// Nombre 
	aData["CreditorCountry"	] := "ES" 							// País
	aData["CreditorAdress" 	] := "" 							// Dirección en texto libre
	aData["CreditorIban"   	] := "NL71RABO0300300301" 			// IBAN
	aData["Ccy"            	] := "" 							// Moneda (3) 
	aData["CreditorBic"    	] := "RABONL2U" 					// BIC 
	aData["ChrgBr"         	] := "SLEV" 						// Cláusula de gastos (4)
	aData["InstrId"        	] := "" 							// Identificación de la instrucción
	aData["EndToEndId"     	] := "M20131021195-wzkR23K-1-0001" 	// Identificación de extremo a extremo 
	aData["InstdAmt"  	   	] := "5.00" 						// Importe ordenado 
	aData["MndtId"         	] := "NL17ZZZ412004150001"			// Identificación del mandato 
	aData["DtOfSgntr"		] := "2012-10-28" 					// Fecha de firma 
	aData["AmdmntInd"		] := "FALSE" 						// Indicador de modificación, TRUE=El mandato se ha modificado
	aData["OrgnlMndtId"		] := "" 							// Identificación del mandato original 
	aData["DebtorIban"		] := "NL31INGB0000000044" 			// IBAN
	aData["DebtorAgent"		] := "" 							// Identificación
	aData["ElctrncSgntr"	] := "" 							// Firma electrónica
	aData["DebtorBic"		] := "INGBNL2A"						// BIC 
	
	// aData["DebtorIban"		] := "" 			// IBAN
	aData["Purpose"			] := "" 							// Codigo Proposito
	aData["DbtCdtRptgInd"	] := ""								// Alcance de la información
	aData["DtlsCode"		] := "" 							// Código
	aData["Amt"				] := "" 							// Importe
	aData["Inf"				] := ""								// Información
	aData["Ustrd"			] := "Donation Greenpeace" 			// No estructurado
	aData["RefInf"			] := "" 							// Código
	aData["Issr"			] := "" 							// Emisor
	aData["Ref"				] := ""		 						// Referencia

	MsgStruct( hDoc, aCreditor )

	mxmlSaveFile( hXmlDoc, cFileOut, MXML_NO_CALLBACK )

 	cStr := Space( 64000 )
   	mxmlSaveString( hXmlDoc, @cStr, MXML_NO_CALLBACK ) 
	//mxmlSaveString( hXmlDoc, @cStr, @type_cb() ) 
   //OutStd( cStr + CRLF )

      mxmlSAXLoadString( NIL, cStr, @type_cb(), NIL, MXML_NO_CALLBACK )

    //hXmlDoc := mxmlLoadString( nil, cStr, @type_cb() )


   mxmlDelete( hXmlDoc )

return NIL

//--------------------------------------------------------------------------------------//

static function MsgStruct( hDoc, aCreditor )

 local ServiceLevel		:= "SEPA"	 						// Código nivel de servicio, admitido sólo SEPA
 local LocalInstrument	:= "CORE"							// Código Instrumento local, admitido sólo CORE o COR1

	ItemNew(1, "CstmrDrctDbtInitn",,,, hDoc) 				// Raíz del mensaje 
	ItemNew(2, "GrpHdr") 									// Cabecera 
	ItemNew(3, "MsgId", 35, aData["MsgId"]) 				// Identificación del mensaje
	ItemNew(3, "CreDtTm", 19, aData["CreDtTm"]) 			// Fecha y hora de creación
	ItemNew(3, "NbOfTxs", 15, NbOfTxs) 						// Número de operaciones 
	ItemNew(3, "CtrlSum", 18, CtrlSum) 						// Control de suma 

	FieldNew(3, "InitgPty")									// Parte iniciadora (6)

	ItemNew(2, "PmtInf") 									// Información del pago 
	ItemNew(3, "PmtInfId", 35, aData["PmtInfId"]) 			// Identificación de la información del pago 
	ItemNew(3, "PmtMtd", 2, aData["PmtMtd"]) 				// Método de pago
	ItemNew(3, "BtchBookg", 5, aData["BtchBookg"]) 			// Indicador de apunte en cuenta
	ItemNew(3, "NbOfTxs", 15, NbOfTxs) 						// Número de operaciones 
	ItemNew(3, "CtrlSum", 18, CtrlSum) 						// Control de suma 

	ItemNew(3, "PmtTpInf") 									// Información del tipo de pago 
	ItemNew(4, "SvcLvl") 									// Nivel de servicio 
	ItemNew(5, "Cd", 4, ServiceLevel)	 					// Código Nivel de servicio
	ItemNew(4, "LclInstrm") 								// Instrumento local  
	ItemNew(5, "Cd", 35, LocalInstrument)					// Código Instrumento local
	ItemNew(4, "SeqTp", 4, aData["SeqTp"]) 					// Tipo de secuencia
	ItemNew(4, "CtgyPurp") 									// Categoría del propósito 
	ItemNew(5, "Cd", 4, aData["PurpCode"]) 					// Código 
	ItemNew(5, "Prtry", 35, aData["PurpProprietary"]) 		// Propietario

	ItemNew(3, "ReqdColltnDt", 8, aData["ReqdColltnDt"])	// Fecha de cobro

	ItemNew(3, "Cdtr") 										// Acreedor 
	ItemNew(4, "Nm", 70, aData["CreditorName"]) 			// Nombre 
	ItemNew(4, "PstlAdr") 									// Dirección postal
	ItemNew(5, "Ctry", 2, aData["CreditorCountry"]) 		// País
	ItemNew(5, "AdrLine", 70, aData["CreditorAdress"]) 		// Dirección en texto libre

	ItemNew(3, "CdtrAcct") 									// Cuenta del acreedor
	ItemNew(4, "Id") 										// Identificación
	ItemNew(5, "IBAN", 34, aData["CreditorIban"]) 			// IBAN
//	ItemNew(4, "Ccy", 3, aData["Ccy"]) 						// Moneda 

	ItemNew(3, "CdtrAgt") 									// Entidad del acreedor
	ItemNew(4, "FinInstnId") 								// Identificación de la entidad 
	ItemNew(5, "BIC", 11, aData["CreditorBic"]) 			// BIC 

	FieldNew(3, "UltmtCdtr")	 							// Último acreedor (6)

	ItemNew(3, "ChrgBr", 4, aData["ChrgBr"]) 				// Cláusula de gastos (5)

	CreditItem(3, "CdtrSchmeId", aCreditor)					// Identificación del acreedor

	ItemNew(3, "DrctDbtTxInf") 								// Información de la operación de adeudo directo
	ItemNew(4, "PmtId") 									// Identificación del pago  
	ItemNew(5, "InstrId", 35, aData["InstrId"]) 			// Identificación de la instrucción
	ItemNew(5, "EndToEndId", 35, aData["EndToEndId"]) 		// Identificación de extremo a extremo 
	ItemNew(4, "InstdAmt", 12, aData["InstdAmt"], .t.) 		// Importe ordenado 
	/*
	ItemNew(4, "ChrgBr", 4, aData["ChrgBr"]) 				// Cláusula de gastos (5)
	*/
	ItemNew(4, "DrctDbtTx") 								// Operación de adeudo directo 
	ItemNew(5, "MndtRltdInf") 								// Información del mandato 
	ItemNew(6, "MndtId", 35, aData["MndtId"]) 				// Identificación del mandato 
	ItemNew(6, "DtOfSgntr", 8, aData["DtOfSgntr"]) 			// Fecha de firma 
	ItemNew(6, "AmdmntInd", 5, aData["AmdmntInd"]) 			// Indicador de modificación 
	ItemNew(6, "AmdmntInfDtls") 							// Detalles de la modificación 
	ItemNew(7, "OrgnlMndtId", 35, aData["OrgnlMndtId"]) 	// Identificación del mandato original 

	CreditItem(7, "OrgnlCdtrSchmeId")						// Identificación del acreedor original  
	//CreditItem(7, "OrgnlCdtrSchmeId", nombre)				// Revisar !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	ItemNew(7, "OrgnlDbtrAcct") 							// Cuenta del deudor original 
	ItemNew(8, "Id") 										// Identificación 
	ItemNew(9, "IBAN", 34, aData["DebtorIban"]) 			// IBAN
	ItemNew(7, "OrgnlDbtrAgt") 								// Entidad del deudor original
	ItemNew(8, "FinInstnId") 								// Identificación de la entidad 
	ItemNew(9, "Othr") 										// Otra 
	ItemNew(10,"Id", 35, aData["DebtorAgent"]) 				// Identificación
	ItemNew(6, "ElctrncSgntr", 1025, aData["ElctrncSgntr"]) // Firma electrónica

	CreditItem(5, "CdtrSchmeId", aCreditor) 				// Identificación del acreedor 

	FieldNew(4, "UltmtCdtr")	 							// Último acreedor (6)

	ItemNew(4, "DbtrAgt")									// Entidad del deudor 
	ItemNew(5, "FinInstnId") 								// Identificación de la entidad 
	ItemNew(6, "BIC", 11, aData["DebtorBic"])				// BIC 

	/* este grupo es algo distinto, comprobar */
	FieldNew(4, "Dbtr") 									// Deudor (6)

	ItemNew(4, "DbtrAcct") 									// Cuenta del deudor
	ItemNew(5, "Id") 										// Identificación
	ItemNew(6, "IBAN", 34, aData["DebtorIban"]) 			// IBAN

	FieldNew(4, "UltmtDbtr") 								// Último deudor (6)

	ItemNew(4, "Purp") 										// Propósito 
	ItemNew(5, "Cd", 4, aData["Purpose"]) 					// Código

	ItemNew(4, "RgltryRptg") 								// Información regulatoria
	ItemNew(5, "DbtCdtRptgInd", 4, aData["DbtCdtRptgInd"])	// Alcance de la información
	ItemNew(5, "Dtls") 										// Detalles
	ItemNew(6, "Cd", 3, aData["DtlsCode"]) 					// Código
	ItemNew(6, "Amt", 21, aData["Amt"], .t.) 				// Importe
	ItemNew(6, "Inf", 35, aData["Inf"])						// Información

	ItemNew(4, "RmtInf") 									// Concepto
	ItemNew(5, "Ustrd", 140, aData["Ustrd"])	 			// No estructurado
	ItemNew(5, "Strd") 										// Estructurado
	ItemNew(6, "CdtrRefInf")								// Referencia facilitada por el acreedor
	ItemNew(7, "Tp") 										// Tipo de referencia
	ItemNew(8, "CdOrPrtry") 								// Código o propietario
	ItemNew(9, "Cd", 4, aData["RefInf"]) 					// Código
	ItemNew(8, "Issr", 35, aData["Issr"]) 					// Emisor
	ItemNew(7, "Ref", 35, aData["Ref"])		 				// Referencia

return NIL

//--------------------------------------------------------------------------------------//

static function FieldNew( nLevel, cLabel, lType, nId )

	lType = If( lType == NIL, .f., lType )
	nId   = If( nId == NIL, ENTIDAD_OTRA, nId )

	ItemNew(nLevel, cLabel)		 					// Parte iniciadora 
	ItemNew(nLevel +1, "Nm", 70) 					// Nombre 
	ItemNew(nLevel +1, "Id") 						// Identificación 

	if lType 
		ItemNew(nLevel +2, "OrgId") 				// Persona jurídica
	else 	
		ItemNew(nLevel +2, "PrvtId") 				// Persona física 
	endif

	SWITCH nId

		CASE ENTIDAD_JURIDICA
			ItemNew(nLevel +3, "BICOrBEI", 11) 		// BIC o BEI 

		CASE ENTIDAD_FISICA
			ItemNew(nLevel +3, "DtAndPlcOfBirth") 	// Fecha y lugar de nacimiento 
			ItemNew(nLevel +4, "BirthDt", 8) 		// Fecha de nacimiento 
			ItemNew(nLevel +4, "PrvcOfBirth", 35) 	// Provincia de nacimiento
			ItemNew(nLevel +4, "CityOfBirth", 35) 	// Ciudad de nacimiento 
			ItemNew(nLevel +4, "CtryOfBirth", 2) 	// País de nacimiento

		OTHERWISE
			ItemNew(nLevel +3, "Othr") 				// Otra 
			ItemNew(nLevel +4, "Id", 35) 			// Identificación 
			ItemNew(nLevel +4, "SchmeNm") 			// Nombre del esquema 
			ItemNew(nLevel +5, "Cd", 4) 			// Código 
			ItemNew(nLevel +5, "Prtry", 35) 		// Propietario
			ItemNew(nLevel +4, "Issr", 35) 			// Emisor 
	END

return NIL

//--------------------------------------------------------------------------------------//

static function ItemNew(nLevel, cLabel, nLen, xValue, lCurrency, hParent)

 local hItem

	if len(aItems) < nLevel
		aadd( aItems, {} )
	endif

	if hParent == NIL
	   hParent := atail( aItems[nLevel -1] )
	endif

	hItem := mxmlNewElement( hParent, cLabel )

	if lCurrency != NIL
	   mxmlElementSetAttr( hItem, "Ccy", "EUR" )
	endif

	if nLen != NIL
	   mxmlNewText( hItem, 0, xValue )
	   //mxmlNewText( hItem, 0, padR(xValue, nLen) )
	endif

	aadd( aItems[nLevel], hItem )

return NIL

//--------------------------------------------------------------------//

static function CreditItem(nLevel, cLabel, aInfo, cName)

	if aInfo != NIL
		if cName != NIL
		   ItemNew(nLevel +1, "Nm", 70) 				// Nombre  
		endif

		ItemNew(nLevel +1, "Id") 						// Identificación  
		ItemNew(nLevel +2, "PrvtId") 					// Identificación privada  
		ItemNew(nLevel +3, "Othr") 						// Otra 
		ItemNew(nLevel +4, "Id", 35, aInfo["Id"])		// Identificación 
		ItemNew(nLevel +4, "SchmeNm") 					// Nombre del esquema 
		ItemNew(nLevel +5, "Prtry", 35, aInfo["Prtry"])	// Propietario 
	endif

return NIL

//--------------------------------------------------------------------//

FUNCTION type_cb( hNode )            

  local cText :=  mxmlGetText( hNode )
  	 
//  if ! Empty( mxmlGetFirstChild( hNode ) )	 
//  	 OutStd( mxmlGetElement( hNode ), mxmlGetFirstChild( hNode ) )
//  endif

  if !empty( cText )
  	 OutStd( "element :", mxmlGetElement( hNode ), cText + hb_eol() )
  endif

return NIL