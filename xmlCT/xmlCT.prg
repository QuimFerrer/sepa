/* v.1.0 18/12/2013
 * RB SEPA Credit Transfer pain.001.001.03
 * Ordenes en formato ISO 20022 para emisión de transferencias y cheques en euros
 * (c) Joaquim Ferrer Godoy <quim_ferrer@yahoo.es>
 *
 * Notas:
 * Version para CA-Clipper/Harbour, 'casi en pseudo-codigo', para adaptar 
 * facilmente a otros paradigmas (OOPS, arrays asociativos, etc.) o lenguajes
 * de programación.
 * Las variables no declaradas se pueden sustituir por campos de base de datos
 */

#include "hbmxml.ch"

#define ENTIDAD_JURIDICA	0
#define ENTIDAD_FISICA		1
#define ENTIDAD_OTRA		2

static aItems := {}


//--------------------------------------------------------------------//

function main()

	local cDocType, cFileOut
  	local hXmlDoc, hDoc
	local idOrdenante

	cDocType 	:= "pain.001.001.03"
	cFileOut 	:= "testSepa.xml"
	hXmlDoc  	:= mxmlNewXML()
  	hDoc 	 	:= mxmlNewElement(hXmlDoc, "Document")
	idOrdenante := ENTIDAD_JURIDICA

	mxmlElementSetAttr( hDoc, "xmlns","urn:iso:std:iso:20022:tech:xsd:"+ cDocType )
	mxmlElementSetAttr( hDoc, "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance" )

	/* Variables */
	MsgId 		:= 'ABC/060928/CCT001'			
	CreDtTm 	:= '2010-12-18T14:07:00'		// ISODateTime YYYY-MM-DDThh:mm:ss (Año-mes-día)
	NbOfTxs 	:= '3' 							// NumberOfTransactions
	CtrlSum 	:= 535.25 						// Suma total importes individuales, 18 digitos, va desde 0.01 hasta 999999999999999.99
	InstrPrty	:= ""
	InitgPtyNm 	:= 'E77846772000' 				// InitiatingParty NIF-Sufijo (E77846772 + 000)

	BICOrBEI 	:= ""
	OthrId 		:= '0468651441'
	Cd 			:= "" 
	Prtry 		:= ""
	Issr 		:= 'KBO-BCE' 

	PmtInfId 	:= 'ABC/4560/2010-12-15'
	PmtMtd 		:= 'TRF' 
	BtchBookg 	:= 'false' 
	Cd 			:= 'SEPA' 
	ReqdExctnDt := '2010-12-19'
	Nm 			:= 'Cobelfac' 
	IBAN 		:= 'BE68539007547034' 
	BIC 		:= 'AAAABE33'
	InstrId 	:= ""
	EndToEndId 	:= 'ABC/4562/2010-12-18' 
	InstdAmt 	:= 535.25 
	BIC 		:= 'CRBABE22' 
	CdtrNm 		:= 'SocMetal' 
	Ctry 		:= 'BE' 
	AdrLine1 	:= 'Hoogstraat 156' 
	AdrLine2	:= '2000 Antwerp' 
	IBAN 		:= 'BE43187123456701'
	Ustrd 		:= 'Invoice 378265'

	/* Cabecera */
	itemNew(1, 'CstmrCdtTrfInitn',,, hDoc) 		// Raiz del mensaje
	itemNew(2, 'GrpHdr') 						// Cabecera
	itemNew(3, 'MsgId', 35, MsgId) 				// Identificación de mensaje
	itemNew(3, 'CreDtTm', 19, CreDtTm) 			// Fecha y hora de creación 
	itemNew(3, 'NbOfTxs', 5, NbOfTxs)  			// Número de operaciones
	itemNew(3, 'CtrlSum', 18, CtrlSum) 			// Control de suma
	itemNew(3, 'InitgPty') 						// Parte iniciadora, Ordenante
	itemNew(4, 'Nm', 70, Nm) 					// Nombre
	itemNew(4, 'Id') 							// Identificación

if idOrdenante == ENTIDAD_JURIDICA
	itemNew(5, 'OrgId') 						// Persona jurídica
	itemNew(6, 'BICOrBEI', 11, BICOrBEI) 		// BIC o BEI
else
 if idOrdenante == ENTIDAD_FISICA
	itemNew(5, 'PrvtId')						 // Persona física
	itemNew(6, 'DtAndPlcOfBirth')				 // Fecha y lugar de nacimiento
	itemNew(7, 'BirthDt', 8, BirthDt)			 // Fecha de nacimiento
	itemNew(7, 'PrvcOfBirth', 35, PrvcOfBirth)	 // Provincia de nacimiento
	itemNew(7, 'CityOfBirth', 35, CityOfBirth)   // Ciudad de nacimiento
	itemNew(7, 'CtryOfBirth', 2, CtryOfBirth)    // País de nacimiento
 else
	itemNew(6, 'Othr') 							 // Otra
	itemNew(7, 'Id', 35, OthrId) 				 // Identificación
	itemNew(7, 'SchmeNm') 						 // Nombre del esquema
	itemNew(8, 'Cd', 4, Cd) 					 // Código
	itemNew(8, 'Prtry', 35, Prtry)				 // Propietario
	itemNew(7, 'Issr', 35, Issr)				 // Emisor
 endif
