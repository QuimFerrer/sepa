<h1>SEPA</h1>
<h3>Generación de ficheros para normas AEB (Asociación Española de Banca) 
adaptadas a SEPA (Single Euro Payments Area), en formato texto
Para periodo transitorio hasta 31-Enero-2016</h3>
=====================================================================
<ul>
<li>./aeb1914 Adeudos Directos CORE Direct Debit (para particulares)</li>
<li>./aeb1944 Adeudos Directos B2B Direct Debit (entre empresas)</li>
<li>./aeb3414 Ordenes en fichero para emision de transferencias y cheques en euros.</li>
</ul>
Notas
-----
Cada norma dispone de su propio directorio de trabajo y utiliza sepamisc.prg del directorio raiz, a modo de 
libreria de funciones misceláneas, comunes a todas las normas. 

Se ha desarrollado pensando en la implementación más simple, para que pueda ser fácilmente trasladable a otros
paradigmas (OOPS, arrays asociativos) e incluso a otros lenguajes (PHP, Java... )

hbSepa.prg es un embrión de clase OOPS para Harbour, para encapsulación de todas las normas.


Construccion y entorno
----------------------
Cada norma dispone de c.bat para automatizar la creación del ejecutable, que no es más que una llamada
simplificada a la utilidad make hbmk2 de harbour.
Para establecer variables de entorno de compilacion, adaptar y/o ejecutar cset.bat 


Otra documentación 
------------------
<ul>
<li>./data Ficheros DBF con los codigos BIC para entidades bancarias españolas y europeas.</li> 
<li>./doc  Ficheros PDF de las normas AEB utilizados en esta implementación y ultimas novedades SEPA Boletin BBVA</li>
</ul>

Sugerencias y mejoras serán bienvenidas :)
Que lo disfruten !

(c)2013 Joaquim Ferrer
<quim_ferrer@yahoo.es>
"No es que tengamos poco tiempo, sino que perdemos mucho" (Séneca)
