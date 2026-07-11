#!/usr/bin/env bash
# ORA BRABO launcher
# Usa o virtualenv do projeto (.venv/) se existir; caso contrário usa python3 do sistema.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PYTHON="$SCRIPT_DIR/.venv/bin/python"

cd "$SCRIPT_DIR"

if [[ -x "$VENV_PYTHON" ]]; then
    exec "$VENV_PYTHON" app.py "$@"
else
    # Fallback: sistema — tenta instalar se textual não encontrado
    if ! python3 -c "import textual" 2>/dev/null; then
        echo "ORA BRABO: dependências não encontradas."
        echo "Execute: bash $SCRIPT_DIR/install.sh"
        exit 1
    fi
    exec python3 app.py "$@"
fi
