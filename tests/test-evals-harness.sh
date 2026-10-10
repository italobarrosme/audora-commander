#!/usr/bin/env bash
# Orquestrador de evals: harness próprio do caso tdd e mutação de regra — tudo
# offline, com claude falso (stub); o claude real nunca roda (evals-comportamento/12).
source "$(dirname "$0")/lib.sh"
. "$ROOT/tests/evals-lib.sh"
. "$ROOT/tests/evals-testlib.sh"
roda_evals() { bash "$ROOT/tests/evals.sh" --claude "$STUB" --raiz "$RZ" "$@"; }

# --- harness próprio do caso tdd (evals-comportamento/2,7,9) ---
RZ="$SP/raizh"; mkdir -p "$RZ/tests/evals/tdd"
echo "execute de dobro" > "$RZ/tests/evals/tdd/harness.md"
printf '#!/usr/bin/env bash\necho fixture > semente.txt\n' > "$RZ/tests/evals/tdd/fixture.sh"
mkraiz "$RZ"
# result_ev <custo> [campos-extra] — evento result com usage {1,2,3,4}
result_ev() { printf '{"type":"result","subtype":"success","is_error":false,"api_error_status":null,"total_cost_usd":%s,"usage":{"input_tokens":1,"cache_creation_input_tokens":2,"cache_read_input_tokens":3,"output_tokens":4}%s}\n' "$1" "${2-}"; }
# reseta_hs [stream-de-tdd] — cenário do -p: fluxo tdd que passa + result 0.3
reseta_hs() {
  reseta_pe; rm -rf "$SP/hs" "$SP/stub.env" "$SP/stub.pwd" "$SP/stub.ls"; mkdir -p "$SP/hs"
  fluxo "$SP/hs/stream.jsonl" $TT B- $LB B+; result_ev 0.3 >> "$SP/hs/stream.jsonl"
}
export EVALS_CANARIO=vazou

reseta_hs
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/7 harness sem token sai 3"
assert_contains "$out" "RECUSADO · tdd · isolamento: sem CLAUDE_CODE_OAUTH_TOKEN nem ANTHROPIC_API_KEY (rode claude setup-token)" "evals-comportamento/7 harness sem token é recusado"
assert_eq 0 "$(grep -c '^-p ' "$SP/stub.log")" "evals-comportamento/7 harness sem token não chama -p"
reseta_hs
out="$(CLAUDE_CODE_OAUTH_TOKEN=__coloque_o_valor__ roda_evals 2>/dev/null)"
assert_contains "$out" "RECUSADO · tdd · isolamento: sem CLAUDE_CODE_OAUTH_TOKEN" "evals-comportamento/7 placeholder não é token"

export CLAUDE_CODE_OAUTH_TOKEN=tok-teste
reseta_hs
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 0 "$code" "evals-comportamento/2 harness que passa sai 0"
assert_contains "$out" "PASSOU · tdd · com 1/1 · US\$ 0.3000 · tokens 10" "evals-comportamento/2 harness: veredito do grader_tdd, custo e tokens"
env_visto="$(cat "$SP/stub.env" 2>/dev/null)"
assert_contains "$env_visto" "PATH=" "evals-comportamento/7 stub gravou o ambiente (guarda contra env vazio)"
assert_not_contains "$env_visto" "EVALS_CANARIO" "evals-comportamento/7 harness não herda o ambiente do humano"
assert_contains "$env_visto" "CLAUDE_CODE_OAUTH_TOKEN=tok-teste" "evals-comportamento/7 harness passa o token"
assert_not_contains "$(grep '^HOME=' <<< "$env_visto")" "HOME=$HOME" "evals-comportamento/7 harness com HOME temporário"
ws="$(dirname "$(cat "$SP/stub.pwd")")"
# /tmp e /c/Users/... (e o nome 8.3) são o mesmo lugar: compara pelo nome único do workspace
cfg="$(sed -n 's/^CLAUDE_CONFIG_DIR=//p' <<< "$env_visto" | tr '\\' /)"
assert_eq "$(basename "$ws")/config" "$(basename "$(dirname "$cfg")")/$(basename "$cfg")" "evals-comportamento/7 harness com CLAUDE_CONFIG_DIR no workspace"
case "$(cat "$SP/stub.pwd")" in "$RZ"*) ko "evals-comportamento/7 harness roda dentro da raiz" ;; *) ok ;; esac
assert_contains "$(cat "$SP/stub.ls" 2>/dev/null)" "semente.txt" "evals-comportamento/7 harness roda na fixture"
assert_no_file "$ws" "evals-comportamento/7 workspace apagado depois do run"
inv="$(grep '^-p ' "$SP/stub.log")"
assert_eq "-p execute de dobro --plugin-dir $RZ --model sonnet --output-format stream-json --verbose --max-budget-usd 10.0000 --permission-mode dontAsk --strict-mcp-config --no-session-persistence --allowedTools Read Glob Grep Skill TodoWrite Edit(./**) Write(./**) Bash" "$inv" "evals-comportamento/7 invocação exata do harness (Bash livre: decisão 2026-10-10)"
# o claude acha o CLAUDE.md global pela API do SO, ignorando HOME/USERPROFILE (rodada real 2026-10-10)
assert_contains "$env_visto" "CLAUDE_CODE_DISABLE_CLAUDE_MDS=1" "evals-comportamento/7 harness desliga a descoberta de CLAUDE.md"

