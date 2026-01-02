#set page(
  paper: "a4",
)

#set par(first-line-indent: 1em, justify: true)

#set heading(
  numbering: "1.",
  bookmarked: true,
)

#show heading : it => block[
  #let (depth, body, numbering, ..args) = it.fields()

  #if numbering == none [] else if depth == 1 [
    #if numbering == "A.1" [
      #text(size: 20pt)[Anexo #context counter(heading).display()] #v(0pt)
    ] else [
      #text(size: 15pt)[Capítulo #context counter(heading).display()] #v(0pt)
    ]
  ] else [
    #context counter(heading).display()
  ]
  #text(size: if depth == 1 { 30pt } else {1em})[#body #v(20pt)]
]


#set text(
  lang: "es",
  size: 12pt,
)

#let listing(content) = {
  align(left)[
    #block(
      fill: luma(200),
      inset: 8pt,
      radius: 4pt,
      content
    )
  ]
}

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

  *Despliegue de una federación _cloud_: instanciación, presentación de recursos, gestión de la
pertenencia y monitorización y recuperación ante desastres*
  \
  \
  *Deployment of a _cloud_ federation: instantiation, resource submission, membership management
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

#heading(outlined: false, numbering: none)[Agradecimientos]

#align(center)[
Gracias a quien me ha apoyado en todo este proceso.

Gracias a Eduardo, por ayudarme en el desarrollo del proyecto y a Unai, por
aportar una mirada objetiva y sincera.
]

#pagebreak()
#pagebreak()

#heading(outlined: false, numbering: none)[Resumen]
#text(size: 11pt)[

Este proyecto tiene como objetivo definir, implementar y validar un modelo de federación entre distintos despliegues del software de gestión de máquinas virtuales _OpenNebula_.
Una solución de recuperación ante desastres para la federación es esencial para incorporar el modelo planteado en un entorno real.
Con ello se pretende ampliar la tecnología _cloud_ existente, siendo capaz de abordar escenarios complejos.

La arquitectura del modelo de federación está formada por tres planos de acción: el de confianza, donde se definen los mecanismos de interacción entre la infraestructura de las distintas entidades; el de gestión, en el que se definen las políticas, métricas y organización de usuarios para gobernar la federación; y el de uso, el cual presenta el catálogo de recursos de la federación que los usuarios emplean, según dictan las políticas definidas.
Los elementos funcionales del plano de gestión son, la seguridad en las comunicaciones entre entidades, el gestor de políticas y el servicio de monitorización.
Se interactúa con estos servicios a través del sistema de eventos de _OpenNebula_, que permite ejecutar la lógica personalizada que hace cumplir con las políticas definidas.

El sistema desplegado tiene en consideración la naturaleza de cada componente que lo forma; el almacenamiento persistente y volátil de estados, bases de datos y políticas se guardan en _Ceph_, los servicios de la federación que requieren cómputo se han virtualizado en _OpenNebula_ y cada componente basa su configuración en las políticas que se han implementado.

Se ha escogido el modelo de federación para poder incorporar miembros a un entorno de confianza, donde compartir usuarios y recursos de virtualización, como imágenes de disco para máquinas virtuales.
Este modelo permite a cada entidad mantener una gestión local de su infraestructura sin tener que acomodarse a las restricciones individuales del resto de entidades.
Además, cada entidad es soberana de sus recursos, pudiendo entrar y salir de la federación en cualquier momento sin penalizar al funcionamiento del sistema, siempre que se haga de forma controlada.

El sistema de recuperación ante desastres confeccionado actúa sobre la federación, no cada elemento independiente, homogeneizando las políticas destinadas a este ámbito.
Se ha diseñado una arquitectura para el _backup_, donde los servicios están virtualizados en _OpenNebula_ y almacena las copias en _Ceph_.
Para que la implementación de las estrategias y trabajos de _backup_ diseñados sea lo más directa y efectiva posible, se ha valorado positivamente que _OpenNebula_ integre la herramienta de _backup_.

La fuente de código en la que están definidos los componentes de la infraestructura y los servicios de la federación cumple con las políticas establecidas.
Las herramientas de despliegue automático escogidas interpretan esta fuente de código y despliegan los componentes definidos.
Para describir la interacción entre entidades y la gestión de los componentes de la infraestructura en masa, se han definido una serie de manifiestos en un lenguaje declarativo.
Esto permite mantener una configuración homogénea que pueda replicarse a las entidades cuando sea pertinente.
Así, los planes de despliegue entre entidades serán idénticos, evitando fallos humanos.

Al no contar con la infraestructura necesaria para realizar el despliegue real del sistema diseñado, se ha optado por desarrollar un entorno de simulación en un único nodo físico, donde desplegar y probar los servicios de la federación.


Ha sido satisfactorio el grado de completitud de los objetivos y los conocimientos adquiridos. La puesta en marcha ha sido un éxito y las pruebas han demostrado la corrección del diseño y la implementación.
]

#pagebreak()

#heading(outlined: false, numbering: none)[Abstract]
#text(size: 11pt)[

The goal of this project is to define, implement and validate a federation model between different OpenNebula deployments, a virtual machine management software.
In order to deploy this model in a real environment, a disaster recovery plan must be designed.
This project aims to extend the current cloud technology, being able to face complex cloud designs.

The architecture introduced for the federation model consists of three levels of action: the trust level, where the means of interaction between the infrastructure of the different entities is described; the management level, where the policies, metrics and user organisation for governing the federation are defined; and the usage level, which introduces the federation resources catalog that users interact with, as it is allowed by the defined policies.
The working components from the management level are, communications security between entities, policies manager and the monitoring service.
The interaction with these services is accomplished with the event system builtin in OpenNebula, that allows executing custom logic, forcing the resources to be compliant with the defined policies.

The system being deployed takes into account the nature of each component that it is made of; persistent and volatile storage, data bases and policies are kept in Ceph, the services that require compute power have been virtualized within OpenNebula and every component's configuration is compliant with the  implemented policies.

The federation model has been chosen so that new members can be added to a trusted environment, where to share users and virtual resources, such as disk images for virtual machines.
This model allows to locally manage each entity's infrastructure resources, disregarding individual constraints from others.
Moreover, each entity has sovereignty over its own resources, and may anter or leave the federation at any time without affecting the system's workflow.

The system designed for disaster recovery acts on the federation as a whole, not each element individually, standarizing policies in this environment.
The backup system has its own architecture design, where services are virtualized within OpenNebula and the data is stored in Ceph.
Tools that integrate directly with OpenNebula have been upvoted in order to benefit the builtin backup strategies and jobs, this will allow for a more effective implementation of the backup system.

The source code defining the infrastructure components and the federation services is compliant with the stablished policies.
The automated deployment tools chosen for the project interpret the source code and deploy the defined components.
A series of manifests, written in a declarative programming language, describe the interaction between entities and the infrastructure management at scale.
This allows a standarized configuration for every component, able to be replicated to each entity whenever is required.
Execution plans will be the same for different entities and free from human errors.

A simulation environment within a single physical node has been developed due to the lack of real infrastructure.
Tests and the designed deployment take this into account.

Project goals have been met, the deployment has been successful and tests show the wellness of the design and implementation.
Also, a substantial  knowledge has been acquired along the way.
]

#pagebreak()


#heading(outlined: false, numbering: none)[Glosario]
#let glossary = (
  (
    term: "Bridge huérfano",
    definition: [Interfaz _bridge_ sin interfaz física como _master_.],
  ),
  (
    term: "Cloud On-Premise",
    definition: [Tipo de _cloud_ cuya infraestructura, usuarios y software reside en la propia organización y es gestionada por la misma.],
  ),
  (
    term: "Cloud privado",
    definition: [Tipo de _cloud_ que utiliza una infraestructura de nube dedicada a una organización concreta. Un _cloud_ privado puede ser On-Premise o estar construido sobre un _cloud_ público.],
  ),
  (
    term: "Device class",
    definition: [Etiqueta asignada a un OSD.],
  ),
  (
    term: "Entidad",
    definition: [Organización, sede o grupo de personas que participa en la federación y que está ligado a una zona geográfica  y unos recursos informáticos concretos.],
  ),
  (
    term: "Federación",
    definition: [Medio para habilitar una interacción o colaboración de algún tipo. En este documento se entiende como federación _cloud_: habilidad de dos o más proveedores _cloud_ para interactuar o colaborar cooperativamente, estableciendo un espacio de nombres común para los recursos compartidos (usuarios, grupos, políticas, etc...).],
  ),
  (
    term: "Hook OpenNebula",
    definition: [Plantilla en texto plano, interpretada por el modelo de ejecución programada de eventos de OpenNebula (_Hook Execution Manager_), que liga la ejecución de un _script_ personalizado a un cambio en el estado de un recurso o una llamada API.],
  ),
  (
    term: "Infraestructura",
    definition: [Conjunto de recursos informáticos sobre los que se basa la arquitectura de un sistema. En este proyecto se entiende por infraestructura de virtualización o red según el contexto.],
  ),
  (
    term: "Imagen no persistente",
    definition: [En _OpenNebula_, tipo de imagen de disco sobre la que no se despliegan máquinas virtuales, solo guarda el estado concreto de una máquina.],
  ),
  (
    term: "Imagen persistente",
    definition: [En _OpenNebula_, tipo de imagen de disco sobre la que permanecen las escrituras que realiza una máquina virtual tras la destrucción de la misma. No confundir con el clonado enlazado o total de QEMU.],
  ),
  (
    term: "Imagen volátil",
    definition: [Tipo de imagen de disco que solo escribe las diferencias respecto de la imagen que tiene como base (en _OpenNebula_, no persistente). Una vez eliminada la máquina virtual, el disco ligado a este tipo de imagen se destruye.],
  ),
  (
    term: "Nodo",
    definition: [Computadora que forma parte de un conjunto de máquinas que sirven un propósito similar.],
  ),
  (
    term: "Política",
    definition: [Directrices que rigen la actuación de entidades, usuarios y recursos _cloud_ en la federación. Son la base fundamental para establecer la gobernanza en la federación.],
  ),
  (
    term: "Pool Ceph",
    definition: [Agrupación lógica de un conjunto de objetos RADOS sobre la que se aplican un conjunto de reglas de replicación y mantienen los datos distribuidos con el uso de _placement groups_.],
  ),
  (
    term: "Relación maestro-esclavo",
    definition: [Caracterización de dos o varios sistemas por el que el _maestro_ completa cierto tipo de peticiones que el _esclavo_ reexpide al _maestro_ o desecha. El _maestro_ replica su estado en los _esclavos_.],
  ),
  (
    term: "Servicio OpenNebula",
    definition: [Plantilla que define el despliegue de una o varias máquinas virtuales y recursos ligados a ella.],
  ),
  (
    term: "Servidor o host",
    definition: [Computadora física o virtual,con especial capacidad para cómputo, que ofrece un servicio a un cliente. En este proyecto hay servidores de virtualización, de gestión de políticas y el núcleo de _OpenNebula_],
  ),
  (
    term: "Servidor puente",
    definition: [Almacenamiento intermedio donde asentar primero los imágenes al descargarlas o migrarlas en _OpenNebula_.],
  ),
  (
    term: "Trunk",
    definition: [En el contexto de interfaces de red que dejan pasar tráfico de VLAN, capacidad de la interfaz para transmitir más de una VLAN.],
  ),
  (
    term: "Zona OpenNebula",
    definition: [Instalación del software de _OpenNebula_ que tiene cada entidad federada y está en una relación de maestro-esclavo con otra instalación diferente. ],
  ),
)

#let gl(key) = {
  let entry_index = glossary.position(entry => entry.key == key) + 1
  let entry = glossary.find(entry => entry.key == key)
  link(entry.label)[#emph[#lower(entry.term)#super[#entry_index]]]
}

#for entry in glossary [
  #let term = entry.term
  #let def = entry.definition
  / #term: #def
]



#pagebreak()

#outline()
#pagebreak()
/*
*
* INTRODUCCION
*
*/

#import "@preview/wordometer:0.1.5": word-count, total-words

#show: word-count

#counter(page).update(1)
#set page(numbering: "1")
#word-count(intro => [
= Introducción

== Contexto
Este proyecto se ha realizado en el Servicio de Informática y Comunicaciones de la Universidad de Zaragoza (SICUZ); encargado de mantener la operativa informática de la Universidad y la infraestructura que le da soporte.
En este contexto, la gestión de un _cloud_ on premise permite controlar la información y servicios ofrecidos desde la Universidad.
Este proyecto se alinea con los planes de desarrollo en tecnologías _cloud_ de la Unión Europea, entre los que se encuentran: la estrategia de gestión datos, en la que la federación de _clouds_ juega un rol vital, y la protección de datos en espacios seguros frente a su almacenamiento en empresas de _cloud_ privadas.

En este departamento se está implementando _Boira_ #footnote[https://boira.es/],  un proyecto de colaboración interuniversitario, donde se ha desplegado _OpenNebula_ @nebula-docs siguiendo una arquitectura distribuida.
Distintas universidades aportan parte de su infraestructura tecnológica para dar soporte a este despliegue.
Hay tres núcleos de _OpenNebula_ repartidos entre tres universidades formando un único _cloud_ on-premise.
Esto supone homogeneizar la infraestructura (almacenamiento, red y cómputo) para que cada universidad ofrezca y reciba rendimientos similares.

La confianza entre las distintas universidades se establece de palabra y siguiendo una serie de buenas prácticas establecidas de forma general.
Así, se ha contemplado la idea de federar cada uno de los _cloud_ on-premise de cada universidad, permitiendo una gestión abstracta y gobernada mediante políticas que afectan al uso y los recursos presentados.


== Motivación y alcance

El uso de una federación _cloud_ on-premise permite tener una gestión local de la infraestructura y compartida de la información de usuarios.
El nivel de confianza entre las entidades federadas rige el control de acceso a los recursos presentados.

El despliegue de un _cloud_ on-premise permite, a nivel de mantenimiento y hardware de la infraestructura, tener unos costes fijos; el tráfico puede entrar y salir sin restricciones ajenas a la organización (_egress fees_) y la escalabilidad de los recursos no tiene costes monetarios adicionales.
Los sistemas cuyo estado avanza consensuadamente entre los servicios que los componen, son sensibles a las latencias entre ellos.
Con un _cloud_ on premise hay una mayor flexibilidad para cumplir con los tiempos que estos sistemas requieren.
Además, el rendimiento de los programas informáticos ejecutados, no se verá afectado por entornos compartidos con usuarios ajenos.

La Unión Europea está apostando por el uso de este tipo de tecnologías que permiten a las organizaciones ser soberanas de su propia información, independizándose de contratos con empresas privadas donde almacenar la información de sus usuarios y clientes.
No obstante, la puesta en marcha de estos proyectos supone una gran dedicación en tiempo y personal para llegar a acuerdos en las políticas de uso e incorporación de entidades.


== Objetivos

