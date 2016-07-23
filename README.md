# KVM
Scripts to Manage Kvm Machines with Command Line

There are various scripts written for creating,deleting,updating,snapshots,restoring snapshots of kvm virtual machines.

For VM console, you can VNC into it with IP address of your host and port number mentioned in vm xml file.

All error,successful and debug logs related to virtual machines go to /var/log/kvmrpc.log.

Change Below parameter in KVM.PM file with your host IP address
my $host_ip_address  = "1.1.1.1";
