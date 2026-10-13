#!/usr/bin/env bash
# Orquestrador de evals de comportamento (evals.sh) — tudo offline, com um
# claude falso (stub). O claude real nunca roda aqui (evals-comportamento/12).
source "$(dirname "$0")/lib.sh"
. "$ROOT/tests/evals-lib.sh"
. "$ROOT/tests/evals-testlib.sh"
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
assert_contains "$err" "evals: --runs só vale com --mutar ou --completo" "porta-anuncio/13 --runs sozinho recusado"
err="$(roda_evals --completo --runs 0 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "porta-anuncio/13 --completo --runs 0 sai 4"
assert_contains "$err" "evals: --runs inválido ('0')" "porta-anuncio/13 --completo --runs 0 explica"
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

# --- evals-comportamento/1: caso plugin-eval no modo rápido ---
RZ="$SP/raiz1"; mkraiz "$RZ" porta
T1="$SP/claude-eval-x1/out/trace.jsonl"
reseta_pe; trace "$T1" 10 7632 8239 600
resultado "$SP/pe/r.json" "$(run 1 null 0.4123 "$T1")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 0 "$code" "evals-comportamento/1 caso que passa sai 0"
assert_contains "$out" "PASSOU · porta · com 1/1 · US\$ 0.4123 · tokens 16481" "evals-comportamento/1 linha PASSOU com custo e tokens"
assert_contains "$out" "total: 1 caso(s) · 1 passou · 0 reprovou · 0 erro de infra · 0 não rodado · US\$ 0.4123 · tokens 16481" "evals-comportamento/1 total da rodada"
assert_no_file "$SP/claude-eval-x1" "evals-comportamento/1 apaga o claude-eval-* deixado pelo --keep-temp"
inv="$(grep '^plugin eval' "$SP/stub.log")"
tmpj="$(printf '%s' "$inv" | sed -n 's/.* --json \([^ ]*\) .*/\1/p')"; tmpj="${tmpj%/r.json}"
assert_eq "plugin eval $RZ --eval-dir tests/evals --case porta --runs 1 --ablation none --threshold 0 --trust-plugin --scaffold --allow-tools Write Edit --model sonnet --keep-temp --no-publish --max-cost-usd 10.0000 --json $tmpj/r.json --output-dir $tmpj/out" \
  "$inv" "evals-comportamento/1 invocação exata do plugin eval"

reseta_pe; trace "$T1" 10 7632 8239 600
resultado "$SP/pe/r.json" "$(run 0.5 null 0.4123 "$T1" "$G_CAT")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 1 "$code" "evals-comportamento/1 caso reprovado sai 1"
assert_contains "$out" "REPROVOU · porta · com 0/1 · US\$ 0.4123 · tokens 16481 · motivo: categoria: no match" "evals-comportamento/1 REPROVOU com o motivo do grader"
assert_contains "$out" "· 0 passou · 1 reprovou ·" "evals-comportamento/1 total conta reprovado"

reseta_pe; mkdir -p "$SP/outro/out"; T2="$SP/outro/out/trace.jsonl"; trace "$T2" 1 2 3 4
resultado "$SP/pe/r.json" "$(run 1 null 0.1 "$T2")"
roda_evals >/dev/null 2>&1
assert_file "$T2" "evals-comportamento/1 trace fora de claude-eval-* fica"

reseta_pe; trace "$T1" 1 1 1 1
resultado "$SP/pe/r.json" "$(run 0 null 0.2 "$T1")"
out="$(roda_evals 2>/dev/null)"
assert_contains "$out" "REPROVOU · porta · com 0/1 · US\$ 0.2000 · tokens 4 · motivo: score 0" "evals-comportamento/1 reprovado sem grader falho diz o score"

