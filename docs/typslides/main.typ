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
  aspect-ratio: "16-9",
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
    logo: image("images/unizar.png", fit: "contain"),
  ),
)

#set text(
  lang: "es",
  size: 20pt
)

#set heading(numbering: (..nums) => {
  let level = nums.pos().len()
  if level == 1 {
    numbering("1", ..nums)
  }
})
#show outline.entry: it => link(
  it.element.location(),
  it.indented(it.prefix(), it.body())
)

#title-slide(logo: none)

== Indice <touying:hidden>

#components.adaptive-columns(
  outline(
    title: none,
    indent: 1em,
    target: <outlined>
  )
)

= Introducción <outlined>
==

#speaker-note[
  + SICUZ
  + Boira
]

- *Motivación* #[
- Gestión local de infraestructura pero servicios compartidos
- Planes de desarrollo UE para la soberanía de la información.
]

#pause

- *Objetivos* #[
- Definir, implementar y validar modelo de federación.
- Dar una solución para la recuperación ante desastres.
- Definir la organización de los usuarios en federación.
]

= Estado del arte <outlined>
==

#speaker-note[
  + Cloud on premise OpenNebula con arquitectura distribuida.
  + Almacenamiento distribuido Ceph
  + XACML, modelo para la validación de políticas y su definición basada en XML
  + NIST, modelo de federación basado en 3 capas de abstracción
  + Gaia X, proyecto europeo que desarrolla un modelo de federación, de donde tomar inspiración para políticas
  + Despliegue automático.
]

#grid(
  columns: (1fr, 1fr, 1fr),
[
  === Infraestructura
  - Cloud On-Premise, OpenNebula
  - Almacenamiento, Ceph
],pause,[
  === Servicios de la federación
  - Gestor de políticas, XACML
  - Modelo de federación, NIST
  - Diseño de políticas, Gaia X
],pause,[
  === Despliegue
  - Puppet
  - Ansible
  - OpenTofu
])

= Análisis y diseño <outlined>

==  Análisis del problema

#speaker-note[
  + Tolerancia a fallos y disponibilidad de cada componente (Infraestructura y servicios)
  + Despliegue controlado, relaciones entre recursos bien definidas
  + Políticas que abarquen todos los componentes
  + Sistema de monitorización y métricas que cubran todos los componentes más disponibilidad
  + Visión unificada del almacenamiento subyacente del catálogo
  + Disponibilidad de los datos de backup, almacenamiento de objetos y que pueda aprovechar las caracterísiticas que ofrece OpenNebula
]

#grid(
  columns: (1fr, 1fr, 1fr),
[
  === Federación
  - Políticas de amplio alcance
  - Gestor de políticas y sistema de monitorización
  - Catálogo de recursos
],pause,[
  === Infraestructura
  - Tolerante a fallos y alta disponibilidad
  - Despliegue controlado
  - Confiable y segura
],pause,[
  === Recuperación ante desastres
  - Disponibilidad del dato
  - Almacenamiento de objetos
  - Integración con OpenNebula
])


== Diseño

#speaker-note[
  + Cloud Privado para la información de los usuarios
  + Adaptable mediante cumplimiento de políticas

  *Posibles Preguntas*
]

#grid(
  columns: (1fr, 1fr, 1fr),
[
  === Infraestructura
  - Cloud On-Premise
  - Confianza entre entidades
  - Adaptable a cada escenario
],pause,[
  === Arquitectura
  - Cloud Privado
  - Estructura modular y libre implementación
],pause,[
  === Recuperación ante desastres
  - Madurez de entorno real
  - Contenido en OpenNebula
])

#slide[
  === Arquitectura

#speaker-note[
  + Gestión de usuarios por defecto y lo que se ha hecho
  + Inspiración del NIST, XACML, Gaia X
  + Qué es cada plano, qué servicios hay en cada uno

  *Posibles Preguntas*
]

  #grid(
  columns: (1fr, 1fr),
  [
    - Abstracción en 3 planos.
    - Servicios de catálogo, control de accesos, monitorización y backup.
    - Gestión extendida de usuarios.
  ],
  image("images/arquitectura.png", height: 80%)
)

]

#slide[
  === Infraestructura

#speaker-note[
  + Red y almacenamiento
  + Cómo está desplegado OpenNebula
  + Cómo está desplegado Ceph
  + Cómo se integran (datastores, pooles, etc...)
  + Replicación

  *Posibles Preguntas*
]

  #grid(
  columns: (1fr, 1fr),
  [
    - Red y almacenamiento aislado en cada entidad.
    - OpenNebula y Ceph.
    - Replicación segura.
  ],
  image("images/diseño-infra.png", height: 80%, fit: "contain")
)

]


#slide[
  === Recuperación ante desastres

