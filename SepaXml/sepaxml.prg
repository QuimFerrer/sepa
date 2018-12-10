/* v.1.0 31/12/2013
 * v.2.0 17/02/2016
 * SEPA ISO 20022 http://http://www.iso20022.org/
 * pain.008.001.02 Direct Debit Core y B2B 
 * pain.001.001.03 Credit Transfer 
 *
 * Para lenguaje Harbour - http://harbour-project.org
 * (c) Joaquim Ferrer Godoy <quim_ferrer@yahoo.es>
 *
 * Características :
 * Generacion de formato XML
 * Control de errores en campos requeridos
 * Verifica importes y numero total de efectos
 * 
 * Reglas de uso locales AEB:
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
 * (6) Regla de uso: Para el sistema de adeudos SEPA se utilizará exclusivamente la etiqueta 'Otra' estructurada 
 *	   según lo definido en el epígrafe 'Identificador del presentador' de la sección 3.3 del cuaderno.
 * (7) Regla de uso: Solamente se admite el código 'SEPA'
 * (8) Código comercial del acreedor (Sufijo): Número de tres cifras comprendido entre 000 y 999. 
 *	   Contiene información necesaria en la relación entre la entidad del acreedor y el acreedor y permite al 
 *     acreedor identificar diferentes líneas comerciales o servicios. 
 */

#include "hbclass.ch"
#include "hbmxml.ch"

#define SEPA_DIRECT_DEBIT 		0
#define SEPA_CREDIT_TRANSFER 	1

#define SEPA_SCHEME_CORE 		0
#define SEPA_SCHEME_COR1 		1
#define SEPA_SCHEME_B2B 		2

#define ENTIDAD_JURIDICA		0
#define ENTIDAD_FISICA			1
#define ENTIDAD_OTRA			2

//--------------------------------------------------------------------------------------//
// --> ejemplo de uso :
function main()

	local n	
	local oDoc  := SepaXml():New( SEPA_DIRECT_DEBIT, SEPA_SCHEME_COR1, "testSepa.xml" )

   // Documento----------------------------------------------------------------
	WITH OBJECT oDoc
	  :NbOfTxs 	:= 2 								// Número de operaciones 
	  :CtrlSum 	:= 370.35 							// Control de suma total importes
	  :Financiar:= .T.								// Remesa con financiacion (descuento)	
	  :Sufijo	:= "000"							// Regla 8	
	/* Idea ! NbOfTxs y CtrlSum deberan ser informadas, contrastar con variables calculadas en Activate() */
	ENDWITH

   // Presentador--------------------------------------------------------------
   // Los carácter tilde, apóstrofe, ñ, ç, etc debe realizarse con str2iso2022()
	WITH OBJECT oDoc:oInitPart
	  :nEntity	:= ENTIDAD_JURIDICA
	  :Nm 		:= str2iso2022("NOMBRE DEL PRESENTADOR, S.L.")
	  :AdrLine1 := str2iso2022("Dirección del presentador")
	  :AdrLine2 := str2iso2022("Población del presentador")
	  :Ctry 	:= "ES"
	  :NIF      := "B12345678"
	ENDWITH

   // Acreedor-----------------------------------------------------------------
	WITH OBJECT oDoc:oCreditor
	  :nEntity	:= ENTIDAD_JURIDICA
	  :Nm 		:= str2iso2022("NOMBRE DEL ACREEDOR, S.L.")
	  :AdrLine1 := str2iso2022("Dirección del acreedor")
	  :AdrLine2 := str2iso2022("Población del acreedor")
	  :Ctry 	:= "ES"
	  :NIF      := "B87654321"
	  :IBAN		:= "ES0321001234561234567890"
	ENDWITH
	/* Si el Acreedor es tambien el presentador, especificar asi :
	 * oDoc:oCreditor := __objClone( oDoc:oInitPart )
 	 */

   // Deudor/es----------------------------------------------------------------
	for n := 1 to oDoc:NbOfTxs
		oDebtor := SepaDebitActor():New()

		WITH OBJECT oDebtor
		  :nEntity		:= ENTIDAD_OTRA
		  :Nm 			:= str2iso2022("NOMBRE DEL DEUDOR")+ strzero(n, 4) 
		  :AdrLine1 	:= str2iso2022("Dirección del deudor")+ strzero(n, 4) 
		  :AdrLine2 	:= str2iso2022("Población del deudor")+ strzero(n, 4) 
		  :Ctry 		:= "ES"
		  :NIF 			:= "12345678Z"
		  :InstdAmt		:= 123.45 * n						 // Importe
		  :ReqdColltnDt := ctod("02-21-2014") + (n*10)		 // Fecha de cobro (Vencimiento)
		  :IBAN 		:= "ES0321001234561234567890"
		  :MndtId 		:= hb_md5(oDoc:oCreditor:NIF + :NIF) // Identificación del mandato, sugerencia: NIF Acreedor + NIF Deudor 
		  :DtOfSgntr 	:= ctod("10-31-2009") 				 // Si no se especifica, mandato preexistente 
		  :Info 		:= "FACTURA "+ strzero(n, 3)         // Concepto del cobro
		ENDWITH

		oDoc:DebtorAdd( oDebtor )
	next

	oDoc:Activate()

	if oDoc:lError
		aeval( oDoc:aErrors, {|err| outstd( err + hb_eol() ) } )
	endif

	oDoc:End()

