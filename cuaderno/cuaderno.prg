#include "FiveWin.Ch"

//---------------------------------------------------------------------------//

Function DecimalToString( nValue, nLen )

   local cValue       
      
   cValue   := str( nValue, nLen + 1, 2 )    // +1 espacio que resta punto decimal
   cValue   := strtran( cValue, "." )        // Quitar punto decimal
   cValue   := strtran( cValue, " ", "0" )   // Reemplazar espacios por 0
   
Return ( cValue )

//---------------------------------------------------------------------------//

Function TimeToString()                         

   local cTime  := time()
   cTime        := substr( cTime, 1, 2 ) + substr( cTime, 4, 2 ) + substr( cTime, 7, 2 )
      
Return ( cTime )

//---------------------------------------------------------------------------//

Function DateToString( dDate )
      
   DEFAULT dDate  := date()

Return ( dtos( dDate ) )

//---------------------------------------------------------------------------//

CLASS Cuaderno

   DATA cFile                             INIT "c:\prueba.txt" 
   DATA hFile 
   DATA cFechaCreacion                    INIT DateToString()

   METHOD FechaCreacion( dValue )         INLINE ( if( !Empty( dValue ), ::cFechaCreacion    := DateToString( dValue ), ::cFechaCreacion ) )

ENDCLASS

//---------------------------------------------------------------------------//

CLASS Cuaderno1914 FROM Cuaderno

   DATA oPresentador
   DATA cVersionCuaderno                  INIT '19143' 

   METHOD VersionCuaderno( cValue )       INLINE ( if( !Empty( cValue ), ::cVersionCuaderno  := padr( cValue, 5 ),      ::cVersionCuaderno ) )
   METHOD CodigoRegistro( cValue )        INLINE ( '01' )

   METHOD GetPresentador()                INLINE ( ::oPresentador ) 
   METHOD InsertAcreedor()                INLINE ( ::GetPresentador():InsertAcreedor() )
   METHOD InsertDeudor()                  INLINE ( ::GetPresentador():GetAcreedor():InsertDeudor() )

   METHOD New()
   METHOD SerializeASCII()

ENDCLASS

   //------------------------------------------------------------------------//

   METHOD New() CLASS Cuaderno1914

      ::oPresentador    := Presentador():New( Self )

   Return ( Self )

   //------------------------------------------------------------------------//

   METHOD SerializeASCII() CLASS Cuaderno1914

      ::hFile  := fCreate( ::cFile )

      if !Empty( ::hFile )
         fWrite( ::hFile, ::GetPresentador():SerializeASCII() )
         fClose( ::hFile )
      end if

   Return ( Self )

//---------------------------------------------------------------------------//

CLASS Presentador 

   DATA oSender

   DATA cEntidad     
   DATA cOficina     
   DATA cReferencia  

   DATA cPais                    INIT 'ES'         
   DATA cNombre                  INIT space( 70 )       
   DATA cNif                     INIT space( 36 )

   DATA cSufijo                  INIT '000'

   DATA aChild                   INIT {}

   METHOD New( oSender )         INLINE ( ::oSender   := oSender, Self ) 

   METHOD VersionCuaderno()      INLINE ( ::oSender:VersionCuaderno() )
   METHOD FechaCreacion()        INLINE ( ::oSender:FechaCreacion() )

   METHOD CodigoRegistro()       INLINE ( '01' )
   METHOD CodigoRegistroTotal()  INLINE ( '05' )
   METHOD Dato()                 INLINE ( '001' )
   METHOD Sufijo( cValue )       INLINE ( if( !Empty( cValue ), ::cSufijo     := padr( cValue, 3 ),   ::cSufijo ) )   

   METHOD Entidad( cValue )      INLINE ( if( !Empty( cValue ), ::cEntidad    := padr( cValue, 4 ),   ::cEntidad ) )
   METHOD Oficina( cValue )      INLINE ( if( !Empty( cValue ), ::cOficina    := padr( cValue, 4 ),   ::cOficina ) )    
   METHOD Referencia( cValue )   INLINE ( if( !Empty( cValue ), ::cReferencia := ::File( cValue ),    ::cReferencia ) )

   METHOD Nombre( cValue )       INLINE ( if( !Empty( cValue ), ::cNombre     := padr( cValue, 70 ),  ::cNombre ) )
   METHOD Pais( cValue )         INLINE ( if( !Empty( cValue ), ::cPais       := padr( cValue, 2 ),   ::cPais ) )
   METHOD Nif( cValue )          INLINE ( if( !Empty( cValue ), ::cNif        := padr( cValue, 36 ),  ::cNif ) )     

   METHOD TotalImporte()         INLINE ( DecimalToString( ::nTotalImporte(), 17 ) )
   METHOD nTotalImporte()

   METHOD TotalRegistros()       INLINE ( strzero( ::nTotalRegistros(), 8 ) )
   METHOD nTotalRegistros()                
   METHOD TotalFinalRegistros()   INLINE ( strzero( ::nTotalRegistros() + 3, 10 ) )

   METHOD GetAcreedor()          INLINE ( atail( ::aChild ) )
   METHOD InsertAcreedor()       INLINE ( aadd( ::aChild, Acreedor():New( Self ) ), ::GetAcreedor() )

   METHOD File( cValue )         INLINE ( padr( "PRE" + DateToString() + TimeToString() + strzero( seconds(), 5 ) + cValue, 35 ) )

   METHOD Identificador()

   METHOD SerializeASCII()

