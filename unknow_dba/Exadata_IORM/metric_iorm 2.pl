#!/usr/bin/perl
# 
# $Header: oss/deploy/scripts/metric_iorm.pl /main/10 2015/02/18 08:34:22 aksshah Exp $
#
# metric_iorm.pl
# 
# Copyright (c) 2009, 2015, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      metric_iorm.pl - <one-line expansion of the name>
#
#    DESCRIPTION
#      This script parses the cellcli IORM metrics and 
#      displays the information sorted based on database and 
#      consumer groups.
#
#    NOTES
#      <other useful comments, qualifications, etc.>
#
#    MODIFIED   (MM/DD/YY)
#    aksshah     07/20/15 - Bug 21349565: Versioning for fc allocate metrics
#    aksshah     02/10/15 - Add flash cache usage
#    kishykum    02/19/14 - Bug 18242146: Adding PDB metrics
#    aksshah     12/29/13 - Query metrics explicitly
#    aksshah     01/22/13 - Add debug mode
#    aksshah     07/20/09 - Add metrichistory support
#    aksshah     07/16/09 - IORM metrics script
#    aksshah     07/16/09 - Creation
# 

#Category metrics
$catg = "Don't parse!!";


#Consumer group metrics
$cg_io = "CG_IO";

#CG I/O count metrics
$cg_rq = "CG_IO_RQ";
@cg_rq_arr = ("CG_IO_RQ_SM_SEC", "CG_IO_RQ_LG_SEC");

#CG I/O wait metrics
$cg_wt = "CG_IO_WT";
@cg_wt_arr = ("CG_IO_WT_SM_RQ", "CG_IO_WT_LG_RQ");

#CG util metrics
$cg_util = "CG_IO_UTIL";
@cg_util_arr = ("CG_IO_UTIL_SM", "CG_IO_UTIL_LG");

#CG xput metrics
$cg_xput = "CG_IO_BY_SEC";

#Flash cache metrics
$fc_rq = "_FC_IO_RQ_SEC";
$fc_usage = "_FC_BY_ALLOCATED";
#CG FC metrics
$cg_fc_rq = "CG_FC_IO_RQ_SEC";

#Database metrics
$db_io = "DB_IO";

#DB I/O count metrics
$db_rq = "DB_IO_RQ";
@db_rq_arr = ("DB_IO_RQ_SM_SEC", "DB_IO_RQ_LG_SEC");

#DB I/O wait metrics
$db_wt = "DB_IO_WT";
@db_wt_arr = ("DB_IO_WT_SM_RQ", "DB_IO_WT_LG_RQ");

#DB util metrics
$db_util = "DB_IO_UTIL";
@db_util_arr = ("DB_IO_UTIL_SM", "DB_IO_UTIL_LG");

#DB xput metrics
$db_xput = "DB_IO_BY_SEC";

#DB FC metrics
$db_fc_rq = "DB_FC_IO_RQ_SEC";
$db_fc_usage = "DB_FC_BY_ALLOCATED";

#Pluggable Database metrics
$pdb_io = "PDB_IO";

#PDB I/O count metrics
$pdb_rq = "PDB_IO_RQ";
@pdb_rq_arr = ("PDB_IO_RQ_SM_SEC", "PDB_IO_RQ_LG_SEC");

#PDB I/O wait metrics
$pdb_wt = "PDB_IO_WT";
@pdb_wt_arr = ("PDB_IO_WT_SM_RQ", "PDB_IO_WT_LG_RQ");

#PDB util metrics
$pdb_util = "PDB_IO_UTIL";
@pdb_util_arr = ("PDB_IO_UTIL_SM", "PDB_IO_UTIL_LG");

#PDB xput metrics
$pdb_xput = "PDB_IO_BY_SEC";

#PDB FC metrics
$pdb_fc_rq = "PDB_FC_IO_RQ_SEC";
$pdb_fc_usage = "PDB_FC_BY_ALLOCATED";

#Celldisk latency metrics
$cd_io_tm = "CD_IO_TM";
@cd_io_tm_arr = ("CD_IO_TM_R_SM_RQ", "CD_IO_TM_R_LG_RQ", "CD_IO_TM_W_SM_RQ", "CD_IO_TM_W_LG_RQ");

#Celldisk IOPS metrics
$cd_rq = "CD_IO_RQ";
@cd_rq_arr = ("CD_IO_RQ_R_SM_SEC", "CD_IO_RQ_R_LG_SEC", "CD_IO_RQ_W_SM_SEC", "CD_IO_RQ_W_LG_SEC");

#Celldisk MBPS metrics
$cd_xput = "CD_IO_BY";
@cd_xput_arr = ("CD_IO_BY_R_SM_SEC", "CD_IO_BY_R_LG_SEC", "CD_IO_BY_W_SM_SEC", "CD_IO_BY_W_LG_SEC");

#Cellcli error string
$cli_error = "CELL-0";

#Where clause
$clause = "where";

#Debug clause
$debug = "-debug";

#Metrics clause
$metrics = "DB_IO_RQ_SM_SEC, DB_IO_RQ_LG_SEC, DB_IO_WT_SM_RQ, DB_IO_WT_LG_RQ, DB_IO_UTIL_SM, DB_IO_UTIL_LG, DB_IO_BY_SEC, DB_FC_IO_RQ_SEC, DB_FC_BY_ALLOCATED, CG_IO_RQ_SM_SEC, CG_IO_RQ_LG_SEC, CG_IO_WT_SM_RQ, CG_IO_WT_LG_RQ, CG_IO_UTIL_SM, CG_IO_UTIL_LG, CG_IO_BY_SEC, CG_FC_IO_RQ_SEC, CD_IO_TM_R_SM_RQ, CD_IO_TM_R_LG_RQ, CD_IO_TM_W_SM_RQ, CD_IO_TM_W_LG_RQ, CD_IO_RQ_R_SM_SEC, CD_IO_RQ_R_LG_SEC, CD_IO_RQ_W_SM_SEC, CD_IO_RQ_W_LG_SEC, CD_IO_BY_R_SM_SEC, CD_IO_BY_R_LG_SEC, CD_IO_BY_W_SM_SEC, CD_IO_BY_W_LG_SEC, PDB_IO_RQ_SM_SEC, PDB_IO_RQ_LG_SEC, PDB_IO_WT_SM_RQ, PDB_IO_WT_LG_RQ, PDB_IO_UTIL_SM, PDB_IO_UTIL_LG, PDB_IO_BY_SEC, PDB_FC_IO_RQ_SEC, PDB_FC_BY_ALLOCATED";

