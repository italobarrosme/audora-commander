#!/usr/bin/env bash
# Orquestrador de evals de comportamento (tests/evals.sh) — tudo offline, com um
# claude falso (stub). O claude real nunca roda aqui (evals-comportamento/12).
source "$(dirname "$0")/lib.sh"
. "$ROOT/tests/evals-lib.sh"
unset CLAUDE_CODE_OAUTH_TOKEN ANTHROPIC_API_KEY

# Stub: grava os argumentos de cada chamada (1 chamada por linha) em $SP/stub.log;
# --version lê $SP/versao; o resto do comportamento vem de $SP/cenario.sh.
STUB="$SP/claude-stub"
cat > "$STUB" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$SP/stub.log"
if [ "\$1" = --version ]; then
  echo "\$(cat "$SP/versao" 2>/dev/null || echo 2.1.284) (Claude Code)"; exit 0
fi
[ -f "$SP/cenario.sh" ] && . "$SP/cenario.sh"
# plugin eval: copia \$SP/pe/<caso>.json (ou r.json) para o --json, ecoa
# \$SP/pe/stderr e sai com \$SP/pe/rc
if [ "\$1" = plugin ]; then
  a=("\$@"); J=""; C=""
  for ((i=0; i<\${#a[@]}; i++)); do
    case "\${a[\$i]}" in --json) J="\${a[\$((i+1))]}" ;; --case) C="\${a[\$((i+1))]}" ;; esac
  done
  src="$SP/pe/\$C.json"; [ -f "\$src" ] || src="$SP/pe/r.json"
  [ -f "\$src" ] && [ -n "\$J" ] && cp "\$src" "\$J"
  [ -f "$SP/pe/stderr" ] && cat "$SP/pe/stderr" >&2
  exit "\$(cat "$SP/pe/rc" 2>/dev/null || echo 0)"
fi
exit 0
EOF
chmod +x "$STUB"

# --- JSON do plugin eval no formato real (spike 2026-10-09, CLI 2.1.284) ---
# jcaminho <caminho> — forma Windows (como o host devolve), escapada para JSON
jcaminho() {
  local p="$1"
  command -v cygpath >/dev/null 2>&1 && p="$(cygpath -w "$1")"
  printf '%s' "$p" | sed 's/\\/\\\\/g'
}
# trace <arquivo> <in> <cc> <cr> <out> [plugins-json] — init + evento result
trace() {
  mkdir -p "$(dirname "$1")"
  local pl="${6-[{\"name\":\"audora-commander\",\"source\":\"audora-commander@inline\"}]}"
  printf '%s\n' "{\"type\":\"system\",\"subtype\":\"init\",\"plugins\":$pl}" \
    "{\"type\":\"result\",\"subtype\":\"success\",\"is_error\":false,\"total_cost_usd\":0.1,\"usage\":{\"input_tokens\":$2,\"cache_creation_input_tokens\":$3,\"cache_read_input_tokens\":$4,\"output_tokens\":$5}}" > "$1"
}
# run <score> <error-json> <custo> <trace> [graders-json] — 1 run de um braço
run() {
  printf '{"score":%s,"passed":%s,"turns":3,"costUsd":%s,"judgeCostUsd":0,"error":%s,"tracePath":"%s","graders":%s}' \
    "$1" "$([ "$1" = 1 ] && echo true || echo false)" "$3" "$2" "$(jcaminho "$4")" "${5-[]}"
}
# resultado <arquivo> <with-runs> [without-runs] [partial] [partialReason]
resultado() {
  local sem=""; [ -z "${3-}" ] || sem=",\"without\":[$3]"
  local pr=""; [ -z "${5-}" ] || pr=",\"partialReason\":\"$5\""
  mkdir -p "$(dirname "$1")"
  printf '{"schemaVersion":1,"claudeVersion":"2.1.284","costUsd":0,"partial":%s%s,"suite":{"plugins":[{"name":"audora-commander","version":"0.16.0"}]},"cases":[{"name":"x","arms":{"with":[%s]%s}}]}' \
    "${4-false}" "$pr" "$2" "$sem" > "$1"
}
G_CAT='[{"name":"primeira-skill","passed":true,"explanation":"ok"},{"name":"categoria","passed":false,"explanation":"no match"}]'
# reseta_pe — limpa o cenário do plugin eval
reseta_pe() { rm -rf "$SP/pe" "$SP"/claude-eval-* "$SP/outro"; mkdir -p "$SP/pe"; reseta; }

# mkraiz <dir> <caso>... — raiz de plugin (repo git) com casos plugin-eval
mkraiz() {
  local d="$1" c; shift
  mkdir -p "$d/tests/evals"
  for c in "$@"; do mkdir -p "$d/tests/evals/$c"; echo "prompt $c" > "$d/tests/evals/$c/prompt.md"; done
  git -C "$d" init -q && git -C "$d" config core.excludesFile "$d/.nao-existe" \
    && git -C "$d" config core.autocrlf false \
    && git -C "$d" add -A && git -C "$d" -c user.name=t -c user.email=t@t commit -qm base
}
# reseta — limpa log, versão e cenário do stub
reseta() { rm -f "$SP/stub.log" "$SP/versao" "$SP/cenario.sh"; }
RZ="$SP/raiz"
mkraiz "$RZ" a b
roda_evals() { bash "$ROOT/tests/evals.sh" --claude "$STUB" --raiz "$RZ" "$@"; }

# --- evals-comportamento/11: uso inválido sai 4 ---
reseta
err="$(roda_evals --teto abc 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "evals-comportamento/11 --teto abc sai 4"
assert_contains "$err" "evals: --teto inválido ('abc')" "evals-comportamento/11 --teto abc explica"
err="$(roda_evals --teto 0 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "evals-comportamento/11 --teto 0 sai 4"
assert_contains "$err" "evals: --teto inválido ('0')" "evals-comportamento/11 --teto 0 explica"
err="$(roda_evals --caso nada 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "evals-comportamento/11 --caso nada sai 4"
assert_contains "$err" "evals: caso desconhecido: nada" "evals-comportamento/11 caso desconhecido"
err="$(roda_evals --runs 2 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "evals-comportamento/11 --runs sem --mutar sai 4"
assert_contains "$err" "evals: --runs só vale com --mutar" "evals-comportamento/11 --runs sem --mutar explica"
err="$(roda_evals --xpto 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "evals-comportamento/11 opção desconhecida sai 4"
assert_contains "$err" "evals: opção desconhecida: --xpto" "evals-comportamento/11 opção desconhecida explica"
assert_no_file "$SP/stub.log" "evals-comportamento/11 uso inválido não chama o claude"

# --- evals-comportamento/9: claude ausente ---
reseta
out="$(roda_evals --claude /nao/existe 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/9 claude ausente sai 3"
assert_contains "$out" "evals: modo rápido · modelo sonnet · teto US\$ 10.00" "evals-comportamento/9 cabeçalho"
assert_contains "$out" "ERRO INFRA · a · causa: claude ausente (/nao/existe) · US\$ 0.0000 · tokens 0" "evals-comportamento/9 claude ausente caso a"
assert_contains "$out" "ERRO INFRA · b · causa: claude ausente (/nao/existe) · US\$ 0.0000 · tokens 0" "evals-comportamento/9 claude ausente caso b"
assert_contains "$out" "total: 2 caso(s) · 0 passou · 0 reprovou · 2 erro de infra · 0 não rodado · US\$ 0.0000 · tokens 0" "evals-comportamento/9 total com erro de infra"

# --- evals-comportamento/9: versão abaixo da mínima ---
reseta; echo 2.1.268 > "$SP/versao"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/9 versão abaixo sai 3"
assert_contains "$out" "ERRO INFRA · a · causa: claude 2.1.268 abaixo da mínima 2.1.269" "evals-comportamento/9 versão abaixo explica"
assert_eq "--version" "$(cat "$SP/stub.log" 2>/dev/null)" "evals-comportamento/9 versão abaixo não chama mais nada"

# --- versao_ok ---
versao_ok 2.1.284 2.1.269; assert_eq 0 "$?" "versao_ok 2.1.284 >= 2.1.269"
versao_ok 2.1.268 2.1.269; assert_eq 1 "$?" "versao_ok 2.1.268 < 2.1.269"
versao_ok 2.10.0 2.9.9;    assert_eq 0 "$?" "versao_ok compara por número, não texto"
versao_ok 2.1.269 2.1.269; assert_eq 0 "$?" "versao_ok igual à mínima"

# --- carrega_env ---
printf '%s\n' '# comentário' '' 'CLAUDE_CODE_OAUTH_TOKEN=__coloque_o_valor__' 'EVX=1' 'EVY=3' 'EVZ=' > "$SP/env1"
r="$(unset CLAUDE_CODE_OAUTH_TOKEN EVX EVZ; EVY=2; export EVY; carrega_env "$SP/env1"
     echo "${CLAUDE_CODE_OAUTH_TOKEN-unset}|${EVX-unset}|$EVY|${EVZ-unset}")"