ENDCLASS

   //------------------------------------------------------------------------//

   METHOD Identificador() CLASS Presentador 
 
      local n
      local cId
      local nLen
      local cValue
      local cAlgorithm  := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   
      cId               := ""
      nLen              := len( alltrim( ::Nif() ) )

      for n := 1 to nLen
         cValue         := substr( ::Nif(), n, 1 )
         if isDigit( cValue )
            cId         += cValue
         else
            cId         += str( at( cValue, cAlgorithm ) + 9, 2, 0 )
         endif
      next
   
      cId               += str( at( substr( ::Pais(), 1, 1 ), cAlgorithm ) + 9, 2, 0 )
      cId               += str( at( substr( ::Pais(), 2, 1 ), cAlgorithm ) + 9, 2, 0 )
      cId               += "00"
      cId               := ::Pais() + strzero( 98 - ( val( cId ) % 97 ), 2 ) + ::Sufijo() + alltrim( ::Nif() )
   
   Return ( padr( cId, 35 ) )

   //------------------------------------------------------------------------//

   METHOD nTotalImporte() CLASS Presentador 

      local nTotalImporte        := 0
      
      aEval( ::aChild, {|o| nTotalImporte += o:nTotalImporte() } )

   Return ( nTotalImporte )

   //------------------------------------------------------------------------//
   
   METHOD nTotalRegistros() CLASS Presentador

      local nTotalRegistros      := 0

      aEval( ::aChild, {|o| nTotalRegistros += o:nTotalRegistros() } )

   Return ( nTotalRegistros )

   //------------------------------------------------------------------------//

   METHOD SerializeASCII() CLASS Presentador 

      local oAcreedor
      local cBuffer  := ""

      cBuffer        += ::CodigoRegistro()
      cBuffer        += ::VersionCuaderno()
      cBuffer        += ::Dato()
      cBuffer        += ::Identificador()
      cBuffer        += ::Nombre()
      cBuffer        += ::FechaCreacion()
      cBuffer        += ::Referencia()
      cBuffer        += ::Entidad()
      cBuffer        += ::Oficina()
      cBuffer        := padr( cBuffer, 600 ) + CRLF 

      for each oAcreedor in ::aChild
         cBuffer     += oAcreedor:SerializeASCII()
      next

      cBuffer        += ::CodigoRegistroTotal()
      cBuffer        += ::Identificador()
      cBuffer        += ::TotalImporte()
      cBuffer        += ::TotalRegistros()
      cBuffer        += ::TotalFinalRegistros()
      cBuffer        += padr( cBuffer, 520 ) + CRLF 

   Return ( cBuffer )

//---------------------------------------------------------------------------//

