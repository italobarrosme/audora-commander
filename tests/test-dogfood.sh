#!/usr/bin/env bash
# memory-graphify/9,/12 — este repositório usa MEMORY + Graphify.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
assert_file MEMORY.md "/9 MEMORY.md"
assert_eq "memory-schema: 1" "$(head -1 MEMORY.md | tr -d '\r')" "/9 schema"
m="$(cat MEMORY.md)"
assert_contains "$m" '## Aprendizados [carga: sempre]' "/9 Aprendizados"
assert_contains "$m" '**graphify**: ativo' "/12 Constituição graphify ativo"
for id in plugin-v0.1.0 memory-graphify skill-memory comandos-ingles grafo-v2 docs-bilingues e2e-playwright-docker skill-depurar memory-inicio-fim skill-poc porte-multi-harness marketplace-publico agentes-dedicados; do
  grep -q "^- $id |" MEMORY.md && ok || ko "/9 índice perdeu $id"
done
grep -q '^- skill-memory | discarded |' MEMORY.md && ok || ko "/9 skill-memory discarded"
assert_file docs/audora/memory/memory-graphify.md "/9 nó em memory/"
run_hook memory-validate "$ROOT/MEMORY.md"; assert_eq 0 "$code" "/9 memory-validate verde"; assert_empty "$out" "/9 stderr vazio"
run_hook memory-guard "$ROOT/MEMORY.md";    assert_eq 0 "$code" "/9 memory-guard verde"
grep -q '^graphify-out/$' .gitignore && ok || ko "/12 gitignore"
if command -v graphify >/dev/null; then
  assert_eq "ativo" "$(bash hooks/graphify-status .)" "/12 status ativo"
  assert_contains "$(graphify hook status 2>&1)" 'post-commit: installed' "/12 git hook instalado"
fi
report
