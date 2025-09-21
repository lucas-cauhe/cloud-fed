#!/usr/bin/env ruby
require 'open3'
require 'json'

def show_error(output, status)
  if output && status && status != 0
    puts "ERROR happened: #{output} with status #{status}"
    return false 
  end
  return true
end

def run_command(command, skip=false)
  output, stderr, status = Open3.capture3(command)
  exit 1 unless show_error(stderr, status) || skip
  return output
end

def unmap_rbd(cluster_id)
  raw_mappings = run_command("rbd -c /etc/ceph-#{cluster_id}/ceph.conf -k /etc/ceph-#{cluster_id}/ceph.client.admin.keyring showmapped --format json")

  mappings = JSON.parse(raw_mappings)
  mappings.each do |mapping|
    _ = run_command("rbd -c /etc/ceph-#{cluster_id}/ceph.conf -k /etc/ceph-#{cluster_id}/ceph.client.admin.keyring unmap #{mapping["device"]}")
  end

end

# Clean the deployed infrastructure

# Remove opennebula containers (depends on ceph)
_ = run_command("podman stop --time 1 one-db-0", skip=true)
_ = run_command("podman stop --time 1 one-db-1", skip=true)
_ = run_command("podman stop --time 1 one-db-2", skip=true)

#
# Clean used mountpoints
#
used_mountpoints = ['/opt/one-db-0', '/opt/one-db-1', '/opt/one-db-2']
used_mountpoints.each do |mp|
  out = run_command("findmnt #{mp}")
  if out != "" 
    _ = run_command("umount #{mp}")
  end
end

#
# Delete rbd mappings
#
unmap_rbd(10)
unmap_rbd(20)

#
# Stop running containers
#
run_command("podman stop --time 1 -a")

#
# Delete all container systemd files to ensure recreation
#
Dir.glob('/etc/containers/systemd/puppet-podman-*').each { |file| File.delete(file)}
