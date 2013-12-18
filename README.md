<h1>SEPA para Harbour</h1>
<h3>Generación de ficheros para normas AEB (Asociación Española de Banca) 
adaptadas a SEPA (Single Euro Payments Area), formatos texto (*) y XML<h3>
<h4>(*)Para periodo transitorio hasta 31-Enero-2016</h4>
=====================================================================
<ul>
<li><em>aeb1914 </em>Adeudos Directos CORE Direct Debit (para particulares)</li>
<li><em>aeb1944 </em>Adeudos Directos B2B Direct Debit (entre empresas)</li>
<li><em>aeb3414 </em>Ordenes en fichero para emision de transferencias y cheques en euros (formato texto).</li>
<li><em>Cuaderno</em> es un embrión de clase OOPS para Harbour, para encapsulación de todas las normas.</li>
<li><em>xmlCT   </em>Ordenes en fichero para emision de transferencias y cheques en euros (formato XML).</li>
</ul>

Otra documentación 
------------------
<ul>
<li>./data Ficheros DBF con los codigos BIC para entidades bancarias españolas y europeas.</li> 
<li>./doc  Ficheros PDF de las normas AEB utilizados en esta implementación y ultimas novedades SEPA Boletin BBVA</li>
</ul>

Notas
-----
Cada norma dispone de su propio directorio de trabajo y utiliza <em>sepamisc.prg</em> del directorio raiz, a modo de 
libreria de funciones misceláneas, comunes a todas las normas. 

Se ha desarrollado pensando en la implementación más simple, para que pueda ser fácilmente trasladable a otros
paradigmas (OOPS, arrays asociativos) e incluso a otros lenguajes (PHP, Java... )


Construccion y entorno
----------------------
Cada norma dispone de <em>c.bat</em> para automatizar la creación del ejecutable, que no es más que una llamada
simplificada a la utilidad make hbmk2 de harbour.
Para establecer variables de entorno de compilacion, adaptar y/o ejecutar <em>cset.bat</em> 

Sugerencias y mejoras serán bienvenidas :)
Que lo disfruten !

(c)2013 Joaquim Ferrer
<quim_ferrer@yahoo.es>
<code>No es que tengamos poco tiempo, sino que perdemos mucho (Séneca)</code>
