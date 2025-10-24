#set page(
  paper: "a4",
)

#set par(justify: true)

#set heading(
  numbering: "1."
)

#set text(
  lang: "es",
  size: 11pt,
)

#set enum(numbering: "1.i")
/*
*
* SHOW RULES
*
*/

#show figure.caption: emph
#show regex("br_\w+"): emph


#align(center + top)[
  #image("images/unizar.png", width: 70%)

  #smallcaps[Universidad De Zaragoza]
  #line(length: 100%)
  #smallcaps[Trabajo De Fin De Grado]
  #v(1fr)

  *Despliegue de una federación cloud: instanciación, presentación de recursos, gestión de la
pertenencia y monitorización y recuperación ante desastres*
  \
  \
  *Deployment of a cloud federation: instantiation, resource submission, membership management
and monitoring and disaster recovery.*

  #v(1fr)

  #smallcaps[Lucas Cauhé Viñao]
  \
  \
  #grid(
    columns: 2,
    gutter: 10pt,
    align: right,
    text[Director:],
    text[Eduardo Tomás Fiat Gracia],
    text[Ponente:],
    text[Unai Arronategui Arribalzaga],
  )

  #v(1fr)
  Grado en Ingeniería Informática
  \
  Computación
  \
  \
  2025
  #v(1fr)

  #pagebreak()
]

#pagebreak()
#counter(page).update(1)

#set page(numbering: "I")

#heading(outlined: false, numbering: none)[Resumen]


#pagebreak()


#heading(outlined: false, numbering: none)[Glosario]
#let glossary = (
  bridge-huerfano: (
    term: "Bridge huérfano",
    definition: [Interfaz _bridge_ sin interfaz física como _master_.],
    label: <bridge-huerfano>,
    idx: 1
  ),
  trunk: (
    term: "Trunk",
    definition: [En el contexto de interfaces de red que dejan pasar tráfico de VLAN, capacidad de la interfaz para transmitir más de una VLAN.],
    label: <trunk>,
    idx: 2
  ),
  ceph-pool: (
    term: "pool Ceph",
    definition: [Agrupación lógica de un conjunto de objetos RADOS sobre la que se aplican un conjunto de reglas de replicación y mantienen los datos distribuidos con el uso de _placement groups_.],
    label: <ceph-pool>,
    idx: 3
  ),
)

#let gl(key) = {
  let entry = glossary.at(key)
  link(entry.label)[#emph[#lower(entry.term)#super[#entry.idx]]]
}

#for (key, entry) in glossary [
  *#entry.term:*#entry.label #entry.definition \
]

#pagebreak()


#heading(outlined: false, numbering: none)[Conceptos]
#let concepts = (
  ha: (
    term: "HA",
    definition: [Alta Disponibilidad. Característica de un sistema que asegura un cierto rendimiento, normalmente de \"Tiempo en línea\", por un periodo de tiempo más extenso al normal.],
    label: <ha>,
    idx: 1
  ),
  confianza: (
    term: "Confianza",
    definition: [Interfaz _bridge_ sin interfaz física como _master_.],
    label: <trust>,
    idx: 2
  ),
  iac: (
    term: "IaC",
    definition: [Ifraestructura como código (del inglés _Infrastructure as code_). Proceso de gestión y aprovisionamiento de recursos informáticos en una infraestructura cloud, a través de ficheros de de definición interpretables por una máquina.],
    label: <iac>,
    idx: 3
  ),
  overcommitment: (
    term: "sobreaproisionmiento",
    definition: [.],
    label: <overcommitment>,
    idx: 4
  ),
)

#let conc(key) = {
  let entry = concepts.at(key)
  link(entry.label)[#emph[#lower(entry.term)#super[#entry.idx]]]
}

#for (key, entry) in concepts [
  *#entry.term:*#entry.label #entry.definition \
]

#pagebreak()

#outline()
#pagebreak()
/*
*
* INTRODUCCION
*
*/

#counter(page).update(1)
#set page(numbering: "1")
= Introducción

== Contexto
El SICUZ es el departamento de Servicios de Informática y Comunicaciones de la Universidad de Zaragoza. Encargado de mantener la operativa informática y la infraestrucutra que le da soporte. En este contexto, la gestión de un cloud privado permite controlar la información y servicios ofrecidos desde la Universidad.