return NIL
// <-- ejemplo de uso :
//--------------------------------------------------------------------------------------//

CLASS SepaXml

  	DATA hXmlDoc
	DATA FinancialMsg 			
	DATA SchmeNm 				
	DATA DocType 				
	DATA cFileOut 				
  	DATA lMinified				AS LOGICAL 	INIT .T. 				// Documento compactado o con espacios y tabuladores
  	DATA lError					AS LOGICAL 	INIT .F. 				// Control de errores
  	DATA aErrors 				AS ARRAY 	INIT {} 				// Control de errores
  	DATA ErrorMessages 			AS ARRAY 	INIT {=>} 				// Hash mensajes de error multilenguaje
  	DATA aDebtors 				AS ARRAY 	INIT {} 				// Lista de deudores

	DATA MsgId 														// Identificación del mensaje
	DATA CreDtTm 													// Fecha y hora de creación
	DATA NbOfTxs 													// Número de operaciones 
	DATA Currency 				AS CHARACTER INIT "EUR" 			// Moneda, Divisa
	DATA CtrlSum 													// Control de suma
	DATA Financiar				AS LOGICAL 	INIT .F. 				// Financiacion: T=(Descuento), F=(Al cobro)
	DATA Sufijo					AS CHARACTER INIT "000"				// Facilitado por entidad bancaria, regla 8

	DATA ServiceLevel	 		AS CHARACTER INIT "SEPA"			// Código Nivel de servicio (7)
	DATA SeqTp 					AS CHARACTER INIT "RCUR" 			// Tipo de secuencia (2)
	DATA PurposeCd 													// Código categoria proposito
	DATA PurposePrtry 												// Propietario categoria proposito

	DATA oInitPart
	DATA oCreditor
	DATA oUltimateCreditor
	DATA oDebtor
	DATA oUltimateDebtor

  	METHOD New()

  	METHOD DebtorAdd(oDebtor)		INLINE aadd(::aDebtors, oDebtor)

	METHOD GroupHeader()
	METHOD InfoPayment()
	METHOD DirectDebit()

	METHOD SetActor()
	METHOD TypePayment()
	METHOD IdPayment()
	METHOD Creditor()
	METHOD IdCreditor()

	METHOD SetLanguage()
  	METHOD Activate()
  	METHOD End()					

ENDCLASS

//--------------------------------------------------------------------------------------//

