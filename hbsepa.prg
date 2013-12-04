#include "hbclass.ch"
#include "fileio.ch"

#define CRLF chr(13)+chr(10)

CLASS SepaFile
	DATA   nHandle, nError	
	DATA   Norma	
	DATA   Sufijo					AS CHARACTER INIT "000"

	METHOD New( norma, fileOut ) 	CONSTRUCTOR
	METHOD WriteHeader()
	METHOD WriteRecord()
	METHOD OutFile()
	METHOD End() 					INLINE fclose(::nHandle)
ENDCLASS


METHOD SepaFile:New( norma, fileOut )

	::Norma 		:= norma
	::nHandle 		:= fcreate( fileOut, FO_READ + FO_EXCLUSIVE )
	::nError		:= ferror()
	::oPresentador 	:= SepaItem():New()
	::oAcreedor 	:= SepaItem():New()
	::oRegistro 	:= SepaItem():New()

return( Self )


METHOD SepaFile:OutFile(a)

	local strRec := ""
	aeval( a, {|e| strRec += e } )
	fwrite(::nHandle, strRec + CRLF)

return NIL


CLASS SepaItem
	DATA Entidad  
	DATA Oficina 	
	DATA Referencia
	DATA Nombre		
	DATA Direcc	 
	DATA Ciudad	 
	DATA Provin	 	
	DATA Pais	
	DATA Nif	 
	DATA Cta 		
																// FNAL Último adeudo de varios FRST Primer adeudo de varios 
	DATA Adeudo 		AS STRING INIT 'OOFF'					// OOFF Unico pago RCUR Adeudo de varios que no es FNAL ni FRST
	DATA Categoria		AS STRING INIT ''						// Opcional segun tabla de categorias de proposito
	DATA Referencia 											// Referencia unica para identificacion del recibo
	DATA RMandato 	 											// Referencia unica orden domiciliación. Utilizar hash, p.e., MD5
	DATA DMandato 												// Fecha orden domiciliación o mandato	
	DATA BIC 		
	DATA Importe 	
	DATA Plazo		
	DATA Tipo 			AS STRING INIT ''						// Opcional, tipo de persona 1=Juridica 2=Fisica 
	DATA Emisor 		AS STRING INIT ''						// Opcional, solo si se usa DATA Tipo
	DATA IdCta 			AS STRING INIT 'A'						// A=IBAN B=CCC
	DATA Proposito  	AS STRING INIT ''						// Opcional, 4 digitos segun tabla ISO 20022 UNIFI
	DATA Concepto   
ENDCLASS

METHOD SepaItem:New()
return( Self )