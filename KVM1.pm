#!/usr/bin/perl
# Utility drawer for Appliance.
# $Id: KVM.pm.in,v 1.6 2011/07/07 20:29:55 
#
# $Log: KVM,v $
# Revision 1.0  2011/07/07 20:29:55  Abhinav
#package KVM;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(&write_log $PATH_TO_APPLIANCE_LOG &fail &success &initialize &search &addKVMACHINE &delKVMACHINE &delVIRTUALMACHINE &addVIRTUALMACHINE &assignIP);
#
$debug=0; # set to zero to turn off debugging

$PATH_TO_APPLIANCE_LOG="/var/log/kvmrpc.log";

sub fail { 0 }
sub success { 1 }
#use strict;
use DBI;
use File::Remote;
use Symbol;
$ENV{'PATH'}="/bin:/usr/bin:/sbin:/usr/sbin:/bin:/usr/local/bin";

## FUNCTIONS start here .
####################################################################
# write_log($msg): appends a time/date stamp and $msg to the log file.
####################################################################
sub write_log {
  my $msg=$_[0];

  $msg=date_string() . $msg;

  if(open(LOGFILE, ">> $PATH_TO_APPLIANCE_LOG")) {
    print LOGFILE $msg . "\n";
    close LOGFILE;
  } 
	else {
		print("Couldn't open $PATH_TO_APPLIANCE_LOG!!!");
	}

	if ($debug)
	{
	print $msg."\n";}
	
} 

####################################################################
# date_string: returns a timestamp suitable for log files.
####################################################################
sub date_string {

    # This should be fast -- no shell commands in here.
    # This routine benchmarked at approx .18 ms,
    # so we can run this more than 1000 times/second
    # QF March 31 1998 (code ripped from bunyan --gb)

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
        localtime(time);

    $mon++;  # Map 0-11 => 1-12

    return sprintf "%s:%s:%s:%s:%s:%s # ",
      $year+1900,
      $mon  < 10 ? "0$mon"  : $mon,
      $mday < 10 ? "0$mday" : $mday,
      $hour < 10 ? "0$hour" : $hour,
      $min  < 10 ? "0$min"  : $min,
      $sec  < 10 ? "0$sec" :  $sec;
}



####################################################################
# Change: alters a line in a file
# Change($file, $find, $replacewith)
####################################################################
sub Change {
	my $file=$_[0];
	my $find=$_[1];
	my $replace=$_[2];
	my $foundit=0;
	my @infile;

	write_log("Changing [$find] to [$replace] in $file...");

	if(-f $file) {
		unless(-w $file) {
			write_log("  $file isn't writeable! Can't change [$find] to [$replace]!");
			return fail;
		}
	}
	else {
		write_log("  Can't \"Change\" a file that doesnt exist! [$file]");
		return fail;
	}

	unless(open(INFILE, "$file")) {
		write_log("  Unable to open $file for reading");
		return fail;
	}
	@infile=<INFILE>;
	close INFILE;

	unless(open(OUTFILE, "> $file")) {
		write_log("  Unable to truncate $file for writing");
		return fail;
	}

	foreach(@infile) {
		$foundit++ if /$find/;
		s/$find/$replace/;
		print OUTFILE;
	}

	close OUTFILE;

	if($foundit == 0) {
		write_log("WARNING: Never found [$find] in $file");
	}

	return success;
}

####################################################################
# search: search a line in file 
# search($find, $file)
####################################################################
sub search {
        my $find=$_[0];
        my $file=$_[1];
        my @infile;

        write_log("Searching [$find]  in $file...");

        if(-f $file) {
        }
        else {
                write_log("  Can't \"Change\" a file that doesnt exist! [$file]");
                return fail;
        }

        unless(open(INFILE, "$file")) {
                write_log("  Unable to open $file for reading");
                return fail;
        }
        @infile=<INFILE>;
        close INFILE;

        foreach(@infile) {
                return $_ if /$find/;
        }

        return fail;
}


####################################################################
# Append: adds a line to a file
# Append($file, $line);
####################################################################
sub Append {
	my $file=$_[0];
	my $line=$_[1] or return fail;

	write_log("Appending [$line] to [$file]");

	if(-f $file) {
		unless(-w $file) {
			write_log("  $file isn't writeable! Can't append [$line]!");
			return fail;
		}
	}

	if(open(OUT, ">> $file")) {
		print OUT "$line\n";
		close OUT;
	}
	else {
		write_log("Couldn't open $file for appending!");
		return fail;
	}

	return success;
}

