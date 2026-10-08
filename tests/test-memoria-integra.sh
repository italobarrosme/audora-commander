#!/usr/bin/env bash
# memoria-integra/1..21 — critérios de HIGH no nó, ordem nó→índice, cleanup que não apaga o que o framework lê, aprendizados em arquivo próprio.
source "$(dirname "$0")/lib.sh"
mk() { # mk <nome> <linha1> <índice...>
  d="$SP/$1"; mkdir -p "$d/docs/audora/memory"
  printf '%s\n\n## Propósito [carga: sempre]\n\nx\n\n## Constituição [carga: sempre]\n\n- **stack**: x\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n%s\n' "$2" "$3" > "$d/MEMORY.md"
}
no() { printf -- '---\nid: %s\nestado: %s\norigem: humano\ndepende-de: [%s]\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-08-26\n---\n# %s\n' "$2" "$3" "$4" "$2" > "$SP/$1/docs/audora/memory/$2.md"; }

# /5 e /6 — órfão (arquivo sem linha no índice) só é cobrado na escrita do índice
mk n5 'memory-schema: 1' '- x | in-progress | X | r | k | —'; no n5 x in-progress ''; no n5 novo planned ''
run_hook memory-validate "$SP/n5/docs/audora/memory/novo.md"
assert_eq 0 "$code" "memoria-integra/5 nó novo planned antes da linha → 0"; assert_empty "$out" "memoria-integra/5 nó novo planned sem saída"
no n5 novo in-progress ''
run_hook memory-validate "$SP/n5/docs/audora/memory/novo.md"
assert_eq 0 "$code" "memoria-integra/5 nó novo in-progress antes da linha → 0"; assert_empty "$out" "memoria-integra/5 nó novo in-progress sem saída"
no n5 novo planejado ''
run_hook memory-validate "$SP/n5/docs/audora/memory/novo.md"
assert_eq 2 "$code" "memoria-integra/5 enum segue cobrado na escrita do nó → 2"
assert_contains "$out" "planejado" "memoria-integra/5 msg do enum"
assert_not_contains "$out" "sem linha no índice" "memoria-integra/5 só o órfão é adiado"
no n5 novo planned ''
run_hook memory-validate "$SP/n5/MEMORY.md"
assert_eq 2 "$code" "memoria-integra/6 escrita do índice com órfão → 2"
assert_contains "$out" "novo.md sem linha no índice mestre" "memoria-integra/6 msg do órfão"

report
