### Script 2 In All the Lustre Servers ###
#!/bin/bash
mkdir -p /logs
log_file="/logs/phase2-`date +'%Y-%m-%d_%H-%M-%S'`.log"
[ -f "$log_file" ] || touch "$log_file"
set -x
exec 1>> $log_file 2>&1
#Varibales

sasextpw=`facter sasextpw`  ##To be passed as variable

#ADD Users
cat /etc/group |grep -wiq sas
if [ $? -eq 0 ]; then
   echo "SAS Group exists"
else
   groupadd -g 5001 sas
fi
 
if [ ! -f /home/sasinst ]; then
   useradd -u 1002 -g sas sasinst
   echo ${sasextpw} | passwd sasinst --stdin
else
   echo "User sasinst exists"
fi
 
if [ ! -f /home/sassrv ]; then
   useradd -u 1003 -g sas sassrv
   echo ${sasextpw} | passwd sassrv --stdin
else
   echo "User sassrv exists"
fi
 
if [ ! -f /home/sasdemo ]; then
   useradd -u 1005 -g sas sasdemo
   echo ${sasextpw} | passwd sasdemo --stdin
else
   echo "User sasdemo exists"
fi
 
if [ ! -f /home/lsfadmin ]; then
   useradd -u 1006 -g sas lsfadmin
   echo ${sasextpw} | passwd lsfadmin --stdin
else
   echo "User lsfadmin exists"
fi
echo "**************SAS Admin Users created successfully.***************"

## Basic Pre Reqs for the SAS
yum install ruby wget -y
wget http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/f/facter-2.4.1-1.el7.x86_64.rpm
rpm  --reinstall -vh facter-2.*.rpm

if [ $? -eq 0 ] ;then
   echo "Facter Installation Sucess"
else
   echo "ERROR: Facter module installation failed."
   exit 1
fi

##Facter Variables and Declaration
environmentLocation="/etc/facter/facts.d/variables.txt"
if [ -f $environmentLocation ]; then
	rm -f $environmentLocation
fi

cat << EOF > $environmentLocation
mgt_vm_name=$1
index_value=$2
EOF

## Creating the repo configuration for dowloading all the rpm packages based on the server version
cat >/tmp/lustre-repo.conf <<\__EOF
[lustre-server]
name=lustre-server
baseurl=https://downloads.whamcloud.com/public/lustre/lustre-2.12.4/el7.7.1908/server
gpgcheck=0
[lustre-client]
name=lustre-client
baseurl=https://downloads.whamcloud.com/public/lustre/lustre-2.12.4/el7.7.1908/client
gpgcheck=0
[e2fsprogs-wc]
name=e2fsprogs-wc
baseurl=https://downloads.whamcloud.com/public/e2fsprogs/latest/el7
gpgcheck=0
__EOF
echo "Repo configured"

sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/sysconfig/selinux
## Installing dependency packages
yum install createrepo yum-utils cifs-utils  nfs-utils -y
if [ $? -eq 0 ] 
then
echo "Dependency packages installation successful."
else
echo "ERROR: Dependency packages installation failed."
exit 1
fi

# Downloading all the rpm packegs required for the lustre
mkdir -p  /opt/lustre-temp/
cd /opt/lustre-temp/
reposync -c /tmp/lustre-repo.conf -n -r lustre-server -r lustre-client -r e2fsprogs-wc
if [ $? -eq 0 ] 
then
echo "Dependency packages downloaded successful."
else
echo "ERROR: failed to download dependency packages."
exit 1
fi

echo "Downloading and installing kernel dependency packages"
wget http://rpmfind.net/linux/centos/7/os/x86_64/Packages/resource-agents-4.1.1-46.el7.x86_64.rpm
wget http://rpmfind.net/linux/centos/7/os/x86_64/Packages/psmisc-22.20-16.el7.x86_64.rpm
rpm -ivh *.rpm
if [ $? -eq 0 ] 
then
echo " Kernel dependency installed successfully."
else
echo "ERROR: failed to install kernel dependency packages."
exit 1
fi
## Please check the kernel only rpm package kernel-3.* In My case it is 3.
cd /opt/lustre-temp/lustre-server/RPMS/x86_64/
yum localinstall kernel-3.10.0-1062.9.1.el7_lustre.x86_64.rpm  -y
if [ $? -eq 0 ] 
then
echo "Kernel installation completed successful."
else
echo "ERROR: Kernel installation failed."
exit 1
fi
yum install xorg-x11-xauth.x86_64 xorg-x11-server-utils.x86_64 dbus-x11.x86_64 -y
echo  "options lnet networks=tcp" >> /etc/modprobe.d/lustre.conf
echo "Rebooting the system."
 
echo  "* * * * * sleep 10;/sbin/shutdown -r now" >> /var/spool/cron/root
echo "@reboot crontab -r" >> /var/spool/cron/root

echo "*** Phase 1 - Luster pre-req Install Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