####################################################################
# inititalize: Initialize a blank file
# initialize($file);
####################################################################
sub initialize {
	my $file=$_[0] or return fail;

	write_log("Initializing [$file]");

	if(-f $file) {
		unless(-w $file) {
			write_log("  $file isn't writeable! Can't append [$line]!");
			return fail;
		}
	}

	if(open(OUT, "> $file")) {
		print OUT "";
		close OUT;
	}
	else {
		write_log("Couldn't open $file for Initializing!");
		return fail;
	}

	return success;
}


####################################################################
# replace:  Replace a file with other
# replace($file, $line);
####################################################################
sub replace {
	my $file=$_[0];
	my $file2=$_[1] or return fail;

	write_log("Moving [$file] if it exists to $file2");
			system("rm -rf 	$file2");
			system("mv $file $file2");
			return success;

}


####################################################################
# remove:  Remove a file 
# remove($file);
####################################################################
sub remove {
        my $file=$_[0] or return fail;

        write_log("REMoving [$file] if it exists ");
                        system("rm -rf  $file");
                        return success;

}



###################################################################
# ModifyFile: It modifies a file for deleting a stanza which is 
# between Marks
# 
# Usage : ModifyFile --delete /path/file startmark.endmark
##################################################################
sub ModifyFile
{
  my $file = shift ;
  my $opening = shift ;
  my $closing = shift ;
chomp($opening);
chomp($closing);

write_log ("Parameters :: $file , $opening ,$closing");
open FILE, "$file" or print "FATAL:: Failed to  open  $file";
my $copy=1;
write_log ("Reading the file $file ");
while (<FILE>)
{
chomp $_;
	if (/$opening/ && $copy eq 1)
	{
	$copy=0;
	write_log("Found Starting of the Share Block ");
		}

	if ($copy eq 1)
	{
	$newfiletext.=$_ ."\n";
	}
	if ($_ eq $closing && $copy eq 0)
	{
	write_log("Found Closing of the Share Block ");
	$copy=1;
	}

}
close FILE;
open FILE, ">$file" or print "FATAL::can't write  on $file";
print FILE $newfiletext; 
close FILE;
}

###########################################################################
## Append- Appedsa line in the file.
############################################################################
sub Append {
        my $file=$_[0];
        my $line=$_[1] or return fail;
        write_log("Appending [$line] to [$file]");
        if(-f $file) {
        unless(-w $file) {
        write_log("  $file isn't writeable! Can't append [$line]!");
        return fail;
                                   }
                    }
       if(open(OUT, ">> $file")) {
       print OUT "$line\n";
       close OUT;
                                                                                                                                                                        }
                                                                                                                                                                                else {
       write_log("Couldn't open $file for appending!");
       return fail;
     }
      return success;
                                                                                                                                                                                                                                }
###########################################################################
## Remote Append- Appends line in the Remote file.
############################################################################

sub RAppend {
	my $file=$_[0];
        my $line=$_[1] or return fail;
        my $remote = new File::Remote;

        write_log("Appending [$line] to [$file]");

        if(-f $file) {
                unless(-w $file) {
                        write_log("  $file isn't writeable! Can't append [$line]!");
                        return fail;
                }
        }

$remote->open(FILE, ">>192.168.41.10:/etc/network/interfaces") or die $!;        

if($remote->open(FILE, ">>192.168.41.10:$file")) {
                print FILE "$line\n";
                $remote->close(FILE);
        }
        else {
                write_log("Couldn't open $file for appending!");
                return fail;
        }

        return success;
}

##################################################################################################
## Assing IP Address
##################################################################################################

