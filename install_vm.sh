#!/bin/bash

# Script to build virtual machine.
# Must be run once on fresh runner to add VM to libvirt.

OS_TYPE="ubuntu-20.04"
VM_NAME="inner"
DISK_IMAGE="./$VM_NAME.qcow2"

mkdir inner
guestmount -a inner.qcow2 -i --ro inner/
sudo cp inner/boot/initrd.img-5.8.0-63-generic .
sudo cp inner/boot/vmlinuz-5.8.0-63-generic .
sudo guestunmount inner

virt-install --import \
    --name "$VM_NAME" \
    --vcpu 2 \
    --ram 2048 \
    --disk path="$DISK_IMAGE" \
    --os-variant ubuntu20.04 \
    --network network:default \
    --graphics none \
    --console pty,target_type=serial \
    --noautoconsole \
    --filesystem "`pwd`",runner \
    --boot kernel=./vmlinuz-5.8.0-63-generic,initrd=./initrd.img-5.8.0-63-generic,kernel_args="ro console=tty0 console=ttyS0,115200n8 root=/dev/vda5"

# To change kernel later you have to have proper initrd and vmlinuz on local disk (not inside a VM) and fix xml definition of VM. 