El objetivo principal del proyecto es definir, implementar y validar un modelo de federación entre dos instancias de cloud on-premise _OpenNebula_ usando Ceph @ceph como sistema de almacenamiento distribuido.
Este se contempla como un prototipo que permita identificar posibles defectos del diseño real y confeccionar el despliegue de los elementos esenciales.
También el de contribuir a la creación de tecnología _cloud_, capaz de abordar escenarios complejos en múltiples zonas geográficas.

Se va a dar una solución de recuperación ante desastres para los recursos de la federación, siendo estos: sistemas de ficheros (de máquinas virtuales, de configuración y estado de la federación), estado de máquinas virtuales y catálogo de servicios de la federación (imágenes persistentes y volátiles del Marketplace privado de _OpenNebula_).

El uso de la federación que hagan los usuarios y recursos, se basará en las políticas de gobernanza especificadas.
También han de intervenir un sistema de monitorización y otro de control de accesos que validará las políticas definidas.

Los usuarios comunes de la federación en _OpenNebula_ son visibles para el administrador.
Estos usuarios tienen, por defecto, permisos restringidos a la zona en la que han sido creados.
Se va a crear una organización más compleja que permita tener administradores locales y grupos que controlen cierto tipo de recursos.

== Metodología

El proyecto se desarrolla mediante una metodología iterativa, permitiendo ajustar progresivamente el diseño y la implementación de la federación _cloud_ en función de los resultados obtenidos en cada ciclo.
En una primera fase se definen la arquitectura, la infraestructura base y las políticas iniciales.
Posteriormente, se implementan gradualmente los componentes de la federación y del sistema de _backup_, evaluando su funcionamiento a través de la comprobación del estado de cada componente.
Los resultados de estas validaciones sirven para refinar y optimizar las políticas diseñadas inicialmente, adaptándolas a las necesidades reales del entorno y consolidando finalmente una infraestructura estable y alineada con los objetivos del proyecto.

== Organización de la memoria

Se da comienzo por el estudio del estado del arte de los conceptos, tecnologías y herramientas relacionadas con la federación _cloud_.
Seguidamente se presenta un análisis de los requisitos del problema y el diseño del sistema planteado.
El diseño se divide en tres partes.
Primero, la arquitectura del prototipo de federación, tomando inspiración del modelo del NIST @nist, donde se comentan las relaciones entre los componentes de cada plano de la federación: mecanismos de confianza entre las entidades, validador de políticas y monitorización y el servicio de catálogo de recursos y usuarios.
Después, se aborda la infraestructura que da soporte a la arquitectura de federación, comentando aspectos de red, almacenamiento y despliegue, y se termina con el sistema de recuperación ante desastres.

Se sigue con la implementación del prototipo diseñado, describiendo el despliegue del catálogo, sistema de validación y control de accesos, monitorización e interacción con estos servicios.
Se cuenta cómo se ha simulado el entorno real de la infraestructura, cómo cada componente se ha tenido que adecuar al entorno de despliegue y se hace referencia a los problemas encontrados por este motivo.
Se termina la implementación con la recuperación ante desastres.

Por último se comentan las pruebas que se han llevado a cabo y los métodos de validación seguidos, para asegurar que la infraestructura se encuentra en el estado deseado en el momento del despliegue de los servicios. En otro apartado se hacen una valoración final y personal del proyecto.

Al final de la memoria hay una serie de anexos donde se documentan en detalle la distribución de carga de trabajo para este proyecto, la especificación de las políticas implementadas, problemas encontrados, una tabla con aspectos de red de los servicios desplegados, el código que valida las políticas y los manifiestos y código personalizado que definen los componentes de la federación.
//Total palabras introducción: #intro.words
])

#pagebreak()
/*
* ESTADO DEL ARTE
*
*/
#word-count(intro => [
= Estado del arte <etat-delart>

El _NIST_  @nist presenta un modelo de federación _cloud_ dividido en tres planos: confianza, donde cada entidad aplica una serie de protocolos que le permiten compartir información de su sistema con otro; administración, donde se hacen cumplir unas políticas de gobernanza y se definen usuarios y controles de acceso; y el plano de uso, donde los usuarios de la federación emplean los servicios publicados mediante la interacción con un servicio de catálogo.
Se entiende por confianza a la esperanza de que la otra entidad satisfaga lo previamente pactado, es decir, sea el cumplimiento de las políticas definidas para la gobernanza, lo que permita a entidades incorporarse al clúster.

La solución _cloud_ on-premise viene ya dada para el proyecto, _OpenNebula_, que permite federar varias instancias en lo que se denominan zonas.
_OpenNebula_ es un software de gestión de máquinas virtuales en nodos de virtualización separados.
La gestión de usuarios que ofrece es similar a la de UNIX, basándose en usuarios, grupos y permisos e incorporando otros conceptos como las listas de control de acceso.
El método de confianza establecido es la compartición de credenciales de administrador entre todas las zonas.
Este protocolo hace que la confianza se establezca de forma manual e implica que varias personas se pongan de acuerdo.
Para mejorar este aspecto se ha valorado el uso de _Verifiable Credentials_ @vc.
Este concepto lo presenta el W3 y permitiría crear una capa de confianza añadida, pero por la complejidad de la solución valorada (red IPFS más sistema de recuperación de credenciales) se ha descartado.
Esta solución, no obstante, se ha suplido por el uso de la infraestructura de clave pública (_PKI_) para la replicación entre zonas de _OpenNebula_, ya que la comunicación por defecto es en texto plano.

_OpenNebula_ incorpora conceptos imprescindibles para el diseño, como pueden ser las listas de control de accesos y la alta disponibilidad, de la infraestructura y las máquinas virtuales.
Las listas de control de acceso (_ACL_ en inglés), son acciones que pueden realizar unos sujetos sobre un objeto. Así, los usuarios de la federación podrán pertenecer a los grupos que tienen permisos sobre máquinas virtuales, pero si no están autorizados a efectuar las acciones descritas en las listas de control de acceso, no podrán interactuar con dichos objetos.
La alta disponibilidad (_HA_ en inglés), es la característica de un sistema que asegura un cierto rendimiento, normalmente de \"Tiempo en línea\", por un periodo de tiempo más extenso al normal.

Los componentes de _OpenNebula_ de interés para este proyecto son: el núcleo (demonio _oned_), cuya función es guardar y propagar el estado del sistema y gestionar el planificador (_scheduler_);  el subsistema de _hooks_, que permite ejecutar lógica personalizada tras haberse disparado un cambio de estado o ejecutado una acción en la API; y el sistema de backup, que presenta la definición de trabajos planificados para grupos de recursos.
Además, introduce con el concepto de _datastore_, una capa de abstracción sobre el almacenamiento real que hace uso de drivers específicos para cada solución de almacenamiento soportada.

La arquitectura de federación de _OpenNebula_ plantea una replicación jerárquica, donde cada entidad (zona _OpenNebula_) toma el rol de maestro o esclavo. Hay un maestro y uno o más esclavos.
Se asegura consistencia secuencial entre zonas, es decir, que las operaciones replicadas están en el mismo orden en el estado de cada zona, sin embargo es posible que los esclavos lean datos anticuados.

De la arquitectura de Ceph, los componentes de mayor valor para el prototipo son RADOS @ceph-arch, el sistema autónomo de replicación donde se almacenan los objetos del clúster; RadosGW @radosgw-docs, la puerta de enlace con el clúster mediante una interfaz compatible con S3; RBD, que ofrece una representación de un dispositivo de bloque, cuyos sectores de disco se encuentran distribuidos en Ceph, que puede ser montada (_map_) localmente como tal dispositivo o accedido a través de la interfaz de QEMU/KVM; y CephFS @cephfs, el sistema de ficheros compartido compatible con POSIX.

RADOS está formado por monitores, gestores del estado del clúster y recuperación de los datos; OSD, servicios que efectúan el almacenamiento de objetos en disco; _managers_, servicio encargado de exportar métricas del clúster; y MDS, los servicios de gestión de metadatos para CephFS, un estilo de monitores especiales para los sistemas de ficheros.
Además se basa en los conceptos matemáticos, no materializados como servicios, de _placement group_, un cálculo estadístico para la distribución (y replicación) de objetos en OSDs, y _pools_, agrupamientos lógicos con unas políticas de replicación personalizables.
Los _pools_ pueden estar configurados con dos modos o estrategias de replicación: réplica _n_ o _erasure code_.
Para el modo de réplica _n_, siendo 3 la _n_ más utilizada, existen varios modos de copia entre los OSD en el mismo _placement group_, donde _primario-copia_ es el más utilizado por tener la menor latencia en la confirmación de las operaciones de escritura.
La estrategia de _erasure code_ se basa en la definición de _m_, el número de bloques de datos y _k_, bloques de paridad.
Esto permite soportar el fallo de hasta _k_ OSD (o _k_ entidades si se expande el clúster), corregirlo y restaurar la E/S después de su corrección.
La primera estrategia permite recuperar datos tras fallo más rápido que la segunda, aunque se penalice con la copia de cada objeto _n_ veces.

El proyecto _Gaia X_ @gaiax ha servido de inspiración para encontrar tipos de políticas que implementar en la federación. Estas han sido las de servicio mínimo y resaltar la importancia de que cubran todos los componentes de la infraestructura, usuarios y servicios de la federación.
Esto último, ha sido extraída como núcleo conceptual de las políticas definidas en la federación presentada.

XACML @xacml es un lenguaje de marcado, basado en XML, para definir políticas de control de accesos basadas en atributos.
Es un estándar publicado por _OASIS_ que presenta también un arquitectura y un modelo de evaluación de las peticiones de acceso a recursos.
Las decisiones de control de acceso se toman en base a un conjunto de reglas, cada una formada por una serie condiciones.
Una implementación de este estándar es _Open Policy Agent_ @opa-docs, que presenta un lenguaje de dominio específico para expresar las políticas y un motor de que valide las peticiones de acceso a recursos. En general, comprueba si el conjunto de reglas de una política se satisfacen dada una entrada y un conjunto de datos.

Las características esenciales que debe presentar un sistema de backup para entornos _cloud_ son la gestión de duplicados, compresión y cifrado para el almacenamiento de los datos de tipo objeto.
A estos datos se los conoce como datos fríos, es decir, que no se necesitan con frecuencia pero deben guardarse a largo plazo.
_OpenNebula_ presenta dos tipos de backup: incremental y completo, con distintos modos de control del sistema de ficheros de las máquinas virtuales.
Las herramientas de backup estudiadas han sido Restic y Bacula, siendo la primera la que se ha acabado utilizando. _OpenNebula_ cuenta con un driver, aunque incompleto, de Restic, por lo que la definición de trabajos automáticos de backup está integrado. Bacula, pese a ser una herramienta más completa, debería ser desplegada como una máquina virtual y gestionada a parte, como un servicio desconectado de la federación.

Entre las tecnologías estudiadas para el desarrollo de la solución se encuentra la Infraestructura como Código (_IaC_ en inglés).
Define el proceso de gestión y aprovisionamiento de recursos informáticos en una infraestructura _cloud_, a través de manifiestos interpretables por alguna herramienta.
Puppet, Ansible y OpenTofu han sido las herramientas contempladas para la implementación del diseño, pero finalmente se han escogido Puppet @puppet-docs, dada la capacidad de personalización de los recursos del despliegue, y OpenTofu @opentofu-docs, al ser la herramienta de integración nativa con _OpenNebula_ y la rama de código abierto de Terraform.

//Total palabras estado del arte: #intro.words
])


/*
*
* ANÁLISIS Y DISEÑO
*
*/

#pagebreak()
#word-count(intro => [
= Análisis y Diseño del sistema

== Análisis del problema

El diseño de La infraestructura que da soporte a las instancias _cloud_, incorpora como propiedades la *tolerancia a fallos y alta disponibilidad*.

Teniendo en cuenta la alta disponibilidad, el entorno _cloud_ on-premise requiere bajas latencias entre núcleos para avanzar el estado del sistema de forma consensuada.
Se debe utilizar un *sistema de almacenamiento tolerante a fallos y que pueda ser utilizado como datastore de _OpenNebula_*.
La configuración de cada entidad y el proceso de incorporación a la federación es una parte sensible, ya que hay una relación de orden entre operaciones estricta y precisa.
Por ello, *el despliegue debe controlar las relaciones entre recursos y estar automatizado*. Así se evitan fallos recurrentes y la distribución de cambios de configuración es inmediata.

Las políticas que se definan *deben cubrir el uso y control de acceso a los servicios de la federación por parte de los usuarios de las entidades federadas*.
Además del almacenamiento, cómputo y estado de la federación.
*Debe haber un sistema de monitorización y otro de gestión de las políticas*, que dado un servicio y su uso deseado, dictará si se permite o no el uso del servicio.
Las *métricas han de estar disponibles y ser accesibles en un _endpoint_* acordado, de este modo se asegura que la interacción con los servicios sea efectiva.

El *catálogo de servicios de la federación ha de tener una visión unificada del almacenamiento subyacente*, es decir, que independientemente del número de entidades federadas, cada una tiene la responsabilidad de almacenar parte de la información del catálogo.
La *ubicación de esa información debe ser transparente al recuperarla*.

La recuperación ante desastres debe cumplir las políticas establecidas, ya que es un servicio más de la federación.
El *tipo de datos almacenados en este proceso debe ser de objetos*, ya que responden a la naturaleza del problema: múltiples lecturas, única escritura y recuperación del objeto, del medio de almacenamiento, eficiente.
La *información almacenada ha de estar disponible para todas las entidades en cualquier momento*, siendo la recuperación de los datos independiente del estado del servicio de _backup_ en cada entidad.

La *definición de los servicios de _backup_, gestor de políticas, monitorización y catálogo debe ser homogénea*, independiente de la configuración local de cada zona y compatible con _OpenNebula_. Esto permite replicar la configuración de estos servicios de manera inmediata entre las distintas entidades federadas.

Por defecto, la propagación del estado de la federación emplea el protocolo HTTP, al estar comunicando información de usuarios, grupos y otros datos sensibles, se considera esencial proteger esta fase, mediante el *cifrado de las comunicaciones entre entidades*.
Además, para asegurar que no cualquier despliegue de _OpenNebula_ pueda comenzar a recibir datos de la replicación, se ha de habilitar un *mecanismo de confianza entre entidades a nivel de red (o pertenencia a la federación)*.
La infraestructura es naturalmente escalable ya que la capacidad de cómputo y almacenamiento incrementa tras la incorporación de nuevas entidades.



== Diseño de la federación
Se plantea la federación como un _cloud_ privado para la información de las entidades federadas y público para los usuarios que utilicen los servicios que presenta.
Las políticas que conforman la gobernanza deben ser respetadas a todos los niveles, infraestructura, servicios y aplicaciones, y en cada ámbito, entidades que guardan datos de sus usuarios como _cloud_ privado y usuarios que entran a la federación como _cloud_ público.
#figure(
  image("images/arquitectura.png", width: 70%),
  placement: auto,
  caption: [
    Arquitectura del prototipo de federación.
  ]
) <arch>


