#!/usr/bin/env bash
# Instalador do plugin audora-commander a partir de uma cópia local deste
# repositório (clonado ou baixado). Requer a Claude Code CLI (comando
# `claude`) já instalada.
#
# Uso: ./install.sh  (rode de dentro da pasta do repo, ou via install.cmd
# no Windows nativo)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKETPLACE="audora-commander-dev"
PLUGIN="audora-commander@${MARKETPLACE}"

if [ ! -f "${SCRIPT_DIR}/.claude-plugin/plugin.json" ]; then
    echo "Erro: não achei .claude-plugin/plugin.json ao lado deste script." >&2
    echo "Rode install.sh de dentro da pasta onde o repo audora-commander foi clonado." >&2
    exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
    echo "Erro: comando 'claude' (Claude Code CLI) não encontrado no PATH." >&2
    echo "Instale a Claude Code CLI antes de rodar este script." >&2
    exit 1
fi

echo "Adicionando marketplace local (${SCRIPT_DIR})..."
claude plugin marketplace add "${SCRIPT_DIR}"

echo "Instalando plugin ${PLUGIN}..."
claude plugin install "${PLUGIN}"

cat <<EOF

Instalação concluída.

Próximos passos:
  1. Reinicie sua sessão do Claude Code (ou rode /clear) — o hook de
     SessionStart passa a injetar o ponteiro do framework.
  2. Rode o "Checklist de validação da instalação" no README.md.
EOF
