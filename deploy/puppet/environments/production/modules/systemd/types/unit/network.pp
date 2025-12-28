# @summary Possible keys for the [Swap] section of a unit file
# @see https://www.freedesktop.org/software/systemd/man/latest/systemd.swap.html
#
type Systemd::Unit::Network = Struct[
  {
    Optional['Bridge']           => String,
    Optional['Address']          => String,
    Optional['Gateway']          => String,
    Optional['DNS']              => String,
  }
]