reseta_hs; printf '%s\n' '{"type":"result","subtype":"success","is_error":true,"api_error_status":null,"total_cost_usd":0,"result":"Not logged in · Please run /login"}' > "$SP/hs/stream.jsonl"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/9 harness sem login sai 3"
assert_contains "$out" "ERRO INFRA · tdd · causa: sem autenticação · US\$ 0.0000" "evals-comportamento/9 harness sem login é infra"

reseta_hs; : > "$SP/hs/stream.jsonl"; echo 1 > "$SP/hs/rc"
out="$(roda_evals 2>/dev/null)"
assert_contains "$out" "ERRO INFRA · tdd · causa: sem evento result (exit 1)" "evals-comportamento/9 harness sem result é infra"

reseta_hs; fluxo "$SP/hs/stream.jsonl" $TT B-; result_ev 0.1 ',"api_error_status":529' >> "$SP/hs/stream.jsonl"
sed -i 's/"api_error_status":null,//' "$SP/hs/stream.jsonl"
out="$(roda_evals 2>/dev/null)"
assert_contains "$out" "ERRO INFRA · tdd · causa: API (529)" "evals-comportamento/9 harness com erro de API é infra"

reseta_hs; fluxo "$SP/hs/stream.jsonl" $TT; printf '%s\n' '{"type":"result","subtype":"error_max_budget_usd","is_error":true,"total_cost_usd":0.2,"usage":{}}' >> "$SP/hs/stream.jsonl"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 2 "$code" "evals-comportamento/8 harness no teto sai 2"
assert_contains "$out" "NÃO RODADO · tdd · não rodado: teto" "evals-comportamento/8 harness no teto"

reseta_hs; echo '[{"name":"audora-commander","source":"audora-commander@inline"},{"name":"outro","source":"outro@inline"}]' > "$SP/hs/init"
out="$(roda_evals 2>/dev/null)"
assert_contains "$out" "RECUSADO · tdd · isolamento: plugins na sessão audora-commander,outro" "evals-comportamento/7 harness com plugin extra é recusado"

reseta_hs; fluxo "$SP/hs/stream.jsonl" $LB $TT B+; result_ev 0.1 >> "$SP/hs/stream.jsonl"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 1 "$code" "evals-comportamento/6 harness que fura o TDD sai 1"
assert_contains "$out" "REPROVOU · tdd · com 0/1 · US\$ 0.1000 · tokens 10 · motivo: código editado antes do teste falhando" "evals-comportamento/6 harness reprova pelo grader_tdd"

reseta_hs; echo 5 > "$SP/hs/sleep"
out="$(roda_evals --timeout-run 1 2>/dev/null)"
if timeout --version >/dev/null 2>&1; then
  assert_contains "$out" "ERRO INFRA · tdd · causa: timeout (1 s)" "evals-comportamento/9 harness com timeout é infra"
fi

reseta_hs; printf '#!/usr/bin/env bash\nexit 7\n' > "$SP/fx-ruim.sh"
cp "$RZ/tests/evals/tdd/fixture.sh" "$SP/fx-bom.sh"; cp "$SP/fx-ruim.sh" "$RZ/tests/evals/tdd/fixture.sh"
out="$(roda_evals 2>/dev/null)"
cp "$SP/fx-bom.sh" "$RZ/tests/evals/tdd/fixture.sh"
assert_contains "$out" "ERRO INFRA · tdd · causa: fixture saiu 7" "evals-comportamento/9 fixture quebrada é infra"
assert_eq 0 "$(grep -c '^-p ' "$SP/stub.log")" "evals-comportamento/9 fixture quebrada não chama -p"

