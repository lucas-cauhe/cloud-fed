TAGS_MAP = {
  :prod => "80",
  :dev => "50",
  :test => "10",
}

def update_backupjob(action, api_info)
  backupjob_file = "one-10-"
  current_vm_id = ""
  if action == :insert
    api_info.xpath("/CALL_INFO/PARAMETERS/PARAMETER").each do |param|
      if param.xpath("POSITION").text.to_i == 2 and param.xpath("TYPE").text == "IN"
        resource_template = parse_template(param.xpath("VALUE").text)
        label = resource_template["LABELS"][..-2]
        puts label
        backupjob_file += TAGS_MAP[label.to_sym]
        current_vm_id = `onevm list -f NAME=#{resource_template["NAME"]} --no-header | cut -d ' ' -f4`
      end
    end
  else
    api_info.xpath("/CALL_INFO/PARAMETERS/PARAMETER").each do |param|
      if param.xpath("POSITION").text.to_i == 2 and param.xpath("TYPE").text == "IN"
        action = param.xpath("VALUE").text
        if action != "terminate" and action != "terminate-hard"
          exit 0
        end
      end
      if param.xpath("POSITION").text.to_i == 2 and param.xpath("TYPE").text == "OUT"
        current_vm_id = param.xpath("VALUE").text
      end
    end
    #
    # Obtener label con el que se ha creado
    #
    label = `onevm show #{current_vm_id} | grep LABELS | cut -d '"' -f2`
    backupjob_file = "one-10-" + TAGS_MAP[label[..-2].to_sym]
  end
  #
  # Obtener máquinas actuales
  #
  backupjob_id = `onebackupjob list -f NAME=#{backupjob_file} --no-header | cut -d ' ' -f4`
  current_vms = `onebackupjob show #{backupjob_id} | grep BACKUP_VMS`

  if action == :insert
    modified_vms = current_vms[..-2] + current_vm_id + "\""
  else
    modified_vms = current_vms.gsub(/5/, "")
    modified_vms = modified_vms.gsub(/,,/, ",")
  end
  #
  # Modificar backupjob
  #
  temp_file = "/tmp/update_backupjob_#{backupjob_file}.tmpl"
  File.write(temp_file, modified_vms)
  `onebackupjob update #{backupjob_id} #{temp_file}`
  File.delete(temp_file)
end
