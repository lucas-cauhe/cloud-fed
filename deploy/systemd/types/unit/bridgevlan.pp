# @summary Possible keys for the [Swap] section of a unit file
# @see https://www.freedesktop.org/software/systemd/man/latest/systemd.swap.html
#
type Systemd::Unit::BridgeVLAN = Struct[
  {
    Optional['PVID']           => Integer,
    Optional['VLAN']           => Array[Integer],
    Optional['EgressUntagged']        => Integer,
  }
]