En este departamento se está implementando un proyecto de colaboración interuniversitario, donde infraestructura en distintas universidades forman un clúster que da soporte a una instancia cloud de _OpenNebula_. Esto supone homogeneizar la infraestructura (almacenamiento, red y cómputo) para que cada universidad ofrezca y reciba rendimientos similares.

A nivel de aplicación y gestión de usuarios, la confianza entre los miembros del clúster se establece de palabra y siguiendo una serie de buenas prácticas establecidas de forma general.

Así, se ha contemplado la idea de federar cada uno de los cloud privados de cada universidad, permitiendo una gestión abstracta y establecida mediante políticas sobre el uso y recursos presentados.

== Motivación y alcance
TODO

El uso de una federación cloud permite tener una gestión local de la infraestructura y compartida de la información de usuarios. Así, el nivel de confianza entre las entidades federadas rige el control de acceso a los recursos presentados.

== Estudio del arte
TODO

== Objetivos

TODO \
El objetivo principal del proyecto es establecer una federación entre 2 instancias de OpenNebula usando Ceph como sistema de almacenamiento distribuido. Se dará una solución de recuperación ante desastres para los recursos de la federación, siendo estos: sistemas de ficheros (de máquinas virtuales, de configuración y estado de la federación), estado de máquinas virtuales y catálogo de servicios de la federación (imágenes persistentes del Marketplace privado de OpenNebula). Por último, se especificarán las políticas de gobernanza básicas que afectaran al uso y los recursos de la federación y un sistema de monitorización y control de accesos que valide las políticas definidas.

Para ello, primero se desarrollará la infraestructura que dé soporte a las instancias cloud. El diseño de la infraestructura deberá considerar la tolerancia a fallos y alta disponibilidad. El despliegue de la infraestructura (red y almacenamiento local de los servidores implicados, 2 instancias de OpenNebula, 2 instancias de Ceph) y federación de las entidades será automático.

Las políticas definidas deberán cubrir el uso y control de acceso a los servicios de la federación por parte de los usuarios de las entidades federadas. Habrá un sistema de monitorización y otro de validación de las políticas, que dado un servicio y su uso deseado, dictará si se permite o no el uso del servicio.

La recuperación ante desastres deberá cumplir las políticas establecidas, ya que será un servicio más de la federación. El despliegue de los recursos cloud de OpenNebula empleados para la recuperación ante desastres será automático mediante alguna herramienta de automatización que integre OpenNebula. El tipo de datos almacenados en este proceso será de objetos ya que responden a la naturaleza del problema: múltiples lecturas, única escritura y recuperación del objeto del medio rápida. La información almacenada deberá estar disponible para todas las entidades en cualquier momento ya que la recuperación de los datos debe ser independiente del estado del servicio de backup en cada entidad.

== Metodología
TODO \


== Organización de la memoria
TODO \
Freestyle


/*
*
* DISEÑO
*
*/

#pagebreak()
= Diseño

== Diseño de la federación
#figure(
  image("images/arquitectura.png", width: 70%),
  caption: [
    Arquitectura del sistema presentado de acuerdo con el modelo del NIST
  ]
) <arch>


La @arch introduce los componentes principales principales del sistema.
El modelo planteado por el NIST establece tres planos de abstracción: confianza, gestión y uso.
La confianza entre entidades se establecerá mediante los protocolos internos de compartición de credenciales de administración de OpenNebula.
En el plano de gestión se hará cumplir con las políticas de gobernanza definidas mediante un sistema de validación.
El plano de uso describe la interacción que habrá entre los usuarios de las distintas entidades con los servicios ofrecidos por la federación.

=== Plano de confianza
El plano de confianza lo forman las instancias de OpenNebula, desplegadas en alta disponibildad cada una de ellas.
La confianza entre ambas entidades se consigue compartiendo las credenciales del usuario administrador _ondeadmin_ de la entidad _maestra_ a la _esclava_. En la @arch la #quote[Entidad 0] es la _maestra_ y la #quote[Entidad 1] la _esclava_.


Aunque Ceph no es estrictamente necesario, su uso es recomendado por ser un estándar en la industria.

=== Plano de gestión
La gestión de la federación estará a cargo de una serie de políticas de gobernanza que controlarán accesos de usuarios a servicios y el comportamiento y rendimiento de los servicios (backup, sistema de validación y máquinas virtuales de usuarios) en ejecución en la federación.

