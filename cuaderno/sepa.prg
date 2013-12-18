/* v.1.0 18/12/2013
 * Test de la clase Cuaderno, para formatos AEB 19.14 Adeudos Directos y AEB 19.44 B2B
 * (c) Manuel Calero Solis <mcalero@gestool.es>
 * Valido para periodo transitorio Noviembre 2010 / Enero 2016
 */

function main()

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

   // Deudor--------------------------------------------------------------------

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

   // Deudor--------------------------------------------------------------------

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

   __Run( "notepad.exe " + AllTrim( oCuaderno:cFile ) )

return ( nil ) 

//---------------------------------------------------------------------------//


