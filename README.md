The repository was created in order to check if it possible to run specific kernel version in GitHub Actions runner.

**NOTE:** Public runners VM have disabled KVM acceleration, so performance will not be the best.

# About files

- [kernel.yml](.github/workflows/kernel.yml) - configures workflow, run required scripts. It also uses cache to speed up tests,
in this demo cache has size about 1400 MB.
- [prepare_runner.sh](prepare_runner.sh) - installs all required packages and configure host. It also recreate `default` network
(using [default_network.xml](default_network.xml)) with DHCP that have only one IP in its pool so VM will always have the same IP.
- [build_vm.sh](build_vm.sh) - builds disk image for VM. It uses pre-built images provided by [`virt-builder`](https://libguestfs.org/virt-builder.1.html).
Note that resize image with Ubuntu 20.04 is not possible, because it uses extenden partition. The script must be executed when
there is no cached disk image. Configuration of target system is following:
  - Disk image name: `inner.qcow2`. Compression enabled.
  - Hostname: `inner`.
  - User `ubuntu` with password `ubuntu`. `sudo` is executed without password.
  - Installs kernel `5.8.0-63` from system repository.
  - Configures additional serial console (useful for debugging on local machine).
  - Configures `netplan` to use DHCPv4 on every `en*` interface. Config file is [netcfg.yaml](netcfg.yaml).
  - Configures shared directory with host to share files from git repository. Option `_netdev` is required to delay mount of
  filesystem, because `9p` modules are not built-in into initrd by deafult.
  - To be sure VM is ready after boot, wait for SSH server (see [test.sh](test.sh#L7)).
- [install_vm.sh](install_vm.sh) - imports disk image into `libvirt` and start it. It also extracts initrd and kernel image
from disk and boots directly into it. Resources passed to VM are 2 vCPU cores (no more available on runner) and 2GB RAM (from 7 GB).
- [test.sh](test.sh) - script that runs test. It uses `ssh` to run commands and `sshpass` to login with password. After tests
it shutdown VM and wait for finish this operation in order to properly build cache (file with disk image might be modified
during shutdown).

# Possible improvements

- Change working directory, for example to `.github/kernel/`.
- Use environment varibles in [kernel.yml](.github/workflows/kernel.yml) instead hardcoded values inside every script.
- Use separate test script to run inside VM and other to run from [kernel.yml](.github/workflows/kernel.yml).
- Create more steps to separate VM management and tests.

# Example logs from Actions run

## Build VM
```
Run sudo ./build_vm.sh
[   3.4] Downloading: http://builder.libguestfs.org/ubuntu-20.04.xz
#=#=#                                                                         

######################################################################## 100.0%##O#- #                                                                       
##=O#- #                                                                      
#-#O=#  #                                                                     

                                                                           0.0%
...
#######################################################################   99.4%
######################################################################## 100.0%
[  30.2] Planning how to build this image
[  30.2] Uncompressing
[  50.3] Converting raw to qcow2
[  54.3] Opening the new disk
[ 110.1] Setting a random seed
virt-builder: warning: random seed could not be set for this type of guest
[ 110.2] Setting the hostname: inner
[ 118.8] Setting the timezone: Etc/UTC
[ 119.0] Updating packages
[1751.1] Installing packages: linux-image-5.8.0-63-generic linux-modules-5.8.0-63-generic linux-modules-extra-5.8.0-63-generic linux-tools-5.8.0-63-generic
[2259.1] Running: useradd -p wk3oxPMUIX7cc -s /bin/bash -m -d /home/runner/work/kernel-version-demo/kernel-version-demo -G sudo ubuntu
[2259.9] Editing: /etc/sudoers
[2260.3] Editing: /etc/default/grub
[2260.6] Running: update-grub
[2283.3] Uploading: netcfg.yaml to /etc/netplan/netcfg.yaml
[2283.5] Running: chown root:root /etc/netplan/netcfg.yaml
[2284.2] Running: echo "runner /home/runner/work/kernel-version-demo/kernel-version-demo 9p defaults,_netdev 0 0" >> /etc/fstab
[2284.7] Installing firstboot command: dpkg-reconfigure openssh-server
[2285.2] Setting passwords
virt-builder: Setting random password of root to FhcRtgTN4yPq3kC0
[2295.2] Finishing off
                   Output file: ./inner.qcow2
                   Output size: 6.0G
                 Output format: qcow2
            Total usable space: 5.8G
                    Free space: 3.2G (54%)
```

## Launch VM
```
Run sudo ./install_vm.sh
WARNING  KVM acceleration not available, using 'qemu'

Starting install...
Domain creation completed.
```

## Run test script
```
Run ./test.sh
wait-for-it: waiting 300 seconds for 192.168.122.2:22
wait-for-it: 192.168.122.2:22 is available after 25 seconds
ready
+ sshpass -p ubuntu ssh -o StrictHostKeyChecking=no ubuntu@192.168.122.2 uname -a
Warning: Permanently added '192.168.122.2' (ECDSA) to the list of known hosts.
Linux inner 5.8.0-63-generic #71~20.04.1-Ubuntu SMP Thu Jul 15 17:46:08 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
+ sshpass -p ubuntu ssh ubuntu@192.168.122.2 'pwd; ls'
/home/runner/work/kernel-version-demo/kernel-version-demo
build_vm.sh
default_network.xml
initrd.img-5.8.0-63-generic
inner
inner.qcow2
install_vm.sh
netcfg.yaml
prepare_runner.sh
README.md
test.sh
vmlinuz-5.8.0-63-generic
+ sshpass -p ubuntu ssh ubuntu@192.168.122.2 df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            964M     0  964M   0% /dev
tmpfs           199M  708K  199M   1% /run
/dev/vda5       5.4G  2.7G  2.4G  53% /
tmpfs           994M     0  994M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           994M     0  994M   0% /sys/fs/cgroup
/dev/vda1       511M  4.0K  511M   1% /boot/efi
runner           84G   53G   31G  64% /home/runner/work/kernel-version-demo/kernel-version-demo
tmpfs           199M     0  199M   0% /run/user/1001
+ sudo virsh shutdown inner
Domain inner is being shutdown

+ sudo virsh domstate inner
+ grep shut
+ sleep 5
+ sudo virsh domstate inner
+ grep shut
shut off
```