Habrá un sistema de validación en cada entidad federada dotando de alta disponibilidad a este servicio.
Se plantean este servicio en un modo pasivo, es decir, que este sistema dictará si un recurso presentado cumple o con las políticas establecidas y dejará o no desplegarlo consecuentemente.
En el caso de que se plantease activo, el sistema debería ser capaz de aplicar los cambios necesarios al recurso para que cumpla con las políticas.
Se ha escogido el modelo pasivo por claridad y simpleza en el diseño y viabilidad técnica en tiempo y forma en su implementación.

Los ficheros que describan las políticas se almacenarán en un sistema accesible desde el sistema de validación y será independiente de la solución de almacenamiento escogida.



Sistema de monitorización

=== Plano de uso

El plano de uso viene definido por dos componentes: usuarios y catálogo de la federación. Los usuarios...

== Diseño de la Infraestructura

Infraestructura real a desplegar.

=== Red


=== Almacenamiento

== Diseño de la Recuperación ante Desastres
El eje central de la recuperación ante desastres será el sistema de backup. Se hablará del backup de la federación más que backup de los componentes que la componen por separado. Así se van a tener una serie de políticas que afecten al backup, como a cualquier otro servicio, y la infraestructura que le dé soporte. Los recursos sobre los que se actuará serán sistemas de ficheros (de máquinas virtuales, configuraciones y estado de la federación y políticas) y estado de las máquinas virtuales de la federación.
Al ser el despliegue de OpenNebula autocontenido, los componentes de este sistema se autogestionarán, haciendo que con la misma configuración se hagan backups de servicios de la federación y de los componentes de OpenNebula.

El servicio de backup y de validación de políticas no almacenan estado por lo que su recuperación ante desastres consistirá en almacenar la configuración de OpenNebula que permita desplegar automáticamente estos servicios cuando se detecte que falta alguno.

#figure(
  image("images/arquitectura-backup.png", width: 70%),
  caption: [
    Arquitectura del servicio de backup para cada entidad
  ]
) <backup-arch>


La @backup-arch destaca el uso de un repositorio backup que contacte con Ceph para el almacenamiento de objetos deseado y el protocolo de comunicación SFTP entre el frontal de OpenNebula y el servicio de backup escogido. Este útlimo es una restricción de OpenNebula para conseguir backups nativos, otra opción hubiese sido desaprovechar la capacidad de definición de tareas de backup nativa de OpenNebula para emplear un protocolo de almacenamiento de objetos como Ceph S3. Con este diseño, se configurará el servicio de backup para que almacene localmente las imágenes de backup de OpenNebula y el sistema de ficheros empleado tendrá contacto con Ceph.


La infraestructura de red que dé soporte al backup en cada entidad es libre pero estará sujeta a los SLA acordados para backup. Para ello se propone una red basada en la tecnología fibre channel, con posibilidad de utilizar FCoE si se cuenta con mecanismos de DCB en la infraestructura interna de la entidad.


/*
*
* IMPLEMENTACIÓN
*
*/
#pagebreak()
= Implementación

La asignación de direcciones a cada uno de los servicios y componentes del sistema se expresa en la @ip-tables.

#figure(
  table(
   columns: (1fr, 1fr, 1fr, 1fr),
   table.header(
    [*Nombre*], [*IP Sistema*], [*IP Pública*], [*IP Interna*]
   ),
  [ Red cluster ceph ], [ 192.168.\<vid\>.0/24 ], [-], [-],
  [ Red replicación ceph ], [ - ], [ - ], [ 192.168.30.0/24 ],
  [ Gateway ], [ 192.168.\<vid\>.254 ], [ 10.88.0.144 ], [-],
  [ Ceph monitor ], [ 192.168.\<vid\>.90-2 ],[-], [-],
  [ Ceph manager ], [ 192.168.\<vid\>.93-4 ],[-], [-],
  [ Ceph OSD ], [ 192.168.\<vid\>.80-2 ],[-], [ 192.168.30.80-2 ],
  [ Ceph MDS ], [ 192.168.\<vid\>.100-3 ],[-], [-],
  [ Frontal OpenNebula ], [ 192.168.\<vid\>.0-2 ],[-], [-],
  [ IP Virtual OpenNebula ], [ 192.168.\<vid\>.10 ],[-], [-],
  [ MariaDB OpenNebula ], [ 192.168.\<vid\>.20-2 ],[-], [-],
  [ MV Backup ], [ 192.168.\<vid\>.55 ],[-], [-],
  [ MV OPA ], [ 192.168.\<vid\>.56 ],[-], [-],
  ),
  caption: [ Asignación de direcciones IP. ],
) <ip-tables>