sub assignIP
{
$mac_name=shift;
$publicip=shift;
#$lanip=shift;
$osname=shift;
$ipblock=shift;
my $block8="255.255.255.248";
my $block16="255.255.255.240";
########################################################################################################################
my @array1 = split(/\./,$publicip);   # Perl Code to split strings of an ip address by delimiter "."
splice @array1, 3, 4;                      # perl Code to get the first three strings out of the splitted array
my $gateway = join(".",@array1);                     # Perl Code to join the first three spliced strings of array

if ( $osname eq "centos" ) {
my $file="/etc/sysconfig/network-scripts/ifcfg-eth1";
	$line1="DEVICE=eth1";
        $line2="ONBOOT=yes";
	$line3="HOTPLUG=no";
	$line4="IPADDR=$publicip";
if ( $ipblock == 8 ) {
	$line5="NETMASK=$block8"; }
else { $line5="NETMASK=$block16"; }
	$line6="GATEWAY=$gateway.1";
#if ($response=RAppend($lanip,$file,$line1) && RAppend($lanip,$file,$line2) && RAppend($lanip,$file,$line3) && RAppend($lanip,$file,$line4) && RAppend($lanip,$file,$line5) && RAppend($lanip,$file,$line6)) {
if ($response=RAppend($file,$line1) && RAppend($file,$line2) && RAppend($file,$line3) && RAppend($file,$line4) && RAppend($file,$line5) && RAppend($file,$line6)) {
write_log(" IP Assignment Successful ");
}
else
{
write_log(" IP Assignmnet Failed");
}
}
elsif ( $osname eq "debian" ) {
my $file="/etc/network/interfaces";
	$line1="iface eth1 inet static";
	$line2="address $publicip";
        $line3="gateway $gateway.1";
if ( $ipblock == 8 ) { $line4="netmask $block8"; } else { $line4="netmask $block16"; }
        $line5="dns-namservers 4.2.2.2";
#if ($response=RAppend($lanip,$file,$line1) && RAppend($lanip,$file,$line2) && RAppend($lanip,$file,$line3) && RAppend($lanip,$file,$line4) && RAppend($lanip,$file,$line5)) 
if ($response=RAppend($file,$line1) && RAppend($file,$line2) && RAppend($file,$line3) && RAppend($file,$line4) && RAppend($file,$line5)) 
{ 
write_log(" IP Assignment Successful "); 
}
else 
{ 
write_log(" IP Assignmnet Failed"); 
}
}
else { write_log("Something Wrong"); }
}



####################################################################################
# Delete KVM Machine
#
###################################################################################

#sub delKVMACHINE
#{
#$mac_name=shift;

##if (-f "/etc/libvirt/qemu/$mac_name.xml")
#{
#    write_log("Machine name $mac_name isn't exist:: ");
#print fail;

#}
#else
#{
#system("rm -rf /var/lib/libvirt/$mac_name.qcow2");
#system("rm -rf /var/log/libvirt/qemu/$mac_name.log");
#system("rm -rf /var/lib/libvirt/qemu/$mac_name.monitor");
#system("rm -rf /var/lib/libvirt/images/$mac_name.img");
#system("rm -rf /etc/libvirt/qemu/$mac_name.xml");
#if ($? == 0)
#        {
#        write_log("Machine $mac_name is deleted successfully");
#        print success;
#        }
#else
#        {
#        write_log("Error::");
#        print fail;
#        }
#}


####################################################################################
## CREATE SNAPSHOT OF VIRTUAL MACHINE
##
####################################################################################

sub vmSNAPSHOT
{

my $client_name=shift;
my $server_id=shift;

	system("virsh snapshot-create $client_name-$server_id");

} # END vmSNAPSHOT 

sub vmREVERTSS
{
my $client_name=shift;
my $server_id=shift;
my $snapshotid=shift;

	system("virsh destroy $client_name-$server_id");
	print "virsh snapshot-revert $client_name-$server_id $snapshotid";
	system("virsh snapshot-revert $client_name-$server_id $snapshotid");
	system("virsh destroy $client_name-$server_id");
	system("virsh start $client_name-$server_id");
}

sub vmCLONE
{

my $client_name=shift;
my $server_id=shift;
my $clone_vmname=shift;

	system("virsh destroy $client_name-$server_id");
	system("virt-clone --original $client_name-$server_id --name $client_name-$clone_vmname -f /var/lib/libvirt/images/$client_name-$clone_vmname.qcow2");
	system("virsh start $client_name-$server_id");

}

