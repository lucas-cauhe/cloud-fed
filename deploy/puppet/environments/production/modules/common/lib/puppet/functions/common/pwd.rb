
Puppet::Functions.create_function(:'common::pwd') do 
  dispatch :_pwd do
  end

  def _pwd
    `pwd`.sub(/\n/, '')
  end
end
