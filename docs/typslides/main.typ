#import "@preview/touying:0.6.1": *
#import "@preview/fletcher:0.5.4" as fletcher: node, edge
#import themes.university: *

#let listing(content) = {
  align(left)[
    #block(
      fill: luma(200),
      inset: 8pt,
      radius: 4pt,
      text(size: 12pt, content)
    )
  ]
}


#show: university-theme.with(
  aspect-ratio: "4-3",
  align: horizon,
  // config-common(handout: true),
  //config-common(frozen-counters: (theorem-counter,)),
  //config-common(show-notes-on-second-screen: right),
  config-info(
    title: [Despliegue de una federación _cloud_],
    subtitle: [Instanciación, presentación de recursos, gestión
    de la pertenencia y monitorización y recuperación ante desastres],
    author: [Lucas Cauhé Viñao],
    date: datetime.today(),
    institution: [Escuela de Ingeniería y Arquitectura \ Universidad de Zaragoza],
    logo: place(bottom + right, dy: +520pt, float: true, image("images/unizar.png", fit: "contain")),

  ),
)

#set text(
  lang: "es",
  font: "Liberation Sans",
  size: 25pt
)

//#set heading(numbering: (..nums) => {
//  let level = nums.pos().len()
//  if level == 2 {
//    numbering("1", ..nums)
//  }
//})
//#set heading(numbering: "1")
#show outline.entry: it => link(
  it.element.location(),
  it.indented([>], it.body())
)


#title-slide(logo: none)

== Indice <touying:hidden>

#components.adaptive-columns(
  outline(
    title: none,
    indent: 1em,
    depth: 2,
    target: <outlined>
  )
)

== Introducción <outlined>

#grid(
  rows: (1fr, 4fr),
  gutter: 0%,
  heading(depth: 3)[Contexto y motivación],
  grid.cell(align: top + left, inset: 5%, list(
    spacing: 50pt,
   [Proyecto interuniversitario (UZ, EHU y UAL) Boira, SICUZ.],
   [Gestión local de infraestructura pero recursos compartidos.],
   [Planes de desarrollo UE para la soberanía informática.],
  ))
)

#speaker-note[
  + SICUZ
  + Boira
  + Definición de federación cloud
  + Definición de entidad
  + Despliegue manual de Boira
  + Federación sigue otros proyectos europeos
  *Posibles preguntas*

  Problemática con VMWare

  Sobrecarga asignada o en uso
]


== Introducción

#grid(
  rows: (1fr, 4fr),
  gutter: 0%,
  heading(depth: 3)[Objetivos],
  grid.cell(align: top + left, inset: 5%,
    list(
      spacing: 40pt,
     [Diseñar e implementar un modelo básico de federación _cloud_.
     \
     \
     - Presentación de recursos de la federación, identificación y autorización de usuarios, y monitorización del sistema],
     [Plan de recuperación ante desastres en entorno _cloud_.],
    )
  )
)


= <touying:hidden>

== Conceptos, tecnologías y herramientas
== Conceptos, tecnologías y herramientas <outlined>

#speaker-note[
  #text(size: 16pt)[
  + Cloud on premise OpenNebula con limitada capacidad de federación.
  + Explicar núcleo/controlador, hosts de virtualización y concepto datastore.
  + Almacenamiento distribuido Ceph, arch y mención a RBD.
  + XACML, modelo para la validación de políticas y su definición basada en XML
  + NIST, modelo de federación basado en 3 capas de abstracción
  + Mención al estudio de un modelo de mercado donde un broker media la adquisición de recursos de cada entidad.
  Ligar con Marketplace OpenNebula.
  + Gaia X, proyecto europeo que desarrolla un modelo de federación, de donde tomar inspiración para políticas
  + Despliegue automático por la entrada y salida dinámica de entidades y recursos.
  + Modelos abstractos de config ayudan al prototipado del modelo.
  + Qué es OPA
  + Qué es Rego
]
]

