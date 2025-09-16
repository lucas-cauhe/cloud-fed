# @summary Possible keys for the [Swap] section of a unit file
# @see https://www.freedesktop.org/software/systemd/man/latest/systemd.swap.html
#
type Systemd::Unit::PodmanNetwork = Struct[
  {
    Optional['Driver']           => String,
    Optional['Gateway']          => String,
    Optional['IPRange']          => String,
    Optional['NetworkName']              => String,
    Optional['Options']              => String,
    Optional['Subnet']              => String,
  }
]