== Implementación de los servicios de la federación


=== Políticas implementadas

==== Política de nomenclatura
Todas los nombres tendrán como prefijo común el nombre de la entidad seguido por un guión. El @rego muestra un ejemplo de una política de nombrado implementada usando el lenguaje _Rego_.
+ *Nombrado de etiquetas:*<policies-naming-labels> \<nombre-etiqueta\> (ej. one-10-prod)
+ *Nombrado de máquinas virtuales:*<policies-naming-vms> \<nombre-usuario\>-\<nombre-maquina\> (ej. one-10-user10-ntp)
+ *Nombrado de imágenes:* <policies-naming-images> \<nombre-usuario\>-\<nombre-imagen\> (ej. one-10-user10-Ubuntu)
+ *Nombrado de tareas de backup:*<policies-naming-backup> \<prioridad\> (ej. one-10-90)
+ *Nombrado de _hooks_:*<policies-naming-hooks> hook-\<nombre-hook\> (ej. one-10-hook-update-backupjob)

==== Políticas de servicio mínimo

+ *Sistema de monitorización:* Cada entidad contará con un sistema que monitorice la actividad local de OpenNebula.  #[
  + *Punto de enlace*: Definir una IP virtual donde establecer la comunicación de la federación.
  + *Exposición de métricas:* Las métricas se expondrán en formato _JSON_ accesibles desde el punto de enlace definido en la ruta _/metrics_ y su esquema en _/metrics/schema_ que deberá coincidir con el esquema esperado por la federación.
  + *Periodo de monitorización:* Se establecerá una frecuencia de monitorización de 30 segundos.
  + *Control de acceso:* Habrá un grupo de usuarios con permisos, exclusivamente, de consulta de métricas llamado \"fed-exporter\".
]
+ *_Uptime_ (tiempo en línea) de servicios:* 90% de tiempo en línea requerido para cada uno de los servicios etiquetados como producción.
+ *Definición de downtime o caída:* Un servicio se considera caído si no se exportan sus métricas durante un periodo entero y el estado de la máquina virtual en la que se ejecuta en OpenNebula es _ERROR_, _POWEROFF_ o no existe.
+ *Sobreaprovisionamiento:* #[
  + *Rango de sobreaprovisionamiento:*
  + *Etiquetado:* Para incrementar la capacidad de sobreaprovisionar una máquina virtual, se deberá etiquetar como \"comp\" o \"storage\" para poder sobreaprovisionar la máquina por encima del por defecto, impidiendo que servicios que no lo necesiten, hagan un uso indebido (política de _opt-in_).
]
+ *Sobrecarga:* #[
  + Una entidad no podrá desplegar más máquinas virtuales si la utilización de _vCPU_ está por encima del 80%.
  + Una entidad no podrá desplegar más máquinas virtuales cuyas imágenes sean persistentes si el almacenamiento supera el 90%.
]


==== Políticas de backup

+ *Tipo de backup:* Se realizarán backups completos cada 4 incrementales.
+ *Modo de backup:* Si el almacenamiento de un servicio se basa en bloque (bases de datos), se escogerá el modo _CBT_ de OpenNebula para seguir cambios a nivel de bloque. Si un servicio solo interactúa con el sistema de ficheros, se escogerá el modo _snapshot_ con diferenciales de _Copy On Write_.
+ *Proceso de backup:* Si un servicio cuenta con solución de backup integrada, se deberá activar dicha solución antes de empezar el backup desde OpenNebula.

==== Políticas de almacenamiento

+ *Uso de imágenes:* El uso de imágenes persistentes estará restringido a máquinas que solo tengan desplegada una instancia y no haya una imagen persistente ya creada en al que basarse. Se deberá hacer uso de imágenes no persitentes en cualquier otro caso.

==== Políticas de aplicación

