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

echo ""

free

echo ""

kvm-ok

# kvm-ok will exit with error so override it
exit 0

