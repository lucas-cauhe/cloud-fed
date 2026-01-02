# Deploy an Opennebula 2-site federation with custom policies management

This project arises from the need to sovereign data and design a policy enforcing system to manage cloud resources.
Those resources include users, virtual definitions of machines and networks and the infrastructure supporting the cloud deployment.

## Features

- Policies management
- Infrastructure monitoring
- Ceph datastore

## Deployment (3 phases)

### Initialisation

Installation of packages needed for the next phases.
This packages inlcude `podman` from the `alvistack` repository, Puppetserver and Vagrant.
In this phase the virtual machines where each OpenNebula instance will be deployed are created and provisioned.

### Puppet phase

From the init script puppet bolt deploys the infrastructure on each virtual machine.
The deployment order for each individual component is defined carefully, distributing plans when possible.
The result of this phase is a federation established between two OpenNebula instances, backed by Ceph datastores.

### OpenTofu phase

Now the federation services can be deployed.
These services include the resources catalog (OpenNebula Marketplace) and the policies manager (OPA).

## Usage

Just install Debian in your server and run the `init.sh` script under `deploy/init`.

## TODO

- Define OpenNebula custom resources in Puppet
- Move all the config to Hiera
- Secrets management
- Improve deployment logging
- Try to use librados from ruby and deploy Ceph using librados interface