#speaker-note[
  + Desplegado en OpenNebula
  + Backup como elemento principal
  + Datastore Restic usando SFTP
  + Repositorio como SF compartido de Ceph
  + Estrategias aplicadas

  *Posibles Preguntas*
]

  #grid(
    columns: (1fr, 1fr),
    [
      - Contenido en OpenNebula.
      - Datastore de _backup_.
      - Estrategia basada en _snapshots_ y _CoW_.
    ],
    image(
      "images/arquitectura-backup.png",
      height: 80%,
      width: 70%,
      fit: "contain"
    )
  )
]

#slide[
  === Despliegue

#speaker-note[
  + Explicar despliegue normal de OpenNebula.
  + Explicar cada fase
  + Por qué es semi-automático

  *Posibles Preguntas*
]

  #grid(
    columns: (1fr, 1fr),
    [
      - Despliegue distribuido de _OpenNebula_.
      - Despliegue semi-automático.
      - Definición de relaciones de despliegue entre recursos.
    ],
    image(
      "images/diseño-despliegue.png",
      height: 80%,
      width: 70%,
      fit: "contain"
    )
  )
]

= Servicios de la federación <outlined>

== Validador de políticas

#speaker-note[
  + Qué es OPA
  + Por qué OPA
  + Qué es Rego
  + Qué políticas se validan (nombrado, sobrecarga, etc...) y por qué
  + Cómo se construye la petición y cómo es la respuesta
  + Quién es el cliente
  + Cómo se accede a las políticas

  *Posibles Preguntas*
]

#grid(
  columns: (1fr, 1fr),
  [
    - Motor de control de accesos OPA
    - Políticas expresadas en _Rego_
    - Políticas de nomenclatura y sobrecarga
  ],
  image(
    "images/opa-interaction.png",
    height: 100%,
    width: 100%,
    fit: "contain"
  )
)

== Monitorización


#speaker-note[
  + Qué se monitoriza (infraestructura como recursos, estado de la fed
como estado de las vm)
  + Por qué Prometheus
  + Scrape period
  + Políticas que hace cumplir y qué info aporta para otras

  *Posibles Preguntas*
]

#grid(
  columns: (1fr, 1fr),
  [
    - Monitorización de infraestructura y estado de la federación
    - Servicio de monitorización Prometheus
    - Cumplimiento de políticas
  ],
  image(
    "images/monitor.png",
    height: 80%,
    width: 100%,
    fit: "contain"
  )
)


== Catálogo de recursos

#speaker-note[
  + Qué significa el círculo negro
  + Explicar qué es el _Marketplace_
  + Explicar arquitectura Multi-site
  + Por qué esta arquitectura (disponibilidad, tolerancia a fallos)

  *Posibles Preguntas*
]

#grid(
  columns: (1fr, 1fr),
  [
    - _Marketplace_ _OpenNebula_
    - Arquitectura \"Multi-site\" de Ceph
    - Peticiones balanceadas
  ],
  image(
    "images/marketplace.png",
    height: 80%,
    width: 100%,
    fit: "contain"
  )
)


== Interacción con los servicios

#speaker-note[
  #text(size: 15pt)[
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
  columns: (1fr, 1fr),
  [
    - Modelo de ejecución programada de eventos (_Hook Execution Manager_).
    - Ejecución de _scripts_ Ruby.
    - Obtención de métricas y validación de políticas.
  ],
  image(
    "images/interaccion.png",
    height: 80%,
    width: 100%,
    fit: "contain"
  )
)

== Despliegue

#speaker-note[
  #text(size: 15pt)[
  + Por qué OpenTofu y Puppet para infraestructura
  + Gestión de usuarios
  + Uso de imágenes no persistentes
  + Despliegue con usuarios diferentes y permisos
  + Gestión de la red

  Poner código OpenTofu?

  *Posibles Preguntas*
]
]

#let tofu_manifest = read("fragments/opa-deploy.tofu")

#grid(
  columns: (1fr, 1fr),
  [
    - Usuarios y permisos
    - Almacenamiento y red
    - Plan de despliegue
  ],
  listing(raw(tofu_manifest, lang: "terraform"))

)


= Validación y pruebas <outlined>
==

- *Validación*

- *Pruebas de funcionamiento*

- *Prueba de sobrecarga*

- *Prueba de _backup_*

= Conclusiones <outlined>
==
#speaker-note[
  + Prototipo funcional
  + Pruebas correctas
]
- *Objetivos alcanzados* #[
- Diseño, implementación y validación del prototipo de federación.
- Backup como recuperación ante desastres
- Gestión extendida de usuarios
- Sistema validado y probado
]

#pause

- *Conclusión Personal* #[
- Exposición a un problema real
- Gran aprendizaje
]



#title-slide(logo:none)