CLASS Acreedor FROM Presentador

   DATA cDireccion      
   DATA cCodigoPostal
   DATA cPoblacion 
   DATA cProvincia      
   DATA cCuentaIBAN     
   DATA cFechaCobro              INIT DateToString()

   DATA aChild                  INIT {}

   METHOD Direccion( cValue )    INLINE ( if( !Empty( cValue ), ::cDireccion     := padr( cValue, 50 ),     ::cDireccion ) )    
   METHOD CodigoPostal( cValue ) INLINE ( if( !Empty( cValue ), ::cCodigoPostal  := cValue,                 rtrim( ::cCodigoPostal ) ) )    
   METHOD Poblacion( cValue )    INLINE ( if( !Empty( cValue ), ::cPoblacion     := cValue,                 rtrim( ::cPoblacion ) ) )    
   METHOD Ciudad()               INLINE ( padr( ::CodigoPostal() + Space( 1 ) + ::Poblacion(), 50 ) )
   METHOD Provincia( cValue )    INLINE ( if( !Empty( cValue ), ::cProvincia     := padr( cValue, 40 ),     ::cProvincia ) )
   METHOD CuentaIBAN( cValue )   INLINE ( if( !Empty( cValue ), ::cCuentaIBAN    := padr( cValue, 34 ),     ::cCuentaIBAN ) )
   METHOD FechaCobro( dValue )   INLINE ( if( !Empty( dValue ), ::cFechaCobro    := DateToString( dValue ), ::cFechaCobro ) )

   METHOD CodigoRegistro()       INLINE ( '01' )
   METHOD CodigoRegistroTotal()  INLINE ( '04' )
   METHOD Dato()                 INLINE ( '002' )

   METHOD GetDeudor()            INLINE ( atail( ::aChild ) )
   METHOD InsertDeudor()         INLINE ( aadd( ::aChild, Deudor():New( Self ) ), ::GetDeudor() )
   
   METHOD SerializeASCII()

ENDCLASS

   //------------------------------------------------------------------------//

   METHOD SerializeASCII() CLASS Acreedor

      local oDeudor
      local cBuffer        := ""

      cBuffer              += ::CodigoRegistro()
      cBuffer              += ::VersionCuaderno()
      cBuffer              += ::Dato()
      cBuffer              += ::Identificador()
      cBuffer              += ::FechaCobro()
      cBuffer              += ::Nombre()
      cBuffer              += ::Direccion()
      cBuffer              += ::Ciudad()
      cBuffer              += ::Provincia()
      cBuffer              += ::Pais()
      cBuffer              += ::CuentaIBAN()
      cBuffer              := padr( cBuffer, 600 ) + CRLF 

      for each oDeudor in ::aChild
         cBuffer           += oDeudor:SerializeASCII()
      next 

      cBuffer              += ::CodigoRegistroTotal()
      cBuffer              += ::Identificador()
      cBuffer              += ::FechaCobro()
      cBuffer              += ::TotalImporte()
      cBuffer              += ::TotalRegistros()
      cBuffer              += ::TotalFinalRegistros()
      cBuffer              += padr( '', 520 ) + CRLF 

   Return ( cBuffer )

//---------------------------------------------------------------------------//