#grid(
  rows: (1fr, 2fr, 2fr),
  heading(depth: 3)[Infraestructura _Cloud_],
  grid.cell(align: top + left, inset: 5%,
  grid(
    rows: (1fr, 4fr),
    heading(depth: 4)[Fijados para el proyecto],
    grid.cell(align: top + left, inset: 5%,
      list(
        spacing: 40pt,
        [OpenNebula como _cloud_ on-premise e híbrido.],
        [Ceph para almacenamiento distribuido de objetos, sin punto único de fallo.],
      )
    )
  )
  ),
  grid.cell(align: top + left, inset: 5%,
  grid(
    rows: (1fr, 4fr),
    heading(depth: 4)[Estudio propio],
    grid.cell(align: top + left, inset: 5%,
      list(
        spacing: 40pt,
        [Modelos abstractos de configuración de sistemas.],
        [Recuperación ante desastres.],
      )
    )
  )
)
)

#grid(
  rows: (1fr, 6fr),
  heading(depth: 3)[Modelos de federación],
  grid.cell(align: top + left, inset: 5%,
    list(
      spacing: 60pt,
      [NIST _Cloud Federation Reference Architecture_.],
      [IEEE _Market Models for Federated Clouds_.],
      [Modelo de validación de políticas, XACML e implementación con OPA.],
      [Diseño de políticas, Gaia X.],
    )
  )
)

==  Análisis y requisitos del problema <outlined>

#speaker-note[
  + Tolerancia a fallos y disponibilidad de cada componente (Infraestructura y servicios)
  + Despliegue controlado, relaciones entre recursos bien definidas
  + Políticas que abarquen todos los componentes
  + Sistema de monitorización y métricas que cubran todos los componentes más disponibilidad
  + Visión unificada del almacenamiento subyacente del catálogo
  + Disponibilidad de los datos de backup, almacenamiento de objetos y que pueda aprovechar las caracterísiticas que ofrece OpenNebula
]

#list(spacing: 40pt,
 [*Tolerancia a fallos y disponibilidad* de componentes clásicos de entornos *cloud* (*nodos de cómputo y sistema de almacenamiento*) y *servicios de la federación*.],
 [*Gobernanza* de la federación mediante *políticas* de SLA, almacenamiento, autorización de usuarios, nomenclatura y aplicación.],
 [*Catálogo distribuido* de plantillas de VM e imágenes de disco ofrecidos por la federación.],
 [Copias de VM en sistema de ficheros y disponibles para usuarios autorizados.],
 [*Despliegue automático* y dependencias entre componentes del despliegue controladas.],
)

== Diseño <outlined>

#slide[
  #grid(
    rows: (1fr, 7fr),
    heading(depth: 3)[Arquitectura],
    figure(image("images/arquitectura.png", height: 100%))
  )

#speaker-note[
  + Gestión de usuarios por defecto y lo que se ha hecho
  + Qué es cada plano, qué servicios hay en cada uno
  + Ir de abajo a arriba y desde arriba ligar con la infraestructura por los servicios virtuales ofrecidos por la infraestructura. Ligar con siguiente sección.

  *Posibles Preguntas*
]

]

#slide[
  #grid(
    rows: (1fr, 7fr),
    heading(depth: 3)[Infraestructura],
    figure(image("images/diseño-infra.png", fit: "cover"))
  )

#speaker-note[
  + Red y almacenamiento
  + Cómo está desplegado OpenNebula
  + Cómo está desplegado Ceph
  + Cómo se integran (datastores, pooles, etc...)
  + Replicación

  *Posibles Preguntas*
]

]


#slide[

  #grid(
    rows: (1fr, 7fr),
    heading(depth: 3)[Recuperación ante desastres],
    figure(image("images/arquitectura-backup.png", fit: "cover"))
  )