+ *Gateways de acceso a Internet:* Toda aplicación debe tener tener conexión a Internet a través de alguna de las puertas de enlace definidas para ese propósito dentro de la federación.
+ *Etiquetado:* Toda aplicación debe estar correctamente etiquetada. Deberá distinguirse si corresponde a un servicio en producción, en desarrollo o pruebas. Para ello emplear los nombres \"prod\", \"dev\" y \"test\".
+ *Replicación mínima:* Las aplicaciones etiquetadas como producción, deberán tener, al menos, 2 instancias en ejecución en entidades federadas distintas.

==== Compatibilidad técnica

Cada entidad debe presentar una instancia de OpenNebula como software de gestión de máquinas virtuales y, opcionalmente, Ceph como sistema de almacenamiento, en su defecto deberá tener un diseño del almacenamiento similar al planteado en la fase de diseño.
Se deberá emplear _KVM_ como hipervisor y _Restic_ como driver del datastore de backup.
El resto de servicios pueden tener una implementación diferente a la presentada en los siguientes apartados.

/*
=== Almacenamiento de las políticas
Se creará un nuevo datastore de OpenNebula de ficheros que almacene las políticas. Tendrá el driver Ceph y se instalará en la máquina virtual donde corra el motor _Open Policy Agent_ para poder cargar los ficheros _Rego_. Todas las instancias de máquinas virtuales corriendo _Open Policy Agent_ tendrán una visión unificada del datastore. Esto se consigue añadiendo en el campo _BRIDGE_LIST_ en la configuración del datastore la dirección IP de cada una de las máquinas que haya en cada zona con el servicio mencionado. Además cada zona deberá tener la configuración que se muestra en el @policies-datastore.

#let policies_datastore_conf = read("fragments/policies_datastore.tmpl")
#figure(
  align(left)[
    #raw(policies_datastore_conf, lang: "text")
  ],
  caption: [ Configuración del datastore de políticas para la zona 10. ]
) <policies-datastore>

*/
=== Sistema de control de accesos y validación de políticas

Para implementar este sistema se ha escogido _OPA_ (_Open Policy Agent_) que es un validador de políticas expresadas en el lenguaje _Rego_. Dado un conjunto de datos de entrada y un archivo con un política expresada en _Rego_, se valida si el conjunto de datos está conforme con la política.

Este servicio ofrece varias opciones de despliegue, siendo la que mejor se ajusta a OpenNebula la opción de contenedores _Docker_. Para ello, se creará una máquina virtual cuya imagen será un _Debian_ no persistente que usarán el backup y esta. Al iniciar la máquina se ejecutará un script que instalará los paquetes necesarios y hará las configuraciones pertinentes. En esta máquina virtual se instalará _Docker_ y desplegará _OPA_.

Primero, se ha definido un nuevo sistema de ficheros en Ceph, _policies_, que se montará en la máquina virtual para que el contenedor pueda acceder a las políticas mediante un volumen. Seguidamente se desplegará el contenedor localmente con exposición en el entorno físico-virtual de la máquina desde el puerto _2345_.

La máquina virtual deberá tener el modo de CPU _host-passthrough_ activo para permitir el uso de contenedores. Para ello, se se tendrá que desactivar el atributo restringido de OpenNebula #emph[VM_RESTRICTED_ARGS=\"RAW/DATA\"]. Se han definido también los siguientes ACL para que los usuarios _backup_ y _policies_ puedan instanciar sus máquinas virtuales.
#emph[oneacl create "@115 VM+NET+IMAGE+TEMPLATE/ * CREATE+USE+MANAGE+ADMIN"]
oneacl create "@114 VM+NET+IMAGE+TEMPLATE/ * CREATE+USE+MANAGE+ADMIN"


#let rego_naming_policy = read("fragments/naming_pol.rego")

#figure(
  align(left)[
    #raw(rego_naming_policy, lang: "text")
  ],
  caption: [ Política de nombrado de máquinas virtuales empleando lenguaje Rego. ]
) <rego>


=== Servicio de monitorización


=== Catálogo de la federación


== Implementación de la Infraestructura

Dado que no se contaba con la infraestructura necesaria para levantar todos los componentes de la infraestructura en distintas máquinas, se ha simulado el entorno real mencionado en el diseño.

