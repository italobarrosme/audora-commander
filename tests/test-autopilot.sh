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
no_ap ap x elegivel
run_hook memory-validate "$SP/ap/MEMORY.md"
assert_eq 0 "$code" "/12 autopilot: elegivel → exit 0"
no_ap ap x 'inelegivel (x/1)'
run_hook memory-validate "$SP/ap/MEMORY.md"
assert_eq 0 "$code" "/12 autopilot: inelegivel (x/1) → exit 0"

nt="$(cat templates/no-template.md 2>/dev/null)"
assert_contains "$nt" 'autopilot:' "/12 no-template documenta o campo"
assert_contains "$nt" 'inelegivel (<id>/<n>)' "/12 no-template documenta o enum completo"
assert_contains "$nt" 'pulado-por-autopilot-sem-ferramenta' "/9 enum de e2e do template ganha o valor novo"

# --- autopilot/1,/2,/3 — porta de entrada: declaração, catraca HIGH, tardia ---
ac="$(cat skills/audora-commander/SKILL.md 2>/dev/null)"
assert_contains "$ac" '## Autopilot' "/1 porta de entrada tem a seção"
assert_contains "$ac" 'roda até o validate' "/1 reconhece a frase de declaração"
assert_contains "$ac" 'autopilot: declarado' "/1 registra o campo no nó"
assert_contains "$ac" '**HIGH** → recusar' "/2 HIGH recusa"
assert_contains "$ac" 'NUNCA ofertar' "/2 ativação só espontânea"
assert_contains "$ac" 'ainda não cruzados' "/3 tardia antecipa só o restante"
assert_contains "$ac" 'checada e gravada na hora' "/3 tardia tem dono da gravação"
assert_contains "$ac" '(salvo autopilot' "/8 tabela de roteamento anota a exceção do e2e"

# --- autopilot/5,/6,/7 — scope: elegibilidade, portão antecipado, marcador ---
sc="$(cat skills/scope/SKILL.md 2>/dev/null)"
assert_contains "$sc" 'autopilot: elegivel' "/5 auto-revisão grava elegível"
assert_contains "$sc" 'autopilot: inelegivel (<id>/<n>)' "/5 inelegível cita o culpado"
assert_contains "$sc" 'portão antecipado' "/6 portão antecipado no scope"
assert_contains "$sc" 'a validate ratifica' "/6 ratificação no portão final"
assert_contains "$sc" 'a fase desmarcada e o marcador' "/7 marcador aberto para com bloco"
assert_contains "$sc" 'portão antecipado por autopilot elegível' "/6 red flag do portão anota a exceção"

# --- autopilot/4,/8,/9 — validate: e2e sem oferta; pulo registrado; LIGHT junto ---
v="$(cat skills/validate/SKILL.md 2>/dev/null)"
fl="$(awk '/^## Fluxo/{f=1;next} /^## /{f=0} f' skills/validate/SKILL.md)"
assert_contains "$fl" 'SEM pergunta' "/8 autopilot roda e2e sem perguntar (dentro do fluxo)"
assert_contains "$fl" 'projeto web' "/8 web com Playwright default conta como ferramenta"
assert_contains "$fl" 'e2e: pulado-por-autopilot-sem-ferramenta' "/9 pulo registrado no nó"
assert_contains "$fl" '`inelegivel` segue o fluxo normal' "/5 inelegível fora do autopilot na validate"
lt="$(awk '/^## Fechamento LIGHT/{f=1;next} /^## /{f=0} f' skills/validate/SKILL.md)"
assert_contains "$lt" 'Em autopilot, mesma condicional' "/4 Fechamento LIGHT preserva o carve-out interno"

# --- autopilot/10,/11,/13 — roteiro, contador e portão final inegociável ---
assert_contains "$v" 'Premissas e decisões tomadas sem portão' "/10 roteiro ganha a seção de premissas"
bf="$(awk '/^## Bloco de fechamento/{f=1;next} /^## /{f=0} f' skills/validate/SKILL.md)"
assert_contains "$bf" 'paradas humanas: N' "/11 contador no bloco de fechamento"
assert_contains "$bf" 'lotes de perguntas' "/11 contador discriminado por tipo de espera"
assert_contains "$bf" 'artefatos duráveis' "/11 N reconstituível fora da conversa"
# /13 — teste negativo: a FRASE INTEIRA do invariante, dentro da seção (a
# revisão adversarial provou por mutação que asserts separados eram enganáveis).
ap="$(awk '/^## Autopilot no portão/{f=1;next} /^## /{f=0} f' skills/validate/SKILL.md)"
assert_contains "$ap" 'portão final NUNCA é antecipado' "/13 invariante em frase inteira, dentro da seção"

# --- autopilot/14 — fundamentos: coluna no P4, regra no P5 ---
fu="$(cat docs/fundamentos.md 2>/dev/null)"
assert_contains "$fu" '| Autopilot |' "/14 tabela do P4 ganha a coluna"
assert_contains "$fu" '| LEVE | executar → validar | resultado | resultado (e2e sem oferta) |' "/14 linha LEVE completa na tabela"
assert_contains "$fu" '**Portão antecipado por declaração**' "/14 P5 ganha a regra nomeada"

# --- achado 8 da revisão — e2e reconhece a declaração como decisão do humano ---
e2s="$(cat skills/e2e/SKILL.md 2>/dev/null)"
assert_contains "$e2s" 'decisão do humano, antecipada' "/8 skill e2e sem contradição com o pulo automático"
report
