#!/usr/bin/env bash
PUPPET_MODULEPATH="$HOME/cloud-fed/deploy:$HOME/cloud-fed/modules"
PUPPET_SETUP_PATH="$HOME/cloud-fed/init/setup.pp"
PUPPET_SSL_PATH="/etc/puppetlabs/puppet/ssl"

BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'

# Prerequisitos

echo "--------------------------"
echo "Instalando dependencias..."
echo "--------------------------"
sudo apt -qq update
sudo apt -qq install -y curl rsync wget gnupg fuse3 fuse-overlayfs \
    nfs-kernel-server rpcbind jq yq

#
# Instalar dependencias del despliegue
# kvm, libvirtd, puppet, vagrant y podman
#

echo "--------------------"
echo "Instalando Puppet..."
echo "--------------------"
# Añadir repositorios de puppet
if [ !$(dpkg -l puppet8-release) ]; then
    echo "Puppet Forge api key: "
    read api_key
    echo "Installing puppet repositories"

    wget -q --content-disposition \
        "https://apt-puppetcore.puppet.com/public/puppet8-release-$(lsb_release -cs).deb"
    sudo dpkg -i "puppet8-release-$(lsb_release -cs).deb"

    sudo bash -c "cat << EOT > /etc/apt/auth.conf.d/apt-puppetcore-puppet.conf
machine apt-puppetcore.puppet.com
login forge-key
password $api_key
EOT"
else
    echo "${YELLOW}----------------------------------"
    echo "${YELLOW}WARNING: Puppet installation found"
    echo "${YELLOW}----------------------------------"
fi

# Añadir repositorios de vagrant
if [ !$(dpkg -l vagrant) ]; then
    echo "Installing vagrant repositories"

    wget -q -O - https://apt.releases.hashicorp.com/gpg \
        | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

    sudo bash -c "cat << EOT > /etc/apt/sources.list.d/hashicorp.list
deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main
EOT"
else
    echo "${YELLOW}----------------------------------"
    echo "${YELLOW}WARNING: Vagrant installation found"
    echo "${YELLOW}----------------------------------"
fi

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
    echo "${YELLOW}--------------------------------------------------------"
    echo "${YELLOW}WARNING: Possible podman alvistack installation detected"
    echo "${YELLOW}--------------------------------------------------------"
fi

echo "Instalando dependencias"
echo "qemu-system libvirt-daemon-system vagrant openjdk-17-jdk openjdk-17-jre \
    puppetserver puppet-agent podman"
sudo apt -qq update
sudo apt -qq install -y \
    qemu-system libvirt-daemon-system \
    vagrant \
    openjdk-17-jdk openjdk-17-jre puppetserver puppet-agent hiera puppet-bolt\
    python3 python3-pip \
    podman podman-netavark crun &>/dev/null

sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
sudo /opt/puppetlabs/bin/puppet \
    config set server cephgateway03.intra.unizar.es \
    --section main

# Instalación específica de ruby
gpg --keyserver keyserver.ubuntu.com \
    --recv-keys \
    409B6B1796C275462A1703113804BB82D39DC0E3 \
    7D2BAF1CF37B13E2069D6956105BD0E739499BDB

curl -sSL https://get.rvm.io | bash -s stable
source /home/cephadm/.rvm/scripts/rvm
rvm install ruby-3.1.7

gem install hiera fog-libvirt
echo "export PATH=$HOME/.rvm/gems/ruby-3.1.7/bin:$PATH" >> ~/.bashrc


#
# Despliegue de los bridge para las vm y gateway
#
sudo /opt/puppetlabs/bin/puppet config set codedir \
    $HOME/cloud-fed/deploy/puppet \
    --section server

sudo /opt/puppetlabs/bin/puppet config set environmentpath \
    $HOME/cloud-fed/deploy/puppet/environments/production \
    --section server

sudo /opt/puppetlabs/bin/puppet config set basemodulepath \
    $HOME/cloud-fed/deploy/puppet/environments/production/modules \
    --section server

sudo /opt/puppetlabs/bin/puppet config set hiera_config \
    $HOME/cloud-fed/deploy/puppet/environments/production/hiera.yaml \
    --section server