assert_eq "unset|1|2|unset" "$r" "carrega_env: placeholder e vazio ignorados, ambiente vence"
printf 'EVW=4\r\n' > "$SP/env2"
r="$(unset EVW; carrega_env "$SP/env2"; printf '%s' "$EVW")"
assert_eq "4" "$r" "carrega_env tira o CR de .env com CRLF"
r="$(carrega_env "$SP/nao-existe" && echo ok)"
assert_eq "ok" "$r" "carrega_env com arquivo ausente não é erro"

# --- lista_casos ---
mkdir -p "$SP/lc/tests/evals/_lib" "$SP/lc/tests/evals/zeta" "$SP/lc/tests/evals/alfa" "$SP/lc/tests/evals/vazio"
echo x > "$SP/lc/tests/evals/_lib/prompt.md"; echo x > "$SP/lc/tests/evals/zeta/harness.md"; echo x > "$SP/lc/tests/evals/alfa/prompt.md"
assert_eq "$(printf 'alfa\tplugin-eval\nzeta\tharness')" "$(lista_casos "$SP/lc")" "lista_casos: ordem alfabética, sem _ e sem pasta vazia"

# --- evals-comportamento/1: caso plugin-eval no modo rápido ---
RZ="$SP/raiz1"; mkraiz "$RZ" porta
T1="$SP/claude-eval-x1/out/trace.jsonl"
reseta_pe; trace "$T1" 10 7632 8239 600
resultado "$SP/pe/r.json" "$(run 1 null 0.4123 "$T1")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 0 "$code" "evals-comportamento/1 caso que passa sai 0"
assert_contains "$out" "PASSOU · porta · com 1/1 · US\$ 0.4123 · tokens 16481" "evals-comportamento/1 linha PASSOU com custo e tokens"
assert_contains "$out" "total: 1 caso(s) · 1 passou · 0 reprovou · 0 erro de infra · 0 não rodado · US\$ 0.4123 · tokens 16481" "evals-comportamento/1 total da rodada"
assert_no_file "$SP/claude-eval-x1" "evals-comportamento/1 apaga o claude-eval-* deixado pelo --keep-temp"
inv="$(grep '^plugin eval' "$SP/stub.log")"
tmpj="$(printf '%s' "$inv" | sed -n 's/.* --json \([^ ]*\) .*/\1/p')"; tmpj="${tmpj%/r.json}"
assert_eq "plugin eval $RZ --eval-dir tests/evals --case porta --runs 1 --ablation none --threshold 0 --trust-plugin --scaffold --allow-tools Write Edit --model sonnet --keep-temp --no-publish --max-cost-usd 10.0000 --json $tmpj/r.json --output-dir $tmpj/out" \
  "$inv" "evals-comportamento/1 invocação exata do plugin eval"