reseta_hs
out="$(roda_evals --completo 2>/dev/null)"; code=$?
assert_eq 6 "$(grep -c '^-p ' "$SP/stub.log")" "evals-comportamento/2 harness completo: 6 runs"
assert_eq 3 "$(grep '^-p ' "$SP/stub.log" | grep -c -- '--plugin-dir')" "evals-comportamento/2 harness completo: 3 com o plugin"
assert_contains "$out" "PASSOU · tdd · com 3/3 · sem 3/3 · Δ +0 pp · US\$ 1.8000 · tokens 60" "evals-comportamento/2 harness completo: taxa e diferença"

reseta_hs
out="$(roda_evals --teto 0.5 --completo 2>/dev/null)"; code=$?
assert_eq 2 "$code" "evals-comportamento/8 harness para no teto entre runs"
assert_eq 2 "$(grep -c '^-p ' "$SP/stub.log")" "evals-comportamento/8 harness: nenhum run depois do teto"
assert_contains "$(grep '^-p ' "$SP/stub.log" | sed -n 2p)" "--max-budget-usd 0.2000" "evals-comportamento/8 harness: run recebe o teto restante"
unset CLAUDE_CODE_OAUTH_TOKEN EVALS_CANARIO

# --- evals-comportamento/10: mutação de regra ---
RZ="$SP/raizm"; mkdir -p "$RZ/skills/x" "$RZ/tests/evals/tdd"
printf 'linha 1\nREGRA A\ncorpo\nfim da regra\nREGRA B dup\nREGRA B dup\nlinha 7\n' > "$RZ/skills/x/SKILL.md"
echo "execute de dobro" > "$RZ/tests/evals/tdd/harness.md"
printf '#!/usr/bin/env bash\ntrue\n' > "$RZ/tests/evals/tdd/fixture.sh"
printf '%s\n' '# regra	caso	arquivo	início	fim' \
  'r-ok	porta	skills/x/SKILL.md	REGRA A	fim da regra' \
  'r-sem-inicio	porta	skills/x/SKILL.md	NAO TEM	fim' \
  'r-ambiguo	porta	skills/x/SKILL.md	REGRA B dup	linha 7' \
  'r-sem-fim	porta	skills/x/SKILL.md	REGRA A	NAO TEM' \
  'r-tdd	tdd	skills/x/SKILL.md	REGRA A	REGRA A' > "$RZ/tests/evals/mutacoes.tsv"
mkraiz "$RZ" porta
sha_antes="$(sha1sum "$RZ/skills/x/SKILL.md")"; st_antes="$(git -C "$RZ" status --porcelain)"
TO="$SP/outro/out/trace.jsonl"
reseta_pe; echo "$RZ" > "$SP/pe/raiz"; trace "$TO" 1 1 1 1
err="$(roda_evals --mutar nada 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "evals-comportamento/10 regra desconhecida sai 4"
assert_contains "$err" "evals: regra desconhecida: nada" "evals-comportamento/10 regra desconhecida explica"
err="$(roda_evals --mutar r-sem-inicio 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "evals-comportamento/10 início ausente sai 4"
assert_contains "$err" "evals: mutação inválida: início não encontrado em skills/x/SKILL.md" "evals-comportamento/10 início ausente"
err="$(roda_evals --mutar r-ambiguo 2>&1 >/dev/null)"
assert_contains "$err" "evals: mutação inválida: início ambíguo (2 ocorrências) em skills/x/SKILL.md" "evals-comportamento/10 início ambíguo"
err="$(roda_evals --mutar r-sem-fim 2>&1 >/dev/null)"
assert_contains "$err" "evals: mutação inválida: fim não encontrado depois do início em skills/x/SKILL.md" "evals-comportamento/10 fim ausente"
assert_no_file "$SP/stub.log" "evals-comportamento/10 mutação inválida não chama o claude"