METHOD New( nFinanMsg, nScheme, cFileOut ) CLASS SepaXml

 	::cFileOut 	:= cFileOut
	::CreDtTm 	:= IsoDateTime()  // Fecha y hora de creación

 	switch nFinanMsg
 		case SEPA_DIRECT_DEBIT 
			::FinancialMsg 	:= "CstmrDrctDbtInitn" 
			::DocType 		:= "pain.008.001.02" 
			EXIT
 		case SEPA_CREDIT_TRANSFER 
 			::FinancialMsg 	:= "CstmrCdtTrfInitn"  
			::DocType 		:= "pain.001.001.03" 
 	end 

 	switch nScheme
 		case SEPA_SCHEME_CORE ; ::SchmeNm := "CORE" ; EXIT
 		case SEPA_SCHEME_COR1 ; ::SchmeNm := "COR1" ; EXIT
 		case SEPA_SCHEME_B2B  ; ::SchmeNm := "B2B" 	; EXIT
 		otherwise ; 			::SchmeNm := "SEPA"
 	end

	::oInitPart			:= SepaDebitActor():New()		
	::oCreditor 		:= SepaDebitActor():New()
	::oUltimateCreditor	:= SepaDebitActor():New()
	::oDebtor 			:= SepaDebitActor():New()
	::oUltimateDebtor 	:= SepaDebitActor():New()

return Self

//--------------------------------------------------------------------------------------//

METHOD GroupHeader( hParent ) CLASS SepaXml

 local hItem

	/* Generar identificador del mensaje 
	 * Regla de uso para financiación de remesas:
	 * El acreedor compondrá la referencia <MsgId> incluyendo en las cuatros primeras 
	 * posiciones de la identificación del mensaje el prefijo FSDD
	 */
	::MsgId := "PRE" + fDate() + cTime() + strzero( seconds(), 5 ) + ::oInitPart:NIF
	if ::Financiar
		::MsgId := "FSDD"+ ::MsgId
	endif

	if ::CreDtTm != NIL .or. ::NbOfTxs != NIL .or. ::CtrlSum != NIL

		hItem := ItemNew(hParent, "GrpHdr") 				// Cabecera

		ItemNew(hItem, "MsgId",   35, ::MsgId) 				// Identificación del mensaje
		ItemNew(hItem, "CreDtTm", 19, ::CreDtTm) 			// Fecha y hora de creación
		ItemNew(hItem, "NbOfTxs", 15, str(::NbOfTxs, 0))	// Número de operaciones 
		ItemNew(hItem, "CtrlSum", 18, ::CtrlSum) 			// Control de suma
		
		if ::oInitPart:Nm != NIL 							// Opcional o Requerido ?
			::SetActor(hItem, "InitgPty", ::oInitPart ) 	// Parte iniciadora (6)
		else
			// Error
		endif
	endif 

return NIL

//--------------------------------------------------------------------------------------//

METHOD InfoPayment( hParent ) CLASS SepaXml
	/*
	Regla de uso: Las etiquetas ‘Último acreedor’, ‘Cláusula de gastos’ e ‘Identificación del acreedor’ pueden aparecer, 
	bien en el nodo ‘Información del pago’ (2.0), bien en el nodo ‘Información de la operación de adeudo directo’ (2.28), 
	pero solamente en uno de ellos. 
	Se recomienda que se recojan en el bloque ‘Información del pago’ (2.0).
	*/
 local hItem

	if ::oDebtor:PmtInfId != NIL .or. ::oDebtor:PmtMtd != NIL .or. ;
	   ::oDebtor:BtchBookg != NIL .or. ::oDebtor:NbOfTxs != NIL .or. ;
	   ::oDebtor:CtrlSum != NIL .or. ::oDebtor:ReqdColltnDt != NIL .or. ::oDebtor:ChrgBr != NIL

		hItem := ItemNew(hParent, "PmtInf") 					// Información del pago 

		::IdPayment(hItem) 										// Identificación de la información del pago 

		::TypePayment(hItem)									// Información del tipo de pago 

		ItemNew(hItem, "ReqdColltnDt", 8, ; 					// Fecha de cobro (Vencimiento)
				::oDebtor:ReqdColltnDt)						

		::Creditor(hItem)										// Datos Acreedor, Cuenta, Entidad

		if ::oUltimateCreditor:Nm != NIL 						// Opcional, Último acreedor (6)
		   ::SetActor(hItem, "UltmtCdtr", ::oUltimateCreditor)	
		endif		 									 		// No produce error, es opcional

		ItemNew(hItem, "ChrgBr", 4, ::oDebtor:ChrgBr) 			// Cláusula de gastos (5)

		::IdCreditor(hItem) 									// Identificación del acreedor
	endif

