#!/usr/bin/env bash
# Funções do orquestrador de evals (tests/evals.sh). Só definições: dá para
# `source` sem efeito colateral. JSON via perl JSON::PP, como os hooks.

VERSAO_MINIMA=2.1.269
PLACEHOLDER=__coloque_o_valor__

# acha_claude — caminho do claude: o do PATH, senão o do instalador; vazio se nenhum
acha_claude() {
  local c
  c="$(command -v claude 2>/dev/null)" && { echo "$c"; return; }
  [ -f "$HOME/.local/bin/claude.exe" ] && echo "$HOME/.local/bin/claude.exe"
}

# versao_ok <versao> <minima> — exit 0 se versao >= minima (ordem numérica)
versao_ok() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]
}

# carrega_env <arquivo> — exporta CHAVE=valor só se a variável está unset e o
# valor não é vazio nem o placeholder; comentário, linha vazia e CR ignorados
carrega_env() {
  local linha k v
  [ -f "$1" ] || return 0
  while IFS= read -r linha || [ -n "$linha" ]; do
    linha="${linha%$'\r'}"
    [[ "$linha" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]] || continue
    k="${BASH_REMATCH[1]}"; v="${BASH_REMATCH[2]}"
    [ -n "$v" ] && [ "$v" != "$PLACEHOLDER" ] || continue
    [ -z "${!k+x}" ] || continue
    export "$k=$v"
  done < "$1"
}

# lista_casos <raiz> — "nome<TAB>tipo" por caso de <raiz>/tests/evals, em ordem
# alfabética; pasta com _ no começo ou sem prompt.md/harness.md fica de fora
lista_casos() {
  local d n
  for d in "$1"/tests/evals/*/; do
    [ -d "$d" ] || continue
    n="$(basename "$d")"
    case "$n" in _*) continue ;; esac
    if [ -f "$d/prompt.md" ]; then printf '%s\tplugin-eval\n' "$n"
    elif [ -f "$d/harness.md" ]; then printf '%s\tharness\n' "$n"
    fi
  done | LC_ALL=C sort
}

# --- contadores da rodada e aritmética decimal (awk; o Git Bash não tem bc) ---
N_CASOS=0; N_PASSOU=0; N_REPROVOU=0; N_INFRA=0; N_NAO_RODADO=0
GASTO=0; TOKENS=0; ISOLAMENTO_VIOLADO=0
soma() { awk -v a="$1" -v b="$2" 'BEGIN{printf "%.10g", a+b}'; }
usd()  { awk -v a="$1" 'BEGIN{printf "%.4f", a}'; }

# acumula <custo> <tokens> — soma ao gasto e aos tokens da rodada
acumula() { GASTO="$(soma "$GASTO" "$1")"; TOKENS=$((TOKENS + $2)); }

# registra_infra <caso> <causa> <custo> <tokens> — linha ERRO INFRA e contadores
registra_infra() {
  N_CASOS=$((N_CASOS+1)); N_INFRA=$((N_INFRA+1)); acumula "$3" "$4"
  echo "ERRO INFRA · $1 · causa: $2 · US\$ $(usd "$3") · tokens $4"
}

# linha_total — a última linha do relatório
linha_total() {
  echo "total: $N_CASOS caso(s) · $N_PASSOU passou · $N_REPROVOU reprovou · $N_INFRA erro de infra · $N_NAO_RODADO não rodado · US\$ $(usd "$GASTO") · tokens $TOKENS"
}

# exit_rodada — 3 (infra, recusado, isolamento) > 2 (teto) > 1 (reprovou) > 0
exit_rodada() {
  if [ "$N_INFRA" -gt 0 ] || [ "$ISOLAMENTO_VIOLADO" -gt 0 ]; then echo 3
  elif [ "$N_NAO_RODADO" -gt 0 ]; then echo 2
  elif [ "$N_REPROVOU" -gt 0 ]; then echo 1
  else echo 0
  fi
}