#speaker-note[
  + Estrategias aplicadas, políticas aplicadas, aplicación local de backups
  + Recuperación disponible desde cualquier entidad autorizada
  + Desplegado en OpenNebula
  + Backup como elemento principal
  + Datastore Restic usando SFTP
  + Repositorio como SF compartido de Ceph

  *Posibles Preguntas*
]

]

#slide[
  #grid(
    rows: (1fr, 7fr),
    heading(depth: 3)[Despliegue automatizado del prototipo],
    figure(image("images/diseño-despliegue-01.png", height: 80%))
  )

  #grid(
    rows: (1fr, 7fr),
    heading(depth: 3)[Despliegue automatizado del prototipo],
    figure(image("images/diseño-despliegue-02.png", fit: "cover"))
  )

  #grid(
    rows: (1fr, 7fr),
    heading(depth: 3)[Despliegue automatizado del prototipo],
    figure(image("images/diseño-despliegue-03.png", fit: "cover"))
  )

#speaker-note[
  + Explicar despliegue normal (distribuido) de OpenNebula.
  + Explicar cada fase del despliegue
  + Por qué es semi-automático

  *Posibles Preguntas*
]

]

== Implementación <outlined>

#speaker-note[
  + Por qué OPA
  + Qué políticas se validan (nombrado, sobrecarga, etc...) y por qué
  + Cómo se construye la petición y cómo es la respuesta
  + Quién es el cliente
  + Cómo se accede a las políticas

  *Posibles Preguntas*
]
  #grid(
    rows: (1fr, 20fr),
    heading(depth: 3)[Validador de políticas],
    figure(image("images/opa-interaction.png", fit: "cover"))
  )

#speaker-note[
  + Multi-site de reino a zona

  *Posibles Preguntas*
]

#grid(
  columns: (1fr, 1fr),
  grid(
  heading(depth: 3)[Catálogo de recursos],
  rows: (1fr, 7fr),
  list(
    spacing: 60pt,
    [_Marketplace_ _OpenNebula_.],
    [Arquitectura \"Multi-site\" de Ceph.],
    [Peticiones de recuperación de recursos balanceadas],
  )),
  figure(image("images/marketplace.png", fit: "cover"))
)

#speaker-note[
  + Qué significa el círculo negro
  + Explicar qué es el _Marketplace_
  + Explicar arquitectura Multi-site
  + Por qué esta arquitectura (disponibilidad, tolerancia a fallos)

  *Posibles Preguntas*
]

//#grid(
//  rows: (1fr, 17fr),
//  heading(depth: 3)[Recuperación ante desastres],
//  figure(image("images/impl-backup.png", fit: "cover"))
//)


#speaker-note[
  #text(size: 15pt)[
  + Qué se monitoriza (infraestructura como recursos, estado de la fed
como estado de las vm)
  + Por qué Prometheus
  + Políticas que hace cumplir y qué info aporta para otras
  + Explicar orden en el que suceden las operaciones
  + Explicar gestor de ejecución programada de eventos, HEM (API vs State hooks)
  + Explicar qué es y cómo viene dado el contexto del recurso
  + Explicar cómo se llevan a cabo las acciones de borrado de recursos
  + Explicar uso de ruby y _middleware_ para interacción con Prometheus y OPA
  *Posibles Preguntas*
  -¿Por qué Ruby? \
    Librerías ya existentes para interacción con servicios \
    Lenguaje de scripting \
    Modularización]
]

  #grid(
    rows: (1fr, 7fr),
    heading(depth: 3)[Interacción entre servicios],
    figure(image("images/interaccion-monitorizacion.png", height: 80%))
  )


#speaker-note[
  #text(size: 15pt)[
  + Por qué OpenTofu y Puppet para infraestructura
  + Gestión de usuarios
  + Uso de imágenes no persistentes
  + Despliegue con usuarios diferentes y permisos
  + Gestión de la red


  *Posibles Preguntas*
]
]

