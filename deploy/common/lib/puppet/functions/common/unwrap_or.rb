
Puppet::Functions.create_function(:'common::unwrap_or') do 
  dispatch :_unwrap_or do
    param 'Optional[String]', :opt
    param 'String', :fallback
  end

  def _unwrap_or(opt, fallback)
    opt || fallback
  end
end