#11g cell deos not support PDB, FC space usage metrics
$metrics_11g_cell = "DB_IO_RQ_SM_SEC, DB_IO_RQ_LG_SEC, DB_IO_WT_SM_RQ, DB_IO_WT_LG_RQ, DB_IO_UTIL_SM, DB_IO_UTIL_LG, DB_IO_BY_SEC, DB_FC_IO_RQ_SEC, CG_IO_RQ_SM_SEC, CG_IO_RQ_LG_SEC, CG_IO_WT_SM_RQ, CG_IO_WT_LG_RQ, CG_IO_UTIL_SM, CG_IO_UTIL_LG, CG_IO_BY_SEC, CG_FC_IO_RQ_SEC, CD_IO_TM_R_SM_RQ, CD_IO_TM_R_LG_RQ, CD_IO_TM_W_SM_RQ, CD_IO_TM_W_LG_RQ, CD_IO_RQ_R_SM_SEC, CD_IO_RQ_R_LG_SEC, CD_IO_RQ_W_SM_SEC, CD_IO_RQ_W_LG_SEC, CD_IO_BY_R_SM_SEC, CD_IO_BY_R_LG_SEC, CD_IO_BY_W_SM_SEC, CD_IO_BY_W_LG_SEC";

$idx = 0;
$cidx = 0;
$dbm = 0;
$pdbm = 0;
$cgm = 0;
$cdm = 0;

#Routine to compare times
sub convert_time_to_int
{
  $_[0] =~ m/(\d{4})-(\d{2})-(\d{2})(\w{1})(\d{2}):(\d{2}):(\d{2})(\S+)/;
  return "$1$2$3$5$6$7";
}

#Array to store hardisk celldisks
@celldisk = ();

$numArgs = $#ARGV + 1;
if ($numArgs)
{
  foreach $arg(@ARGV)
  {
    if (index($arg, $clause) >= 0)
    {
      $metric_mode = 1;
    }
    if (index($arg, $debug) >= 0)
    {
      $debug_mode = 1;
    }
    if ($metric_mode == 1)
    {
      if (index($arg, $debug) == -1)
      {
        $whr_clause = $whr_clause." ".$arg;
      }
    }
  }
}

# Check PDB, FC space usage support for metrics
@result = `cellcli -e "list metricdefinition PDB_IO_RQ_SM_SEC, DB_FC_BY_ALLOCATED, PDB_FC_BY_ALLOCATED"`;
foreach $res(@result)
{
  if (index($res, $cli_error) >= 0)
  {
    $ver_11g_cell = 1;
  }
  else
  {
    $ver_11g_cell = 0;
  }
}

if ($metric_mode == 1)
{
  if ($ver_11g_cell)
  {
    @result = `cellcli -e "list metrichistory $metrics_11g_cell $whr_clause"`;
  }
  else
  {
    @result = `cellcli -e "list metrichistory $metrics $whr_clause"`;
  }
  foreach $res(@result)
  {
    if (index($res, $cli_error) >= 0)
    {
      print $res;
      exit (0);
    }
    $size = @result;
  }
}
else
{
  if ($ver_11g_cell)
  {
    @result = `cellcli -e "list metriccurrent $metrics_11g_cell"`;
  }
  else
  {
    @result = `cellcli -e "list metriccurrent $metrics"`;
  }
  foreach $res(@result)
  {
    if (index($res, $cli_error) >= 0)
    {
      print $res;
      exit (0);
    }
    $size = @result;
  }
}

#Identify hard disk celldisks
@cdisk_result = `cellcli -e "list celldisk where diskType = 'HardDisk'"`;
$csize = @cdisk_result;

while ($cidx < $csize)
{
  $cdisk_result[$cidx] =~ m/(\s+)(\w+)(\s+)(\w+)/;
  push (@celldisk, $2);
  $cidx++;
}
$cdisk_size = @celldisk;

# Spool data to a file
if ($debug_mode)
{
  open (DUMPFILE, '>metric_iorm.out');
}

