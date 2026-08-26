#!/usr/bin/env bash
# memory-graphify/8 — tetos de linhas: MEMORY.md > 300 e nó > 100 → exit 2; -historico e sem schema → 0.
source "$(dirname "$0")/lib.sh"
d="$SP/p"; mkdir -p "$d/docs/audora/memory"
{ echo 'memory-schema: 1'; yes 'l' | head -310; } > "$d/MEMORY.md"
run_hook memory-guard "$d/MEMORY.md";                       assert_eq 2 "$code" "/8 índice 311 linhas → 2"; assert_contains "$out" "teto ~300" "/8 msg índice"
{ echo 'memory-schema: 1'; yes 'l' | head -100; } > "$d/MEMORY.md"
run_hook memory-guard "$d/MEMORY.md";                       assert_eq 0 "$code" "/8 índice 101 linhas → 0"
{ echo 'versao-schema: 2'; yes 'l' | head -310; } > "$d/MEMORY.md"
run_hook memory-guard "$d/MEMORY.md";                       assert_eq 0 "$code" "/8 sem memory-schema → 0"
yes 'x' | head -120 > "$d/docs/audora/memory/n.md"
run_hook memory-guard "$d/docs/audora/memory/n.md";         assert_eq 2 "$code" "/8 nó 120 linhas → 2"; assert_contains "$out" "n-historico.md" "/8 msg nó"
yes 'x' | head -120 > "$d/docs/audora/memory/n-historico.md"
run_hook memory-guard "$d/docs/audora/memory/n-historico.md"; assert_eq 0 "$code" "/8 -historico → 0"
mkdir -p "$d/docs/audora/nos"; yes 'x' | head -120 > "$d/docs/audora/nos/n.md"
run_hook memory-guard "$d/docs/audora/nos/n.md";            assert_eq 0 "$code" "/8 pasta nos/ antiga ignorada → 0"
report
