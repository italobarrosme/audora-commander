#!/usr/bin/env bash
# contexto-por-fase — parada entre fases, retomada, "segue" em subagente.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# sec <arquivo> '<cabeçalho exato>' → corpo da seção, sem \r (checkout CRLF)
sec() { tr -d '\r' 2>/dev/null < "$1" | awk -v h="$2" '$0==h{f=1;next} /^## /{f=0} f'; }

# --- /1 /2 /3 /4 /9 /10 /12 /13 — regra de parada no template de fechamento ---
T=templates/bloco-fechamento-template.md
pa="$(sec "$T" '## Parada entre fases')"
assert_contains "$pa" 'PARADA: rode /clear e, na sessão nova,' "/1 Próximo vira PARADA com retomada"
assert_contains "$pa" 'NÃO emenda a fase seguinte na mesma resposta' "/1 fase não emenda a seguinte"
assert_contains "$pa" 'porta de entrada → 1ª fase' "/2 entrada emenda"
assert_contains "$pa" 'LIGHT, HOTFIX' "/3 LIGHT e HOTFIX emendam"
assert_contains "$pa" 'e2e ↔ validate' "/4 e2e e validate na mesma sessão"
assert_not_contains "$pa" 'autopilot' "corte-sem-uso/6 parada sem exceção de autopilot"
assert_contains "$pa" 'templates/fase-subagente-template.md' "/5 segue aponta o template do subagente"
assert_contains "$pa" 'recusar nomeando o que falta e a fase certa' "/9 retomada inválida recusa"
assert_contains "$pa" 'interrompida, bloqueada ou reprovada não tem PARADA' "/12 fase parada sem retomada"
assert_not_contains "$(tr -d '\r' < "$T")" '/clear recomendado' "/13 template não volta a só recomendar"

# --- /5 /6 /7 /8 /11 — template do subagente de fase ---
F=templates/fase-subagente-template.md
assert_file "$F" "/5 template do subagente existe"
fs="$(tr -d '\r' 2>/dev/null < "$F")"
assert_contains "$fs" '{{FASE}} de {{ID}}' "/5 prompt cita fase e id"
assert_contains "$fs" 'contexto zerado' "/5 subagente começa limpo"
assert_contains "$fs" 'devolva SÓ o bloco de fechamento' "/5 principal recebe só o bloco"
assert_contains "$fs" 'NUNCA aprove portão' "/6 subagente não aprova"
assert_contains "$fs" 'portão é apresentado na sessão principal' "/6 portão na principal"
assert_contains "$fs" 'devolva a pergunta' "/7 input humano volta à principal"
assert_contains "$fs" '[PRECISA-CLARIFICAR' "/7 marcador aberto interrompe"
assert_contains "$fs" 'reancore só pelos artefatos em disco' "/8 reancoragem pelos artefatos"

# --- /1 /9 /13 — scope e plan param; plan recusa retomada sem escopo ---
for s in scope plan; do
  k="$(tr -d '\r' < skills/$s/SKILL.md)"
  assert_contains "$k" 'PARADA: rode /clear' "/1 $s instrui a parada"
  assert_not_contains "$k" 'Recomendo /clear' "/13 $s não volta a só recomendar"
done
assert_contains "$(tr -d '\r' < skills/scope/SKILL.md)" 'na sessão nova: `plan de <id>`' "/1 scope imprime a retomada"
assert_contains "$(tr -d '\r' < skills/plan/SKILL.md)" 'na sessão nova: `execute de <id>`' "/1 plan imprime a retomada"
assert_contains "$(tr -d '\r' < skills/plan/SKILL.md)" 'recusar nomeando o que falta' "/9 plan recusa retomada sem escopo"

# --- /1 /3 /9 — execute: parada, LIGHT emenda ---
ex="$(tr -d '\r' < skills/execute/SKILL.md)"
bf="$(sec skills/execute/SKILL.md '## Bloco de fechamento')"
assert_contains "$bf" 'PARADA: rode /clear e, na sessão nova: `validate de <id>`' "/1 execute MEDIUM/HIGH para"
assert_contains "$bf" 'LIGHT/HOTFIX → validate na mesma sessão' "/3 LIGHT/HOTFIX emendam"
assert_contains "$ex" 'sem plano-arquivo → recusar nomeando o que falta' "/9 execute recusa retomada sem plano"

# --- /1 /13 — docs descrevem a parada (READMEs EN/PT e fundamentos) ---
en="$(tr -d '\r' < README.md)"; pt="$(tr -d '\r' < README.pt-BR.md)"
assert_contains "$en" 'after a STOP' "/1 README EN descreve a parada"
assert_contains "$pt" 'depois de uma PARADA' "/1 README PT descreve a parada"
assert_not_contains "$en" '`/clear` recommended' "/13 README EN sem recomendação solta"
assert_not_contains "$pt" '`/clear` recomendado' "/13 README PT sem recomendação solta"
assert_contains "$(tr -d '\r' < docs/fundamentos.md)" 'a skill PARA e não emenda a fase seguinte' "/1 fundamentos P3 regra 6"

report
