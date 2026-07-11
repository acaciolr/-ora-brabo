#!/usr/bin/env perl
#
# Author: Bertrand Drouvot
# Visit my blog : http://bdrouvot.wordpress.com/
# exadata_metrics.pl : V1.0 (2012/11)
# exadata_metrics.pl : V1.1 (2012/12) : Removed NAME_LIKE and METRICOBJECTNAME_LIKE
# exadata_metrics.pl : V1.1 (2012/12) : Added != predicates and changed = predicates to accept wildcard
# exadata_metrics.pl : V1.2 (2013/01) : Send Hangup signal to the Python Childs in case of Ctrl+C
# exadata_metrics.pl : V1.3 (2013/03) : Add the groupfile option and the show option (to allow aggregation on cell and objectname)
# exadata_metrics.pl : V1.4 (2013/09) : Add the DELTA(s) field: Delta in seconds between the completionTime attributes of the snaps
# exadata_metrics.pl : V2.0 (2013/11) : Add the display option: Can display metrics per snap (snap) or since the collection began (avg)
# exadata_metrics.pl : V2.1 (2013/12) : Month '12' out of range 0..11 bug correction
# Utility used to display cumulative exadata metrics in real time
# A cell os user allowed to run dcli without password (celladmin for example) can launch the script (ORACLE_HOME must be set).
#
# Chek for new version : http://bdrouvot.wordpress.com/exadata_metrics_script/
#
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
my $interval=1;
my $count=999999;
my $help=0;
my $deltavalue=0;
my $topn=10;
my $goodparam=0;

my $cell_pattern='';
my $dclicomm='';
my $groupcell_pattern='';
my $show_pattern='cell,objectname';
my $name_pattern='ALL';
my $notname_pattern='EMPTY_PATTERN';
my $metricobjectname_pattern='ALL';
my $notmetricobjectname_pattern='EMPTY_PATTERN';
my $result;

my @array_of_ckeys_description=();
my @array_of_display_keys=();
my @array_of_ckey=();
my @delta_fields=();
my $ckey_cpt=0;
my $display_pattern='snap';



#
# check the parameters line
#
if ($ARGV[0] =~ /^\d+/ ) {
$interval=$ARGV[0];
$nbmatch++;
}

if ($ARGV[1] =~ /^\d+/ ) {
$count=$ARGV[1];
$nbmatch++;
}
foreach my $para (@ARGV) {

if ( $para =~ m/^help.*/i ) {
$nbmatch++;
$help=1;
}

if ( $para =~ m/^top=(.*)$/i ) {
$nbmatch++;
$topn=$1;
}
if ( $para =~ m/^name=(.*)$/i ) {
$nbmatch++;
$name_pattern=$1;
}

if ( $para =~ m/^name!=(.*)$/i ) {
$nbmatch++;
$notname_pattern=$1;
}

if ( $para =~ m/^objectname=(.*)$/i ) {
$nbmatch++;
$metricobjectname_pattern=$1;
}

if ( $para =~ m/^objectname!=(.*)$/i ) {
$nbmatch++;
$notmetricobjectname_pattern=$1;
}


if ( $para =~ m/^cell=(.*)$/i ) {
$nbmatch++;
$cell_pattern=$1;
$goodparam++;
}

if ( $para =~ m/^groupfile=(.*)$/i ) {
$nbmatch++;
$groupcell_pattern=$1;
$goodparam++;
}

if ( $para =~ m/^show=(.*)$/i ) {
$nbmatch++;
$show_pattern=$1;
}

if ( $para =~ m/^display=(.*)$/i ) {
$nbmatch++;
$display_pattern=$1;
}

}

# Hash Tables
my %exametric;
my %diffstats;
my %avgdiffstats;
my $cpt=0;
my %cpt_array=0;
my %resultset;

# Check if cell pattern and groupfile are empty

if ((!$goodparam) | $goodparam > 1) {
print "\n Error while processing parameters : CELL or GROUPFILE (mutually exclusive) parameter is mandatory !!! \n\n" unless ($help);
$help=1;
}

