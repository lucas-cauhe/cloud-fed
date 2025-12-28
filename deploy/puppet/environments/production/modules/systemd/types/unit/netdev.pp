# @summary Possible keys for the [Swap] section of a unit file
# @see https://www.freedesktop.org/software/systemd/man/latest/systemd.swap.html
#
type Systemd::Unit::NetDev = Struct[
  {
    Optional['Name']           => String,
    Optional['Kind']        => Enum['bridge', 'bond', 'tun', 'veth', 'gre'],
  }
]