El despliegue está basado en contenedores _Podman_. Sabiendo que el backup y el sistema de control de accesos se desplegarían en máquinas virtuales, se ha hecho la infraestructura lo más ligera posible. Cada contenedor se ejecutará en modo no privilegiado aunque se les asignarán las _capabilities_ _NET\_RAW_ y _NET\_ADMIN_ que permitan modificar la red.
Cualquier acceso a dispositivos físicos, en el caso de OSDs o asegurar la persistencia de las bases de datos, se realizado a través de volúmenes con los dispositivos previamente configurados y montados en una ruta específica en el host.

Cada instancia de OpenNebula tendrá como único host de virtualización el mismo servidor donde se despliega. Por ello ha habido que modificar el estado de OpenNebula, a nivel de base de datos, para que una de las instancias comience con un identificador de máquinas virtuales superior (100) al otro.

=== Red <net-impl>


La @red-simulada pretende simular la red descrita en el diseño, teniendo únicamente un servidor.

#figure(
  image("images/infra-simulada.png"),
  caption: [ Infraestructura de red simulada ]
) <red-simulada>

La distinción geográfica entre sedes se consigue mediante _VLANs_, haciendo que los componentes de cada entidad tengan que pasar por el router más cercano para poder comunicarse. Así, las interfaces de cada contenedor han sido configuradas correspondientemente con la _VLAN_ a la que pertenece su servicio.

Para simular la comunicación interna de cada entidad, se han empleado interfaces tipo #gl("bridge-huerfano") que permiten simular el enrutado de capa 2 de un switch.
Hay 4 de estas interfaces: br_ceph, para la red pública Ceph (monitores, _managers_, OSDs y CephFS); br_stor, para la privada de Ceph (red de replicación de OSDs); br_one, la pública de OpenNebula (frontales, base de datos y acceso a la federación); y br_kvm, a la que se acoplan las máquinas virtuales.
La interconexión entre los bridge se ha conseguido mediante interfaces de pares VETH. Así, la figura del router queda para relegada para el acceso a internet o comunicación entre VLAN diferentes.
Cabe destacar que ambas interfaces mencionadas cuentan con la capacidad de #gl("trunk") para poder transmitir paquetes de varias VLAN.

Se ha definido una red frontal de todo el sistema que controle el acceso a Internet. Así, todo el tráfico hacia el exterior es procesado por una serie de reglas de red. En este caso, se han establecido reglas de retransmisión de paquetes entre VLAN como puede verse en la @reglas-iptables. Este router es un contenedor _Alpine Linux_ con las reglas establecidas ya que no hay más necesidades de enrutamiento que las mencionadas.
Este contenedor se acopla a los bridge que simulan las redes públicas internas de cada entidad: br_one y br_ceph. Esto supone crear bucles de red entre el router, los _bridge_ y la interfaz VETH que une los _bridge_ por lo que se ha activado el protocolo STP en los bridge, otorgando máxima prioridad a los bridge para que la interfaz de VETH no quede en desuso.

#let rules_iptables = read("fragments/iptables.txt")

#figure(
  align(left)[
    #raw(rules_iptables, lang: "text")
  ],
  caption: [ Reglas de IPTables para retransmisión de VLAN. ]
) <reglas-iptables>

La red de contenedores se implementado mediante _macvlan_, redes virtuales que se acoplan a una interfaz física, sobre las interfaces VLAN en cada bridge.

=== Almacenamiento

El almacenamiento local del entorno de simulación consta de 3 discos mecánicos de 1TB dispuestos en RAID5. Para ofrecer el almacenamiento al resto de la infraestructura, se ha definido un grupo volumen con volumen físico los discos mencionados y tantos volúmenes lógicos como necesite cada componente.
Así, para los OSDs, que en total son 6, se han instanciado 6 volúmenes lógicos y sobre ellos se ha instalado un sistema de ficheros XFS.

En Ceph se almacenan las bases de datos de los frontales de OpenNebula, las imágenes de máquinas virtuales, su estado y los backup. Para ello se han definido los siguientes #gl("ceph-pool"), donde _eid_ es el identificador de cada entidad (10 o 20): _one-db-eid_, que contiene 3 imágenes, una por cada base de datos del frontal en #conc("ha"); _one-eid_, que da soporte a los datastores de OpenNebula y los pooles de backup _backup\_data-ceph-eid_ y _backup\_meta-ceph-eid_, definidos en la siguiente sección.
Cada uno de los pooles mencionados anteriormente, a excepción de los de backup, están configurados en modo réplica 3, 3 copias idéndticas en 3 OSD diferentes, y primario-copia, el dato se da por asentado cuando una mayoría simple de OSDs se lo comunican la principal.

