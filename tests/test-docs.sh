#!/usr/bin/env bash
# memory-graphify/19 — versão 0.4.0, READMEs e PRD falam MEMORY + Graphify; blocos de código idênticos EN/PT.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' < "$j" 2>/dev/null && ok || ko "$j JSON inválido"
  assert_contains "$(cat "$j")" '"version": "0.4.0"' "/19 $j versão 0.4.0"
done
assert_contains "$(cat .claude-plugin/plugin.json)" '"graphify"' "/19 keyword graphify"
en="$(cat README.md)"; pt="$(cat README.pt-BR.md)"
assert_contains "$en" '## Renamed in 0.4.0' "/19 seção 0.4.0 EN"
assert_contains "$pt" '## Renomeado em 0.4.0' "/19 seção 0.4.0 PT"
for s in 'MEMORY.md' '`memory`' 'docs/audora/memory/' 'graphify-out/' 'uv tool install graphifyy' 'memory-validate'; do
  assert_contains "$en" "$s" "/19 README EN cita $s"; assert_contains "$pt" "$s" "/19 README PT cita $s"
done
assert_not_contains "$en" 'Renamed in 0.3.0' "/1 seção 0.3.0 removida (tabela grafo)"
blocos() { awk '/^```/{f=!f; next} f' "$1"; }
assert_eq "$(blocos README.md | md5sum)" "$(blocos README.pt-BR.md | md5sum)" "/19 blocos de código idênticos EN/PT"
p="$(cat PRD.md)"
for s in 'MEMORY.md' 'memory-guard' 'memory-validate' 'graphify-status' 'Graphify' 'tests/' '0.4.0'; do assert_contains "$p" "$s" "/19 PRD cita $s"; done
report