# dois casos: total soma custo e tokens
RZ="$SP/raiz2"; mkraiz "$RZ" memoria porta
reseta_pe; trace "$SP/claude-eval-p/out/trace.jsonl" 1 2 3 4; trace "$SP/claude-eval-m/out/trace.jsonl" 10 20 30 40
resultado "$SP/pe/porta.json" "$(run 1 null 0.25 "$SP/claude-eval-p/out/trace.jsonl")"
resultado "$SP/pe/memoria.json" "$(run 1 null 0.5 "$SP/claude-eval-m/out/trace.jsonl")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 0 "$code" "evals-comportamento/1 dois casos que passam saem 0"
assert_contains "$out" "PASSOU · memoria · com 1/1 · US\$ 0.5000 · tokens 100" "evals-comportamento/1 caso memoria"
assert_contains "$out" "total: 2 caso(s) · 2 passou · 0 reprovou · 0 erro de infra · 0 não rodado · US\$ 0.7500 · tokens 110" "evals-comportamento/1 total soma os casos"
assert_eq 2 "$(grep -c '^plugin eval' "$SP/stub.log")" "evals-comportamento/1 uma invocação por caso"
assert_contains "$(grep -- '--case porta' "$SP/stub.log")" "--max-cost-usd 9.5000" "evals-comportamento/1 2º caso recebe o teto restante"

# --- evals-comportamento/9: erros de infra do run e da invocação ---
RZ="$SP/raiz1"
reseta_pe; trace "$T1" 10 7632 8239 600
resultado "$SP/pe/r.json" "$(run 1 '"timed out after 600s"' 0.4123 "$T1")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/9 timeout sai 3"
assert_contains "$out" "ERRO INFRA · porta · causa: timeout (timed out after 600s) · US\$ 0.4123 · tokens 16481" "evals-comportamento/9 timeout é infra, nunca aprovado"

reseta_pe; trace "$T1" 1 1 1 1
resultado "$SP/pe/r.json" "$(run 1 '"API Error: 529 overloaded"' 0.1 "$T1")"
out="$(roda_evals 2>/dev/null)"
assert_contains "$out" "ERRO INFRA · porta · causa: API (API Error: 529 overloaded)" "evals-comportamento/9 erro de API é infra"

reseta_pe; trace "$T1" 1 1 1 1
resultado "$SP/pe/r.json" "$(run 1 '"reached max turns (40)"' 0.1 "$T1")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 1 "$code" "evals-comportamento/9 limite de turnos é reprovação, não infra"
assert_contains "$out" "REPROVOU · porta · com 0/1 · US\$ 0.1000 · tokens 4 · motivo: run: reached max turns (40)" "evals-comportamento/9 limite de turnos explica"

reseta_pe; resultado "$SP/pe/r.json" "" "" true auth_failed; echo 2 > "$SP/pe/rc"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/9 sem autenticação sai 3"
assert_contains "$out" "ERRO INFRA · porta · causa: sem autenticação · US\$ 0.0000 · tokens 0" "evals-comportamento/9 sem autenticação"

reseta_pe; echo 1 > "$SP/pe/rc"; printf 'No eval cases found\nmais linha\n' > "$SP/pe/stderr"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/9 plugin eval sem JSON sai 3"
assert_contains "$out" "ERRO INFRA · porta · causa: plugin eval saiu 1: No eval cases found · US\$ 0.0000 · tokens 0" "evals-comportamento/9 plugin eval sem JSON explica"

# --- evals-comportamento/8: teto de custo da rodada ---
RZ="$SP/raiz3"; mkraiz "$RZ" a b c
TA="$SP/claude-eval-a/out/trace.jsonl"; TB="$SP/claude-eval-b/out/trace.jsonl"
reseta_pe; trace "$TA" 1 1 1 1
resultado "$SP/pe/a.json" "$(run 1 null 1.2 "$TA")"
out="$(roda_evals --teto 1 2>/dev/null)"; code=$?
assert_eq 2 "$code" "evals-comportamento/8 teto atingido sai 2 (≠ reprovação)"
assert_contains "$out" "PASSOU · a · com 1/1 · US\$ 1.2000" "evals-comportamento/8 caso que estourou ainda conta"
assert_contains "$out" "NÃO RODADO · b · não rodado: teto" "evals-comportamento/8 caso seguinte não rodado"
assert_contains "$out" "NÃO RODADO · c · não rodado: teto" "evals-comportamento/8 todos os restantes não rodados"
assert_eq 1 "$(grep -c '^plugin eval' "$SP/stub.log")" "evals-comportamento/8 para antes do próximo run"
assert_contains "$out" "total: 3 caso(s) · 1 passou · 0 reprovou · 0 erro de infra · 2 não rodado · US\$ 1.2000 · tokens 4" "evals-comportamento/8 total conta não rodado e mantém o gasto"
assert_contains "$out" "teto US\$ 1.00" "evals-comportamento/8 cabeçalho mostra o teto configurado"

