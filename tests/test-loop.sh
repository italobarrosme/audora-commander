#!/usr/bin/env bash
# loop-motor/1..15 — motor headless: pré-condições, volta, paradas, retomada.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1

# --- loop-motor/5 — template do prompt da volta ---
assert_file templates/loop-prompt-template.md "/5 template do prompt existe"
lp="$(cat templates/loop-prompt-template.md 2>/dev/null)"
for s in '{{NO}}' '{{PLANO}}' '{{TAREFA}}' '{{ID}}'; do
  assert_contains "$lp" "$s" "/5 placeholder $s"
done
for s in 'UMA tarefa' 'Procurar antes de criar' 'placeholder' 'NÃO commitar' \
         'NÃO marcar checkbox' 'NÃO tocar outra tarefa' 'NÃO rodar o gate'; do
  assert_contains "$lp" "$s" "/5 regra: $s"
done
assert_contains "$lp" 'concluida-pelo-motor' "/5 contrato do marcador citado"

# --- fixture do motor: projeto git, MEMORY, plano, fake claude e fake gate ---
LM="$ROOT/hooks/loop"
lproj="$SP/lproj"
mkloop() {
  rm -rf "$lproj"
  mkdir -p "$lproj/docs/audora/memory" "$lproj/docs/audora/planos" "$lproj/bin"
  git -C "$lproj" init -q
  git -C "$lproj" config user.email l@t; git -C "$lproj" config user.name l
  git -C "$lproj" config core.autocrlf false
  printf '%s\n' '#!/usr/bin/env bash' 'f="$(dirname "$0")/../gate-verdicts.txt"' 'v="$(head -1 "$f" 2>/dev/null)"; tail -n +2 "$f" > "$f.t" 2>/dev/null; mv "$f.t" "$f" 2>/dev/null' '[ "$v" = verde ] && { echo "GATE: passou"; exit 0; }' 'echo "GATE: reprovado — suite falhou"; exit 1' > "$lproj/bin/fake-gate"
  printf '%s\n' '#!/usr/bin/env bash' 'd="$(dirname "$0")/.."' 'echo "$@" >> "$d/claude-calls.log"' 'echo "obra da volta" >> "$d/obra.txt"' 'printf "{\"result\":\"ok\",\"total_cost_usd\":%s}\n" "${FAKE_COST:-0.05}"' > "$lproj/bin/claude"
  chmod +x "$lproj/bin/fake-gate" "$lproj/bin/claude"
  { printf 'memory-schema: 1\n\n## Propósito [carga: sempre]\n\nfixture\n\n## Constituição [carga: sempre]\n\n- **stack**: bash\n- **gate**: bash bin/fake-gate <id-da-demanda>\n- **sandbox**: docker\n- **loop**: voltas-tarefa=2 voltas-rodada=5 custo-usd=1\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n- d1 | in-progress | D1 | r | k | —\n'; } > "$lproj/MEMORY.md"
  printf -- '---\nid: d1\nestado: in-progress\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: []\nresumo: r\nautopilot: elegivel\natualizado-em: 2026-09-05\n---\n# d1\n\n## criterios-aceite\n\n- **d1/1** — QUANDO rodar O SISTEMA DEVE somar\n' > "$lproj/docs/audora/memory/d1.md"
  printf '# Plano — d1\n\n## Tarefa 1: primeira\n\n- **depende-de**: []\n- **requisito**: d1/1\n\n## Tarefa 2: segunda\n\n- **depende-de**: [Tarefa 1]\n- **requisito**: d1/1\n\n## Notas de sessão\n' > "$lproj/docs/audora/planos/plano-d1.md"
  git -C "$lproj" add -A; git -C "$lproj" commit -qm base
  git -C "$lproj" checkout -qb demanda-d1
}
runloop() { out="$(cd "$lproj" && PATH="$lproj/bin:$PATH" LOOP_ROOT="$lproj" bash "$LM" "$@" 2>&1)"; code=$?; }

# --- loop-motor/1..4 — pré-condições ---
assert_file "$LM" "/1 hooks/loop existe"
mkloop; runloop d1
assert_eq 0 "$code" "/1 fixture completa → pré-condições OK"
assert_contains "$out" 'pré-condições OK' "/1 mensagem de OK"
mkloop; git -C "$lproj" checkout -q -
sed -i 's/^autopilot: elegivel/autopilot: declarado/' "$lproj/docs/audora/memory/d1.md"
sed -i '/^- \*\*gate\*\*/d' "$lproj/MEMORY.md"
runloop d1
assert_eq 1 "$code" "/1 recusa → exit 1"
assert_contains "$out" 'autopilot: elegivel' "/1 nomeia a elegibilidade ausente"
assert_contains "$out" 'branch própria' "/1 nomeia a branch"
assert_contains "$out" "bullet 'gate:'" "/1 nomeia o gate ausente"
mkloop; sed -i '/^- \*\*sandbox\*\*/d' "$lproj/MEMORY.md"; runloop d1
assert_eq 1 "$code" "/2 sem sandbox: → recusa"
assert_contains "$out" "bullet 'sandbox:'" "/2 nomeia o sandbox"
mkloop; sed -i 's/^- \*\*sandbox\*\*: docker/- **sandbox**: nenhum/' "$lproj/MEMORY.md"; runloop d1
assert_eq 1 "$code" "/3 nenhum sem confirmação → recusa"
assert_contains "$out" 'confirmo-sem-sandbox' "/3 diz qual flag falta"
runloop d1 --confirmo-sem-sandbox
assert_eq 0 "$code" "/3 confirmado → segue"
assert_contains "$out" 'AVISO' "/3 aviso impresso"
mkloop; sed -i '/^- \*\*loop\*\*/d' "$lproj/MEMORY.md"; runloop d1
assert_eq 1 "$code" "/4 sem teto nenhum → recusa"
assert_contains "$out" 'tetos' "/4 nomeia os tetos"
runloop d1 --voltas-tarefa 2 --voltas-rodada 5 --custo-usd 1
assert_eq 0 "$code" "/4 parâmetros suprem o bullet"
rm -rf "$lproj/.git"; runloop d1
assert_eq 1 "$code" "/1 sem git → recusa"
assert_contains "$out" 'repo git' "/1 nomeia o git"
report