=== Despliegue

El despliegue de la infraestructura se ha realizado mediante la herramienta de automatización Puppet.
Se han definido los módulos _net_, _storage_ y _virt_ para el despliegue de cada parte de la infraestructura por separado.
En el módulo _net_ están definidos los recursos de red definidos en la @net-impl con dependencias de despliegue internas: primero se despliegan los _bridge_ y después, sobre estas, las interfaces VETH.
El módulo _storage_ contiene tanto el almacenamiento local, con la definición de la estructura de LVM, como los recursos Ceph. El almacenamiento local no tiene dependencias internas ni externas, pero Ceph depende de los recursos de red y del almacenamiento local. Internamente, primero se despliegan los monitores, después los _managers_ y posteriormente los OSD y MDS. El módulo _virt_ contiene todo lo relacionado con la infraestructura de virtualización. Esta consiste en el _gateway_ y los componentes de OpenNebula. El contenedor de la puerta de enlace es el primero en ser desplegado, seguido de las bases de datos y los frontales de OpenNebula. Posteriormente se establece la comunicación entre cada frontal, formando un único clúster en #conc("ha").
En la @puppet-anex de los anexos se encuentra el grafo de dependencias entre recursos entero.

Entre los varios recursos personalizados que se han definido en Puppet, cabe destacar el de aprovisionamiento de contenedores.
Pese a sonar contraintuitivo (los contenedores vienen aprovisionados ya antes de ser desplegados), el procedimiento por el que se establece #conc("ha") entre los tres frontales de OpenNebula requiere acceso a los contenedores en tiempo de ejecución, siendo capaz de modificar ficheros de configuración y ejecutar comandos, esperando su respuesta y sincronizando el estado de otros contenedores.
El recurso definido permite esta operativa y ofrece una interfaz por la que acceder a recursos del contenedor a través de variables personalizadas.

En concreto, primero se despliegan 3 frontales en #conc("ha") que forman la zona maestra de la federación, seguido viene el frontal maestro de la segunda zona con el que se establece la federación.
Una vez establecida, se incorporan dos frontales más a la zona esclava.



== Implementación de la Recuperación ante Desastres
La implementación se enfoca en las dos necesidades planteadas en el diseño: servicio de backup y repositorio que se comunique con Ceph. La solución natural para el repositorio es CephFS, el cual se montará en el directorio _/var/lib/one/datastores_ de la máquina virtual donde se ejecute el servicio de backup. Para este servicio se ha escogido _Restic_, el cual cuenta con integración nativa en OpenNebula e implementa las necesidades de backup básicas (deduplicación, versionado y encriptado).

En Ceph se han definido dos pooles que dan soporte al sistesma de ficheros _backup_.
El de metadatos está en modo réplica 3 y el de datos está distribuido mediante erasure code 3-1, para soportar el fallo de hasta 1 OSD (o una entidad si se expande el clúster), corregirlo y restaurar la E/S después de su corrección.
Al tratarse de almacenamiento archivado (datos fríos), 1 bloque de paridad se considera aceptable.
Los pooles y el sistema de ficheros en base a estos se ha definido en el manifiesto _virt/manifests/services/opennebula/ceph/backup.pp_ Puppet.

Para desplegar Restic en OpenNebula, se ha definido la máquina virtual con usuario _oneadmin_, montado el sistema de ficheros Ceph _backup_, e instalado las dependencias _rsync_ y _qemu-img_.
Se ha creado un usuario llamado _backup_ con permisos de explotación de la máquina virtual a nivel de zona.
El nombre de la máquina virtual es _one-10-backup-backup_ siguiendo con la política de nomenclatura y se ha etiquetado como _one-10-prod_.
También se ha declarado un _datastore_ cuyo driver es _restic_ y no emplea puentes como intermediarios para almacenar las imágenes temporalmente.
La máquina virtual contiene las claves _ssh_ de los 3 frontales para su acceso remoto sin contraseña, requerido por la integración de _Restic_.
Esta configuración es necesaria por cada entidad federada.
La definición de la máquina virtual, usuario y datastore han sido definidos en el manifiesto _backup_datastore.tofu_ OpenTofu.

