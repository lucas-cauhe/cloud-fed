require 'securerandom'
Puppet::Functions.create_function(:'storage::uuid') do 
  dispatch :_uuid do 
  end

  def _uuid 
    SecureRandom.uuid
  end
end
