#version=RHEL9
ignoredisk --only-use=sda
# Partition clearing information
clearpart --none --initlabel
# Use CDROM installation media
cdrom
text
keyboard --xlayouts='in(eng)'
timezone Asia/Kolkata --utc
# System language
lang en_IN
lang en_US.UTF-8

# Network information
#network  --bootproto=dhcp
network  --bootproto=dhcp --ipv6=auto --activate
network  --hostname=RHEL9Template
repo --name="AppStream" --baseurl=file:///run/install/repo/AppStream
# Root password
rootpw $6$3jxRqOkH8n2q4W88$AwsjYcFRIAlh5Wb09NQ./5RpoTRO9vZ7DsufuPFGrp280pcGCLUMaH.QrSR7n6rhr0oE6J89vK4nJH9QANh5p/ --iscrypted
user --name=darkrose --groups=wheel --password=$6$3jxRqOkH8n2q4W88$AwsjYcFRIAlh5Wb09NQ./5RpoTRO9vZ7DsufuPFGrp280pcGCLUMaH.QrSR7n6rhr0oE6J89vK4nJH9QANh5p/ --iscrypted
auth --passalgo=sha512 --useshadow
%post
echo 'darkrose ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
%end
# Run the Setup Agent on first boot
firstboot --disable
selinux --permissive
# Do not configure the X Window System
skipx

bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"

# System services
services --disabled="kdump" --enabled="sshd,rsyslog,chronyd"

rhsm --organization="11883197" --activation-key="Proxmox"
syspurpose --role="RHEL Server" --sla="Self-Support" --usage="Development/Test"

# Disk partitioning information
part / --fstype="xfs" --grow --size=6144
part swap --fstype="swap" --size=512
reboot


%packages
@^minimal-environment
@network-tools
openssh-server
openssh-clients
sudo
kexec-tools
curl
# allow for ansible
python3
python3-libselinux

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%post
mkdir -p /home/darkrose/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0Mrz/2CXLoD3i5oHsLCEdVQrfGzKUDAgJumLLUKmnx darkrose@yaseenins" > /home/darkrose/.ssh/authorized_keys
chmod 700 /home/darkrose/.ssh
chmod 600 /home/darkrose/.ssh/authorized_keys
chown -R darkrose:darkrose /home/dark/.ssh

mkdir -p /root/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0Mrz/2CXLoD3i5oHsLCEdVQrfGzKUDAgJumLLUKmnx darkrose@yaseenins" > /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
chown -R root:root /root/.ssh

# set virtual-guest as default profile for tuned
echo "virtual-guest" > /etc/tuned/active_profile

# Because memory is scarce resource in most cloud/virt environments,
# and because this impedes forensics, we are differing from the Fedora
# default of having /tmp on tmpfs.
echo "Disabling tmpfs for /tmp."
systemctl mask tmp.mount

cat <<EOL > /etc/sysconfig/kernel
# UPDATEDEFAULT specifies if new-kernel-pkg should make
# new kernels the default
UPDATEDEFAULT=yes

# DEFAULTKERNEL specifies the default kernel package type
DEFAULTKERNEL=kernel
EOL

# make sure firstboot doesn't start
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot

echo "Fixing SELinux contexts."
touch /var/log/cron
touch /var/log/boot.log
mkdir -p /var/cache/yum
/usr/sbin/fixfiles -R -a restore

# reorder console entries
sed -i 's/console=tty0/console=tty0 console=ttyS0,115200n8/' /boot/grub2/grub.cfg

#echo "Zeroing out empty space."
# This forces the filesystem to reclaim space from deleted files
# dd bs=1M if=/dev/zero of=/var/tmp/zeros || :
# rm -f /var/tmp/zeros
# echo "(Don't worry -- that out-of-space error was expected.)"

yum update -y

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

yum clean all
%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
