#
# Define image
#

#
# Imagen no persistente con software mínimo preinstalado, cloud init,
# permisos de explotación y gestión para el propietario y usada como base para
# los servicios mínimos de la federación
#
resource "opennebula_image" "services-10" {
  provider = opennebula.one-10
  name         = "services"
  description  = "Debian limpio"
  datastore_id = 101
  persistent   = false
  lock         = "UNLOCK"
  path         = "https://marketplace.opennebula.systems/appliance/f4cc1890-f430-013c-b669-7875a4a4f528/download"
  dev_prefix   = "vd"
  driver       = "qcow2"
  type         = "OS"
  group        = "services"
  size         = "8196"
  permissions  = "660"
}

# Homóloga de la entidad 10
resource "opennebula_image" "services-20" {
  provider = opennebula.one-20
  name         = "services"
  description  = "Debian limpio"
  datastore_id = 101
  persistent   = false
  lock         = "UNLOCK"
  path         = "https://marketplace.opennebula.systems/appliance/f4cc1890-f430-013c-b669-7875a4a4f528/download"
  dev_prefix   = "vd"
  driver       = "qcow2"
  type         = "OS"
  group        = "services"
  size         = "8196"
  permissions  = "660"
}
