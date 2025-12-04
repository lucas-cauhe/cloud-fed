#!/usr/bin/env ruby

require "open3"

cluster_name = ARGV[0]
client_name = ARGV[1]
pool = ARGV[2]
image = ARGV[3]
mountpoint = ARGV[4]

# Muestra un error en caso de fallo
# El programa termina si hay fallo
def show_error(output, status)
  if output != "" && status && status != 0
    puts "RBD mount went wrong: #{status}: #{output}"
    exit 1
  end
end

# Ejecuta un comando de sistema arbitrario y devuelve
# la salida del comando
def run_command(cmd)
  puts "RUNNING COMMAND: #{cmd}"
  out, stderr, status = Open3.capture3(cmd)
  show_error(stderr, status)
  return out.strip
end

#
# If there is an rbd already on that mountpoint do nothing
#
exit 0 unless run_command("/usr/bin/findmnt #{mountpoint}") == ""

#
# Ensure rbd kernel module is loaded
#
_ = run_command("/usr/sbin/modprobe rbd")

#
# Map the device
#
device = run_command("/usr/bin/rbd -n client.#{client_name} -c /etc/#{cluster_name}/ceph.conf -k /etc/#{cluster_name}/ceph.client.#{client_name}.keyring --id #{client_name} map --pool #{pool} #{image}")

#
# Wipe device
#
_ = run_command("/usr/sbin/wipefs -a #{device}")

#
# Format device with xfs
#
_ = run_command("/usr/sbin/mkfs.xfs #{device}")

#
# Mount device into `mountpoint`
#
_ = run_command("/usr/bin/mount -t xfs #{device} #{mountpoint}")
