/* v.1.0 31/12/2013
 * v.2.0 17/02/2016
 * SEPA ISO 20022 http://http://www.iso20022.org/
 * pain.008.001.02 Direct Debit Core y B2B 
 * pain.001.001.03 Credit Transfer 
 *
 * Para lenguaje Harbour - http://harbour-project.org
 * (c) Joaquim Ferrer Godoy <quim_ferrer@yahoo.es>
 *
 * Caracter�sticas :
 * Generacion de formato XML
 * Control de errores en campos requeridos
 * Verifica importes y numero total de efectos
 * 
 * Reglas de uso locales AEB:
 * (1) TRUE = Un apunte en cuenta por la suma de los importes de todas las operaciones del mensaje.
 *	   FALSE= Un apunte en cuenta por cada una de las operaciones incluidas en el mensaje.
 * (2) FNAL=�ltimo adeudo de una serie de adeudos recurrentes.
 *     FRST=Primer adeudo de una serie de adeudos recurrentes.
 *	   OOFF=Adeudo correspondiente a una operaci�n con un �nico pago(*).
 *	   RCUR=Adeudo de una serie de adeudos recurrentes, cuando no se trata ni del primero ni del �ltimo.
 *		(*) Para este tipo de operaciones el mandato y su referencia deben ser �nicos y no pueden utilizarse para operaciones 
 *		puntuales posteriores. Si siempre se factura a los mismos clientes, aunque varie el importe de los adeudos y la periodicidad
 *		de los mismos, es necesario utilizar el tipo de adeudo recurrente si se utiliza la misma referencia, creando para cada 
 *		cliente deudor un solo mandato que ampare todos los adeudos que se emitan. 
 *		El primer adeudo deber� ser FRST y los siguientes RCUR.
 * (3) Esta etiqueta s�lo debe usarse cuando un mismo n�mero de cuenta cubra diferentes divisas y el presentador 
 * 	   necesite identificar en cu�l de estas divisas debe realizarse el asiento sobre su cuenta.
 * (4) Regla de uso: Solamente se admite el c�digo �SLEV�
 * (5) La etiqueta �Cl�usula de gastos� puede aparecer, bien en el nodo �Informaci�n del pago� (2.0), bien en el 
 * 	   nodo �Informaci�n de la operaci�n de adeudo directo� (2.28), pero solamente en uno de ellos. 
 * 	   Se recomienda que se recoja en el bloque �Informaci�n del pago� (2.0).
 * (6) Regla de uso: Para el sistema de adeudos SEPA se utilizar� exclusivamente la etiqueta 'Otra' estructurada 
 *	   seg�n lo definido en el ep�grafe 'Identificador del presentador' de la secci�n 3.3 del cuaderno.
 * (7) Regla de uso: Solamente se admite el c�digo 'SEPA'
 * (8) C�digo comercial del acreedor (Sufijo): N�mero de tres cifras comprendido entre 000 y 999. 
 *	   Contiene informaci�n necesaria en la relaci�n entre la entidad del acreedor y el acreedor y permite al 
 *     acreedor identificar diferentes l�neas comerciales o servicios. 
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
	  :NbOfTxs 	:= 2 								// N�mero de operaciones 
	  :CtrlSum 	:= 370.35 							// Control de suma total importes
	  :Financiar:= .T.								// Remesa con financiacion (descuento)	
	  :Sufijo	:= "000"							// Regla 8	
	/* Idea ! NbOfTxs y CtrlSum deberan ser informadas, contrastar con variables calculadas en Activate() */
	ENDWITH

   // Presentador--------------------------------------------------------------
   // Los car�cter tilde, ap�strofe, �, �, etc debe realizarse con str2iso2022()
	WITH OBJECT oDoc:oInitPart
	  :nEntity	:= ENTIDAD_JURIDICA
	  :Nm 		:= str2iso2022("NOMBRE DEL PRESENTADOR, S.L.")
	  :AdrLine1 := str2iso2022("Direcci�n del presentador")
	  :AdrLine2 := str2iso2022("Poblaci�n del presentador")
	  :Ctry 	:= "ES"
	  :NIF      := "B12345678"
	ENDWITH

   // Acreedor-----------------------------------------------------------------
	WITH OBJECT oDoc:oCreditor
	  :nEntity	:= ENTIDAD_JURIDICA
	  :Nm 		:= str2iso2022("NOMBRE DEL ACREEDOR, S.L.")
	  :AdrLine1 := str2iso2022("Direcci�n del acreedor")
	  :AdrLine2 := str2iso2022("Poblaci�n del acreedor")
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
		  :AdrLine1 	:= str2iso2022("Direcci�n del deudor")+ strzero(n, 4) 
		  :AdrLine2 	:= str2iso2022("Poblaci�n del deudor")+ strzero(n, 4) 
		  :Ctry 		:= "ES"
		  :NIF 			:= "12345678Z"
		  :InstdAmt		:= 123.45 * n						 // Importe
		  :ReqdColltnDt := ctod("02-21-2014") + (n*10)		 // Fecha de cobro (Vencimiento)
		  :IBAN 		:= "ES0321001234561234567890"
		  :MndtId 		:= hb_md5(oDoc:oCreditor:NIF + :NIF) // Identificaci�n del mandato, sugerencia: NIF Acreedor + NIF Deudor 
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

	DATA MsgId 														// Identificaci�n del mensaje
	DATA CreDtTm 													// Fecha y hora de creaci�n
	DATA NbOfTxs 													// N�mero de operaciones 
	DATA Currency 				AS CHARACTER INIT "EUR" 			// Moneda, Divisa
	DATA CtrlSum 													// Control de suma
	DATA Financiar				AS LOGICAL 	INIT .F. 				// Financiacion: T=(Descuento), F=(Al cobro)
	DATA Sufijo					AS CHARACTER INIT "000"				// Facilitado por entidad bancaria, regla 8

	DATA ServiceLevel	 		AS CHARACTER INIT "SEPA"			// C�digo Nivel de servicio (7)
	DATA SeqTp 					AS CHARACTER INIT "RCUR" 			// Tipo de secuencia (2)
	DATA PurposeCd 													// C�digo categoria proposito
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
	::CreDtTm 	:= IsoDateTime()  // Fecha y hora de creaci�n

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
	 * Regla de uso para financiaci�n de remesas:
	 * El acreedor compondr� la referencia <MsgId> incluyendo en las cuatros primeras 
	 * posiciones de la identificaci�n del mensaje el prefijo FSDD
	 */
	::MsgId := "PRE" + fDate() + cTime() + strzero( seconds(), 5 ) + ::oInitPart:NIF
	if ::Financiar
		::MsgId := "FSDD"+ ::MsgId
	endif

	if ::CreDtTm != NIL .or. ::NbOfTxs != NIL .or. ::CtrlSum != NIL

		hItem := ItemNew(hParent, "GrpHdr") 				// Cabecera

		ItemNew(hItem, "MsgId",   35, ::MsgId) 				// Identificaci�n del mensaje
		ItemNew(hItem, "CreDtTm", 19, ::CreDtTm) 			// Fecha y hora de creaci�n
		ItemNew(hItem, "NbOfTxs", 15, str(::NbOfTxs, 0))	// N�mero de operaciones 
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
	Regla de uso: Las etiquetas ��ltimo acreedor�, �Cl�usula de gastos� e �Identificaci�n del acreedor� pueden aparecer, 
	bien en el nodo �Informaci�n del pago� (2.0), bien en el nodo �Informaci�n de la operaci�n de adeudo directo� (2.28), 
	pero solamente en uno de ellos. 
	Se recomienda que se recojan en el bloque �Informaci�n del pago� (2.0).
	*/
 local hItem

	if ::oDebtor:PmtInfId != NIL .or. ::oDebtor:PmtMtd != NIL .or. ;
	   ::oDebtor:BtchBookg != NIL .or. ::oDebtor:NbOfTxs != NIL .or. ;
	   ::oDebtor:CtrlSum != NIL .or. ::oDebtor:ReqdColltnDt != NIL .or. ::oDebtor:ChrgBr != NIL

		hItem := ItemNew(hParent, "PmtInf") 					// Informaci�n del pago 

		::IdPayment(hItem) 										// Identificaci�n de la informaci�n del pago 

		::TypePayment(hItem)									// Informaci�n del tipo de pago 

		ItemNew(hItem, "ReqdColltnDt", 8, ; 					// Fecha de cobro (Vencimiento)
				::oDebtor:ReqdColltnDt)						

		::Creditor(hItem)										// Datos Acreedor, Cuenta, Entidad

		if ::oUltimateCreditor:Nm != NIL 						// Opcional, �ltimo acreedor (6)
		   ::SetActor(hItem, "UltmtCdtr", ::oUltimateCreditor)	
		endif		 									 		// No produce error, es opcional

		ItemNew(hItem, "ChrgBr", 4, ::oDebtor:ChrgBr) 			// Cl�usula de gastos (5)

		::IdCreditor(hItem) 									// Identificaci�n del acreedor
	endif

