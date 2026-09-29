#!/usr/bin/env bash
# contexto-por-fase — parada entre fases, retomada, "segue" em subagente, autopilot pelo motor.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# sec <arquivo> '<cabeçalho exato>' → corpo da seção, sem \r (checkout CRLF)
sec() { tr -d '\r' < "$1" 2>/dev/null | awk -v h="$2" '$0==h{f=1;next} /^## /{f=0} f'; }

# --- /1 /2 /3 /4 /9 /10 /12 /13 — regra de parada no template de fechamento ---
T=templates/bloco-fechamento-template.md
pa="$(sec "$T" '## Parada entre fases')"
assert_contains "$pa" 'PARADA: rode /clear e, na sessão nova,' "/1 Próximo vira PARADA com retomada"
assert_contains "$pa" 'NÃO emenda a fase seguinte na mesma resposta' "/1 fase não emenda a seguinte"
assert_contains "$pa" 'porta de entrada → 1ª fase' "/2 entrada emenda"
assert_contains "$pa" 'LIGHT, HOTFIX' "/3 LIGHT e HOTFIX emendam"
assert_contains "$pa" 'e2e ↔ validate' "/4 e2e e validate na mesma sessão"
assert_contains "$pa" 'autopilot (execute pelo motor' "/10 autopilot sem parada"
assert_contains "$pa" 'templates/fase-subagente-template.md' "/5 segue aponta o template do subagente"
assert_contains "$pa" 'recusar nomeando o que falta e a fase certa' "/9 retomada inválida recusa"
assert_contains "$pa" 'interrompida, bloqueada ou reprovada não tem PARADA' "/12 fase parada sem retomada"
assert_not_contains "$(tr -d '\r' < "$T")" '/clear recomendado' "/13 template não volta a só recomendar"

report