La @arch introduce los componentes principales principales del sistema.
Se definen tres planos de abstracción: confianza, gestión y uso.
La confianza entre entidades se establecerá mediante los protocolos internos de distribución de credenciales de administración de _OpenNebula_.
En el plano de gestión se hará cumplir con las políticas de gobernanza definidas mediante un sistema de validación.
El plano de uso describe la interacción que habrá entre los usuarios de las distintas entidades con los servicios ofrecidos por la federación.


=== Plano de confianza

El plano de confianza lo forman las instalaciones de _OpenNebula_ y _Ceph_ locales en cada entidad.
A este nivel, y con la arquitectura de federación de _OpenNebula_, se establece la confianza para dos escenarios: pertenencia a la federación y el proceso de replicación entre zonas.
Las credenciales del usuario administrador _ondeadmin_ se comparten de la entidad _maestra_ a la _esclava_, así ambas zonas pertenecen a la misma federación.
En la @arch la \"Entidad 0\" es la _maestra_ y la \"Entidad 1\" la _esclava_.
Esta es la primera aproximación a la pertenencia de una entidad a la federación.
A nivel de infraestructura, se establece otro mecanismo para gestionar la pertenencia.
El proceso de replicación entre entidades es confiable mediante el uso de algún protocolo de  comunicación cifrada.

La confianza entre cada instancia de _OpenNebula_ y su clúster Ceph se establecerá a través de un usuario de Ceph que tendrá los permisos necesarios para consumir los recursos del clúster y almacenar los datos de _OpenNebula_.



=== Plano de gestión
En el plano de gestión, una serie de políticas definen la gobernanza de la infraestructura y controlan accesos de usuarios a servicios.
El comportamiento y rendimiento del _backup_, sistema de validación de políticas y máquinas virtuales de usuarios, que se ejecutan en la federación, está monitorizado; atendiendo también a las políticas definidas.

Las políticas diseñadas cubren los componentes definidos de la infraestructura y en los distintos planos de la federación.
El acceso al almacenamiento, cómputo, recursos de _OpenNebula_, _backup_, monitorización y validador de políticas está controlado mediante alguna política específica para ello.
En el @pseudo-naming se muestra el ejemplo de la política de nombrado para máquinas virtuales, pero también se cubren imágenes y _hooks_; estas son de gran utilidad para administrar estos y más recursos mencionados en la @impl-policies.
Se definen políticas de acuerdos de servicio mínimo (_SLA_) que los servicios desplegados en la federación han de respetar.
Estas permiten que cada entidad perciba un rendimiento, de los servicios que ofrece la federación, adecuado al nivel de los que tiene ella desplegados.
La organización de usuarios en la federación, comentada en la siguiente subsección, está cubierta por políticas respecto a la gestión de usuarios.
Más políticas diseñadas y su especificación se pueden encontrar en el @anexo-politicas[Anexo] y su implementación en el @rego-policies[Anexo].

#let pseudo_naming = read("fragments/pseudo-naming.pseudo")
#figure(
  listing(raw(pseudo_naming, lang: "text")),
  placement: auto,
  caption: [ Pseudocódigo de política de nombrado. ]
) <pseudo-naming>

El sistema que valida las políticas diseñadas se plantea en un modo pasivo, es decir, que dicta si se está respetando una política concreta para un recurso presentado, en cuyo caso se deja o no desplegarlo.
En un modo activo, el sistema sería capaz de aplicar los cambios necesarios al recurso para que cumpla con las políticas.
En el @pseudo-policy se puede ver en las líneas finales como se aplica este modo de uso.
Se ha escogido el modelo pasivo por claridad, simplificar el diseño, viabilidad técnica y disponibilidad de tiempo.

El sistema de monitorización ofrece la información necesaria para hacer cumplir ciertas políticas definidas.
El @pseudo-policy describe el procedimiento por el cual se interactúa con el punto de acceso a las métricas y con el validador de políticas, obteniendo la información requerida para determinar si un recurso cumple con las políticas que le incumben.
En este proceso se consultan y se procesan las métricas exportadas por el servicio de monitorización, que después sirven de entrada para el validador de políticas.
El modelo de ejecución programada de eventos que ofrece _OpenNebula_ permite ejecutar la lógica personalizada que implementa este flujo de trabajo.
El @rhook refleja parte de la implementación del pseudocódigo del @pseudo-policy.

#let pseudo_policy = read("fragments/pseudo-policy.pseudo")
#figure(
  listing(raw(pseudo_policy, lang: "text")),
  placement: auto,
  caption: [ Pseudocódigo de validación de políticas. ]
) <pseudo-policy>

Se necesita algún tipo de interacción con los servicios mencionados para este plano, si no, no se podrían validar las políticas implementadas y ejecutar lógica personalizada que permite gestionar trabajos de _backup_.
_OpenNebula_ ofrece un modelo de ejecución programada de eventos, el _Hook Execution Manager_, que permite suscribir la ejecución de un _script_ a eventos del tipo de cambio de estado o llamadas a la API interna.

=== Plano de uso

En el plano de uso destacan los usuarios y el catálogo de la federación.
Los usuarios son nativos de _OpenNebula_, se comparten en la federación y están sujetos a una serie de _ACL_, con permisos sobre imágenes y máquinas virtuales que regulan el uso que hacen de la federación.
Además estos usuarios pueden publicar y emplear los recursos ofrecidos en el catálogo de la federación.

El catálogo de la federación es el espacio virtual donde la federación ofrece imágenes de disco para máquinas virtuales y servicios _OpenNebula_, que los usuarios de la federación pueden emplear.
_OpenNebula_ ofrece un servicio llamado \"Marketplace\" #footnote[https://docs.opennebula.io/6.10/marketplace/private_marketplaces/overview.html], el cual es accesible desde las zonas de la federación, donde publicar los recursos mencionados ligados a una serie de permisos.
Este modelo es el más adecuado dada su integración nativa con _OpenNebula_.

Al crear un usuario, por defecto en _OpenNebula_, se le asigna al grupo de usuarios de la zona en la que se crea.
En la organización diseñada, se extienden los permisos mediante la incorporación a grupos secundarios.
Estos grupos adicionales son los sujetos de listas de control de acceso que otorgan privilegios según el propósito de cada grupo.
Para encapsular el radio de acción de ciertos grupos se definen cuotas de uso o grupos de recursos.

Por defecto, la figura del administrador es única en la federación de _OpenNebula_.
Siguiendo la organización anterior, se definen administradores locales de cada entidad cuyos permisos estarán ligados a su propia entidad.

== Diseño de la Infraestructura


#figure(
  image("images/diseño-infra.png", width: 90%),
  caption: [
   Diseño de la infraestructura multi sede.
  ]
) <infra-arch>


La infraestructura desplegada consiste en dos entidades separadas geográficamente, cada una ejecuta su propio software de _OpenNebula_ local.
Esto constituye un despliegue _cloud_ On-Premise en cada entidad.
Los núcleos, inicialmente, son máquinas virtuales gestionadas por una interfaz de virtualización local.
_OpenNebula_ ofrece un mecanismo de adopción por el que máquinas virtuales locales pueden pasar a ser gestionadas por _OpenNebula_.
En _OpenNebula_ se conoce a este tipo de máquinas como \"máquinas salvajes\".
Adoptando los núcleos como \"máquinas salvajes\", se consigue tener una infraestructura autocontenida.
Cada núcleo se coloca en un servidor distinto, asumiendo que cada entidad cuenta con, al menos, tres servidores de virtualización.
Los datastores de _OpenNebula_ tienen configurado el driver de Ceph y como servidor puente los nodos de virtualización.

=== Red <net-design>
La red interna de cada entidad cumple con políticas de red, lo que permite que los servicios de backup, sistema de validación y catálogo puedan desplegarse de forma transparente en cualquier entidad.
Para separar la infraestructura de la federación de cualquier otro servicio con el que ya cuente una entidad, se definen 3 redes distintas: una de servicio, para la comunicación entre servicios de _OpenNebula_ y la interacción con los usuarios y otras entidades; administración, donde residen las máquinas físicas; y almacenamiento, independiente del resto y que sirve como punto de entrada al clúster Ceph, el cual cuenta con una red interna de replicación, aunque en otros despliegues pueda ser opcional.

El acceso a la red física desde las máquinas virtuales se consigue mediante las interfaces de red locales de cada nodo de virtualización.
Estas deben estar creadas en cada nodo de cada entidad federada;  el tipo escogido para estas interfaces es el de conmutación de paquetes.
Estas interfaces tienen como entrada el tráfico de alguna de las redes descritas en el primer párrafo, habiendo creado tantas como componentes existen, una para los elementos de Ceph (OSD, monitores, etc...), otra para los de _OpenNebula_ y para las máquinas virtuales y servicios de la federación.

Este diseño permite aislar el tráfico de las máquinas virtuales a una red en un _host_, sin afectar al funcionamiento de la federación.
Se configuran en cada nodo de virtualización y las máquinas virtuales ven una interfaz de red ethernet sin alteraciones.
En la @net-impl puede verse la implementación de la red y en el @vagrant[Anexo] la definición concreta.

El endpoint de cada zona conecta cada entidad de la federación y se comunican a través de sus redes de servicio.
Esta comunicación entre endpoints se basa en una solución que permite establecer la pertenencia de una entidad a la federación (VxLAN, VPN o PKI), permitiendo la conexión a través de la red WAN y aislando la comunicación frente a terceros.
Se adopta el protocolo TLS, basado en infraestructura de clave pública, para esta comunicación ya que de serie, _OpenNebula_ transfiere los datos en texto plano.

=== Almacenamiento

Cada entidad tiene una serie de discos locales reservados para la federación.
Se diferencian dos espacios de discos, uno para explotación (datos calientes) y otro para la recuperación ante desastres (datos fríos).

Cada entidad contará con su propio cluster Ceph.
Esta solución de almacenamiento es muy sensible a latencias entre sedes por lo que se recomienda #footnote[https://docs.ceph.com/en/squid/radosgw/multisite/#requirements-and-assumptions] su uso de forma independiente en conexiones por red WAN.
Cada clúster seguirá la organización planteada en el diseño de cada componente de la federación (propósito de los pooles definidos, etiquetado de dispositivos y redes internas), pero las reglas internas de gestión son de libre implementación.
No obstante, tienen como base las políticas de servicio mínimo implementadas.

En Ceph se almacenan el estado de los núcleos de _OpenNebula_, de las máquinas virtuales y del sistema de monitorización, las imágenes de disco de máquinas virtuales, los backup y los recursos alojados en el _Marketplace_.
En el @puppet-storage[Anexo] se trata en detalle el módulo de almacenamiento implementado.



== Diseño de la Recuperación ante Desastres
El eje central de la recuperación ante desastres es el sistema de _backup_.
Se habla del _backup_ de la federación más que de sus componentes por separado.
Así, se van a tener una serie de políticas que afecten al _backup_, como a cualquier otro servicio, y la infraestructura que le da soporte.
Los recursos sobre los que se actúa son: sistemas de ficheros, que incluyen máquinas virtuales, configuraciones, estado de la federación y políticas; y estado de las máquinas virtuales de la federación.
Al ser el despliegue de _OpenNebula_ autocontenido, la gestión de los _backup_ de los servicios de la federación y de los componentes de _OpenNebula_ es idéntica.

El diseño del _backup_ de los sistemas de ficheros está dirigido por las opciones que ofrece _OpenNebula_.
Se emplea un agente nativo que no haga perder disponibilidad del servicio que ofrezca la máquina, si esta se crea desde _OpenNebula_.
En caso contrario, se suspende momentáneamente la E/S y se realiza la copia.
Los parámetros concretos en _OpenNebula_ que ofrecen esta gestión, se detallan en la @backup-impl.

El servicio de validación de políticas no almacena estado, por lo que para su recuperación en caso de fallo, se almacena la configuración de su despliegue como parte del estado de _OpenNebula_, lo que permite relanzar automáticamente este servicio.

#figure(
  image("images/arquitectura-backup.png", width: 70%),
  caption: [
    Arquitectura del servicio de backup para cada entidad.
  ]
) <backup-arch>


La @backup-arch destaca el uso de un repositorio backup que contacta con Ceph para el almacenamiento de objetos deseado (representados en la figura mediante el cuadro duplicado en el que está escrito \"Imagen X\").
El repositorio tendrá más implicaciones de red que de almacenamiento _per se_. Al estar comunicado con Ceph, los datos no residirán en la máquina virtual del servicio de backup, si no que lo harán directamente en Ceph.
Se emplea el protocolo de comunicación SFTP entre el núcleo de _OpenNebula_ y el servicio de backup escogido.
Este protocolo es una restricción de _OpenNebula_ #footnote[https://docs.opennebula.io/6.10/management_and_operations/backups/restic.html?highlight=backup#backup-datastore-restic] para conseguir backups nativos; otra opción hubiese sido desaprovechar la capacidad de definición de tareas de backup nativa de _OpenNebula_ para emplear un protocolo de almacenamiento de objetos como Ceph S3.
Con este diseño, se configura el servicio de backup para que almacene localmente las imágenes de backup de _OpenNebula_ y el sistema de ficheros empleado tendrá contacto con Ceph.

Cabe destacar que el término \"imagen\" en la @backup-arch es el nombre que _OpenNebula_ da al resultado de aplicar una estrategia cualquiera de backup sobre la imagen de disco (persistente o no) de una máquina virtual.

//La implementación de la infraestructura de red que soporta al backup en cada entidad es libre, pero está sujeta a los SLA acordados para backup.
//Para ello se propone una red basada en la tecnología fibre channel, con posibilidad de utilizar FCoE si se cuenta con mecanismos de DCB en la infraestructura interna de la entidad.


== Despliegue <deploy-design>

El despliegue de la arquitectura de _OpenNebula_ consiste en la instalación, por medio de paquetes software, de los servicios esenciales mencionados en la @etat-delart. Con ello, se definen los _datastores_ de tipo imagen y sistema con un driver específico de almacenamiento, en este caso _Ceph_. Por último se incorporan una serie de nodos de virtualización con el hipervisor KVM instalado y cargado como módulo del kernel.

Los núcleos de _OpenNebula_ de cada entidad están desplegados formando un clúster en alta disponibilidad.
En el plano de gestión, están desplegados en cada zona, el sistema de validación de políticas, el servicio de monitorización y una interfaz que permite la conservación de los recursos alojados en el _Marketplace_, dotando de alta disponibilidad a estos servicios.
Así se consigue también la completitud de las métricas ofrecidas. La infraestructura y los servicios que está ofreciendo a la federación son el objeto del servicio de monitorización.

Los recursos siguen un despliegue escalonado (_Rolling Deployment_), se comienza por la entidad de la zona maestra y, tras validar el correcto estado de sus componentes, se sigue por las zonas de las demás entidades. Para cambios o actualizaciones, además de tener en consideración lo anterior para _OpenNebula_, se sigue una estrategia que mantiene la consistencia de los recursos almacenados en el _Marketplace_, que están distribuidos entre todas las entidades.

El despliegue se completa en dos etapas con propósitos distintos, una primera para la infraestructura y después la arquitectura de la federación.
Se plantea el despliegue de forma semi-automática, donde cada etapa se completa mediante una herramienta de _IaC_ con propósito distinto.
Hay ciertos parámetros, como claves de acceso o identificadores de recursos, necesarios en la segunda etapa, que se generan en la primera. De ahí, que el despliegue no pueda ser completamente automático, ciñéndose a estas herramientas.

Durante la primera etapa del despliegue, se declaran varias fases ordenadas por su naturaleza y la relación entre los componentes de la infraestructura.
En la primera fase, se prepara el almacenamiento físico, particionando el espacio, y la red, creando las interfaces de red locales.
En la segunda fase, se crean las redes virtuales necesarias para comunicar los contenedores Ceph y máquinas virtuales, según la implementación escogida.
La siguiente fase corresponde al despliegue del clúster Ceph, que se detalla en el @puppet-storage[Anexo], subsección de Ceph.
Con esto, ya se pueden desplegar los núcleos de _OpenNebula_, ya en la siguiente fase, dotarlos de alta disponibilidad y definir una primera zona maestra. Tras ello, se sigue el mismo procedimiento para la zona esclava y se termina creando los recursos que emplean directamente los servicios de la federación.
Esta primera etapa se comenta más en detalle en la @impl-deployment.

En la siguiente etapa de despliegue están definidos los usuarios, grupos y permisos, creados en la primera fase.
Con ellos se despliegan el backup, validador de políticas y catálogo de servicios, cada uno en su fase correspondiente.
En la @impl-fed-deploy se comenta más en detalle esta etapa.


//Total palabras diseño: #intro.words
])


