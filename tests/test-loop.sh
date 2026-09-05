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
  rm -rf "$lproj" "$SP/lbin"
  mkdir -p "$lproj/docs/audora/memory" "$lproj/docs/audora/planos" "$SP/lbin"
  git -C "$lproj" init -q
  git -C "$lproj" config user.email l@t; git -C "$lproj" config user.name l
  git -C "$lproj" config core.autocrlf false
  # fakes vivem FORA da árvore do repo (o descarte do vermelho roda git clean)
  printf '%s\n' '#!/usr/bin/env bash' 'f="$(dirname "$0")/gate-verdicts.txt"' 'v="$(head -1 "$f" 2>/dev/null)"; tail -n +2 "$f" > "$f.t" 2>/dev/null; mv "$f.t" "$f" 2>/dev/null' '[ "$v" = verde ] && { echo "GATE: passou"; exit 0; }' 'echo "GATE: reprovado — suite falhou"; exit 1' > "$SP/lbin/fake-gate"
  printf '%s\n' '#!/usr/bin/env bash' 'echo "$@" >> "$(dirname "$0")/claude-calls.log"' 'case "${FAKE_MODE:-work}" in' '  work) echo "obra da volta" >> ./alvo.txt ;;' '  newfile) echo novo > ./novo-arquivo.txt ;;' '  rogue) echo "obra da volta" >> ./alvo.txt; git add -A >/dev/null 2>&1; git commit -qm rogue-do-agente >/dev/null 2>&1 ;;' '  tamper) sed -i "s/^## Tarefa 2:.*/&\n- [x] concluida-pelo-motor (fraude)/" ./docs/audora/planos/plano-d1.md; echo obra >> ./alvo.txt ;;' '  noop-fail) exit 1 ;;' 'esac' 'printf "{\"result\":\"ok\",\"total_cost_usd\":%s}\n" "${FAKE_COST:-0.05}"' > "$SP/lbin/claude"
  chmod +x "$SP/lbin/fake-gate" "$SP/lbin/claude"
  printf 'verde\nverde\nverde\n' > "$SP/lbin/gate-verdicts.txt"
  printf 'linha base\n' > "$lproj/alvo.txt"
  { printf 'memory-schema: 1\n\n## Propósito [carga: sempre]\n\nfixture\n\n## Constituição [carga: sempre]\n\n- **stack**: bash\n- **gate**: bash ../lbin/fake-gate <id-da-demanda>\n- **sandbox**: docker\n- **loop**: voltas-tarefa=2 voltas-rodada=5 custo-usd=1\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n- d1 | in-progress | D1 | r | k | —\n'; } > "$lproj/MEMORY.md"
  printf -- '---\nid: d1\nestado: in-progress\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: []\nresumo: r\nautopilot: elegivel\natualizado-em: 2026-09-05\n---\n# d1\n\n## criterios-aceite\n\n- **d1/1** — QUANDO rodar O SISTEMA DEVE somar\n' > "$lproj/docs/audora/memory/d1.md"
  printf '# Plano — d1\n\n## Tarefa 1: primeira\n\n- **depende-de**: []\n- **requisito**: d1/1\n\n## Tarefa 2: segunda\n\n- **depende-de**: [Tarefa 1]\n- **requisito**: d1/1\n\n## Notas de sessão\n' > "$lproj/docs/audora/planos/plano-d1.md"
  git -C "$lproj" add -A; git -C "$lproj" commit -qm base
  git -C "$lproj" checkout -qb demanda-d1
}
runloop() { out="$(cd "$lproj" && PATH="$SP/lbin:$PATH" LOOP_ROOT="$lproj" bash "$LM" "$@" 2>&1)"; code=$?; }

# --- loop-motor/1..4 — pré-condições ---
assert_file "$LM" "/1 hooks/loop existe"
mkloop; runloop d1
assert_eq 0 "$code" "/1 fixture completa → pré-condições OK"
assert_contains "$out" 'pré-condições OK' "/1 mensagem de OK"
mkloop; git -C "$lproj" checkout -q -; git -C "$lproj" branch -m main 2>/dev/null || true
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

