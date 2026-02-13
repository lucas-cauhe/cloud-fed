resource "one_vm" "opa-10" {
  provider = opennebula.policies-10

  name        = "one-10/policies_10/opa"
  group       = "policies"
  permissions = "740"

  context = {
    NETWORK      = "YES"
    HOSTNAME     = "$NAME"
    USERNAME     = "oneadmin"
    PASSWORD     = zone1.password
    SSH_PUBLIC_KEY = zone1.ssh_keys
    START_SCRIPT = <<-EOT
    # Instalación y montaje de Cephfs
    EOT
  }
  disk {
    image_id = one_image.services-10.id
  }
  nic {
    network_id = one_vn.services-10.id
