#!/usr/bin/env bash
# prd-foto — PRD.md vira foto com teto de 200 linhas (hook); histórico no CHANGELOG.md.
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

# --- /5 /6 /7 — memory-guard cobra o teto do PRD.md da raiz ---
d="$SP/p"; mkdir -p "$d/docs"
echo 'memory-schema: 1' > "$d/MEMORY.md"
msg='memory-guard: PRD.md com 201 linhas — teto 200. Compactar a foto: mover o histórico de entregas, literal, para a seção `## Histórico até AAAA-MM-DD` do CHANGELOG.md (skill validate, sync).'
yes l | head -201 > "$d/PRD.md"
run_hook memory-guard "$d/PRD.md"; assert_eq 2 "$code" "prd-foto/5 PRD 201 linhas → 2"; assert_eq "$msg" "$out" "prd-foto/5 mensagem exata"
yes l | head -200 > "$d/PRD.md"
run_hook memory-guard "$d/PRD.md"; assert_eq 0 "$code" "prd-foto/6 PRD 200 linhas → 0"; assert_empty "$out" "prd-foto/6 200 linhas em silêncio"
yes l | head -201 | perl -pe 'chomp if eof' > "$d/PRD.md"
run_hook memory-guard "$d/PRD.md"; assert_eq 2 "$code" "prd-foto/5 201 linhas sem newline final → 2"
printf 'memory-schema: 1\r\n' > "$d/MEMORY.md"
yes l | head -201 | sed 's/$/\r/' > "$d/PRD.md"
run_hook memory-guard "$d/PRD.md"; assert_eq 2 "$code" "prd-foto/5 PRD e MEMORY em CRLF → 2"
echo 'memory-schema: 1' > "$d/MEMORY.md"; yes l | head -201 > "$d/PRD.md"
run_hook memory-guard "$(cygpath -w "$d/PRD.md")"; assert_eq 2 "$code" "prd-foto/5 caminho Windows → 2"
mkdir -p "$SP/q"; yes l | head -250 > "$SP/q/PRD.md"
run_hook memory-guard "$SP/q/PRD.md"; assert_eq 0 "$code" "prd-foto/7 pasta sem MEMORY.md → 0"; assert_empty "$out" "prd-foto/7 sem MEMORY.md em silêncio"
mkdir -p "$SP/r"; echo '# MEMORY de outra ferramenta' > "$SP/r/MEMORY.md"; yes l | head -250 > "$SP/r/PRD.md"
run_hook memory-guard "$SP/r/PRD.md"; assert_eq 0 "$code" "prd-foto/7 MEMORY sem schema → 0"; assert_empty "$out" "prd-foto/7 sem schema em silêncio"
yes l | head -250 > "$d/docs/PRD.md"
run_hook memory-guard "$d/docs/PRD.md"; assert_eq 0 "$code" "prd-foto/7 PRD.md fora da raiz → 0"; assert_empty "$out" "prd-foto/7 fora da raiz em silêncio"
yes l | head -250 > "$d/OLDPRD.md"
run_hook memory-guard "$d/OLDPRD.md"; assert_eq 0 "$code" "prd-foto/7 OLDPRD.md → 0"; assert_empty "$out" "prd-foto/7 OLDPRD.md em silêncio"
rm -f "$d/PRD.md"
run_hook memory-guard "$d/PRD.md"; assert_eq 0 "$code" "prd-foto/7 PRD.md inexistente → 0"; assert_empty "$out" "prd-foto/7 inexistente em silêncio"

# --- /2 /4 — template do CHANGELOG: 1 linha por entrega + histórico literal ---
ct="templates/changelog-template.md"
assert_file "$ct" "prd-foto/2 template existe"
cf="$(flat "$ct")"
assert_contains "$cf" '# Changelog — <nome do projeto>' "prd-foto/2 template: título"
assert_contains "$cf" 'Formato: `- AAAA-MM-DD | <versão ou —> | <id> | <1 frase> → docs/audora/arquivo/AAAA-MM-DD-<id>.md`' "prd-foto/2 template: formato da linha"
assert_contains "$cf" 'literal, sem reescrita' "prd-foto/4 template: histórico literal"
le="$(tr -d '\r' 2>/dev/null < "$ct" | awk '$0=="## Entregas"{print NR; exit}')"
lh="$(tr -d '\r' 2>/dev/null < "$ct" | awk '$0=="## Histórico até AAAA-MM-DD"{print NR; exit}')"
[ -n "$le" ] && [ -n "$lh" ] && [ "$le" -lt "$lh" ] && ok || ko "prd-foto/2,4 template: ## Entregas ($le) antes de ## Histórico até AAAA-MM-DD ($lh)"
ex="$(tr -d '\r' 2>/dev/null < "$ct" | grep -cE '^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| [^|]+ \| [a-z0-9-]+ \| [^|]+ → docs/audora/arquivo/[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+\.md$')"
assert_eq 1 "$ex" "prd-foto/2 template: exatamente 1 linha de exemplo"

# --- /1 /2 /3 /4 — sync atualiza a foto do PRD e acrescenta 1 linha ao CHANGELOG ---
sy="$(flat skills/validate/references/sync.md)"
for s in 'atualize só as seções da foto (o que é, stack, arquitetura, metas futuras) que a entrega mudou' \
         'e a data de última atualização' 'nunca acrescente parágrafo de histórico de entrega'; do
  assert_contains "$sy" "$s" "prd-foto/1 sync: '$s'"
done
assert_not_contains "$sy" 'resumo do que foi entregue' "prd-foto/1 sync: sem o resumo antigo"
for s in 'exatamente uma linha no `CHANGELOG.md` da raiz, em toda categoria' 'templates/changelog-template.md' \
         'sem o arquivo, crie-o pelo template' 'acrescente o `CHANGELOG.md` sempre'; do
  assert_contains "$sy" "$s" "prd-foto/2 sync: '$s'"
done
for s in 'Meta futura entregue sai das metas futuras' 'a entrega fica só na linha do `CHANGELOG.md`'; do
  assert_contains "$sy" "$s" "prd-foto/3 sync: '$s'"
done
for s in '`PRD.md` com histórico de entregas ou com mais de 200 linhas' \
         'mova o histórico, literal e sem reescrita, para `## Histórico até AAAA-MM-DD` do `CHANGELOG.md`' \
         'foto com até 200 linhas' 'escreva a foto num Write só'; do
  assert_contains "$sy" "$s" "prd-foto/4 sync: '$s'"
done
for s in 'MEMORY → PRD' 'o `PRD.md` ainda não foi tocado' 'ordem importa' 'nó primeiro, índice depois'; do
  assert_contains "$sy" "$s" "prd-foto/1 sync mantém '$s'"
done
cp="$(flat skills/memory/references/compactar.md)"
assert_not_contains "$cp" 'promoção do resumo' "prd-foto/1 compactar: sem a promoção do resumo"
assert_contains "$cp" 'foto do `PRD.md` e a linha do `CHANGELOG.md` são da skill validate' "prd-foto/1,2 compactar aponta a validate"
vf="$(flat skills/validate/SKILL.md)"
assert_contains "$vf" '`arquivos:` do diff real, PRD + CHANGELOG, HOTFIX' "prd-foto/2 validate: item 6 cita o CHANGELOG"
assert_contains "$vf" '`PRD.md` atualizado e `CHANGELOG.md` com a linha da entrega' "prd-foto/2 validate: bloco Arquivos cita o CHANGELOG"
[ "$(tr -d '\r' < skills/validate/SKILL.md | wc -c)" -lt 7700 ] && ok || ko "prd-foto/2 validate < 7700 bytes"

report