# --- loop-motor/5..9,/13 — rodada feliz: 2 voltas verdes, DONE, métricas ---
mkloop; printf 'verde\nverde\n' > "$SP/lbin/gate-verdicts.txt"
runloop d1
assert_eq 0 "$code" "/9 rodada feliz → exit 0"
assert_contains "$out" 'DONE' "/9 imprime DONE"
assert_contains "$out" 'validate' "/9 aponta a preparação de evidência da validate"
assert_eq 2 "$(git -C "$lproj" log --oneline | grep -c 'verde — tarefa')" "/7 dois commits verdes do motor"
assert_contains "$(git -C "$lproj" log --format=%s -2)" 'd1/1' "/7 commit cita o endereço do critério"
assert_eq 2 "$(grep -c 'concluida-pelo-motor' "$lproj/docs/audora/planos/plano-d1.md")" "/7 duas tarefas marcadas pelo motor"
p1="$lproj/docs/audora/planos/loop/d1/rodada1-volta1-prompt.txt"
assert_file "$p1" "/5 prompt da volta 1 salvo"
t1sec="$(awk '/=== SUA TAREFA/{f=1;next} /=== REGRAS/{f=0} f' "$p1")"
assert_contains "$t1sec" '## Tarefa 1: primeira' "/5 volta 1 recebe a tarefa 1"
assert_not_contains "$t1sec" '## Tarefa 2' "/5 tarefa 2 fora da seção da volta 1"
assert_contains "$(cat "$SP/lbin/claude-calls.log")" '--max-budget-usd' "/5 claude chamado com teto de custo"
assert_contains "$(cat "$SP/lbin/claude-calls.log")" '--output-format json' "/5 claude chamado com saída json"
assert_contains "$(cat "$lproj/docs/audora/planos/plano-d1.md")" 'Métricas de rodada' "/13 métricas gravadas no plano"
assert_contains "$out" 'custo' "/13 custo no fechamento"

# --- loop-motor/8 — vermelho: patch salvo, árvore limpa, sem commit, nota ---
mkloop; printf 'vermelho\nverde\nverde\n' > "$SP/lbin/gate-verdicts.txt"
runloop d1
assert_eq 0 "$code" "/8 vermelha + verdes seguintes → DONE"
assert_file "$lproj/docs/audora/planos/loop/d1/rodada1-volta1.patch" "/8 patch da volta vermelha salvo"
assert_eq 2 "$(grep -c 'obra da volta' "$lproj/alvo.txt")" "/8 obra da vermelha descartada da árvore"
assert_eq 2 "$(git -C "$lproj" log --oneline | grep -c 'verde — tarefa')" "/8 vermelha não commita"
notasec="$(awk '/^## Notas de sessão/{f=1;next} /^## /{f=0} f' "$lproj/docs/audora/planos/plano-d1.md")"
assert_contains "$notasec" 'GATE: reprovado' "/8 saída do gate DENTRO da seção Notas de sessão"

# --- loop-motor/10 — nunca-verde → blocked no arquivo e no índice ---
mkloop; printf 'vermelho\nvermelho\nvermelho\n' > "$SP/lbin/gate-verdicts.txt"
runloop d1
assert_eq 1 "$code" "/10 nunca-verde → exit 1"
assert_contains "$out" 'blocked' "/10 anuncia o blocked"
assert_contains "$(cat "$lproj/docs/audora/memory/d1.md")" 'estado: blocked' "/10 nó vira blocked"
assert_contains "$(cat "$lproj/MEMORY.md")" '- d1 | blocked |' "/10 índice vira blocked"