/*
*
* IMPLEMENTACIÓN
*
*/
#pagebreak()
#word-count(impl => [
= Implementación

Para implementar el prototipo de federación diseñado se emplean herramientas de despliegue automático, Puppet para la infraestructura y OpenTofu para los servicios de la federación; _Prometheus_, como servicio de monitorización y gestor de métricas personalizadas; el _driver_ de _Restic_, con el que llevar a cabo los _backup_; y _Open Policy Agent_ (OPA), como sistema de validación de políticas, junto a _Rego_ para implementar las políticas.
Además se emplea el lenguaje de _scripting_ _Ruby_ para definir recursos personalizados en _Puppet_ y los _hooks_ de _OpenNebula_.

Por cuestiones económicas y materiales, no se contaba con la infraestructura necesaria para desplegar todos los componentes de la infraestructura en distintas máquinas, por lo que se ha optado por simular el entorno real mencionado en el diseño.
Este entorno consiste en un único servidor de virtualización, lo que restringe el despliegue real.

El servidor en el que se simula la infraestructura tiene dos procesadores de 16 núcleos, 128GB de memoria RAM y tres discos de 1 TiB de capacidad, dispuestos en RAID5.

== Implementación de la Infraestructura

#figure(
  image("images/impl-infraestructura.png"),
  caption: [ Infraestructura virtualizada ],
  placement: auto
) <red-simulada>

El despliegue está basado en contenedores _Podman_, que usan _Debian_ como sistema operativo, y dos máquinas virtuales que simulan cada sede geográficamente separada.
Sabiendo que el backup y el sistema de control de accesos se despliegan en máquinas virtuales, se ha hecho la infraestructura lo más ligera posible.
Cada contenedor se ejecuta en modo no privilegiado, aunque al _gateway_ se le asignan las _capabilities_ _NET\_RAW_ y _NET\_ADMIN_ que permiten modificar la red.
Cualquier acceso a dispositivos físicos, en el caso de OSDs o asegurar la persistencia de las bases de datos, se realiza a través de volúmenes con los dispositivos previamente configurados y montados en una ruta específica en el host.

En el @puppet_virt_deploy se muestra el despliegue que sigue la federación de _OpenNebula_. La creación de la red, seguida por el _gateway_ y los cluster Ceph, son los pilares sobre los que se despliegan los núcleos en alta disponibilidad de la zona maestra, incorporando después la zona esclava, salvando las relaciones de orden entre ellas.


=== Red <net-impl>

La topología de red presentada en la @red-simulada es una adaptación de la diseñada en la @net-design al entorno de despliegue.

La distinción geográfica entre sedes se consigue haciendo que el tráfico pase por el encaminador más cercano, en este caso el _gateway_.
Para ello, cada máquina virtual, que corresponde a una sede distinta, tiene configuradas rutas para su subred local y como puerta de enlace el _gateway_.
En el servidor físico están definidas la interfaz tipo bridge para las máquinas virtuales y la red por defecto de contenedores.

Cada máquina virtual cuenta con dos interfaces tipo bridge sobre las que conectar los contenedores, una de ellas es para el despliegue de los componentes de _OpenNebula_, Ceph y las máquinas virtuales gestionadas por _OpenNebula_.
La otra es la red de almacenamiento interno de Ceph.
Además, las máquinas virtuales que simulan cada sede están en una misma red de administración, lo cual facilita luego el despliegue.

Se define la red frontal de todo el sistema para que controle el acceso a Internet.
Esta se detalla en el @puppet-virt[Anexo], en el subapartado del _gateway_.

La red de contenedores emplea _macvlan_, redes virtuales que se acoplan a una interfaz física, en este caso los _bridge_.
En el @asign-direcciones[Anexo] hay una tabla que refleja los aspectos de red que se tienen en cuenta durante el despliegue.
=== Almacenamiento


El _host_ utilizado para simular la infraestructura, tiene definido un _pool_ de almacenamiento de imágenes de disco.
Este cuenta con tantas imágenes como necesite cada componente de la infraestructura, y arquitectura.
Así, para los OSDs, que en total son seis, se instancian seis imágenes de 20GB, permitiendo el uso de forma más granular del almacenamiento físico.
Los espacios de explotación y backup forman parte del clúster Ceph local, pero están diferenciados por el _device class_ de sus OSDs que permite asignarlos al pool de backup o explotación.

Los pooles de Ceph definidos están configurados en modo réplica 3 y primario-copia, a excepción del pool de datos del sistema de ficheros para el backup, que emplea la técnica de _erasure code_ 3-1.
Al tratarse de almacenamiento archivado (datos fríos), 1 bloque de paridad se considera aceptable.
Las bases de datos de los núcleos se guardan como imágenes en un pool de bases de datos.

_Prometheus_ almacena sus métricas en el almacenamiento local o, en su defecto, necesita un adaptador en el que almacenar la información y que este se la comunique a la solución de almacenamiento real.
Como adaptador se emplea un volumen de contenedor cuyo soporte subyacente es un disco RBD de Ceph.
En el pool empleado para las bases de datos hay creada una nueva imagen para este servicio.

_OpenNebula_ consigue almacenar las imágenes de disco de máquinas virtuales mediante el uso de datastores configurados con el driver Ceph.
Se emplea el almacenamiento local del nodo de virtualización como \"puente\" entre la solución de almacenamiento y la instancia de máquina virtual, gestionada por _OpenNebula_.
Se puede observar en detalle la definición de estos elementos en el @puppet-storage[Anexo].


== Implementación de los servicios de la federación

A continuación se abordan los aspectos técnicos más concretos del despliegue de los servicios de validación de políticas, monitorización, catálogo de recursos e interacción con ellos mediante el uso de _hooks_ de _OpenNebula_.


=== Sistema de control de accesos y validación de políticas <impl-policies>

Para implementar este sistema se emplea _OPA_ (_Open Policy Agent_) @opa-docs, que es un validador de políticas expresadas en el lenguaje de dominio específico _Rego_ #footnote[https://www.openpolicyagent.org/docs/policy-language]. Dado un conjunto de datos de entrada y un archivo con un política expresada en _Rego_, se valida si el conjunto de datos está conforme con la política.

Este servicio ofrece varias opciones de despliegue, siendo la que mejor se ajusta a _OpenNebula_ la opción de contenedores _Docker_ #footnote[https://www.docker.com/]. En la @impl-fed-deploy se explica en detalle el despliegue de este servicio.

#let rego_naming_policy = read("fragments/rego/naming_pol.rego")

#figure(
  listing(raw(rego_naming_policy, lang: "text")),
  caption: [ Política de nombrado de máquinas virtuales empleando lenguaje Rego. ]
) <rego>

Las políticas preliminares implementadas cubren los siguientes aspectos: nomenclatura de recursos, imágenes de disco, máquinas virtuales, etiquetado de recursos y tareas de backup; acuerdos de servicio mínimo, sobrecarga, sobreaprovisionamiento, uptime y endpoints de servicios; usuarios de la federación, almacenamiento, compatibilidad técnica, backup y despliegue de aplicaciones finalistas. Estas se encuentran especificadas en el @anexo-politicas[Anexo].

Las políticas de nomenclatura y sobrecarga se validan mediante el lenguaje _Rego_, visto en el ejemplo del @rego, mientras que las demás están implementadas como código del despliegue en Puppet.

#let ruby_hook = read("fragments/ruby_hook.rb")

#figure(
  listing(raw(ruby_hook, lang: "ruby")),
  placement: auto,
  caption: [  Código Ruby para el control de despliegue tras validación de políticas. ]
) <rhook>

En el @rhook se resalta una parte de un _hook_ implementado, visto en el @resource-allocate[Anexo], que se ejecuta tras la creación de un recurso en _OpenNebula_, que tenga asociado este script ruby.
Esta es la parte de implementación más directa del @pseudo-policy.
Destaca el uso de librerías personalizadas, o _middleware_, para la comunicación con _OPA_, la API de _OpenNebula_ y el endpoint donde _Prometheus_ exporta las métricas de la federación.

=== Servicio de monitorización


Se emplea _Prometheus_ #footnote[https://docs.opennebula.io/6.10/management_and_operations/monitor_alert/overview.html] como sistema de monitorización por su integración con _OpenNebula_ y porque el tipo de métricas que ofrece permiten implementar las políticas de forma más directa.

Se consiguen cubrir las métricas de la federación, del estado de los servidores de cómputo, el de _OpenNebula_, como servicio, y el almacenamiento de la federación, siguiendo el despliegue mencionado en la @impl-fed-deploy.
Estas métricas son accesibles desde un mismo _endpoint_.
Mediante el uso de métricas personalizadas definidas en _Prometheus_, que se detallan en el @prometheus-metrics[Anexo], se implementan algunas políticas de servicio mínimo.

Ceph cuenta con su propio servicio de monitorización, a través de los _managers_, que servirán para consultar el estado del clúster. El driver de Ceph para los datastores de imagen y sistema se encarga de recuperar estas métricas y exponerlas como el estado de los datastores.


=== Interacción con los servicios

Para ligar los eventos de creación y eliminación de máquinas virtuales, imágenes y trabajos de backup con el sistema de validación se definen dos hooks de _OpenNebula_, ambos son un script Ruby.
Uno de ellos interpreta la plantilla en formato XML del recurso en cuestión, valida los parámetros recibidos y el contexto de la operación mediante una petición HTTP a la API REST de OPA y actúa consecuentemente con el resultado obtenido.
Opcionalmente, realiza una petición HTTP, con una consulta en PromQL, al endpoint de Prometheus para obtener algunos parámetros que validar posteriormente.
En caso de no cumplir la política, el recurso se elimina a través de la interfaz de Ruby que ofrece _OpenNebula_.
El otro _hook_ actualiza la lista de máquinas a las que aplicar un trabajo de _backup_ concreto.
La implementación concreta de estos hooks puede encontrarse en el @hooks-anex[Anexo].

La otra parte de la definición de un hook es una plantilla que interpreta _OpenNebula_.
El @hook-templ muestra una de estas plantillas.
En ella se especifica la ubicación del script (_COMMAND_), el evento que inicie su ejecución (_CALL_) y los argumentos para el programa (_ARGUMENTS_).
_OpenNebula_ ofrece dos tipos de eventos a los que suscribir un hook: cambios de estado (_state hooks_) o peticiones API (_API hooks_).
Se suscriben los hooks a las peticiones API de creación (_allocate_) y eliminación (_terminate_), respectivamente.
Un mismo script puede ser ejecutado por varias plantillas, mientras no haya dos plantillas que estén suscritas al mismo evento.

#let hook_templ = read("fragments/hook_templ.txt")

#figure(
  listing(raw(hook_templ, lang: "text")),
  caption: [ Plantilla de un hook de OpenNebula. ]
) <hook-templ>


=== Catálogo de la federación

La arquitectura de almacenamiento, en Ceph @ceph-docs, escogida para la replicación y visión unificada del contenido del _Marketplace_ es la \"Multi-zona\" #footnote[https://docs.ceph.com/en/quincy/radosgw/multisite/#varieties-of-multi-site-configuration].
Esta consiste en un reino (_realm_), que es el dominio de acción de la federación, con un _zonegroup_ (o región) que cuenta con dos zonas: maestra y secundaria.
Hay una zona en cada clúster de las entidades federadas y a las que responden los Rados Gateway (RGW), servicios de Ceph que exponen una interfaz compatible con S3.
Hay diferentes tipos de usuarios, uno encargado de la replicación entre zonas, con permisos de administrador, y otro con el que _OpenNebula_ accede al almacenamiento del _Marketplace_.
Este último es el propietario del _bucket_ donde se almacenan los objetos del _Marketplace_ privado de la federación.
Se puede seguir la definición de estos recursos en el @puppet-storage[Anexo], en la subsección de _Scripts_ y @tofu-manifests[Anexo], en el apartado del _Marketplace_.

Hay un servicio balanceador que distribuye la carga entre las zonas y que reside en una red alcanzable por todos los nodos de la entidad, la red frontal.
Se emplea el software _HAProxy_ para este servicio y donde se define un _frontend_ cuyo único _backend_ ejerce una política de _Round Robin_ entre los _RGW_.
Con esta arquitectura se consigue la disponibilidad del dato desde cualquier entidad de la federación y tolerancia al fallo de alguna de las zonas dentro del _zonegroup_.


== Implementación de la Recuperación ante Desastres <backup-impl>
La implementación se enfoca en las dos necesidades planteadas en el diseño: servicio de backup y repositorio que se comunique con Ceph.
Para este servicio se usa _Restic_, el cual cuenta con integración nativa en _OpenNebula_ e implementa las necesidades de backup básicas (deduplicación, versionado y encriptado).
Para la incorporación del driver a _OpenNebula_, se tiene que crear un nuevo _datastore_ de tipo _BACKUP_DS_.
Ya que el driver de _Restic_ en _OpenNebula_ todavía no implementa la comunicación mediante la interfaz S3, se despliega una máquina virtual en la que se monta un sistema de ficheros compartido CephFS.
El punto de montaje es un directorio que es accedido por el driver de _Restic_ de _OpenNebula_, para ello se emplea el protocolo de red SFTP.

