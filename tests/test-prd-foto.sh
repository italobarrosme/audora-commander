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

report