reseta_pe; trace "$TA" 1 1 1 1; trace "$TB" 1 1 1 1
resultado "$SP/pe/a.json" "$(run 1 null 0.4123 "$TA")"; resultado "$SP/pe/b.json" "$(run 1 null 0.1 "$TB")"
roda_evals --caso a --caso b >/dev/null 2>&1
assert_contains "$(grep -- '--case b' "$SP/stub.log")" "--max-cost-usd 9.5877" "evals-comportamento/8 run seguinte recebe teto − gasto"

reseta_pe; resultado "$SP/pe/a.json" "" "" true cost_ceiling; echo 2 > "$SP/pe/rc"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 2 "$code" "evals-comportamento/8 teto do host (cost_ceiling) sai 2"
assert_contains "$out" "NÃO RODADO · a · não rodado: teto" "evals-comportamento/8 cost_ceiling do host vira não rodado"
assert_contains "$out" "NÃO RODADO · c · não rodado: teto" "evals-comportamento/8 cost_ceiling para a rodada"
assert_eq 1 "$(grep -c '^plugin eval' "$SP/stub.log")" "evals-comportamento/8 cost_ceiling não invoca o resto"

reseta_pe; trace "$TA" 1 1 1 1; trace "$TB" 1 1 1 1
resultado "$SP/pe/a.json" "$(run 0 null 0.5 "$TA" "$G_CAT")"; resultado "$SP/pe/b.json" "$(run 1 null 0.6 "$TB")"
out="$(roda_evals --teto 1 2>/dev/null)"; code=$?
assert_eq 2 "$code" "evals-comportamento/8 teto vence reprovação no exit"
assert_contains "$out" "NÃO RODADO · c · não rodado: teto" "evals-comportamento/8 teto atingido pela soma de casos"

reseta_pe; trace "$TA" 1 1 1 1
resultado "$SP/pe/a.json" "$(run 1 '"timed out after 600s"' 1.5 "$TA")"
out="$(roda_evals --teto 1 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/8 erro de infra vence teto no exit"
assert_contains "$out" "NÃO RODADO · b · não rodado: teto" "evals-comportamento/8 teto vale depois de erro de infra"

# --- evals-comportamento/2: modo completo, 3 com e 3 sem ---
# runs <c|s> <score|T>... — runs de custo 0.1 e tokens 10; 0 reprova no grader
# categoria; T = erro de timeout; braço s com a sessão sem plugin
runs() {
  local b="$1" s i=0 r=() t; shift
  for s in "$@"; do
    i=$((i+1)); t="$SP/claude-eval-$b$i/out/trace.jsonl"
    if [ "$b" = s ]; then trace "$t" 1 2 3 4 '[]'; else trace "$t" 1 2 3 4; fi
    case "$s" in
      T) r+=("$(run 1 '"timed out after 600s"' 0.1 "$t")") ;;
      0) r+=("$(run 0.5 null 0.1 "$t" "$G_CAT")") ;;
      *) r+=("$(run 1 null 0.1 "$t")") ;;
    esac
  done
  local IFS=,; printf '%s' "${r[*]}"
}
RZ="$SP/raiz1"
reseta_pe; resultado "$SP/pe/r.json" "$(runs c 1 1 1)" "$(runs s 1 0 0)"
out="$(roda_evals --completo 2>/dev/null)"; code=$?
assert_eq 0 "$code" "evals-comportamento/2 3/3 com o plugin sai 0"
assert_contains "$out" "evals: modo completo · modelo sonnet · teto US\$ 10.00" "evals-comportamento/2 cabeçalho do modo completo"
assert_contains "$out" "PASSOU · porta · com 3/3 · sem 1/3 · Δ +67 pp · US\$ 0.6000 · tokens 60" "evals-comportamento/2 taxa sem o plugin e diferença"
assert_contains "$(grep '^plugin eval' "$SP/stub.log")" "--runs 3 --ablation with-without" "evals-comportamento/2 invoca 3 runs com e sem"

reseta_pe; resultado "$SP/pe/r.json" "$(runs c 1 1 0)" "$(runs s 0 0 0)"
out="$(roda_evals --completo 2>/dev/null)"; code=$?
assert_eq 1 "$code" "evals-comportamento/2 2/3 com o plugin reprova"
assert_contains "$out" "REPROVOU · porta · com 2/3 · sem 0/3 · Δ +67 pp · US\$ 0.6000 · tokens 60 · motivo: categoria: no match" "evals-comportamento/2 reprovado só passa com 3/3"

