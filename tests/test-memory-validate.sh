#!/usr/bin/env bash
# memory-graphify/8 — memory-validate acusa cada classe de inconsistência (exit 2) e cala fora do MEMORY (exit 0).
source "$(dirname "$0")/lib.sh"
mk() { # mk <nome> <linha1> <índice...>
  d="$SP/$1"; mkdir -p "$d/docs/audora/memory"
  printf '%s\n\n## Propósito [carga: sempre]\n\nx\n\n## Constituição [carga: sempre]\n\n- **stack**: x\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n%s\n' "$2" "$3" > "$d/MEMORY.md"
}
no() { printf -- '---\nid: %s\nestado: %s\norigem: humano\ndepende-de: [%s]\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-08-26\n---\n# %s\n' "$2" "$3" "$4" "$2" > "$SP/$1/docs/audora/memory/$2.md"; }

mk ok 'memory-schema: 1' '- x | in-progress | X | r | k | —'; no ok x in-progress ''
run_hook memory-validate "$SP/ok/MEMORY.md";            assert_eq 0 "$code" "/8 ok → 0"; assert_empty "$out" "/8 ok stderr vazio"
run_hook memory-validate "$SP/ok/docs/audora/memory/x.md"; assert_eq 0 "$code" "/8 ok via nó → 0"

mk sem-arq 'memory-schema: 1' '- x | in-progress | X | r | k | —'
run_hook memory-validate "$SP/sem-arq/MEMORY.md";       assert_eq 2 "$code" "/8 nó sem arquivo → 2"; assert_contains "$out" "sem arquivo docs/audora/memory/x.md" "/8 msg sem arquivo"

mk orfao 'memory-schema: 1' ''; no orfao y planned ''
run_hook memory-validate "$SP/orfao/MEMORY.md";         assert_eq 2 "$code" "/8 arquivo sem índice → 2"; assert_contains "$out" "sem linha no índice" "/8 msg órfão"

mk enum 'memory-schema: 1' '- x | em-curso | X | r | k | —'; no enum x em-curso ''
run_hook memory-validate "$SP/enum/MEMORY.md";          assert_eq 2 "$code" "/8 estado fora do enum → 2"; assert_contains "$out" "fora do enum" "/8 msg enum"; assert_contains "$out" "/templates/no-template.md" "/8 msg cita template absoluto"

mk sempipe 'memory-schema: 1' '- nota sem pipe'
run_hook memory-validate "$SP/sempipe/MEMORY.md";       assert_eq 2 "$code" "/8 linha sem estado → 2"; assert_contains "$out" "sem coluna de estado" "/8 msg sem estado"

mk dep 'memory-schema: 1' '- x | planned | X | r | k | —'; no dep x planned 'nao-existe'
run_hook memory-validate "$SP/dep/MEMORY.md";           assert_eq 2 "$code" "/8 dep inexistente → 2"; assert_contains "$out" "depende de 'nao-existe'" "/8 msg dep"

mk ciclo 'memory-schema: 1' $'- a | planned | A | r | k | —\n- b | planned | B | r | k | —'; no ciclo a planned 'b'; no ciclo b planned 'a'
run_hook memory-validate "$SP/ciclo/MEMORY.md";         assert_eq 2 "$code" "/8 ciclo → 2"; assert_contains "$out" "ciclo em depende-de" "/8 msg ciclo"

d="$SP/secao"; mkdir -p "$d/docs/audora/memory"; printf 'memory-schema: 1\n\n## Índice de nós [carga: sempre]\n\n' > "$d/MEMORY.md"
run_hook memory-validate "$d/MEMORY.md";                assert_eq 2 "$code" "/4 seção ausente → 2"; assert_contains "$out" "'## Aprendizados'" "/4 msg cita Aprendizados"

mk semschema 'versao-schema: 2' '- x | em-curso | X | r | k | —'
run_hook memory-validate "$SP/semschema/MEMORY.md";     assert_eq 0 "$code" "/8 sem memory-schema → 0 (não é nosso)"
mkdir -p "$SP/g/docs/audora/nos"; printf 'versao-schema: 2\n\n## Índice de nós [carga: sempre]\n\n- x | em-curso | X\n' > "$SP/g/GRAFO.md"
run_hook memory-validate "$SP/g/GRAFO.md";              assert_eq 0 "$code" "/8 GRAFO.md ignorado → 0"
run_hook memory-validate "$SP/ok/qualquer.txt";         assert_eq 0 "$code" "/8 fora do MEMORY → 0"
out="$(echo 'nao-json' | bash "$ROOT/hooks/memory-validate" 2>&1)"; assert_eq 0 "$?" "/8 JSON inválido → 0"
report
