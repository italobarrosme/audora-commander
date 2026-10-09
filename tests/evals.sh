#!/usr/bin/env bash
# Evals de comportamento do plugin. MANUAL e PAGO — fica fora do tests/run.sh.
# Uso: bash tests/evals.sh [--completo] [--caso <nome>]... [--teto <usd>] [--modelo <m>]
#                          [--mutar <regra-id> [--runs <n>]]
#                          [--claude <bin>] [--raiz <dir>] [--timeout-run <s>]
# Exit: 0 tudo passou · 1 reprovou · 2 teto · 3 erro de infra/recusado/isolamento · 4 uso.
set -uo pipefail
. "$(dirname "$0")/evals-lib.sh"

uso() { echo "evals: $1" >&2; exit 4; }

completo=0; pedidos=(); teto=10; modelo=sonnet; mutar=""; runs=""
claude=""; raiz=""; timeout_run=900
while [ $# -gt 0 ]; do
  case "$1" in
    --completo) completo=1; shift; continue ;;
    --caso|--teto|--modelo|--mutar|--runs|--claude|--raiz|--timeout-run)
      [ $# -ge 2 ] || uso "$1 sem valor" ;;
    *) uso "opção desconhecida: $1" ;;
  esac
  case "$1" in
    --caso) pedidos+=("$2") ;;
    --teto) teto="$2" ;;
    --modelo) modelo="$2" ;;
    --mutar) mutar="$2" ;;
    --runs) runs="$2" ;;
    --claude) claude="$2" ;;
    --raiz) raiz="$2" ;;
    --timeout-run) timeout_run="$2" ;;
  esac
  shift 2
done

[[ "$teto" =~ ^[0-9]+(\.[0-9]+)?$ ]] && awk -v t="$teto" 'BEGIN{exit !(t > 0)}' \
  || uso "--teto inválido ('$teto')"
[ -z "$runs" ] || [ -n "$mutar" ] || uso "--runs só vale com --mutar"
[ -z "$runs" ] || [[ "$runs" =~ ^[1-9][0-9]*$ ]] || uso "--runs inválido ('$runs')"
[[ "$timeout_run" =~ ^[1-9][0-9]*$ ]] || uso "--timeout-run inválido ('$timeout_run')"
[ -n "$raiz" ] || raiz="$(cd "$(dirname "$0")/.." && pwd)"
[ -d "$raiz" ] || uso "--raiz inexistente ('$raiz')"

carrega_env "$raiz/.env"

# casos da rodada: os pedidos (validados) ou todos
declare -A tipo_de=()
todos=()
while IFS=$'\t' read -r n t; do
  [ -n "$n" ] || continue
  tipo_de["$n"]="$t"; todos+=("$n")
done < <(lista_casos "$raiz")
for p in "${pedidos[@]}"; do [ -n "${tipo_de[$p]+x}" ] || uso "caso desconhecido: $p"; done
casos=("${todos[@]}")
[ "${#pedidos[@]}" -eq 0 ] || casos=("${pedidos[@]}")

modo="modo rápido"; [ "$completo" -eq 0 ] || modo="modo completo"
echo "evals: $modo · modelo $modelo · teto US\$ $(awk -v t="$teto" 'BEGIN{printf "%.2f", t}')"

# pré-checagem do claude: ausente ou abaixo da mínima → todo caso vira erro de infra
infra=""
if [ -z "$claude" ]; then claude="$(acha_claude)"; [ -n "$claude" ] || infra="claude ausente (claude)"; fi
if [ -z "$infra" ] && [ ! -f "$claude" ] && ! command -v "$claude" >/dev/null 2>&1; then
  infra="claude ausente ($claude)"
fi
if [ -z "$infra" ]; then
  versao="$("$claude" --version 2>/dev/null | awk 'NR==1{print $1}')"
  if ! [[ "$versao" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then infra="claude --version sem versão"
  elif ! versao_ok "$versao" "$VERSAO_MINIMA"; then infra="claude $versao abaixo da mínima $VERSAO_MINIMA"
  fi
fi

for caso in "${casos[@]}"; do
  if [ -n "$infra" ]; then registra_infra "$caso" "$infra" 0 0; continue; fi
done

linha_total
exit "$(exit_rodada)"
