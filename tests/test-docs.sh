#!/usr/bin/env bash
# docs — versão, READMEs e PRD falam MEMORY; blocos de código idênticos EN/PT.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' < "$j" 2>/dev/null && ok || ko "$j JSON inválido"
  assert_contains "$(cat "$j")" '"version": "0.16.0"' "skill-cleanup $j declara 0.16.0 (substitui leitura-por-secao/12)"
done
en="$(cat README.md)"; pt="$(cat README.pt-BR.md)"
for s in 'MEMORY.md' '`memory`' 'docs/audora/memory/' 'memory-validate'; do
  assert_contains "$en" "$s" "/19 README EN cita $s"; assert_contains "$pt" "$s" "/19 README PT cita $s"
done
blocos() { awk '/^```/{f=!f; next} f' "$1"; }
assert_eq "$(blocos README.md | md5sum)" "$(blocos README.pt-BR.md | md5sum)" "/19 blocos de código idênticos EN/PT"
p="$(cat PRD.md)"
for s in 'MEMORY.md' 'memory-guard' 'memory-validate' 'tests/'; do assert_contains "$p" "$s" "/19 PRD cita $s"; done
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
# readme-skills/1,/2,/3 — toda skill de skills/ tem subseção com os 5 rótulos nos 2 READMEs
sec() { awk -v h="### \`$2\`" '$0==h{f=1;next} /^##/{f=0} f' "$1"; }
for d in skills/*/; do
  s="$(basename "$d")"
  sen="$(sec README.md "$s")"; spt="$(sec README.pt-BR.md "$s")"
  [ -n "$sen" ] && ok || ko "readme-skills/3 README.md sem subseção da skill $s"
  [ -n "$spt" ] && ok || ko "readme-skills/3 README.pt-BR.md sem subseção da skill $s"
  for l in '**When it fires**' '**What it does**' '**What it leaves on disk**' '**Human gates**' '**Next**'; do
    assert_contains "$sen" "$l" "readme-skills/1 $s EN tem $l"
  done
  for l in '**Quando dispara**' '**O que faz**' '**O que deixa no disco**' '**Portões humanos**' '**Próxima**'; do
    assert_contains "$spt" "$l" "readme-skills/2 $s PT tem $l"
  done
done
# readme-skills/5 — a tabela-resumo continua e linka o detalhe
assert_contains "$(cat README.md)" '## Skills in detail' "readme-skills/5 EN tem a seção"
assert_contains "$(cat README.pt-BR.md)" '## As skills em detalhe' "readme-skills/5 PT tem a seção"
assert_contains "$(cat README.md)" '(#skills-in-detail)' "readme-skills/5 tabela EN linka o detalhe"
assert_contains "$(cat README.pt-BR.md)" '(#as-skills-em-detalhe)' "readme-skills/5 tabela PT linka o detalhe"
# validate-estado-no/8 — READMEs listam a checagem de estado nos arquivos de nó
assert_contains "$(cat README.md)" 'state in each node file' "validate-estado-no/8 README EN cita estado no nó"
assert_contains "$(cat README.pt-BR.md)" 'estado em cada arquivo de nó' "validate-estado-no/8 README PT cita estado no nó"
report