return hItem

//--------------------------------------------------------------------------------------//

METHOD DirectDebit( hParent ) CLASS SepaXml

 local hItem, hChild

	if ::oDebtor:InstdAmt > 0
		hItem := ItemNew(hParent, "DrctDbtTxInf") 							// Información de la operación de adeudo directo

		if ::oDebtor:InstrId != NIL .or. ::oDebtor:EndToEndId != NIL	
			hChild := ItemNew(hItem, "PmtId") 								// Identificación del pago  
			ItemNew(hChild, "InstrId", 35, ::oDebtor:InstrId) 				// Identificación de la instrucción
			ItemNew(hChild, "EndToEndId", 35, ::oDebtor:EndToEndId) 		// Identificación de extremo a extremo 
		endif

		ItemNew(hItem, "InstdAmt", 12, ::oDebtor:InstdAmt, ::Currency) 		// Importe ordenado 

		if ::oDebtor:MndtId != NIL .or. ::oDebtor:DtOfSgntr != NIL 
			hChild := ItemNew(hItem, "DrctDbtTx") 							// Operación de adeudo directo 
			hChild := ItemNew(hChild, "MndtRltdInf") 						// Información del mandato 
			ItemNew(hChild, "MndtId", 35, ::oDebtor:MndtId) 				// Identificación del mandato 
			ItemNew(hChild, "DtOfSgntr", 8, ::oDebtor:DtOfSgntr) 			// Fecha de firma 
			
			if ::oDebtor:AmdmntInd != NIL
				ItemNew(hChild, "AmdmntInd", 5, ::oDebtor:AmdmntInd) 		// Indicador de modificación 
				
				if ::oDebtor:OrgnlMndtId != NIL
					hChild := ItemNew(hChild, "AmdmntInfDtls") 					// Detalles de la modificación 
					ItemNew(hChild, "OrgnlMndtId", 35, ::oDebtor:OrgnlMndtId) 	// Identificación del mandato original 
				endif
			endif
		endif

 		hChild := ItemNew(hItem, "DbtrAgt") 			// Entidad del deudor 
		hChild := ItemNew(hChild, "FinInstnId") 		// Identificación de la entidad 
 
 		if ::oDebtor:BICOrBEI != NIL
			ItemNew(hChild, "BIC", 11, ::oDebtor:BICOrBEI)	// BIC 
		else
			hChild := ItemNew(hChild, "Othr")				// Otro 
			ItemNew(hChild, "Id", 11, "NOTPROVIDED")
		endif

		if ::oDebtor:Nm != NIL 								// Requerido
			hChild := ItemNew(hItem, "Dbtr")
			ItemNew(hChild, "Nm", 70, ::oDebtor:Nm)									// Nombre 

			if ::oDebtor:Ctry != NIL .and. ::oDebtor:AdrLine1 != NIL
				hChild := ItemNew(hChild, "PstlAdr") 					 // Dirección postal
				ItemNew(hChild, "Ctry", 2, ::oDebtor:Ctry) 			 // País
				ItemNew(hChild, "AdrLine", 70, ::oDebtor:AdrLine1) 	 // Dirección en texto libre
				
				if ::oDebtor:AdrLine2 != NIL
					ItemNew(hChild, "AdrLine", 70, ::oDebtor:AdrLine2) // Población en texto libre
				endif
			endif
		else
			aadd( ::aErrors, ::ErrorMessages['SEPA_DEBTOR_NAME'] )
		endif

		if ::oDebtor:IBAN != NIL 
			hChild := ItemNew(hItem, "DbtrAcct") 			// Cuenta del deudor
			hChild := ItemNew(hChild, "Id") 				// Identificación
			ItemNew(hChild, "IBAN", 34, ::oDebtor:IBAN) 	// IBAN
		else
			aadd( ::aErrors, ::ErrorMessages['SEPA_DEBTOR_ACCOUNT'] )
		endif

		if ::oUltimateDebtor:Nm != NIL 						// Opcional o Requerido ?
			::SetActor(hItem, "UltmtDbtr", ::oUltimateDebtor) 		// Último deudor (6)
		endif

		if ::PurposeCd != NIL
			hChild := ItemNew(hItem, "Purp") 						// Propósito 
			ItemNew(hChild, "Cd", 4, ::PurposeCd) 					// Código
		endif

		if ::oDebtor:Info != NIL
			hChild := ItemNew(hItem, "RmtInf") 						// Concepto
			ItemNew(hChild, "Ustrd", 140, ::oDebtor:Info)	 		// No estructurado
		endif
	else
		// Error
	endif

