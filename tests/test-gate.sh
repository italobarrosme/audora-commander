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
report
