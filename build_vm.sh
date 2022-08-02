#!/bin/bash

# Script to build virtual machine.
# Must be run when there is no cache hit for disk.

OS_TYPE="ubuntu-20.04"
VM_NAME="inner"
DISK_IMAGE="./$VM_NAME.qcow2"

USER_NAME="ubuntu"
USER_PASS=`mkpasswd ubuntu`
USER_HOME=`pwd`

virt-builder "$OS_TYPE" \
    --hostname "$VM_NAME" \
    --network \
    --timezone "`cat /etc/timezone`" \
    --format qcow2 -o "$DISK_IMAGE" \
    --update \
    --install "linux-image-5.8.0-63-generic,linux-modules-5.8.0-63-generic,linux-modules-extra-5.8.0-63-generic,linux-tools-5.8.0-63-generic" \
    --run-command "useradd -p $USER_PASS -s /bin/bash -m -d $USER_HOME -G sudo $USER_NAME" \
    --edit '/etc/sudoers:s/^%sudo.*/%sudo	ALL=(ALL) NOPASSWD:ALL/' \
    --edit '/etc/default/grub:s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"/' \
    --run-command update-grub \
    --upload netcfg.yaml:/etc/netplan/netcfg.yaml \
    --run-command "chown root:root /etc/netplan/netcfg.yaml" \
    --run-command 'echo "runner '"$USER_HOME"' 9p defaults,_netdev 0 0" >> /etc/fstab' \
    --firstboot-command "dpkg-reconfigure openssh-server"

# wait for SSH server to be sure VM is ready when starting it

# Enable compression on disk
mv "$DISK_IMAGE" "$DISK_IMAGE.old"
qemu-img convert -O qcow2 -c "$DISK_IMAGE.old" "$DISK_IMAGE"
rm -f "$DISK_IMAGE.old"
