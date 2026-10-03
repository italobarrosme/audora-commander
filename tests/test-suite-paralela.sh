#!/usr/bin/env bash
# suite-paralela/1..16 — tests/run.sh em paralelo: blocos em ordem, limite,
# fluxo, timeout, código de saída e contrato do gate.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1

# --- helpers: suíte falsa num diretório próprio, rodando a cópia do run.sh ---
mksuite() { rm -rf "$1"; mkdir -p "$1/tests" "$1/bin"; cp "$ROOT/tests/run.sh" "$1/tests/"; }
fake()    { printf '#!/usr/bin/env bash\n%s\n' "$3" > "$1/tests/test-$2.sh"; }
# ambiente <dir> [VAR=valor...] — num subshell: SUITE_* do runner externo não
# vazam, bin/ da suíte falsa na frente do PATH. Sem `env`: aqui ele pode ser
# outro programa (aprendizado 2026-10-03).
ambiente() {
  local d="$1"; shift
  cd "$d" || exit 1
  unset SUITE_JOBS SUITE_TIMEOUT
  export PATH="$d/bin:$PATH" MARK="$d/mark"
  [ $# -gt 0 ] && export "$@"
  return 0
}
runs()   { (ambiente "$@" && bash tests/run.sh >"$SP/o" 2>"$SP/e"); code=$?; o="$(cat "$SP/o")"; e="$(cat "$SP/e")"; }
mescla() { (ambiente "$@" && bash tests/run.sh >"$SP/m" 2>&1); code=$?; m="$(cat "$SP/m")"; }
primeiras() { printf '%s\n' "$1" | head -n "$2" | tr '\n' ' '; }
ultima()    { printf '%s\n' "$1" | tail -n 1; }

d="$SP/s"

# --- suite-paralela/5 — blocos na ordem do glob; /8 resumo com tempo ---
mksuite "$d"
fake "$d" a 'sleep 2; echo a1; echo a2'
fake "$d" b 'echo b1; echo b2'
fake "$d" c 'sleep 1; echo c1'
runs "$d"
assert_eq 0 "$code" "suite-paralela/5 tudo verde sai 0"
assert_eq 'a1 a2 b1 b2 c1 ' "$(primeiras "$o" 5)" "suite-paralela/5 blocos na ordem do glob"
l="$(ultima "$o")"
s="$(printf '%s' "$l" | sed -nE 's/^run\.sh: 0 arquivo\(s\) de teste com falha \(([0-9]+) s\)$/\1/p')"
[ -n "$s" ] && ok || ko "suite-paralela/8 última linha com tempo — obtido '$l'"
[ "${s:-0}" -ge 2 ] && ok || ko "suite-paralela/8 tempo ≥ 2 s — obtido '${s:-}'"

# --- suite-paralela/7 — stderr do arquivo antes do stdout dele, no bloco ---
mksuite "$d"
fake "$d" a 'echo O1; echo E1 >&2; echo O2; echo E2 >&2'
runs "$d"
assert_eq "$(printf 'E1\nE2')" "$e" "suite-paralela/7 stderr do arquivo no stderr do run.sh"
assert_eq "$(printf 'O1\nO2')" "$(printf '%s\n' "$o" | sed '$d')" "suite-paralela/7 stdout sem as linhas de stderr"
mescla "$d"
assert_eq 'E1 E2 O1 O2 ' "$(primeiras "$m" 4)" "suite-paralela/7 stderr antes do stdout no bloco"

# --- suite-paralela/9 — falhas contadas, todos rodam, exit 1 ---
mksuite "$d"; mkdir -p "$d/mark"
fake "$d" ok 'touch "$MARK/ok"'
fake "$d" um 'touch "$MARK/um"; exit 1'
fake "$d" tres 'touch "$MARK/tres"; exit 3'
fake "$d" nada 'touch "$MARK/nada"; comando-inexistente-xyz'
runs "$d"
assert_eq 1 "$code" "suite-paralela/9 alguma falha → exit 1"
assert_contains "$(ultima "$o")" 'run.sh: 3 arquivo(s) de teste com falha (' "suite-paralela/9 conta as 3 falhas"
for k in ok um tres nada; do assert_file "$d/mark/$k" "suite-paralela/9 test-$k.sh rodou"; done

# --- suite-paralela/10 — tudo verde sai 0 ---
mksuite "$d"
fake "$d" x 'true'
fake "$d" y 'echo y'
runs "$d"
assert_eq 0 "$code" "suite-paralela/10 tudo verde → exit 0"
assert_contains "$(ultima "$o")" 'run.sh: 0 arquivo(s) de teste com falha (' "suite-paralela/10 resumo sem falha"

# --- suite-paralela/11 — suíte vazia → mensagem e exit 1 ---
mksuite "$d"
runs "$d"
assert_eq 1 "$code" "suite-paralela/11 suíte vazia → exit 1"
assert_eq 'run.sh: nenhum arquivo de teste' "$e" "suite-paralela/11 mensagem no stderr"
assert_empty "$o" "suite-paralela/11 stdout vazio"

report
