#!/usr/bin/env bash
# memory-graphify/4,/5 — templates do MEMORY existem com as seções/campos do schema.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
t="$(cat templates/MEMORY-template.md 2>/dev/null)"
assert_eq "memory-schema: 1" "$(head -1 templates/MEMORY-template.md 2>/dev/null | tr -d '\r')" "/4 linha 1"
for sec in '## Propósito [carga: sempre]' '## Constituição [carga: sempre]' '## Aprendizados [carga: sempre]' '## Índice de nós [carga: sempre]'; do
  assert_contains "$t" "$sec" "/4 seção $sec"
done
assert_contains "$t" '**graphify**:' "/4 bullet graphify na Constituição"
assert_contains "$t" 'docs/audora/memory/<id>.md' "/5 caminho do nó"
assert_contains "$t" '| <fase> | <aprendizado' "/6 formato de aprendizado"
n="$(cat templates/no-template.md)"
for campo in '^id:' '^estado:' '^origem:' '^depende-de:' '^arquivos:' '^keywords:' '^resumo:' '^atualizado-em:'; do
  printf '%s\n' "$n" | grep -qE "$campo" && ok || ko "/5 frontmatter $campo"
done
assert_contains "$n" 'exemplo-login/1' "/5 critério numerado"
assert_not_contains "$n" 'PT→EN' "/5 sem migração PT→EN"
assert_no_file templates/GRAFO-template.md "/1 GRAFO-template removido"
assert_no_file templates/GRAFO-template-v1.md "/1 GRAFO-template-v1 removido"
assert_empty "$(grep -rli grafo templates || true)" "/1 zero grafo em templates"
report