return NIL

//--------------------------------------------------------------------------------------//

METHOD SetActor( hParent, cLabel, oActor ) CLASS SepaXml

	local hItem := ItemNew(hParent, cLabel)		 						// Actor

	ItemNew(hItem, "Nm", 70, oActor:Nm)									// Nombre 
	hItem := ItemNew(hItem, "Id") 										// Identificación 

	if oActor:nEntity == ENTIDAD_JURIDICA
		hItem := ItemNew(hItem, "OrgId") 								// Persona jurídica
	elseif oActor:nEntity == ENTIDAD_FISICA	
		hItem := ItemNew(hItem, "PrvtId") 								// Persona física 
	else
		// Error, no se ha especificado un tipo de identificador valido
		// Solo existen 2 opciones : Fisica o Juridica
	endif

	/* Generar identificador para el actor */
	oActor:id := Id_Name( oActor:Ctry, ::Sufijo, oActor:NIF )   	// Pais+Sufijo+NIF

	switch oActor:nEntity
		case ENTIDAD_JURIDICA
			if oActor:BICOrBEI != NIL
				ItemNew(hItem, "BICOrBEI", 11, oActor:BICOrBEI) 		// BIC o BEI 
			else
				if oActor:Id != NIL
					hItem  := ItemNew(hItem, "Othr")
 					ItemNew( hItem, "Id", 35, rtrim(oActor:Id) ) 
					hChild := ItemNew(hItem, "SchmeNm") 				// Nombre del esquema 
					ItemNew(hChild, "Prtry", 35, oActor:Prtry) 		// Propietario
				else
					// Error
				endif
			endif
			EXIT 

		case ENTIDAD_FISICA
			if oActor:BirthDt != NIL .or. oActor:PrvcOfBirth != NIL .or. ;
			   oActor:CityOfBirth != NIL .or. oActor:CtryOfBirth != NIL

				hItem := ItemNew(hItem, "DtAndPlcOfBirth") 				// Fecha y lugar de nacimiento 
				ItemNew(hItem, "BirthDt", 8, oActor:BirthDt) 			// Fecha de nacimiento 
				ItemNew(hItem, "PrvcOfBirth", 35, oActor:PrvcOfBirth) 	// Provincia de nacimiento
				ItemNew(hItem, "CityOfBirth", 35, oActor:CityOfBirth) 	// Ciudad de nacimiento 
				ItemNew(hItem, "CtryOfBirth", 2, oActor:CtryOfBirth) 	// País de nacimiento
			else
				// Error
			endif
			EXIT 

		otherwise
			if oActor:Id != NIL .or. oActor:Cd != NIL .or. oActor:Prtry != NIL .or. oActor:Issr != NIL
				hItem := ItemNew(hItem, "Othr") 						// Otra 
				ItemNew(hItem, "Id", 35, oActor:Id) 					// Identificación 

				if oActor:Cd != NIL .or. oActor:Prtry != NIL
					hChild := ItemNew(hItem, "SchmeNm") 				// Nombre del esquema 
					ItemNew(hChild +5, "Cd", 4, oActor:Cd) 				// Código 
					ItemNew(hChild +5, "Prtry", 35, oActor:Prtry) 		// Propietario
				endif
				ItemNew(hItem, "Issr", 35, oActor:Issr) 				// Emisor
			else
				// Error
			endif
	end

return NIL

//--------------------------------------------------------------------------------------//

METHOD IdPayment( hItem ) CLASS SepaXml

	ItemNew(hItem, "PmtInfId", 35, ::oDebtor:PmtInfId)		// Identificación de la información del pago 
	ItemNew(hItem, "PmtMtd", 2, ::oDebtor:PmtMtd) 			// Método de pago
	ItemNew(hItem, "BtchBookg", 5, ::oDebtor:BtchBookg) 		// Indicador de apunte en cuenta
	ItemNew(hItem, "NbOfTxs", 15, str(::oDebtor:NbOfTxs, 0)) 	// Número de operaciones 
	ItemNew(hItem, "CtrlSum", 18, ::oDebtor:CtrlSum) 			// Control de suma 