CLASS Deudor FROM Acreedor

   DATA cReferencia                       INIT space( 35 )
   DATA cReferenciaMandato                INIT space( 35 )
   DATA cTipoAdeudo                       INIT 'OOFF'
   DATA cCategoria                        INIT space( 4 )
   DATA nImporte                          INIT 0
   DATA cImporte                          INIT '0'
   DATA cFechaMandato                     INIT DateToString()
   DATA cEntidadBIC                       INIT space( 11 )
   DATA cTipo                             INIT space( 1 )
   DATA cEmisor                           INIT space( 35 )
   DATA cIdentificadorCuenta              INIT 'A'
   DATA cProposito                        INIT space( 4 )
   DATA cConcepto                         INIT space( 140 )

   METHOD CodigoRegistro()                INLINE ( ::oSender:oSender:CodigoRegistro() )
   METHOD VersionCuaderno()               INLINE ( ::oSender:oSender:VersionCuaderno() )

   METHOD Referencia( cValue )            INLINE ( if( !Empty( cValue ), ::cReferencia          := padr( cValue, 35 ),     ::cReferencia ) )
   METHOD ReferenciaMandato( cValue )     INLINE ( if( !Empty( cValue ), ::cReferenciaMandato   := padr( cValue, 35 ),     ::cReferenciaMandato ) )
   METHOD TipoAdeudo( cValue )            INLINE ( if( !Empty( cValue ), ::cTipoAdeudo          := padr( cValue, 4 ),      ::cTipoAdeudo ) )
   METHOD Categoria( cValue )             INLINE ( if( !Empty( cValue ), ::cCategoria           := padr( cValue, 4 ),      ::cCategoria ) )
   METHOD FechaMandato( dValue )          INLINE ( if( !Empty( dValue ), ::cFechaMandato        := DateToString( dValue ), ::cFechaMandato ) )
   METHOD EntidadBIC( cValue )            INLINE ( if( !Empty( cValue ), ::cEntidadBIC          := padr( cValue, 11 ),     ::cEntidadBIC ) )
   METHOD Tipo( cValue )                  INLINE ( if( !Empty( cValue ), ::cTipo                := padr( cValue, 1 ),      ::cTipo ) )
   METHOD Emisor( cValue )                INLINE ( if( !Empty( cValue ), ::cEmisor              := padr( cValue, 35 ),     ::cEmisor ) )
   METHOD IdentificadorCuenta( cValue )   INLINE ( if( !Empty( cValue ), ::cIdentificadorCuenta := padr( cValue, 1 ),      ::cIdentificadorCuenta ) )
   METHOD Proposito( cValue )             INLINE ( if( !Empty( cValue ), ::cProposito           := padr( cValue, 4 ),      ::cProposito ) )
   METHOD Concepto( cValue )              INLINE ( if( !Empty( cValue ), ::cConcepto            := padr( cValue, 140 ),    ::cConcepto ) )

   METHOD Dato()                          INLINE ( '003' )

   METHOD nTotalRegistros()               INLINE ( 1 )

   METHOD Importe( nValue )

   METHOD SerializeASCII()

ENDCLASS

   //------------------------------------------------------------------------//

   METHOD Importe( nValue ) CLASS Deudor

      if !Empty( nValue )
         ::nImporte                    := nValue
         ::cImporte                    := DecimalToString( nValue, 11 )
      endif

   Return ( ::cImporte ) 

   //------------------------------------------------------------------------//

   METHOD SerializeASCII() CLASS Deudor

      local cBuffer  := ""

      cBuffer        += ::CodigoRegistro()
      cBuffer        += ::VersionCuaderno()
      cBuffer        += ::Dato()
      cBuffer        += ::Referencia()
      cBuffer        += ::ReferenciaMandato()
      cBuffer        += ::TipoAdeudo()
      cBuffer        += ::Categoria()
      cBuffer        += ::Importe()
      cBuffer        += ::FechaMandato()
      cBuffer        += ::EntidadBIC()
      cBuffer        += ::Nombre()
      cBuffer        += ::Direccion()
      cBuffer        += ::Ciudad()
      cBuffer        += ::Provincia()
      cBuffer        += ::Pais()
      cBuffer        += ::Tipo()
      cBuffer        += ::Nif()
      cBuffer        += ::Emisor()
      cBuffer        += ::IdentificadorCuenta()
      cBuffer        += ::CuentaIBAN()
      cBuffer        += ::Proposito()
      cBuffer        += ::Concepto()
      cBuffer        := padr( cBuffer, 600 ) + CRLF 

   Return ( cBuffer )

//---------------------------------------------------------------------------//

