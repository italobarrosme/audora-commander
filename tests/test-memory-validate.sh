#!/usr/bin/env bash
# memory-validate acusa cada classe de inconsistência (exit 2) e cala fora do MEMORY (exit 0).
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

mk fed 'memory-schema: 1' '- x | planned | X | r | k | —'; no fed x planned 'ext:x'
run_hook memory-validate "$SP/fed/MEMORY.md";           assert_eq 2 "$code" "limpeza-codigo-morto/4 dep com ':' é id comum → 2"; assert_contains "$out" "depende de 'ext:x'" "limpeza-codigo-morto/4 msg"

mk ciclo 'memory-schema: 1' $'- a | planned | A | r | k | —\n- b | planned | B | r | k | —'; no ciclo a planned 'b'; no ciclo b planned 'a'
run_hook memory-validate "$SP/ciclo/MEMORY.md";         assert_eq 2 "$code" "/8 ciclo → 2"; assert_contains "$out" "ciclo em depende-de" "/8 msg ciclo"

d="$SP/secao"; mkdir -p "$d/docs/audora/memory"; printf 'memory-schema: 1\n\n## Índice de nós [carga: sempre]\n\n' > "$d/MEMORY.md"
run_hook memory-validate "$d/MEMORY.md";                assert_eq 2 "$code" "/4 seção ausente → 2"; assert_contains "$out" "'## Aprendizados'" "/4 msg cita Aprendizados"

mk semschema '# MEMORY de outra ferramenta' '- x | em-curso | X | r | k | —'
run_hook memory-validate "$SP/semschema/MEMORY.md";     assert_eq 0 "$code" "/8 sem memory-schema → 0 (não é nosso)"
run_hook memory-validate "$SP/ok/qualquer.txt";         assert_eq 0 "$code" "/8 fora do MEMORY → 0"
out="$(echo 'nao-json' | bash "$ROOT/hooks/memory-validate" 2>&1)"; assert_eq 0 "$?" "/8 JSON inválido → 0"

# validate-estado-no/1 — estado do NÓ fora do enum (índice válido) → 2
mk nenum 'memory-schema: 1' '- x | planned | X | r | k | —'; no nenum x planejado ''
run_hook memory-validate "$SP/nenum/docs/audora/memory/x.md"
assert_eq 2 "$code" "validate-estado-no/1 estado do nó fora do enum → 2"
assert_contains "$out" "docs/audora/memory/x.md" "validate-estado-no/1 msg nomeia o arquivo"
assert_contains "$out" "'planejado'" "validate-estado-no/1 msg nomeia o valor"
assert_contains "$out" "planned|in-progress|blocked|delivered|discarded|hotfix-pending-record" "validate-estado-no/1 msg cita o enum"
run_hook memory-validate "$SP/nenum/MEMORY.md"
assert_eq 2 "$code" "validate-estado-no/1 idem via MEMORY.md → 2"

# validate-estado-no/2 — nó sem estado: no frontmatter → 2 (estado: no CORPO não conta)
sem_estado() { printf -- '---\nid: %s\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-09-28\n---\n# %s\n\nestado: planned\n' "$2" "$2" > "$SP/$1/docs/audora/memory/$2.md"; }
mk nsem 'memory-schema: 1' '- x | planned | X | r | k | —'; sem_estado nsem x
run_hook memory-validate "$SP/nsem/docs/audora/memory/x.md"
assert_eq 2 "$code" "validate-estado-no/2 nó sem estado: → 2"
assert_contains "$out" "docs/audora/memory/x.md sem campo 'estado:'" "validate-estado-no/2 msg nomeia o arquivo"

# validate-estado-no/4 — escrita num nó BOM acusa OUTRO nó ruim
mk todos 'memory-schema: 1' $'- x | planned | X | r | k | —\n- y | planned | Y | r | k | —'; no todos x planned ''; no todos y planejado ''
run_hook memory-validate "$SP/todos/docs/audora/memory/x.md"
assert_eq 2 "$code" "validate-estado-no/4 escrita em x acusa y → 2"
assert_contains "$out" "docs/audora/memory/y.md" "validate-estado-no/4 msg nomeia o outro nó"

# validate-estado-no/5 — CRLF + espaços ao redor do valor → 0, sem falso positivo
mk crlf 'memory-schema: 1' '- x | in-progress | X | r | k | —'
printf -- '---\r\nid: x\r\nestado:   in-progress  \r\norigem: humano\r\ndepende-de: []\r\narquivos: []\r\nkeywords: []\r\nresumo: r\r\natualizado-em: 2026-09-28\r\n---\r\n# x\r\n' > "$SP/crlf/docs/audora/memory/x.md"
run_hook memory-validate "$SP/crlf/MEMORY.md"
assert_eq 0 "$code" "validate-estado-no/5 CRLF e espaços via MEMORY.md → 0"; assert_empty "$out" "validate-estado-no/5 stderr vazio"
run_hook memory-validate "$SP/crlf/docs/audora/memory/x.md"
assert_eq 0 "$code" "validate-estado-no/5 CRLF e espaços via nó → 0"

# validate-estado-no/6 — <id>-historico.md sem frontmatter é ignorado
printf '# x — histórico\n\nsem frontmatter\n' > "$SP/ok/docs/audora/memory/x-historico.md"
run_hook memory-validate "$SP/ok/MEMORY.md"
assert_eq 0 "$code" "validate-estado-no/6 histórico ignorado → 0"; assert_empty "$out" "validate-estado-no/6 stderr vazio"

# validate-estado-no/3 — índice in-progress, nó delivered, escrita no ÍNDICE → 2
mk div 'memory-schema: 1' '- x | in-progress | X | r | k | —'; no div x delivered ''
run_hook memory-validate "$SP/div/MEMORY.md"
assert_eq 2 "$code" "validate-estado-no/3 divergência na escrita do índice → 2"
assert_contains "$out" "nó 'x' com estado divergente: índice 'in-progress', arquivo 'delivered'" "validate-estado-no/3 msg nomeia nó e os dois valores"
# validate-estado-no/9 — mesma divergência, escrita no NÓ (1ª metade da transição) → 0
run_hook memory-validate "$SP/div/docs/audora/memory/x.md"
assert_eq 0 "$code" "validate-estado-no/9 divergência na escrita do nó → 0"; assert_empty "$out" "validate-estado-no/9 stderr vazio"
# validate-estado-no/7 — nó sem linha no índice: só o erro de órfão, sem divergência
run_hook memory-validate "$SP/orfao/MEMORY.md"
assert_contains "$out" "sem linha no índice" "validate-estado-no/7 órfão continua acusado"
assert_not_contains "$out" "divergente" "validate-estado-no/7 sem divergência duplicada"
report
