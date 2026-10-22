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

# --- validate — aponta o relatório após qualquer decisão do portão, última parte do turno ---
V=skills/validate/SKILL.md
v="$(flat "$V" '## Bloco de fechamento')"
assert_contains "$v" '**Próximo**: aprovada, nenhum — o fluxo encerra; reprovada ou parcial, a decisão humana ou a fase de retorno (scope ou plan).' "relatorio-entrega/9 validate: Próximo cobre reprovação e parcial"
assert_contains "$v" 'Decidido o portão — aprovado, parcial ou reprovado, em toda categoria —, o bloco de fase é seguido do relatório de **Entrega**' "relatorio-entrega/1 validate aponta o relatório em toda decisão e categoria"
assert_contains "$v" 'última parte da resposta: nenhuma ferramenta depois dele' "relatorio-entrega/11 validate: relatório fecha o turno"
assert_contains "$v" 'arquivos tocados do `git diff --numstat`' "relatorio-entrega/8 validate: arquivos tocados do numstat"
for s in 'Aprovada, o bloco de fase é seguido do bloco **Entrega**' 'git diff --name-only'; do
  assert_not_contains "$v" "$s" "relatorio-entrega/1 regressão: texto antigo da validate"
done
assert_contains "$v" '`PRD.md` atualizado e `CHANGELOG.md` com a linha da entrega' "relatorio-entrega/1 regressão: bloco Arquivos da validate mantido"

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
