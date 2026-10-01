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

# --- /2 /1 — LIGHT também ganha a linha do CHANGELOG; foto só se mudar ---
fl="$(flat skills/validate/references/fechamento-light.md)"
assert_contains "$fl" 'A linha do `CHANGELOG.md` entra sempre, também em LIGHT' "prd-foto/2 LIGHT: linha do CHANGELOG sempre"
assert_contains "$fl" 'atualize a foto só se o ajuste mudar o que ela descreve' "prd-foto/1 LIGHT: foto só se mudar"
for s in 'silêncio sobre o PRD é proibido' 'não tem plano' 'caminho percorrido pelo usuário' 'arquivos de teste separados'; do
  assert_contains "$fl" "$s" "prd-foto/2 LIGHT mantém '$s'"
done

# --- docs de /1 /2 /5 — READMEs e fundamentos descrevem a foto e o CHANGELOG ---
en="$(flat README.md)"
for s in 'the `PRD.md` snapshot updated' 'one line appended to `CHANGELOG.md`' '`PRD.md` over 200 lines'; do
  assert_contains "$en" "$s" "prd-foto docs README EN: '$s'"
done
for s in 'summary promoted to `PRD.md`' 'receives the summary'; do
  assert_not_contains "$en" "$s" "prd-foto docs README EN sem '$s'"
done
pt="$(flat README.pt-BR.md)"
for s in 'foto do `PRD.md` atualizada' 'uma linha acrescentada ao `CHANGELOG.md`' '`PRD.md` acima de 200 linhas'; do
  assert_contains "$pt" "$s" "prd-foto docs README PT: '$s'"
done
for s in 'resumo promovido ao `PRD.md`' 'PRD.md recebe o resumo'; do
  assert_not_contains "$pt" "$s" "prd-foto docs README PT sem '$s'"
done
fu="$(flat docs/fundamentos.md)"
assert_contains "$fu" 'atualiza a foto do PRD.md e acrescenta 1 linha ao CHANGELOG.md' "prd-foto docs fundamentos P5"
assert_not_contains "$fu" 'promove o resumo ao PRD.md' "prd-foto docs fundamentos sem o resumo antigo"

# --- /10 — versão 0.14.0 nos dois manifests (parada-revisao/10) ---
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  assert_contains "$(tr -d '\r' < "$j")" '"version": "0.14.0"' "parada-revisao/10 $j declara 0.14.0 (substitui prd-foto/10)"
  assert_not_contains "$(tr -d '\r' < "$j")" '"version": "0.12.0"' "prd-foto/10 $j sem 0.12.0"
done

# --- /8 — dogfood: PRD.md do plugin é foto; histórico literal no CHANGELOG.md ---
[ "$(awk 'END{print NR}' PRD.md)" -le 200 ] && ok || ko "prd-foto/8 PRD.md do plugin com até 200 linhas"
pr="$(tr -d '\r' < PRD.md)"
assert_not_contains "$pr" '## Estado atual' "prd-foto/8 PRD sem histórico de entregas"
assert_not_contains "$pr" 'PRD como foto' "prd-foto/3 meta entregue saiu das metas futuras"
assert_file CHANGELOG.md "prd-foto/8 CHANGELOG.md existe"
cl="$( { tr -d '\r' < CHANGELOG.md; } 2>/dev/null)"
assert_contains "$cl" '## Histórico até 2026-' "prd-foto/8 CHANGELOG com o histórico movido"
assert_contains "$cl" 'Plano-mapa entregue em 2026-10-01 (nó `plano-mapa`, MEDIUM, versão 0.12.0).' "prd-foto/8 histórico literal: plano-mapa"
assert_contains "$cl" 'Corte do sem uso entregue em 2026-09-30' "prd-foto/8 histórico literal: corte-sem-uso"
re='^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| 0\.13\.0 \| prd-foto \| .+ → docs/audora/arquivo/[0-9]{4}-[0-9]{2}-[0-9]{2}-prd-foto\.md$'
assert_eq 1 "$(printf '%s\n' "$cl" | grep -cE "$re")" "prd-foto/2,8 exatamente 1 linha da entrega prd-foto"
alvo="$(printf '%s\n' "$cl" | grep -E "$re" | sed 's/.* → //')"
assert_file "${alvo:-ausente}" "prd-foto/2,8 a linha aponta um nó arquivado que existe"
run_hook memory-guard "$ROOT/PRD.md"; assert_eq 0 "$code" "prd-foto/8 hook aceita a foto"; assert_empty "$out" "prd-foto/8 foto em silêncio"

report
