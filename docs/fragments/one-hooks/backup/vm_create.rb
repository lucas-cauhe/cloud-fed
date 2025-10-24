#!/usr/bin/env ruby

require "base64"
require "nokogiri"

TAGS_MAP = {
  :prod => "80",
  :dev => "50",
  :test => "10",
}

#
# Al crear una MV, incluir el id en la tarea correspondiente
#

api_info = Nokogiri::XML(Base64::decode64(ARGV[0]))

success = api_info.xpath("/CALL_INFO/RESULT").text.to_i == 1

if !success
  puts "Resource wasn't created, hook not executed"
  exit 0
end

#
# Obtener tag con el que se ha creado
#

def parse_template(template_content)
  template_content.split(/\n/).inject({}) do |prev, kv|
    if kv != "]"
      key, value = kv.strip.split("=")
      value = value.strip.gsub('"', "")
      if value != "["
        prev[key] = value
      end
    end
    prev
  end
end

backupjob_file = "one-10-"
current_vm_id = ""
api_info.xpath("/CALL_INFO/PARAMETERS/PARAMETER").each do |param|
  if param.xpath("POSITION").text.to_i == 2 and param.xpath("TYPE").text == "IN"
    resource_template = parse_template(param.xpath("VALUE").text)
    label = resource_template["LABELS"][..-2]
    puts label
    backupjob_file += TAGS_MAP[label.to_sym]
    current_vm_id = `onevm list -f NAME=#{resource_template["NAME"]} --no-header | cut -d ' ' -f4`
  end
end
puts "BACKUPJOB_FILE = #{backupjob_file}"
puts "CURRENT_VM_ID = #{current_vm_id}"

#
# Obtener máquinas actuales
#
backupjob_id = `onebackupjob list -f NAME=#{backupjob_file} --no-header | cut -d ' ' -f4`
current_vms = `onebackupjob show #{backupjob_id} | grep BACKUP_VMS`
puts "BACKUPJOB_ID = #{backupjob_id}"
puts "CURRENT_VMS = #{current_vms}"

modified_vms = current_vms[..-2] + current_vm_id + "\""
#
# Modificar backupjob
#
temp_file = "/tmp/update_backupjob_#{backupjob_file}.tmpl"
File.write(temp_file, modified_vms)
`onebackupjob update #{backupjob_id} #{temp_file}`
File.delete(temp_file)

exit 0