return NIL

//--------------------------------------------------------------------------------------//

METHOD TypePayment( hParent ) CLASS SepaXml

 local hItem, hChild

 	hItem := ItemNew(hParent, "PmtTpInf") 						// Información del tipo de pago 

	hChild := ItemNew(hItem, "SvcLvl") 							// Nivel de servicio 
	ItemNew(hChild, "Cd", 4, ::ServiceLevel)	 				// Código Nivel de servicio

	hChild := ItemNew(hItem, "LclInstrm") 						// Instrumento local  
	ItemNew(hChild, "Cd", 35, ::SchmeNm)						// Código Instrumento local

	ItemNew(hItem, "SeqTp", 4, ::SeqTp) 						// Tipo de secuencia

	/* Lista de códigos recogidos en la norma ISO 20022 
	   Ex: CASH=CashManagementTransfer (Transaction is a general cash management instruction) */
	if ::PurposeCd != NIL
		hChild := ItemNew(hItem, "CtgyPurp") 					// Categoría del propósito 
		ItemNew(hChild, "Cd", 4, ::PurposeCd) 					// Código 
		ItemNew(hChild, "Prtry", 35, ::PurposePrtry) 			// Propietario
	endif

return NIL

//--------------------------------------------------------------------------------------//

METHOD Creditor( hParent ) CLASS SepaXml

 local hItem

	if ::oCreditor:Nm != NIL
		hItem := ItemNew(hParent, "Cdtr") 							// Acreedor 
		ItemNew(hItem, "Nm", 70, ::oCreditor:Nm) 					// Nombre 

		if ::oCreditor:Ctry != NIL .and. ::oCreditor:AdrLine1 != NIL
			hItem := ItemNew(hItem, "PstlAdr") 						// Dirección postal
			ItemNew(hItem, "Ctry", 2, ::oCreditor:Ctry) 			// País
			ItemNew(hItem, "AdrLine", 70, ::oCreditor:AdrLine1) 	// Dirección en texto libre
			
			if ::oCreditor:AdrLine2 != NIL
				ItemNew(hItem, "AdrLine", 70, ::oCreditor:AdrLine2) // Población en texto libre
			endif
		else
			// Error
			//aadd( ::aErrors, ::aMessages['creditor_does_not_exist'] )
		endif
	else
		// Error
	endif

	if ::oCreditor:IBAN != NIL
		hItem := ItemNew(hParent, "CdtrAcct") 						// Cuenta del acreedor
		/* Da error de validacion en: 
		 * http://www.sepa-info.es/main/tags/validador-gratuito-sepa-xml-sdd
		 * Esta etiqueta sólo debe usarse cuando un mismo número de cuenta
		 * cubra  diferentes divisas y el presentador necesite identificar
		 * en cuál de estas divisas debe realizarse el asiento sobre su cuenta
			ItemNew(hItem, "Ccy", 3, ::Currency) 					// Moneda 
		 */
		hItem := ItemNew(hItem, "Id") 								// Identificación
		ItemNew(hItem, "IBAN", 34, ::oCreditor:IBAN) 				// IBAN
	else
		// Error
	endif

	hItem := ItemNew(hParent, "CdtrAgt") 							// Entidad del acreedor
	hItem := ItemNew(hItem, "FinInstnId") 							// Identificación de la entidad 
	
	if ::oCreditor:BIC != NIL
		ItemNew(hItem, "BIC", 11, ::oCreditor:BIC) 					// BIC
	else
		ItemNew(hItem, "BIC", 11, "NOTPROVIDED") 					
	endif 

return NIL

//--------------------------------------------------------------------------------------//

