#!/usr/bin/env bash
# shell/collect_asm.sh
# Query ASM diskgroups via asmcmd when +ASM instance is local.

set -euo pipefail

ORACLE_HOME=${ORACLE_HOME:-/u01/app/oracle/product/19.3.0/dbhome_1}
ASM_HOME=${ASM_HOME:-/u01/app/19.3.0/grid}
export ORACLE_HOME PATH="$ASM_HOME/bin:$ORACLE_HOME/bin:$PATH"
export ORACLE_SID="+ASM"

asmcmd lsdg 2>/dev/null || echo "asmcmd not available or +ASM not local"