return hItem

//--------------------------------------------------------------------------------------//

METHOD DirectDebit( hParent ) CLASS SepaXml

 local hItem, hChild

	if ::oDebtor:InstdAmt > 0
		hItem := ItemNew(hParent, "DrctDbtTxInf") 							// Informaci�n de la operaci�n de adeudo directo

		if ::oDebtor:InstrId != NIL .or. ::oDebtor:EndToEndId != NIL	
			hChild := ItemNew(hItem, "PmtId") 								// Identificaci�n del pago  
			ItemNew(hChild, "InstrId", 35, ::oDebtor:InstrId) 				// Identificaci�n de la instrucci�n
			ItemNew(hChild, "EndToEndId", 35, ::oDebtor:EndToEndId) 		// Identificaci�n de extremo a extremo 
		endif

		ItemNew(hItem, "InstdAmt", 12, ::oDebtor:InstdAmt, ::Currency) 		// Importe ordenado 

		if ::oDebtor:MndtId != NIL .or. ::oDebtor:DtOfSgntr != NIL 
			hChild := ItemNew(hItem, "DrctDbtTx") 							// Operaci�n de adeudo directo 
			hChild := ItemNew(hChild, "MndtRltdInf") 						// Informaci�n del mandato 
			ItemNew(hChild, "MndtId", 35, ::oDebtor:MndtId) 				// Identificaci�n del mandato 
			ItemNew(hChild, "DtOfSgntr", 8, ::oDebtor:DtOfSgntr) 			// Fecha de firma 
			
			if ::oDebtor:AmdmntInd != NIL
				ItemNew(hChild, "AmdmntInd", 5, ::oDebtor:AmdmntInd) 		// Indicador de modificaci�n 
				
				if ::oDebtor:OrgnlMndtId != NIL
					hChild := ItemNew(hChild, "AmdmntInfDtls") 					// Detalles de la modificaci�n 
					ItemNew(hChild, "OrgnlMndtId", 35, ::oDebtor:OrgnlMndtId) 	// Identificaci�n del mandato original 
				endif
			endif
		endif

 		hChild := ItemNew(hItem, "DbtrAgt") 			// Entidad del deudor 
		hChild := ItemNew(hChild, "FinInstnId") 		// Identificaci�n de la entidad 
 
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
				hChild := ItemNew(hChild, "PstlAdr") 					 // Direcci�n postal
				ItemNew(hChild, "Ctry", 2, ::oDebtor:Ctry) 			 // Pa�s
				ItemNew(hChild, "AdrLine", 70, ::oDebtor:AdrLine1) 	 // Direcci�n en texto libre
				
				if ::oDebtor:AdrLine2 != NIL
					ItemNew(hChild, "AdrLine", 70, ::oDebtor:AdrLine2) // Poblaci�n en texto libre
				endif
			endif
		else
			aadd( ::aErrors, ::ErrorMessages['SEPA_DEBTOR_NAME'] )
		endif

		if ::oDebtor:IBAN != NIL 
			hChild := ItemNew(hItem, "DbtrAcct") 			// Cuenta del deudor
			hChild := ItemNew(hChild, "Id") 				// Identificaci�n
			ItemNew(hChild, "IBAN", 34, ::oDebtor:IBAN) 	// IBAN
		else
			aadd( ::aErrors, ::ErrorMessages['SEPA_DEBTOR_ACCOUNT'] )
		endif

		if ::oUltimateDebtor:Nm != NIL 						// Opcional o Requerido ?
			::SetActor(hItem, "UltmtDbtr", ::oUltimateDebtor) 		// �ltimo deudor (6)
		endif

		if ::PurposeCd != NIL
			hChild := ItemNew(hItem, "Purp") 						// Prop�sito 
			ItemNew(hChild, "Cd", 4, ::PurposeCd) 					// C�digo
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
	hItem := ItemNew(hItem, "Id") 										// Identificaci�n 

	if oActor:nEntity == ENTIDAD_JURIDICA
		hItem := ItemNew(hItem, "OrgId") 								// Persona jur�dica
	elseif oActor:nEntity == ENTIDAD_FISICA	
		hItem := ItemNew(hItem, "PrvtId") 								// Persona f�sica 
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
				ItemNew(hItem, "CtryOfBirth", 2, oActor:CtryOfBirth) 	// Pa�s de nacimiento
			else
				// Error
			endif
			EXIT 

		otherwise
			if oActor:Id != NIL .or. oActor:Cd != NIL .or. oActor:Prtry != NIL .or. oActor:Issr != NIL
				hItem := ItemNew(hItem, "Othr") 						// Otra 
				ItemNew(hItem, "Id", 35, oActor:Id) 					// Identificaci�n 

				if oActor:Cd != NIL .or. oActor:Prtry != NIL
					hChild := ItemNew(hItem, "SchmeNm") 				// Nombre del esquema 
					ItemNew(hChild +5, "Cd", 4, oActor:Cd) 				// C�digo 
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

	ItemNew(hItem, "PmtInfId", 35, ::oDebtor:PmtInfId)		// Identificaci�n de la informaci�n del pago 
	ItemNew(hItem, "PmtMtd", 2, ::oDebtor:PmtMtd) 			// M�todo de pago
	ItemNew(hItem, "BtchBookg", 5, ::oDebtor:BtchBookg) 		// Indicador de apunte en cuenta
	ItemNew(hItem, "NbOfTxs", 15, str(::oDebtor:NbOfTxs, 0)) 	// N�mero de operaciones 
	ItemNew(hItem, "CtrlSum", 18, ::oDebtor:CtrlSum) 			// Control de suma 

