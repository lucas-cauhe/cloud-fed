#!/usr/bin/env bash
PUPPETSERVER="cephgateway03.intra.unizar.es"
VMID=$1
PRIV_KEY=$2
PUB_KEY=$3

export DEBIAN_FRONTEND=noninteractive

sudo apt -qq update
sudo apt -qq install -y curl rsync wget gnupg \
    fuse3 fuse-overlayfs python3 lvm2

# Install Puppet agent
wget https://apt.puppet.com/puppet8-release-bookworm.deb
dpkg -i puppet8-release-bookworm.deb
apt-get -qq update
apt-get -qq install -y puppet-agent

echo "10.0.13.71     $PUPPETSERVER" >> /etc/hosts

# Configure Puppet
cat > /etc/puppetlabs/puppet/puppet.conf <<EOF
[main]
certname = vm${VMID}-cert
server = $PUPPETSERVER
EOF

# Enable and start Puppet service
systemctl enable puppet
systemctl start puppet

sudo ln -s /opt/puppetlabs/puppet/bin/ruby /usr/bin/ruby

# Añadir repositorios alvistack para podman >=v4.4
alvistack_repokey="/etc/apt/trusted.gpg.d/alvistack.gpg"
if [ ! -f $alvistack_repokey ]; then
    wget -q -O - http://downloadcontent.opensuse.org/repositories/home:/alvistack/Debian_12/Release.key \
        | sudo gpg --dearmor -o $alvistack_repokey

    sudo bash -c "cat << EOT > /etc/apt/sources.list.d/alvistack.list
deb http://downloadcontent.opensuse.org/repositories/home:\
/alvistack/Debian_12/ /
EOT"
else
    echo "--------------------------------------------------------"
    echo "WARNING: Possible podman alvistack installation detected"
    echo "--------------------------------------------------------"
fi

sudo apt -qq update
sudo apt -qq install -y \
    podman podman-netavark crun \
    ceph-common

echo $PRIV_KEY | base64 --decode > /home/vagrant/.ssh/id_ecdsa
echo $PUB_KEY | base64 --decode >> /home/vagrant/.ssh/authorized_keys

sudo chmod 0600 /home/vagrant/.ssh/id_ecdsa

# Directorios para ficheros temporales
mkdir /tmp/templates
mkdir /tmp/scripts

# para conseguir libruby de los repos oficiales
sudo rm /etc/apt/sources.list.d/alvistack.list

# configuracion de red
NETID="$((VMID + 1))0"
echo "Setting up network..."

sudo ip link add name frontend type bridge
sudo ip link add name br_stor type bridge
sudo ip link set eth1 master frontend
sudo ip a flush dev eth1
sudo ip link set eth1 up
sudo ip link set frontend up

echo "Frontend bridge configured"

# conexión macvlan

echo "Setting up macvlan connection"
sudo ip link add link frontend name host-bridge type macvlan mode bridge
sudo ip a add 192.168.$NETID.250/24 dev host-bridge
sudo ip link set host-bridge up
echo "macvlan has ip address"
sudo ip r add 192.168.$NETID.0/24 dev host-bridge
echo "Macvlan connection configured"
