#!/usr/bin/env ruby
require 'open3'
require 'json'

def show_error(output, status)
  if output && status && status != 0
    puts "ERROR happened: #{output} with status #{status}"
    return true 
  end
  return true
end

def run_command(command)
  output, stderr, status = Open3.capture3(command)
  exit 1 unless show_error(stderr, status)
  return output
end

# Clean the deployed infrastructure

# Remove opennebula containers (depends on ceph)
_ = run_command("podman stop --time 1 one_db")

#
# Clean used mountpoints
#
used_mountpoints = ['/opt/one_db']
used_mountpoints.each do |mp|
  _ = run_command("umount #{mp}")
end

#
# Delete rbd mappings
#
raw_mappings = run_command("rbd -c /etc/ceph-10/ceph.conf -k /etc/ceph-10/ceph.client.admin.keyring showmapped --format json")

mappings = JSON.parse(raw_mappings)
mappings.each do |mapping|
  _ = run_command("rbd -c /etc/ceph-10/ceph.conf -k /etc/ceph-10/ceph.client.admin.keyring unmap #{mapping["device"]}")
end

#
# Stop running containers
#
run_command("podman stop --time 1 -a")

