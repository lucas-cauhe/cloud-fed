
Puppet::Functions.create_function(:'common::var_subs') do 
  dispatch :_var_subs do
    param 'String', :src
    param 'Hash', :ns
  end

  def _var_subs(src, ns)
    # For each %expr%
    # Evaluate it agains the ns
    # Substitute with evaluation result
    # The regex matches %expr%
    #  where expr is divided into: 
    #    main variable name -> (\w+)
    #    traverse its values hash-style -> (\[\w+\])
    #  example -> %network['interface_name'][:ipaddress]%
    Puppet.notice("Incoming namespace: #{ns}")
  end
end
