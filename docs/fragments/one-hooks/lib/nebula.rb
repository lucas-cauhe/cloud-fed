require "opennebula"

include OpenNebula

module One
  CREDENTIALS = "oneadmin:xxxxxxx"
  ENDPOINT = nil

  # Inicializar comunicación con API
  def set_endpoint(endpoint)
    @ENDPOINT = endpoint
    @client = Client.new(@ENDPOINT, @CREDENTIALS)
  end

  # Eliminar MV de OpenNebula
  def delete_vm(vmname)
    vm = VirtualMachine.new(VirtualMachine.build_xml(vmname), @client)
    vm.delete
  end

  # Eliminar imagen de OpenNebula
  def delete_image(iname)
    image = Image.new(Image.build_xml(iname), @client)
    image.delete
  end

  # Eliminar hook de OpenNebula
  def delete_hook(hname)
    hook = Hook.new(Hook.build_xml(hname), @client)
    hook.delete
  end

  # Eliminar backupjob de OpenNebula
  def delete_backupjob(bjname)
    image = BackupJob.new(BackupJob.build_xml(bjname), @client)
    image.delete
  end

  # Elimina un recurso de OpenNebula
  # rtype -> tipo de recurso
  # rname -> id del recurso
  def delete_resource(rtype, rname)
    begin
      case rtype
      when "vm"
        delete_vm(rname)
      when "image"
        delete_image(rname)
      when "hook"
        delete_hook(rname)
      when "backupjob"
        delete_backupjob(rname)
      end
    rescue
      puts "Failed to perform action #{rtype} on #{rname}"
    end
  end
end
