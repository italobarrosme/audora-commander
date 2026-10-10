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
# senão "reprovou: <motivo>". Código antes do 1º teste falhando reprova.
# - escrita: Write/Edit, ou Bash com `>`/`>>`/`tee` (corpo de heredoc descartado;
#   `>&N` e /dev/* ignorados) — em tests/ é teste novo; fora, e não .md, é código;
# - teste rodado: Bash que executa algo em tests/ (`bash|sh tests/…`, `./tests/…`);
#   falhando = is_error OU a saída mostra falha ("N teste(s) falhando" N>0,
#   FALHOU, exit=N≠0) — `bash tests/run.sh; echo "exit=$?"` sai 0 com a suíte falhando;
# - um comando Bash vira várias ações, na ordem em que aparecem nele.
grader_tdd() {
  perl - "$1" <<'PERL' 2>/dev/null
use strict; use warnings; use JSON::PP;
my (@ev, %erro);
open(my $h, '<', $ARGV[0]) or do { print "reprovou: faltou teste novo\n"; exit 0 };
while (my $l = <$h>) {
  my $d = eval { decode_json($l) } or next;
  next unless ref $d->{message} eq "HASH" && ref $d->{message}{content} eq "ARRAY";
  for my $b (@{ $d->{message}{content} }) {
    next unless ref $b eq "HASH";
    my $t = $b->{type} // "";
    if ($t eq "tool_use") { push @ev, [$b->{id} // "", $b->{name} // "", $b->{input} // {}] }
    elsif ($t eq "tool_result") {
      my $c = $b->{content} // "";
      $c = join "\n", map { ref $_ eq "HASH" ? $_->{text} // "" : $_ } @$c if ref $c eq "ARRAY";
      my $falhou = $b->{is_error} || $c =~ /\b[1-9]\d* teste\(s\) falhando|FALHOU|\bexit=[1-9]/;
      $erro{$b->{tool_use_id} // ""} = $falhou ? "F" : "P";
    }
  }
}
sub alvo {
  my $p = shift;
  return "T" if $p =~ m{(^|[\\/])tests[\\/]};
  return "-" if $p =~ /\.md$/i;
  return "C";
}
my @k;
for my $e (@ev) {
  my ($id, $nome, $in) = @$e;
  if ($nome =~ /^(Write|Edit|MultiEdit)$/) { push @k, alvo($in->{file_path} // ""); next }
  next unless $nome eq "Bash";
  my $cmd = $in->{command} // "";
  $cmd =~ s/<<-?\s*(['"]?)(\w+)\1([^\n]*)\n(?:.*?\n)??[ \t]*\2[ \t]*(?=\n|\z)/<<H$3/gs;
  my @a;
  while ($cmd =~ /(?<![0-9&>])>>?\s*(['"]?)([^\s;&|<>'"]+)\1/g) {
    push @a, [$-[0], alvo($2)] unless $2 =~ m{^/dev/};
  }
  while ($cmd =~ /\btee\s+(?:-a\s+)?(['"]?)([^\s;&|<>'"]+)\1/g) { push @a, [$-[0], alvo($2)] }
  while ($cmd =~ m{(?:\b(?:bash|sh)\s+|\./)tests[\\/]}g) { push @a, [$-[0], $erro{$id} // "-"] }
  push @k, map { $_->[1] } sort { $a->[0] <=> $b->[0] } @a;
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
PERL
}

# emula_grader <grader.md> <trace.jsonl> <workspace> — "passou" | "reprovou" |
# "erro: <motivo>". Emula OFFLINE só o que os casos usam (regex sobre trace ou
# arquivo; tool_used; tool_order), para provar graders sem gastar. NÃO é o
# veredito — o do host é; a rodada real confirma.
emula_grader() {
  perl - "$@" <<'PERL'
use strict; use warnings;
my ($gf, $tf, $ws) = @ARGV;
sub sai { print "$_[0]\n"; exit 0 }
sub ler { my $f = shift; open(my $h, '<:raw', $f) or return undef; local $/; my $t = <$h>; close $h; $t =~ s/\r\n/\n/g; $t }
sub val {
  my $v = shift; $v =~ s/^\s+|\s+$//g;
  if ($v =~ /^'(.*)'$/s) { (my $x = $1) =~ s/''/'/g; return $x }
  if ($v =~ /^"(.*)"$/s) { (my $x = $1) =~ s/\\(.)/$1/g; return $x }
  if ($v =~ /^\{(.*)\}$/s) {
    my ($in, %h) = ($1);
    while ($in =~ /\s*(\w+)\s*:\s*('(?:[^']|'')*'|"(?:[^"\\]|\\.)*"|[^,]*?)\s*(?:,|$)/g) { $h{$1} = val($2) }
    return \%h;
  }
  $v;
}
my $g = ler($gf) // sai("erro: grader ausente");
$g =~ /\A---\n(.*?)\n---/s or sai("erro: sem frontmatter");
my %c;
my %ok = map { $_ => 1 } qw(type weight arm pattern flags match target tool input_match min max before after);
for my $l (split /\n/, $1) {
  next if $l =~ /^\s*(#|$)/;
  $l =~ /^(\w+):\s*(.*)$/ or sai("erro: linha inválida: $l");
  $ok{$1} or sai("erro: chave desconhecida: $1");
  $c{$1} = val($2);
}
my $tipo = $c{type} // "";
# chamadas de ferramenta na ordem do trace: [nome, input JSON como está no trace]
my @usos;
my $trace = ler($tf) // "";
for my $l (split /\n/, $trace) {
  while ($l =~ /"type":"tool_use","id":"[^"]*","name":"([^"]+)","input":(?<bal>\{(?:[^{}"]++|"(?:[^"\\]++|\\.)*+"|(?&bal))*+\})/g) {
    push @usos, [$1, $+{bal}];
  }
}
sub casa_uso {
  my ($u, $spec) = @_;
  my ($t, $im) = ref $spec ? ($spec->{tool}, $spec->{input_match}) : ($spec, undef);
  return 0 unless $u->[0] eq ($t // "");
  return 1 unless defined $im;
  return $u->[1] =~ /$im/ ? 1 : 0;
}
if ($tipo eq "regex") {
  my $alvo = $c{target} // "last_message";
  my $texto;
  if (ref $alvo) { $texto = ler("$ws/$alvo->{path}") // sai("reprovou") }
  elsif ($alvo eq "trace") { $texto = $trace }
  else { sai("erro: alvo não emulado: $alvo") }
  my $fl = $c{flags} // ""; $fl =~ /^[ims]*$/ or sai("erro: flags não emuladas: $fl");
  my $re = eval { length $fl ? qr/(?$fl)$c{pattern}/ : qr/$c{pattern}/ } or sai("erro: regex inválida");
  my $n = () = $texto =~ /$re/g;
  my $m = $c{match} // "contains";
  if ($m eq "contains") { sai($n > 0 ? "passou" : "reprovou") }
  if ($m eq "not_contains") { sai($n == 0 ? "passou" : "reprovou") }
  if ($m =~ /^count:(\d+)$/) { sai($n == $1 ? "passou" : "reprovou") }
  sai("erro: match não emulado: $m");
}
if ($tipo eq "tool_used") {
  my $n = grep { casa_uso($_, { tool => $c{tool}, input_match => $c{input_match} }) } @usos;
  my $min = $c{min} // 1;
  sai($n >= $min && (!defined $c{max} || $n <= $c{max}) ? "passou" : "reprovou");
}
if ($tipo eq "tool_order") {
  my ($ib, $ia) = (-1, -1);
  for my $i (0 .. $#usos) {
    $ib = $i if $ib < 0 && casa_uso($usos[$i], $c{before});
    $ia = $i if $ia < 0 && casa_uso($usos[$i], $c{after});
  }
  sai($ib >= 0 && $ia >= 0 && $ib < $ia ? "passou" : "reprovou");
}
sai("erro: tipo não emulado: $tipo");
PERL
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

# --- mutação de regra ---

# busca_mutacao <raiz> <regra> — "caso<TAB>arquivo<TAB>início<TAB>fim" da regra em
# <raiz>/tests/evals/mutacoes.tsv (# = comentário); exit 1 se não existe
busca_mutacao() {
  [ -f "$1/tests/evals/mutacoes.tsv" ] || return 1
  tr -d '\r' < "$1/tests/evals/mutacoes.tsv" | awk -F'\t' -v OFS='\t' -v r="$2" '
    $1 == r && $1 !~ /^#/ { print $2, $3, $4, $5; achou = 1; exit } END { exit !achou }'
}

# copia_plugin <raiz> <destino> — cópia dos arquivos do repo (versionados e
# não ignorados), sem .git: o plugin como o humano o tem, para mutar sem tocar no repo
copia_plugin() {
  local f lista=()
  while IFS= read -r -d '' f; do [ -f "$1/$f" ] && lista+=("$f"); done \
    < <(git -C "$1" ls-files -co --exclude-standard -z)
  mkdir -p "$2"
  printf '%s\0' "${lista[@]}" | ( cd "$1" && tar --null -T - -cf - ) | tar -xf - -C "$2"
}

# aplica_mutacao <arquivo> <início> <fim> — remove da linha que contém <início>
# (única) até a 1ª linha seguinte, inclusive, que contém <fim>; preserva CRLF.
# Imprime "linhas A-B"; erro → exit 1 e o motivo no stderr
aplica_mutacao() {
  perl - "$@" <<'PERL'
use strict; use warnings;
my ($f, $ini, $fim) = @ARGV;
open(my $h, '<:raw', $f) or do { print STDERR "arquivo ilegível\n"; exit 1 };
my @l = <$h>; close $h;
my @i = grep { index($l[$_], $ini) >= 0 } 0 .. $#l;
if (!@i) { print STDERR "início não encontrado\n"; exit 1 }
if (@i > 1) { print STDERR "início ambíguo (" . scalar(@i) . " ocorrências)\n"; exit 1 }
my ($b) = grep { index($l[$_], $fim) >= 0 } $i[0] .. $#l;
if (!defined $b) { print STDERR "fim não encontrado depois do início\n"; exit 1 }
splice @l, $i[0], $b - $i[0] + 1;
open($h, '>:raw', $f) or do { print STDERR "arquivo não gravável\n"; exit 1 };
print $h @l; close $h;
print "linhas ", $i[0] + 1, "-", $b + 1, "\n";
PERL
}

# relatorio_mutacao <caso> <registros> — linha do resultado (registros "com" =
# skill original, "sem" = sem a regra); imprime e devolve o exit da rodada
relatorio_mutacao() {
  local mot cp cn sp sn ef
  if mot="$(motivo_de recusado "$2")"; then echo "RECUSADO · $1 · isolamento: $mot"; return 3; fi
  if mot="$(motivo_de infra "$2")"; then echo "ERRO INFRA · $1 · causa: $mot"; return 3; fi
  if motivo_de teto "$2" >/dev/null; then echo "NÃO RODADO · $1 · não rodado: teto"; return 2; fi
  cn="$(conta com '*' "$2")"; cp="$(conta com passou "$2")"
  sn="$(conta sem '*' "$2")"; sp="$(conta sem passou "$2")"
  if [ "$sp" -ge "$cp" ]; then
    ef="sem efeito"
  else
    ef="efeito $(awk -v c="$cp" -v s="$sp" -v n="$cn" 'BEGIN { v = 100 * (s - c) / n; r = int(v < 0 ? v - 0.5 : v + 0.5); printf "%+d", r }') pp"
  fi
  echo "com a regra $cp/$cn · sem a regra $sp/$sn · $ef"
  return 0
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