# Print usage if a difference exists between parameters checked
#
if ($nbmatch != $#ARGV | $help) {
print "\n Error while processing parameters \n\n" unless ($help);
print " \nUsage: $0 [Interval [Count]] [cell=|groupfile=] [display=] [show=] [top=] [name=] [name!=] [objectname=] [objectname!=] \n\n";

print " Default Interval : 1 second.\n";
print " Default Count : Unlimited\n\n";
printf (" %-25s %-60s %-10s \n",'Parameter','Comment','Default');
printf (" %-25s %-60s %-10s \n",'---------','-------','-------');
printf (" %-25s %-60s %-10s \n",'CELL=','comma-separated list of cells','');
printf (" %-25s %-60s %-10s \n",'GROUPFILE=','file containing list of cells','');
printf (" %-25s %-60s %-10s \n",'SHOW=','What to show (name included): cell,objectname','ALL');
printf (" %-25s %-60s %-10s \n",'DISPLAY=','What to display: snap,avg (comma separated list)','SNAP');
printf (" %-25s %-60s %-10s \n",'TOP=','Number of rows to display ','10');
printf (" %-25s %-60s %-10s \n",'NAME=','ALL - Show all cumulative metrics (wildcard allowed)','ALL');
printf (" %-25s %-60s %-10s \n",'NAME!=','Exclude cumulative metrics (wildcard allowed)','EMPTY');
printf (" %-25s %-60s %-10s \n",'OBJECTNAME=','ALL - Show all objects (wildcard allowed)','ALL');
printf (" %-25s %-60s %-10s \n",'OBJECTNAME!=','Exclude objects (wildcard allowed)','EMPTY');
print ("\n");
print ("utility assumes passwordless SSH from this cell node to the other cell nodes\n");
print ("utility assumes ORACLE_HOME has been set (with celladmin user for example)\n");
print ("\n");
print ("Example : $0 cell=cell\n");
print ("Example : $0 groupfile=./cell_group\n");
print ("Example : $0 groupfile=./cell_group show=name\n");
print ("Example : $0 cell=cell objectname='CD_disk03_cell' name!='.*RQ_W.*'\n");
print ("Example : $0 cell=cell name='.*BY.*' objectname='.*disk.*' name!='GD.*' objectname!='.*disk1.*'\n");
print "\n\n";
exit 0;
}

# Build the dcli command

#debug print "cell patern is $cell_pattern\n";
# Create the name pattern

if ($name_pattern =~ /all/i) {
$name_pattern = ""
}
else
{
$name_pattern = " and name like \\'".$name_pattern."\\' "
}

# Create the "Not" name pattern

if ($notname_pattern =~ /EMPTY_PATTERN/i) {
$notname_pattern = ""
}
else
{
$notname_pattern = " and name not like \\'".$notname_pattern."\\' "
}


# Create the metricobjectname pattern

if ($metricobjectname_pattern =~ /all/i) {
$metricobjectname_pattern = ""
}
else
{
$metricobjectname_pattern =  " and metricObjectName like \\'".$metricobjectname_pattern."\\' "
}

# Create the not metricobjectname pattern

if ($notmetricobjectname_pattern =~ /EMPTY_PATTERN/i) {
$notmetricobjectname_pattern = ""
}
else
{
$notmetricobjectname_pattern =  " and metricObjectName not like \\'".$notmetricobjectname_pattern."\\' "
}

# check if cell list
if ($cell_pattern)
{
$dclicomm="dcli -c ".$cell_pattern. " cellcli -e \"list metriccurrent attributes name,metricObjectName,collectionTime,metricValue where metricType='Cumulative'".$name_pattern."".$notname_pattern."".$notmetricobjectname_pattern."".$metricobjectname_pattern."\"";
}
# Then group file is used
else
{
$dclicomm="dcli -g ".$groupcell_pattern. " cellcli -e \"list metriccurrent attributes name,metricObjectName,collectionTime,metricValue where metricType='Cumulative'".$name_pattern."".$notname_pattern."".$notmetricobjectname_pattern."".$metricobjectname_pattern."\"";
}

# Function to build the "compute" key
sub build_compute_key {
my @tab1 = @_;
for my $i ( 0 .. $#array_of_ckeys_description ) {
my $bckey='';
my @eckey=();
for my $j ( sort { $a <=> $b } (keys %{ $array_of_ckeys_description[$i] }) ) {
  ($bckey)?($bckey = $bckey.".".$array_of_ckeys_description[$i]{$j}):($bckey = $array_of_ckeys_description[$i]{$j});
  push(@eckey,$tab1[$j]);
  }
my $ckey = sprintf($bckey,@eckey);
$array_of_ckey[$i]=$ckey;
}
}

