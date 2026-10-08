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

# --- /1 /2 /3 /4 /9 — plan: mapa, asserção exata, header por trecho, subagente conferido ---
pf="$(flat skills/plan/SKILL.md '## Fluxo')"
assert_contains "$pf" 'Tarefa é MAPA, sem o corpo do teste nem o da implementação' "plano-mapa/1 plan: tarefa é mapa"
assert_contains "$pf" 'ponto de mudança `caminho:linha`, arquivo e caso de teste, trechos a ler e done' "plano-mapa/1 plan: campos do mapa"
assert_contains "$pf" 'Critério que não fixa o valor exato (formato, ordem, mensagem, código de saída, borda) → a tarefa traz a asserção exata `entrada → saída esperada` de cada caso' "plano-mapa/2 plan: asserção exata"
assert_contains "$pf" 'Listar no header CADA leitura como `caminho:início-fim`, com o que foi relevante nela' "plano-mapa/3 plan: header por trecho"
assert_contains "$pf" 'subagente de exploração com UMA pergunta delimitada, que devolve `caminho:linha`; confira o trecho com leitura própria antes de gravar no mapa' "plano-mapa/4 plan: subagente conferido"
assert_contains "$(flat skills/plan/SKILL.md '## Replanejamento (durante a execução)')" '(d) a execute precisa modificar arquivo fora do mapa' "plano-mapa/9 plan: gatilho de replanejamento"

# --- /5 /6 /7 /8 /9 /10 /11 — execute: localização por trecho ---
el="$(flat skills/execute/SKILL.md '## Localização de código')"
for s in 'ao começar a tarefa, ler os trechos que o mapa aponta' \
         'Arquivo com mais de 200 linhas é lido pelo trecho, nunca inteiro'; do
  assert_contains "$el" "$s" "plano-mapa/5 execute: '$s'"
done
assert_contains "$el" '**Fora do mapa**: buscar o símbolo e ler só o trecho apontado' "plano-mapa/6 execute: busca do símbolo"
assert_contains "$el" 'a mudança toca import, herança, registro ou configuração → seguir a ligação e ler o trecho ligado, mesmo fora do mapa' "plano-mapa/7 execute: segue ligações"
assert_contains "$el" 'na 3ª leitura fora do mapa na mesma tarefa, acrescentar ao mapa do plano os `caminho:linha` lidos e seguir' "plano-mapa/8 execute: orçamento de 3 leituras"
assert_contains "$el" '**Modificar arquivo fora do mapa** → parar a tarefa e voltar ao plan para replanejar só aquela etapa' "plano-mapa/9 execute: modificar fora volta ao plan"
assert_contains "$el" '(`caminho:linha` não bate): relocalizar pela busca do símbolo e corrigir o mapa, sem ler o arquivo inteiro' "plano-mapa/10 execute: mapa desatualizado"
assert_contains "$el" '**Plano no formato antigo** (código completo do teste): executar como está, sem pedir conversão' "plano-mapa/11 execute: formato antigo aceito"
assert_contains "$(flat skills/execute/SKILL.md '## Fluxo')" 'o caso e as asserções vêm do mapa' "plano-mapa/1 execute: teste nasce do mapa"

# --- /12 — debug sintoma localiza como a execute (mesmas frases); caçada segue varredura ---
for par in "skills/execute/SKILL.md|## Localização de código" "skills/debug/SKILL.md|## Modo sintoma"; do
  f="${par%%|*}"; h="${par#*|}"; t="$(flat "$f" "$h")"
  for s in 'mais de 200 linhas é lido pelo trecho, nunca inteiro' 'buscar o símbolo e ler só o trecho apontado' \
           'seguir a ligação e ler o trecho ligado' 'relocalizar pela busca do símbolo'; do
    assert_contains "$t" "$s" "plano-mapa/12 $f ($h) tem '$s'"
  done
done
dc="$(flat skills/debug/SKILL.md '## Modo caçada (sem sintoma)')"
assert_contains "$dc" 'Varredura por classes de defeito' "plano-mapa/12 caçada continua varredura por classes"
assert_not_contains "$dc" 'mais de 200 linhas' "plano-mapa/12 caçada sem regra de trecho"

# --- /1 /5 /12 — docs descrevem o mapa e a leitura por trecho ---
en="$(flat README.md)"; pt="$(flat README.pt-BR.md)"; fu="$(flat docs/fundamentos.md)"
assert_contains "$en" 'Each task is a map' "plano-mapa/1 README EN: tarefa é mapa"
assert_not_contains "$en" 'full TEST code' "plano-mapa/1 README EN sem teste completo"
assert_contains "$pt" 'Cada tarefa é um mapa' "plano-mapa/1 README PT: tarefa é mapa"
assert_not_contains "$pt" 'código completo do TESTE' "plano-mapa/1 README PT sem teste completo"
assert_contains "$en" 'Reads code by snippet' "plano-mapa/5 README EN: execute lê por trecho"
assert_contains "$pt" 'Lê código por trecho' "plano-mapa/5 README PT: execute lê por trecho"
assert_contains "$en" 'Symptom mode locates code like `execute`' "plano-mapa/12 README EN: debug localiza como execute"
assert_contains "$pt" 'O modo sintoma localiza código como a `execute`' "plano-mapa/12 README PT: debug localiza como execute"
assert_contains "$fu" 'A tarefa é mapa' "plano-mapa/1 fundamentos P2: tarefa é mapa"

# --- /14 /15 — teto BASE intacto (FULL: prd-foto/2); versão 0.16.0 (skill-cleanup) ---
tc="$(tr -d '\r' < tests/test-carga.sh)"
assert_contains "$tc" 'TETO_BASE=54900' "plano-mapa/14 teto BASE intacto"
assert_contains "$tc" 'TETO_FULL=63000' "prd-foto/2 teto FULL 63000 — sync com CHANGELOG + template no FULL (substitui plano-mapa/14)"
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  assert_contains "$(tr -d '\r' < "$j")" '"version": "0.16.0"' "skill-cleanup $j declara 0.16.0 (substitui leitura-por-secao/12)"
  assert_not_contains "$(tr -d '\r' < "$j")" '"version": "0.11.0"' "plano-mapa/15 $j sem 0.11.0"
done

report