reseta_pe; trace "$T1" 10 7632 8239 600
resultado "$SP/pe/r.json" "$(run 0.5 null 0.4123 "$T1" "$G_CAT")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 1 "$code" "evals-comportamento/1 caso reprovado sai 1"
assert_contains "$out" "REPROVOU · porta · com 0/1 · US\$ 0.4123 · tokens 16481 · motivo: categoria: no match" "evals-comportamento/1 REPROVOU com o motivo do grader"
assert_contains "$out" "· 0 passou · 1 reprovou ·" "evals-comportamento/1 total conta reprovado"

reseta_pe; mkdir -p "$SP/outro/out"; T2="$SP/outro/out/trace.jsonl"; trace "$T2" 1 2 3 4
resultado "$SP/pe/r.json" "$(run 1 null 0.1 "$T2")"
roda_evals >/dev/null 2>&1
assert_file "$T2" "evals-comportamento/1 trace fora de claude-eval-* fica"

reseta_pe; trace "$T1" 1 1 1 1
resultado "$SP/pe/r.json" "$(run 0 null 0.2 "$T1")"
out="$(roda_evals 2>/dev/null)"
assert_contains "$out" "REPROVOU · porta · com 0/1 · US\$ 0.2000 · tokens 4 · motivo: score 0" "evals-comportamento/1 reprovado sem grader falho diz o score"

