#!/usr/bin/perl
use strict;
	#use warning;

main (@ARGV);

sub  main
{
my $cust_id=shift;
my $server_id=shift;
my $cust_name=shift;
my $os_type=shift;
my $os_name=shift;
my $os_version=shift;
my $os_arch=shift;
my $os_image_location=shift;
my $host_name=shift;
my $ram=shift;
my $vcpu=shift;
my $storage=shift;
#my $disk_path="/var/lib/libvirt/images/$cust_id-$server_id.qcow2";
#my $iso_path="/var/lib/libvirt/images/$cust_id-$server_id.iso"; # Cloud Init ISO, generated later.
my $admin_password=shift;
my $wan_mac_address=shift;
my $wan_primary_ip=shift;
my $wan_sec_ip_list=shift;
my $vm_host_vnc_port=shift;
my $vnc_password=shift;
my $ram=$ram*1024;
my $dm="G";
my $host_ip_address="162.222.32.102";
###########################################################################################
######## Check whether same hostname machine is not created previously#######################
if (-e "/etc/libvirt/qemu/$cust_id-$server_id.xml")
{
    #write_log("Machine name $cust_id-$server_id  exist:: ");
    #return fail;
}
else
###################  Create Virtual Machine #######################################################
{

################ Calculate Gateway #############################################
my @array1 = split(/\./,$wan_primary_ip);   # Perl Code to split strings of an ip address by delimiter "."
splice @array1, 3, 4;                      # perl Code to get the first three strings out of the splitted array
my $wan_ip_gateway = join(".",@array1);                     # Perl Code to join the first three spliced strings of array


if ($os_type eq "linux")  {
if (($os_name eq "centos") || ($os_name eq "redhat")) {

        }
elsif (($os_name eq "debian") || ($os_name eq "ubuntu") ) {


        if (-e "/mnt/$os_image_location/$os_name-$os_version-$os_arch.qcow2")
        {
         #write_log("COPYING IMAGE FROM /mnt/$os_image_location/$os_name-$os_version-$os_arch.qcow2 TO /var/lib/libvirt/images/$cust_id-$server_id.qcow2");
         system("cp /mnt/$os_image_location/$os_name-$os_version-$os_arch.qcow2 /var/lib/libvirt/images/$cust_id-$server_id.qcow2.org >/dev/null 2>/dev/null");
	 print("copying image"); ## copying image
        }
        else
        {
         #write_log("PATH : $os_image_location \n");
         #write_log("IMAGE IS NOT EXIST AT /mnt/$os_image_location/$os_name-$os_version-$os_arch.qcow2 \n");
         #return fail;
        }



    #Convert the compressed qcow2.org file downloaded to a uncompressed qcow2
        system("qemu-img convert -O qcow2 /var/lib/libvirt/images/$cust_id-$server_id.qcow2.org /var/lib/libvirt/images/$cust_id-$server_id.qcow2 >/dev/null 2>/dev/null");

        ##### resize image


        #system("qemu-img resize /var/lib/libvirt/images/$cust_id-$server_id.qcow2 +$storage$dm >/dev/null 2>/dev/null");
        

        my $userdata="/var/lib/libvirt/images/$cust_id-$server_id-userdata";
        my $metadata="/var/lib/libvirt/images/$cust_id-$server_id-metadata";
        my $password=qx{mkpasswd --method=SHA-512 --rounds=4096 $admin_password};

        ### Creating metadata file
	
        system("touch /var/lib/libvirt/images/$cust_id-$server_id-metadata >/dev/null 2>/dev/null");
   #if(open(FH, "> $metadata"))
   #				{
   #				print FH "instance-id: $cust_id-$server_id\n";
   #				close FH;			
   #				}


        ### Creating userdata file

   if(open(OUT, "> $userdata")) 
		               {

print OUT "#cloud-config\n";
print OUT "hostname: $host_name\n";
print OUT "fqdn: $host_name\n";
print OUT "manage_etc_hosts: true\n";
print OUT "chpasswd:\n";
print OUT "  list: |\n";
print OUT "    root:arcand00\n";
print OUT "  expire: False\n";

   				#print OUT "#cloud-config\n";
				#print OUT "hostname: $host_name\n";
			        #print OUT "fqdn: $host_name\n";
				#print OUT "manage_etc_hosts: true\n";
   				#print OUT "chpasswd:\n";
   				#print OUT "list: |\n";
   				#print OUT "    root:arcand00!!\n";
   				#print OUT "expire: False\n";
				#print OUT "users:\n";
  				#print OUT "    - name: chicloud\n";
				#print OUT "      lock-passwd: false\n";
				#print OUT "      passwd: $password\n";
    				#print OUT "    shell: /bin/bash\n";
    				#print OUT "    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n";
			    	#print OUT "    ssh-authorized-keys:\n";
			        #print OUT '        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFXPCPfLMHZgcJBvJfVTy78gV8pcP+3YMyylmpLx3zC+q7grwDSflnTG4Zz/NqpyZdw6rDXwMFEh5Jw/9ypvpUghATRND6xl3cIxN6leRJd7YIfizjhJWsYBnMsgEkb6wbxTe/bqLRDJAaX2NrLaI04NmlPkU7q6oQTpMP6OldPdES4uk8jr05I6olFy6cuDWlyVU1IhdSVfCTV52yGlTpWX/CfiKjhrYtpynGTF5fdC2wRA9Z5UD7JCVtay2/UjpMKblpboBfS8YzDQUvXFB03u988i33Rzya0ndl9drmCkty/vTo816JJxWDJ46rhNk4CAiSqolzlx9yfCgsKgYX root@vinay-HP-ProBook-440-G2';
				#print OUT "\nwrite_files:\n";
				#print OUT "    - path: /etc/network/interfaces.d/eth0.cfg\n";
				#print OUT "    content: |\n";
      				#print OUT "        auto eth0\n";
      				#print OUT "        iface eth0 inet static\n";
				#print OUT "        address $wan_primary_ip\n";
			      	#print OUT "        netmask 255.255.255.0\n";
				#print OUT "        gateway $wan_ip_gateway.1\n";
				#print OUT "        dns-nameservers 8.8.8.8 4.2.2.2\n";
   				
   close OUT;
   				}
   ################################## Genrating cloud config drive ##################

   system("genisoimage -o /var/lib/libvirt/images/$cust_id-$server_id.iso  -V cidata -r -J $metadata $userdata  >>/tmp/log 2>>/tmp/log ");
    print("\nuserdata file :$userdata\n");
    print("\nmetadata file :$metadata\n");

   #system("virt-install --connect qemu:///system --name $cust_id-$server_id --ram $ram --vcpus $vcpu --disk /var/lib/libvirt/images/$cust_id-$server_id.qcow2,format=qcow2 --graphics vnc,password=$vnc_password,port=$vm_host_vnc_port,listen=$host_ip_address --cdrom /var/lib/libvirt/images/$cust_id-$server_id.iso --network network:phybrid,mac=$wan_mac_address >>/tmp/log 2>>/tmp/log");
   system("virt-install --connect qemu:///system --name $cust_id-$server_id --ram $ram --vcpus $vcpu --disk /var/lib/libvirt/images/$cust_id-$server_id.qcow2,format=qcow2 --graphics vnc,password=$vnc_password,port=$vm_host_vnc_port,listen=$host_ip_address --cdrom /var/lib/libvirt/images/$cust_id-$server_id.iso  --network network:phybrid,mac=$wan_mac_address");



 }
	#closing debian and ubuntu condition

}

### Closing of linux if condition
}
### Closing for creating virtual machine
} 
### Closing  main block