METHOD IdCreditor( hParent ) CLASS SepaXml

	if ::oCreditor:Ctry != NIL .or. ::oCreditor:NIF != NIL

		/* Generar identificador para el creditor, Pais+Sufijo+NIF */
		::oCreditor:Id := Id_Name( ::oCreditor:Ctry, ::Sufijo, ::oCreditor:NIF )   	

		hItem := ItemNew(hParent, "CdtrSchmeId") 					// Identificación del acreedor 
		hItem := ItemNew(hItem, "Id") 								// Identificación  
		hItem := ItemNew(hItem, "PrvtId") 							// Identificación privada  
		hItem := ItemNew(hItem, "Othr") 							// Otra 

		ItemNew( hItem, "Id", 35, alltrim(::oCreditor:Id) )			// Identificación 

		if ::oCreditor:Prtry != NIL
			hItem := ItemNew(hItem, "SchmeNm") 						// Nombre del esquema 
			ItemNew(hItem, "Prtry", 35, ::oCreditor:Prtry)			// Propietario 
		endif
	else
		// Error
	endif

return NIL

//--------------------------------------------------------------------------------------//

METHOD SetLanguage() CLASS SepaXml

	::ErrorMessages['SEPA_DEBTOR_AGENT'] 	:= "La entidad del cliente no existe"
	::ErrorMessages['SEPA_DEBTOR_NAME']	 	:= "El nombre del deudor no existe"
	::ErrorMessages['SEPA_DEBTOR_ACCOUNT'] 	:= "La cuenta del deudor no existe"

return NIL

//--------------------------------------------------------------------------------------//

METHOD Activate() CLASS SepaXml

 local hItem, oDebtor, cMsg
 local nNumOp := 1

	::SetLanguage()

	mxmlSetWrapMargin(0)  // No formatea XML (TheFull thanks!)

	::hXmlDoc  	:= mxmlNewXML("1.0")
  	hItem 	 	:= mxmlNewElement(::hXmlDoc, "Document")

	// Comprobar numero de operaciones y suma total de importes
	for each oDebtor in ::aDebtors
		::oDebtor:NbOfTxs += 1
		::oDebtor:CtrlSum += oDebtor:InstdAmt
	next

	if ::NbOfTxs != ::oDebtor:NbOfTxs 
		outstd( 'Existen errores, no es posible continuar' )
		return(NIL)
	endif 

	if ::CtrlSum != ::oDebtor:CtrlSum
		outstd( 'Existen errores, no es posible continuar' )
		return(NIL)
	endif

	//mxmlElementSetAttr( hItem, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance' )
	mxmlElementSetAttr( hItem, "xmlns","urn:iso:std:iso:20022:tech:xsd:"+ ::DocType )

	hItem := ItemNew(hItem, ::FinancialMsg)						// Raíz del mensaje 

	::GroupHeader(hItem) 										// Cabecera

	/* La informacion del pago puede incluir varios adeudos por fecha de cobro
	 * Aqui se asume fecha de cobro distinta para cada adeudo, no realizando agrupacion.
	 */

	for each oDebtor in ::aDebtors
		/*
		::oDebtor:= __objClone(oDebtor)
		*/
		::oDebtor:= oDebtor
		::oDebtor:CtrlSum := oDebtor:InstdAmt
		::oDebtor:NbOfTxs := 1

		/* Generar identificador para el deudor, Pais+Sufijo+NIF */
		::oDebtor:Id := Id_Name( ::oDebtor:Ctry, ::Sufijo, ::oDebtor:NIF )   	

		/* Generar identificador de pago, a partir del id */
		::oDebtor:PmtInfId := alltrim(::oDebtor:Id) +"-"
		::oDebtor:PmtInfId += fDate() + cTime()
		::oDebtor:PmtInfId += strzero(nNumOp, 4)

		/* Identificación de la instrucción, 35 de longitud (8+6+1+20) */
		cMsg := fDate() + cTime() +"-"+ strzero(nNumOp, 20) 
		::oDebtor:InstrId 	 := cMsg 

		/* Identificación de extremo a extremo, 35 de longitud (8+1+6+20) 
		   Distinto a InstrId (alterando orden)	
		 */
		cMsg := fDate() +"-"+ cTime() + strzero(nNumOp, 20) 
		::oDebtor:EndToEndId := cMsg

		hChild := ::InfoPayment(hItem) 						// Informacion del pago
		::DirectDebit(hChild)								// Adeudo individual
		nNumOp++									
	next

	if !(::lError := len( ::aErrors ) > 0)
		if ::lMinified
			mxmlSaveFile( ::hXmlDoc, ::cFileOut, MXML_NO_CALLBACK )
		else
			mxmlSaveFile( ::hXmlDoc, ::cFileOut, @WhiteSpace() )
		endif
	endif

