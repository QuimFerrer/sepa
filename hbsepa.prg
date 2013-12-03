#include "hbclass.ch"
#include "fileio.ch"

#define CRLF chr(13)+chr(10)

CLASS Sepa
	DATA   nHandle, nError		
	DATA   Modelo 					AS CHARACTER INIT "340"
	DATA   Ejercicio
	DATA   Periodo
	DATA   Contador					AS CHARACTER INIT "0001"
	DATA   Registros 				AS NUMERIC   INIT 0
	DATA   Idocumento 
	DATA   CEA 						//Codigo Electronico Autoliquidacion
	DATA   TotBase 					AS NUMERIC 	 INIT 0
	DATA   TotIva 					AS NUMERIC 	 INIT 0
	DATA   TotFras 					AS NUMERIC 	 INIT 0
	DATA   Libro 
	DATA   Operacion 
	DATA   oEntidad, oDeclarado

	METHOD New( ejercicio, periodo, fileOut ) CONSTRUCTOR
	METHOD WriteHeader()
	METHOD WriteRecord()
	METHOD OutFile()
	METHOD End() 		
ENDCLASS

METHOD Sepa:New( norma, fileOut )

	::nHandle 		:= fcreate( fileOut, FO_READ + FO_EXCLUSIVE )
	::nError		:= ferror()
	::Ejercicio 	:= ejercicio
	::Periodo 		:= Qtr2Month(periodo)
	::Idocumento 	:= ::Modelo + ::Ejercicio + ::Periodo + ::Contador
	::oEntidad 		:= Entidad():New()
	::oDeclarado 	:= Declarado():New()

return( Self )