Function TestCuaderno1914()

   local oCuaderno   := Cuaderno1914():New()

   // Presentador--------------------------------------------------------------

   with object ( oCuaderno:GetPresentador() )
      :Entidad( '0081' )
      :Oficina( '1234' )
      :Referencia( 'REMESA0000123' )            
      :Nombre( "NOMBRE DEL PRESENTADOR, S.L." )
      :Pais( "ES" )
      :Nif( "W9614457A" )
   end with

   // Acreedor 1 -----------------------------------------------------------------

   with object ( oCuaderno:InsertAcreedor() )
      :FechaCobro( Date() )
      :Nombre( "NOMBRE DEL ACREEDOR #1, S.L." )
      :Direccion( "CALLE DEL ACREEDOR #1, 1234" )
      :CodigoPostal( "12345" )
      :Poblacion( "CIUDAD DEL ACREEDOR #1" )
      :Provincia( "PROVINCIA DEL ACREEDOR #1" )
      :Pais( "ES" )
      :Nif( "E77846772" )
      :CuentaIBAN( "ES7600811234461234567890" )   
   end with

   // Dudor--------------------------------------------------------------------

   with object ( oCuaderno:InsertDeudor() )
      :Referencia( 'RECIBO002401' )
      :ReferenciaMandato( '2E5F9458BCD27E3C2B5908AF0B91551A' )
      :Importe( 123.45 )
      :EntidadBIC( 'CAIXESBBXXX' )
      :Nombre( 'NOMBRE DEL DEUDOR, S.L.' )
      :Direccion( "CALLE DEL DEUDOR, 1234" )
      :CodigoPostal( "12345" )
      :Poblacion( "CIUDAD DEL DEUDOR" )
      :Provincia( "PROVINCIA DEL DEUDOR" )
      :Pais( "ES" )
      :Nif( "12345678Z" )
      :CuentaIBAN( "ES0321001234561234567890" )
      :Concepto( 'CONCEPTO DEL ADEUDO FRA.1234' )
   end with

   with object ( oCuaderno:InsertDeudor() )
      :Referencia( 'RECIBO002401' )
      :ReferenciaMandato( '2E5F9458BCD27E3C2B5908AF0B91551A' )
      :Importe( 123.45 )
      :EntidadBIC( 'CAIXESBBXXX' )
      :Nombre( 'NOMBRE DEL DEUDOR, S.L.' )
      :Direccion( "CALLE DEL DEUDOR, 1234" )
      :CodigoPostal( "12345" )
      :Poblacion( "CIUDAD DEL DEUDOR" )
      :Provincia( "PROVINCIA DEL DEUDOR" )
      :Pais( "ES" )
      :Nif( "12345678Z" )
      :CuentaIBAN( "ES0321001234561234567890" )
      :Concepto( 'CONCEPTO DEL ADEUDO FRA.1234' )
   end with

   // Acreedor 2-----------------------------------------------------------------

   with object ( oCuaderno:InsertAcreedor() )
      :FechaCobro( Ctod( "17/01/1968" ) )
      :Nombre( "NOMBRE DEL ACREEDOR #2, S.L." )
      :Direccion( "CALLE DEL ACREEDOR #2, 1234" )
      :CodigoPostal( "12345" )
      :Poblacion( "CIUDAD DEL ACREEDOR #2" )
      :Provincia( "PROVINCIA DEL ACREEDOR #2" )
      :Pais( "ES" )
      :Nif( "E77846772" )
      :CuentaIBAN( "ES7600811234461234567890" )   
   end with

   // Dudor--------------------------------------------------------------------

   with object ( oCuaderno:InsertDeudor() )
      :Referencia( 'RECIBO002401' )
      :ReferenciaMandato( '2E5F9458BCD27E3C2B5908AF0B91551A' )
      :Importe( 123.45 )
      :EntidadBIC( 'CAIXESBBXXX' )
      :Nombre( 'NOMBRE DEL DEUDOR, S.L.' )
      :Direccion( "CALLE DEL DEUDOR, 1234" )
      :CodigoPostal( "12345" )
      :Poblacion( "CIUDAD DEL DEUDOR" )
      :Provincia( "PROVINCIA DEL DEUDOR" )
      :Pais( "ES" )
      :Nif( "12345678Z" )
      :CuentaIBAN( "ES0321001234561234567890" )
      :Concepto( 'CONCEPTO DEL ADEUDO FRA.1234' )
   end with

   with object ( oCuaderno:InsertDeudor() )
      :Referencia( 'RECIBO002401' )
      :ReferenciaMandato( '2E5F9458BCD27E3C2B5908AF0B91551A' )
      :Importe( 123.45 )
      :EntidadBIC( 'CAIXESBBXXX' )
      :Nombre( 'NOMBRE DEL DEUDOR, S.L.' )
      :Direccion( "CALLE DEL DEUDOR, 1234" )
      :CodigoPostal( "12345" )
      :Poblacion( "CIUDAD DEL DEUDOR" )
      :Provincia( "PROVINCIA DEL DEUDOR" )
      :Pais( "ES" )
      :Nif( "12345678Z" )
      :CuentaIBAN( "ES0321001234561234567890" )
      :Concepto( 'CONCEPTO DEL ADEUDO FRA.1234' )
   end with

   oCuaderno:SerializeASCII()

   WinExec( "notepad.exe " + AllTrim( oCuaderno:cFile ) )

Return ( nil ) 

//---------------------------------------------------------------------------//


