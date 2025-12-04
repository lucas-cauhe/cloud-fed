#
# Define vnet
#

# Red VLAN de servicio en la entidad 10
resource "opennebula_virtual_network" "services-10" {
  provider = opennebula.one-10
  name            = "services-10"
  type            = "802.1Q"
  physical_device = "br_kvm"
  vlan_id         = "10"
  gateway         = "192.168.10.254"
  dns             = "155.210.3.12 155.210.12.9"
  mtu             = 1500
}

# Red VLAN de servicio en la entidad 20
resource "opennebula_virtual_network" "services-20" {
  provider = opennebula.one-20
  name            = "services-20"
  type            = "802.1Q"
  physical_device = "br_kvm"
  vlan_id         = "20"
  gateway         = "192.168.10.254"
  dns             = "155.210.3.12 155.210.12.9"
  mtu             = 1500
}

# Rango de direcciones para la VLAN de servicios en la entidad 10
resource "opennebula_virtual_network_address_range" "services_ar-10" {
  provider = opennebula.one-10
  virtual_network_id = opennebula_virtual_network.services-10.id
  ar_type            = "IP4"
  size               = length(local.services)
  ip4                = local.zone1.nebula.ipaddress
}

# Rango de direcciones para la VLAN de servicios en la entidad 20
resource "opennebula_virtual_network_address_range" "services_ar-20" {
  provider = opennebula.one-20
  virtual_network_id = opennebula_virtual_network.services-20.id
  ar_type            = "IP4"
  size               = length(local.services)
  ip4                = local.zone2.nebula.ipaddress
}
