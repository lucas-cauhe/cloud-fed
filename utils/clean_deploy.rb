#!/usr/bin/env ruby
require 'open3'
require 'json'

stop_pattern = ARGV[0]

stop_one = false
stop_all = true

if stop_pattern == "one"
  stop_one = true
  stop_all = false
end


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
  #
  # Umount used mountpoints
  #
    mountpoint = run_command("findmnt --source #{mapping["device"]} -o TARGET | tail -n1").strip
    _ = run_command("umount #{mountpoint}")

    #
    # Unmap device
    #
    _ = run_command("rbd -c /etc/ceph-#{cluster_id}/ceph.conf -k /etc/ceph-#{cluster_id}/ceph.client.admin.keyring unmap #{mapping["device"]}")
  end

end

def stop_containers(pattern)
  all_containers = JSON.parse(run_command("podman ps --format json", skip=true))
  db_containers = all_containers.inject([]) {|prev, ctr| if ctr["Names"][0].include?(pattern) then prev.append(ctr["Names"][0]) else prev end}
  if db_containers.length > 0
    _ = run_command("podman stop --time 1 #{db_containers.join(' ')}")
  end
end

# Clean the deployed infrastructure

# Remove db containers (depends on ceph)
stop_containers("one-db")

#
# Delete rbd mappings
#
unmap_rbd(10)
unmap_rbd(20)


#
# Stop running containers
#
stop_containers("oned") if stop_one
run_command("podman stop --time 1 -a") if stop_all


#
# Delete all container systemd files to ensure recreation
#
Dir.glob('/etc/containers/systemd/puppet-podman-*').each { |file| File.delete(file)}