# --- loop-motor/11 — tetos param: voltas da rodada e custo ---
mkloop; printf 'vermelho\nvermelho\nvermelho\nvermelho\n' > "$SP/lbin/gate-verdicts.txt"
runloop d1 --voltas-tarefa 99 --voltas-rodada 3 --custo-usd 9
assert_eq 1 "$code" "/11 teto de voltas → exit 1"
assert_contains "$out" 'teto de voltas' "/11 nomeia o teto de voltas"
assert_eq 0 "$(grep -c 'concluida-pelo-motor' "$lproj/docs/audora/planos/plano-d1.md")" "/11 plano retomável sem marca falsa"
mkloop; printf 'vermelho\nvermelho\n' > "$SP/lbin/gate-verdicts.txt"
FAKE_COST=0.6 runloop d1 --voltas-tarefa 99 --voltas-rodada 99 --custo-usd 1
assert_eq 1 "$code" "/11 teto de custo → exit 1"
assert_contains "$out" 'teto de custo' "/11 nomeia o teto de custo"

# --- loop-motor/12 — marcador aberto para ANTES de qualquer volta ---
mkloop; printf '\n[PRECISA-CLARIFICAR: qual formato?]\n' >> "$lproj/docs/audora/planos/plano-d1.md"
runloop d1
assert_eq 1 "$code" "/12 marcador → exit 1"
assert_contains "$out" 'aguardando humano' "/12 bloco aguardando humano"
assert_no_file "$SP/lbin/claude-calls.log" "/12 zero volta executada"

# --- loop-motor/9 — plano sem tarefa aberta → DONE imediato ---
mkloop; printf '# Plano — d1\n\n## Notas de sessão\n' > "$lproj/docs/audora/planos/plano-d1.md"
runloop d1
assert_eq 0 "$code" "/9 plano sem tarefa → exit 0"
assert_contains "$out" 'DONE' "/9 DONE imediato"
assert_no_file "$SP/lbin/claude-calls.log" "/9 zero claude"

# --- loop-motor/15 — retomada: rodada 2 continua da primeira aberta ---
mkloop; printf 'verde\n' > "$SP/lbin/gate-verdicts.txt"
runloop d1 --voltas-tarefa 2 --voltas-rodada 1 --custo-usd 9
assert_eq 1 "$code" "/15 rodada 1 para no teto"
printf 'verde\n' > "$SP/lbin/gate-verdicts.txt"
runloop d1 --voltas-tarefa 2 --voltas-rodada 9 --custo-usd 9
assert_eq 0 "$code" "/15 rodada 2 → DONE"
assert_contains "$out" 'rodada 2' "/15 numera a rodada nova"
p2="$lproj/docs/audora/planos/loop/d1/rodada2-volta1-prompt.txt"
t2sec="$(awk '/=== SUA TAREFA/{f=1;next} /=== REGRAS/{f=0} f' "$p2" 2>/dev/null)"
assert_contains "$t2sec" '## Tarefa 2: segunda' "/15 retoma na tarefa 2, sem refazer a 1"