sub createcustomIMAGE
{

my $cust_id=shift;
my $server_id=shift;
my $custom_img_id=shift;
my $custom_img_location=shift;

	if (-e "/etc/libvirt/qemu/$cust_id-$server_id.xml")
	{
	 system("virsh list --all | grep -i $cust_id-$server_id | grep running > /dev/null");
         if ($? == 0)
          { system("virsh destroy $cust_id-$server_id > /dev/null"); }
         system("mkdir -p /mnth$custom_img_location");
	 system("cp -rp /var/lib/libvirt/images/$cust_id-$server_id.qcow2 /mnth$custom_img_location/$custom_img_id.qcow2");
	 system("virsh start $cust_id-$server_id > /dev/null");
         return success;
	}
	else
	{
	 write_log("MACHINE NOT EXIST : $cust_id-$server_id FOR CUSTOMER : $cust_id\n");	
	 return fail;
	}	
	
}

sub createBACKUP
{

my $cust_id=shift;
my $server_id=shift;
my $bkp_img_id=shift;
my $bkp_img_location=shift;

        if (-e "/etc/libvirt/qemu/$cust_id-$server_id.xml")
        {
         system("virsh list --all | grep -i $cust_id-$server_id | grep running > /dev/null");
         if ($? == 0)
          { system("virsh destroy $cust_id-$server_id > /dev/null"); }
         system("mkdir -p /mnth$bkp_img_location");
         system("cp -rp /var/lib/libvirt/images/$cust_id-$server_id.qcow2 /mnth$bkp_img_location/$bkp_img_id.qcow2");
         system("virsh start $cust_id-$server_id > /dev/null");
         return success;
        }
        else
        {
         write_log("MACHINE NOT EXIST : $cust_id-$server_id FOR CUSTOMER : $cust_id\n");
         return fail;
        }

}

sub delBACKUP
{

my $cust_id=shift;
my $server_id=shift;
my $bkp_img_id=shift;
my $bkp_img_location=shift;

        if (-e "/etc/libvirt/qemu/$cust_id-$server_id.xml")
        {
         #print "/mnth$bkp_img_location/$bkp_img_id.qcow2\n";
         system("rm  -rf /mnth$bkp_img_location/$bkp_img_id.qcow2");
         return success;
        }
        else
        {
         write_log("MACHINE NOT EXIST : $cust_id-$server_id FOR CUSTOMER : $cust_id\n");
         return fail;
        }

}


sub delcustomIMAGE
{

my $cust_id=shift;
my $server_id=shift;
my $custom_img_id=shift;
my $custom_img_location=shift;

        if (-e "/etc/libvirt/qemu/$cust_id-$server_id.xml")
        {
	 #print "/mnth$custom_img_location/$custom_img_id.qcow2\n";
         system("rm  -rf /mnth$custom_img_location/$custom_img_id.qcow2");
         return success;
        }
        else
        {
         write_log("MACHINE NOT EXIST : $cust_id-$server_id FOR CUSTOMER : $cust_id\n");
         return fail;
        }

}

##################################################################################
######### CONFIGURE HOSTNAME ON WINDOWS VM #######################################

sub vmSETCONFIG4WINDOWS
{
my $cust_id=shift;
my $mac_name=shift;
my $hostname=shift;
my $ipaddr=shift;
my $passd=shift;

system("virsh destroy $mac_name");
system("mkdir /mnt/$cust_id-$mac_name");
system("guestmount -a /var/lib/libvirt/images/$mac_name.qcow2 -i --rw /mnt/$cust_id-$mac_name");
#system("touch /home/set-config.bat");

system("echo net user Administrator $passd > /home/set-config.bat");
system("echo REG ADD HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName /v ComputerName /t REG_SZ /d $hostname /f  >> /home/set-config.bat");
system("echo REG ADD HKLM\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\ /v ComputerName /t REG_SZ /d $hostname /f >> /home/set-config.bat");
system("echo REG ADD HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ /v Hostname /t REG_SZ /d $hostname /f  >> /home/set-config.bat");
system("echo REG ADD HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ /v \"NV Hostname\" /t REG_SZ /d $hostname /f >> /home/set-config.bat");
system("echo netsh interface ip set address name=\"Local Area Connection\" static $ipaddr 255.255.255.0 192.168.2.1 >> /home/set-config.bat");
system("echo netsh interface ip add dns name=\"Local Area Connection\" addr=4.2.2.2  >> /home/set-config.bat");
system("echo netsh interface ip add dns name=\"Local Area Connection\" addr=8.8.8.8 index=2  >> /home/set-config.bat");
system("echo netsh firewall set opmode disable  >> /home/set-config.bat");
system("echo netsh advfirewall set privateprofile state off >>  /home/set-config.bat");
system("echo netsh advfirewall set publicprofile state off  >>  /home/set-config.bat");
system("echo netsh advfirewall set  allprofiles state off  >> /home/set-config.bat");
system("echo reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server /v fDenyTSConnections /t REG_DWORD /d 0 /f >> /home/set-config.bat");

system("cp -pf /home/set-config.bat /mnt/$cust_id-$mac_name/Windows/System32/GroupPolicy/Machine/Scripts/Startup/set-config.bat");
system("umount /mnt/$cust_id-$mac_name");
system("rm -rf /mnt/$cust_id-$mac_name");
#system("rm -rf /home/set-config.bat");
#system("cp -pf /home/set-config.bat /mnt/$cust_id-$mac_name/Windows/System32/GroupPolicy/Machine/Scripts/Startup/set-config.bat");
system("virsh start $mac_name");
system("sleep 10");
success;
}
####################################################################################
## REBOOT VIRTUAL MACHINE
##
####################################################################################

