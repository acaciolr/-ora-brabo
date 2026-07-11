#!/usr/bin/env bash
# shell/collect_rac.sh
# Collect RAC node info via srvctl/crsctl when available on the OS.
# Output: JSON to stdout

set -euo pipefail

ORACLE_HOME=${ORACLE_HOME:-/u01/app/oracle/product/19.3.0/dbhome_1}
export ORACLE_HOME PATH="$ORACLE_HOME/bin:$PATH"

DB_NAME=${1:-""}

echo "{"
echo "  \"srvctl_status\": \""
srvctl status database -d "$DB_NAME" 2>/dev/null | tr '\n' '|' || echo "N/A"
echo "\","
echo "  \"crsctl_check\": \""
crsctl check cluster -all 2>/dev/null | tr '\n' '|' || echo "N/A"
echo "\","
echo "  \"olsnodes\": \""
olsnodes -n 2>/dev/null | tr '\n' '|' || echo "N/A"
echo "\""
echo "}"
