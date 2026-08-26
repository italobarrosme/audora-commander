#!/usr/bin/env bash
# memory-graphify/1 — zero "grafo" na superfície do plugin; skill memory existe, graph não.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# Exceção única (delta /1 de 2026-08-26): a skill memory cita `GRAFO.md` UMA vez, no aviso do critério /3.
restos="$(LC_ALL=C.UTF-8 grep -rniE 'grafo' skills hooks templates .claude-plugin README.md README.pt-BR.md PRD.md 2>/dev/null | grep -v '^skills/memory/SKILL.md:[0-9]*:.*GRAFO\.md' || true)"
assert_empty "$restos" "memory-graphify/1 resíduo de GRAFO"
n="$(grep -c 'GRAFO' skills/memory/SKILL.md 2>/dev/null)"; [ "${n:-99}" -le 1 ] && ok || ko "memory-graphify/1 skill memory cita GRAFO mais de uma vez"
assert_file "skills/memory/SKILL.md" "memory-graphify/1 skill memory"
assert_no_file "skills/graph" "memory-graphify/1 skill graph removida"
assert_eq "8" "$(ls -d skills/*/ | wc -l | tr -d ' ')" "memory-graphify/1 8 skills"
report
