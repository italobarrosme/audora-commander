#!/usr/bin/env bash
# leitura-por-secao — toda fase carrega do MEMORY.md só o recorte de que precisa:
# Propósito e Constituição inteiras, Aprendizados e Índice de nós por busca.
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

# --- /1–/9 — carregar-contexto por seção ---
m="$(flat skills/memory/SKILL.md)"
cc="$(tr -d '\r' 2>/dev/null < skills/memory/SKILL.md | awk '/^### 1\. carregar-contexto/{f=1;next} /^### /{f=0} f' | tr '\n' ' ' | tr -s ' ')"

assert_contains "$m" '### 1. carregar-contexto (toda fase: `MEMORY.md` por seção, nunca inteiro)' "leitura-por-secao/1 título do carregar-contexto"
assert_contains "$m" '1. O recorte do `MEMORY.md` da fase (carregar-contexto), nunca o arquivo inteiro.' "leitura-por-secao/1 leitura seletiva carrega o recorte"
assert_not_contains "$m" 'é pequeno por construção' "leitura-por-secao/1 sem MEMORY.md inteiro na leitura seletiva"
assert_not_contains "$m" 'Ler `MEMORY.md`. Ausente' "leitura-por-secao/1 carregar-contexto não lê o MEMORY.md inteiro"
assert_contains "$cc" 'Propósito e Constituição: inteiras, Read por `offset`/`limit`' "leitura-por-secao/1 seções fixas inteiras"
assert_contains "$cc" 'demais fases, a fase + keywords e arquivos-chave do nó (debug sem nó: termos do sintoma)' "leitura-por-secao/2 filtro das fases"
assert_contains "$cc" 'porta de entrada, termos do pedido' "leitura-por-secao/3 filtro da porta"
assert_contains "$cc" '`[invalidado-em:` nunca entra' "leitura-por-secao/4 invalidado fora"
assert_contains "$cc" 'nada casou → seguir sem aprendizados, sem ler a seção' "leitura-por-secao/5 filtro vazio segue"
assert_contains "$cc" 'Índice de nós: inteiro na porta de entrada, scope e plan; execute, e2e, validate e debug pegam só a linha do nó e as de `depende-de`' "leitura-por-secao/6 índice por fase"
assert_contains "$m" '**Já carregado nesta sessão** (recorte do `MEMORY.md` lido, sem `/clear` nem compactação depois)' "leitura-por-secao/7 reuso do recorte"
assert_contains "$cc" 'avisar em 1 linha qual seção faltou, ler o arquivo inteiro e seguir a fase' "leitura-por-secao/8 seção faltando"
for n in 'Propósito' 'Constituição' 'Aprendizados' 'Índice de nós'; do
  tr -d '\r' < templates/MEMORY-template.md | grep -qxF "## $n [carga: sempre]" && ok || ko "leitura-por-secao/9 template mantém '## $n [carga: sempre]'"
  assert_contains "$cc" "\`## $n\`" "leitura-por-secao/9 carregar-contexto acha '## $n' sem marcador novo"
done
run_hook memory-validate "$ROOT/MEMORY.md"
assert_eq 0 "$code" "leitura-por-secao/9 memory-validate aceita o MEMORY.md atual"

# Comandos literais do carregar-contexto (trechos em crase), placeholders trocados.
cmds() { printf '%s' "$cc" | grep -oE "\`$1 '[^\`]*\`" | tr -d '\`'; }
c_sec="$(cmds 'grep -n' | sed -n 1p)"
c_porta="$(cmds 'grep -iE' | sed -n 1p)"
c_fase="$(cmds 'grep -iE' | sed -n 2p)"
c_idx="$(cmds 'grep -E' | sed -n 1p)"
sub_fase()  { local c="${c_fase//"<fase>"/"$1"}"; printf '%s' "${c//"<termo>|<termo>"/"$2"}"; }
sub_porta() { printf '%s' "${c_porta//"<termo>|<termo>"/"$1"}"; }
sub_idx()   { printf '%s' "${c_idx//"<id>|<dep>"/"$1"}"; }
roda()      { (cd "$1" && bash -c "$2") | tr -d '\r'; }
ids_apr()   { sed -E 's/^- [0-9-]{10} \| [a-z0-9]+ \| ([A-Z0-9]+) .*/\1/' | tr '\n' ' ' | sed 's/ $//'; }
ids_idx()   { sed -E 's/^- ([^ ]+) .*/\1/' | tr '\n' ' ' | sed 's/ $//'; }
secoes()    { sed -E 's/^[0-9]+:## ([^ ]+).*/\1/' | tr '\n' ' ' | sed 's/ $//'; }

