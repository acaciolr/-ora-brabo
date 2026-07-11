#!/usr/bin/env perl

# Author: Bertrand Drouvot
# exadata_metrics_desc.pl: V1.0 (2015/07)
# Visit my blog : http://bdrouvot.wordpress.com/
#
# Utility used to add the exadata metric description to the cellcli output on the fly
# Example: cellcli -e "list metriccurrent attributes metricObjectName,name,metricValue where name like 'DB.*' and metricObjectName='BDT'" | ./exadata_metrics_desc.pl
#
# would produce something like:
#
#  BDT   DB_FC_IO_RQ (Number of IO requests issued by a database to flash cache)                58,611 IO requests
#  BDT   DB_FC_IO_RQ_SEC (Number of IO requests issued by a database to flash cache per second) 2.0 IO/sec 
#  .
#  .
#  .
#
# Feel free to build the query you want on the metrics.
# You just need to launch exadata_metrics_desc.pl to see the metric description being added on the fly
# (as long as the metric name appears in the output of your initial query).
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

my $cellclicom="cellcli -e \"list metricdefinition attributes name,description\"";
my $inputline="";
my %metric_desc;
my $key;
my $val;
my $word;
my $new_word;
my $mylength;
my $max_length=0;
my @max_length;
my @source_line;
my $inc=0;
my $cpt=-1;
my $report_format_values;
my $max_format;
my @report_values;


# Build the metric description Array
# Launch the command
my $result=`$cellclicom` ;

if ( $? != 0 ) 
{ 
print "\n";
print "\n";
die "Something went wrong executing [$cellclicom]\n"; 
}

# Split the string into array
my @array_result = split(/\n/, $result);

foreach my $line ( @array_result ) {
# drop tab
$line =~ s/\t+/ /g;
# drop blanks
$line =~ s/\s+/ /g;
$line =~ s/^ //g;

($key, $val) = split (/"/,$line);
$key =~ s/\s+//g;

$metric_desc{$key}=$val;
}

# Read the input: Add description and get max length per word

foreach $inputline (<>)
{
$inputline =~ s/^\t//g;
my @words= split '\t',$inputline;
$new_word="";
$inc=-1;
$cpt=$cpt+1;

foreach $word (@words)
{
$inc=$inc+1;
$word =~ s/^\s+|\s+$//g;
if ($metric_desc{$word}) {
$new_word = $word." (".$metric_desc{$word}.")";
} else {
$new_word = $word;
}
$mylength=length($new_word);
$max_length[$inc] = ($max_length[$inc], $mylength)[$max_length[$inc] < $mylength];
$source_line[$cpt]=$inputline;
}
}

# build the printf format

foreach $max_format (@max_length) {
$report_format_values=$report_format_values."%1s %-".$max_format."s ";
}
$report_format_values =~ s/ $/\n/g;

# second loop to replace and format the ouput

foreach $inputline (@source_line)
{
my @words= split '\t',$inputline;
my @values;
$new_word="";
$inc=-1;

foreach $word (@words)
{
$inc=$inc+1;
$word =~ s/^\s+|\s+$//g;
if ($metric_desc{$word}) {
$new_word = $word." (".$metric_desc{$word}.")";
} else {
$new_word = $word;
}
push(@values,' ',$new_word);
}
printf ($report_format_values,@values);
}
