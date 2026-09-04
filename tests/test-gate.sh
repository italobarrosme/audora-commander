#!/usr/bin/env bash
# gate-mecanico/1..11 — template do gate, instância dogfood, ofertas e skills.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1

# --- gate-mecanico/1 — template canônico existe com o contrato completo ---
assert_file templates/gate-template.md "/1 gate-template existe"
t="$(cat templates/gate-template.md 2>/dev/null)"
for s in 'GATE_SUITE_CMD' 'GATE_LINT_CMD' 'GATE_TYPECHECK_CMD' 'GATE_TEST_ERE' \
         'GATE_SKIP_ERE' 'GATE_ASSERT_ERE'; do
  assert_contains "$t" "$s" "/1 template define $s"
done
assert_contains "$t" 'gate-asserts:' "/1 template define o marcador de justificativa"
assert_contains "$t" 'git diff HEAD' "/1 template examina o diff não commitado"
assert_contains "$t" 'gate: <comando>' "/1 template cita o registro na Constituição"
assert_contains "$t" 'gate: recusado' "/1 template cita a recusa registrada"
assert_contains "$t" 'GATE: passou' "/1 template define a saída verde"
assert_contains "$t" 'GATE: reprovado' "/1 template define a saída vermelha"
assert_contains "$t" 'pulado' "/1 template pula etapa sem ferramenta avisando"
assert_contains "$t" 'GATE_ROOT' "/1 template define GATE_ROOT"

# --- fixture: repo git real exercitando a instância dogfood hooks/gate ---
g="$ROOT/hooks/gate"
proj="$SP/gproj"
mkfix() {
  rm -rf "$proj"; mkdir -p "$proj/tests" "$proj/docs/audora/memory"
  git -C "$proj" init -q
  git -C "$proj" config user.email gate@test; git -C "$proj" config user.name gate
  printf '%s\n' 'assert_eq 1 1' 'assert_eq 2 2' 'ok fim' > "$proj/tests/test-a.sh"
  git -C "$proj" add -A; git -C "$proj" commit -qm base
}
rungate() { out="$(cd "$proj" && GATE_ROOT="$proj" GATE_SUITE_CMD="$1" bash "$g" "${2:-}" 2>&1)"; code=$?; }

# gate-mecanico/3 — árvore limpa + suíte verde → exit 0 e GATE: passou
assert_file "$g" "/3 hooks/gate existe"
mkfix; rungate true
assert_eq 0 "$code" "/3 árvore limpa + suíte verde → exit 0"
assert_contains "$out" 'GATE: passou' "/3 imprime GATE: passou"
# gate-mecanico/4 — lint e typecheck ausentes → pulados com aviso, sem falhar
assert_contains "$out" 'lint pulado' "/4 lint ausente é pulado avisando"
assert_contains "$out" 'typecheck pulado' "/4 typecheck ausente é pulado avisando"
# gate-mecanico/3 — suíte vermelha → exit 1 com motivo
rungate false
assert_eq 1 "$code" "/3 suíte vermelha → exit 1"
assert_contains "$out" 'GATE: reprovado' "/3 imprime GATE: reprovado"
assert_contains "$out" 'suite falhou' "/3 nomeia a suíte como motivo"
report