En la puesta en marcha del servicio de backup, se instalan los paquetes _rsync_ y _qemu-img_, requeridos por el driver _Restic_; se sigue la política de nomenclatura de máquinas virtuales y etiquetado; y se distribuyen las claves públicas _ssh_ de los tres núcleos a la máquina virtual.
La definición de la máquina virtual, usuario y _datastore_ pueden encontrarse en el manifiesto _OpenTofu_ de la @tofu-manifests.

Las tareas definidas, tienen en cuenta las políticas de backup.
Para cumplir con ellas, se especifican los modos de agente (atributo _FS\_FREEZE=\"AGENT\"_) o suspensión (atributo _FS\_FREEZE=\"SUSPEND\"_) según la naturaleza de la máquina virtual.
Los backup se realizan de manera incremental usando como base el _snapshot_ cada cuatro repeticiones. Las copias intermedias emplean la técnica de _Copy On Write_ (_CoW_).
Siguiendo este método, se guarda también el estado de la máquina virtual de forma consistente en caso de fallo.
En el @backup-job se ve la aplicación de una tarea para los servicios básicos de _OpenNebula_ (tres núcleos en HA con sus bases de datos).

#let backupjob = read("fragments/backupjob.txt")


#figure(
  listing(raw(backupjob, lang: "text")),
  placement: auto,
  caption: [
    Definición de la tarea de backup one-10-90 en _OpenNebula_
  ]
) <backup-job>

Para la incorporación de nuevos servicios al sistema de backup, se define un nuevo _hook_.
Este leerá la etiqueta de la máquina virtual para determinar su prioridad y asignará su identificador a la tarea que le corresponda según la prioridad.
Habrá igualmente otro _hook_ definido para el borrado de máquinas donde se eliminará su identificador de la tarea.
Ambos pueden encontrarse en el @hooks-anex[Anexo].



== Despliegue <impl-deployment>

=== Infraestructura

#let puppet_virt_deploy = read("fragments/puppet_virt_deploy.pp")

#figure(
  listing(text(size: 11pt,raw(puppet_virt_deploy, lang: "puppet"))),
  placement: auto,
  caption: [ Despliegue, en _Puppet_, de la federación _OpenNebula_, zonas en HA y pooles de Ceph. ]
) <puppet_virt_deploy>

Se opta por la herramienta de despliegue automático Puppet @puppet-docs porque permite definir las relaciones entre recursos de manera más granular y la naturaleza del problema permite instalar en cada servidor del despliegue un agente Puppet.
Este tipo de herramientas permiten modelizar los recursos de un sistema y automatizar el aprovisionamiento de servidores, sin modificar las características previamente configuradas.
El @puppet_virt_deploy muestra un ejemplo de código _Puppet_.

En Puppet se definen los módulos _storage_ y _virt_ para el despliegue de cada parte de la infraestructura por separado.
La relación de despliegue entre estos módulos se rige por la que se ha diseñado en la @deploy-design.
Se ha empleado Bolt @bolt para el despliegue distribuido de estos recursos y Vagrant @vagrant-libvirt para el aprovisionamiento y despliegue de las máquinas virtuales que simulan cada sede.
El detalle más fino y el uso de recursos personalizados de Puppet de estos módulos se comenta en el @puppet-manifests[Anexo].

=== Servicios de la federación <impl-fed-deploy>

Se emplea _OpenTofu_ @opentofu-docs para la segunda etapa del despliegue ya que se están desplegando recursos que gestiona _OpenNebula_.
OpenTofu guarda en un fichero el estado del despliegue de los recursos, lo que permite no duplicarlos, actualizarlos cuando se modifican o eliminarlos si se desea.
Hay que tener cuidado con el borrado de este fichero de estado, ya que el despliegue de futuros recursos sería inconsistente y podría afectar al estado de los servicios existentes.

En el @tofu-manifests[Anexo] sigue de forma ordenada el despliegue de los recursos que se van a presentar.
En una primera fase, se crean los usuarios y grupos de cada zona con los que luego se despliegan el resto de recursos.
En esta fase se emplea el usuario administrador de la federación, _oneadmin_.

Se crea una imagen de disco, _cloud init_, provista a través del paquete de contextualización #footnote[https://docs.opennebula.io/6.10/management_and_operations/guest_os/kvm_contextualization.html] de _OpenNebula_ e instalado el sistema operativo _Debian_.
Esta imagen se crea como no persistente, de forma que pueda ser utilizada por las máquinas virtuales en las que se despliegan el _backup_ y _OPA_, como imágenes volátiles.

Al iniciar la máquina se ejecuta un script que instala los paquetes necesarios y monta el sistema de ficheros compartidos que expone las políticas.
En esta máquina virtual se instala _Docker_ y se despliega _OPA_. En el anexo @passthrough se detalla un problema encontrado con este despliegue.

Se define un nuevo sistema de ficheros en Ceph, _policies_, montado en la máquina virtual para que el contenedor pueda acceder a las políticas mediante un volumen. Este actúa como repositorio, comunicando los objetos a guardar con Ceph, a tráves de la red. El contenedor se despliega localmente con exposición en el entorno físico-virtual de la máquina desde el puerto _2345_.

Para la monitorización de la infraestructura, se despliega un contenedor separado que ejecuta el software de Prometheus, este ofrece el _endpoint_ en el que se exponen las métricas.
Los exportadores de métricas se distribuyen como paquetes de software desde el repositorio oficial de _OpenNebula_; estos instalan agentes de exportación de métricas en los nodos de virtualización y en los núcleos y datastores de _OpenNebula_.

El manifiesto del _Marketplace_ de la federación define los permisos de uso a todos los usuarios de la federación, gestión solo al grupo que pertenezca el recurso y administración al propietario.
En este manifiesto se declara también la conexión, mediante el protocolo S3, con el balanceador de la red frontal.


//Total palabras implementación: #impl.words
])

#pagebreak()
#word-count(pruebas => [
= Validación y Pruebas realizadas

== Validación

Existen recursos que tienen dependencias que no se pueden expresar mediante las herramientas de despliegue automático utilizadas.
Por lo general, las herramientas de despliegue automático emplean lenguajes declarativos y no pueden gestionar dependencias generadas en tiempo de ejecución, de forma nativa (e.g. Esperar a que un recurso alcance un estado concreto).
Mediante la ejecución de lógica personalizada, que sirve como barrera para confirmar el estado deseado del clúster, se previene el despliegue prematuro de estos recursos.
Así, se valida que el comportamiento final de los componentes es el esperado.

Las relaciones de orden para la configuración de los nodos en alta disponibilidad, establecer la federación y la \"Multi-zona\" de Ceph son estrictas e involucran mezclar distintos tipos de recursos.
Por este motivo, se valida el despliegue automático de la infraestructura, generando el grafo de dependencias que ofrece Puppet, para comprobar el orden en el que se despliegan los recursos.
El flujo de _logs_ generados por el líder de cada zona de la federación sirve para detectar errores en la configuración o fallos en el despliegue.
Creando usuarios en _OpenNebula_, en cualquiera de las zonas, se comprueba que la replicación interna funciona si se pueden listar los usuarios desde ambas zonas.
Para Ceph, se controla el estado del clúster en todo momento, consiguiendo determinar que el número de OSDs requeridos para los sistemas de ficheros y la interfaz S3 es de 5, si no, los _placement group_ quedaban desprovistos de los OSDs necesarios.

Las políticas implementadas con el lenguaje _Rego_ se validan en el entorno controlado #footnote[https://play.openpolicyagent.org/] de pruebas que ofrece la propia herramienta.
Se comprueba como con distintos valores de la entrada, la salida variaba según el comportamiento esperado.

== Pruebas

A continuación se presentan dos pruebas generales que comprueban el correcto funcionamiento del sistema implementado.
Previo a ellas, se completan una serie de pruebas.
La primera comprueba que la infraestructura se despliegue correctamente, para ello se prueba que los paquetes de red llegan a los distintos componentes dentro de la misma federación y que los núcleos de _OpenNebula_ se encuentran en un estado estable.
Se sigue por comprobar que se consiguen desplegar las máquinas virtuales definidas en los manifiestos _OpenTofu_.
Más tarde se prueba mediante el _script_ que utilizan los _hooks_, a modo de test, que se obtiene la respuesta esperada del _endpoint_ de _OPA_ y que se procedería a la eliminación del recurso desplegado, en el caso correspondiente.

=== Prueba de sobrecarga

Esta prueba involucra la recolección de métricas del servicio de monitorización, la aplicación de políticas de SLA, sobrecarga en este caso, y su interacción con el subsistema de hooks de _OpenNebula_.
Además, fuerza la portabilidad de los servicios en la federación, para su despliegue inmediato en cualquier entidad mediante el uso de _IaC_.
Esto permite validar posibles políticas de infraestructura, aquellas que se escapen del alcance del servicio de validación de políticas, y la organización de usuarios en la federación, permitiendo un acceso más restringido a usuarios de zonas ajenas a la que despliega el recurso.

Se despliega una máquina virtual en una zona de _OpenNebula_, ejecutando tareas de cómputo exigentes, tales que lleguen a superar el 80% de utilización de _vCPU_.
Entonces, se prueba que se impida el despliegue de una nueva máquina virtual.
Este efecto debe ser visible solo para usuarios de una zona diferente a donde se está desplegando el recurso, diferenciando a nivel organizativo usuarios de entidades distintas.

Para llevar a cabo esta prueba, primero se despliega una máquina virtual con imagen base no persistente sobre la que se instala el software _cpuburn_. Se usa esta nueva imagen en la plantilla de máquina virtual que después se despliega hasta conseguir superar el 80% de utilización de _vCPU_.

Se ha visto como la herramienta _cpuburn_ #footnote[https://patrickmn.com/projects/cpuburn/] es muy agresiva y rápidamente ha aumentado la carga del nodo KVM, alcanzando el porcentaje objetivo en menos tiempo que el periodo de recolecta de métricas. Por ello, se ha reconfigurado el periodo inicial, rebajándolo a 2 segundos.

Aún así, la aplicación de la política ha sido correcta y se ha impedido la creación de una nueva máquina virtual, probando el correcto funcionamiento del sistema de monitorización y la validación de políticas.

=== Prueba de backup

Para probar el despliegue del backup se va lanza una tarea en _OpenNebula_ que almacena el estado de una de las bases de datos de uno de los núcleos. Dado que la base de datos utilizada (MariaDB) ya cuenta con un plan de backup, se va a hacer la copia del contenido de la máquina virtual que la almacena. Para esto, en el entorno de simulación se despliega una nueva máquina virtual que actuará como el cuarto núcleo de _OpenNebula_ para la zona _maestra_.

La ejecución del plan ha congelado momentáneamente el sistema de ficheros, hecho probado mediante la ejecución de un script a modo de agente, que lista el directorio raíz y manda una baliza a un puerto escuchando en otra máquina.
Tras haberse ejecutado el plan definido, la ocupación del datastore ha aumentado, según muestra la monitorización del mismo ofrecida por _OpenNebula_.
Este aumento ha sido de un 40% menos que la imagen original, debido a la compresión.
También ha crecido la ocupación de los OSD en el pool de backup y se ha repartido la carga de forma homogénea entre los OSD con device class \"backup\". Entre los tres OSD suman una carga ligeramente mayor que el tamaño de la copia, debido a los bloques de paridad.
Esto enseña el uso de la técnica erasure code en el pool.

Seguidamente, se ha eliminado la máquina virtual y se ha recuperado del backup, lo que ha conllevado la replicación entre núcleos, visto en los logs del núcleo recuperado.

//Total palabras pruebas: #pruebas.words
])


#pagebreak()

#word-count(conclusiones => [
= Conclusiones y Trabajo futuro


Se ha conseguido el objetivo de desplegar el prototipo de una federación entre dos instancias de _OpenNebula_, que sirva como primer paso para un posterior despliegue real con dos entidades en zonas geográficamente separadas.
El correcto despliegue de los componentes de _OpenNebula_ y Ceph, ha probado la validez de la infraestructura simulada.
Pese a ello, se han encontrado una serie de problemas que han dificultado el despliegue de la infraestructura inicial, pero se han resuelto satisfactoriamente.
El uso de los manifiestos de despliegue automático ayudará en parte al despliegue real.

Las pruebas han demostrado que los servicios principales funcionan como se esperaba, que la infraestructura soporta la traslación de recursos virtuales entre zonas de _OpenNebula_ y las políticas implementadas aseguran el uso adecuado de la federación.

La red frontal diseñada ha quedado desprotegida, en el contexto de la seguridad. Por ello, habría que considerar la incorporación de un router perimetral que actúe como un firewall. Estaría controlado por software y permitiría cumplir políticas de enrutado y control de acceso, independientemente del hardware utilizado.
Un aspecto de relevancia para ciertos tipos de despliegue, sería la definición de \"servicios\" de _OpenNebula_ que permiten desplegar conjuntos de máquinas virtuales con una relación concreta entre ellas.
Para ello, se deberán habilitar los servicios de OneFlow y OneGate.
Quedan abiertos al diseño otros aspectos como la seguridad, modelado de usuarios más complejo y migración en caliente de máquinas virtuales entre sedes.

//La migración entre zonas queda fuera de este proyecto ya que la federación en _OpenNebula_ #footnote[https://docs.opennebula.io/6.10/installation_and_configuration/data_center_federation/overview.html] se ha diseñado como un sistema de compartición de recursos estáticos.
//Los recursos esenciales de _OpenNebula_ (scheduler, OneFlow y OneGate para despliegue de servicios) #footnote[https://docs.opennebula.io/6.10/installation_and_configuration/opennebula_services/overview.html] se gestionan localmente.
//
//La solución de recuperación ante desastres se centra en presentar una arquitectura funcional que permita guardar la información de la federación.
//Esta llega hasta el almacenamiento principal, Ceph.
//Una gestión más tradicional del almacenamiento, en este ámbito, queda fuera de este proyecto.

Personalmente, considero que este proyecto ha sido un importante motor de conocimiento para proyectar los conceptos aprendidos durante la carrera. No solo me ha permitido conocer en profundidad las herramientas utilizadas, los algoritmos que las hacen funcionar y los conceptos en los que se basan, si no que también entender porqué herramientas de software libre permiten garantizar la soberanía de la información que uno genera.

//Total palabras conclusiones: #conclusiones.words
])

#pagebreak()

#show bibliography: set heading(numbering: none)
#bibliography("bib.yaml")
#pagebreak()

#set heading(numbering: none)
#{
  show heading: none
  heading(numbering: none)[Anexos]
}

#counter(heading).update(0)
#set heading(
  numbering: "A.1"
)

= Diagrama de Gantt

#figure(
  image("images/gantt.png"),
  caption: [ Diagrama de gantt. ],
) <gantt>

#pagebreak()

