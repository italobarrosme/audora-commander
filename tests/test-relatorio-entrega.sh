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

T=templates/bloco-fechamento-template.md
H='## Relatório de entrega (só a validate, decidido o portão)'
r="$(sec "$T" "$H")"
f="$(flat "$T" "$H")"
b="$(flat "$T")"

# --- /1 — seção existe; 7 seções nesta ordem; toda categoria, toda decisão; depois do bloco de fase ---
[ -n "$r" ] && ok || ko "relatorio-entrega/1 template sem a seção '$H'"
ordem="$(printf '%s\n' "$r" | grep -oE '^\*\*[^*]+\*\*' | tr '\n' '|')"
assert_eq '**Demanda**|**Mudanças no caminho**|**Entregue**|**Evidência**|**Como conferir**|**Decisões tomadas pela IA**|**Arquivos tocados**|' "$ordem" "relatorio-entrega/1 ordem das 7 seções"
for s in 'TODA categoria (LIGHT, MEDIUM, HIGH, HOTFIX)' 'aprovado, parcial ou reprovado' 'depois do bloco de fase'; do
  assert_contains "$f" "$s" "relatorio-entrega/1 toda categoria, toda decisão, após o bloco de fase"
done

# --- /2 — Demanda: categoria, total de critérios, objetivo copiado do nó ---
for s in '**Demanda** — <categoria> · <n> critérios' 'objetivo copiado do campo `objetivo` do nó' 'nunca reescrito de memória'; do
  assert_contains "$f" "$s" "relatorio-entrega/2 seção Demanda"
done

# --- /3 — Entregue: todos os critérios, endereço, veredito com palavra, linguagem de usuário ---
for s in '✅ entregue' '⏳ pendente' '❌ reprovado' 'TODOS os critérios do nó, um por linha' 'o sistema agora'; do
  assert_contains "$f" "$s" "relatorio-entrega/3 seção Entregue"
done

# --- /4 — Evidência: tabela por critério; comando+resultado ou link com âncora; motivo quando ⏳/❌ ---
for s in '| critério | evidência' 'comando executado nesta sessão + resultado em 1 linha, ou link para o teste com âncora de linha' 'leva o motivo no lugar da evidência'; do
  assert_contains "$f" "$s" "relatorio-entrega/4 tabela Evidência"
done

# --- /5 — Mudanças no caminho: uma linha por delta; omitida sem delta ---
for s in 'uma linha por entrada de `## delta` do nó' 'Sem delta, a seção não é impressa'; do
  assert_contains "$f" "$s" "relatorio-entrega/5 seção Mudanças no caminho"
done

# --- /6 — Decisões tomadas pela IA: uma linha por decisão; omitida sem nenhuma ---
for s in 'uma linha por decisão' 'Sem nenhuma, a seção não é impressa'; do
  assert_contains "$f" "$s" "relatorio-entrega/6 seção Decisões tomadas pela IA"
done

# --- /7 — Como conferir: ≥ 1 item ligado ao critério; code block text ou tela/rota ---
for s in '≥ 1 item, cada um ligado ao critério que confere' 'code block ` ```text `' 'tela/rota a abrir'; do
  assert_contains "$f" "$s" "relatorio-entrega/7 seção Como conferir"
done

# --- /8 — Arquivos tocados: numstat real, total somado, link clicável, removido sem link ---
for s in 'git diff --numstat <base>..HEAD' 'total somado dela' 'arquivo removido sem link (`~~caminho/antigo.ts~~`)' 'link clicável'; do
  assert_contains "$f" "$s" "relatorio-entrega/8 seção Arquivos tocados"
done

# --- /9 — reprovado ou parcial imprime igual; Próximo = decisão humana ou fase de retorno ---
for s in 'Portão reprovado ou parcial imprime o relatório do mesmo jeito' 'fase de retorno (scope ou plan)' 'Nunca omitir o relatório'; do
  assert_contains "$f" "$s" "relatorio-entrega/9 reprovação e parcial"
done

# --- /10 — dado sem fonte lida nesta sessão → [SEM FONTE] e critério ⏳ ---
for s in '[SEM FONTE]' 'nunca preencher de memória'; do
  assert_contains "$f" "$s" "relatorio-entrega/10 sem fonte"
done

# --- /11 — última parte da resposta do turno, sem ferramenta depois ---
for s in 'última parte da resposta do turno' 'nenhuma chamada de ferramenta depois dele'; do
  assert_contains "$f" "$s" "relatorio-entrega/11 última parte do turno"
done

# --- regressão — seção velha "Bloco de entrega" sumiu; vizinha "Parada entre fases" intocada ---
for s in 'só a validate, após aprovação' 'entre **Arquivos** e **Próximo**' '#### 🚀 Entrega — <id>'; do
  assert_not_contains "$b" "$s" "relatorio-entrega/1 regressão: texto do bloco de entrega antigo"
done
assert_contains "$b" '## Parada entre fases' "relatorio-entrega/1 regressão: seção vizinha intocada"

report
