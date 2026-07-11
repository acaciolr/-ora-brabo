#!/usr/bin/env bash
# ORA BRABO — Instalador
# Cria virtualenv isolado e instala dependências.
# Também adiciona o alias `ora_brabo` ao ~/.zshrc (ou ~/.bashrc).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
SHELL_RC=""

# ── Detectar shell ──────────────────────────────────────────────────
if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == */bash ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ORA BRABO — Instalação                 ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Virtualenv ──────────────────────────────────────────────────────
if [[ ! -d "$VENV_DIR" ]]; then
    echo "→ Criando virtualenv em $VENV_DIR ..."
    python3 -m venv "$VENV_DIR"
else
    echo "→ Virtualenv já existe em $VENV_DIR"
fi

# ── Dependências ────────────────────────────────────────────────────
echo "→ Instalando dependências..."
"$VENV_DIR/bin/pip" install --upgrade pip -q
"$VENV_DIR/bin/pip" install -r "$SCRIPT_DIR/requirements.txt"

echo "→ Dependências instaladas:"
"$VENV_DIR/bin/pip" show oracledb textual rich 2>/dev/null | grep -E "^(Name|Version):" | paste - -

# ── Alias ───────────────────────────────────────────────────────────
ALIAS_LINE="alias ora_brabo='\"$SCRIPT_DIR/ora_brabo.sh\"'"

if [[ -n "$SHELL_RC" ]]; then
    if grep -q "ora_brabo" "$SHELL_RC" 2>/dev/null; then
        echo "→ Alias ora_brabo já existe em $SHELL_RC"
    else
        echo "" >> "$SHELL_RC"
        echo "# ── ORA BRABO ──────────────────────────────────────────────────────" >> "$SHELL_RC"
        echo "$ALIAS_LINE" >> "$SHELL_RC"
        echo "→ Alias adicionado em $SHELL_RC"
    fi
else
    echo "→ Shell não identificado. Adicione manualmente ao seu rc:"
    echo "   $ALIAS_LINE"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Instalação concluída!                  ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  Recarregue o shell:   source $SHELL_RC"
echo "  Ou execute direto:    $SCRIPT_DIR/ora_brabo.sh"
echo ""
