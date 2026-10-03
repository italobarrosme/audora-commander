#!/usr/bin/env bash
# Roda todos os testes do plugin. Exit 1 se qualquer um falhar.
# Cada arquivo roda em background; a saída sai em blocos, na ordem do glob
# (stderr do arquivo, depois stdout), assim que ele e os anteriores acabam.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

shopt -s nullglob
arqs=(tests/test-*.sh)
shopt -u nullglob
[ "${#arqs[@]}" -gt 0 ] || { echo "run.sh: nenhum arquivo de teste" >&2; exit 1; }

jobs=1
W="$(mktemp -d)"
trap 'rm -rf "$W"' EXIT

# dispara <i> — roda o arquivo i em background; o exit chega em $W/<i>.rc (mv atômico)
dispara() {
  local i="$1"
  ( bash "${arqs[$i]}" </dev/null >"$W/$i.out" 2>"$W/$i.err"
    echo "$?" >"$W/$i.tmp" && mv "$W/$i.tmp" "$W/$i.rc" ) &
}
# despeja <i> — imprime o bloco do arquivo i e conta a falha
despeja() {
  local i="$1" rc
  read -r rc <"$W/$i.rc"
  cat "$W/$i.err" >&2
  cat "$W/$i.out"
  [ "$rc" -eq 0 ] || falhas=$((falhas+1))
}

total="${#arqs[@]}"; falhas=0; prox=0; impresso=0
while [ "$impresso" -lt "$total" ]; do
  while [ "$impresso" -lt "$prox" ] && [ -f "$W/$impresso.rc" ]; do
    despeja "$impresso"; impresso=$((impresso+1))
  done
  rodando=0
  for ((i=impresso; i<prox; i++)); do [ -f "$W/$i.rc" ] || rodando=$((rodando+1)); done
  while [ "$rodando" -lt "$jobs" ] && [ "$prox" -lt "$total" ]; do
    dispara "$prox"; prox=$((prox+1)); rodando=$((rodando+1))
  done
  [ "$impresso" -lt "$total" ] && sleep 0.1
done
wait
echo "run.sh: $falhas arquivo(s) de teste com falha ($SECONDS s)"
[ "$falhas" -eq 0 ]
