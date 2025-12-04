require "opennebula"

include OpenNebula

module One
  CREDENTIALS = "oneadmin:oneadmin"
  ENDPOINT = nil

  def set_endpoint(endpoint)
    @ENDPOINT = endpoint
    @client = Client.new(@ENDPOINT, @CREDENTIALS)
  end

  def delete_vm(vmname)
    vm = VirtualMachine.new(VirtualMachine.build_xml(vmname), @client)
    vm.delete
  end

  def delete_image(iname)
    image = Image.new(Image.build_xml(iname), @client)
    image.delete
  end

  def delete_hook(hname)
    hook = Hook.new(Hook.build_xml(hname), @client)
    hook.delete
  end

  def delete_backupjob(bjname)
    image = BackupJob.new(BackupJob.build_xml(bjname), @client)
    image.delete
  end

  def delete_resource(rtype, rname)
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
  end
end
