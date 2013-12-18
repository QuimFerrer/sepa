/* v.1.0 18/12/2013
 * Clase Harbour para formatos AEB 19.14 Adeudos Directos y AEB 19.44 B2B
 * (c) Manuel Calero Solis <mcalero@gestool.es>
 * Valido para periodo transitorio Noviembre 2010 / Enero 2016 (formato texto)
 */

#include "hbclass.ch"

#define CRLF chr( 13 ) + chr( 10 )

static function DecimalToString(nValue, nLen)   ; return( Dec2Str(nValue, nLen) )

static function TimeToString()                  ; return( cTime() )                         

static function DateToString(dDate)             ; return( fDate(dDate) )
      

//---------------------------------------------------------------------------//

CLASS Cuaderno

   DATA cFile                             INIT "prueba.txt" 
   DATA hFile 
   DATA cFechaCreacion                    INIT DateToString()

   METHOD Fichero( cValue )               INLINE ( if( !Empty( cValue ), ::cFile             := cValue,                 ::cFile ) )
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
   METHOD TotalFinalRegistros()  INLINE ( strzero( ::nTotalRegistros() + 3, 10 ) )

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

   DATA cDireccion               INIT Space( 50 )      
   DATA cCodigoPostal            INIT Space( 10 )
   DATA cPoblacion               INIT Space( 60 )       
   DATA cProvincia               INIT Space( 40 )      
   DATA cCuentaIBAN              INIT Space( 34 )
   DATA cFechaCobro              INIT DateToString()

   DATA aChild                   INIT {}

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

   METHOD Referencia( cValue )            INLINE ( if( !Empty( cValue ), ::cReferencia          := padr( cValue, 35 ),           ::cReferencia ) )
   METHOD ReferenciaMandato( cValue )     INLINE ( if( !Empty( cValue ), ::cReferenciaMandato   := hb_md5( padr( cValue, 35 ) ), ::cReferenciaMandato ) )
   METHOD TipoAdeudo( cValue )            INLINE ( if( !Empty( cValue ), ::cTipoAdeudo          := padr( cValue, 4 ),            ::cTipoAdeudo ) )
   METHOD Categoria( cValue )             INLINE ( if( !Empty( cValue ), ::cCategoria           := padr( cValue, 4 ),            ::cCategoria ) )
   METHOD FechaMandato( dValue )          INLINE ( if( !Empty( dValue ), ::cFechaMandato        := DateToString( dValue ),       ::cFechaMandato ) )
   METHOD EntidadBIC( cValue )            INLINE ( if( !Empty( cValue ), ::cEntidadBIC          := padr( cValue, 11 ),           ::cEntidadBIC ) )
   METHOD Tipo( cValue )                  INLINE ( if( !Empty( cValue ), ::cTipo                := padr( cValue, 1 ),            ::cTipo ) )
   METHOD Emisor( cValue )                INLINE ( if( !Empty( cValue ), ::cEmisor              := padr( cValue, 35 ),           ::cEmisor ) )
   METHOD IdentificadorCuenta( cValue )   INLINE ( if( !Empty( cValue ), ::cIdentificadorCuenta := padr( cValue, 1 ),            ::cIdentificadorCuenta ) )
   METHOD Proposito( cValue )             INLINE ( if( !Empty( cValue ), ::cProposito           := padr( cValue, 4 ),            ::cProposito ) )
   METHOD Concepto( cValue )              INLINE ( if( !Empty( cValue ), ::cConcepto            := padr( cValue, 140 ),          ::cConcepto ) )

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