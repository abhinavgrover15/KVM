#!/usr/bin/perl -w

use strict;
use warnings;
use DBI;

my $data_source = q/dbi:ODBC:provisioning_demo/;
my $user = q/xchangeprojectuser/;
my $password = q/mnzx0912#/;



my $host = '192.168.199.228';
my $database = 'provisioning_demo';
my $user = 'xchangeprojectuser';
my $auth = 'mnzx0912#';

$dsn  = "Provider=sqloledb;Trusted Connection=yes;";
$dsn .= "Server=$host;Database=$database";
DBI->connect("dbi:ODBC:Driver={SQL Server};Server=192.168.199.228;UID=$user;PWD=$password")
my $dbh = DBI->connect("dbi:ADO:$dsn",$user,$auth,{ RaiseError => 1, AutoCommit => 1}) || die "Database connection not made: $DBI::errstr";

