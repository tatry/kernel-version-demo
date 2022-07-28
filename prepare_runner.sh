#!/bin/bash

# Script to prepare runner: install all packages to build and run virtual machine

sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst libguestfs-tools

echo ""

free

echo ""

kvm-ok