#Parse the metriccurent output to filter DB, PDB, CG and CD metrics
while($idx < $size)
{
  # filter IORM metrics
  if (index($result[$idx], $cg_io)  >= 0 || 
      index($result[$idx], $pdb_io) >= 0 || 
      index($result[$idx], $db_io)  >= 0 ||
      index($result[$idx], $fc_rq)  >= 0 ||
      index($result[$idx], $fc_usage) >= 0)
  {
    # Dump the metrics to file
    if ($debug_mode)
    {
      print DUMPFILE $result[$idx];
    }

    if (index($result[$idx], $cg_io) >= 0)
    {
      if (index($result[$idx], $cg_rq) >= 0 || index($result[$idx], $cg_wt) >= 0)
      {
        if ($metric_mode == 1)
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)(\s+)(\w+)(\/*)(\s*)(\w+)(\s+)(\S+)(\s+)/;

          # Store details in arrays
          if ( ( grep { $_ eq $2 } @cg_rq_arr ) ||
               ( grep { $_ eq $2 } @cg_wt_arr ) )
          {
            push(@cg_metric,$2);
            push(@cg_dbname,$4);
            push(@cg_cgname,$6);
            push(@cg_value,$8.$10.$11.$12);
            push(@cg_time, $19);

            if ($6 =~ m/(\S+)\.(\S+)/)
            {
              push(@cg_pdbname, $1);
            }
            else
            {
              push(@cg_pdbname, "");
            }
            $cgm++;
          }
        }
        else
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)/;

          # Store details in arrays
          if ( ( grep { $_ eq $2 } @cg_rq_arr ) || 
               ( grep { $_ eq $2 } @cg_wt_arr ) )
          {
            push(@cg_metric,$2);
            push(@cg_dbname,$4);
            push(@cg_cgname,$6);
            push(@cg_value,($8.$10.$11.$12));

            if ($6 =~ m/(\S+)\.(\S+)/)
            {
              push(@cg_pdbname, $1);
            }
            else
            {
              push(@cg_pdbname, "");
            }
            $cgm++;
          }
        }
      }
      elsif (index($result[$idx], $cg_util) >= 0)
      {
        if ($metric_mode == 1)
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\s+)(\%{1})(\s+)(\S+)(\s+)/;

          # Store details in arrays
          if ( grep { $_ eq $2 } @cg_util_arr )
          {
            push(@cg_metric,$2);
            push(@cg_dbname,$4);
            push(@cg_cgname,$6);
            push(@cg_value,$8);
            push(@cg_time, $12);
            if ($6 =~ m/(\S+)\.(\S+)/)
            {
              push(@cg_pdbname, $1);
            }
            else
            {
              push(@cg_pdbname, "");
            }
            $cgm++;
          }
        }
        else
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\s+)(\%{1})(\s+)/;

          # Store details in arrays
          if ( grep { $_ eq $2 } @cg_util_arr )
          {
            push(@cg_metric,$2);
            push(@cg_dbname,$4);
            push(@cg_cgname,$6);
            push(@cg_value,$8);
            if ($6 =~ m/(\S+)\.(\S+)/)
            {
              push(@cg_pdbname, $1);
            }
            else
            {
              push(@cg_pdbname, "");
            }
            $cgm++;
          }
        }
      }
      elsif (index($result[$idx], $cg_xput) >= 0)
      {
        if ($metric_mode == 1)
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\s+)(\S+)(\s+)(\S+)(\s+)/;

          # Store details in arrays
          push(@cg_metric,$2);
          push(@cg_dbname,$4);
          push(@cg_cgname,$6);
          push(@cg_value,$8);
          push(@cg_time, $12);
          if ($6 =~ m/(\S+)\.(\S+)/)
          {
            push(@cg_pdbname, $1);
          }
          else
          {
            push(@cg_pdbname, "");
          }
          $cgm++;
        }
        else
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\s+)(\S+)(\s+)/;

          # Store details in arrays
          push(@cg_metric,$2);
          push(@cg_dbname,$4);
          push(@cg_cgname,$6);
          push(@cg_value,$8);
          if ($6 =~ m/(\S+)\.(\S+)/)
          {
            push(@cg_pdbname, $1);
          }
          else
          {
            push(@cg_pdbname, "");
          }
          $cgm++;
        }
      }
    }
    elsif (index($result[$idx], $pdb_io) >= 0)
    {
      if (index($result[$idx], $pdb_rq) >= 0 || index($result[$idx], $pdb_wt) >= 0)
      {
        if ($metric_mode == 1)
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)(\s+)(\w+)(\/*)(\s*)(\w+)(\s+)(\S+)(\s+)/;

          # Store details in arrays
          if ( ( grep { $_ eq $2 } @pdb_rq_arr ) ||
               ( grep { $_ eq $2 } @pdb_wt_arr ) )
          {
            push(@pdb_metric,$2);
            push(@pdb_dbname,$4);
            push(@pdb_pdbname,$6);
            push(@pdb_value,$8.$10.$11.$12);
            push(@pdb_time, $19);
            $pdbm++;
          }
        }
        else
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)/;

          # Store details in arrays
          if ( ( grep { $_ eq $2 } @pdb_rq_arr ) || 
               ( grep { $_ eq $2 } @pdb_wt_arr ) )
          {
            push(@pdb_metric,$2);
            push(@pdb_dbname,$4);
            push(@pdb_pdbname,$6);
            push(@pdb_value,($8.$10.$11.$12));
            $pdbm++;
          }
        }
      }
      elsif (index($result[$idx], $pdb_util) >= 0)
      {
        if ($metric_mode == 1)
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\s+)(\%{1})(\s+)(\S+)(\s+)/;

          # Store details in arrays
          if ( grep { $_ eq $2 } @pdb_util_arr )
          {
            push(@pdb_metric,$2);
            push(@pdb_dbname,$4);
            push(@pdb_pdbname,$6);
            push(@pdb_value,$8);
            push(@pdb_time, $12);
            $pdbm++;
          }
        }
        else
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\s+)(\%{1})(\s+)/;

          # Store details in arrays
          if ( grep { $_ eq $2 } @pdb_util_arr )
          {
            push(@pdb_metric,$2);
            push(@pdb_dbname,$4);
            push(@pdb_pdbname,$6);
            push(@pdb_value,$8);
            $pdbm++;
          }
        }
      }
      elsif (index($result[$idx], $pdb_xput) >= 0)
      {
        if ($metric_mode == 1)
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\s+)(\S+)(\s+)(\S+)(\s+)/;

          # Store details in arrays
          push(@pdb_metric,$2);
          push(@pdb_dbname,$4);
          push(@pdb_pdbname,$6);
          push(@pdb_value,$8);
          push(@pdb_time, $12);
          $pdbm++;
        }
        else
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\s+)(\S+)(\s+)/;

          # Store details in arrays
          push(@pdb_metric,$2);
          push(@pdb_dbname,$4);
          push(@pdb_pdbname,$6);
          push(@pdb_value,$8);
          $pdbm++;
        }
      }
    }
    elsif (index($result[$idx], $db_io) >= 0)
    {
      if (index($result[$idx], $db_rq) >= 0 || index($result[$idx], $db_wt) >= 0)
      {
        if ($metric_mode == 1)
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)(\s+)(\w+)(\/*)(\s*)(\w+)(\s+)(\S+)(\s+)/;
          
          # Store details in arrays
          if ( ( grep { $_ eq $2 } @db_rq_arr ) || 
               ( grep { $_ eq $2 } @db_wt_arr ))
          {
            push(@db_metric,$2);
            push(@db_name,$4);
            push(@db_value,$6.$8.$9.$10);
            push(@db_time, $17);
            $dbm++;
          }
        }
        else
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)/;

          # Store details in arrays
          if ( ( grep { $_ eq $2 } @db_rq_arr ) || 
               ( grep { $_ eq $2 } @db_wt_arr ) )
          {
            push(@db_metric,$2);
            push(@db_name,$4);
            push(@db_value,($6.$8.$9.$10));
            $dbm++;
          }
        }
      }
      elsif (index($result[$idx], $db_util) >= 0)
      {
        if ($metric_mode == 1)
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\s+)(\%{1})(\s+)(\S+)(\s+)/;
          
          # Store details in arrays
          if (grep { $_ eq $2 } @db_util_arr)
          {
            push(@db_metric,$2);
            push(@db_name,$4);
            push(@db_value,$6);
            push(@db_time, $10);
            $dbm++;
          }
        }
        else
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\s+)(\%{1})(\s+)/;

          # Store details in arrays
          if (grep { $_ eq $2 } @db_util_arr)
          {
            push(@db_metric,$2);
            push(@db_name,$4);
            push(@db_value,($6));
            $dbm++;
          }
        } 
      }
      elsif (index($result[$idx], $db_xput) >= 0)
      {
        if ($metric_mode == 1)
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\s+)(\S+)(\s+)(\S+)(\s+)/;

          # Store details in arrays
          push(@db_metric,$2);
          push(@db_name,$4);
          push(@db_value,$6);
          push(@db_time, $10);
          $dbm++;
        }
        else
        {
          # Parse the metric line
          $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\s+)(\S+)(\s+)/;

          # Store details in arrays
          push(@db_metric,$2);
          push(@db_name,$4);
          push(@db_value,($6));
          $dbm++;
        }
      }
    }
    elsif (index($result[$idx], $cg_fc_rq) >= 0)
    {
      if ($metric_mode == 1)
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)(\s+)(\w+)(\/*)(\s*)(\w+)(\s+)(\S+)(\s+)/;

        # Store details in arrays
        push(@cg_metric,$2);
        push(@cg_dbname,$4);
        push(@cg_cgname,$6);
        push(@cg_value,$8.$10.$11.$12);
        push(@cg_time, $19);
        if ($6 =~ m/(\S+)\.(\S+)/)
        {
          push(@cg_pdbname, $1);
        }
        else
        {
          push(@cg_pdbname, "");
        }
        $cgm++;
      }
      else
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)/;
       
        # Store details in arrays
        push(@cg_metric,$2);
        push(@cg_dbname,$4);
        push(@cg_cgname,$6);
        push(@cg_value,($8.$10.$11.$12));
        if ($6 =~ m/(\S+)\.(\S+)/)
        {
          push(@cg_pdbname, $1);
        }
        else
        {
          push(@cg_pdbname, "");
        }
        $cgm++;
      }
    }
    elsif (index($result[$idx], $pdb_fc_rq) >= 0)
    {
      if ($metric_mode == 1)
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)(\s+)(\w+)(\/*)(\s*)(\w+)(\s+)(\S+)(\s+)/;

        # Store details in arrays
        push(@pdb_metric,$2);
        push(@pdb_dbname,$4);
        push(@pdb_pdbname,$6);
        push(@pdb_value,$8.$10.$11.$12);
        push(@pdb_time, $19);
        $pdbm++;
      }
      else
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)/;

        # Store details in arrays
        push(@pdb_metric,$2);
        push(@pdb_dbname,$4);
        push(@pdb_pdbname,$6);
        push(@pdb_value,($8.$10.$11.$12));
        $pdbm++;
      }
    }
    elsif (index($result[$idx], $db_fc_rq) >= 0)
    {
      if ($metric_mode == 1)
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)(\s+)(\w+)(\/*)(\s*)(\w+)(\s+)(\S+)(\s+)/;

        # Store details in arrays
        push(@db_metric,$2);
        push(@db_name,$4);
        push(@db_value,$6.$8.$9.$10);
        push(@db_time, $17);
        $dbm++;
      }
      else
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)/;

        # Store details in arrays
        push(@db_metric,$2);
        push(@db_name,$4);
        push(@db_value,($6.$8.$9.$10));
        $dbm++;
      }
    }
    elsif (index($result[$idx], $pdb_fc_usage) >= 0)
    {
      if ($metric_mode == 1)
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)(\s+)(\w+)(\/*)(\s*)(\w+)(\s+)(\S+)(\s+)/;

        # Store details in arrays
        push(@pdb_metric,$2);
        push(@pdb_dbname,$4);
        push(@pdb_pdbname,$6);
        push(@pdb_value,$8.$10.$11.$12);
        push(@pdb_time, $19);
        $pdbm++;
      }
      else
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\.*)(\S+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)/;

        # Store details in arrays
        push(@pdb_metric,$2);
        push(@pdb_dbname,$4);
        push(@pdb_pdbname,$6);
        push(@pdb_value,($8.$10.$11.$12));
        $pdbm++;
      }
    }
    elsif (index($result[$idx], $db_fc_usage) >= 0)
    {
      if ($metric_mode == 1)
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)(\s+)(\w+)(\/*)(\s*)(\w+)(\s+)(\S+)(\s+)/;

        # Store details in arrays
        push(@db_metric,$2);
        push(@db_name,$4);
        push(@db_value,$6.$8.$9.$10);
        push(@db_time, $17);
        $dbm++;
      }
      else
      {
        # Parse the metric line
        $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)/;

        # Store details in arrays
        push(@db_metric,$2);
        push(@db_name,$4);
        push(@db_value,($6.$8.$9.$10));
        $dbm++;
      }
    }
  }
  elsif (index($result[$idx], $cd_io_tm) >= 0)
  {
    # Dump the metrics to file
    if ($debug_mode)
    {
      print DUMPFILE $result[$idx];
    }

    if ($metric_mode == 1)
    {
      # Parse the metric line
      $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d*)(\,*)(\d*)(\,*)(\d*)(\.*)(\d*)(\s+)(\S+)(\s+)(\S+)(\s+)/;

      # Check if this is a harddisk metric
      if ( ( grep { $_ eq $2 } @cd_io_tm_arr ) && 
           ( grep { $_ eq $4 } @celldisk ) )
      {
        # Store details in arrays
        push(@cd_metric,$2);
        push(@cd_name,$4);
        push(@cd_value, ($6.$8.$10.$11.$12));
        push(@cd_time, $16);
        $cdm++;
      }
    }
    else
    {
      # Parse the metric line
      $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d*)(\,*)(\d*)(\,*)(\d*)(\.*)(\d*)/;

      # Check if this is a harddisk metric
      if ( ( grep { $_ eq $2 } @cd_io_tm_arr ) && 
           ( grep { $_ eq $4 } @celldisk ) )
      {
        # Store details in arrays
        push(@cd_metric,$2);
        push(@cd_name,$4);
        push(@cd_value, ($6.$8.$10.$11.$12));
        $cdm++;
      }
    }
  }
  elsif (index($result[$idx], $cd_rq) >= 0)
  {
    # Dump the metrics to file
    if ($debug_mode)
    {
      print DUMPFILE $result[$idx];
    }

    if ($metric_mode == 1)
    {
      # Parse the metric line
      $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)(\s+)(\w+)(\/*)(\w+)(\s*)(\S+)(\s+)/;

      # Check if this is a harddisk metric
      if ( ( grep { $_ eq $2 } @cd_rq_arr ) && 
           ( grep { $_ eq $4 } @celldisk ) )
      {
        # Store details in arrays
        push(@cd_metric,$2);
        push(@cd_name,$4);
        push(@cd_value, ($6.$8.$9.$10));
        push(@cd_time, $16);
        $cdm++;
      }
    }
    else
    {
      # Parse the metric line
      $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\,*)(\d*)(\.*)(\d*)/;

      # Check if this is a harddisk metric
      if ( ( grep { $_ eq $2 } @cd_rq_arr ) && 
           ( grep { $_ eq $4 } @celldisk ) )
      {
        # Store details in arrays
        push(@cd_metric,$2);
        push(@cd_name,$4);
        push(@cd_value, ($6.$8.$9.$10));
        $cdm++;
      }
    }
  }
  elsif (index($result[$idx], $cd_xput) >= 0)
  {
    # Dump the metrics to file
    if ($debug_mode)
    {
      print DUMPFILE $result[$idx];
    }

    if ($metric_mode == 1)
    {
      # Parse the metric line
      $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\.*)(\d*)(\s+)(\S+)(\s+)(\S+)(\s+)/;

      # Check if this is a harddisk metric
      if ( ( grep { $_ eq $2 } @cd_xput_arr ) &&
           ( grep { $_ eq $4 } @celldisk ) )
      {
        # Store details in arrays
        push(@cd_metric,$2);
        push(@cd_name,$4);
        push(@cd_value, ($6.$7.$8));
        push(@cd_time, $12);
        $cdm++;
      }
    }
    else
    {
      # Parse the metric line
      $result[$idx] =~ m/(\s+)(\w+)(\s+)(\w+)(\s+)(\d+)(\.*)(\d*)(\s+)(\S+)(\s+)/;

      # Check if this is a harddisk metric
      if ( ( grep { $_ eq $2 } @cd_xput_arr ) &&
           ( grep { $_ eq $4 } @celldisk ) )
      {
        # Store details in arrays
        push(@cd_metric,$2);
        push(@cd_name,$4);
        push(@cd_value, ($6.$7.$8));
        $cdm++;
      }
    }
  }

  #Process the next metric
  $idx++;
}

# Close the file
if ($debug_mode)
{
  close(DUMPFILE);
}

#Identify unique time periods
%unique_times;
foreach my $time (@db_time)
{
  $unique_times{$time} =  1;
}
foreach my $time (@cd_time)
{
  $unique_times{$time} =  1;
}
@unsorted_time = keys %unique_times;

#Sort times in ascending order
@unique_time = sort@unsorted_time;
$num_periods = @unique_time;
if (!$metric_mode)
{
  $num_periods = 1;
}

#Identify unique databases
%unique_dbs;
foreach my $db (@db_name)
{
  $unique_dbs{$db} = 1;
}
@unique_dbname = keys %unique_dbs;

#Identify unique pluggable databases
%unique_pdbs;
foreach my $pdb (@pdb_pdbname)
{
  $unique_pdbs{$pdb} = 1;
}
@unique_pdbname = keys %unique_pdbs;
$num_pdbs = @unique_pdbname;

#Identify unique consumer groups
%unique_cgs;
foreach my $cg (@cg_cgname)
{
  $unique_cgs{$cg} = 1;
}
@unique_cgname = keys %unique_cgs;

#Identify unique consolidated databases
%unique_cdbs;
foreach my $cdb (@pdb_dbname)
{
  $unique_cdbs{$cdb} = 1;
}
@unique_cdbname = keys %unique_cdbs;

#Process each minute
for ($t=0; $t < $num_periods; $t++)
{
  $i = $time = 0;
  $show_lat_stats = 0;
  $show_summary_stats = 0;

  #Process each DB metric
  while ($i < @unique_dbname)
  {
    $sio_iops = $sio_qtime = 0;
    $lio_iops = $lio_qtime = 0;
    $lio_util = $sio_util = 0;
    $fc_iops = $xput = 0;
    $fc_usage = 0;

    #Process each database metric
    for ($j=0; $j < $dbm; $j++)
    {
      # Verify that name is exact match and not subset
      if (($db_name[$j] eq $unique_dbname[$i])&&
          ($db_time[$j] eq $unique_time[$t]))
      {
        #Print DB metrics for each database
        if ($db_metric[$j] eq $db_rq_arr[0])
        {
          if (length $db_value[$j] > 0)
          {
            $sio_iops = $db_value[$j];
          }
          else
          {
            $sio_iops = 0;
          }
        }
        if ($db_metric[$j] eq $db_rq_arr[1])
        {
          if (length $db_value[$j] > 0)
          {
            $lio_iops = $db_value[$j];
          }
          else
          {
            $lio_iops = 0;
          }
        }
        if ($db_metric[$j] eq $db_wt_arr[0])
        {
          if (length $db_value[$j] > 0)
          {
            $sio_qtime = $db_value[$j];
          }
          else
          {
            $sio_qtime = 0;
          }
        }
        if ($db_metric[$j] eq $db_wt_arr[1])
        {
          if (length $db_value[$j] > 0)
          {
            $lio_qtime = $db_value[$j];
          }
          else
          {
            $lio_qtime = 0;
          }
        }
        if ($db_metric[$j] eq $db_util_arr[0])
        {
          if (length $db_value[$j] > 0)
          {
            $sio_util = $db_value[$j];
          }
          else
          {
            $sio_util = 0;
          }
        }
        if ($db_metric[$j] eq $db_util_arr[1])
        {
          if (length $db_value[$j] > 0)
          {
            $lio_util = $db_value[$j];
          }
          else
          {
            $lio_util = 0;
          }
        }
        if ($db_metric[$j] eq $db_xput)
        {
          if (length $db_value[$j] > 0)
          {
            $xput = $db_value[$j];
          }
          else
          {
            $xput = 0;
          }
        }
        if ($db_metric[$j] eq $db_fc_rq)
        {
          if (length $db_value[$j] > 0)
          {
            $fc_iops = $db_value[$j];
          }
          else
          {
            $fc_iops = 0;
          }
        }
        if ($db_metric[$j] eq $db_fc_usage)
        {
          if (length $db_value[$j] > 0)
          {
            $fc_usage = $db_value[$j];
          }
          else
          {
            $fc_usage = 0;
          }
        }
      }
    }

    if (($sio_iops ne "0.0" && $sio_iops) || 
        ($lio_iops ne "0.0" && $lio_iops) || 
        ($sio_qtime ne "0.0" && $sio_qtime) || 
        ($lio_qtime ne "0.0" && $lio_qtime) ||
        ($lio_util ne "0.0" && $lio_util) ||
        ($sio_util ne "0.0" && $sio_util) ||
        ($xput ne "0.0" && $xput) ||
        ($fc_iops ne "0.0" && $fc_iops) ||
        ($fc_usage ne "0.0" && $fc_usage))
    {
      if (!$time && $metric_mode)
      {
        print "\nTime: $unique_time[$t]";
        $time = 1;
      }
      print "\nDatabase: ".$unique_dbname[$i]."\n";
      print "Utilization:     Small=".$sio_util."%\tLarge=".$lio_util."%\n";
      print "Flash Cache:     IOPS=".$fc_iops."\tSpace allocated=".$fc_usage."MB\n";
      print "Disk Throughput: MBPS=".$xput."\n";
      print "Small I/O's:     IOPS=".$sio_iops."\tAvg qtime=".$sio_qtime."ms\n";
      print "Large I/O's:     IOPS=".$lio_iops."\tAvg qtime=".$lio_qtime."ms\n";

      $show_lat_stats = 1;
      $show_summary_stats = 1;

      # Update summary stats
      $sio_util_sum += $sio_util;
      $lio_util_sum += $lio_util;
      $fc_iops_sum += $fc_iops;
      $fc_usage_sum += $fc_usage;
      $xput_sum += $xput;
      $sio_iops_sum += $sio_iops;
      $lio_iops_sum += $lio_iops;
    }

    #PDB metrics
    $sio_iops = $sio_qtime = 0;
    $lio_iops = $lio_qtime = 0;
    $lio_util = $sio_util = 0;
    $fc_iops = $xput = 0;
    $fc_usage = 0;

    $is_cdb = 0;
    if ($unique_cdbs{$unique_dbname[$i]} == 1)
    {
      $is_cdb = 1;
    }
 
    #Process each unique Pluggable Database
    $pdb_iter = (($is_cdb) ? ($num_pdbs): 1);

    for ($p=0; $p < $pdb_iter; $p++)
    {
      #Process each pluggable database metric
      for ($j=0; ($is_cdb == 1) && ($j < $pdbm); $j++)
      {
        #Match pluggable database name and database name
        if ($unique_pdbname[$p] eq $pdb_pdbname[$j] &&
            $pdb_dbname[$j] eq $unique_dbname[$i] &&
            $pdb_time[$j] eq $unique_time[$t])
        {
          $found = 1;
          if ($pdb_metric[$j] eq $pdb_rq_arr[0])
          {
            if (length $pdb_value[$j] > 0)
            {
              $sio_iops = $pdb_value[$j];
            }
            else
            {
              $sio_iops = 0;
            }
          }
          if ($pdb_metric[$j] eq $pdb_rq_arr[1])
          {
            if (length $pdb_value[$j] > 0)
            {
              $lio_iops = $pdb_value[$j];
            }
            else
            {
              $lio_iops = 0;
            }
          }
          if ($pdb_metric[$j] eq $pdb_wt_arr[0])
          {
            if (length $pdb_value[$j] > 0)
            {
              $sio_qtime = $pdb_value[$j];
            }
            else
            {
              $sio_qtime = 0;
            }
          }
          if ($pdb_metric[$j] eq $pdb_wt_arr[1])
          {
            if (length $pdb_value[$j] > 0)
            {
              $lio_qtime = $pdb_value[$j];
            }
            else
            {
              $lio_qtime = 0;
            }
          }
          if ($pdb_metric[$j] eq $pdb_util_arr[0])
          {
            if (length $pdb_value[$j] > 0)
            {
              $sio_util = $pdb_value[$j];
            }
            else
            {
              $sio_util = 0;
            }
          }
          if ($pdb_metric[$j] eq $pdb_util_arr[1])
          {
            if (length $pdb_value[$j] > 0)
            {
              $lio_util = $pdb_value[$j];
            }
            else
            {
              $lio_util = 0;
            }
          }
          if ($pdb_metric[$j] eq $pdb_xput)
          {
            if (length $pdb_value[$j] > 0)
            {
              $xput = $pdb_value[$j];
            }
            else
            {
              $xput = 0;
            }
          }
          if ($pdb_metric[$j] eq $pdb_fc_rq)
          {
            if (length $pdb_value[$j] > 0)
            {
              $fc_iops = $pdb_value[$j];
            }
            else
            {
              $fc_iops = 0;
            }
          }
          if ($pdb_metric[$j] eq $pdb_fc_usage)
          {
            if (length $pdb_value[$j] > 0)
            {
              $fc_usage = $pdb_value[$j];
            }
            else
            {
              $fc_usage = 0;
            }
          }
        }
      }
      if ($is_cdb == 1 && $found &&
          (($sio_iops ne "0.0" && $sio_iops) ||
           ($lio_iops ne "0.0" && $lio_iops) || 
           ($sio_qtime ne "0.0" && $sio_qtime) ||
           ($lio_qtime ne "0.0" && $lio_qtime) ||
           ($lio_util ne "0.0" && $lio_util) ||
           ($sio_util ne "0.0" && $sio_util) ||
           ($xput ne "0.0" && $xput) ||
           ($fc_iops ne "0.0" && $fc_iops) ||
           ($fc_usage ne "0.0" && $fc_usage)))
      {
        print "    Pluggable Database: ".$unique_pdbname[$p]."\n";
        print "    Utilization:     Small=".$sio_util."%\tLarge=".$lio_util."%\n";
        print "    Flash Cache:     IOPS=".$fc_iops."\tSpace allocated=".$fc_usage."MB\n";
        print "    Disk Throughput: MBPS=".$xput."\n";
        print "    Small I/O's:     IOPS=".$sio_iops."\tAvg qtime=".$sio_qtime."ms\n";
        print "    Large I/O's:     IOPS=".$lio_iops."\tAvg qtime=".$lio_qtime."ms\n";
        $found = 0;
        $sio_iops = $sio_qtime = 0;
        $lio_iops = $lio_qtime = 0;
        $lio_util = $sio_util = 0;
        $fc_iops = $xput = 0;
        $fc_usage = 0;
      }

      $sio_iops = $sio_qtime = 0;
      $lio_iops = $lio_qtime = 0;
      $lio_util = $sio_util = 0;
      $fc_iops = $xput = 0;

      #Process each unique Consumer Group
      for ($k=0; $k < @unique_cgname; $k++)
      {
        #Process each consumer group metric
        for ($j=0; $j < $cgm; $j++)
        {
          #Match the database name and consumer group name
          if ($unique_cgname[$k] eq $cg_cgname[$j] &&
              ($is_cdb == 0 || $cg_pdbname[$j] eq $unique_pdbname[$p]) &&
              $cg_dbname[$j] eq $unique_dbname[$i] &&
              $cg_time[$j] eq $unique_time[$t])
          {
            $found = 1;
            if ($cg_metric[$j] eq $cg_rq_arr[0])
            {
              if (length $cg_value[$j] > 0)
              {
                $sio_iops = $cg_value[$j];
              }
              else
              {
                $sio_iops = 0;
              }
            }
            if ($cg_metric[$j] eq $cg_rq_arr[1])
            {
              if (length $cg_value[$j] > 0)
              {
                $lio_iops = $cg_value[$j];
              }
              else
              {
                $lio_iops = 0;
              }
            }
            if ($cg_metric[$j] eq $cg_wt_arr[0])
            {
              if (length $cg_value[$j] > 0)
              {
                $sio_qtime = $cg_value[$j];
              }
              else
              {
                $sio_qtime = 0;
              }
            }
            if ($cg_metric[$j] eq $cg_wt_arr[1])
            {
              if (length $cg_value[$j] > 0)
              {
                $lio_qtime = $cg_value[$j];
              }
              else
              {
                $lio_qtime = 0;
              }
            }
            if ($cg_metric[$j] eq $cg_util_arr[0])
            {
              if (length $cg_value[$j] > 0)
              {
                $sio_util = $cg_value[$j];
              }
              else
              {
                $sio_util = 0;
              }
            }
            if ($cg_metric[$j] eq $cg_util_arr[1])
            {
              if (length $cg_value[$j] > 0)
              {
                $lio_util = $cg_value[$j];
              }
              else
              {
                $lio_util = 0;
              }
            }
            if ($cg_metric[$j] eq $cg_xput)
            {
              if (length $cg_value[$j] > 0)
              {
                $xput = $cg_value[$j];
              }
              else
              {
                $xput = 0;
              }
            }
            if ($cg_metric[$j] eq $cg_fc_rq)
            {
              if (length $cg_value[$j] > 0)
              {
                $fc_iops = $cg_value[$j];
              }
              else
              {
                $fc_iops = 0;
              }
            }
          }
        }
        if ($found && 
            (($sio_iops ne "0.0" && $sio_iops) || 
             ($lio_iops ne "0.0" && $lio_iops) || 
             ($sio_qtime ne "0.0" && $sio_qtime) ||
             ($lio_qtime ne "0.0" && $lio_qtime) ||
             ($lio_util ne "0.0" && $lio_util) ||
             ($sio_util ne "0.0" && $sio_util) ||
             ($xput ne "0.0" && $xput) ||
             ($fc_iops ne "0.0" && $fc_iops)))
        {
          print "\tConsumer Group: ".$unique_cgname[$k]."\n";
          print "\tUtilization:     Small=".$sio_util."%    Large=".$lio_util."%\n";
          print "\tFlash Cache:     IOPS=".$fc_iops."\n";
          print "\tDisk Throughput: MBPS=".$xput."\n";
          print "\tSmall I/O's:     IOPS=".$sio_iops."    Avg qtime=".$sio_qtime."ms\n";
          print "\tLarge I/O's:     IOPS=".$lio_iops."    Avg qtime=".$lio_qtime."ms\n";
          $found = 0;
          $sio_iops = $sio_qtime = 0;
          $lio_iops = $lio_qtime = 0;
          $lio_util = $sio_util = 0;
          $fc_iops = $xput = 0;
        }
      }
    }
    $i++;
  }

  if ($show_summary_stats)
  {
    print "\nCELL METRICS SUMMARY\n\n";
    print "Cell Total Utilization:     Small=".$sio_util_sum."%\tLarge=".$lio_util_sum."%\n";
    print "Cell Total Flash Cache:     IOPS=".$fc_iops_sum."\tSpace allocated=".$fc_usage_sum."MB\n";
  }

  # Reset summary fields
  $sio_util_sum = 0;
  $lio_util_sum = 0;
  $fc_iops_sum = 0;
  $fc_usage_sum = 0;
  $xput_sum = 0;
  $sio_iops_sum = 0;
  $lio_iops_sum = 0;
  $cd_siops = 0;
  $cd_liops = 0;

  $lg_rd_lat = 0;
  $sm_rd_lat = 0;
  $lr_wt_lat = 0;
  $sm_wt_lat = 0;

  #Process latency metrics
  for ($i=0; $i < $cdm; $i++)
  {
    # Celldisk metric time might be off by a couple of seconds wrt to the IORM metrics.
    # Hence we compare the time upto the minute value.

    $cd_time_int = convert_time_to_int($cd_time[$i]);
    $unique_time_int = convert_time_to_int($unique_time[$t]);

    if (($cd_time_int > $unique_time_int && ($cd_time_int - $unique_time_int) < 45) ||
        ($unique_time_int > $cd_time_int && ($unique_time_int - $cd_time_int) < 45) ||
        ($cd_time_int == $unique_time_int))
    {
      if ($cd_metric[$i] eq $cd_io_tm_arr[0])
      {
        $sm_rd_lat += $cd_value[$i];
      }
      if ($cd_metric[$i] eq $cd_io_tm_arr[1])
      {
        $lg_rd_lat += $cd_value[$i];
      }
      if ($cd_metric[$i] eq $cd_io_tm_arr[2])
      {
        $sm_wrt_lat += $cd_value[$i];
      } 
      if ($cd_metric[$i] eq $cd_io_tm_arr[3])
      {
        $lg_wrt_lat += $cd_value[$i];
      }
      if ($cd_metric[$i] eq $cd_rq_arr[0] ||
          $cd_metric[$i] eq $cd_rq_arr[2])
      {
        $cd_siops += $cd_value[$i];
      }
      if ($cd_metric[$i] eq $cd_rq_arr[1] ||
          $cd_metric[$i] eq $cd_rq_arr[3])
      {
        $cd_liops += $cd_value[$i];
      }
      if ($cd_metric[$i] eq $cd_xput_arr[0] ||
          $cd_metric[$i] eq $cd_xput_arr[1] ||
          $cd_metric[$i] eq $cd_xput_arr[2] ||
          $cd_metric[$i] eq $cd_xput_arr[3])
      {
        $xput_sum += $cd_value[$i];
      }
    }
  }

  #Convert to milli seconds and weighted average across all celldisks
  if ($cdm)
  {
    $lg_rd_lat = ($lg_rd_lat / (1000 * $cdisk_size));
    $sm_rd_lat = ($sm_rd_lat / (1000 * $cdisk_size));
    $lg_wrt_lat = ($lg_wrt_lat / (1000 * $cdisk_size));
    $sm_wrt_lat = ($sm_wrt_lat / (1000 * $cdisk_size));
  }

  $lg_rd_lat = sprintf "%.2f", $lg_rd_lat;
  $sm_rd_lat = sprintf "%.2f", $sm_rd_lat;
  $lg_wrt_lat = sprintf "%.2f", $lg_wrt_lat;
  $sm_wrt_lat = sprintf "%.2f", $sm_wrt_lat;

  if ($show_summary_stats)
  {
    print "Cell Total Disk Throughput: MBPS=".$xput_sum."\n";
    print "Cell Total Small I/O's:     IOPS=".$cd_siops."\n";
    print "Cell Total Large I/O's:     IOPS=".$cd_liops."\n";
  }

  if ($show_lat_stats && 
      ($lg_rd_lat ne "0.00" || $lg_wrt_lat ne "0.00" 
       || $sm_rd_lat ne "0.00" || $sm_wrt_lat ne "0.00"))
  {
    print "\nCell Avg small read latency:  $sm_rd_lat ms\n";
    print "Cell Avg small write latency: $sm_wrt_lat ms\n";
    print "Cell Avg large read latency:  $lg_rd_lat ms\n";
    print "Cell Avg large write latency: $lg_wrt_lat ms\n";
  }
  $time = 0;
}