endif

/* --> Bucle para múltiples ordenes */

	/* Registro individual */
	itemNew(2, 'PmtInf') 						 // Información del pago
	itemNew(3, 'PmtInfId', 35, PmtInfId)		 // Identificación de Información del pago
	itemNew(3, 'PmtMtd', 3, PmtMtd) 			 // Método de pago
	itemNew(3, 'BtchBookg', 5, BtchBookg) 		 // Indicador de apunte en cuenta
	itemNew(3, 'NbOfTxs', 5, NbOfTxs) 		 	 // Número de operaciones
	itemNew(3, 'CtrlSum', 18, CtrlSum) 		 	 // Control de suma
	itemNew(3, 'PmtTpInf') 						 // Información del tipo de pago 
	itemNew(4, 'InstrPrty', 4, InstrPrty) 		 // Prioridad de la instrucción
	itemNew(4, 'SvcLvl') 						 // Nivel de servicio
	itemNew(5, 'Cd', 4, Cd) 					 // Código
	itemNew(4, 'LclInstrm') 					 // Instrumento local
	itemNew(5, 'Cd', 4, Cd) 					 // Código
	itemNew(5, 'Prtry', 35, Prtry) 				 // Propietario
	itemNew(4, 'CtgyPurp') 					 	 // Tipo de transferencia
	itemNew(5, 'Cd', 4, Cd) 					 // Código
	itemNew(3, 'ReqdExctnDt', 10, ReqdExctnDt) 	 // Fecha de ejecución solicitada
	itemNew(3, 'Dbtr') 							 // Ordenante
	itemNew(4, 'Nm', 70, 'Cobelfac')			 // Nombre
/* desde anterior a posterior revisar y completar*/
	itemNew(3, 'DbtrAcct') 						 // Cuenta del ordenante
	itemNew(4, 'Id') 							 // Identificación
	itemNew(5, 'IBAN', 34, IBAN) 				 // IBAN
/* desde anterior a posterior revisar y completar*/
	itemNew(3, 'DbtrAgt') 						 // Entidad ordenante
	itemNew(4, 'FinInstnId')					 // Identificación de la entidad ordenante 
	itemNew(5, 'BIC', 11, BIC)					 // BIC de la entidad ordenante
/* desde anterior a posterior revisar y completar*/
	itemNew(3, 'CdtTrfTxInf') 					 // Información de transferencia individual
	itemNew(4, 'PmtId') 						 // Identificación del pago
	itemNew(5, 'InstrId', 35, InstrId) 	 		 // Identificación de la instrucción
	itemNew(5, 'EndToEndId', 35, EndToEndId) 	 // Identificación de extremo a extremo
/* desde anterior a posterior revisar y completar*/
	itemNew(4, 'Amt')							 // Importe 				
	itemNew(5, 'InstdAmt', 11, InstdAmt)		 // Importe ordenado --> Ver <InstdAmt Ccy="EUR">
/* desde anterior a posterior revisar y completar*/
	itemNew(4, 'CdtrAgt') 						 // Entidad del beneficiario 
	itemNew(5, 'FinInstnId') 					 // Identificación de la entidad del beneficiario
	itemNew(6, 'BIC', 11, BIC) 					 // BIC de la entidad del beneficiario 
	itemNew(4, 'Cdtr') 							 // Beneficiario 
	itemNew(5, 'Nm', 70, CdtrNm) 				 // Nombre
	itemNew(5, 'PstlAdr')						 // Dirección postal
	itemNew(6, 'Ctry', 2, Ctry) 				 // País
	itemNew(6, 'AdrLine', 70, AdrLine1) 		 // Dirección en texto libre		
	itemNew(6, 'AdrLine', 70, AdrLine2)			 // Se puede repetir hasta 140 caracter 
/* desde anterior a posterior revisar y completar*/
	itemNew(4, 'CdtrAcct') 						 // Cuenta del beneficiario
	itemNew(5, 'Id') 							 // Identificación
	itemNew(6, 'IBAN', 34, IBAN) 				 // IBAN
/* desde anterior a posterior revisar y completar*/
	itemNew(4, 'RmtInf')						 // Concepto
	itemNew(5, 'Ustrd', 140, Ustrd)				 // No estructurado

/* <-- fin de bucle para múltiples ordenes */

	mxmlSaveFile( hXmlDoc, cFileOut, MXML_NO_CALLBACK )

return NIL


//--------------------------------------------------------------------//

static function itemNew(nLevel, cLabel, nLen, xValue, hParent)

 local hItem

	if len(aItems) < nLevel
		aadd( aItems, {} )
	endif

	if hParent == NIL
	   hParent := atail( aItems[nLevel -1] )
	endif

	hItem := mxmlNewElement( hParent, cLabel )

	if xValue != NIL
	   mxmlNewText( hItem, 0, padR(xValue, nLen) )
	endif

	aadd( aItems[nLevel], hItem )

return NIL

//--------------------------------------------------------------------//