= Especificación de las políticas <anexo-politicas>

A continuación se especifican todas las políticas que se han implementado usando _Rego_, las métricas de _Prometheus_ y otros métodos.

== Nomenclatura
Todas los nombres tendrán como prefijo común el nombre de la entidad. Se emplea una barra lateral (_\/_) como separador. El @rego muestra un ejemplo de una política de nombrado implementada usando el lenguaje _Rego_.
+ *Nombrado de etiquetas:*<policies-naming-labels> \<nombre-etiqueta\> (ej. one-10/prod)
+ *Nombrado de máquinas virtuales:*<policies-naming-vms> \<nombre-usuario\>/\<nombre-maquina\> (ej. one-10/user10/ntp)
+ *Nombrado de imágenes:* <policies-naming-images> \<nombre-usuario\>/\<nombre-imagen\> (ej. one-10/user10/Ubuntu)
+ *Nombrado de tareas de backup:*<policies-naming-backup> \<prioridad\> (ej. one-10/90)
+ *Nombrado de _hooks_:*<policies-naming-hooks> hook/\<nombre-hook\> (ej. one-10/hook/update-backupjob)

== Servicio mínimo

+ *Sistema de monitorización:* Cada entidad contará con un sistema que monitorice la actividad local de _OpenNebula_.  #[
  + *Punto de enlace*: Definir una IP virtual donde establecer la comunicación de la federación.
  + *Exposición de métricas:* Las métricas se expondrán en formato _JSON_ accesibles desde el punto de enlace definido en la ruta _/metrics_ y su esquema en _/metrics/schema_ que deberá coincidir con el esquema esperado por la federación.
  + *Periodo de monitorización:* Se establecerá una frecuencia de monitorización de 30 segundos.
  + *Control de acceso:* Habrá un grupo de usuarios con permisos, exclusivamente, de consulta de métricas llamado \"fed-exporter\".
]
+ *_Uptime_ (tiempo en línea) de servicios:* 99% de tiempo en línea requerido para cada uno de los servicios etiquetados como producción. Se comprobará que el _LCM STATE_ tenga el valor _ACTIVE_
+ *Definición de downtime o caída:* Un servicio se considera caído si no se exportan sus métricas durante un periodo entero y el estado de la máquina virtual en la que se ejecuta en _OpenNebula_ es _ERROR_, _POWEROFF_ o no existe. En el caso de que la máquina esté activa (estado _ACTIVE_) se mirará el estado de su ciclo de vida o _LCM STATE_ y comprobará que está en un estado diferente a _ACTIVE_.
+ *Sobreaprovisionamiento:* #[
  + *Proporción:* No se podrán aprovisionar más _CPU_ reales que _vCPU_.
  + *Rango de sobreaprovisionamiento:* El rango por defecto será de hasta 2:1 (2 _vCPU_ por cada _CPU_ real).
  + *Memoria de respaldo:* La cantidad de _swap_ presente en los nodos KVM deberá soportar la carga de sobreaprovisionamiento de memoria asignada en un momento dado.
  + *Etiquetado:* Para incrementar la capacidad de sobreaprovisionar una máquina virtual, se deberá etiquetar como \"comp\" o \"storage\" para poder sobreaprovisionar la máquina por encima del por defecto, impidiendo que servicios que no lo necesiten, hagan un uso indebido (política de _opt-in_). El máximo establecido es de 6:1.

]
+ *Sobrecarga:* Los porcentajes presentados responden a la intuición que se tiene de las capacidades del sistema previsto, la realidad dependerá de la robustez de cada uno de los miembros. #[
  + Una entidad no podrá desplegar más máquinas virtuales si la utilización de _vCPU_ está por encima del 80%.
  + Una entidad no podrá desplegar más máquinas virtuales cuyas imágenes sean persistentes si el almacenamiento supera el 90%.
]


== Backup

+ *Tipo de backup:* Se realizarán backups completos cada 4 incrementales.
+ *Modo de backup:* Si el almacenamiento de un servicio se basa en bloque (bases de datos), se escogerá el modo _CBT_ de _OpenNebula_ para seguir cambios a nivel de bloque. Si un servicio solo interactúa con el sistema de ficheros, se escogerá el modo _snapshot_ con diferenciales de _Copy On Write_.
+ *Proceso de backup:* Si un servicio cuenta con solución de backup integrada, se deberá activar dicha solución antes de empezar el backup desde _OpenNebula_.

== Almacenamiento

+ *Uso de imágenes:* El uso de imágenes persistentes estará restringido a máquinas que solo tengan desplegada una instancia y no haya una imagen persistente ya creada en al que basarse. Se deberá hacer uso de imágenes no persistentes en cualquier otro caso.
+ *Marketplace:* #[
  + Las imágenes publicadas tendrán instalados el paquete de contextualización de _OpenNebula_.
  + El usuario _oneadmin_ no podrá publicar imágenes.
]
+ *Ceph:* #[
  + Los pooles de metadatos tendrán una regla CRUSH que los asigne a OSDs con los discos de menor latencia.
  + El pool de backup tendrá asignados los OSD con device class _backup_.
]

== Usuarios y grupos

+ *Administradores:* El usuario _oneadmin_ es global a la federación y solo tendrá permisos sobre las máquinas desplegadas para el backup. En cada entidad habrá un administrador que tendrá un uso privilegiado sobre su zona y pertenecerá al grupo de administradores de la federación.
+ *Uso de imágenes:* Cada usuario tendrá como grupo primario el de su zona y el administrador de zona podrá añadirlo a los grupos de la federación oportunos.

== Políticas de aplicación

+ *Gateways de acceso a Internet:* Toda aplicación debe tener tener conexión a Internet a través de alguna de las puertas de enlace definidas para ese propósito dentro de la federación.
+ *Etiquetado:* Toda aplicación debe estar correctamente etiquetada. Deberá distinguirse si corresponde a un servicio en producción, en desarrollo o pruebas. Para ello emplear los nombres \"prod\", \"dev\" y \"test\".
+ *Replicación mínima:* Las aplicaciones etiquetadas como producción, deberán tener, al menos, dos instancias en ejecución en entidades federadas distintas.

== Compatibilidad técnica

Cada entidad debe presentar una instancia de _OpenNebula_ como software de gestión de máquinas virtuales y, opcionalmente, Ceph como sistema de almacenamiento. En su defecto, el diseño del almacenamiento debe ser similar al planteado en la fase de diseño.
Se ha de emplear _KVM_ como hipervisor y _Restic_ #footnote[https://docs.opennebula.io/6.10/management_and_operations/backups/restic.html?highlight=backup] como driver del datastore de backup.
El resto de servicios pueden tener una implementación diferente a la presentada en los siguientes apartados.

#pagebreak()



= Implementación de políticas <rego-policies>

A continuación se muestran las dos políticas implementadas usando el lenguaje _Rego_.
La primera implementa las políticas de nombrado de máquinas virtuales, imágenes _OpenNebula_, _hooks_ y trabajos de _backup_.
La segunda detalla la política de sobrecarga, que forma parte de las políticas de acuerdo de servicio mínimo.


== Política de nombrado

En el código, se obtiene de la entrada (variable _input_) el contexto en el que se está desplegando cada recurso, esto es, el nombre de la entidad y nombre de usuario.
En el campo _action_ se definen el nombre del recurso dado por el usuario (_resource_name_), el recurso al que afecta la acción y, opcionalmente, la etiqutea (_label_) que tiene asignada.
Primero se comprueba que la acción corresponda a algún recurso de los definidos, seguidamente se aplican las reglas establecidas en el @anexo-politicas[Anexo].

#let naming_rego = read("fragments/rego/resource_allocate.rego")
#raw(naming_rego, lang: "rego")


== Política de sobrecarga

Aquí, la variable de entrada solo contiene el campo de acción (_action_) cuyos campos se relacionan directamente con las métricas obtenidas desde _Prometheus_.

#let load_rego = read("fragments/rego/load.rego")
#raw(load_rego, lang: "rego")

== Políticas de _uptime_ y _downtime_ <prometheus-metrics>

#let prom_alert_group = read("fragments/prometheus_uptime.yml")

#figure(
  listing(raw(prom_alert_group, lang: "text")),
  caption: [ Grupo de reglas Prometheus que detectan las políticas de uptime y downtime. ]
) <prom_alert_group>

En el @prom_alert_group se muestra un ejemplo de implementación de las políticas de uptime y downtime mediante grupos de reglas de Prometheus. La naturaleza de estas políticas invitan a enviar alertas a la federación más que esperar a que suceda algún evento para comprobar si el recurso cumple las políticas. Así, se consigue monitorizar el estado de los servicios de backup y validador de políticas.


#pagebreak()

= Problemas encontrados

== Despliegue en contenedores de Ceph <why-ceph-containers>

Ceph está desplegado en contenedores ya que involucra la definición de un número _a priori_ indefinido de OSD. No se contempla la posibilidad de definir nodos LXC en _OpenNebula_ en esta versión temprana del proyecto, principalmente por la limitación de recursos de los que se dispone (se necesitaría otro servidor de virtualización). Al emplear la tecnología de contenedores, se tiene que hacer uso de un orquestador o una herramienta de despliegue automático que gestione los contenedores.

== Múltiples instancias _OpenNebula_ en único servidor<server-problems>

Cada instancia de _OpenNebula_ tendrá como único host de virtualización el mismo servidor donde se ha desplegado.
Siendo que _OpenNebula_ define dominios de _libvirt_ al crear máquinas virtuales, y hay dos instancias de _OpenNebula_ corriendo, existe la posibilidad de que se creen dominios con identificadores duplicados.
Por ello, ha habido que modificar el estado de _OpenNebula_, a nivel de base de datos, para que una de las instancias comience con un identificador de máquinas virtuales superior al otro. La entidad esclava empieza por el identificador 100.

== Bucles de red <network-problem>

La implementación del esquema de red del entorno de simulación es relativamente compleja.
En este escenario, se ha detectado la presencia de bucles de red entre el router, los _bridge_ y la interfaz VETH que une los _bridge_.
Para solucionar esta situación se ha activado el protocolo STP en los _bridge_, otorgándoles máxima prioridad para que la interfaz de VETH no quede en desuso.
Por otro lado, la topología de red presentada es tolerante al fallo de la interfaz que une los bridges, a expensas de incrementar las latencias entre _OpenNebula_ y Ceph, lo cual no supone problemas graves.

== Contenedores en máquina virtual <passthrough>
Se ha de habilitar el modo de CPU _host-passthrough_ @host-passthrough @invalid-xml activo para permitir el uso de contenedores en una máquina virtual. Para ello, se ha desactivado el atributo restringido de _OpenNebula_ #emph[VM_RESTRICTED_ARGS=\"RAW/DATA\"].
Se han definido también los siguientes ACL para que los usuarios _backup_ y _policies_ puedan instanciar sus máquinas virtuales: \
#align(center)[#emph[oneacl create \"\@115 VM\+NET\+IMAGE\+TEMPLATE\/\* CREATE\+USE\+MANAGE\+ADMIN\"]]
#align(center)[#emph[oneacl create \"\@114 VM\+NET\+IMAGE\+TEMPLATE\/\* CREATE\+USE\+MANAGE\+ADMIN\"]]

#pagebreak()

= Implementación del modelo de ejecución de eventos <hooks-anex>

Todos los _hooks_ definidos en _OpenNebula_ tienen prefijadas con unas líneas que definen la ubicación de las librerías de ruby que usa _OpenNebula_.

#let hooks_prefix = read("fragments/one-hooks/prefix.rb")
#raw(hooks_prefix, lang: "ruby")

== Hook creación de recursos <resource-allocate>
Este código es el referenciado en varias partes de la memoria.
Se interpreta la plantilla XML que _OpenNebula_ pasa como parámetro a cualquier _hook_, codificada en base 64.
Se validan las políticas de nombrado y de sobrecarga. Para el recurso de trabajos de _backup_, se añade el identificador del recurso presentado a una la lista de máquinas virtuales en los trabajos de _backup_ principales.
#let creation_hook = read("fragments/one-hooks/resource_create.rb")
#raw(creation_hook, lang: "ruby")

== Hook eliminación de recursos

En esta ocasión, solo hay que eliminar de la lista de máquinas virtuales del trabajo de backup correspondiente al recurso que se quiere eliminar.

#let terminate_hook = read("fragments/one-hooks/resource_terminate.rb")
#raw(terminate_hook, lang: "ruby")

== Librerías para los hooks

A continuación se ofrece el código correspondiente al _middleware_ utilizado para interactuar con _OPA_, la interfaz _ruby_ de _OpenNebula_ y para _parsear_ la entrada en formato XML de los _hooks_.

=== OPA

#let opa_lib = read("fragments/one-hooks/lib/opa.rb")
#raw(opa_lib, lang: "ruby")
#pagebreak()

=== _OpenNebula_

#let nebula_lib = read("fragments/one-hooks/lib/nebula.rb")
#raw(nebula_lib, lang: "ruby")
#pagebreak()

=== Parsing

#let parsing_lib = read("fragments/one-hooks/lib/parsing.rb")
#raw(parsing_lib, lang: "ruby")
#pagebreak()

= Manifiestos Puppet <puppet-manifests>

En este anexo se documenta cada módulo _Puppet_ definido en el despliegue de la infraestructura.
Cada uno de estos módulos consta de manifiestos en lenguaje _Puppet_, _scripts_ en lenguaje _ruby_, plantillas expresadas en metalenguaje _epp_ y funciones de utilidad compartidas para todo el módulo, también en lenguaje _ruby_.

== Módulo de almacenamiento <puppet-storage>
Este módulo define los componentes esenciales para el despliegue de un clúster Ceph en un única máquina.
Pese a existir distintos módulos Puppet en la comunidad que despliegan Ceph, no se han podido adecuar a las necesidades concretas de este proyecto.
También se define el almacenamiento local del nodo de virtualización, siguiendo la estructura LVM descrita en la implementación.

Los _scripts_ de interés en este módulo son el de creación de dispositivos de bloque, que simulan sectores de disco distribuidos en la red, RBD, la creación de la arquitectura \"Multi-zona\" de _Rados Gateway_ y la preparación del particionamiento lógico LVM.

Se ha empleado una plantilla _epp_ que genera el fichero de configuración de Ceph, _ceph.conf_.

El módulo contiene tanto el almacenamiento local, con la definición de la estructura de LVM, como los recursos Ceph.
El almacenamiento local no tiene dependencias internas ni externas, pero Ceph depende de los recursos de red y del almacenamiento local.
Internamente, primero se despliegan los monitores, después los _managers_ y posteriormente los OSD y MDS.
Se termina con los RGW, la arquitectura \"Multi-zona\" y la creación de pooles.

=== Manifiestos
*Almacenamiento local*

Manifiesto que crea la estructura de LVM mencionada en la implementación.
Se instala el paquete de _lvm2_ según el sistema operativo y posteriormente se crea un grupo volumen cuyos volúmenes físicos son los dispositivios especificados como parámetro.
Los volúmenes lógicos se crean también a partir del parámetro _lvs_ de la clase definida.

