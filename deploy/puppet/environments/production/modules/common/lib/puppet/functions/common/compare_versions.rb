
Puppet::Functions.create_function(:'common::compare_versions') do 

  dispatch :_compare_versions do
    param 'String', :received
    param 'String', :expected
  end

  def _compare_versions(received, expected)
    return if expected == "any"
    ineq_sign = expected[0,1]
    case ineq_sign
    when "<"
      error_message(expected, received) unless cmp(received, expected[1..-1], :<=)
    when ">"
      error_message(expected, received) unless cmp(received, expected[1..-1], :>=)
    else
      error_message(expected, received) unless cmp(received, expected, :==)
    end
  end

  def cmp(rcvd, exp, cmp_sign)
    exp_splitted = exp.split('.')
    rcvd.split('.').each_with_index do |item, index|
      break unless exp_splitted[index]
      return false unless item.to_i.send(cmp_sign, exp_splitted[index].to_i)
    end
    return true
  end

  def error_message(expected, received)
    Puppet.err("Expected: #{expected}, got #{received}")
  end
end
