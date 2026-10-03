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
stubnproc() { printf '#!/usr/bin/env bash\necho %s\n' "$2" > "$1/bin/nproc"; chmod +x "$1/bin/nproc"; }
maxconc()   { cat "$1"/mark/n.* 2>/dev/null | sort -n | tail -n 1; }
# fake de concorrência: marca que está rodando, espera, conta quantos rodam juntos
CONC='mkdir -p "$MARK"; touch "$MARK/r.$$"; sleep 2
ls "$MARK" | grep -c "^r\." > "$MARK/n.$$"; rm -f "$MARK/r.$$"'
conc() { local k; mksuite "$1"; for k in $(seq "$2"); do fake "$1" "c$k" "$CONC"; done; }
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

# --- suite-paralela/1 — sem SUITE_JOBS, limite = núcleos ---
conc "$d" 4; stubnproc "$d" 2
runs "$d"
assert_eq 0 "$code" "suite-paralela/1 nproc 2 → exit 0"
assert_eq 2 "$(maxconc "$d")" "suite-paralela/1 nproc 2 → no máximo 2 juntos"
conc "$d" 4; stubnproc "$d" 8
runs "$d"
assert_eq 4 "$(maxconc "$d")" "suite-paralela/1 nproc 8 → os 4 juntos"

# --- suite-paralela/2 — SUITE_JOBS=N limita; N=1 é série ---
conc "$d" 4; stubnproc "$d" 8
runs "$d" SUITE_JOBS=2
assert_eq 2 "$(maxconc "$d")" "suite-paralela/2 SUITE_JOBS=2 → no máximo 2 juntos"
conc "$d" 2; stubnproc "$d" 8
runs "$d" SUITE_JOBS=1
assert_eq 1 "$(maxconc "$d")" "suite-paralela/2 SUITE_JOBS=1 → um de cada vez"

# --- suite-paralela/3 — SUITE_JOBS inválido → aviso e default ---
conc "$d" 4; stubnproc "$d" 2
runs "$d" SUITE_JOBS=abc
assert_contains "$e" "run.sh: SUITE_JOBS inválido ('abc') — usando 2" "suite-paralela/3 avisa abc"
assert_eq 2 "$(maxconc "$d")" "suite-paralela/3 abc → limite default"
assert_eq 0 "$code" "suite-paralela/3 abc → exit 0"
mksuite "$d"; fake "$d" t 'true'; stubnproc "$d" 2
for v in '0' '-1' ''; do
  runs "$d" "SUITE_JOBS=$v"
  assert_contains "$e" "run.sh: SUITE_JOBS inválido ('$v') — usando 2" "suite-paralela/3 avisa '$v'"
  assert_eq 0 "$code" "suite-paralela/3 '$v' → exit 0"
done

# --- suite-paralela/6 — bloco sai na hora, sem esperar os seguintes ---
mksuite "$d"; stubnproc "$d" 8
fake "$d" a 'echo a'
fake "$d" b 'sleep 6; echo b'
: > "$SP/f.o"
(ambiente "$d" && bash tests/run.sh >"$SP/f.o" 2>"$SP/f.e") & pid=$!
for k in $(seq 40); do grep -qx a "$SP/f.o" && break; sleep 0.1; done
fo="$(cat "$SP/f.o")"
wait "$pid"; code=$?
assert_contains "$fo" 'a' "suite-paralela/6 bloco de a sai antes de b acabar"
assert_not_contains "$fo" 'run.sh:' "suite-paralela/6 resumo ainda não saiu"
assert_eq 0 "$code" "suite-paralela/6 exit 0"

# --- suite-paralela/12+13 — SUITE_TIMEOUT=T mata a árvore do arquivo ---
# neto em laço limitado (~30 s): sem timeout, o red não deixa processo eterno
mksuite "$d"; mkdir -p "$d/mark"
fake "$d" ok 'true'
fake "$d" lento 'echo antes; (for k in $(seq 150); do touch "$MARK/tick"; sleep 0.2; done) & sleep 30'
s0=$SECONDS
mescla "$d" SUITE_TIMEOUT=2
dur=$((SECONDS - s0))
[ "$dur" -lt 15 ] && ok || ko "suite-paralela/13 SUITE_TIMEOUT=2 encerra cedo — levou $dur s"
assert_eq 1 "$code" "suite-paralela/12 timeout conta como falha → exit 1"
par="$(printf '%s\n' "$m" | grep -A1 -xF 'run.sh: TIMEOUT tests/test-lento.sh (2 s)' | tr '\n' '|')"
assert_eq 'run.sh: TIMEOUT tests/test-lento.sh (2 s)|antes|' "$par" "suite-paralela/12 linha de TIMEOUT no bloco, antes do stdout"
assert_contains "$(ultima "$m")" 'run.sh: 1 arquivo(s) de teste com falha (' "suite-paralela/12 resumo conta o timeout"
rm -f "$d/mark/tick"; sleep 1
assert_no_file "$d/mark/tick" "suite-paralela/12 nenhum processo do arquivo sobrou"