reseta_pe; resultado "$SP/pe/r.json" "$(runs c 1 1 1)" "$(runs s 1 1 1)"
out="$(roda_evals --completo 2>/dev/null)"
assert_contains "$out" "PASSOU · porta · com 3/3 · sem 3/3 · Δ +0 pp" "evals-comportamento/2 diferença zero com sinal"

# --- porta-anuncio/13: --runs <n> no modo completo ---
reseta_pe; resultado "$SP/pe/r.json" "$(runs c 1 1 1 1 1 1)" "$(runs s 0 0 0 0 0 0)"
out="$(roda_evals --completo --runs 6 2>/dev/null)"; code=$?
assert_eq 0 "$code" "porta-anuncio/13 --completo --runs 6 sai 0"
assert_contains "$(grep '^plugin eval' "$SP/stub.log")" "--runs 6 --ablation with-without" "porta-anuncio/13 invoca 6 runs com e sem"
assert_contains "$out" "PASSOU · porta · com 6/6 · sem 0/6 · Δ +100 pp · US\$ 1.2000 · tokens 120" "porta-anuncio/13 taxa com 6 runs por braço"

# --- porta-anuncio/6: --traces <dir> guarda o trace de cada run antes da limpeza ---
reseta_pe; resultado "$SP/pe/r.json" "$(runs c 1 1 1)" "$(runs s 0 0 0)"
out="$(roda_evals --completo --traces "$SP/trp" 2>/dev/null)"; code=$?
assert_eq 0 "$code" "porta-anuncio/6 --traces sai 0"
assert_eq 3 "$(ls "$SP/trp"/porta-com-*.jsonl 2>/dev/null | wc -l)" "porta-anuncio/6 --traces guarda os 3 traces com o plugin"
assert_eq 3 "$(ls "$SP/trp"/porta-sem-*.jsonl 2>/dev/null | wc -l)" "porta-anuncio/6 --traces guarda os 3 traces sem o plugin"
assert_eq 0 "$(ls -d "$SP"/claude-eval-* 2>/dev/null | wc -l)" "porta-anuncio/6 --traces não impede a limpeza do temporário"
reseta_pe; resultado "$SP/pe/r.json" "$(runs c 1 1 1)" "$(runs s 0 0 0)"
roda_evals --completo >/dev/null 2>&1
assert_no_file "$SP/trp2" "porta-anuncio/6 sem --traces nada é guardado"
assert_eq 0 "$(ls -d "$SP"/claude-eval-* 2>/dev/null | wc -l)" "porta-anuncio/6 sem --traces o temporário é apagado"
: > "$SP/arq"
err="$(roda_evals --traces "$SP/arq/sub" 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "porta-anuncio/6 --traces em caminho impossível sai 4"
assert_contains "$err" "evals: --traces inválido ('$SP/arq/sub')" "porta-anuncio/6 --traces em caminho impossível explica"
err="$(roda_evals --traces 2>&1 >/dev/null)"; code=$?
assert_eq 4 "$code" "porta-anuncio/6 --traces sem valor sai 4"
assert_contains "$err" "evals: --traces sem valor" "porta-anuncio/6 --traces sem valor explica"

reseta_pe; resultado "$SP/pe/r.json" "$(runs c 1 1 1)" "$(runs s 1 T 0)"
out="$(roda_evals --completo 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/2 infra no braço sem sai 3"
assert_contains "$out" "ERRO INFRA · porta · causa: timeout (timed out after 600s) · US\$ 0.6000 · tokens 60" "evals-comportamento/2 infra em qualquer braço vira erro de infra"

reseta_pe; resultado "$SP/pe/r.json" "$(runs c 0 0 1)" "$(runs s 1 1 1)"
out="$(roda_evals --completo 2>/dev/null)"
assert_contains "$out" "com 1/3 · sem 3/3 · Δ -67 pp" "evals-comportamento/2 diferença negativa"

