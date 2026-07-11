#!/usr/bin/env bash
# shell/collect_dg.sh
# Run dgmgrl show configuration and output plain text.

set -euo pipefail

ORACLE_HOME=${ORACLE_HOME:-/u01/app/oracle/product/19.3.0/dbhome_1}
export ORACLE_HOME PATH="$ORACLE_HOME/bin:$PATH"

TNS_ALIAS=${1:-""}
DG_USER=${2:-"sys"}
DG_PASS=${3:-""}

dgmgrl -silent "${DG_USER}/${DG_PASS}@${TNS_ALIAS}" <<EOF 2>/dev/null
show configuration verbose;
show database verbose;
EOF