# --- suite-paralela/12 — arquivo que ignora TERM: KILL depois (exit 137), mesma linha ---
mksuite "$d"
fake "$d" teimoso 'trap "" TERM; sleep 30'
s0=$SECONDS
mescla "$d" SUITE_TIMEOUT=1
dur=$((SECONDS - s0))
[ "$dur" -lt 15 ] && ok || ko "suite-paralela/12 TERM ignorado ainda encerra (KILL) — levou $dur s"
assert_eq 1 "$code" "suite-paralela/12 TERM ignorado → exit 1"
assert_contains "$m" 'run.sh: TIMEOUT tests/test-teimoso.sh (1 s)' "suite-paralela/12 TERM ignorado ganha linha de TIMEOUT"
assert_not_contains "$m" 'Killed' "suite-paralela/12 aviso do shell não vaza fora do bloco"

# --- suite-paralela/12 — sem GNU timeout (ex.: timeout.exe do Windows na frente) ---
mksuite "$d"; fake "$d" t 'echo t'
printf '#!/usr/bin/env bash\nexit 1\n' > "$d/bin/timeout"; chmod +x "$d/bin/timeout"
runs "$d"
assert_contains "$e" 'run.sh: timeout ausente — rodando sem limite' "suite-paralela/12 avisa timeout ausente"
assert_eq 0 "$code" "suite-paralela/12 timeout ausente → roda sem limite, exit 0"
assert_eq 't ' "$(primeiras "$o" 1)" "suite-paralela/12 timeout ausente → o arquivo rodou"

# --- suite-paralela/14 — SUITE_TIMEOUT=0 roda sem limite ---
mksuite "$d"; fake "$d" t 'sleep 3'
runs "$d" SUITE_TIMEOUT=0
assert_eq 0 "$code" "suite-paralela/14 SUITE_TIMEOUT=0 → exit 0"
assert_not_contains "$e" 'inválido' "suite-paralela/14 0 não é inválido"
assert_not_contains "$e" 'TIMEOUT' "suite-paralela/14 sem timeout"

# --- suite-paralela/15 — SUITE_TIMEOUT inválido → aviso e 300 ---
mksuite "$d"; fake "$d" t 'true'
for v in 'x' '-5' ''; do
  runs "$d" "SUITE_TIMEOUT=$v"
  assert_contains "$e" "run.sh: SUITE_TIMEOUT inválido ('$v') — usando 300" "suite-paralela/15 avisa '$v'"
  assert_eq 0 "$code" "suite-paralela/15 '$v' → exit 0"
done

# --- suite-paralela/16 — hooks/gate com o default `bash tests/run.sh` ---
gproj="$SP/gproj"
mkgate() {  # mkgate <corpo de test-b.sh>
  mksuite "$gproj"; rm -rf "$gproj/bin"
  fake "$gproj" a 'true'
  fake "$gproj" b "$1"
  git -C "$gproj" init -q
  git -C "$gproj" config user.email gate@test; git -C "$gproj" config user.name gate
  git -C "$gproj" config core.autocrlf false
  git -C "$gproj" config core.excludesFile "$SP/sem-ignore"
  git -C "$gproj" add -A; git -C "$gproj" commit -qm base
}
rungate() {
  out="$(cd "$gproj" && unset GATE_SUITE_CMD SUITE_JOBS SUITE_TIMEOUT &&
         GATE_ROOT="$gproj" bash "$ROOT/hooks/gate" 2>&1)"; code=$?
}
mkgate 'echo b'; rungate
assert_eq 0 "$code" "suite-paralela/16 suíte verde → gate exit 0"
assert_contains "$out" 'GATE: passou' "suite-paralela/16 suíte verde → GATE: passou"
mkgate 'exit 1'; rungate
assert_eq 1 "$code" "suite-paralela/16 arquivo vermelho → gate exit 1"
assert_contains "$out" 'GATE: reprovado' "suite-paralela/16 arquivo vermelho → GATE: reprovado"
assert_contains "$out" 'suite falhou: bash tests/run.sh' "suite-paralela/16 reprova pelo motivo da suíte"

# --- docs citam as variáveis do run.sh ---
for f in README.md README.pt-BR.md; do
  r="$(cat "$f")"
  assert_contains "$r" 'SUITE_JOBS' "docs $f cita SUITE_JOBS"
  assert_contains "$r" 'SUITE_TIMEOUT' "docs $f cita SUITE_TIMEOUT"
done

report
