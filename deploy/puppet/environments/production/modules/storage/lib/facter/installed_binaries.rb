Facter.add('installed_binaries') do
  setcode do
    binaries = ['python3', 'podman']
    binaries.inject({}) do |memo, bin|  
      if Facter::Core::Execution.execute("which #{bin}") 
        memo.merge({ "#{bin}": { "version": Facter::Core::Execution.execute("#{bin} --version").strip[/[0-9\.]+/] } }) 
      else
        memo
      end
    end
  end
end