#let tofu_manifest = read("fragments/opa-deploy.tofu")
#let main_plan_manifest = read("fragments/main_puppet.pp")
#let run_plan_manifest = read("fragments/run_puppet.pp")

#grid(
  rows: (1fr, 50fr),
  heading(depth: 3)[Despliegue automatizado del prototipo],
  grid(
    columns: (1fr, 1fr),
    grid(
      rows: (1fr, 1fr),
      gutter: -200pt,
      figure(
        listing(
          text(size: 18pt, raw(
            main_plan_manifest,
            lang: "puppet")
          )),
          numbering: none),
      figure(
        listing(
          text(size: 18pt,raw(
            run_plan_manifest,
            lang: "puppet")
          ) ),
          caption: text(
            size: 16pt
          )[Despliegue de componentes Ceph y nodos OpenNebula\ (Puppet Bolt)],
          numbering: none),
    ),
    figure(
      listing(
        text(size: 16pt, raw(
          tofu_manifest,
          lang: "terraform"
        ))

      ),
      caption: text(
        size: 16pt
      )[Despliegue de VM en el entorno de federación\ (OpenTofu)],
      numbering: none
    )

  )
)


== Validación y pruebas <outlined>

#set list(spacing: 35pt)

- *Pruebas de funcionamiento* #[ \

  - Obtención de imagen de disco del marketplace, tolerante al fallo de una entidad.
  - Despliegue automático de VMs con imagen obtenida.
  - Validación de políticas durante despliegue de VM.
]


- *Prueba de sobrecarga* #[ \
  - Usuarios de entidades diferentes.
  - Impide despliegue de VM si el uso de CPU > 80%.
]

- *Prueba de _backup_* #[ \
  - Recuperación de VM que ejecuta núcleo de OpenNebula
]

== Conclusiones <outlined>
#speaker-note[
  + Prototipo funcional
  + Pruebas correctas
]

#grid(
  rows: (1fr, 5fr),
  heading(depth: 3)[Objetivos alcanzados],
  grid.cell(align: top + left,
    list(
      spacing: 30pt,
      [Diseño de un modelo de federación _cloud_ tolerante a fallos.

      #[
       - Políticas de autorización de usuarios, definición de VM, estrategias de backup y rendimiento de las entidades.
      ]],
     [Despliegue distribuido automatizado.],
     [Prototipo funcional del modelo.

     #[
     - Gobernanza de las entidades con las políticas definidas.
     - Catálogo de recursos distribuido y tolerante a fallos.
     - Recuperación de máquinas virtuales a un estado previo.
     ]],

    )
  )
)

#grid(
  rows: (1fr, 1fr),
  grid(
    rows: (1fr, 4fr),
    heading(depth: 3)[Trabajo futuro],
    grid.cell(align: horizon + left, inset: 5%,
      list(
        spacing: 50pt,
       [Desarrollo de políticas de red y seguridad a nivel de servicios.],
       [Implementación de infraestructura de clave pública (PKI).],
      )
    )
  ),
  grid(
    rows: (1fr, 4fr),
    heading(depth: 3)[Conclusiones personales],
    grid.cell(align: horizon + left, inset: 5%,
      list(
        spacing: 60pt,
       [Exposición a un problema real.],
       [Aprendizaje de nuevos conceptos y tecnologías.],
      )
    )
  )
)
==
#slide[
  #align(center,
  grid(
    rows: (1fr, 1fr),
    //stroke: 1pt,
    heading(depth: 3)[Gracias por su atención],
    grid(
      rows: (2fr, 2fr, 1fr, 1fr),
      heading(depth: 3)[Despliegue de una federación _cloud_],
      heading(depth: 4)[Lucas Cauhé Viñao],
      [Escuela de Ingeniería y Arquitectura],
      [Universidad de Zaragoza],

    )
  )

)
]
