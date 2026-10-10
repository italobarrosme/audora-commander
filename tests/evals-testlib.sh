#!/usr/bin/env bash
# Helpers dos testes de evals (test-evals.sh, test-evals-graders.sh): claude falso
# (stub), raiz de plugin, JSON e stream no formato real. Fica fora do glob
# tests/test-*.sh; uso: source depois de lib.sh e evals-lib.sh.
unset CLAUDE_CODE_OAUTH_TOKEN ANTHROPIC_API_KEY
# evals-comportamento/12: claude/claude.exe do PATH viram shims que denunciam a chamada
mkdir -p "$SP/shims"
for s in claude claude.exe; do printf '#!/usr/bin/env bash\ntouch "%s/chamou-claude"\nexit 1\n' "$SP" > "$SP/shims/$s"; chmod +x "$SP/shims/$s"; done
PATH="$SP/shims:$PATH"

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
  # mutação: alvo ≠ \$SP/pe/raiz é a cópia mutada → \$SP/pe/copia.json
  [ -f "$SP/pe/copia.json" ] && [ "\$3" != "\$(cat "$SP/pe/raiz" 2>/dev/null)" ] && src="$SP/pe/copia.json"
  [ -f "\$src" ] && [ -n "\$J" ] && cp "\$src" "\$J"
  [ -f "$SP/pe/stderr" ] && cat "$SP/pe/stderr" >&2
  exit "\$(cat "$SP/pe/rc" 2>/dev/null || echo 0)"
fi
# claude -p: grava env e pwd, escreve o init (com o plugin se veio --plugin-dir,
# ou \$SP/hs/init) e o corpo \$SP/hs/stream.jsonl; dorme \$SP/hs/sleep; sai \$SP/hs/rc
if [ "\$1" = -p ]; then
  /usr/bin/env > "$SP/stub.env"; pwd > "$SP/stub.pwd"; ls > "$SP/stub.ls"
  [ -f "$SP/hs/sleep" ] && sleep "\$(cat "$SP/hs/sleep")"
  pl='[{"name":"telemetry","source":"telemetry@builtin"}]'
  case " \$* " in *" --plugin-dir "*) pl='[{"name":"audora-commander","source":"audora-commander@inline"},{"name":"telemetry","source":"telemetry@builtin"}]' ;; esac
  [ -f "$SP/hs/init" ] && pl="\$(cat "$SP/hs/init")"
  echo "{\"type\":\"system\",\"subtype\":\"init\",\"plugins\":\$pl}"
  [ -f "$SP/hs/stream.jsonl" ] && cat "$SP/hs/stream.jsonl"
  exit "\$(cat "$SP/hs/rc" 2>/dev/null || echo 0)"
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
  local pl='[{"name":"audora-commander","source":"audora-commander@inline"}]'
  [ $# -lt 6 ] || pl="$6"
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
# eventos do stream-json do claude -p (formato do spike)
jesc() { printf '%s' "$1" | sed 's/\\/\\\\/g'; }
ev_tool() { printf '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"%s","name":"%s","input":%s}]}}\n' "$1" "$2" "$3"; }
ev_result() { printf '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"%s","is_error":%s,"content":"x"}]}}\n' "$1" "$2"; }
# fluxo <arquivo> <passo>... — W:<caminho> / E:<caminho> (Write/Edit);
# B- / B+ = bash tests/run.sh falhando / passando
fluxo() {
  local f="$1" p n=0; shift; : > "$f"
  for p in "$@"; do
    n=$((n+1))
    case "$p" in
      W:*) ev_tool "t$n" Write "{\"file_path\":\"$(jesc "${p#W:}")\",\"content\":\"x\"}"; ev_result "t$n" false ;;
      E:*) ev_tool "t$n" Edit "{\"file_path\":\"$(jesc "${p#E:}")\",\"old_string\":\"a\",\"new_string\":\"b\"}"; ev_result "t$n" false ;;
      B-) ev_tool "t$n" Bash '{"command":"bash tests/run.sh","description":"x"}'; ev_result "t$n" true ;;
      B+) ev_tool "t$n" Bash '{"command":"bash tests/run.sh","description":"x"}'; ev_result "t$n" false ;;
    esac >> "$f"
  done
}
TT=W:/ws/cwd/tests/test-dobro.sh; LB=E:/ws/cwd/lib.sh
ev_saida() { printf '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"%s","is_error":%s,"content":"%s"}]}}\n' "$1" "$2" "$3"; }
ev_bash() { printf '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"%s","name":"Bash","input":%s}]}}\n' "$1" "$(CMD="$2" perl -MJSON::PP -e 'print JSON::PP->new->encode({command => $ENV{CMD}})')"; }
EV="$ROOT/tests/evals"
# na_fixture <dir> <script> — roda o script com cwd = <dir> vazio, como o scaffold
na_fixture() { mkdir -p "$1" && ( cd "$1" && bash -c ". \"\$1\"" _ "$2" ) >/dev/null 2>&1; }