sudo sed -i \
    "s/server-code-dir/\/.*$/\/home\/cephadm\/cloud-fed\/deploy\/puppet/" \
    /etc/puppetlabs/puppetserver/conf.d/puppetserver.conf
sudo groupadd deploy
sudo usermod -aG deploy cephadm
sudo usermod -aG deploy puppet
sudo chown -R cephadm:deploy $HOME/cloud-fed
sudo chmod -R 775 $HOME/cloud-fed
sudo chmod -R 755 $HOME

sudo /opt/puppetlabs/bin/puppet apply \
    $PUPPET_SETUP_PATH \
    --modulepath=$PUPPET_MODULEPATH

sudo /opt/puppetlabs/bin/puppetserver ca generate \
    --certname vm0-cert,vm1-cert

sudo cp $PUPPET_SSL_PATH/certs/ca.pem /tmp
sudo cp $PUPPET_SSL_PATH/certs/vm0-cert.pem /tmp
sudo cp $PUPPET_SSL_PATH/certs/vm1-cert.pem /tmp
sudo cp $PUPPET_SSL_PATH/private_keys/vm0-cert.pem /tmp/pk-vm0-cert.pem
sudo cp $PUPPET_SSL_PATH/private_keys/vm1-cert.pem /tmp/pk-vm1-cert.pem

echo "${GREEN}--------------------------------------------------"
echo "${GREEN}Certificados de agentes Puppet firmados y en sitio"
echo "${GREEN}--------------------------------------------------"

sudo chmod o+r /tmp/*.pem

#
# Despliegue de las VM con vagrant
#

# Definición de pool de almacenamiento para VM
echo "${BLUE}--------------------------------------------"
echo "${BLUE}Creación de pooles de almacenamiento para VM"
echo "${BLUE}--------------------------------------------"

sudo mkdir -p /var/lib/virt/images
sudo mkfs.ext4 /dev/sda
sudo mount /dev/sda /var/lib/virt/images
virsh -c qemu:///system \
    pool-define-as \
    --name virtimages \
    --type dir \
    --target /var/lib/virt/images

virsh -c qemu:///system \
    pool-start virtimages

virsh -c qemu:///system \
    pool-autostart virtimages

# Instalación del plugin vagrant-libvirt
echo "${BLUE}---------------------------------"
echo "${BLUE}Instalando plugin vagrant-libvirt"
echo "${BLUE}---------------------------------"

vagrant plugin install vagrant-libvirt

ssh-keygen -q \
    -t ecdsa \
    -f /tmp/id_ecdsa.k1 \
    -N ""

ssh-keygen -q \
    -t ecdsa \
    -f /tmp/id_ecdsa.k2 \
    -N ""

# Rootless virsh
sudo usermod -aG libvirt $USER

echo "${GREEN}----------------"
echo "${GREEN}Plugin instalado"
echo "${GREEN}----------------"

echo "${BLUE}-----------------------------------------"
echo "${BLUE}Desplegando máquinas para infraestructura"
echo "${BLUE}-----------------------------------------"

vagrant up

echo "${GREEN}--------------------"
echo "${GREEN}Máquinas desplegadas"
echo "${GREEN}--------------------"


sudo ip r add 192.168.0.0/19 via 10.88.0.144

# Modificar ips de administración en el inventorio

vm0_ip=$(vagrant ssh vm0 -- ip -j a show eth0 \
    | jq -r '.[] | .addr_info[0].local')
vm1_ip=$(vagrant ssh vm1 -- ip -j a show eth0 \
    | jq -r '.[] | .addr_info[0].local')

yq -y \
    -i "(.targets[] | select(.name == 'vm0-cert')).uri = '$vm0_ip'" \
    inventory.yaml

yq -y \
    -i "(.targets[] | select(.name == 'vm1-cert')).uri = '$vm1_ip'" \
    inventory.yaml

#
# Ofrecer comando para desplegar la infraestructura
#
echo "${BLUE}---------------------------"
echo "${BLUE}Desplegando infraestructura"
echo "${BLUE}---------------------------"
bolt plan run \
    --project $HOME/cloud_fed/deploy/puppet/environments/production \
    cloud_fed::deploy_federation

echo "${GREEN}--------------------------"
echo "${GREEN}Infraestructura desplegada"
echo "${GREEN}--------------------------"