sub rebootVM
{
my $cust_id=shift;
my $server_id=shift;

	if (-e "/etc/libvirt/qemu/$cust_id-$server_id.xml")
	{

  	 system("virsh list --all | grep -i $cust_id-$server_id | grep running");
 	 if ($? == 0)
	 {
	  system("virsh reboot  $cust_id-$server_id");
	  system("sleep 3");
	  return sucess;
	 }
         else
         {
	  write_log("MACHINE : $cust_id-$server_id IS POWERED OFF FOR CUSTOMER : $cust_id\n");
	  return fail;
         }
        }
       else
	{
	 write_log("MACHINE NOT EXIST : $cust_id-$server_id FOR CUSTOMER : $cust_id\n");
	 return fail;
	}

}

####################################################################################
## UPDATE VIRTUAL MACHINE
##
###################################################################################
sub updateVM
{
my $cust_id=shift;
my $server_id=shift;
my $ram=shift;
my $vcpu=shift;
my $storage_old=shift;
my $storage_new=shift;
my $os_type=shift;
       
	write_log("RESIZE SCRIPT CALLED : $cust_id-$server_id server $ram RAM $vcpu CPU old storage $storage_old new $storage_new os_type $os_type \n"); 
	if (-e "/etc/libvirt/qemu/$cust_id-$server_id.xml")
	 {
          system("virsh list --all | grep -i $cust_id-$server_id | grep running > /dev/null");

	    if ($? == 0)
	    { system("virsh destroy $cust_id-$server_id > /dev/null"); }
	  if ($storage_new > $storage_old)
          {
		write_log("Storage is greater than\n");
	   if ($os_type eq "linux")
	   {
	    system("cp -rp /var/lib/libvirt/images/$cust_id-$server_id.qcow2 /iso/backupimages/$cust_id-$server_id.qcow2");
	    write_log("cp -rp /var/lib/libvirt/images/$cust_id-$server_id.qcow2 /iso/backupimages/$cust_id-$server_id.qcow2 $?");
	    write_log ("MACHINE IMAGE $cust_id-$server_id.qcow2 BACKUP DONE\n");

	    system("qemu-img create -f qcow2 -o preallocation=metadata  /iso/tempimages/$cust_id-$server_id.qcow2 $storage_new > /dev/null");
            write_log ("qemu-img create -f qcow2 -o preallocation=metadata  /iso/tempimages/$cust_id-$server_id.qcow2 $storage_new $?");
    
	    system("virt-resize --expand /dev/sda1 /var/lib/libvirt/images/$cust_id-$server_id.qcow2 /iso/tempimages/$cust_id-$server_id.qcow2 >/dev/null");
            write_log("virt-resize --expand /dev/sda1 /var/lib/libvirt/images/$cust_id-$server_id.qcow2 /iso/tempimages/$cust_id-$server_id.qcow2 $?");
            system("rm -rf /var/lib/libvirt/images/$cust_id-$server_id.qcow2");
	    system("mv /iso/tempimages/$cust_id-$server_id.qcow2 /var/lib/libvirt/images/$cust_id-$server_id.qcow2");
            write_log("mv /iso/tempimages/$cust_id-$server_id.qcow2 /var/lib/libvirt/images/$cust_id-$server_id.qcow2 $?");

	    write_log("$cust_id-$server_id.qcow2 DISK INCREATED FOR LINUX\n");
	    success;
	   }
	   else
           {
	    system("cp -rp /var/lib/libvirt/images/$cust_id-$server_id.qcow2 /iso/backupimages/$cust_id-$server_id.qcow2");
            write_log ("MACHINE IMAGE $cust_id-$server_id.qcow2 BACKUP DONE\n");
            system("qemu-img create -f qcow2 -o preallocation=metadata  /iso/tempimages/$cust_id-$server_id.qcow2 $storage_new > /dev/null");
	    system("virt-resize --expand /dev/sda2 /var/lib/libvirt/images/$cust_id-$server_id.qcow2 /iso/tempimages/$cust_id-$server_id.qcow2 >>/tmp/resizelog");
	    system("mv /iso/tempimages/$cust_id-$server_id.qcow2 /var/lib/libvirt/images/$cust_id-$server_id.qcow2");
	    write_log("$cust_id-$server_id.qcow2 DISK INCREATED FOR WINDOWS\n");
	    success;
   	   }
          }
	 else
         {
		write_log("Storage is not upgraded\n");
	 }
	 
################################################################# RESIZE RAM ###############################################################
############################################################################################################################################
        $VMRAM = $ram * 1024 * 1024;
        $NOLRECORD=qx(grep -Frn '<memory unit=' /etc/libvirt/qemu/$cust_id-$server_id.xml | cut -d ':' -f1);
        $NOLRECORD=$NOLRECORD-1;
        qx(head -$NOLRECORD /etc/libvirt/qemu/$cust_id-$server_id.xml > /tmp/$cust_id-$server_id.xml);
        qx(echo "  <memory unit='KiB'>$VMRAM</memory>" >> /tmp/$cust_id-$server_id.xml);
        qx(echo "  <currentMemory unit='KiB'>$VMRAM</currentMemory>" >> /tmp/$cust_id-$server_id.xml);
        $TOTALRECORD=qx(cat /etc/libvirt/qemu/$cust_id-$server_id.xml | wc -l);
        $NOLRECORD=$NOLRECORD+2;
        $TAILRECORD=$TOTALRECORD-$NOLRECORD;
        qx(tail -$TAILRECORD /etc/libvirt/qemu/$cust_id-$server_id.xml >> /tmp/$cust_id-$server_id.xml);
        qx(cp /tmp/$cust_id-$server_id.xml /etc/libvirt/qemu/$cust_id-$server_id.xml);

################################################################# RESIZE CPU ###############################################################
############################################################################################################################################
        $VMCPU = $vcpu;
        $NOLRECORD=qx(grep -Frn '<vcpu placement=' /etc/libvirt/qemu/$cust_id-$server_id.xml | cut -d ':' -f1);
        $NOLRECORD=$NOLRECORD-1;
        qx(head -$NOLRECORD /etc/libvirt/qemu/$cust_id-$server_id.xml > /tmp/$cust_id-$server_id.xml);
        qx(echo "  <vcpu placement='static'>$VMCPU</vcpu>" >> /tmp/$cust_id-$server_id.xml);
        $TOTALRECORD=qx(cat /etc/libvirt/qemu/$cust_id-$server_id.xml | wc -l);
        $NOLRECORD=$NOLRECORD+1;
        $TAILRECORD=$TOTALRECORD-$NOLRECORD;
        qx(tail -$TAILRECORD /etc/libvirt/qemu/$cust_id-$server_id.xml >> /tmp/$cust_id-$server_id.xml);
        qx(cp /tmp/$cust_id-$server_id.xml /etc/libvirt/qemu/$cust_id-$server_id.xml);
	qx (rm -rf /tmp/$cust_id-$server_id.xml);
        system("virsh define /etc/libvirt/qemu/$cust_id-$server_id.xml > /dev/null");
        system("virsh start $cust_id-$server_id > /dev/null");
        return success;
          }
	 else
	{
	  write_log("MACHINE NOT EXIST : $cust_id-$server_id FOR CUSTOMER : $cust_id\n");
	  return fail;
	}   	 
	
}

