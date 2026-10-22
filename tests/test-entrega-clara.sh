#!/usr/bin/env bash
# entrega-clara — decidido o portão, a validate fecha o turno com um cartão
# único (🏁 DONE, ❌ NÃO ENTREGUE ou ⚠️ PARCIAL) no lugar do bloco de fase.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# sec <arquivo> '<cabeçalho exato>' → corpo da seção, sem \r (checkout CRLF).
# `## ` dentro de fence de 4 crases (o esqueleto do cartão) não fecha a seção.
sec() {
  tr -d '\r' 2>/dev/null < "$1" |
    awk -v h="$2" '/^````/{q=!q} $0==h{f=1;next} !q && /^## /{f=0} f'
}
# flat <arquivo> [cabeçalho] → texto (da seção, se dado) numa linha só,
# espaços colapsados: frase que quebra linha no Markdown ainda casa.
flat() {
  if [ -n "${2:-}" ]; then sec "$1" "$2"; else tr -d '\r' 2>/dev/null < "$1"; fi |
    tr '\n' ' ' | tr -s ' '
}

T=templates/bloco-fechamento-template.md
H='## Cartão de entrega (só a validate, decidido o portão)'
r="$(sec "$T" "$H")"
f="$(flat "$T" "$H")"
b="$(flat "$T")"
esq="$(printf '%s\n' "$r" | awk '/^````markdown/{f=1;next} /^````/{f=0} f')"

# --- /1 — cartão único de título DONE, em toda categoria, no lugar do bloco de fase ---
[ -n "$r" ] && ok || ko "entrega-clara/1 template sem a seção '$H'"
for s in '## 🏁 DONE — <id>' 'no lugar do bloco de fase' 'em TODA categoria (LIGHT, MEDIUM, HIGH, HOTFIX)'; do
  assert_contains "$f" "$s" "entrega-clara/1 cartão DONE no lugar do bloco de fase"
done
ordem="$(printf '%s\n' "$esq" | grep -oE '^\*\*[^*]+\*\*' | tr '\n' '|')"
assert_eq '**O que mudou**|**Como foi**|**Ressalvas**|**Mudanças no caminho**|**Por critério**|**Evidência**|**Decisões da IA**|**Como conferir**|**Arquivos**|**Memória**|' "$ordem" "entrega-clara/1 rótulos do esqueleto em ordem"
assert_contains "$b" 'a validate, decidido o portão, imprime o cartão de entrega no lugar do bloco' "entrega-clara/1 header do template aponta o cartão"
for s in '## Relatório de entrega' '#### Relatório de entrega — <id>' '| critério | evidência' '~~caminho/antigo.ts~~'; do
  assert_not_contains "$b" "$s" "entrega-clara/1 regressão: relatório velho sumiu"
done
assert_contains "$b" '## Parada entre fases' "entrega-clara/1 regressão: seção vizinha intocada"

# --- /2 — linha de estado: categoria · entregues/total critérios · main ou branch ---
for s in '<categoria> · <entregues>/<total> critérios · na main' 'ou `na branch <nome>`'; do
  assert_contains "$f" "$s" "entrega-clara/2 linha de estado"
done

# --- /15 — cartão é a última parte do turno ---
for s in 'última parte da resposta do turno' 'nenhuma chamada de ferramenta depois dele'; do
  assert_contains "$f" "$s" "entrega-clara/15 última parte do turno"
done

report
