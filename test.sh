#!/bin/bash -e

# Test script

IP="192.168.122.2"

wait-for-it "$IP:22" -t 300 -- echo ready

set -x

sshpass -p ubuntu ssh -o "StrictHostKeyChecking=no" "ubuntu@$IP" uname -a

sshpass -p ubuntu ssh "ubuntu@$IP" pwd

sshpass -p ubuntu ssh "ubuntu@$IP" df -h

sudo virsh shutdown inner