resultado "$SP/pe/r.json" "$(run 1 null 0.1 "$TO")"; resultado "$SP/pe/copia.json" "$(run 0.5 null 0.1 "$TO" "$G_CAT")"
out="$(roda_evals --mutar r-ok --runs 1 2>/dev/null)"; code=$?
assert_eq 0 "$code" "evals-comportamento/10 mutação com efeito sai 0"
assert_contains "$out" "mutação r-ok · caso porta · skills/x/SKILL.md (linhas 2-4)" "evals-comportamento/10 cabeçalho da mutação"
assert_contains "$out" "com a regra 1/1 · sem a regra 0/1 · efeito -100 pp" "evals-comportamento/10 taxa com e sem a regra"
inv="$(grep '^plugin eval' "$SP/stub.log")"
assert_eq 2 "$(printf '%s\n' "$inv" | grep -c -- '--runs 1 --ablation none')" "evals-comportamento/10 dois braços com o plugin, --runs 1"
assert_contains "$(printf '%s\n' "$inv" | sed -n 1p)" "plugin eval $RZ " "evals-comportamento/10 1º braço na raiz"
copia="$(printf '%s\n' "$inv" | sed -n 2p | awk '{print $3}')"
case "$copia" in "$RZ"|"") ko "evals-comportamento/10 2º braço na cópia (obtido '$copia')" ;; *) ok ;; esac
assert_no_file "$copia" "evals-comportamento/10 cópia apagada no fim"
assert_eq "$sha_antes" "$(sha1sum "$RZ/skills/x/SKILL.md")" "evals-comportamento/10 skill do repo intocada"
assert_eq "$st_antes" "$(git -C "$RZ" status --porcelain)" "evals-comportamento/10 git status da raiz intocado"

resultado "$SP/pe/copia.json" "$(run 1 null 0.1 "$TO")"; rm -f "$SP/stub.log"
out="$(roda_evals --mutar r-ok --runs 1 2>/dev/null)"; code=$?
assert_contains "$out" "com a regra 1/1 · sem a regra 1/1 · sem efeito" "evals-comportamento/10 taxa igual = sem efeito"
assert_eq 0 "$code" "evals-comportamento/10 sem efeito ainda sai 0 (relatório)"
resultado "$SP/pe/r.json" "$(run 0.5 null 0.1 "$TO" "$G_CAT")"
out="$(roda_evals --mutar r-ok --runs 1 2>/dev/null)"
assert_contains "$out" "com a regra 0/1 · sem a regra 1/1 · sem efeito" "evals-comportamento/10 taxa que sobe = sem efeito"
rm -f "$SP/stub.log"; roda_evals --mutar r-ok >/dev/null 2>&1
assert_eq 2 "$(grep -c -- '--runs 3 --ablation none' "$SP/stub.log")" "evals-comportamento/10 --runs padrão 3"

resultado "$SP/pe/r.json" "$(run 1 '"timed out after 600s"' 0.1 "$TO")"
out="$(roda_evals --mutar r-ok --runs 1 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/10 infra na mutação sai 3"
assert_contains "$out" "ERRO INFRA · porta · causa: timeout" "evals-comportamento/10 infra na mutação"
resultado "$SP/pe/r.json" "$(run 1 null 1.5 "$TO")"; rm -f "$SP/stub.log"
out="$(roda_evals --mutar r-ok --runs 1 --teto 1 2>/dev/null)"; code=$?
assert_eq 2 "$code" "evals-comportamento/10 teto na mutação sai 2"
assert_eq 1 "$(grep -c '^plugin eval' "$SP/stub.log")" "evals-comportamento/10 teto: braço mutado não roda"

export CLAUDE_CODE_OAUTH_TOKEN=tok-teste
reseta_hs; echo "$RZ" > "$SP/pe/raiz"
out="$(roda_evals --mutar r-tdd --runs 1 2>/dev/null)"; code=$?
assert_eq 2 "$(grep -c '^-p ' "$SP/stub.log")" "evals-comportamento/10 caso harness: 2 runs"
assert_contains "$(grep '^-p ' "$SP/stub.log" | sed -n 1p)" "--plugin-dir $RZ " "evals-comportamento/10 harness: raiz"
assert_not_contains "$(grep '^-p ' "$SP/stub.log" | sed -n 2p)" "--plugin-dir $RZ " "evals-comportamento/10 harness: cópia"
assert_contains "$out" "mutação r-tdd · caso tdd · skills/x/SKILL.md (linhas 2-2)" "evals-comportamento/10 harness: cabeçalho"
assert_contains "$out" "com a regra 1/1 · sem a regra 1/1 · sem efeito" "evals-comportamento/10 harness: relatório"
unset CLAUDE_CODE_OAUTH_TOKEN

assert_no_file "$SP/chamou-claude" "evals-comportamento/12 nenhum claude real chamado pelo test-evals-harness.sh"
report
