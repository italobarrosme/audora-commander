#!/usr/bin/env bash
# corte-sem-uso/5..10 — o plugin não carrega mais Graphify, autopilot, motor de loop nem a skill worktree.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# lista_com <ERE> <caminho>... → arquivos que casam (case-insensitive)
lista_com() { local e="$1"; shift; grep -rliE -- "$e" "$@" 2>/dev/null; }

# --- /5 Graphify fora da superfície; limpeza e seu teste não existem ---
assert_empty "$(lista_com 'graphify' skills templates hooks .claude-plugin README.md README.pt-BR.md docs/fundamentos.md)" "corte-sem-uso/5 superfície sem Graphify"
assert_no_file hooks/graphify-limpeza "corte-sem-uso/5 script de limpeza removido"
assert_no_file tests/test-graphify-limpeza.sh "corte-sem-uso/11 teste da limpeza removido"
cc="$(tr -d '\r' < skills/memory/SKILL.md | awk '/^### 1\. carregar-contexto/{f=1;next} /^### /{f=0} f')"
assert_not_contains "$cc" 'Restos do' "corte-sem-uso/5 carregar-contexto sem oferta de limpeza"
assert_contains "$cc" 'ofertar UMA vez gerar o gate' "corte-sem-uso/5 carregar-contexto mantém a oferta do gate"
grep -qsi graphify .git/hooks/post-commit .git/hooks/post-checkout && ko "corte-sem-uso/5 hook de git do repo cita graphify" || ok
assert_no_file graphify-out "corte-sem-uso/5 repo sem graphify-out"

report
