#!/usr/bin/env ruby

require 'open3'
require 'fileutils'

osd_name = ARGV[0]
cluster_name = ARGV[1]
fsid = ARGV[2]

def show_error(output, status)
  if output != "" && status && status != 0
    puts "OSD creation went wrong: #{status}: #{output}"
  end
end


stdout, stderr, status = Open3.capture3("lvdisplay -m main/#{osd_name}")

if stderr != ""
  puts "Lvm doesn't exist for osd $name, create one with the same name"
  exit 0
end

lv_path = stdout.lines[1].strip.split[-1]
# Zap & clean mounted dir if it already exists
FileUtils.rm_rf("/etc/#{cluster_name}/osd/#{osd_name}")
Open3.capture3("cephadm shell -m /etc/#{cluster_name}:/etc/ceph -- ceph-volume lvm zap #{lv_path}")
puts "Device #{lv_path} zapped"

#
# Create new osd from cephadm shell
#
osd_secret, sdterr, status = Open3.capture3("cephadm shell -- ceph-authtool --gen-print-key")
show_error(stderr, status)
osd_secret = osd_secret.strip
Open3.capture3("podman cp mon-0:/var/lib/ceph/bootstrap-osd/ceph.keyring /etc/#{cluster_name}")
osd_id, stderr, status = Open3.capture3("echo { \"cephx_secret\": \"#{osd_secret}\" } | cephadm shell -m /etc/#{cluster_name}:/etc/ceph -- ceph osd new #{fsid} -i - -n client.bootstrap-osd -k /etc/ceph/ceph.keyring")
show_error(stderr, status)

osd_id = osd_id.strip
puts "New osd #{osd_name} created with fsid #{fsid}, osd_secret #{osd_secret} and id #{osd_id}"
#
# Handle device preparation 
#
File.open("/tmp/env-#{osd_name}", File::CREAT|File::WRONLY) {|f| f.puts "ID=#{osd_id}\nOSD_SECRET=#{osd_secret}"}
FileUtils.mkdir_p("/etc/#{cluster_name}/osd/#{osd_name}")
Open3.capture3("mkfs.xfs /dev/main/#{osd_name}")
Open3.capture3("mount /dev/main/#{osd_name} /etc/#{cluster_name}/osd/#{osd_name}")
puts "Formatted device /dev/main/#{osd_name} and mounted"

#
# Create keyring with secret for osd
#
keyring_cmd = "cephadm shell -m /etc/#{cluster_name}:/etc/ceph -- ceph-authtool --create-keyring /etc/ceph/osd/#{osd_name}/keyring --name osd.#{osd_id} --add-key #{osd_secret}"
puts "Running command #{keyring_cmd}"
_, stderr, status = Open3.capture3(keyring_cmd)
show_error(stderr, status)
puts "Created keyring for osd"

#
# Add osd keyring to auth registry
#
_, stderr, status = Open3.capture3("cephadm shell -m /etc/#{cluster_name}:/etc/ceph -- ceph auth add osd.#{osd_id} osd 'allow *' mon 'allow profile osd' -i /etc/ceph/osd/#{osd_name}/keyring")
show_error(stderr, status)
puts "Added keyring to auth registry"
