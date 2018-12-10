<h1>SEPA para Harbour</h1>
<h3>Generación de ficheros para normas AEB (Asociación Española de Banca) 
adaptadas a SEPA (Single Euro Payments Area), formatos XML y texto *<h3>
<p>* Para periodo transitorio hasta 31-Enero-2016</hp>
===============================================================
<ul>
<li><em>SepaXML </em>Adeudos directos (CORE, COR1 y B2B) y transferencias (formato XML)</li>
<li><em>aeb1914 </em>Adeudos Directos CORE Direct Debit (para particulares)</li>
<li><em>aeb1944 </em>Adeudos Directos B2B Direct Debit (entre empresas)</li>
<li><em>aeb3414 </em>Ordenes en fichero para emision de transferencias y cheques en euros (formato texto).</li>
<li><em>Cuaderno</em> es un embrión de clase OOPS para Harbour, para encapsulación de todas las normas.</li>
<li><em>xmlCT   </em>Ordenes en fichero para emision de transferencias y cheques en euros (formato XML) *</li>
</ul>
<p>* A unificar con SepaXML</p>

Otra documentación 
------------------
<ul>
<li>./data Ficheros DBF con los codigos BIC para entidades bancarias españolas y europeas.</li> 
<li>./doc  Ficheros PDF de las normas AEB utilizados en esta implementación y ultimas novedades SEPA Boletin BBVA</li>
</ul>

Calculo de Identificador del acreedor
-------------------------------------
<a href="http://inza.wordpress.com/2013/10/25/como-preparar-los-mandatos-sepa-identificador-del-acreedor/">SEPA – Identificador del acreedor
</a>

Uno de los datos importantes del mandato SEPA es el “identificador del acreedor” o “creditor Identifier” que tiene una regla de construcción un poco enrevesada en cuanto al cálculo del código de control.

En España el formato es este: ESZZXXXAAAAAAAAA, siendo:
<ul>
<li>ES: código del país España según la norma ISO 3166</li>
<li>ZZ: dígitos de control (cuyo cálculo se explica a continuación)</li>
<li>XXX: sufijo (normalmente 000, pero el acreedor puede gestionar más de un canal de adeudos poniendo otros valores)</li>
<li>AAAAAAAAA: CIF del acreedor, frecuentemente una letra seguida de 8 cifras, sin espacios, guiones u otros símbolos.</li>
</ul>
Los dígitos de control se calculan en base al NIF, aplicando el modelo 97-10 (regla de cálculo definida en la norma ISO 7604 y ampliamente usada en la norma ISO 20022, UNIFI).
<ul>
	<li>Tomamos posiciones de la 8 a la 15, es decir el CIF, añadiendo ES y 00<br>
		Por ejemplo, en el caso de EADTrust, B85626240ES00</li>
	<li>Convertimos letras a números, considerando que la A es 10, la B es 11, … la E es 14, … la  S es 28, … hasta que la Z es 35.<br>
		Por ejemplo, en el caso de EADTrust, 1185626240142800</li>
	<li>Aplicamos modelo 97-10 (dado un número, lo dividimos entre 97 y restamos a 98 el resto de la operación. Si se obtiene un único dígito, se completa con un cero a la izquierda)<br>
		Por ejemplo, <br>en el caso de EADTrust, el resto de dividir 1185626240142800 entre 97 sale 21 y 98-21=77,<br> por tanto el código completo:  ES77000B85626240</li>
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