# dois casos: total soma custo e tokens
RZ="$SP/raiz2"; mkraiz "$RZ" memoria porta
reseta_pe; trace "$SP/claude-eval-p/out/trace.jsonl" 1 2 3 4; trace "$SP/claude-eval-m/out/trace.jsonl" 10 20 30 40
resultado "$SP/pe/porta.json" "$(run 1 null 0.25 "$SP/claude-eval-p/out/trace.jsonl")"
resultado "$SP/pe/memoria.json" "$(run 1 null 0.5 "$SP/claude-eval-m/out/trace.jsonl")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 0 "$code" "evals-comportamento/1 dois casos que passam saem 0"
assert_contains "$out" "PASSOU · memoria · com 1/1 · US\$ 0.5000 · tokens 100" "evals-comportamento/1 caso memoria"
assert_contains "$out" "total: 2 caso(s) · 2 passou · 0 reprovou · 0 erro de infra · 0 não rodado · US\$ 0.7500 · tokens 110" "evals-comportamento/1 total soma os casos"
assert_eq 2 "$(grep -c '^plugin eval' "$SP/stub.log")" "evals-comportamento/1 uma invocação por caso"
assert_contains "$(grep -- '--case porta' "$SP/stub.log")" "--max-cost-usd 9.5000" "evals-comportamento/1 2º caso recebe o teto restante"

# --- evals-comportamento/9: erros de infra do run e da invocação ---
RZ="$SP/raiz1"
reseta_pe; trace "$T1" 10 7632 8239 600
resultado "$SP/pe/r.json" "$(run 1 '"timed out after 600s"' 0.4123 "$T1")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/9 timeout sai 3"
assert_contains "$out" "ERRO INFRA · porta · causa: timeout (timed out after 600s) · US\$ 0.4123 · tokens 16481" "evals-comportamento/9 timeout é infra, nunca aprovado"

reseta_pe; trace "$T1" 1 1 1 1
resultado "$SP/pe/r.json" "$(run 1 '"API Error: 529 overloaded"' 0.1 "$T1")"
out="$(roda_evals 2>/dev/null)"
assert_contains "$out" "ERRO INFRA · porta · causa: API (API Error: 529 overloaded)" "evals-comportamento/9 erro de API é infra"

reseta_pe; trace "$T1" 1 1 1 1
resultado "$SP/pe/r.json" "$(run 1 '"reached max turns (40)"' 0.1 "$T1")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 1 "$code" "evals-comportamento/9 limite de turnos é reprovação, não infra"
assert_contains "$out" "REPROVOU · porta · com 0/1 · US\$ 0.1000 · tokens 4 · motivo: run: reached max turns (40)" "evals-comportamento/9 limite de turnos explica"

reseta_pe; resultado "$SP/pe/r.json" "" "" true auth_failed; echo 2 > "$SP/pe/rc"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/9 sem autenticação sai 3"
assert_contains "$out" "ERRO INFRA · porta · causa: sem autenticação · US\$ 0.0000 · tokens 0" "evals-comportamento/9 sem autenticação"

reseta_pe; echo 1 > "$SP/pe/rc"; printf 'No eval cases found\nmais linha\n' > "$SP/pe/stderr"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/9 plugin eval sem JSON sai 3"
assert_contains "$out" "ERRO INFRA · porta · causa: plugin eval saiu 1: No eval cases found · US\$ 0.0000 · tokens 0" "evals-comportamento/9 plugin eval sem JSON explica"

# --- funções da Tarefa 2 ---
assert_eq "infra: timeout" "$(classifica_erro 'Timeout: run exceeded')" "classifica_erro timeout"
assert_eq "infra: API" "$(classifica_erro 'API Error: 500')" "classifica_erro API"
assert_eq "reprovado" "$(classifica_erro 'reached max turns (40)')" "classifica_erro max turns"
printf 'x\n' > "$SP/sem-result.jsonl"
assert_eq 0 "$(tokens_trace "$SP/sem-result.jsonl")" "tokens_trace sem evento result → 0"
assert_eq 0 "$(tokens_trace "$SP/nao-existe.jsonl")" "tokens_trace sem arquivo → 0"

report
