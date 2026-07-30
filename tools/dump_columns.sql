-- ============================================================================
-- ORA BRABO — dump de colunas das views/tabelas usadas pelos collectors
-- ----------------------------------------------------------------------------
-- OBJETIVO: listar TODAS as colunas reais (no SEU banco) de cada objeto que as
-- queries usam, para validar de uma vez se alguma coluna referenciada não
-- existe nesta versão/edição (ADB).
--
-- COMO USAR no SQL Developer:
--   1. Conecte com o mesmo usuário do app (admin).
--   2. Rode este script (F5).
--   3. Na grade de resultados: botão direito -> Export -> CSV
--      salve como:  <pasta do projeto>/docs/db_columns.csv
--   4. Me avise que o CSV está lá — eu comparo com o que as queries usam e
--      devolvo/ conserto todas as colunas inválidas.
--
-- Observação: nomes V$/GV$ aparecem no dicionário como V_$ / GV_$ (a forma
-- V$xxx é sinônimo público). Este script já usa a forma V_$ / GV_$.
-- ============================================================================

SELECT table_name, column_name, data_type, column_id
FROM   dba_tab_columns
WHERE  table_name IN (
    -- ---- V$ (fixed views) ----
    'V_$ASM_DISK','V_$ASM_DISKGROUP','V_$RECOVERY_FILE_DEST',
    'V_$FLASH_RECOVERY_AREA_USAGE','V_$ARCHIVED_LOG',
    'V_$DIAG_ALERT_EXT','V_$DIAG_PROBLEM','V_$DIAG_INCIDENT',
    'V_$DATABASE','V_$DATAGUARD_STATS','V_$MANAGED_STANDBY',
    'V_$ARCHIVE_DEST_STATUS','V_$ARCHIVE_GAP','V_$LOG_HISTORY',
    'V_$CELL_CONFIG','V_$SYSSTAT','V_$SESSION','V_$SGASTAT','V_$PGASTAT',
    'V_$OSSTAT','V_$FILESTAT','V_$DATAFILE','V_$TABLESPACE',
    'V_$IOSTAT_FUNCTION','V_$SYSMETRIC','V_$LOG','V_$LOGFILE','V_$UNDOSTAT',
    'V_$SGA_TARGET_ADVICE','V_$PGA_TARGET_ADVICE','V_$BUFFER_POOL_STATISTICS',
    'V_$DB_CACHE_ADVICE','V_$PARAMETER','V_$MEMORY_RESIZE_OPS','V_$LATCH',
    'V_$MUTEX_SLEEP','V_$PDBS','V_$SEGMENT_STATISTICS','V_$WAIT_CHAINS',
    'V_$RMAN_STATUS','V_$BACKUP_SET_DETAILS','V_$SQLAREA','V_$SQL_MONITOR',
    'V_$SQL_PLAN_MONITOR',
    -- ---- GV$ (global fixed views) ----
    'GV_$ACTIVE_SESSION_HISTORY','GV_$MANAGED_STANDBY','GV_$SQL',
    'GV_$SYSTEM_EVENT','GV_$PARAMETER','GV_$SESSION','GV_$INSTANCE',
    'GV_$SYSSTAT','GV_$CLUSTER_INTERCONNECTS','GV_$ACTIVE_SERVICES',
    'GV_$PX_SESSION','GV_$SESSION_LONGOPS','GV_$BACKUP_ASYNC_IO',
    'GV_$BACKUP_SYNC_IO','GV_$SQL_MONITOR','GV_$LOCK','GV_$PROCESS',
    'GV_$LOCKED_OBJECT',
    -- ---- DBA_/CDB_ (data dictionary) ----
    'DBA_HIST_SNAPSHOT','DBA_ADVISOR_TASKS','DBA_ADVISOR_FINDINGS',
    'DBA_HIST_SQLSTAT','DBA_HIST_SQLTEXT','DBA_HIST_SYSTEM_EVENT',
    'DBA_HIST_SYSSTAT','DBA_TABLESPACES','DBA_DATA_FILES','DBA_FREE_SPACE',
    'DBA_TABLES','DBA_UNDO_EXTENTS','DBA_SEGMENTS','DBA_TAB_STATISTICS',
    'DBA_TAB_MODIFICATIONS','DBA_SCHEDULER_JOBS','DBA_SCHEDULER_JOB_RUN_DETAILS',
    'DBA_SQL_PLAN_BASELINES','DBA_OBJECTS','DBA_SERVICES',
    'CDB_TABLESPACES','CDB_DATA_FILES','CDB_FREE_SPACE'
)
ORDER BY table_name, column_id;

-- Bônus: objetos da lista que NÃO existem/estão inacessíveis para você
-- (ex.: views de Exadata ou ADR bloqueadas no ADB). Rode junto:
--
-- SELECT t.name AS objeto_ausente_ou_sem_privilegio
-- FROM (
--   SELECT column_value AS name FROM TABLE(sys.odcivarchar2list(
--     'V_$WAIT_CHAINS','V_$CELL_CONFIG','V_$DIAG_ALERT_EXT','V_$SQL_MONITOR'
--   ))
-- ) t
-- WHERE NOT EXISTS (SELECT 1 FROM dba_tab_columns c WHERE c.table_name = t.name);
