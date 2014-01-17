#include "hbclass.ch"

#define CRLF chr( 13 ) + chr( 10 )

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
      
   local cDateFrm := Set( 4, "yyyy/mm/dd" )
   local strDate  := if( dDate != NIL, dtos( dDate ), dtos( date() ) )
   Set( 4, cDateFrm )

Return( strDate )

//---------------------------------------------------------------------------//

Function GetBic( cEntidad )

   local cDevuelve
   local BIC         := {=>}
   
   BIC[ "0030" ]     := 'ESPCESMMXXX'
   BIC[ "2100" ]     := 'CAIXESBBXXX'
   BIC[ "0073" ]     := 'OPENESMMXXX'
   BIC[ "0083" ]     := 'RENBESMMXXX'
   BIC[ "0122" ]     := 'CITIES2XXXX'
   BIC[ "0186" ]     := 'BFIVESBBXXX'
   BIC[ "0200" ]     := 'PRVBESB1XXX'
   BIC[ "0224" ]     := 'SCFBESMMXXX'
   BIC[ "1545" ]     := 'AGRIESMMXXX'
   BIC[ "0049" ]     := 'BSCHESMMXXX'
   BIC[ "0036" ]     := 'SABNESMMXXX'
   BIC[ "0086" ]     := 'NORTESMMXXX'
   BIC[ "0061" ]     := 'BMARES2MXXX'
   BIC[ "0065" ]     := 'BARCESMMXXX'
   BIC[ "0075" ]     := 'POPUESMMXXX'
   BIC[ "0003" ]     := 'BDEPESM1XXX'
   BIC[ "0072" ]     := 'PSTRESMMXXX'
   BIC[ "0216" ]     := 'POHIESMMXXX'
   BIC[ "0229" ]     := 'POPLESMMXXX'
   BIC[ "0233" ]     := 'POPIESMMXXX'
   BIC[ "1459" ]     := 'PRABESMMXXX'
   BIC[ "0081" ]     := 'BSABESBBXXX'
   BIC[ "0231" ]     := 'DSBLESMMXXX'
   BIC[ "0093" ]     := 'VALEESVVXXX'
   BIC[ "0128" ]     := 'BKBKESMMXXX'
   BIC[ "0182" ]     := 'BBVAESMMXXX'
   BIC[ "0057" ]     := 'BVADESMMXXX'
   BIC[ "0058" ]     := 'BNPAESMMXXX'
   BIC[ "0130" ]     := 'CGDIESMMXXX'
   BIC[ "0136" ]     := 'AREBESMMXXX'
   BIC[ "0149" ]     := 'BNPAESMSXXX'
   BIC[ "0196" ]     := 'WELAESMMXXX'
   BIC[ "0219" ]     := 'BMCEESMMXXX'
   BIC[ "0220" ]     := 'FIOFESM1XXX'
   BIC[ "0227" ]     := 'UNOEESM1XXX'
   BIC[ "0236" ]     := 'LOYIESMMXXX'
   BIC[ "1460" ]     := 'CRESESMMXXX'
   BIC[ "1534" ]     := 'KBLXESMMXXX'
   BIC[ "1544" ]     := 'BACAESMMXXX'
   BIC[ "2107" ]     := 'BBVAESMM107'
   BIC[ "0198" ]     := 'BCOEESMMXXX'
   BIC[ "0094" ]     := 'BVALESMMXXX'
   BIC[ "0184" ]     := 'BEDFESM1XXX'
   BIC[ "0188" ]     := 'ALCLESMMXXX'
   BIC[ "0235" ]     := 'PICHESMMXXX'
   BIC[ "1490" ]     := 'SELFESMMXXX'
   BIC[ "1491" ]     := 'TRIOESMMXXX'
   BIC[ "3001" ]     := 'BCOEESMM001'
   BIC[ "3005" ]     := 'BCOEESMM005'
   BIC[ "3007" ]     := 'BCOEESMM007'
   BIC[ "3008" ]     := 'BCOEESMM008'
   BIC[ "3009" ]     := 'BCOEESMM009'
   BIC[ "3016" ]     := 'BCOEESMM016'
   BIC[ "3017" ]     := 'BCOEESMM017'
   BIC[ "3018" ]     := 'BCOEESMM018'
   BIC[ "3020" ]     := 'BCOEESMM020'
   BIC[ "3023" ]     := 'BCOEESMM023'
   BIC[ "3059" ]     := 'BCOEESMM059'
   BIC[ "3060" ]     := 'BCOEESMM060'
   BIC[ "3063" ]     := 'BCOEESMM063'
   BIC[ "3067" ]     := 'BCOEESMM067'
   BIC[ "3070" ]     := 'BCOEESMM070'
   BIC[ "3076" ]     := 'BCOEESMM076'
   BIC[ "3080" ]     := 'BCOEESMM080'
   BIC[ "3081" ]     := 'BCOEESMM081'
   BIC[ "3085" ]     := 'BCOEESMM085'
   BIC[ "3089" ]     := 'BCOEESMM089'
   BIC[ "3096" ]     := 'BCOEESMM096'
   BIC[ "3098" ]     := 'BCOEESMM098'
   BIC[ "3104" ]     := 'BCOEESMM104'
   BIC[ "3111" ]     := 'BCOEESMM111'
   BIC[ "3113" ]     := 'BCOEESMM113'
   BIC[ "3115" ]     := 'BCOEESMM115'
   BIC[ "3116" ]     := 'BCOEESMM116'
   BIC[ "3117" ]     := 'BCOEESMM117'
   BIC[ "3127" ]     := 'BCOEESMM127'
   BIC[ "3130" ]     := 'BCOEESMM130'
   BIC[ "3134" ]     := 'BCOEESMM134'
   BIC[ "3138" ]     := 'BCOEESMM138'
   BIC[ "3144" ]     := 'BCOEESMM144'
   BIC[ "3146" ]     := 'CCCVESM1XXX'
   BIC[ "3150" ]     := 'BCOEESMM150'
   BIC[ "3159" ]     := 'BCOEESMM159'
   BIC[ "3162" ]     := 'BCOEESMM162'
   BIC[ "3166" ]     := 'BCOEESMM166'
   BIC[ "3174" ]     := 'BCOEESMM174'
   BIC[ "3187" ]     := 'BCOEESMM187'
   BIC[ "3190" ]     := 'BCOEESMM190'
   BIC[ "3191" ]     := 'BCOEESMM191'
   BIC[ "2000" ]     := 'CECAESMMXXX'
   BIC[ "0125" ]     := 'BAOFESM1XXX'
   BIC[ "0138" ]     := 'BKOAES22XXX'
   BIC[ "0211" ]     := 'PROAESMMXXX'
   BIC[ "0487" ]     := 'GBMNESMMXXX'
   BIC[ "1474" ]     := 'CITIESMXXXX'
   BIC[ "1480" ]     := 'VOWAES21XXX'
   BIC[ "2010" ]     := 'CECAESMM010'
   BIC[ "2017" ]     := 'CECAESMM017'
   BIC[ "2031" ]     := 'CECAESMM031'
   BIC[ "2043" ]     := 'CECAESMM043'
   BIC[ "2045" ]     := 'CECAESMM045'
   BIC[ "2048" ]     := 'CECAESMM048'
   BIC[ "2051" ]     := 'CECAESMM051'
   BIC[ "2056" ]     := 'CECAESMM056'
   BIC[ "2066" ]     := 'CECAESMM066'
   BIC[ "2080" ]     := 'CAGLESMMXXX'
   BIC[ "2081" ]     := 'CECAESMM081'
   BIC[ "2086" ]     := 'CECAESMM086'
   BIC[ "2096" ]     := 'CSPAES2LXXX'
   BIC[ "2099" ]     := 'CECAESMM099'
   BIC[ "2103" ]     := 'UCJAES2MXXX'
   BIC[ "2104" ]     := 'CSSOES2SXXX'
   BIC[ "2105" ]     := 'CECAESMM105'
   BIC[ "2013" ]     := 'CESCESBBXXX'
   BIC[ "2038" ]     := 'CAHMESMMXXX'
   BIC[ "0099" ]     := 'AHCRESVVXXX'
   BIC[ "0232" ]     := 'INVLESMMXXX'
   BIC[ "2085" ]     := 'CAZRES2ZXXX'
   BIC[ "2095" ]     := 'BASKES2BXXX'
   BIC[ "0059" ]     := 'MADRESMMXXX'
   BIC[ "0237" ]     := 'CSURES2CXXX'
   BIC[ "0133" ]     := 'MIKBESB1XXX'
   BIC[ "3058" ]     := 'CCRIES2AXXX'
   BIC[ "0046" ]     := 'GALEES2GXXX'
   BIC[ "0031" ]     := 'ETCHES2GXXX'
   BIC[ "0078" ]     := 'BAPUES22XXX'
   BIC[ "0160" ]     := 'BOTKESMXXXX'
   BIC[ "0234" ]     := 'CCOCESMMXXX'
   BIC[ "1465" ]     := 'INGDESMMXXX'
   BIC[ "1475" ]     := 'CCSEESM1XXX'
   BIC[ "3025" ]     := 'CDENESBBXXX'
   BIC[ "3029" ]     := 'CCRIES2A029'
   BIC[ "3035" ]     := 'CLPEES2MXXX'
   BIC[ "3045" ]     := 'CCRIES2A045'
   BIC[ "3084" ]     := 'CVRVES2BXXX'
   BIC[ "3095" ]     := 'CCRIES2A095'
   BIC[ "3102" ]     := 'BCOEESMM102'
   BIC[ "3105" ]     := 'CCRIES2A105'
   BIC[ "3110" ]     := 'BCOEESMM110'
   BIC[ "3112" ]     := 'CCRIES2A112'
   BIC[ "3118" ]     := 'CCRIES2A118'
   BIC[ "3119" ]     := 'CCRIES2A119'
   BIC[ "3121" ]     := 'CCRIES2A121'
   BIC[ "3123" ]     := 'CCRIES2A123'
   BIC[ "3135" ]     := 'CCRIES2A135'
   BIC[ "3137" ]     := 'CCRIES2A137'
   BIC[ "3140" ]     := 'BCOEESMM140'
   BIC[ "3152" ]     := 'CCRIES2A152'
   BIC[ "3157" ]     := 'CCRIES2A157'
   BIC[ "3160" ]     := 'CCRIES2A160'
   BIC[ "3165" ]     := 'CCRIES2A165'
   BIC[ "3177" ]     := 'BCOEESMM177'
   BIC[ "3179" ]     := 'CCRIES2A179'
   BIC[ "3183" ]     := 'CASDESBBXXX'
   BIC[ "3186" ]     := 'CCRIES2A186'
   BIC[ "3188" ]     := 'CCRIES2A188'
   BIC[ "9000" ]     := 'ESPBESMMXXX'

   TRY
      cDevuelve      := BIC[ cEntidad ]
   CATCH
      cDevuelve      := space(10)
   END

