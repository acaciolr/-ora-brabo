export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1

export ORACLE_SID=WHPRO1301
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/levanta_mes.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/movmens.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/levanta_bkp_mes.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/rel_aloasmdg.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/levanta_size_db_mes.sql
echo $ORACLE_SID
. /home/oracle/.profile WHPRE130
echo $ORACLE_SID
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/movmens.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/levanta_bkp_mes.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/levanta_size_db_mes.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/rel_aloasmdg.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/levanta_size_db_mes.sql
echo $ORACLE_SID
. /home/oracle/.profile WHCAR130
echo $ORACLE_SID
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/movmens.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/levanta_bkp_mes.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/levanta_size_db_mes.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/rel_aloasmdg.sql
/u01/app/oracle/product/12.1.0.2/dbhome_1/bin/sqlplus / as sysdba @/home/oracle/scripts/levanta_size_db_mes.sql
