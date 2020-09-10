#!/bin/bash
## OSS Node Install Script
# Variables
index_value=`facter index_value`
mgt_vm_name=`facter mgt_vm_name`

echo "Installing dependency packages"
yum install asciidoc audit-libs-devel automake bc binutils-devel bison device-mapper-devel elfutils-devel elfutils-libelf-devel expect flex gcc gcc-c++ git glib2 glib2-devel hmaccalc keyutils-libs-devel krb5-devel ksh libattr-devel libblkid-devel libselinux-devel libtool libuuid-devel libyaml-devel lsscsi make ncurses-devel net-snmp-devel net-tools newt-devel numactl-devel parted patchutils pciutils-devel perl-ExtUtils-Embed pesign python-devel redhat-rpm-config rpm-build systemd-devel tcl tcl-devel tk tk-devel wget xmlto yum-utils zlib-devel -y
if [ $? -eq 0 ]
then
echo "Dependency packages installation successful."
else
echo "ERROR: Dependency packages installation failed."
exit 1
fi

cd /opt/lustre-temp/e2fsprogs-wc/RPMS/x86_64/
yum localinstall *.rpm -y
if [ $? -eq 0 ]
then
echo "Lustre packages installation successful."
else
echo "ERROR: Lustre packages installation failed."
exit 1
fi


cd /opt/lustre-temp/lustre-server/RPMS/x86_64/
yum remove kernel-tools kernel-tools-libs -y
## Kernel Modules, please slect the kernel version based on your server in my case it is "3.10.0-162" from script 1
#new
yum localinstall kernel-devel-3.10.0-1062.9.1.el7_lustre.x86_64.rpm kernel-headers-3.10.0-1062.9.1.el7_lustre.x86_64.rpm -y
yum install kernel-tools -y

if [ $? -eq 0 ]
then
	echo "Kernel packages installation successful."
else
	echo "ERROR: Kernel packages installation failed."
	exit 1
fi

# KMOD modules, please select the kmod versions, it might vary based on the server version but will be listed on the respective folder "/opt/lustre-temp/lustre-server/RPMS/x86_64/ "
echo "Installing Lustre packages"
yum localinstall kmod-lustre-2.12.4-1.el7.x86_64.rpm kmod-lustre-osd-ldiskfs-2.12.4-1.el7.x86_64.rpm lustre-osd-ldiskfs-mount-2.12.4-1.el7.x86_64.rpm lustre-2.12.4-1.el7.x86_64.rpm lustre-resource-agents-2.12.4-1.el7.x86_64.rpm -y
if [ $? -eq 0 ]
then
echo "Lustre package installation successful."
else
echo "ERROR: Lustre packages installation failed."
exit 1
fi
## To verify the Lustre
modprobe -v lustre
echo "Lustre installation completed"

###########################
## MGS/MDT ##
## Disable Iptables
iptables -F
#crontab -r
ip6tables -F
systemctl disable firewalld
### Only # MGS
echo "Formating file system and mounting "
## OSS1
mountpoint=`hostname`

mdadm -C /dev/md0 --level=raid0 --raid-devices=10 /dev/disk/azure/scsi1/lun[0-9]
mkfs.lustre --fsname lustre --ost --mgsnode=$mgt_vm_name@tcp --index=$index_value /dev/md0
mkdir -p /opt/$mountpoint
mount.lustre /dev/md0 /opt/$mountpoint

if [ $? -eq 0 ]
then
	echo "File system mounted successful."
else
	echo "ERROR: failed to mount lustre file system."
	exit 1
fi
#lctl set_param obdfilter.*.readcache_max_filesize=2M
lctl set_param osd-ldiskfs.*.readcache_max_filesize=2M
echo "*** Phase 2 - Luster OSS Install Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