Return cDevuelve

//----------------------------------------------------------------//
 
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

   METHOD CodigoRegistro()                INLINE ( '99' )

   METHOD TotalImporte()                  INLINE ( ::oPresentador:TotalImporte() )
   METHOD TotalRegistros()                INLINE ( strzero( ::oPresentador:nTotalRegistros() ) )
   METHOD TotalFinalRegistros()           INLINE ( strzero( ::oPresentador:nTotalRegistros() + 5, 10 ) )

   METHOD New()
   METHOD WriteASCII()

   METHOD SerializeASCII()

ENDCLASS

   //------------------------------------------------------------------------//

   METHOD New() CLASS Cuaderno1914

      ::oPresentador    := Presentador():New( Self )

   Return ( Self )

   //------------------------------------------------------------------------//

   METHOD WriteASCII()

      ::hFile  := fCreate( ::cFile )

      if !Empty( ::hFile )
         fWrite( ::hFile, ::SerializeASCII() )
         fClose( ::hFile )
      end if

   Return ( Self )

   //------------------------------------------------------------------------//

   METHOD SerializeASCII() CLASS Cuaderno1914

      local cBuffer     := ""

      cBuffer           := ::GetPresentador():SerializeASCII()

      cBuffer           += ::CodigoRegistro()
      cBuffer           += ::TotalImporte() 
      cBuffer           += ::TotalRegistros() 
      cBuffer           += ::TotalFinalRegistros()

   Return ( cBuffer )

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
      cBuffer        += padr( '', 520 ) + CRLF 

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

   METHOD CodigoRegistro()       INLINE ( '02' )
   METHOD CodigoRegistroTotal()  INLINE ( '04' )
   METHOD Dato()                 INLINE ( '002' )

   METHOD GetDeudor()            INLINE ( atail( ::aChild ) )
   METHOD InsertDeudor()         INLINE ( aadd( ::aChild, Deudor():New( Self ) ), ::GetDeudor() )

   METHOD TotalFinalRegistros()  INLINE ( strzero( ::nTotalRegistros() + 2, 10 ) )

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
   METHOD ReferenciaMandato( cValue )     INLINE ( if( !Empty( cValue ), ::cReferenciaMandato   := padr( hb_md5( cValue ), 35 ), ::cReferenciaMandato ) )
   METHOD TipoAdeudo( cValue )            INLINE ( if( !Empty( cValue ), ::cTipoAdeudo          := padr( cValue, 4 ),            ::cTipoAdeudo ) )
   METHOD Categoria( cValue )             INLINE ( if( !Empty( cValue ), ::cCategoria           := padr( cValue, 4 ),            ::cCategoria ) )
   METHOD FechaMandato( dValue )          INLINE ( if( !Empty( dValue ), ::cFechaMandato        := DateToString( dValue ),       ::cFechaMandato ) )
   METHOD EntidadBIC( cValue )            INLINE ( if( !Empty( cValue ), ::cEntidadBIC          := padr( cValue, 11 ),           ::cEntidadBIC ) )
   METHOD Tipo( cValue )                  INLINE ( if( !Empty( cValue ), ::cTipo                := padr( cValue, 1 ),            ::cTipo ) )
   METHOD Emisor( cValue )                INLINE ( if( !Empty( cValue ), ::cEmisor              := padr( cValue, 35 ),           ::cEmisor ) )
   METHOD IdentificadorCuenta( cValue )   INLINE ( if( !Empty( cValue ), ::cIdentificadorCuenta := padr( cValue, 1 ),            ::cIdentificadorCuenta ) )
   METHOD Proposito( cValue )             INLINE ( if( !Empty( cValue ), ::cProposito           := padr( cValue, 4 ),            ::cProposito ) )
   METHOD Concepto( cValue )              INLINE ( if( !Empty( cValue ), ::cConcepto            := padr( cValue, 140 ),          ::cConcepto ) )

   METHOD CodigoRegistro()                INLINE ( '03' )
   METHOD Dato()                          INLINE ( '003' )

   METHOD nTotalRegistros()               INLINE ( 1 )
   METHOD nTotalImporte()                 INLINE ( ::nImporte )

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
/*
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
*/
Return ( nil ) 

//---------------------------------------------------------------------------//


