#!/usr/bin/env ruby

require "open3"
require "json"
require "fileutils"

$cluster_name = ARGV[1]
id = ARGV[2]
role = ARGV[3]
zonegroup_name = ARGV[4]
zone_name = ARGV[5]
address = ARGV[6]

# Muestra un error en caso de fallo
# El programa termina si hay fallo
def show_error(cmd, output, status)
  if output != "" && status && status != 0
    puts "RGW admin command went wrong"
    puts cmd
    puts "OUTPUT #{status}: #{output}"
    exit 1
  end
end

# Ejecuta comando podman arbitrario
def run_command(cmd)
  container_name = ARGV[0]
  prefix = "podman exec #{container_name} "
  stdout, stderr, status = Open3.capture3(prefix + cmd)
  show_error(cmd, stderr, status)
  stdout
end

# Ejecuta comando de radosgw-admin y devuelve su resultado
def rgw_admin(cmd)
  rgw_prefix = "radosgw-admin -c /etc/ceph/#{$cluster_name}.conf -k /etc/ceph/ceph.client.admin.keyring "
  run_command(rgw_prefix + cmd)
end

# Crea usuario en la arquitectura multi-zona
def create_user(zone_name, user_id)
  creds_file = "/tmp/radosgw-#{user_id}-creds.json"
  user_info = rgw_admin("user create --uid=#{user_id} --display-name=#{user_id} --system --rgw-zone=#{zone_name}")
  File.write(creds_file, user_info)
  JSON.parse(user_info)
end

# Obtiene un usuario de radosgw-admin
def get_user(user_id)
  creds_file = "/tmp/radosgw-#{user_id}-creds.json"
  file = File.read creds_file
  JSON.load file
end

zonegroup_file = "/tmp/radosgw-zonegroup-#{zonegroup_name}.json"
sync_user = "synchronization-user"

if role == "master"
  #
  # Create zone
  #
  rgw_admin("zone create --rgw-zonegroup=#{zonegroup_name} --rgw-zone=#{zone_name} --master --endpoints=http://#{address}")

  #
  # Store zonegroup info for slaves
  #
  File.write(zonegroup_file, rgw_admin("zonegroup get --rgw-zonegroup=#{zonegroup_name}"))

  #
  # Create zone admin user
  #
  user_info = create_user(zone_name, sync_user)

  #
  # Add keys to zone
  #
  rgw_admin("zone modify --rgw-zone=#{zone_name} --access-key=#{user_info["keys"][0]["access_key"]} --secret=#{user_info["keys"][0]["secret_key"]}")

  #
  # Update period
  #
  rgw_admin("period update --commit --rgw-zone=#{zone_name} ")
else

  #
  # Get admin user info & zone url
  #
  user_info = get_user(sync_user)
  zg_file = File.read zonegroup_file
  zonegroup_info = JSON.load(zg_file)
  master_zone = zonegroup_info["zones"].find { |zone| zone["id"] == zonegroup_info["master_zone"] }

  access_key = user_info["keys"][0]["access_key"]
  secret = user_info["keys"][0]["secret_key"]

  #
  # Pull realm config
  #
  realm_config = rgw_admin("realm pull --url=#{master_zone["endpoints"][0]} --access-key=#{access_key} --secret=#{secret}")
  realm_config = JSON.parse(realm_config)

  # Make realm the default one
  rgw_admin("realm default --rgw-realm=#{realm_config["name"]}")

  #
  # Create secondary zone
  #
  rgw_admin("zone create --rgw-zonegroup=#{zonegroup_name} --rgw-zone=#{zone_name} --access-key=#{access_key} --secret=#{secret} --endpoints=http://#{address}")

  #
  # Update period
  #
  rgw_admin("period update --commit --rgw-zonegroup=#{zonegroup_name} --rgw-zone=#{zone_name} ")
end

#
# Start rgw process
#
run_command("radosgw -c /etc/ceph/#{$cluster_name}.conf --keyring /var/lib/ceph/radosgw/ceph-rgw-#{id}/keyring --name client.rgw-#{id} --cluster #{$cluster_name} --setuser ceph --setgroup ceph --rgw-zone=#{zone_name}")