# Function to convert collectionTime (2013-09-12T14:28:21+02:00) to seconds

sub collectionTime_to_seconds {
my $collectionTime = $_[0];
my @extract_from_date;
@extract_from_date = $collectionTime =~ /^(.{4})-(.{2})-(.{2})T(.{2}):(.{2}):(.{2}).*$/;

# Month '12' out of range 0..11 bug correction
@extract_from_date[1] = @extract_from_date[1] - 1;

my $secs += timegm reverse @extract_from_date;

return $secs;
}

# Function to compute the Max

sub bdt_max {
my($max_so_far) = shift @_;  
  foreach (@_) {            
    if ($_ > $max_so_far) {
      $max_so_far = $_;
    }
  }
  return $max_so_far;
}

# What to show
my @show_fields = split (/,/,$show_pattern);

# Show at least the name and the units
$array_of_ckeys_description[$ckey_cpt]{1}='%30s';
$array_of_display_keys[$ckey_cpt]{1}='y';
$array_of_display_keys[$ckey_cpt]{5}='y';

foreach my $show (@show_fields) {

if ($show =~ m/^cell$/i ){
# group by cell
$array_of_ckeys_description[$ckey_cpt]{0}='%30s';
$array_of_display_keys[$ckey_cpt]{0}='y';
if (grep (/^objectname$/i,@show_fields)) {
$array_of_ckeys_description[$ckey_cpt]{2}='%60s';
$array_of_display_keys[$ckey_cpt]{2}='y';
}
}

if ($show =~ m/^objectname$/i ){
# group by metricobjectname
$array_of_ckeys_description[$ckey_cpt]{2}='%30s';
$array_of_display_keys[$ckey_cpt]{2}='y';
}
}

#Delta fields
@delta_fields=(4);

#DEBUG PURPOSE
#print "command is $dclicomm\n";
#exit 0;

#
# Ctrl+C signal
#
$SIG{INT}= \&close;

sub close {
print "Stopping metrics collection...\n";
kill HUP => -$$;
}

sub report_values()
{

my %display_what = @_;
printf "\n";
printf ("%-8s %1s %-20s %2s %-25s %2s %-50s %-8s %-10s %-10s\n",'DELTA(s)','','CELL','','NAME','','OBJECTNAME','','VALUE','');
printf ("%-8s %1s %-20s %2s %-25s %2s %-50s %-8s %-10s %-10s\n",'--------','','----','','----','','----------','','-----','');

my $nb =1;
%resultset = ();

# Sort descending and keep the top first rows
foreach my $metric (sort {$display_what{$b}[4] <=> $display_what{$a}[4] } (keys(%display_what))) {

if ($nb <= $topn )
{
$nb=$nb+1;
@{$resultset{$metric}}=@{$display_what{$metric}};
}

# Break the foreach
last if ($nb > $topn);
}

# Display the top rows in ascending order by value
foreach my $metric (sort {$resultset{$a}[4] <=> $resultset{$b}[4] } (keys(%resultset))) {

printf ("%-8s %1s %-20s %2s %-25s %2s %-50s %-8s %-.2f %-10s\n",$resultset{$metric}->[3],'',$resultset{$metric}->[0],'',$resultset{$metric}->[1],'',$resultset{$metric}->[2],'',$resultset{$metric}->[4],$resultset{$metric}->[5]);
}
}

#
# get the metrics and populate the table
#

# Initialise
my $result=`$dclicomm` ;
my $key;
my $ckey;

# Split the string into array
my @array_result = split(/\n/, $result);

foreach my $line ( @array_result ) {
# drop tab
$line =~ s/\t+/ /g;
# drop blanks
$line =~ s/\s+/ /g;

#Split each line on 5 pieces based on blanks
my @tab1 = split (/ +/,$line,6);


# Supress : from the cell name
$tab1[0] =~ s/://;

# Convert collectionTime to seconds
$tab1[3]=collectionTime_to_seconds($tab1[3]);

# Use cell, name, metricObjectName as key
my $key = sprintf("%30s.%30s.%60s",$tab1[0],$tab1[1],$tab1[2]);
@{$exametric{$key}}=@tab1;
@{$diffstats{$key}}=@tab1;
}
# end Initialise