# --- achados da revisão adversarial (ALTOs 1-4, MÉDIOs 5-9, BAIXOs 11-12) ---
# A1: claude falha/não trabalha → violação, nunca DONE
mkloop; FAKE_MODE=noop-fail runloop d1 --voltas-tarefa 2 --voltas-rodada 9 --custo-usd 9
assert_eq 1 "$code" "A1 claude falhando → exit 1"
assert_contains "$out" 'VIOLAÇÃO' "A1 violação anunciada"
assert_eq 0 "$(grep -c 'concluida-pelo-motor' "$lproj/docs/audora/planos/plano-d1.md")" "A1 nenhuma tarefa marcada"
assert_eq 0 "$(git -C "$lproj" log --oneline | grep -c 'verde — tarefa')" "A1 nenhum commit verde"
# A2: vermelho com arquivo NOVO → patch não-vazio e árvore limpa
mkloop; printf 'vermelho\nvermelho\nvermelho\n' > "$SP/lbin/gate-verdicts.txt"
FAKE_MODE=newfile runloop d1
assert_contains "$(cat "$lproj/docs/audora/planos/loop/d1/rodada1-volta1.patch" 2>/dev/null)" 'novo-arquivo' "A2 patch captura o arquivo novo"
assert_no_file "$lproj/novo-arquivo.txt" "A2 arquivo novo descartado da árvore"
# A3: commit rogue do agente → desfeito, violação
mkloop; FAKE_MODE=rogue runloop d1 --voltas-tarefa 1 --voltas-rodada 9 --custo-usd 9
assert_eq 1 "$code" "A3 rogue → exit 1"
assert_contains "$out" 'commitou por conta própria' "A3 nomeia a violação"
assert_eq 0 "$(git -C "$lproj" log --oneline | grep -c 'rogue-do-agente')" "A3 commit rogue desfeito da história"
# A4: agente frauda o plano → violação, plano restaurado
mkloop; FAKE_MODE=tamper runloop d1 --voltas-tarefa 1 --voltas-rodada 9 --custo-usd 9
assert_eq 1 "$code" "A4 fraude no plano → exit 1"
assert_contains "$out" 'artefato do motor' "A4 nomeia a violação"
assert_eq 0 "$(grep -c 'fraude' "$lproj/docs/audora/planos/plano-d1.md")" "A4 plano restaurado"
# M5: métricas da rodada 1 sobrevivem ao vermelho da rodada 2
mkloop; runloop d1 --voltas-tarefa 2 --voltas-rodada 1 --custo-usd 9
printf 'vermelho\nvermelho\nvermelho\n' > "$SP/lbin/gate-verdicts.txt"
runloop d1 --voltas-tarefa 2 --voltas-rodada 9 --custo-usd 9
assert_contains "$(cat "$lproj/docs/audora/planos/plano-d1.md")" '- rodada 1: voltas=' "M5 métricas da rodada 1 duráveis"
# M6: prosa citando o marcador NÃO conta como concluída
mkloop; sed -i 's/^- \*\*requisito\*\*: d1\/1$/- **requisito**: d1\/1 (sem tocar em concluida-pelo-motor)/' "$lproj/docs/audora/planos/plano-d1.md"
runloop d1
assert_eq 0 "$code" "M6 prosa com o termo → rodada normal"
assert_eq 2 "$(git -C "$lproj" log --oneline | grep -c 'verde — tarefa')" "M6 as duas tarefas rodaram"
# M7: teto não-numérico → recusa
mkloop; runloop d1 --custo-usd 0,5
assert_eq 1 "$code" "M7 teto com vírgula → recusa"
assert_contains "$out" 'teto inválido' "M7 nomeia o teto inválido"
# M9: heading de tarefa fora do formato → recusa antes de gastar
mkloop; sed -i 's/^## Tarefa 1: primeira/## Tarefa 1 — primeira/' "$lproj/docs/audora/planos/plano-d1.md"
runloop d1
assert_eq 1 "$code" "M9 plano fora do formato → recusa"
assert_contains "$out" 'formato' "M9 nomeia o formato"
assert_no_file "$SP/lbin/claude-calls.log" "M9 zero volta gasta"
# B12: gate recusado com sufixo → recusa igual
mkloop; sed -i 's/^- \*\*gate\*\*:.*/- **gate**: recusado — decidir depois/' "$lproj/MEMORY.md"
runloop d1
assert_eq 1 "$code" "B12 recusado com sufixo → recusa"
assert_contains "$out" "bullet 'gate:'" "B12 nomeia o gate"

# --- cobertura documental: execute, validate e Constituição ---
ex="$(cat skills/execute/SKILL.md 2>/dev/null)"
assert_contains "$ex" '## Volta de loop' "execute declara a seção da volta"
assert_contains "$ex" 'NÃO roda o gate' "execute: volta não roda o gate"
assert_contains "$ex" 'o motor roda o gate' "execute: quem roda é o motor"
vv="$(cat skills/validate/SKILL.md 2>/dev/null)"
assert_contains "$vv" 'Relatório de rodada' "validate recebe o relatório do motor"
assert_contains "$vv" 'Métricas de rodada (loop)' "validate aponta a seção do plano"
mm2="$(cat MEMORY.md 2>/dev/null)"
assert_contains "$mm2" '**loop**:' "Constituição registra os tetos default"
assert_contains "$mm2" 'voltas-tarefa=3 voltas-rodada=12 custo-usd=10' "tetos propostos e ratificáveis"
report
