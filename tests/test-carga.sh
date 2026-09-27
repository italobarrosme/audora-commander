#!/usr/bin/env bash
# otimizacao-tokens/7 — teto de carga (bytes) do caminho MEDIUM: o texto que o
# framework põe no contexto por demanda não volta a inchar em silêncio.
# BASE = o que toda demanda MEDIUM carrega até o portão final (1 leitura de cada);
# FULL = BASE + o que só a aprovação lê (compactar, sync, filtro de decisões vivas).
# Medição (2026-09-27): antes BASE 56237 / FULL 58036; depois BASE 53609 / FULL 58818.
# Tetos = depois + 3%, arredondado para cima em centenas. Subir teto só com motivo no nó.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
S=skills; T=templates; R=skills/memory/references; V=skills/validate/references
BASE_LIST="$S/audora-commander/SKILL.md $S/memory/SKILL.md $R/registrar-no.md $T/no-template.md $S/scope/SKILL.md $S/plan/SKILL.md $R/consultar-codigo.md $T/plano-template.md $S/execute/SKILL.md $S/validate/SKILL.md $T/bloco-fechamento-template.md"
FULL_EXTRA="$R/compactar.md $V/sync.md $V/decisoes-vivas.md"
TETO_BASE=55300
TETO_FULL=60600
for f in $BASE_LIST $FULL_EXTRA; do assert_file "$f" "otimizacao-tokens/7 arquivo do caminho existe"; done
carga() { local t=0 f; for f in "$@"; do [ -f "$f" ] && t=$((t + $(wc -c < "$f"))); done; echo "$t"; }
base="$(carga $BASE_LIST)"; full=$((base + $(carga $FULL_EXTRA)))
echo "carga MEDIUM (bytes): base=$base full=$full — tetos $TETO_BASE / $TETO_FULL"
[ "$base" -le "$TETO_BASE" ] && ok || ko "otimizacao-tokens/7 carga BASE $base > teto $TETO_BASE — enxugar ou justificar novo teto no nó"
[ "$full" -le "$TETO_FULL" ] && ok || ko "otimizacao-tokens/7 carga FULL $full > teto $TETO_FULL — enxugar ou justificar novo teto no nó"
report
