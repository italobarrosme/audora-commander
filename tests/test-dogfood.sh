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
# memoria-integra/18 — MEMORY deste repo sem linha de aprendizado; todas em docs/audora/aprendizados.md
APR='^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| '
assert_eq 0 "$(grep -cE "$APR" MEMORY.md)" "memoria-integra/18 MEMORY sem linha de aprendizado"
assert_eq 'Aprendizados vivem em `docs/audora/aprendizados.md` (1 linha cada, só por grep — skill memory, registrar-aprendizado).' \
  "$(tr -d '\r' < MEMORY.md | awk '/^## Aprendizados/{on=1; next} on && /^## /{on=0} on && NF')" "memoria-integra/18 seção Aprendizados só com o ponteiro"
antigas="$(git show 684abc9:MEMORY.md | tr -d '\r' | grep -E "$APR")"
assert_eq 53 "$(printf '%s\n' "$antigas" | grep -c .)" "memoria-integra/18 base: 53 aprendizados no MEMORY de 684abc9"
assert_eq "$antigas" "$(tr -d '\r' 2>/dev/null < docs/audora/aprendizados.md | grep -xF -f <(printf '%s\n' "$antigas"))" "memoria-integra/18 as 53 linhas em aprendizados.md, mesma ordem, nenhuma faltando"
assert_contains "$(cat docs/audora/aprendizados.md 2>/dev/null)" '| scope | Princípio da cleanup (humano):' "memoria-integra/18 aprendizado do scope desta demanda migrado"
report
