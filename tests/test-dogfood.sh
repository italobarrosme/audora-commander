#!/usr/bin/env bash
# dogfood — este repositório usa MEMORY.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
assert_file MEMORY.md "/9 MEMORY.md"
assert_eq "memory-schema: 1" "$(head -1 MEMORY.md | tr -d '\r')" "/9 schema"
m="$(cat MEMORY.md)"
assert_contains "$m" '## Aprendizados [carga: sempre]' "/9 Aprendizados"
for id in plugin-v0.1.0 skill-memory comandos-ingles grafo-v2 docs-bilingues e2e-playwright-docker skill-depurar memory-inicio-fim skill-poc porte-multi-harness marketplace-publico agentes-dedicados; do
  grep -q "^- $id |" MEMORY.md && ok || ko "/9 índice perdeu $id"
done
grep -q '^- skill-memory | discarded |' MEMORY.md && ok || ko "/9 skill-memory discarded"
assert_file docs/audora/arquivo/2026-09-27-plugin-v0.1.0.md "limpeza-codigo-morto/5 plugin-v0.1.0 arquivado"
run_hook memory-validate "$ROOT/MEMORY.md"; assert_eq 0 "$code" "/9 memory-validate verde"; assert_empty "$out" "/9 stderr vazio"
run_hook memory-guard "$ROOT/MEMORY.md";    assert_eq 0 "$code" "/9 memory-guard verde"
report