#
# Main loop
#

for (my $nb=0;$nb < $count;$nb++) {

printf "\n";
printf "--------------------------------------\n";
printf "----------COLLECTING DATA-------------\n";
printf "--------------------------------------\n";
sleep $interval;

my ($seconds, $minuts, $hours) = localtime(time);

# Get the metrics

my $result=`$dclicomm` ;
my $key;
my $ckey;

# Split the string into array
my @array_result = split(/\n/, $result);

# Empty diffstats
%diffstats = ();

foreach my $line ( @array_result ) {
$line =~ s/\s+/ /g;
$line =~ s/\t+/ /g;
#Split each line on 5 pieces based on blanks
my @tab1 = split (/ +/,$line,6);
# Supress : from the cell name
$tab1[0] =~ s/://;

# Convert Collection time to seconds
$tab1[3]=collectionTime_to_seconds($tab1[3]);


# Use cell, name, metricObjectName as key
$key = sprintf("%30s.%30s.%60s",$tab1[0],$tab1[1],$tab1[2]);

# Build the compute key

&build_compute_key(@tab1);

# Compute the delta value and suppress the "," first
$tab1[4] =~ s/,//g;
$exametric{$key}->[4] =~ s/,//g;

# Initialise non delta fields
for (my $tabid=0;$tabid < scalar(@tab1);$tabid++) {
if ($tabid != 3) {
for my $i ( 0 .. $#array_of_ckeys_description ) {
my $ckey=$array_of_ckey[$i];
$diffstats{$ckey}->[$tabid]=($array_of_display_keys[$i]{$tabid}?"$tab1[$tabid]":"") unless (grep (/^$tabid$/,@delta_fields));
$avgdiffstats{$ckey}->[$tabid]=($array_of_display_keys[$i]{$tabid}?"$tab1[$tabid]":"") unless (grep (/^$tabid$/,@delta_fields));
}
}
}

# get the list of delta fields
foreach my $deltaid (@delta_fields) {
for my $i ( 0 .. $#array_of_ckeys_description ) {
my $ckey=$array_of_ckey[$i];
$diffstats{$ckey}->[$deltaid] = $diffstats{$ckey}->[$deltaid] + $tab1[$deltaid] - $exametric{$key}->[$deltaid];
$diffstats{$ckey}->[3] = bdt_max($tab1[3] - $exametric{$key}->[3],$diffstats{$ckey}->[3],0);
}
}
@{$exametric{$key}} = @tab1;
}

# compute the average since the collection began

foreach my $deltaid (@delta_fields) {
foreach my $diffkey  (keys %diffstats){
$avgdiffstats{$diffkey}->[3] = $avgdiffstats{$diffkey}->[3] + $diffstats{$diffkey}->[3];
($diffstats{$diffkey}->[3] > 0)?($avgdiffstats{$diffkey}->[$deltaid] = (($avgdiffstats{$diffkey}->[$deltaid] * $cpt_array{$diffkey}) + $diffstats{$diffkey}->[$deltaid]) / ($cpt_array{$diffkey}+1)):"";
}
}

# Increment cpt if delta(s) is not zero
foreach my $diffkey  (keys %diffstats){
($diffstats{$diffkey}->[3] > 0)?($cpt_array{$diffkey}=$cpt_array{$diffkey}+1):"";
}


#--------------------------------#
# 
# Report Section #
# 
#--------------------------------#
# Report now for snaps
(grep (/snap/i,$display_pattern))?(print "\n"):"";
(grep (/snap/i,$display_pattern))?(print "......... SNAP FOR LAST COLLECTION TIME ...................\n"):"";
(grep (/snap/i,$display_pattern))?(print "\n"):"";
(grep (/snap/i,$display_pattern))?(&report_values(%diffstats)):"";

# Report now for avg 
(grep (/avg/i,$display_pattern))?(print "\n"):"";
(grep (/avg/i,$display_pattern))?(print "......... AVG SINCE FIRST COLLECTION TIME...................\n"):"";
(grep (/avg/i,$display_pattern))?(print "\n"):"";
(grep (/avg/i,$display_pattern))?(&report_values(%avgdiffstats)):"";

}
