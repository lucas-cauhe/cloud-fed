#!/usr/bin/env bash
PUPPETSERVER="/opt/puppetlabs/bin/puppetserver"
CERTS="vm0-cert,vm1-cert"

# Clean puppet certificates
sudo $PUPPETSERVER ca clean --certname $CERTS

# Shutdown machines
vagrant destroy -f
