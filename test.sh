#!/bin/bash -x

# Test script

virsh list --all

virsh net-list --all

virsh net-dhcp-leases default

IP=`virsh net-dhcp-leases default | grep inner | awk '{print $5}' | awk -F '/' '{print $1}'`

wait-for-it "$IP:22" -t 300 -- echo ready

sshpass -p ubuntu ssh -o "StrictHostKeyChecking=no" "ubuntu@$IP" uname -a

echo ""

sshpass -p ubuntu ssh "ubuntu@$IP" pwd

echo ""

sshpass -p ubuntu ssh "ubuntu@$IP" df -h

virsh shutdown inner

# success
exit 0

