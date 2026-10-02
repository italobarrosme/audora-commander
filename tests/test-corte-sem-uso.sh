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
# --- /6 autopilot e motor fora de skills, templates e docs; portões do meio sempre humanos ---
assert_empty "$(lista_com 'autopilot|motor|hooks/loop|loop-prompt|elegiv|elegív|antecipad|paradas humanas' skills templates)" "corte-sem-uso/6 skills e templates sem autopilot/motor"
assert_empty "$(lista_com 'autopilot|motor de loop|hooks/loop|loop round|rodada do loop' README.md README.pt-BR.md docs/fundamentos.md)" "corte-sem-uso/6 READMEs e fundamentos sem autopilot/motor"
sc="$(tr -d '\r' < skills/scope/SKILL.md)"
assert_contains "$sc" 'ESPERAR aprovação explícita' "corte-sem-uso/6 portão de escopo sempre humano"
assert_not_contains "$sc" 'Exceção' "corte-sem-uso/6 scope sem exceção ao portão"
assert_not_contains "$(tr -d '\r' < templates/no-template.md)" 'autopilot:' "corte-sem-uso/6 template de nó sem campo autopilot:"
# --- /7 motor de loop e seus testes não existem; Constituição sem loop: ---
for f in hooks/loop templates/loop-prompt-template.md tests/test-loop.sh tests/test-autopilot.sh; do
  assert_no_file "$f" "corte-sem-uso/7,11 $f removido"
done
assert_not_contains "$(cat MEMORY.md templates/MEMORY-template.md)" '**loop**:' "corte-sem-uso/7 Constituição sem bullet loop:"
# --- /8 "segue" continua em subagente; template sem motor ---
fs="$(tr -d '\r' < templates/fase-subagente-template.md)"
assert_contains "$fs" 'o humano diz "segue" na PARADA' "corte-sem-uso/8 template cobre o segue"
assert_contains "$fs" 'contexto zerado rodando {{FASE}} de {{ID}}' "corte-sem-uso/8 subagente de contexto zerado"
assert_not_contains "$fs" 'motor' "corte-sem-uso/8 template sem motor"
assert_not_contains "$fs" '{{TAREFA}}' "corte-sem-uso/8 placeholder do fallback do motor fora"
pa="$(tr -d '\r' < templates/bloco-fechamento-template.md | awk '/^## Parada entre fases/{f=1;next} /^## /{f=0} f')"
assert_contains "$pa" 'templates/fase-subagente-template.md' "corte-sem-uso/8 segue aponta o subagente"
# --- /9 9 skills (skill-cleanup somou a cleanup), nenhuma superfície cita a skill worktree ---
assert_eq "9" "$(ls -d skills/*/ | wc -l | tr -d ' ')" "skill-cleanup 9 skills (substitui corte-sem-uso/9 8 skills)"
assert_no_file skills/worktree/SKILL.md "corte-sem-uso/9 skill worktree removida"
assert_no_file tests/test-worktree.sh "corte-sem-uso/11 teste da worktree removido"
assert_empty "$(lista_com 'worktree' skills templates hooks .claude-plugin docs/fundamentos.md)" "corte-sem-uso/9 skills, templates, hooks, manifests e fundamentos sem worktree"
for r in README.md README.pt-BR.md; do
  assert_not_contains "$(tr -d '\r' < "$r")" '| `worktree` |' "corte-sem-uso/9 $r sem a skill worktree na tabela"
  assert_not_contains "$(tr -d '\r' < "$r")" '### `worktree`' "corte-sem-uso/9 $r sem seção worktree"
  assert_empty "$(grep -nE '(^|[^0-9])8 (chained )?skills' "$r")" "skill-cleanup $r sem contagem velha '8 skills'"
done
assert_contains "$(tr -d '\r' < README.md)" '## The 9 skills' "skill-cleanup README EN diz 9 skills (substitui corte-sem-uso/9)"
assert_contains "$(tr -d '\r' < README.pt-BR.md)" '## As 9 skills' "skill-cleanup README PT diz 9 skills (substitui corte-sem-uso/9)"
# --- /10 versão: 0.12.0 superada pela 0.16.0 (skill-cleanup); 0.10.0 segue fora ---
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  assert_contains "$(tr -d '\r' < "$j")" '"version": "0.16.0"' "skill-cleanup $j declara 0.16.0 (substitui leitura-por-secao/12)"
  assert_not_contains "$(tr -d '\r' < "$j")" '"version": "0.10.0"' "corte-sem-uso/10 $j sem 0.10.0"
done

report
