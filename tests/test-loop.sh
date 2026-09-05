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
report
