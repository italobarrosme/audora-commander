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
exit 0
EOF
chmod +x "$STUB"

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

report
