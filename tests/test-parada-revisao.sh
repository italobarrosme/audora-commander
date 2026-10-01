#!/usr/bin/env bash
# parada-revisao — revisão adversarial (HIGH) com critério de parada: bloqueia só
# achado provado de 3 classes, 1 passagem + reverificação restrita, resto é ressalva.
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
R=skills/validate/references/revisao-adversarial.md
V=skills/validate/SKILL.md

# --- reference: existe, ≤ 250 linhas, cabeçalho e despacho ---
assert_file "$R" "parada-revisao/1 reference da revisão existe"
linhas="$(tr -d '\r' 2>/dev/null < "$R" | wc -l)"
[ "$linhas" -le 250 ] && ok || ko "parada-revisao/1 reference com $linhas linhas > 250"
r="$(flat "$R")"
for s in '# validate — revisão adversarial (HIGH)' 'lida só em demanda HIGH' \
  'subagente de contexto limpo' 'Autor não revisa a si mesmo' 'executáveis falsos no PATH'; do
  assert_contains "$r" "$s" "parada-revisao/1 despacho"
done

# --- /1 — bloqueante só de 3 classes ---
for s in 'bloqueante só o achado de uma de 3 classes' '(a) apaga ou altera coisa fora da demanda' \
  '(b) viola um critério de aceite' '(c) falha com entrada ou formato real'; do
  assert_contains "$r" "$s" "parada-revisao/1 classes"
done

# --- /2 — prova por classe; sem prova (ou prova que não se sustenta) rebaixa ---
for s in '(a) o arquivo ou trecho alheio no diff' '(b) o endereço `<id>/<n>` do critério e como ele é violado' \
  '(c) o comando ou a entrada que reproduz a falha' 'achado sem prova é rebaixado a ressalva' \
  'confira a prova você mesmo' 'prova que não se sustenta também é rebaixada'; do
  assert_contains "$r" "$s" "parada-revisao/2 prova"
done

# --- /3 — não bloqueante é ressalva de 1 linha, sem nova passagem ---
for s in 'ressalva de 1 linha' 'sem voltar à execute e sem disparar nova passagem'; do
  assert_contains "$r" "$s" "parada-revisao/3 ressalva"
done

# --- /9 — MEDIUM não paga o texto: roteador só aponta, fora de BASE e FULL ---
n="$(tr -d '\r' < "$V" | grep -c 'references/revisao-adversarial.md')"
[ "$n" -ge 2 ] && ok || ko "parada-revisao/9 roteador cita a reference na tabela e no item 3 (achou $n)"
v="$(flat "$V")"
for s in 'rebaixado a ressalva' '3 classes' 'ATACAR'; do
  assert_not_contains "$v" "$s" "parada-revisao/9 texto da revisão fora do roteador"
done
bytes="$(tr -d '\r' < "$V" | wc -c)"
[ "$bytes" -le 6139 ] && ok || ko "parada-revisao/9 roteador cresceu: $bytes > 6139 bytes"
assert_not_contains "$(cat tests/test-carga.sh)" 'revisao-adversarial' "parada-revisao/9 reference fora da carga BASE/FULL"
carga_out="$(bash tests/test-carga.sh 2>&1)"; carga_code=$?
assert_eq 0 "$carga_code" "parada-revisao/9 test-carga.sh sai 0"
base="$(printf '%s' "$carga_out" | grep -o 'base=[0-9]*' | cut -d= -f2)"
[ -n "$base" ] && [ "$base" -le 47773 ] && ok || ko "parada-revisao/9 carga BASE '$base' > 47773"

# --- /4 /5 — 1 passagem completa + reverificação restrita; nunca 3ª ---
p="$(flat "$R" '## Parada')"
for s in 'cada bloqueante vira uma tarefa nova no plano' 'registre nas Notas de sessão do plano' 'passagem 1' \
  '`execute de <id>`' 'reverificação restrita: o revisor confere só aqueles achados contra o diff da correção, sem caçar achado novo'; do
  assert_contains "$p" "$s" "parada-revisao/4 reverificação restrita"
done
for s in 'nunca uma 3ª passagem' 'achado novo visto na reverificação entra como ressalva' 'o que restar vai ao portão humano'; do
  assert_contains "$p" "$s" "parada-revisao/5 sem 3ª passagem"
done

# --- /6 /7 — o que entra no roteiro; revisor indisponível não trava o portão ---
q="$(flat "$R" '## No roteiro')"
for s in 'nº de passagens' 'cada bloqueante com classe, prova e estado (corrigido ou aberto)' 'as ressalvas'; do
  assert_contains "$q" "$s" "parada-revisao/6 roteiro"
done
for s in 'revisão adversarial não rodou' 'o portão segue com o humano revisando o diff'; do
  assert_contains "$q" "$s" "parada-revisao/7 revisor indisponível"
done

# --- /8 — ressalva aceita no portão vai ao nó e, no sync, às metas do PRD ---
for s in 'registre cada uma em `## decisoes` do nó' '(humano): ressalva aceita —'; do
  assert_contains "$r" "$s" "parada-revisao/8 portão"
done
S=skills/validate/references/sync.md; sy="$(flat "$S")"
for s in 'Ressalva aceita no portão' 'Candidato a nó: ressalvas do `<id>` aceitas no portão.' \
  'MEMORY → PRD' 'o `PRD.md` ainda não foi tocado' 'ordem importa' 'nó primeiro, índice depois'; do
  assert_contains "$sy" "$s" "parada-revisao/8 sync"
done

# --- docs — READMEs e fundamentos descrevem a parada (/1, /3, /4, /5) ---
en="$(flat README.md)"
for s in 'blocks only on proven findings of three classes' 'the rest becomes a one-line caveat' \
  'one full pass plus a re-check of the fixed blockers'; do
  assert_contains "$en" "$s" "parada-revisao docs README EN"
done
pt="$(flat README.pt-BR.md)"
for s in 'bloqueia só achado provado de 3 classes' 'o resto vira ressalva de 1 linha' \
  '1 passagem completa mais a reverificação dos bloqueantes corrigidos'; do
  assert_contains "$pt" "$s" "parada-revisao docs README PT"
done
fu="$(flat docs/fundamentos.md)"
for s in 'bloqueia só achado provado de 3 classes (alheio, critério, formato real)' 'nunca uma 3ª passagem'; do
  assert_contains "$fu" "$s" "parada-revisao docs fundamentos"
done

report