Las tareas definidas, tienen en cuenta las políticas de backup. Para los sistemas de ficheros, se detendrá la E/S de dos maneras diferentes: si la máquina se ha creado desde OpenNebula, mediante un agente nativo (especificado como _FS\_FREEZE=\"AGENT\"_) o parando la máquina momentáneamente (_FS\_FREEZE=\"SUSPEND\"_). Para este recurso se realizarán backups incrementales usando como base el _snapshot_ cada 4 repeticiones. Así, se guardará también el estado de la máquina de forma consistente en caso de fallo.
En el @backup-job se ve la aplicación de una de estas tareas para los servicios básicos de OpenNebula (3 frontales en HA con sus bases de datos).

#let backupjob = read("fragments/backupjob.txt")


#figure(
  align(left)[
    #raw(backupjob, lang: "text")
  ],
  placement: auto,
  caption: [
    Definición de la tarea de backup one-10-90 en OpenNebula
  ]
) <backup-job>

Para la incorporación de nuevos servicios al sistema de backup, se ha definido un _hook_.
Este leerá la etiqueta de la máquina virtual para determinar su prioridad y asignará su identificador a la tarea que le corresponda según la prioridad.
Habrá igualmente otro _hook_ definido para el borrado de máquinas donde se eliminará su identificador de la tarea.

#pagebreak()
= Validación y Pruebas realizadas

== Validación

== Pruebas

== Prueba de sobrecarga

Esta prueba involucra recolectar métricas del servicio de monitorización, la aplicación de políticas de SLA, sobrecarga en este caso, y su interacción con el subsistema de hooks de OpenNebula. Además, fuerza la portabilidad de los servicios en la federación para su despliegue inmediato en cualquier entidad mediante el uso de #conc("iac"). Esto permite validar posibles políticas de infraestructura que se escapen del alcance del servicio de validación de políticas.

Se desplegarán varias máquinas virtuales en la misma zona de OpenNebula ejecutando tareas de cómputo exigentes, llegando a superar el 80% de utilización de _vCPU_. Entonces, validar que se impide el despliegue de una nueva máquina virtual.

Para llevar a cabo esta prueba, primero se desplegará una máquina virtual con imagen base no persistente sobre la que se instalará el software _cpuburn_. Después se hará una copia persistente de la imagen de la máquina. Se usará esta nueva imagen en la plantilla de máquina virtual que después se desplegará hasta conseguir superar el 80% de utilización de _vCPU_.

imagen utilización más del 80%

La prueba se ha superado satisfactoriamente...

== Prueba de sobreaprovisionamiento

Esta prueba demuestra las horquillas establecidas en las políticas de sobreaprovisionamiento y por qué es viable esta técnica. Es un caso extraño que todos los servicios necesiten acceso al procesador al mismo tiempo, forzando una carga superior a la ofrecida por los host de virtualización. La horquilla establecida impide además el desperdicio de recursos, haciendo que una máquina virtual no pueda aprovisionar más capacidad de cómputo de la que pueda requerir.


#pagebreak()

= Trabajo futuro

- Establecer relación de ejecución entre hooks. Si un recurso falla en desplegarse por incumplir una política concreta, no ejecutar el hook de incorporación a las tareas de backup.

#pagebreak()

= Anexos

#counter(heading).update(0)
#set heading(
  numbering: "A.1"
)


= Hooks OpenNebula

Todos los _hooks_ definidos en OpenNebula empiezan con unas líneas que definen la ubicación de las librerías de ruby que usa OpenNebula.

#let hooks_prefix = read("fragments/one-hooks/prefix.rb")
#raw(hooks_prefix, lang: "ruby")

== Hooks BackupJobs

*Inclusión del ID de un máquina virtual a una tarea de backup*

#let backup_vm_create = read("fragments/one-hooks/backup/vm_create.rb")
#raw(backup_vm_create, lang: "ruby"),

*Eliminación del ID de un máquina virtual a una tarea de backup*

#let backup_vm_create = read("fragments/one-hooks/backup/vm_terminate.rb")
#raw(backup_vm_create, lang: "ruby"),

= Manifiestos Puppet <puppet-anex>