return NIL

//--------------------------------------------------------------------------------------//

METHOD End() CLASS SepaXml

	mxmlDelete( ::hXmlDoc )
	Self := NIL

return NIL

//--------------------------------------------------------------------------------------//

CLASS SepaDebitActor

	DATA nEntity

	DATA Nm 												// Nombre
	DATA AdrLine1 											// Dirección en texto libre
	DATA AdrLine2 											// Se permiten 2 etiquetas para direccion
	DATA Ctry 												// Pais
	DATA NIF												// NIF
	DATA IBAN												// IBAN
	DATA BIC												// BIC
	DATA BICOrBEI 											// BIC o BEI 
	DATA BirthDt											// Fecha de nacimiento 
	DATA PrvcOfBirth 										// Provincia de nacimiento
	DATA CityOfBirth										// Ciudad de nacimiento 
	DATA CtryOfBirth 										// País de nacimiento
	DATA Id													// Identificación 
	DATA Issr												// Emisor 
	DATA Cd 												// Codigo
	DATA Prtry 												// Propietario

	DATA PmtInfId 									 		// Identificación de la información del pago 
	DATA BtchBookg 		AS CHARACTER INIT "true"			// Indicador de apunte en cuenta (1)
	DATA ReqdColltnDt 										// Fecha de cobro (Vencimiento)
	DATA Info 												// Informacion no estructurada, p.e., concepto del cobro
	DATA NbOfTxs		AS NUMERIC INIT 0					// Número de operaciones 
	DATA CtrlSum 		AS NUMERIC INIT 0.00 				// Control de suma 
	DATA PmtMtd 		AS CHARACTER INIT "DD" 	 READONLY 	// Método de pago Regla de uso: Solamente se admite el código ‘DD’
	DATA ChrgBr 		AS CHARACTER INIT "SLEV" READONLY 	// Cláusula de gastos (4)
	DATA InstrId 											// Identificación de la instrucción
	DATA EndToEndId 										// Identificación de extremo a extremo 
	DATA InstdAmt 		AS NUMERIC INIT 0.00 				// Importe ordenado 
	DATA MndtId												// Identificación del mandato 
	DATA DtOfSgntr											// Fecha de firma 
	DATA AmdmntInd 	  	AS CHARACTER INIT "false"	 		// Indicador de modificación 
	DATA OrgnlMndtId									 	// Identificación del mandato original 

	METHOD New() 	
ENDCLASS

//--------------------------------------------------------------------------------------//

METHOD New() CLASS SepaDebitActor
	/* Defaults */
	::DtOfSgntr := ctod("10-31-2009")  // Mandato preexistente o sobreescribir
	::Prtry     := "SEPA" 			   // Regla de uso: Debe consignarse el literal 'SEPA'
return Self

//--------------------------------------------------------------------------------------//

static function ItemNew(hParent, cLabel, nLen, xValue, cCurrency)

 local hItem, cType 

	if nLen != NIL 
		if xValue != NIL

			hItem := mxmlNewElement( hParent, cLabel )
			cType := valtype(xValue)

			if cType == "N"
				xValue := ltrim( str(xValue, nLen, 2) )
			elseif cType == "D"
				xValue := sDate(xValue)
			endif

			mxmlNewText( hItem, 0, ltrim(xValue) )
		endif
	else
		hItem := mxmlNewElement( hParent, cLabel )
	endif

	if hItem != NIL .and. cCurrency != NIL
	   mxmlElementSetAttr( hItem, "Ccy", cCurrency )
	endif

return hItem

//--------------------------------------------------------------------------------------//

static function WhiteSpace( hNode, nWhere )
return If(nWhere == MXML_WS_BEFORE_OPEN, hb_eol(), NIL)

//--------------------------------------------------------------------------------------//
