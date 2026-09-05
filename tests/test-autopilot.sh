#!/usr/bin/env bash
# autopilot/1..14 — declaração, catraca, elegibilidade, e2e sem oferta,
# contador de paradas e schema do campo autopilot:.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1

# --- autopilot/12 — schema: campo no template; hook aceita campo desconhecido ---
# Caracterização (VERDE por design, roda como regressão): memory-validate só lê
# depende-de do frontmatter — nó com autopilot: declarado passa sem exit 2.
mk() {
  d="$SP/$1"; mkdir -p "$d/docs/audora/memory"
  printf '%s\n\n## Propósito [carga: sempre]\n\nx\n\n## Constituição [carga: sempre]\n\n- **stack**: x\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n%s\n' 'memory-schema: 1' "$2" > "$d/MEMORY.md"
}
no_ap() { printf -- '---\nid: %s\nestado: in-progress\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: []\nresumo: r\nautopilot: %s\natualizado-em: 2026-09-04\n---\n# %s\n' "$2" "$3" "$2" > "$SP/$1/docs/audora/memory/$2.md"; }
mk ap '- x | in-progress | X | r | k | —'; no_ap ap x declarado
run_hook memory-validate "$SP/ap/MEMORY.md"
assert_eq 0 "$code" "/12 nó com autopilot: declarado → hook exit 0"
assert_empty "$out" "/12 stderr vazio (campo desconhecido ignorado)"
run_hook memory-validate "$SP/ap/docs/audora/memory/x.md"
assert_eq 0 "$code" "/12 via arquivo do nó → exit 0"

nt="$(cat templates/no-template.md 2>/dev/null)"
assert_contains "$nt" 'autopilot:' "/12 no-template documenta o campo"
assert_contains "$nt" 'inelegivel (<id>/<n>)' "/12 no-template documenta o enum completo"

# --- autopilot/1,/2,/3 — porta de entrada: declaração, catraca HIGH, tardia ---
ac="$(cat skills/audora-commander/SKILL.md 2>/dev/null)"
assert_contains "$ac" '## Autopilot' "/1 porta de entrada tem a seção"
assert_contains "$ac" 'roda até o validate' "/1 reconhece a frase de declaração"
assert_contains "$ac" 'autopilot: declarado' "/1 registra o campo no nó"
assert_contains "$ac" '**HIGH** → recusar' "/2 HIGH recusa"
assert_contains "$ac" 'NUNCA ofertar' "/2 ativação só espontânea"
assert_contains "$ac" 'ainda não cruzados' "/3 tardia antecipa só o restante"

# --- autopilot/5,/6,/7 — scope: elegibilidade, portão antecipado, marcador ---
sc="$(cat skills/scope/SKILL.md 2>/dev/null)"
assert_contains "$sc" 'autopilot: elegivel' "/5 auto-revisão grava elegível"
assert_contains "$sc" 'autopilot: inelegivel (<id>/<n>)' "/5 inelegível cita o culpado"
assert_contains "$sc" 'portão antecipado' "/6 portão antecipado no scope"
assert_contains "$sc" 'a validate ratifica' "/6 ratificação no portão final"
assert_contains "$sc" 'a fase desmarcada e o marcador' "/7 marcador aberto para com bloco"
report