#let lvm_stor_puppet = read("fragments/puppet/storage/lvm_stor.pp")
#raw(lvm_stor_puppet, lang: "puppet", align: center)
#pagebreak()

*Ceph*

Dentro de la primera etapa del despliegue de la infraestructura, también se despliega un clúster Ceph en alta disponibilidad.
Este clúster cuenta con tres monitores, 2 _managers_, 5 OSD, 4 MDS y 1 RGW.
Los monitores son los primeros en ser desplegados, para luego permitir la incorporación de managers, OSDs y MDS.
Posteriormente, se puede crear el entorno de alta disponibilidad escogido para el Marketplace con, al menos, un gateway de RADOS en cada zona.
La elección de contenedores para los servicios se discute en el @why-ceph-containers[Anexo].

Este manifiesto instala un clúster Ceph sobre la infraestructura concreta del prototipo.
Primero se instala la herramienta _cephadm_ que ayuda a administrar el clúster.
Primero, se despliega un solo monitor que instale su configuración y después otros dos monitores que reciben la configuración del primero.
Se habilita la segunda versión del protocolo de comunicación con los monitores _msgr2_.
Siguen los _managers_ y los OSD. Por último se crean los MDS y la arquitectura Multi-zona.

#let ceph_puppet = read("fragments/puppet/storage/ceph.pp")
#raw(ceph_puppet, lang: "puppet")
#pagebreak()

*Cephadm*

Manifiesto que instala la herramienta _cephadm_.
Tiene una serie de dependencias y requiere un fichero de configuración _ceph.conf_ que leer y poder comunicarse con los monitores.
Por último se crea una clave de administrador para poder ejecutar acciones que requieran ese privilegio.

#let cephadm_puppet = read("fragments/puppet/storage/cephadm.pp")
#raw(cephadm_puppet, lang: "puppet")
#pagebreak()

*Variables del módulo*

Manifiesto que contiene las variables utilizadas en el módulo de almacenamiento y Ceph.

#let vars_puppet = read("fragments/puppet/storage/vars.pp")
#raw(vars_puppet, lang: "puppet")
#pagebreak()

*Monitores*

Manifiesto que despliega un monitor de RADOS.
Define la imagen de contenedor que varios servicios de Ceph utilizan y define una serie de acciones a llevar a cabo si es el primer monitor del clúster en ser desplegado.
Se sigue por desplegar el contenedor y aprovisionarlo para que inicie el clúster o se comunique con los demás monitores.

#let monitor_puppet = read("fragments/puppet/storage/monitor.pp")
#raw(monitor_puppet, lang: "puppet")
#pagebreak()

*Managers*

Manifiesto que despliega un _manager_ de RADOS.
Primero se generan las claves con las _capabilities_ de acceso a los distintos servicios de RADOS para poder monitorizar su actividad.
Posteriormente se despliega el contenedor y se aprovisiona con su fichero de configuración específico, la distribución de sus claves de CephX y la puesta en marcha del demonio.

#let manager_puppet = read("fragments/puppet/storage/manager.pp")
#raw(manager_puppet, lang: "puppet")
#pagebreak()

*OSD*

Manifiesto que despliega un OSD de RADOS.
Primero se carga la utilidad de formateo de dispositivos para la instalación del sistema XFS en dispositivos locales.
Se sigue por preparar el particionamiento lógico, documentado más adelante.
Al desplegar el contenedor, se especifica el dispositivo que debe ver a través de un volumen.
El aprovisionamiento consiste en especificar el _ceph.conf_ específico y la instalación de los ficheros internos y el despliegue del demonio.

#let osd_puppet = read("fragments/puppet/storage/osd.pp")
#raw(osd_puppet, lang: "puppet")
#pagebreak()

*MDS*

Manifiesto que despliega un MDS de RADOS.
Con la puesta en marcha del clúster ya se puede interactuar directamente con los monitores.
Se crean las claves del servicio y se despliega el contenedor.
Se aprovisiona con el fichero de configuración de Ceph, la distribución de claves y la puesta en marcha del servicio.

#let mds_puppet = read("fragments/puppet/storage/mds.pp")
#raw(mds_puppet, lang: "puppet")
#pagebreak()

*RGW*

Manifiesto que despliega un Rados Gateway de RADOS, en una arquitectura Multi-zona.
Se identifica el rol que juega la zona en la que se va a crear, se crea el usario administrador para la replicación y se despliega el contenedor.
El aprovisionamiento consta del fichero de configuración y la distribución de credenciales.
Por último se incorpora el RGW a la zona concreta.


#let rgw_puppet = read("fragments/puppet/storage/rgw.pp")
#raw(rgw_puppet, lang: "puppet")
#pagebreak()

*CephFS*

Manifiesto que despliega varios MDS de Ceph.

#let cephfs_puppet = read("fragments/puppet/storage/cephfs.pp")
#raw(cephfs_puppet, lang: "puppet")
#pagebreak()

*Crear CephFS*

Manifiesto que crea un sistema de ficheros CephFS.
Se crean los pooles de datos y metadatos, sobre el que añadir capacidad de réplica mediante _erasure code_, y se crea el sistema de ficheros.
Por último se crea un usuario autorizado para operar sobre el sistema de ficheros.

#let newfs_puppet = read("fragments/puppet/storage/newfs.pp")
#raw(newfs_puppet, lang: "puppet")
#pagebreak()

*User*

Manifiesto que crea un usuario en el registro de Ceph.
Toma una serie de _capabilities_ y permite guardar el _keyring_ generado en un fichero.

#let user_puppet = read("fragments/puppet/storage/user.pp")
#raw(user_puppet, lang: "puppet")
#pagebreak()

*Pool*

Manifiesto que crea un pool Ceph.
Identifica el modo de replicación, réplica _n_ o _erasure code_ y si se va a utilizar para almacenar imágenes RBD, lo que requiere acciones adicionales.

#let pool_puppet = read("fragments/puppet/storage/pool.pp")
#raw(pool_puppet, lang: "puppet")
#pagebreak()

*RBD*

Manifiesto que crea un dispositivo de bloques RBD.
Se asegura de que el pool en el que se va a crear exista y crea una imagen dentro.
Al usuario especificado se le otorgan capacidades de explotación y se monta (_map_) el dispositivo en el punto de montaje especificado.

#let rbd_puppet = read("fragments/puppet/storage/rbd.pp")
#raw(rbd_puppet, lang: "puppet")
#pagebreak()

*S3 User*

Manifiesto que crea un usuario de s3.

#let s3_user_puppet = read("fragments/puppet/storage/s3_user.pp")
#raw(s3_user_puppet, lang: "puppet")
#pagebreak()

=== Scripts

*rbdmap*

_Script_ que instala el sistema de ficheros XFS en un dispositivo y lo monta en un punto de montaje.

#let rbdmap_puppet = read("fragments/puppet/storage/scripts/rbdmap.rb")
#raw(rbdmap_puppet, lang: "ruby")
#pagebreak()

*RGW zone creation*

_Script_ que crea la arquitectura Multi-zona de Ceph según el rol especificado en el parámetro de entrada.

#let rgw_zone_creation_puppet = read("fragments/puppet/storage/scripts/rgw_zone_creation.rb")
#raw(rgw_zone_creation_puppet, lang: "ruby")
#pagebreak()

*LVM preparation*

_Script_ que perpara un LVM para ser utilizado por un OSD.

#let prepare_lvm_puppet = read("fragments/puppet/storage/scripts/prepare_lvm.rb")
#raw(prepare_lvm_puppet, lang: "ruby")
#pagebreak()

=== Funciones

*CephX Key*

#let cephx_puppet = read("fragments/puppet/storage/functions/cephx_key.rb")
#raw(cephx_puppet, lang: "ruby")
#pagebreak()

*UUID*

#let uuid_puppet = read("fragments/puppet/storage/functions/uuid.rb")
#raw(uuid_puppet, lang: "ruby")
#pagebreak()

=== Plantillas

*Ceph Conf*

#let ceph_conf_puppet = read("fragments/puppet/storage/templates/ceph_conf.epp")
#raw(ceph_conf_puppet, lang: "text")
#pagebreak()

== Módulo de virtualización <puppet-virt>
En este módulo se documentan los aspectos relativos a los servicios de cómputo de la infraestructura, el despliegue de los núcleos, _datastores_ y nodo de virtualización de _OpenNebula_ y _gateway_ de la red frontal.
Por cada contenedor que ejecuta el software del núcleo de _OpenNebula_, hay otro contenedor corriendo una base de datos _MariaDB_.
También se aborda aquí el proceso de federación de las dos entidades federadas.
El contenedor de la puerta de enlace es el primero en ser desplegado, seguido de las bases de datos y los núcleos de _OpenNebula_.
Posteriormente se establece la comunicación entre cada núcleo, formando un único clúster en alta disponibilidad.
Se termina ejecutando los demonios encargados de exportar métricas y desplegando el contenedor Prometheus.

Los _scripts_ empleados en este módulo son los de aprovisionamiento de contenedores, uno de los más extensos, y el que simula el comportamiento requerido del demonio principal del sistema _systemd_.
El primero ofrece una interfaz con la que acceder al contexto local de cada contenedor.
Pese a sonar contraintuitivo (los contenedores vienen aprovisionados ya antes de ser desplegados), el procedimiento por el que se establece alta disponibilidad entre los tres núcleos de _OpenNebula_ requiere acceso a los contenedores en tiempo de ejecución, siendo capaz de modificar ficheros de configuración y ejecutar comandos, esperando su respuesta y sincronizando el estado de otros contenedores.
El recurso definido permite esta operativa y ofrece una interfaz por la que acceder a recursos del contenedor a través de variables personalizadas.

En concreto, primero se despliegan tres núcleos en alta disponibilidad que forman la zona maestra de la federación, seguido viene el núcleo maestro de la segunda zona con el que se establece la federación.
Una vez establecida, se incorporan dos núcleos más a la zona esclava.

Se han empleado varias plantillas _epp_ entre las que destacan las de creación de ficheros de contenedor (_Containerfile_) y la configuración de los _datastore_.

=== Manifiestos


*Unidad Systemd Podman*

Manifiesto que instala una unidad systemd de podman.

#let podman_unit_puppet = read("fragments/puppet/virt/podman_unit.pp")
#raw(podman_unit_puppet, lang: "puppet")
#pagebreak()

*Red Podman*

Manifiesto que define redes virtuales entre contenedores podman.
Estas redes están descritas en la implementación.

#let podman_network_puppet = read("fragments/puppet/virt/podman_network.pp")
#raw(podman_network_puppet, lang: "puppet")
#pagebreak()

*Aprovisionamiento de contenedores*

Manifiesto que ejecuta un _script_ ruby para aprovisionar un contenedor haciendo que cumpla con las relaciones establecidas en el plan de despliegue.
El recurso crea un fichero _JSON_ que emplea el _script_ como entrada del plan de ejecución a seguir.

#let container_provision_puppet = read("fragments/puppet/virt/container_provision.pp")
#raw(container_provision_puppet, lang: "puppet")
#pagebreak()

*Archivo de contenedor*

Manifiesto que crea un fichero tipo contenedor, _Containerfile_, y construye la imagen (_build_).

#let container_file_puppet = read("fragments/puppet/virt/container_file.pp")
#raw(container_file_puppet, lang: "puppet")
#pagebreak()

*Gateway*

El tráfico hacia el exterior es procesado por una serie de reglas de red.
En este caso, se han establecido reglas de retransmisión de paquetes entre VLAN como puede verse en la @reglas-iptables.
Este router es un contenedor _Alpine Linux_ con las reglas establecidas ya que no hay más necesidades de enrutamiento que las mencionadas.
Este contenedor se acopla a los bridge que simulan las redes públicas internas de cada entidad.
Esta configuración plantea un problema documentado en el @network-problem[Anexo].

#let rules_iptables = read("fragments/iptables.txt")

#figure(
  listing(raw(rules_iptables, lang: "text")),
  caption: [ Reglas de IPTables para retransmisión de VLAN. ]
) <reglas-iptables>

#let gateway_puppet = read("fragments/puppet/virt/gateway.pp")
#raw(gateway_puppet, lang: "puppet")
#pagebreak()

*_OpenNebula_*

Manifiesto que despliega el software de _OpenNebula_ en un modo concreto de entre los disponibles: _ha_, para desplegar tres núcleos formando un clúster de alta disponibilidad; _slave_leader_, para desplegar un solo núcleo y crear una zona esclava cuya maestra es la especificada en _zone_id_; y _slave_followers_, para desplegar dos núcleos en la zona _zone_id_.

Los datastores solo se configuran cuando se configura la zona en modo de alta disponibilidad.

#let opennebula_puppet = read("fragments/puppet/virt/opennebula.pp")
#raw(opennebula_puppet, lang: "puppet")
#pagebreak()

*Base de datos*

Despliega un contenedor que ejecuta MariaDB.
Crea la base de datos para _OpenNebula_ y guarda sus ficheros en el directorio donde se ha montado el volumen de contenedor que lo conecta con la imagen de RBD de Ceph.

#let db_puppet = read("fragments/puppet/virt/db.pp")
#raw(db_puppet, lang: "puppet")
#pagebreak()

*Frontal _OpenNebula_*

Manifiesto que despliega un núcleo de _OpenNebula_.
Se conecta a la base de datos que le corresponda.
En la parte de aprovisionamiento es donde juega un papel crucial el recurso de aprovisionamiento.
De no ser por este, se hubiese ralentizado el despliegue al tener que ejecutar constantemente recursos tipo _exec_ de Puppet.
De este modo, con la flexibilidad que ofrece un _script_, se puede ejecutar el plan de acciones pudiendo acceder a _APIs_ o librerías internas que agilizan el despliegue.

#let oned_puppet = read("fragments/puppet/virt/oned.pp")
#raw(oned_puppet, lang: "puppet")
#pagebreak()


*Datastores*

Manifiesto que crea un datastore en _OpenNebula_.
En _OpenTofu_ también se crean datastores pero este manifiesto era necesario para poder desplegar primero los núcleos.

#let datastore_puppet = read("fragments/puppet/virt/datastore.pp")
#raw(datastore_puppet, lang: "puppet")
#pagebreak()

*Soporte para Ceph Datastore*

Crea los pool en Ceph necesarios para los datastores de imagen y sistema.
Despliega también los datastores y propaga la clave Ceph al registro de libvirt.

#let ceph_puppet = read("fragments/puppet/virt/ceph.pp")
#raw(ceph_puppet, lang: "puppet")
#pagebreak()

*Nodo KVM*

Configura e instala paquetes necesarios para desplegar el demonio que conecta el nodo KVM con los núcleos de _OpenNebula_.

#let kvm_node_puppet = read("fragments/puppet/virt/kvm_node.pp")
#raw(kvm_node_puppet, lang: "puppet")
#pagebreak()