mkdir -p "$SP/fx" "$SP/fxcr" "$SP/fxsem"
printf '%s\n' 'memory-schema: 1' '' '# MEMORY — loja' '' \
  '## Propósito [carga: sempre]' '' 'Loja de teste.' '' \
  '## Constituição [carga: sempre]' '' '- **stack**: bash; cache em disco.' '' \
  '## Aprendizados [carga: sempre]' '' \
  '- 2026-01-01 | plan | P1 plano sem termo' \
  '- 2026-01-02 | execute | E1 teste do cache' \
  '- 2026-01-03 | execute | E2 nada a ver' \
  '- 2026-01-04 | plan | P2 velho [invalidado-em: 2026-02-01] [substituido-por: P1]' \
  '- 2026-01-05 | validate | V1 deploy [invalidado-em: 2026-02-01] [substituido-por: E1]' \
  '- 2026-01-06 | e2e | X1 Cache maiusculo' '' \
  '## Índice de nós [carga: sempre]' '' \
  '- checkout | in-progress | Checkout | Fecha pedido com cache | cache, pedido | src/' \
  '- pagamento | planned | Pagamento | Cobra o pedido | deploy, pagamento | src/pay' \
  '- outro | planned | Outro | Nada | outro | —' > "$SP/fx/MEMORY.md"
perl -pe 's/\n/\r\n/' "$SP/fx/MEMORY.md" > "$SP/fxcr/MEMORY.md"
awk '/^## Aprendizados/{f=1;next} /^## /{f=0} !f' "$SP/fx/MEMORY.md" > "$SP/fxsem/MEMORY.md"

for d in fx fxcr; do
  D="$SP/$d"
  o_plan="$(roda "$D" "$(sub_fase plan 'cache|deploy')")"
  o_exec="$(roda "$D" "$(sub_fase execute 'cache|deploy')")"
  o_porta="$(roda "$D" "$(sub_porta 'cache|deploy')")"
  assert_eq 'P1 E1 X1' "$(printf '%s\n' "$o_plan" | ids_apr)" "leitura-por-secao/2 comando demais fases: plan + termos ($d)"
  assert_eq 'E1 E2 X1' "$(printf '%s\n' "$o_exec" | ids_apr)" "leitura-por-secao/2 comando demais fases: execute + termos ($d)"
  assert_eq 'E1 X1' "$(printf '%s\n' "$o_porta" | ids_apr)" "leitura-por-secao/3 comando porta: termos do pedido ($d)"
  for o in "$o_plan" "$o_exec" "$o_porta"; do
    assert_not_contains "$o" 'P2' "leitura-por-secao/4 comando não carrega invalidado P2 ($d)"
    assert_not_contains "$o" 'V1' "leitura-por-secao/4 comando não carrega invalidado V1 ($d)"
  done
  assert_eq '' "$(roda "$D" "$(sub_fase debug zzz)")" "leitura-por-secao/5 comando sem casamento → vazio ($d)"
  assert_eq 'checkout pagamento' "$(roda "$D" "$(sub_idx 'checkout|pagamento')" | ids_idx)" "leitura-por-secao/6 comando índice: nó + depende-de ($d)"
  assert_eq 'Propósito Constituição Aprendizados Índice' "$(roda "$D" "$c_sec" | secoes)" "leitura-por-secao/8 comando acha as seções ($d)"
done
assert_eq 'Propósito Constituição Índice' "$(roda "$SP/fxsem" "$c_sec" | secoes)" "leitura-por-secao/8 comando expõe a seção faltando"

apr_repo="$(roda "$ROOT" "$(sub_fase plan 'leitura|secao')")"
sec_apr="$(tr -d '\r' < MEMORY.md | awk '/^## Aprendizados/{f=1;next} /^## /{f=0} f')"
assert_not_contains "$apr_repo" '[invalidado-em:' "leitura-por-secao/4 recorte do MEMORY.md do repo sem invalidados"
b_rec="$(printf '%s' "$apr_repo" | wc -c)"; b_sec="$(printf '%s' "$sec_apr" | wc -c)"
[ "$b_rec" -gt 0 ] && [ "$b_rec" -lt "$b_sec" ] && ok || ko "leitura-por-secao/4 recorte do repo ($b_rec B) não-vazio e menor que a seção ($b_sec B)"