####################################################################################
## Delete Virtual Machine
##
####################################################################################

sub delVIRTUALMACHINE
{
 my $cust_id=shift;
 my $server_id=shift;
 if (-e "/etc/libvirt/qemu/$cust_id-$server_id.xml") 
  {
	   system("virsh list --all | grep -i $cust_id-$server_id | grep running >/dev/null");
	   if ($? == 0)
           {
                system("virsh destroy $cust_id-$server_id >/dev/null");
		write_log("MACHINE : $cust_id-$server_id SHUTDOWN FOR CLIENT : $cust_id\n");    
           }
           system("virsh undefine $cust_id-$server_id >/dev/null");
	   write_log("MACHINE : $cust_id-$server_id UNDEFINE FOR CLIENT : $cust_id\n");
           system("rm -rf /var/lib/libvirt/images/$cust_id-$server_id.qcow2 >/dev/null");
	   write_log("IMAGE $cust_id-$server_id.qcow2 HAS BEEN DELETED\n");
 	   return success;
  }
  else
  {
           write_log("$cust_id-$server_id : MACHINE DOES NOT EXIST FOR CUSTOMER : $cust_id\n");
	   return fail;
  } 
	

}                                                                                       #End of Sub delVIRTUALMACHINE





####################################################################################
## ADD Virtual Machine
##
#####################################################################################