return NIL

//--------------------------------------------------------------------------------------//

METHOD TypePayment( hParent ) CLASS SepaXml

 local hItem, hChild

 	hItem := ItemNew(hParent, "PmtTpInf") 						// Informaci�n del tipo de pago 

	hChild := ItemNew(hItem, "SvcLvl") 							// Nivel de servicio 
	ItemNew(hChild, "Cd", 4, ::ServiceLevel)	 				// C�digo Nivel de servicio

	hChild := ItemNew(hItem, "LclInstrm") 						// Instrumento local  
	ItemNew(hChild, "Cd", 35, ::SchmeNm)						// C�digo Instrumento local

	ItemNew(hItem, "SeqTp", 4, ::SeqTp) 						// Tipo de secuencia

	/* Lista de c�digos recogidos en la norma ISO 20022 
	   Ex: CASH=CashManagementTransfer (Transaction is a general cash management instruction) */
	if ::PurposeCd != NIL
		hChild := ItemNew(hItem, "CtgyPurp") 					// Categor�a del prop�sito 
		ItemNew(hChild, "Cd", 4, ::PurposeCd) 					// C�digo 
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
			hItem := ItemNew(hItem, "PstlAdr") 						// Direcci�n postal
			ItemNew(hItem, "Ctry", 2, ::oCreditor:Ctry) 			// Pa�s
			ItemNew(hItem, "AdrLine", 70, ::oCreditor:AdrLine1) 	// Direcci�n en texto libre
			
			if ::oCreditor:AdrLine2 != NIL
				ItemNew(hItem, "AdrLine", 70, ::oCreditor:AdrLine2) // Poblaci�n en texto libre
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
		 * Esta etiqueta s�lo debe usarse cuando un mismo n�mero de cuenta
		 * cubra  diferentes divisas y el presentador necesite identificar
		 * en cu�l de estas divisas debe realizarse el asiento sobre su cuenta
			ItemNew(hItem, "Ccy", 3, ::Currency) 					// Moneda 
		 */
		hItem := ItemNew(hItem, "Id") 								// Identificaci�n
		ItemNew(hItem, "IBAN", 34, ::oCreditor:IBAN) 				// IBAN
	else
		// Error
	endif

	hItem := ItemNew(hParent, "CdtrAgt") 							// Entidad del acreedor
	hItem := ItemNew(hItem, "FinInstnId") 							// Identificaci�n de la entidad 
	
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

		hItem := ItemNew(hParent, "CdtrSchmeId") 					// Identificaci�n del acreedor 
		hItem := ItemNew(hItem, "Id") 								// Identificaci�n  
		hItem := ItemNew(hItem, "PrvtId") 							// Identificaci�n privada  
		hItem := ItemNew(hItem, "Othr") 							// Otra 

		ItemNew( hItem, "Id", 35, alltrim(::oCreditor:Id) )			// Identificaci�n 

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

	hItem := ItemNew(hItem, ::FinancialMsg)						// Ra�z del mensaje 

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

		/* Identificaci�n de la instrucci�n, 35 de longitud (8+6+1+20) */
		cMsg := fDate() + cTime() +"-"+ strzero(nNumOp, 20) 
		::oDebtor:InstrId 	 := cMsg 

		/* Identificaci�n de extremo a extremo, 35 de longitud (8+1+6+20) 
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
	DATA AdrLine1 											// Direcci�n en texto libre
	DATA AdrLine2 											// Se permiten 2 etiquetas para direccion
	DATA Ctry 												// Pais
	DATA NIF												// NIF
	DATA IBAN												// IBAN
	DATA BIC												// BIC
	DATA BICOrBEI 											// BIC o BEI 
	DATA BirthDt											// Fecha de nacimiento 
	DATA PrvcOfBirth 										// Provincia de nacimiento
	DATA CityOfBirth										// Ciudad de nacimiento 
	DATA CtryOfBirth 										// Pa�s de nacimiento
	DATA Id													// Identificaci�n 
	DATA Issr												// Emisor 
	DATA Cd 												// Codigo
	DATA Prtry 												// Propietario

	DATA PmtInfId 									 		// Identificaci�n de la informaci�n del pago 
	DATA BtchBookg 		AS CHARACTER INIT "true"			// Indicador de apunte en cuenta (1)
	DATA ReqdColltnDt 										// Fecha de cobro (Vencimiento)
	DATA Info 												// Informacion no estructurada, p.e., concepto del cobro
	DATA NbOfTxs		AS NUMERIC INIT 0					// N�mero de operaciones 
	DATA CtrlSum 		AS NUMERIC INIT 0.00 				// Control de suma 
	DATA PmtMtd 		AS CHARACTER INIT "DD" 	 READONLY 	// M�todo de pago Regla de uso: Solamente se admite el c�digo �DD�
	DATA ChrgBr 		AS CHARACTER INIT "SLEV" READONLY 	// Cl�usula de gastos (4)
	DATA InstrId 											// Identificaci�n de la instrucci�n
	DATA EndToEndId 										// Identificaci�n de extremo a extremo 
	DATA InstdAmt 		AS NUMERIC INIT 0.00 				// Importe ordenado 
	DATA MndtId												// Identificaci�n del mandato 
	DATA DtOfSgntr											// Fecha de firma 
	DATA AmdmntInd 	  	AS CHARACTER INIT "false"	 		// Indicador de modificaci�n 
	DATA OrgnlMndtId									 	// Identificaci�n del mandato original 

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
