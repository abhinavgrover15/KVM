#!/usr/bin/perl

use DBI;

my $DSN = 'driver={SQL Server};Server=192.168.199.228; database=provisioning_demo;TrustedConnection=Yes'; 
my $dbh = DBI->connect("dbi:ODBC:$DSN") or die "$DBI::errstr\n";

my $sth = $dbh->prepare('select top 10 * from rack')
    or die "Couldn't prepare statement: " . $dbh->errstr;

$sth->execute();

while( @data = $sth->fetchrow_array())
{
    foreach(@data) {
        print "[$_]";
    }
    print "\n\n";
}

$sth->finish;
$dbh->disconnect;
