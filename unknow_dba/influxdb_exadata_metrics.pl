#!/usr/bin/env perl
#
# Author: Bertrand Drouvot
# influxdb_exadata_metrics.pl : V1.0 (2016/05)
#
# Utility used to extract exadata metrics in InfluxDB line protocol
#
#----------------------------------------------------------------#

BEGIN {
die "ORACLE_HOME not set\n" unless $ENV{ORACLE_HOME};
unless ($ENV{OrAcLePeRl}) {
$ENV{OrAcLePeRl} = "$ENV{ORACLE_HOME}/perl";
$ENV{PERL5LIB} = "$ENV{PERL5LIB}:$ENV{OrAcLePeRl}/lib:$ENV{OrAcLePeRl}/lib/site_perl";
$ENV{LD_LIBRARY_PATH} = "$ENV{LD_LIBRARY_PATH}:$ENV{ORACLE_HOME}/lib32:$ENV{ORACLE_HOME}/lib";
exec "$ENV{OrAcLePeRl}/bin/perl", $0, @ARGV;
}
}

use strict;
use Time::Local;

#
# Variables
#
my $nbmatch=-1;
my $help=0;
my $goodparam=0;

my $dclicomm='';
my $groupcell_pattern='';
my $metrictype_pattern='ALL';
my $result;

# Parameter parsing

foreach my $para (@ARGV) {

if ( $para =~ m/^help.*/i ) {
$nbmatch++;
$help=1;
}

if ( $para =~ m/^groupfile=(.*)$/i ) {
$nbmatch++;
$groupcell_pattern=$1;
$goodparam++;
}
}

# Check if groupfile is empty

if ((!$goodparam) | $goodparam > 1) {
print "\n Error while processing parameters : GROUPFILE parameter is mandatory! \n\n" unless ($help);
$help=1;
}

# Print usage if a difference exists between parameters checked
#
if ($nbmatch != $#ARGV | $help) {
print "\n Error while processing parameters \n\n" unless ($help);
print " \nUsage: $0 [groupfile=] \n\n";

printf (" %-25s %-60s %-10s \n",'Parameter','Comment','Default');
printf (" %-25s %-60s %-10s \n",'---------','-------','-------');
printf (" %-25s %-60s %-10s \n",'GROUPFILE=','file containing list of cells','');
print ("\n");
print ("utility assumes passwordless SSH from this node to the cell nodes\n");
print ("utility assumes ORACLE_HOME has been set \n");
print ("\n");
print ("Example : $0 groupfile=./cell_group\n");
print "\n\n";
exit 0;
}

# dcli command

$dclicomm="dcli -g ".$groupcell_pattern. " cellcli -e \"list metriccurrent attributes name,metricObjectName,metricValue,metricType where metricType !='cumulative'\"";

# Launch the dcli command
my $result=`$dclicomm` ;

if ( $? != 0 ) 
{ 
print "\n";
print "\n";
die "Something went wrong executing [$dclicomm]\n"; 
}

# Split the string into array
my @array_result = split(/\n/, $result);

foreach my $line ( @array_result ) {
# drop tab
$line =~ s/\t+/ /g;
# drop blanks
$line =~ s/\s+/ /g;

#Split each line on 6 pieces based on blanks
my @tab1 = split (/ +/,$line,6);

# Supress : from the cell name
$tab1[0] =~ s/://;

# Supress , from the value
$tab1[3] =~ s/,//g;

# Add "N/A" if no Unit
if ($tab1[5] eq "") {$tab1[5]="N/A"};

# Print
print "exadata_cell_metrics,cell=$tab1[0],metric_name=$tab1[1],metricObjectName=$tab1[2],metric_type=$tab1[5],metric_unit=$tab1[4] metric_value=$tab1[3]\n";
}
