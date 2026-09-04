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
  git -C "$proj" config core.autocrlf false
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

# gate-mecanico/5 — arquivo de teste apagado → reprova nomeando o arquivo
mkfix; rm "$proj/tests/test-a.sh"; rungate true
assert_eq 1 "$code" "/5 teste apagado → exit 1"
assert_contains "$out" 'arquivo de teste apagado: tests/test-a.sh' "/5 nomeia o arquivo apagado"

# gate-mecanico/6 — skip/only adicionado → reprova nomeando arquivo e linha
mkfix; printf 'xit("burla")\n' >> "$proj/tests/test-a.sh"; rungate true
assert_eq 1 "$code" "/6 skip adicionado → exit 1"
assert_contains "$out" 'skip/only adicionado: tests/test-a.sh:4' "/6 nomeia arquivo e linha"

# gate-mecanico/7 — contagem de asserts caiu sem justificativa → reprova antes → depois
mkfix; printf '%s\n' 'assert_eq 1 1' 'ok fim' > "$proj/tests/test-a.sh"; rungate true
assert_eq 1 "$code" "/7 queda de asserts → exit 1"
assert_contains "$out" 'contagem de asserts caiu: 3 → 2' "/7 imprime antes → depois"

# gate-mecanico/8 — queda com justificativa gate-asserts: no nó → passa imprimindo
printf 'gate-asserts: refactor legitimo\n' > "$proj/docs/audora/memory/x1.md"
rungate true x1
assert_eq 0 "$code" "/8 queda justificada → exit 0"
assert_contains "$out" 'refactor legitimo' "/8 imprime a justificativa"
assert_contains "$out" 'GATE: passou' "/8 termina em GATE: passou"

# gate-mecanico/1,/2 — oferta no bootstrap e no início de demanda; recusa gruda
b="$(cat skills/memory/references/bootstrap.md 2>/dev/null)"
assert_contains "$b" 'Etapa gate' "/1 bootstrap tem a etapa gate"
assert_contains "$b" 'templates/gate-template.md' "/1 bootstrap instancia do template"
assert_contains "$b" 'gate: <comando>' "/1 bootstrap registra a aceitação"
assert_contains "$b" 'gate: recusado' "/1 bootstrap registra a recusa"
ms="$(cat skills/memory/SKILL.md 2>/dev/null)"
assert_contains "$ms" 'bullet `gate:`' "/2 carregar-contexto checa o bullet gate:"
assert_contains "$ms" 'não reofertar' "/2 recusa não gera reoferta"

# gate-mecanico/9 — execute: GREEN = gate verde quando a Constituição tem gate:
e="$(cat skills/execute/SKILL.md 2>/dev/null)"
assert_contains "$e" 'Constituição com `gate:`' "/9 execute condiciona ao bullet gate:"
assert_contains "$e" 'verde é o GATE saindo 0' "/9 execute redefine o verde"

# gate-mecanico/10 — validate: diff dos arquivos de teste separado, toda categoria
v="$(cat skills/validate/SKILL.md 2>/dev/null)"
assert_contains "$v" '**Diff de teste**' "/10 validate tem a seção de diff de teste"
assert_contains "$v" 'arquivos de teste separado do resto' "/10 validate separa teste do resto"
lt="$(awk '/^## Fechamento LIGHT/{f=1;next} /^## /{f=0} f' skills/validate/SKILL.md)"
assert_contains "$lt" 'arquivos de teste separados' "/10 Fechamento LIGHT também separa"

# gate-mecanico/11 — este repo dogfooda: gate: na Constituição, instância do template
mm="$(cat MEMORY.md 2>/dev/null)"
assert_contains "$mm" '**gate**:' "/11 Constituição registra o bullet gate"
assert_contains "$mm" 'hooks/gate' "/11 bullet aponta hooks/gate"
gg="$(cat hooks/gate 2>/dev/null)"
for s in GATE_SUITE_CMD GATE_LINT_CMD GATE_TYPECHECK_CMD GATE_TEST_ERE \
         GATE_SKIP_ERE GATE_ASSERT_ERE GATE_ROOT; do
  assert_contains "$gg" "$s" "/11 hooks/gate instancia $s do template"
done
report