# --- /1 /6 — as 7 fases carregam pelo carregar-contexto ---
for s in audora-commander scope plan execute e2e validate debug; do
  assert_contains "$(flat skills/$s/SKILL.md)" 'carregar-contexto (skill memory)' "leitura-por-secao/1 $s carrega pelo carregar-contexto"
done
assert_not_contains "$(flat skills/audora-commander/SKILL.md)" 'operação carregar-contexto (Constituição + Aprendizados + índice de nós)' "leitura-por-secao/6 porta sem a carga antiga"
assert_not_contains "$(flat skills/scope/SKILL.md)" 'carregar constituição + nós relacionados' "leitura-por-secao/6 scope sem a carga antiga"
assert_not_contains "$(flat skills/plan/SKILL.md)" 'carregar nó da demanda + constituição' "leitura-por-secao/6 plan sem a carga antiga"
# A/B (T5): plan, execute e e2e B leram o MEMORY.md inteiro no 1º lote de Reads, antes da
# skill memory; validate e debug têm a mesma frase-ponteiro do e2e.
for s in plan execute e2e validate debug; do
  assert_contains "$(flat skills/$s/SKILL.md)" 'carregar-contexto (skill memory) antes de qualquer Read; `MEMORY.md` nunca inteiro.' "leitura-por-secao/1 $s carrega o recorte antes do 1º Read"
done
sub="$(flat templates/fase-subagente-template.md)"
assert_contains "$sub" 'o recorte do MEMORY.md (carregar-contexto)' "leitura-por-secao/1 subagente reancora pelo recorte"
assert_contains "$sub" 'reancore só pelos artefatos em disco' "leitura-por-secao/1 subagente segue reancorando só pelo disco"
bv="$(tr -d '\r' 2>/dev/null < skills/validate/SKILL.md | wc -c)"
[ "$bv" -le 6139 ] && ok || ko "leitura-por-secao/1 validate $bv B > 6139 (guarda de parada-revisao/9)"

# --- /1 docs ---
en="$(flat README.md)"; pt="$(flat README.pt-BR.md)"; fu="$(flat docs/fundamentos.md)"
assert_contains "$en" '`MEMORY.md` by section' "leitura-por-secao/1 docs README EN: leitura por seção"
assert_contains "$en" 'the Learnings that match the request' "leitura-por-secao/1 docs README EN: porta filtra Aprendizados"
assert_contains "$pt" '`MEMORY.md` por seção' "leitura-por-secao/1 docs README PT: leitura por seção"
assert_contains "$pt" 'os Aprendizados que casam o pedido' "leitura-por-secao/1 docs README PT: porta filtra Aprendizados"
assert_contains "$fu" 'o `MEMORY.md` entra por seção em toda fase' "leitura-por-secao/1 docs fundamentos: carga por seção"
assert_not_contains "$fu" 'o `MEMORY.md` inteiro' "leitura-por-secao/1 docs fundamentos sem MEMORY.md inteiro"

# --- /11 /12 — carga e versão ---
tc="$(tr -d '\r' < tests/test-carga.sh)"
assert_contains "$tc" 'TETO_BASE=48000' "leitura-por-secao/11 teto BASE vigente"
assert_contains "$tc" 'TETO_FULL=56900' "leitura-por-secao/11 teto FULL vigente"
co="$(bash tests/test-carga.sh 2>&1)"; cc_code=$?
assert_eq 0 "$cc_code" "leitura-por-secao/11 test-carga dentro dos tetos"
base="$(printf '%s' "$co" | sed -nE 's/.*base=([0-9]+).*/\1/p')"
[ -n "$base" ] && [ "$base" -le 47773 ] && ok || ko "leitura-por-secao/11 BASE '$base' > 47773 (guarda de parada-revisao/9)"
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  mj="$(tr -d '\r' < "$j")"
  assert_contains "$mj" '"version": "0.15.0"' "leitura-por-secao/12 $j declara 0.15.0"
  assert_not_contains "$mj" '"version": "0.14.0"' "leitura-por-secao/12 $j sem 0.14.0"
done
sobra="$(grep -rlF '"version": "0.14.0"' tests/ | grep -v test-leitura-por-secao)"
assert_empty "$sobra" "leitura-por-secao/12 assert de 0.14.0 em outro teste"

report
