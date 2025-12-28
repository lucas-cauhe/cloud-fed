#!/usr/bin/env ruby

require "open3"
require "fileutils"

osd_name = ARGV[0]
cluster_name = ARGV[1]
fsid = ARGV[2]
monitor = ARGV[3]

def show_error(output, status)
  if output != "" && status && status != 0
    puts "OSD creation went wrong: #{status}: #{output}"
    exit 1
  end
end

osd_number = osd_name.split("-")[1].to_i
vid = (osd_number + 98).chr
#stdout, stderr, status = Open3.capture3("lvdisplay -m main/#{osd_name}")
#
#if stderr != ""
#  puts "Lvm doesn't exist for osd #{osd_name}, create one with the same name"
#  exit 1
#end
#
#lv_path = stdout.lines[1].strip.split[-1]
# Zap & clean mounted dir if it already exists
FileUtils.rm_rf("/etc/#{cluster_name}/osd/#{osd_name}")
Open3.capture3("umount /etc/#{cluster_name}/osd/#{osd_name}")
Open3.capture3("cephadm shell -m /etc/#{cluster_name}:/etc/ceph -- ceph-volume lvm zap /dev/vd#{vid}")
puts "Device vd#{vid} zapped"

#
# Create new osd from cephadm shell
#
osd_secret, stderr, status = Open3.capture3("cephadm shell -- ceph-authtool --gen-print-key")
show_error(stderr, status)
osd_secret = osd_secret.strip
Open3.capture3("podman cp #{monitor}:/var/lib/ceph/bootstrap-osd/ceph.keyring /etc/#{cluster_name}")
osd_id, stderr, status = Open3.capture3("echo { \"cephx_secret\": \"#{osd_secret}\" } | cephadm shell -m /etc/#{cluster_name}:/etc/ceph -- ceph osd new #{fsid} -i - -n client.bootstrap-osd -k /etc/ceph/ceph.keyring")
show_error(stderr, status)

osd_id = osd_id.strip
puts "New osd #{osd_name} created with fsid #{fsid}, osd_secret #{osd_secret} and id #{osd_id}"
#
# Handle device preparation
#
File.open("/tmp/env-#{osd_name}", File::CREAT | File::WRONLY) { |f| f.puts "ID=#{osd_id}\nOSD_SECRET=#{osd_secret}" }
FileUtils.mkdir_p("/etc/#{cluster_name}/osd/#{osd_name}")
Open3.capture3("mkfs.xfs /dev/vd#{vid}")
Open3.capture3("mount /dev/vd#{vid} /etc/#{cluster_name}/osd/#{osd_name}")
puts "Formatted device /dev/sd#{vid} and mounted"

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
