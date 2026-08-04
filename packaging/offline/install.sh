#!/usr/bin/env bash
# ORA BRABO - instalacao OFFLINE (air-gapped).
# Cria o venv e instala TODAS as dependencias a partir dos wheels locais (sem internet).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WHEELS="$HERE/wheels"
APP="$HERE/ora_brabo"

# Descobre o Python nesta ordem:
#   1) variavel PYTHON=...        (voce aponta manualmente)
#   2) ../python/bin/python3      (python portatil extraido ao lado do pacote)
#   3) python3.11 do sistema
if [ -n "${PYTHON:-}" ]; then
  PY="$PYTHON"
elif [ -x "$HERE/../python/bin/python3" ]; then
  PY="$HERE/../python/bin/python3"
elif command -v python3.11 >/dev/null 2>&1; then
  PY="python3.11"
else
  echo "ERRO: Python 3.10+ nao encontrado."
  echo "  - extraia o python portatil ao lado do pacote (../python), ou"
  echo "  - rode apontando o interpretador:  PYTHON=/caminho/para/python3 bash install.sh"
  exit 1
fi

echo "-> Python: $("$PY" --version 2>&1)  ($PY)"
if [ -d "$APP/.venv" ]; then
  echo "AVISO: ja existe $APP/.venv . Para recriar do zero use:  bash reinstall.sh"
fi

cd "$APP"
"$PY" -m venv .venv
.venv/bin/python -m pip install --no-index --find-links "$WHEELS" --upgrade pip setuptools wheel
.venv/bin/pip install --no-index --find-links "$WHEELS" -r requirements.txt -r requirements-optional.txt

echo ""
echo "OK! venv em $APP/.venv"
echo "Testar sem banco:  cd \"$APP\" && .venv/bin/python app.py --demo"
echo "Conectar:          .venv/bin/python app.py --host <ip> --service <svc> --user <u> --password <senha> [--sysdba]"
