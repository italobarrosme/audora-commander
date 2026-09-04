#!/usr/bin/env bash
# memory-graphify/19 — versão 0.4.0, READMEs e PRD falam MEMORY + Graphify; blocos de código idênticos EN/PT.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' < "$j" 2>/dev/null && ok || ko "$j JSON inválido"
  assert_contains "$(cat "$j")" '"version": "0.7.0"' "/19 $j versão 0.7.0"
done
assert_contains "$(cat .claude-plugin/plugin.json)" '"graphify"' "/19 keyword graphify"
en="$(cat README.md)"; pt="$(cat README.pt-BR.md)"
assert_contains "$en" '## Renamed in 0.4.0' "/19 seção 0.4.0 EN"
assert_contains "$pt" '## Renomeado em 0.4.0' "/19 seção 0.4.0 PT"
for s in 'MEMORY.md' '`memory`' 'docs/audora/memory/' 'graphify-out/' 'uv tool install graphifyy' 'memory-validate'; do
  assert_contains "$en" "$s" "/19 README EN cita $s"; assert_contains "$pt" "$s" "/19 README PT cita $s"
done
assert_not_contains "$en" 'Renamed in 0.3.0' "/1 seção 0.3.0 removida (tabela grafo)"
assert_contains "$en" '| `worktree` |' "skill-worktree/1 README EN lista worktree"
assert_contains "$pt" '| `worktree` |' "skill-worktree/1 README PT lista worktree"
assert_contains "$en" 'The 9 skills' "skill-worktree/1 README EN diz 9 skills"
assert_contains "$pt" 'As 9 skills' "skill-worktree/1 README PT diz 9 skills"
assert_empty "$(grep -rn '8 skills' README.md README.pt-BR.md PRD.md 2>/dev/null)" "skill-worktree/1 zero '8 skills' residual"
blocos() { awk '/^```/{f=!f; next} f' "$1"; }
assert_eq "$(blocos README.md | md5sum)" "$(blocos README.pt-BR.md | md5sum)" "/19 blocos de código idênticos EN/PT"
p="$(cat PRD.md)"
for s in 'MEMORY.md' 'memory-guard' 'memory-validate' 'graphify-status' 'Graphify' 'tests/' '0.4.0'; do assert_contains "$p" "$s" "/19 PRD cita $s"; done
# docs-permissoes/1,/2,/3 — READMEs ensinam a reduzir prompts de permissão do harness.
assert_contains "$en" '## Reducing permission prompts' "docs-permissoes/1 README EN tem a seção"
assert_contains "$pt" '## Reduzindo prompts de permissão' "docs-permissoes/2 README PT tem a seção"
for s in 'permissions.allow' '--permission-mode' 'acceptEdits' 'bypassPermissions'; do
  assert_contains "$en" "$s" "docs-permissoes/1 README EN cita $s"
  assert_contains "$pt" "$s" "docs-permissoes/2 README PT cita $s"
done
for s in '**Low**' '**Medium**' '**High**'; do
  assert_contains "$en" "$s" "docs-permissoes/1 README EN gradua risco $s"
done
for s in '**Baixo**' '**Médio**' '**Alto**'; do
  assert_contains "$pt" "$s" "docs-permissoes/2 README PT gradua risco $s"
done
assert_contains "$en" 'sandbox or a disposable worktree' "docs-permissoes/3 README EN restringe bypass a sandbox/worktree"
assert_contains "$pt" 'sandbox ou worktree descartável' "docs-permissoes/3 README PT restringe bypass a sandbox/worktree"
assert_contains "$en" 'the real block is permission' "docs-permissoes/3 README EN avisa que bloqueio real é permissão"
assert_contains "$pt" 'bloqueio real é permissão' "docs-permissoes/3 README PT avisa que bloqueio real é permissão"
# memory-fatiada/6,/8 — Constituição cobre references; READMEs mostram o layout novo.
assert_contains "$(cat MEMORY.md)" 'skills/*/references/' "/6 Constituição cobre references"
for r in README.md README.pt-BR.md; do
  assert_contains "$(cat "$r")" 'skills/memory/references/' "/8 $r cita references/"
done
report
