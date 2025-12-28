require 'securerandom'
require 'base64'
Puppet::Functions.create_function(:'storage::cephx_key') do 
  dispatch :_cephx_key do 
  end

  def _cephx_key 
    rb = SecureRandom.random_bytes(16)
    Base64.strict_encode64(rb)
  end
end
