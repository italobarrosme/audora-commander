#!/usr/bin/env bash
# otimizacao-tokens/7 — teto de carga (bytes) do caminho MEDIUM: o texto que o
# framework põe no contexto por demanda não volta a inchar em silêncio.
# BASE = o que toda demanda MEDIUM carrega até o portão final (1 leitura de cada);
# FULL = BASE + o que só a aprovação lê (compactar, sync, filtro de decisões vivas).
# Medição (blobs LF): antes BASE 56237 / FULL 58036; depois BASE 53274 / FULL 58483; corte-sem-uso: BASE 51800 → 46575 / FULL 57040 → 51815; plano-mapa: BASE 46575 → 47719 / FULL 51815 → 52959.
# Tetos = depois + 3%, arredondado para cima em centenas. Subir teto só com motivo no nó.
# Bytes contados SEM \r: com core.autocrlf=true o checkout grava CRLF e infla a conta.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
S=skills; T=templates; R=skills/memory/references; V=skills/validate/references
BASE_LIST="$S/audora-commander/SKILL.md $S/memory/SKILL.md $R/registrar-no.md $T/no-template.md $S/scope/SKILL.md $S/plan/SKILL.md $T/plano-template.md $S/execute/SKILL.md $S/validate/SKILL.md $T/bloco-fechamento-template.md"
FULL_EXTRA="$R/compactar.md $V/sync.md $V/decisoes-vivas.md"
TETO_BASE=48000
TETO_FULL=53400
for f in $BASE_LIST $FULL_EXTRA; do assert_file "$f" "otimizacao-tokens/7 arquivo do caminho existe"; done
carga() { local t=0 f; for f in "$@"; do [ -f "$f" ] && t=$((t + $(tr -d '\r' < "$f" | wc -c))); done; echo "$t"; }
base="$(carga $BASE_LIST)"; full=$((base + $(carga $FULL_EXTRA)))
echo "carga MEDIUM (bytes): base=$base full=$full — tetos $TETO_BASE / $TETO_FULL"
[ "$base" -le "$TETO_BASE" ] && ok || ko "otimizacao-tokens/7 carga BASE $base > teto $TETO_BASE — enxugar ou justificar novo teto no nó"
[ "$full" -le "$TETO_FULL" ] && ok || ko "otimizacao-tokens/7 carga FULL $full > teto $TETO_FULL — enxugar ou justificar novo teto no nó"
report
