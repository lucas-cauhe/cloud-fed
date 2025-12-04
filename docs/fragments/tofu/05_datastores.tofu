#
# Datastore definition
#

# Datastore backup con driver Restic entidad 10
resource "opennebula_datastore" "backup-10" {
 provider = opennebula.one-10
 name = "backup"

 custom {
  datastore = "restic"
  transfer = "shared"
 }

 tags = {
  restic_password = "opennebula"
  restic_sftp_server = "${local.zone1.nebula.ipaddress}"
  type = "BACKUP_DS"
 }
 type = "IMAGE"
}

# Datastore backup con driver Restic entidad 20
resource "opennebula_datastore" "backup-20" {
 provider = opennebula.one-20
 name = "backup"

 custom {
  datastore = "restic"
  transfer = "shared"
 }

 tags = {
  restic_password = "opennebula"
  restic_sftp_server = local.zone2.nebula.ipaddress
  type = "BACKUP_DS"
  tm_mad = "-"
 }
 type = "IMAGE"
}