*Despliegue Zona maestra de la federacion en HA*


#let fed_masters_setup_puppet = read("fragments/puppet/virt/fed_masters_setup.pp")
#raw(fed_masters_setup_puppet, lang: "puppet")
#pagebreak()

*Despliegue de HA*

Manifiesto que modifica un núcleo en una zona formando un clúster de alta disponibilidad entre los núcleos de esa zona, eventualmente.
Toma como parámetros la información del núcleo, el identificador de la zona y la IP flotante.

#let ha_puppet = read("fragments/puppet/virt/ha.pp")
#raw(ha_puppet, lang: "puppet")
#pagebreak()

*Zona*

Manifiesto que crea una nueva zona en un despliegue de _OpenNebula_.

#let zone_puppet = read("fragments/puppet/virt/zone.pp")
#raw(zone_puppet, lang: "puppet")
#pagebreak()

*Control del estado de zona esclava*

#let stop_slaves_puppet = read("fragments/puppet/virt/stop_slaves.pp")
#raw(stop_slaves_puppet, lang: "puppet")
#pagebreak()

*Monitorización*

Manifiesto que despliega los exportadores de métricas en los núcleos de una zona y sus nodos de virtualización.

#let monitoring_puppet = read("fragments/puppet/virt/monitoring.pp")
#raw(monitoring_puppet, lang: "puppet")
#pagebreak()

=== Scripts

*Emulador systemd en contenedores*

#let mock_service_puppet = read("fragments/puppet/virt/scripts/mock_service.sh")
#raw(mock_service_puppet, lang: "bash")
#pagebreak()

*Aprovisionamiento de contenedores*

_Script_ de aprovisionamiento de contenedores.
Este ofrece una interfaz por la que poder acceder al estado del contenedor en cada momento.
Se puede acceder a aspectos de red y almacenamiento, lo cual resulta útil tras configurar interfaces de red.

#let container_provision_puppet = read("fragments/puppet/virt/scripts/container_provision.rb")
#raw(container_provision_puppet, lang: "ruby")
#pagebreak()

=== Funciones

*Estado del despliegue*

#let network_layout_puppet = read("fragments/puppet/virt/functions/network_layout.rb")
#raw(network_layout_puppet, lang: "ruby")
#pagebreak()

=== Plantillas

*Archivo de contenedor*

#let containerfile_puppet = read("fragments/puppet/virt/templates/containerfile.epp")
#raw(containerfile_puppet, lang: "text")
#pagebreak()

*Aprovisionamiento de contenedores*

#let container_provision_puppet = read("fragments/puppet/virt/templates/container_provision.epp")
#raw(container_provision_puppet, lang: "text")
#pagebreak()

*Configuración de Datastore*

#let one_ds_puppet = read("fragments/puppet/virt/templates/one_ds.epp")
#raw(one_ds_puppet, lang: "text")
#pagebreak()
//== Módulo de red <puppet-network>
//En este módulo están definidos los recursos de red definidos en la @net-impl con dependencias de despliegue internas: primero se despliegan los _bridge_ y después, sobre estas, las interfaces VETH.
//
//*Interfaces*
//
//#let ifaces_puppet = read("fragments/puppet/net/ifaces.pp")
//#raw(ifaces_puppet, lang: "puppet")
//
//*Interfaz VETH*
//
//#let veth_puppet = read("fragments/puppet/net/veth.pp")
//#raw(veth_puppet, lang: "puppet")
//
//#pagebreak()

= Planes de despliegue

Se ha empleado la herramienta Puppet Bolt para controlar el despliegue distribuido de los manifiestos definidos previamente.
Para ello se han definido una serie de planes de despliegue donde se especifican qué acciones se han de ejecutar, en este caso, se compilan y envian, a través de una conexión SSH y el protocolo Puppet, los manifiestos previamente definidos; los objetivos, es decir, las máquinas en las que existe un agente Puppet que pueda ejecutar la acción enviada; y una serie de opciones adicionales, como usuario de ejecución o distintas pruebas.

Se ha empleado Hiera para definir las variables y parámetros de las clases Puppet.
Así se consigue separar la información que corresponde cada entidad individualmente y agruparla en otros casos.

*Plan principal*

Manifiesto, referenciado en el @puppet_virt_deploy, que despliega los servicios virtualizados de una entidad, según se ha especificado en el diseño e implementación.
Primero se comprueba que exista el directorio donde crear las unidades _systemd_ de los contenedores.
Se crea la red de contenedores y el clúster Ceph.
Lo siguiente es crear el usuario s3 que emplea el _Marketplace_.
De _OpenNebula_, lo pirmero que se despliega es la zona maestra con 3 núcleos forman el clúster en alta disponibilidad.
Esto se consigue con el recurso _Puppet_ personalizado _virt::services::opennebula_ y el modo _ha_.
Lo siguiente es desplegar un único núcleo en una zona distinta en modo _slave_leader_.
Este último evento y la zona maestra son eventos concurrentes.
El parámetro _zone_id_ corresponde al identificador de la zona maestra.
Cuando se han desplegado la zona maestra y la esclava, se despliega el recurso que federa ambas zonas.
Se termina formando el clúster de alta disponibilidad en la zona esclava y desplegando los recursos de Ceph para los servicios de backup, _OPA_ y monitorización.
Además se corrigen algunos de los problemas encontrados y descritos en el anexo correspondiente.

#let main_bolt = read("fragments/plans/deploy_federation.pp")
#raw(main_bolt, lang: "puppet")
#pagebreak()

*Plan despliegue de red*

#let net_bolt = read("fragments/plans/net_ifaces.pp")
#raw(net_bolt, lang: "puppet")
#pagebreak()

*Plan despliegue de Ceph*

Este plan despliega un cluster Ceph y dos sitemas de ficheros CephFS en los objetivos especificados.
Lo hace de forma distribuida y como el usuario _root_.

#let ceph_bolt = read("fragments/plans/storage_ceph.pp")
#raw(ceph_bolt, lang: "puppet")
#pagebreak()

*Plan despliegue de OpenNebula*

Plan que crea el usuario s3 para el _Marketplace_ y despliega una primera zona maestra en alta disponibilidad.
Posteriormente, en la máquina destinada a la zona esclava se despliega el líder de una nueva zona.

#let nebinst_bolt = read("fragments/plans/nebula_instances.pp")
#raw(nebinst_bolt, lang: "puppet")
#pagebreak()

*Plan despliegue de federación*

Manifiesto que establece la federación entre dos zonas de _OpenNebula_.
Modifica la configuración de ambas zonas para iniciar el proceso de replicación maestro-esclavo.

#let fed_bolt = read("fragments/plans/nebula_federation.pp")
#raw(fed_bolt, lang: "puppet")
#pagebreak()

*Plan despliegue de zona esclava*

Plan de despliegue que incorpora dos núcleos de _OpenNebula_ a la zona esclava.

#let slaves_bolt = read("fragments/plans/slaves_ha.pp")
#raw(slaves_bolt, lang: "puppet")
#pagebreak()

*Plan despliegue de monitorización*

Plan que despliega en paralelo el servicio de monitorización en ambas entidades.

#let monitor_bolt = read("fragments/plans/monitoring.pp")
#raw(monitor_bolt, lang: "puppet")
#pagebreak()

= Aprovisionamiento del entorno <vagrant>

Para desplegar la red del entorno de despliegue, las máquinas virtuales y su aprovisionamiento se ha empleado la herramienta Vagrant.
Ya que las máquinas virtuales son gestionadas por libvirt, se ha instalado el plugin de Vagrant que permite incorporar esta herramienta.

A continuación se presentan los scripts de aprovisionamiento y el fichero _Vagrantfile_ definidos que automatizan el despliegue del entorno de virtualización partiendo de un sistema limpio.
También se presenta la configuración del servicio HAProxy que ejecutan el _gateway_, para balancear la carga de las zonas Ceph, y los núcleos de _OpenNebula_, para proveer de terminación cifrada a los endpoint RPC.

*Script de inicialización*

Script que instala las dependencias básicas para poder desplegar las máquinas virtuales y la red e instala el maestro Puppet.

#let initsh = read("fragments/init/init.sh")
#raw(initsh, lang: "bash")
#pagebreak()

*Vagrantfile*

Manifiesto que define dos máquinas virtuales, aprovisionadas por el mismo script Bash y pasando los certificados para los agentes Puppet.

#let vagrantfile = read("fragments/init/Vagrantfile")
#raw(vagrantfile, lang: "ruby")
#pagebreak()

*Aprovisionamiento de máquinas virtuales*

Script Bash que instala Podman, y otras dependencias, y configura la red de las máquinas virtuales.

#let vagrant_provisioning = read("fragments/init/vagrant_provision.sh")
#raw(vagrant_provisioning, lang: "bash")
#pagebreak()

*Configuración HAProxy del _gateway_*

Se define un _frontend_ que acepta las peticiones de acceso a recursos del _Marketplace_ y las redirige al _backend_ _s3-balancer_.
El _backend_ aplica una política de _roundrobin_ sobre los RGW.

#let haproxy_gateway = read("fragments/init/haproxy.s3.cfg")
#raw(haproxy_gateway, lang: "ini")
#pagebreak()

*Configuración HAProxy de los núcleos*

Terminación TLS para el endpoint RPC de los endpoint de _OpenNebula_.
Se aplica a comunicaciones entre zonas distintas.

#let haproxy_tls = read("fragments/init/haproxy.cfg")
#raw(haproxy_tls, lang: "ini")
#pagebreak()

= Manifiestos OpenTofu <tofu-manifests>
En este anexo se presentan los manifiestos de _OpenTofu_ empleados para describir la máquina virtual del validador de políticas, la del _backup_, junto a su datastore específico, la imagen de disco que emplean ambas máquinas y el _Marketplace_.
Primero se ha de desplegar el manifiesto _00_providers_, especificando que solo se van a desplegar los usuarios y grupos con los que se deben desplegar el resto de recursos.
Posteriormente, se pueden invocar el resto de manifiestos en un único plan de despliegue, que _OpenTofu_ se encarga de establecer las relaciones de dependencias necesarias.

*Definición del Driver de _OpenNebula_*

#let main_tofu = read("fragments/tofu/main.tofu")
#raw(main_tofu, lang: "terraform")
#pagebreak()

*Proveedores*

Manifiesto que contacta con _OpenNebula_ usando el usuario administrador _oneadmin_ y crea los usuarios, ACL y grupos necesarios para las siguientes fases del despliegue.
Los proveedores con usuario recién creados se ejecutan en un plan de despliegue distinto, pero esto permite agrupar todos los proveedores en el mismo fichero.

#let providers_tofu = read("fragments/tofu/00_providers.tofu")
#raw(providers_tofu, lang: "terraform")
#pagebreak()

*Red*

Manifiesto que crea las redes virtuales de _OpenNebula_ a las que se conectarán las máquinas virtuales de las siguientes fases del despliegue.
Aunque se desplieguen todos los recursos en el mismo plan, _OpenTofu_ entiende las dependencias entre recursos y desplegará las máquinas virtuales una vez que las redes virtuales estén definidas.

#let network_tofu = read("fragments/tofu/02_network.tofu")
#raw(network_tofu, lang: "terraform")
#pagebreak()

*Imágenes*

Manifiesto que crea las imágenes locales a cada zona, no persistentes, sobre las que desplegar _OPA_ y la máquina virtual del _backup_.

#let images_tofu = read("fragments/tofu/03_images.tofu")
#raw(images_tofu, lang: "terraform")
#pagebreak()

*Backup*

Manifiesto que despliega la máquina virtual para el _backup_.
En el contexto se especifican el usuario, su contraseña y las claves de acceso _SSH_.
También se concreta en un _script_ de inicio los paquetes a instalar.

#let backup_tofu = read("fragments/tofu/04_services.tofu")
#raw(backup_tofu, lang: "terraform")
#pagebreak()

*Datastore de backup*

Manifiesto que crea el datastore de tipo _BACKUP_DS_ y conecta con la máquina de _backup_.

#let datastores_tofu = read("fragments/tofu/05_datastores.tofu")
#raw(datastores_tofu, lang: "terraform")
#pagebreak()

*OPA*

Manifiesto que despliega la máquian virtual sobre la que corre el contenedor _Docker_ de _OPA_.

#let opa_tofu = read("fragments/tofu/06_services.tofu")
#raw(opa_tofu, lang: "terraform")
#pagebreak()

*Marketplace*

Manifiesto que despliega el _Marketplace_ privado de la federación.
Se especifica el bucket, usuario y clave de acceso para conectar en el endpoint del balanceador.

#let marketplace_tofu = read("fragments/tofu/07_marketplace.tofu")
#raw(marketplace_tofu, lang: "terraform")

#pagebreak()


= Infraestructura de red <asign-direcciones>

La asignación de direcciones a cada uno de los servicios y componentes del sistema se expresa en la @ip-tables.
La cadena _vid_ representa el número de VLAN utilizado en cada caso, pudiendo valer 10 o 20.

#figure(
  table(
   columns: (1.5fr, 2fr, 1fr, 1fr, 1.2fr),
   table.header(
    [*Nombre*], [*IP Servicio*], [*Puerto Servicio*], [*IP Pública*], [*IP Interna*]
   ),
  [ Red cluster ceph ], [ 192.168.\<vid\>.0/24 ], [-], [-], [-],
  [ Red replicación ceph ], [-], [-], [-], [ 192.168.30.0/24 ],
  [ Gateway ], [ 192.168.\<vid\>.254 ], [-], [ 10.88.0.144 ], [-],
  [ Ceph monitor ], [ 192.168.\<vid\>.90-2 ], [3300, 6789], [-], [-],
  [ Ceph manager ], [ 192.168.\<vid\>.93-4 ],[8443, 8080], [-], [-],
  [ Ceph OSD ], [ 192.168.\<vid\>.80-2 ], [6800-7300], [-], [ 192.168.30.80-2 ],
  [ Ceph MDS ], [ 192.168.\<vid\>.100-3 ],[6800-7300],[-], [-],
  [ Ceph RGW ], [ 192.168.\<vid\>.95 ],[7480],[-], [-],
  [ Frontal _OpenNebula_ ], [ 192.168.\<vid\>.0-2 ], [2633, 9090], [-], [-],
  [ IP Virtual _OpenNebula_ ], [ 192.168.\<vid\>.10 ],[2633, 9090], [-], [-],
  [ MariaDB _OpenNebula_ ], [ 192.168.\<vid\>.20-2 ], [3306], [-], [-],
  [ MV Backup ], [ 192.168.\<vid\>.55 ], [2431 (SFTP)], [-], [-],
  [ MV OPA ], [ 192.168.\<vid\>.56 ], [2345], [-], [-],
  [ Prometheus ], [ 192.168.\<vid\>.30 ], [9090], [-], [-],
  ),
  caption: [ Asignación de direcciones IP. ],
) <ip-tables>
