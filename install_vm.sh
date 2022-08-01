#!/bin/bash

# Script to build virtual machine.
# Must be run once on fresh runner to add VM to libvirt.

OS_TYPE="ubuntu-20.04"
VM_NAME="inner"
DISK_IMAGE="/var/lib/libvirt/images/$VM_NAME.qcow2"

USER_NAME="ubuntu"
USER_PASS=`mkpasswd ubuntu`
USER_HOME=`pwd`

virt-install --import \
    --name "$VM_NAME" \
    --vcpu 2 \
    --ram 2048 \
    --disk path="$DISK_IMAGE" \
    --os-variant ubuntu20.04 \
    --network network:default \
    --graphics none \
    --console pty,target_type=serial \
    --noautoconsole

# give some time to start services, required before obtaining DHCP lease
sleep 10
