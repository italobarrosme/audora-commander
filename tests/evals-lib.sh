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

# --- resultado de um run ---
# Registro de run (comum aos dois tipos de caso), 1 por linha:
#   braço<TAB>status<TAB>custo<TAB>tokens<TAB>motivo
# braço ∈ com|sem|- (- = a invocação toda); status ∈ passou|reprovou|infra|recusado|teto

# posix_path <caminho> — caminho do Windows (como o host devolve) em forma POSIX
posix_path() {
  [ -n "$1" ] || return 0
  if command -v cygpath >/dev/null 2>&1; then cygpath -u "$1"; else printf '%s' "${1//\\//}"; fi
}

# classifica_erro <texto> — erro de um run: infra (timeout, API) ou reprovação
classifica_erro() {
  if printf '%s' "$1" | grep -qiE 'timed? ?out'; then echo "infra: timeout"
  elif printf '%s' "$1" | grep -qiE 'API Error|overloaded|rate.?limit|ECONNRESET|ETIMEDOUT|socket hang up'; then echo "infra: API"
  else echo "reprovado"
  fi
}

# tokens_trace <trace.jsonl> — input + cache_creation + cache_read + output do
# último evento com total_cost_usd; 0 sem arquivo ou sem esse evento
tokens_trace() {
  [ -f "$1" ] || { echo 0; return; }
  perl -MJSON::PP -ne '
    next unless /"total_cost_usd"/;
    my $d = eval { decode_json($_) } or next;
    my $u = $d->{usage} // {};
    $t = 0; $t += $u->{$_} // 0 for qw(input_tokens cache_creation_input_tokens cache_read_input_tokens output_tokens);
    END { print $t // 0, "\n" }' "$1" 2>/dev/null || echo 0
}

# le_resultado <json> — por run do 1º caso: braço<TAB>score<TAB>erro<TAB>custo<TAB>trace<TAB>motivo
# (custo = costUsd + judgeCostUsd; motivo = "nome: explanation" dos graders reprovados)
le_resultado() {
  [ -s "$1" ] || return 1
  perl -MJSON::PP -0777 -ne '
    my $d = eval { decode_json($_) } or die "json inválido\n";
    my $arms = $d->{cases}[0]{arms} // {};
    for my $arm ([with => "com"], [without => "sem"]) {
      for my $r (@{ $arms->{$arm->[0]} // [] }) {
        my @m = map { "$_->{name}: " . ($_->{explanation} // "") } grep { !$_->{passed} } @{ $r->{graders} // [] };
        my $e = $r->{error} // ""; $e =~ s/\s+/ /g;
        my $mot = join("; ", @m); $mot =~ s/\s+/ /g;
        print join("\t", $arm->[1], $r->{score} // 0, $e,
          ($r->{costUsd} // 0) + ($r->{judgeCostUsd} // 0), $r->{tracePath} // "", $mot), "\n";
      }
    }' "$1"
}

# motivo_parcial <json> — partialReason se a rodada do host ficou parcial; vazio senão
motivo_parcial() {
  perl -MJSON::PP -0777 -ne '
    my $d = eval { decode_json($_) } or exit;
    print $d->{partialReason} // "desconhecido" if $d->{partial};' "$1" 2>/dev/null
}

# limpa_temp_eval <tracePath> — apaga o diretório 2 níveis acima do trace só se
# ele é um claude-eval-* (o --keep-temp o deixa para trás no Windows)
limpa_temp_eval() {
  [ -n "$1" ] || return 0
  local d; d="$(dirname "$(dirname "$(posix_path "$1")")")"
  case "$(basename "$d")" in claude-eval-*) rm -rf "$d" ;; esac
}

# grader_tdd <stream.jsonl> — "passou" se o transcript mostra, nesta ordem: teste
# novo escrito → teste rodado falhando → código editado → teste rodado passando;
# senão "reprovou: <motivo>". Teste novo = Write/Edit em tests/; teste rodado =
# Bash que cita tests/ (falhando = is_error do tool_result); código = Write/Edit
# fora de tests/ e não .md. Código antes do 1º teste falhando reprova.
grader_tdd() {
  perl -MJSON::PP -ne '
    my $d = eval { decode_json($_) } or next;
    next unless ref $d->{message} eq "HASH" && ref $d->{message}{content} eq "ARRAY";
    for my $b (@{ $d->{message}{content} }) {
      next unless ref $b eq "HASH";
      my $t = $b->{type} // "";
      if ($t eq "tool_use") { push @ev, [$b->{id} // "", $b->{name} // "", $b->{input} // {}] }
      elsif ($t eq "tool_result") { $erro{$b->{tool_use_id} // ""} = $b->{is_error} ? "F" : "P" }
    }
    END {
      my @k;
      for my $e (@ev) {
        my ($id, $nome, $in) = @$e;
        my $k = "-";
        if ($nome =~ /^(Write|Edit|MultiEdit)$/) {
          my $p = $in->{file_path} // "";
          if ($p =~ m{(^|[\\/])tests[\\/]}) { $k = "T" }
          elsif ($p !~ /\.md$/i) { $k = "C" }
        } elsif ($nome eq "Bash" && ($in->{command} // "") =~ m{tests[\\/]}) {
          $k = $erro{$id} // "-";
        }
        push @k, $k;
      }
      my $s = join "", @k;
      my $i1 = index $s, "T";
      my $i2 = $i1 < 0 ? -1 : index $s, "F", $i1;
      my $i3 = $i2 < 0 ? -1 : index $s, "C", $i2;
      my $i4 = $i3 < 0 ? -1 : index $s, "P", $i3;
      my $c = index $s, "C";
      if ($i1 < 0) { print "reprovou: faltou teste novo\n" }
      elsif ($c >= 0 && $c < $i1) { print "reprovou: código editado antes do teste falhando\n" }
      elsif ($i2 < 0) { print "reprovou: faltou teste falhando depois do teste novo\n" }
      elsif ($c >= 0 && $c < $i2) { print "reprovou: código editado antes do teste falhando\n" }
      elsif ($i3 < 0) { print "reprovou: faltou código editado depois do teste falhando\n" }
      elsif ($i4 < 0) { print "reprovou: faltou teste passando depois do código\n" }
      else { print "passou\n" }
    }' "$1" 2>/dev/null
}

# --- isolamento ---
PLUGIN=audora-commander

# plugins_suite <json> — nomes dos plugins que o host carregou, por vírgula
plugins_suite() {
  perl -MJSON::PP -0777 -ne '
    my $d = eval { decode_json($_) } or next;
    print join(",", map { $_->{name} // "" } @{ $d->{suite}{plugins} // [] });' "$1" 2>/dev/null
}

# plugins_sessao <trace.jsonl> — plugins não-@builtin do evento system/init,
# por vírgula; exit 1 sem arquivo ou sem init
plugins_sessao() {
  [ -f "$1" ] || return 1
  perl -MJSON::PP -ne '
    next unless /"init"/;
    my $d = eval { decode_json($_) } or next;
    next unless ($d->{type} // "") eq "system" && ($d->{subtype} // "") eq "init";
    print join(",", map { $_->{name} // "" } grep { ($_->{source} // "") !~ /\@builtin$/ } @{ $d->{plugins} // [] });
    $achou = 1; last;
    END { $? = $achou ? 0 : 1 }' "$1" 2>/dev/null
}

# isolamento_run <trace> <braço> <erro> — vazio se a sessão do run tinha só o
# esperado (com: o plugin; sem: nenhum); senão o motivo da recusa. Run com erro
# e sem trace é infra, não recusa.
isolamento_run() {
  local p esperado=""
  [ "$2" = sem ] || esperado="$PLUGIN"
  if p="$(plugins_sessao "$1")"; then
    [ "$p" = "$esperado" ] || echo "plugins na sessão ${p:-(nenhum)}"
  elif [ -z "$3" ]; then
    echo "sem evento init no trace"
  fi
}

# confere_git <antes> <depois> — exit 0 se iguais; senão 1 e a 1ª linha divergente
confere_git() {
  [ "$1" = "$2" ] && return 0
  local so_em='NR == FNR { if ($0 != "") a[$0] = 1; next } $0 != "" && !($0 in a) { print; exit }'
  { awk "$so_em" <(printf '%s\n' "$1") <(printf '%s\n' "$2")
    awk "$so_em" <(printf '%s\n' "$2") <(printf '%s\n' "$1"); } | head -1
  return 1
}

# registros_plugin_eval <json> — registros de run a partir do JSON do host
# (lê os tokens do trace, confere o isolamento e apaga o temporário de cada run)
registros_plugin_eval() {
  local l braco score erro custo tr mot t tok cls iso
  # TAB é whitespace de IFS (campos vazios se fundiriam): separa por \x1f
  while IFS= read -r l; do
    IFS=$'\x1f' read -r braco score erro custo tr mot <<< "${l//$'\t'/$'\x1f'}"
    t="$(posix_path "$tr")"; tok="$(tokens_trace "$t")"
    iso="$(isolamento_run "$t" "$braco" "$erro")"
    if [ -n "$iso" ]; then
      printf '%s\trecusado\t%s\t%s\t%s\n' "$braco" "$custo" "$tok" "$iso"
    elif [ -n "$erro" ]; then
      cls="$(classifica_erro "$erro")"
      case "$cls" in
        "infra: timeout") printf '%s\tinfra\t%s\t%s\ttimeout (%s)\n' "$braco" "$custo" "$tok" "$erro" ;;
        "infra: API") printf '%s\tinfra\t%s\t%s\tAPI (%s)\n' "$braco" "$custo" "$tok" "$erro" ;;
        *) printf '%s\treprovou\t%s\t%s\trun: %s\n' "$braco" "$custo" "$tok" "$erro" ;;
      esac
    elif awk -v s="$score" 'BEGIN{exit !(s == 1)}'; then
      printf '%s\tpassou\t%s\t%s\t\n' "$braco" "$custo" "$tok"
    else
      [ -n "$mot" ] || mot="score $score"
      printf '%s\treprovou\t%s\t%s\t%s\n' "$braco" "$custo" "$tok" "$mot"
    fi
    limpa_temp_eval "$tr"
  done < <(le_resultado "$1")
}

# --- caso harness (claude -p próprio) ---

# token_ok — exit 0 se há CLAUDE_CODE_OAUTH_TOKEN ou ANTHROPIC_API_KEY de verdade
token_ok() {
  local v
  for v in CLAUDE_CODE_OAUTH_TOKEN ANTHROPIC_API_KEY; do
    [ -n "${!v-}" ] && [ "${!v}" != "$PLACEHOLDER" ] && return 0
  done
  return 1
}

# resultado_stream <stream.jsonl> — do último evento result, separados por \x1f:
# subtype, is_error (0/1), api_error_status, total_cost_usd, texto; exit 1 sem result
resultado_stream() {
  [ -f "$1" ] || return 1
  perl -MJSON::PP -ne '
    next unless /"type"\s*:\s*"result"/;
    my $d = eval { decode_json($_) } or next;
    next unless ($d->{type} // "") eq "result";
    my $t = $d->{result} // ""; $t =~ s/\s+/ /g;
    $r = join("\x1f", $d->{subtype} // "", $d->{is_error} ? 1 : 0, $d->{api_error_status} // "", $d->{total_cost_usd} // 0, $t);
    END { print "$r\n" if defined $r; $? = defined $r ? 0 : 1 }' "$1" 2>/dev/null
}

# analisa_stream <stream.jsonl> <braço> <exit do claude> <timeout-run> — registro
# de run: timeout > sem result > isolamento > teto > auth > API > erro > grader_tdd
analisa_stream() {
  local s="$1" b="$2" rc="$3" r sub ie api custo txt tok iso v
  if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
    printf '%s\tinfra\t0\t%s\ttimeout (%s s)\n' "$b" "$(tokens_trace "$s")" "$4"; return
  fi
  r="$(resultado_stream "$s")" || { printf '%s\tinfra\t0\t0\tsem evento result (exit %s)\n' "$b" "$rc"; return; }
  IFS=$'\x1f' read -r sub ie api custo txt <<< "$r"
  tok="$(tokens_trace "$s")"
  iso="$(isolamento_run "$s" "$b" "")"
  if [ -n "$iso" ]; then printf '%s\trecusado\t%s\t%s\t%s\n' "$b" "$custo" "$tok" "$iso"
  elif [ "$sub" = error_max_budget_usd ]; then printf '%s\tteto\t%s\t%s\t\n' "$b" "$custo" "$tok"
  elif [ "$ie" = 1 ] && printf '%s' "$txt" | grep -qiE 'not logged in|/login|invalid api key|authenticat'; then
    printf '%s\tinfra\t%s\t%s\tsem autenticação\n' "$b" "$custo" "$tok"
  elif [ -n "$api" ]; then printf '%s\tinfra\t%s\t%s\tAPI (%s)\n' "$b" "$custo" "$tok" "$api"
  elif [ "$ie" = 1 ]; then printf '%s\treprovou\t%s\t%s\trun: %s\n' "$b" "$custo" "$tok" "$sub"
  else
    v="$(grader_tdd "$s")"
    if [ "$v" = passou ]; then printf '%s\tpassou\t%s\t%s\t\n' "$b" "$custo" "$tok"
    else printf '%s\treprovou\t%s\t%s\t%s\n' "$b" "$custo" "$tok" "${v#reprovou: }"
    fi
  fi
}

# --- contadores da rodada e aritmética decimal (awk; o Git Bash não tem bc) ---
N_CASOS=0; N_PASSOU=0; N_REPROVOU=0; N_INFRA=0; N_NAO_RODADO=0
GASTO=0; TOKENS=0; ISOLAMENTO_VIOLADO=0; TETO_ATINGIDO=0
soma() { awk -v a="$1" -v b="$2" 'BEGIN{printf "%.10g", a+b}'; }
usd()  { awk -v a="$1" 'BEGIN{printf "%.4f", a}'; }

# acumula <custo> <tokens> — soma ao gasto e aos tokens da rodada
acumula() { GASTO="$(soma "$GASTO" "$1")"; TOKENS=$((TOKENS + $2)); }

# registra_infra <caso> <causa> <custo> <tokens> — linha ERRO INFRA e contadores
registra_infra() {
  N_CASOS=$((N_CASOS+1)); N_INFRA=$((N_INFRA+1)); acumula "$3" "$4"
  echo "ERRO INFRA · $1 · causa: $2 · US\$ $(usd "$3") · tokens $4"
}

# motivo_de <status> <registros> — motivo do 1º registro com esse status; exit 1 se nenhum
motivo_de() {
  awk -F'\t' -v s="$1" '$2 == s { print $5; achou = 1; exit } END { exit !achou }' "$2"
}
# conta <braço> <status|*> <registros> — quantos registros do braço com o status
conta() {
  awk -F'\t' -v b="$1" -v s="$2" '$1 == b && (s == "*" || $2 == s) { n++ } END { print n+0 }' "$3"
}

# agrega_caso <caso> <registros> <completo 0|1> — linha do caso e contadores
# (recusado > infra > teto > passou/reprovou; passa só com todos os runs com o plugin)
agrega_caso() {
  local caso="$1" f="$2" custo tok mot cp cn sp sn det delta
  custo="$(awk -F'\t' '{ s += $3 } END { printf "%.10g", s+0 }' "$f")"
  tok="$(awk -F'\t' '{ s += $4 } END { print s+0 }' "$f")"
  if mot="$(motivo_de recusado "$f")"; then
    N_CASOS=$((N_CASOS+1)); N_INFRA=$((N_INFRA+1)); acumula "$custo" "$tok"
    echo "RECUSADO · $caso · isolamento: $mot"; return
  fi
  if mot="$(motivo_de infra "$f")"; then registra_infra "$caso" "$mot" "$custo" "$tok"; return; fi
  if motivo_de teto "$f" >/dev/null; then
    TETO_ATINGIDO=1
    N_CASOS=$((N_CASOS+1)); N_NAO_RODADO=$((N_NAO_RODADO+1)); acumula "$custo" "$tok"
    echo "NÃO RODADO · $caso · não rodado: teto"; return
  fi
  cn="$(conta com '*' "$f")"; cp="$(conta com passou "$f")"
  [ "$cn" -gt 0 ] || { registra_infra "$caso" "nenhum run com o plugin" "$custo" "$tok"; return; }
  det="com $cp/$cn"
  if [ "$3" = 1 ]; then
    sn="$(conta sem '*' "$f")"; sp="$(conta sem passou "$f")"
    delta="$(awk -v c="$cp" -v s="$sp" -v n="$cn" 'BEGIN { v = 100 * (c - s) / n; r = int(v < 0 ? v - 0.5 : v + 0.5); printf "%+d", r }')"
    det="$det · sem $sp/$sn · Δ $delta pp"
  fi
  N_CASOS=$((N_CASOS+1)); acumula "$custo" "$tok"
  if [ "$cp" -eq "$cn" ]; then
    N_PASSOU=$((N_PASSOU+1))
    echo "PASSOU · $caso · $det · US\$ $(usd "$custo") · tokens $tok"
  else
    N_REPROVOU=$((N_REPROVOU+1))
    mot="$(awk -F'\t' '$1 == "com" && $2 == "reprovou" { print $5; exit }' "$f")"
    echo "REPROVOU · $caso · $det · US\$ $(usd "$custo") · tokens $tok · motivo: $mot"
  fi
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
