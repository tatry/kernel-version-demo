#!/bin/bash -e

# Test script

IP="192.168.122.2"

wait-for-it "$IP:22" -t 300 -s -- echo ready

set -x

sshpass -p ubuntu ssh -o "StrictHostKeyChecking=no" "ubuntu@$IP" uname -a

sshpass -p ubuntu ssh "ubuntu@$IP" "pwd; ls"

sshpass -p ubuntu ssh "ubuntu@$IP" df -h

sudo virsh shutdown inner
# wait for guest to shutdown itself
until sudo virsh domstate inner | grep shut; do
    sleep 5
done
