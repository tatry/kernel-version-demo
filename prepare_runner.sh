#!/bin/bash

# Script to prepare runner: install all packages to build and run virtual machine.
# Must be run every time (fresh runner) job starts.

apt install -y \
    bridge-utils \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    virtinst \
    libguestfs-tools \
    wait-for-it \
    whois \
    sshpass

# Re-define default network to always assign the same IP address
virsh net-destroy default
virsh net-undefine default
virsh net-define ./default_network.xml
virsh net-autostart default
virsh net-start default

exit 0
