#!/usr/bin/env bash
# relatorio-entrega — decidido o portão, a validate fecha o turno com o
# relatório de entrega (7 seções, regras) em toda categoria e toda decisão.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# sec <arquivo> '<cabeçalho exato>' → corpo da seção, sem \r (checkout CRLF)
sec() { tr -d '\r' 2>/dev/null < "$1" | awk -v h="$2" '$0==h{f=1;next} /^## /{f=0} f'; }
# flat <arquivo> [cabeçalho] → texto (da seção, se dado) sem \r, numa linha só,
# espaços colapsados: frase que quebra linha no Markdown ainda casa.
flat() {
  if [ -n "${2:-}" ]; then
    tr -d '\r' 2>/dev/null < "$1" | awk -v h="$2" '$0==h{f=1;next} /^## /{f=0} f'
  else
    tr -d '\r' 2>/dev/null < "$1"
  fi | tr '\n' ' ' | tr -s ' '
}

# --- fechamento LIGHT — relatório sai igual; decisões da IA só do nó (sem plano) ---
L=skills/validate/references/fechamento-light.md
l="$(flat "$L")"
for s in '**Relatório de entrega**' 'sai igual, com todas as seções, em LIGHT'; do
  assert_contains "$l" "$s" "relatorio-entrega/1 LIGHT imprime o relatório"
done
assert_contains "$l" 'vêm só das linhas `(IA` do `## decisoes` do nó' "relatorio-entrega/6 LIGHT: decisões da IA só do nó"
for s in 'HOTFIX não usa este caminho' 'silêncio sobre o PRD é proibido'; do
  assert_contains "$l" "$s" "relatorio-entrega/1 regressão: LIGHT mantém '$s'"
done
report
