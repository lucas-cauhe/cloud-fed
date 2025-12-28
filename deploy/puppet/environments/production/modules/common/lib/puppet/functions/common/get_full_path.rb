
Puppet::Functions.create_function(:'common::get_full_path') do 
  dispatch :_get_full_path do
    param 'String', :command
  end

  def _get_full_path(command)
    #which $command.split[0] | rev | cut -d '/' -f2- | rev
    Puppet.notice("GETTING FULL PATH FOR COMMAND #{command}")
    path = `which #{command.split[0]}`
    Puppet.notice("FULL PATH FOR COMMAND #{path}")
    path.sub(/([\/\w]+)\/\w+/) do |match|
      Puppet.notice("Matched PATH STRING #{$1}")
      return $1
    end
  end
end
