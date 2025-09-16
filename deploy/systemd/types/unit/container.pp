# @summary Possible keys for the [Swap] section of a unit file
# @see https://www.freedesktop.org/software/systemd/man/latest/systemd.swap.html
#
type Systemd::Unit::Container = Struct[
  {
    Optional['AddCapability']           => String,
    Optional['AddDevice']           => String,
    Optional['ContainerName']           => String,
    Optional['Exec']           => String,
    Optional['Image']           => String,
    Optional['Network']           => String,
    Optional['IP']           => String,
    Optional['Sysctl']           => String,
    Optional['Environment']           => Array[String],
    Optional['Volume']           => String,
    Optional['HostName']           => String,
    Optional['EnvironmentFile']           => String,
    Optional['Label']           => String,
    Optional['Ulimit']           => String
  }
]
