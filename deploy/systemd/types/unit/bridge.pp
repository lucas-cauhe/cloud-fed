# @summary Possible keys for the [Swap] section of a unit file
# @see https://www.freedesktop.org/software/systemd/man/latest/systemd.swap.html
#
type Systemd::Unit::Bridge = Struct[
  {
    Optional['VLANFiltering']           => Enum['yes', 'no'],
    Optional['STP']	                => Enum['yes', 'no'],
  }
]
