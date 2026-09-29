#!/usr/bin/env bash
# Biblioteca dos testes do plugin. Uso: source "$(dirname "$0")/lib.sh"
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SP="$(mktemp -d)"
trap 'rm -rf "$SP"' EXIT
PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); }
ko()   { FAIL=$((FAIL+1)); echo "  FAIL: $1" >&2; }
assert_eq()       { [ "$1" = "$2" ] && ok || ko "$3 — esperado '$1', obtido '$2'"; }
assert_contains() { printf '%s' "$1" | grep -qF -- "$2" && ok || ko "$3 — não contém '$2'"; }
assert_not_contains() { printf '%s' "$1" | grep -qF -- "$2" && ko "$3 — contém '$2'" || ok; }
assert_empty()    { [ -z "$1" ] && ok || ko "$2 — esperado vazio, obtido: $1"; }
assert_file()     { [ -f "$1" ] && ok || ko "$2 — arquivo ausente: $1"; }
assert_no_file()  { [ -e "$1" ] && ko "$2 — ainda existe: $1" || ok; }
# run_hook <nome-do-hook> <file_path>  → define out (stderr) e code
run_hook() {
  local p="${2//\\/\\\\}"
  out="$(printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$p" | bash "$ROOT/hooks/$1" 2>&1 >/dev/null)"; code=$?
}
report() { echo "$(basename "$0"): PASS=$PASS FAIL=$FAIL"; [ "$FAIL" -eq 0 ]; }
# path_sem_uv — o PATH atual sem nenhum dir que tenha uv/pipx.
path_sem_uv() {
  local d x r="" IFS=:
  for d in $PATH; do
    [ -n "$d" ] || continue
    for x in uv uv.exe pipx pipx.exe; do [ -e "$d/$x" ] && continue 2; done
    r="${r:+$r:}$d"
  done
  printf '%s' "$r"
}
# guarda_sem_uv <PATH> [<dir dos falsos>] — script com efeito fora do repo
# (uv/pipx uninstall) nunca alcança o uv/pipx REAIS (incidente 2026-09-29).
# Algum dir do PATH (fora o dos falsos) com uv/pipx, ou `command -v` fora do
# esperado → ko e aborta o arquivo ANTES de rodar o script.
guarda_sem_uv() {
  local d x reais="" esp_uv="" esp_px=""
  [ -n "${2:-}" ] && { esp_uv="$2/uv"; esp_px="$2/pipx"; }
  local IFS=:
  for d in $1; do
    [ -n "$d" ] && [ "$d" != "${2:-}" ] || continue
    for x in uv uv.exe pipx pipx.exe; do [ -e "$d/$x" ] && reais="$reais $d/$x"; done
  done
  [ -z "$reais" ] && [ "$(PATH="$1"; command -v uv)" = "$esp_uv" ] && [ "$(PATH="$1"; command -v pipx)" = "$esp_px" ] && { ok; return 0; }
  ko "fixture alcança uv/pipx reais:${reais:- command -v fora do esperado} — abortado sem rodar o script"; report; exit 1
}
