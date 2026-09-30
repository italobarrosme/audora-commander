#!/usr/bin/env bash
# plano-mapa — plano vira mapa; plan, execute e debug localizam código por trecho.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# flat <arquivo> [cabeçalho] → texto (da seção, se dado) sem \r, numa linha só,
# espaços colapsados: frase que quebra linha no Markdown ainda casa.
flat() {
  if [ -n "${2:-}" ]; then
    tr -d '\r' 2>/dev/null < "$1" | awk -v h="$2" '$0==h{f=1;next} /^## /{f=0} f'
  else
    tr -d '\r' 2>/dev/null < "$1"
  fi | tr '\n' ' ' | tr -s ' '
}

# --- /1 /2 /3 — template: tarefa é mapa, asserção exata, leitura por trecho ---
pt="$(flat templates/plano-template.md)"
for s in '**requisito**: `<id>/<n>`' '**ponto de mudança**: `caminho/arquivo.ts:42`' \
         '**teste**: `caminho/arquivo.test.ts` — caso' '**ler**: `caminho/arquivo.ts:30-80`' \
         '**done quando**' 'sem o corpo do teste nem o da implementação'; do
  assert_contains "$pt" "$s" "plano-mapa/1 template tem '$s'"
done
assert_not_contains "$pt" 'código do teste no plano, completo' "plano-mapa/1 template sem o teste completo"
assert_contains "$pt" '**asserções**: `entrada → saída esperada`, uma por caso — só quando o critério não fixa o valor (formato, ordem, mensagem, código de saída, borda)' "plano-mapa/2 template pede asserção exata"
assert_contains "$pt" 'Uma linha por leitura, `caminho:início-fim`' "plano-mapa/3 template: leitura por trecho"
assert_contains "$pt" '- `caminho/exato/arquivo1.ts:12-60` — <o que foi relevante nela>' "plano-mapa/3 template: exemplo com trecho"

report
