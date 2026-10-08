#!/usr/bin/env bash
# memoria-integra/1..21 — critérios de HIGH no nó, ordem nó→índice, cleanup que não apaga o que o framework lê, aprendizados em arquivo próprio.
source "$(dirname "$0")/lib.sh"
mk() { # mk <nome> <linha1> <índice...>
  d="$SP/$1"; mkdir -p "$d/docs/audora/memory"
  printf '%s\n\n## Propósito [carga: sempre]\n\nx\n\n## Constituição [carga: sempre]\n\n- **stack**: x\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n%s\n' "$2" "$3" > "$d/MEMORY.md"
}
no() { printf -- '---\nid: %s\nestado: %s\norigem: humano\ndepende-de: [%s]\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-08-26\n---\n# %s\n' "$2" "$3" "$4" "$2" > "$SP/$1/docs/audora/memory/$2.md"; }
# achata <arq...> → texto sem \r, quebras viram espaço, espaços colapsados
achata() { cat "$@" 2>/dev/null | tr -d '\r' | tr '\n' ' ' | tr -s ' '; }
# casa_ci <regex perl> <arq...> → nomes dos arquivos cujo texto achatado casa, sem caixa (UTF-8)
casa_ci() { local re="$1"; shift; RE="$re" perl -CSD -Mutf8 -0777 -ne 'BEGIN{$r=$ENV{RE}; utf8::decode($r)} s/\s+/ /g; print "$ARGV\n" if /$r/i' "$@"; }

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

# /7 — regra única: arquivo do nó primeiro, linha do índice logo depois
cd "$ROOT"
assert_empty "$(casa_ci 'mesma edição' skills/memory/SKILL.md skills/memory/references/*.md templates/MEMORY-template.md templates/no-template.md)" "memoria-integra/7 sem 'mesma edição'"
assert_contains "$(achata skills/memory/references/registrar-no.md)" 'arquivo do nó primeiro, linha do índice logo depois — na criação e na transição de estado' "memoria-integra/7 registrar-no traz a regra"
assert_contains "$(achata skills/memory/SKILL.md)" 'Arquivo do nó primeiro, linha do índice logo depois.' "memoria-integra/7 red flag da memory"
assert_contains "$(achata templates/MEMORY-template.md)" 'Arquivo do nó primeiro, linha do índice logo depois (criação e transição)' "memoria-integra/7 regra 1 do MEMORY-template"
assert_contains "$(achata templates/no-template.md)" '(arquivo do nó primeiro, linha do índice logo depois)' "memoria-integra/7 no-template"

# /1 — scope grava critérios de HIGH no nó; spec só contexto
sc="$(achata skills/scope/SKILL.md)"
assert_contains "$sc" 'MEDIUM e HIGH: os três campos direto no nó, critérios numerados em `## criterios-aceite`' "memoria-integra/1 critérios no nó"
assert_contains "$sc" 'só com contexto (pesquisa, alternativas, diagramas) — nunca critério' "memoria-integra/1 spec só contexto"
assert_not_contains "$sc" 'nó aponta para ela' "memoria-integra/1 nó não aponta para a spec"
assert_not_contains "$sc" 'ou a spec dedicada (HIGH)' "memoria-integra/1 fechamento sem spec como artefato de critério"

# /2 e /3 — sync copia critérios da spec antes do git mv; sem critério, para
sy="$(achata skills/validate/references/sync.md)"
assert_contains "$sy" 'Antes do `git mv`' "memoria-integra/2 sync: Antes do git mv"
assert_contains "$sy" 'copie literalmente cada um (a linha e suas continuações) para `## criterios-aceite` do nó' "memoria-integra/2 sync copia literal da spec"
assert_contains "$sy" 'Nó <id> sem critério numerado — sync parado, nada arquivado.' "memoria-integra/3 sync para e nomeia o nó"
assert_contains "$sy" 'nó primeiro, índice depois' "memoria-integra/2 sync mantém a ordem da transição"
conta="$(tr -d '\r' < skills/validate/references/sync.md | perl -ne 'print "$1\n" if /`(awk \x27\/\^## criterios-aceite\/[^`]*)`/' | head -1)"
assert_contains "$conta" "docs/audora/memory/<id>.md | grep -cE '" "memoria-integra/2 comando de contagem no sync"
conta="${conta//<id>/z}"
fz="$SP/f23"; mkdir -p "$fz/docs/audora/memory"
printf -- '# z\n\n## criterios-aceite\n\n- **z/1** — QUANDO a O SISTEMA DEVE b\n- **z/2** — QUANDO c O SISTEMA DEVE d\n\n## delta\n\n- z/3 citado\n' > "$fz/docs/audora/memory/z.md"
assert_eq 2 "$(cd "$fz" && bash -c "$conta")" "memoria-integra/2 conta 2 critérios do nó"
printf -- '# z\n\n## criterios-aceite\n\n## delta\n\n- ADICIONADO z/3\n' > "$fz/docs/audora/memory/z.md"
assert_eq 0 "$(cd "$fz" && bash -c "$conta")" "memoria-integra/3 critério só no delta não conta"
printf -- '# z\n\n## criterios-aceite\n\n- **zz/1** — QUANDO a O SISTEMA DEVE b\n' > "$fz/docs/audora/memory/z.md"
assert_eq 0 "$(cd "$fz" && bash -c "$conta")" "memoria-integra/3 critério de outro id não conta"

report
