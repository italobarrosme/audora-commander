#!/usr/bin/env bash
# memory-graphify/9; remover-graphify/12 — este repositório usa MEMORY, sem resto do Graphify.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
assert_file MEMORY.md "/9 MEMORY.md"
assert_eq "memory-schema: 1" "$(head -1 MEMORY.md | tr -d '\r')" "/9 schema"
m="$(cat MEMORY.md)"
assert_contains "$m" '## Aprendizados [carga: sempre]' "/9 Aprendizados"
assert_not_contains "$m" '**graphify**:' "remover-graphify/12 Constituição sem bullet graphify"
for id in plugin-v0.1.0 memory-graphify skill-memory comandos-ingles grafo-v2 docs-bilingues e2e-playwright-docker skill-depurar memory-inicio-fim skill-poc porte-multi-harness marketplace-publico agentes-dedicados; do
  grep -q "^- $id |" MEMORY.md && ok || ko "/9 índice perdeu $id"
done
grep -q '^- skill-memory | discarded |' MEMORY.md && ok || ko "/9 skill-memory discarded"
assert_file docs/audora/arquivo/2026-09-27-memory-graphify.md "limpeza-codigo-morto/5 memory-graphify arquivado"; assert_file docs/audora/arquivo/2026-09-27-plugin-v0.1.0.md "limpeza-codigo-morto/5 plugin-v0.1.0 arquivado"
run_hook memory-validate "$ROOT/MEMORY.md"; assert_eq 0 "$code" "/9 memory-validate verde"; assert_empty "$out" "/9 stderr vazio"
run_hook memory-guard "$ROOT/MEMORY.md";    assert_eq 0 "$code" "/9 memory-guard verde"
grep -q 'graphify-out' .gitignore && ko "remover-graphify/12 .gitignore ainda cita graphify-out" || ok
assert_empty "$(bash hooks/graphify-limpeza .)" "remover-graphify/12 repo sem resto do Graphify"
for t in '_PINNED' 'O post-commit do Graphify' 'e `graphify` não estão no PATH'; do
  assert_contains "$(grep -F -- "$t" MEMORY.md)" '[invalidado-em: 2026-09-29]' "remover-graphify/12 aprendizado '$t' invalidado, não apagado"
done
report