sub  addVIRTUALMACHINE
{
my $cust_id=shift;
my $ostype=shift;
my $version=shift;
my $arch=shift;
my $mac_name=shift;
my $ram=shift;
my $vcpus=shift;
my $disk_size=shift;
my $disk_path="/var/lib/libvirt/images/$mac_name-$cust_id.qcow2";
my $iso_path="/home/iso/dummy.iso";
my $password=shift;
my $publicip=shift;
my $ipblock=shift;
###################### Check for customer prvivate network ##############################
if (-e "/usr/share/libvirt/networks/$cust_id.xml") {
write_log("Client Network Exists, Assigning private IP to it");
$lanip=qx{/usr/local/sbin/assignip $cust_id $mac_name | head -1 };
chomp($lanip);
$macaddress=qx{/usr/local/sbin/assignip $cust_id $mac_name | tail -1 };
chomp($macaddress);
}
else {
system("/usr/local/sbin/addvnetwork $cust_id $mac_name");
$macaddress=qx{cat /home/ipdetails/$cust_id | cut -d- -f2 };
chomp($macaddress);
print "$macaddress\n";
write_log("Network Created Successfully");
}
###########################################################################################
######## Check whether same hostname machine is not created previously#######################
if (-e "/etc/libvirt/qemu/$mac_name-$cust_id.xml")
{
    write_log("Machine name $mac_name-$cust_id  exist:: ");
return fail;
}
else   
###################  Create Virtual Machine #######################################################
{
system("qemu-img create -f qcow2  -o preallocation=metadata /var/lib/libvirt/images/$mac_name-$cust_id.qcow2 20G");
system("virt-install --connect qemu:///system --name $mac_name-$cust_id --ram $ram --vcpus $vcpus -f /var/lib/libvirt/images/$mac_name-$cust_id.qcow2 --vnc --cdrom $iso_path --network network:$cust_id,mac=$macaddress");
system("virsh destroy $mac_name-$cust_id");
system("cp /home/images/$ostype-$version-$arch.qcow2 /var/lib/libvirt/images/$mac_name-$cust_id.qcow2");
system("sleep 10");
############ Check for HDD Size to be increased ###########################################
if ( $disk_size != 20 ) {
system("cp -rp /var/lib/libvirt/images/$mac_name-$cust_id.qcow2 /home/backupimages/$mac_name-$cust_id.qcow2");
system("qemu-img create -f qcow2 -o preallocation=metadata  /home/tempimages/$mac_name-$cust_id.qcow2 $disk_size");
system("virt-resize --expand /dev/sda1 /var/lib/libvirt/images/$mac_name-$cust_id.qcow2 /home/tempimages/$mac_name-$cust_id.qcow2 >/dev/null");
system("mv /home/tempimages/$mac_name-$cust_id.qcow2 /var/lib/libvirt/images/$mac_name-$cust_id.qcow2");
write_log("Disk Resized, Moving Ahead");
}
################# Setting Hostname and Public IP #######################
########Attach Interface###############################
system("virsh attach-interface $mac_name-$cust_id --type bridge --source br1 --persistent");
assignIP($mac_name-$cust_id,$publicip,$lanip,$ostype,$ipblock);
write_log("IP $publicip assigned");
############################################################################################
system("virsh start $mac_name-$cust_id");
write_log("Server $mac_name-$cust_id started successfully");
return success;
}
}
1;
