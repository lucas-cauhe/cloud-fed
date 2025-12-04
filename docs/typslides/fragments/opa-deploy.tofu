resource "opennebula_virtual_machine" "opa-10" {
  provider = opennebula.policies-10

  name        = "one-10/policies_10/opa"
  group       = "policies"
  permissions = "740" # use and manage by zone user and only use by policies group

  context = {
    NETWORK      = "YES"
    HOSTNAME     = "$NAME"
    USERNAME     = "oneadmin"
    PASSWORD     = local.zone1.nebula.password
    SSH_PUBLIC_KEY = local.zone1.nebula.ssh_keys
    START_SCRIPT = <<-EOT
    # Instalación, montaje de Cephfs y puesta en marcha
    EOT
  }
  disk {
    image_id = opennebula_image.services-10.id
    target   = "hda"
    driver   = "qcow2"
  }
  nic {
    model           = "virtio"
    network_id      = opennebula_virtual_network.services-10.id
  }
}