# --- evals-comportamento/7: isolamento conferido no caso plugin-eval ---
RZ="$SP/raiz1"
PL_OUTRO='[{"name":"audora-commander","source":"audora-commander@inline"},{"name":"outro","source":"outro@inline"}]'
PL_BUILTIN='[{"name":"audora-commander","source":"audora-commander@inline"},{"name":"agents-md","source":"agents-md@builtin"},{"name":"telemetry","source":"telemetry@builtin"}]'
reseta_pe; trace "$T1" 1 1 1 1
resultado "$SP/pe/r.json" "$(run 1 null 0.1 "$T1")"
sed -i 's/"plugins":\[{"name":"audora-commander","version":"0.16.0"}\]/"plugins":[{"name":"audora-commander"},{"name":"outro"}]/' "$SP/pe/r.json"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/7 plugin extra no suite sai 3"
assert_contains "$out" "RECUSADO · porta · isolamento: plugins carregados audora-commander,outro" "evals-comportamento/7 recusa plugin extra no suite"
assert_contains "$out" "· 1 erro de infra ·" "evals-comportamento/7 RECUSADO conta como erro de infra"

reseta_pe; trace "$T1" 1 1 1 1 "$PL_OUTRO"
resultado "$SP/pe/r.json" "$(run 1 null 0.1 "$T1")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/7 plugin extra na sessão sai 3"
assert_contains "$out" "RECUSADO · porta · isolamento: plugins na sessão audora-commander,outro" "evals-comportamento/7 recusa plugin extra na sessão"

reseta_pe; trace "$SP/claude-eval-s1/out/trace.jsonl" 1 1 1 1
resultado "$SP/pe/r.json" "$(runs c 1 1 1)" "$(run 1 null 0.1 "$SP/claude-eval-s1/out/trace.jsonl")"
out="$(roda_evals --completo 2>/dev/null)"
assert_contains "$out" "RECUSADO · porta · isolamento: plugins na sessão audora-commander" "evals-comportamento/7 braço sem não pode carregar o plugin"

reseta_pe; trace "$T1" 1 1 1 1 "$PL_BUILTIN"
resultado "$SP/pe/r.json" "$(run 1 null 0.1 "$T1")"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 0 "$code" "evals-comportamento/7 plugins @builtin não recusam"
assert_contains "$out" "PASSOU · porta" "evals-comportamento/7 @builtin aceito"

reseta_pe; resultado "$SP/pe/r.json" "$(run 1 null 0.1 "$SP/sem-trace/out/trace.jsonl")"
out="$(roda_evals 2>/dev/null)"
assert_contains "$out" "RECUSADO · porta · isolamento: sem evento init no trace" "evals-comportamento/7 sem trace não dá para garantir isolamento"

reseta_pe; trace "$T1" 1 1 1 1
resultado "$SP/pe/r.json" "$(run 1 null 0.1 "$T1")"
echo "[ \"\$1\" = plugin ] && echo x > \"$RZ/sujeira.txt\"" > "$SP/cenario.sh"
out="$(roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/7 git status mudou sai 3"
assert_eq "ISOLAMENTO VIOLADO · git status mudou: ?? sujeira.txt" "$(printf '%s\n' "$out" | tail -2 | head -1)" "evals-comportamento/7 git status mudou é a linha antes do total"
rm -f "$RZ/sujeira.txt"
tmpj="$(sed -n 's/.* --json \([^ ]*\) .*/\1/p' "$SP/stub.log")"
case "$tmpj" in "$RZ"/*) ko "evals-comportamento/7 --json dentro da raiz: $tmpj" ;; *) ok ;; esac
case "$(sed -n 's/.* --output-dir \([^ ]*\).*/\1/p' "$SP/stub.log")" in "$RZ"/*) ko "evals-comportamento/7 --output-dir dentro da raiz" ;; *) ok ;; esac

reseta_pe; mkdir -p "$SP/sem-git/tests/evals/porta"; echo p > "$SP/sem-git/tests/evals/porta/prompt.md"
out="$(RZ="$SP/sem-git"; roda_evals 2>/dev/null)"; code=$?
assert_eq 3 "$code" "evals-comportamento/7 raiz fora de repo git sai 3"
assert_contains "$out" "RECUSADO · porta · isolamento: raiz fora de um repo git (sem como conferir o git status)" "evals-comportamento/7 recusa raiz sem git"
assert_eq 0 "$(grep -c '^plugin eval' "$SP/stub.log")" "evals-comportamento/7 recusado não invoca"


assert_no_file "$SP/chamou-claude" "evals-comportamento/12 nenhum claude real chamado pelo test-evals.sh"
report
