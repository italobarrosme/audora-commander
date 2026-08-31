#!/usr/bin/env bash
# memory-graphify/1 — zero "grafo" na superfície do plugin; skill memory existe, graph não.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# Exceção única (delta /1 de 2026-08-26): a skill memory cita `GRAFO.md` UMA vez, no aviso do critério /3.
# Exceção 2 (delta /1 de 2026-08-26, fase execute T6): as 3 células de nome antigo da tabela "Renamed in 0.4.0" dos READMEs (/19 exige "GRAFO → MEMORY" literal).
restos="$(LC_ALL=C.UTF-8 grep -rniE 'grafo' skills hooks templates .claude-plugin README.md README.pt-BR.md PRD.md 2>/dev/null | grep -v '^skills/memory/SKILL.md:[0-9]*:.*GRAFO\.md' | grep -vE '^README(\.pt-BR)?\.md:[0-9]+:\| (`GRAFO\.md`|`GRAFO-ARQUIVO\.md`|hooks `grafo-guard`, `grafo-validate`) \|' || true)"
assert_empty "$restos" "memory-graphify/1 resíduo de GRAFO"
for r in README.md README.pt-BR.md; do [ "$(grep -ci grafo "$r")" -le 3 ] && ok || ko "memory-graphify/1 $r cita grafo fora da tabela Renamed in 0.4.0"; done
n="$(grep -c 'GRAFO' skills/memory/SKILL.md 2>/dev/null)"; [ "${n:-99}" -le 1 ] && ok || ko "memory-graphify/1 skill memory cita GRAFO mais de uma vez"
# memory-fatiada/2 — o aviso do GRAFO fica inline (carregar-contexto); reference nenhuma o repete.
r="$(LC_ALL=C.UTF-8 grep -rc 'GRAFO' skills/memory/references 2>/dev/null | grep -v ':0$' || true)"
assert_empty "$r" "memory-graphify/1 reference cita GRAFO"
assert_file "skills/memory/SKILL.md" "memory-graphify/1 skill memory"
assert_no_file "skills/graph" "memory-graphify/1 skill graph removida"
assert_eq "9" "$(ls -d skills/*/ | wc -l | tr -d ' ')" "memory-graphify/1 9 skills"
report
