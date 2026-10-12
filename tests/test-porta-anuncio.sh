#!/usr/bin/env bash
# porta-anuncio — a porta anuncia categoria, porquê e convite antes do 1º
# registro, e o eval porta prova (grader categoria, calibração).
source "$(dirname "$0")/lib.sh"
. "$ROOT/tests/evals-lib.sh"
. "$ROOT/tests/evals-testlib.sh"
cd "$ROOT" || exit 1
# flat <arquivo> [cabeçalho] → texto (da seção, se dado) sem \r, numa linha só,
# espaços colapsados: frase que quebra linha no Markdown ainda casa.
flat() {
  if [ -n "${2:-}" ]; then
    tr -d '\r' 2>/dev/null < "$1" | awk -v h="$2" '$0==h{f=1;next} /^## /{f=0} f'
  else
    tr -d '\r' 2>/dev/null < "$1"
  fi | tr '\n' ' ' | tr -s ' '
}

# --- /1 — passo 4 da porta é regra dura e cabe inteiro na mutação ---
P=skills/audora-commander/SKILL.md
fl="$(flat "$P" '## Fluxo')"
for s in 'Demanda classificada como <CATEGORIA> porque <respostas às perguntas de risco> — me corrija se discordar.' \
         'ANTES do passo 5' 'frase própria' 'o bloco de fechamento não substitui'; do
  assert_contains "$fl" "$s" "porta-anuncio/1"
done
for s in '[X]' '[respostas às perguntas]'; do
  assert_not_contains "$fl" "$s" "porta-anuncio/1 sem o modelo antigo"
done
resto="${fl#*5. \*\*Registrar o nó\*\*}"
assert_not_contains "$resto" '4. **Anunciar**:' "porta-anuncio/1 passo 4 antes do passo 5"
assert_contains "$fl" '5. **Registrar o nó**' "porta-anuncio/1 passo 5 existe"
assert_eq 1 "$(grep -cF '4. **Anunciar**:' "$P")" "porta-anuncio/1 âncora da mutação única"
cp "$P" "$SP/porta.md"
aplica_mutacao "$SP/porta.md" '4. **Anunciar**:' 'Correção do humano vale na hora.' >/dev/null
mu="$(flat "$SP/porta.md")"
for s in 'classificada como' 'me corrija' 'frase própria' 'ANTES do passo 5'; do
  assert_not_contains "$mu" "$s" "porta-anuncio/1 a mutação corta a regra inteira"
done

# --- /2 /3 — grader categoria: anúncio do assistente, antes do 1º registro ---
GC="$EV/porta/graders/categoria.md"
for k in 'type: regex' 'arm: both' 'target: trace' 'flags: i'; do
  assert_contains "$(cat "$GC" 2>/dev/null)" "$k" "porta-anuncio/2 categoria.md mantém $k"
done
ev_text() { printf '{"type":"assistant","message":{"content":[{"type":"text","text":"%s"}]}}\n' "$1"; }
# formato real (spike T2): o corpo da skill chega em evento user
ev_meta() { printf '{"type":"user","message":{"role":"user","content":[{"type":"text","text":"%s"}]},"isMeta":true}\n' "$1"; }
# ga <esperado> <descrição> — emula o categoria sobre $SP/em.jsonl
ga() { assert_eq "$1" "$(emula_grader "$GC" "$SP/em.jsonl" "$SP/emws")" "porta-anuncio/2,3 categoria: $2"; }
mkdir -p "$SP/emws"
A='Demanda classificada como **MEDIUM** porque nenhuma pergunta de risco deu SIM e há lógica nova — me corrija se discordar.'
WN="$(jesc 'C:\w\docs\audora\memory\media.md')"; WM="$(jesc 'C:\w\MEMORY.md')"
ev_text "$A" > "$SP/em.jsonl"; ga passou "anúncio completo"
ev_text 'Classificada como MEDIUM porque toca vários arquivos; me corrija' > "$SP/em.jsonl"; ga passou "sem negrito, maiúscula"
ev_text 'classificada como **MEDIUM** porque \"x\" e\\nlinha — me corrija' > "$SP/em.jsonl"; ga passou "escapes JSON no meio"
ev_text 'Demanda classificada como **MEDIUM**.' > "$SP/em.jsonl"; ga reprovou "sem porque nem convite"
ev_text 'classificada como MEDIUM porque x' > "$SP/em.jsonl"; ga reprovou "sem me corrija"
ev_text 'Classificada como MEDIUM — me corrija' > "$SP/em.jsonl"; ga reprovou "sem porque"
{ ev_text 'classificada como MEDIUM porque x'; ev_text 'me corrija'; } > "$SP/em.jsonl"; ga reprovou "partes em blocos separados"
ev_text "${A/MEDIUM/LIGHT}" > "$SP/em.jsonl"; ga reprovou "LIGHT"
ev_text "${A/MEDIUM/HIGH}" > "$SP/em.jsonl"; ga reprovou "HIGH"
ev_text 'não seria MEDIUM' > "$SP/em.jsonl"; ga reprovou "MEDIUM sem o anúncio"
: > "$SP/em.jsonl"; ga reprovou "trace vazio"
ev_meta 'Demanda classificada como [X] porque [respostas às perguntas] — me corrija se discordar.' > "$SP/em.jsonl"; ga reprovou "modelo [X] só na skill carregada"
ev_meta "$A" > "$SP/em.jsonl"; ga reprovou "anúncio só em evento user"
ev_tool w Write "{\"file_path\":\"/w/docs/audora/memory/media.md\",\"content\":\"$A\"}" > "$SP/em.jsonl"; ga reprovou "anúncio só no conteúdo do Write"
ev_tool s Skill "{\"skill\":\"audora-commander:scope\",\"args\":\"$A\"}" > "$SP/em.jsonl"; ga reprovou "anúncio só nos args do Skill"
{ ev_tool w Write "{\"file_path\":\"$WN\",\"content\":\"x\"}"; ev_text "$A"; } > "$SP/em.jsonl"; ga reprovou "Write no nó antes"
{ ev_tool w Edit "{\"file_path\":\"$WM\",\"old_string\":\"a\",\"new_string\":\"b\"}"; ev_text "$A"; } > "$SP/em.jsonl"; ga reprovou "Edit no MEMORY antes"
{ ev_tool w Edit '{"file_path":"/w/MEMORY.md","old_string":"a","new_string":"b"}'; ev_text "$A"; } > "$SP/em.jsonl"; ga reprovou "Edit no MEMORY (posix) antes"
# formato real (spike T2): o Edit traz replace_all antes de file_path
{ ev_tool w Edit "{\"replace_all\":false,\"file_path\":\"$WM\",\"old_string\":\"a {b} \\\"c\\\"\",\"new_string\":\"d\"}"; ev_text "$A"; } > "$SP/em.jsonl"; ga reprovou "Edit com replace_all antes de file_path no MEMORY antes"
{ ev_tool r Read "{\"file_path\":\"$WM\"}"; ev_text "$A"; ev_tool w Write "{\"file_path\":\"$WM\",\"content\":\"x\"}"; } > "$SP/em.jsonl"; ga passou "Read antes, Write depois"
{ ev_tool w Write "{\"file_path\":\"$(jesc 'C:\w\docs\audora\aprendizados.md')\",\"content\":\"x\"}"; ev_text "$A"; } > "$SP/em.jsonl"; ga passou "Write fora do MEMORY e do nó antes"
printf '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"w","name":"Write","input":{"file_path":"/w/MEMORY.md","content":"x"}},{"type":"text","text":"%s"}]}}\n' "$A" > "$SP/em.jsonl"; ga reprovou "Write antes no mesmo evento"
printf '{"type":"assistant","message":{"content":[{"type":"text","text":"%s"},{"type":"tool_use","id":"w","name":"Write","input":{"file_path":"/w/MEMORY.md","content":"x"}}]}}\n' "$A" > "$SP/em.jsonl"; ga passou "texto antes no mesmo evento"
{ for i in $(seq 3000); do ev_tool "r$i" Read '{"file_path":"/w/lib.sh"}'; ev_result "r$i" false; done; ev_text "$A"; } > "$SP/em.jsonl"; ga passou "trace grande"

# --- /7–/11 — hook anuncio-guard ---
# linhas do transcript real do Claude Code (parentUuid antes de type)
js() { T="$1" perl -MJSON::PP -e 'print JSON::PP->new->allow_nonref->encode($ENV{T})'; }
tr_user() { printf '{"parentUuid":"p","type":"user","message":{"role":"user","content":%s}}\n' "$(js "$1")"; }
tr_meta() { printf '{"parentUuid":"p","type":"user","message":{"role":"user","content":[{"type":"text","text":%s}]},"isMeta":true}\n' "$(js "$1")"; }
tr_result() { printf '{"parentUuid":"p","type":"user","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"t","content":"x"}]}}\n'; }
tr_text() { printf '{"parentUuid":"p","type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":%s}]}}\n' "$(js "$1")"; }
tr_thinking() { printf '{"parentUuid":"p","type":"assistant","message":{"role":"assistant","content":[{"type":"thinking","thinking":%s,"signature":"s"}]}}\n' "$(js "$1")"; }
tr_tool() { printf '{"parentUuid":"p","type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"t","name":"%s","input":{"args":%s}}]}}\n' "$1" "$(js "$2")"; }
# pre <transcript> <file_path> <conteúdo> [tool] → code e out (stderr)
pre() {
  out="$(TP="$1" FP="$2" CT="$3" TN="${4:-Write}" perl -MJSON::PP -e 'print JSON::PP->new->encode({tool_name => $ENV{TN}, tool_input => {file_path => $ENV{FP}, content => $ENV{CT}}, transcript_path => $ENV{TP}})' | bash "$ROOT/hooks/anuncio-guard" 2>&1 >/dev/null)"; code=$?
}
PJ="$SP/pj"; mkdir -p "$PJ/docs/audora/memory"; printf 'memory-schema: 1\n# MEMORY\n' > "$PJ/MEMORY.md"
N="$PJ/docs/audora/memory/novo.md"; T="$SP/tr.jsonl"
CI=$'---\nid: novo\nestado: in-progress\n---\n'
MSG='anuncio-guard: antes de registrar o nó, escreva ao humano, em texto (não no raciocínio), o anúncio da porta: "Demanda classificada como <CATEGORIA> porque <respostas às perguntas de risco> — me corrija se discordar." Depois repita esta escrita.'
SEM="$(tr_user 'Quero media'; tr_text 'Usando audora-commander para classificar.')"
printf '%s\n' "$SEM" > "$T"
pre "$T" "$N" "$CI";                         assert_eq 2 "$code" "porta-anuncio/7 nó novo in-progress sem anúncio → 2"; assert_eq "$MSG" "$out" "porta-anuncio/7 mensagem"
pre "$T" "$N" "${CI/in-progress/hotfix-pending-record}"; assert_eq 2 "$code" "porta-anuncio/7 hotfix-pending-record → 2"
pre "$T" "$(cygpath -w "$N")" "$CI";         assert_eq 2 "$code" "porta-anuncio/7 caminho Windows → 2"
pre "$T" "$N" "${CI//$'\n'/$'\r\n'}";        assert_eq 2 "$code" "porta-anuncio/7 conteúdo CRLF → 2"
{ tr_user 'Quero media'; tr_text 'Demanda classificada como MEDIUM.'; } > "$T"
pre "$T" "$N" "$CI";                         assert_eq 2 "$code" "porta-anuncio/7 só a categoria → 2"
# /8 — anúncio completo em texto do assistente desde a última mensagem do humano
{ tr_user 'Quero media'; tr_text "$A"; } > "$T"
pre "$T" "$N" "$CI";                         assert_eq 0 "$code" "porta-anuncio/8 anúncio → 0"; assert_empty "$out" "porta-anuncio/8 calado"
pre "$(cygpath -w "$T")" "$(cygpath -w "$N")" "$CI"; assert_eq 0 "$code" "porta-anuncio/8 transcript e nó em caminho Windows → 0"
{ tr_user 'Quero media'; tr_text "${A/MEDIUM/LIGHT}"; } > "$T"; pre "$T" "$N" "$CI"; assert_eq 0 "$code" "porta-anuncio/8 LIGHT → 0"
{ tr_user 'Quero media'; tr_text "${A/MEDIUM/HOTFIX}"; } > "$T"; pre "$T" "$N" "$CI"; assert_eq 0 "$code" "porta-anuncio/8 HOTFIX → 0"
{ tr_user 'Quero media'; tr_text "$A"; tr_tool Read x; tr_result; tr_meta 'Base directory for this skill: x'; } > "$T"
pre "$T" "$N" "$CI";                         assert_eq 0 "$code" "porta-anuncio/8 tool_result e skill não fecham a janela → 0"
# /9 — fora do alvo passa calado (transcript sem anúncio)
printf '%s\n' "$SEM" > "$T"
pre "$T" "$N" "$CI" Edit;                    assert_eq 0 "$code" "porta-anuncio/9 Edit → 0"; assert_empty "$out" "porta-anuncio/9 Edit calado"
printf 'x\n' > "$N"; pre "$T" "$N" "$CI";   assert_eq 0 "$code" "porta-anuncio/9 nó já existe → 0"; assert_empty "$out" "porta-anuncio/9 existente calado"; rm -f "$N"
pre "$T" "$N" "${CI/in-progress/planned}";   assert_eq 0 "$code" "porta-anuncio/9 estado planned → 0"; assert_empty "$out" "porta-anuncio/9 planned calado"
pre "$T" "$PJ/docs/outro.md" "$CI";          assert_eq 0 "$code" "porta-anuncio/9 fora de docs/audora/memory → 0"; assert_empty "$out" "porta-anuncio/9 fora calado"
P2="$SP/p2"; mkdir -p "$P2/docs/audora/memory"; printf '# MEMORY de outra ferramenta\nmemory-schema: 1\n' > "$P2/MEMORY.md"
pre "$T" "$P2/docs/audora/memory/novo.md" "$CI"; assert_eq 0 "$code" "porta-anuncio/9 sem schema na 1ª linha → 0"; assert_empty "$out" "porta-anuncio/9 sem schema calado"
P3="$SP/p3"; mkdir -p "$P3/docs/audora/memory"
pre "$T" "$P3/docs/audora/memory/novo.md" "$CI"; assert_eq 0 "$code" "porta-anuncio/9 sem MEMORY.md → 0"; assert_empty "$out" "porta-anuncio/9 sem MEMORY calado"
# /10 — anúncio fora de texto do assistente, ou antes da última mensagem do humano
{ tr_user 'Quero media'; tr_thinking "$A"; } > "$T"; pre "$T" "$N" "$CI"; assert_eq 2 "$code" "porta-anuncio/10 só no raciocínio → 2"
{ tr_user 'Quero media'; tr_tool Skill "$A"; } > "$T"; pre "$T" "$N" "$CI"; assert_eq 2 "$code" "porta-anuncio/10 só em input de ferramenta → 2"
{ tr_user 'Quero media'; tr_meta "$A"; } > "$T"; pre "$T" "$N" "$CI"; assert_eq 2 "$code" "porta-anuncio/10 só na skill carregada → 2"
{ tr_user 'demanda 1'; tr_text "$A"; tr_user 'demanda 2'; } > "$T"; pre "$T" "$N" "$CI"; assert_eq 2 "$code" "porta-anuncio/10 antes da última mensagem do humano → 2"
tr_user "$A" > "$T"; pre "$T" "$N" "$CI";   assert_eq 2 "$code" "porta-anuncio/10 frase escrita pelo humano → 2"
# /11 — transcript ausente/ilegível ou falha do hook deixa passar
pre "$SP/nao-existe.jsonl" "$N" "$CI";       assert_eq 0 "$code" "porta-anuncio/11 transcript inexistente → 0"; assert_empty "$out" "porta-anuncio/11 inexistente calado"
out="$(printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":"estado: in-progress"}}' "$N" | bash "$ROOT/hooks/anuncio-guard" 2>&1 >/dev/null)"; code=$?
assert_eq 0 "$code" "porta-anuncio/11 sem transcript_path → 0"; assert_empty "$out" "porta-anuncio/11 sem transcript_path calado"
pre "$PJ" "$N" "$CI";                        assert_eq 0 "$code" "porta-anuncio/11 transcript é diretório → 0"; assert_empty "$out" "porta-anuncio/11 diretório calado"
out="$(printf 'não é json' | bash "$ROOT/hooks/anuncio-guard" 2>&1 >/dev/null)"; code=$?
assert_eq 0 "$code" "porta-anuncio/11 stdin não JSON → 0"; assert_empty "$out" "porta-anuncio/11 stdin calado"
{ echo 'lixo {'; tr_user 'Quero media'; echo '{"type":'; tr_text "$A"; echo 'mais lixo'; } > "$T"
pre "$T" "$N" "$CI";                         assert_eq 0 "$code" "porta-anuncio/11 linhas não JSON puladas → 0"
printf 'lixo {\nmais lixo\n' > "$T"; pre "$T" "$N" "$CI"; assert_eq 0 "$code" "porta-anuncio/11 transcript só com lixo → 0"; assert_empty "$out" "porta-anuncio/11 lixo calado"
: > "$T"; pre "$T" "$N" "$CI";               assert_eq 0 "$code" "porta-anuncio/11 transcript vazio → 0"
# escala: transcript longo sem anúncio
{ tr_user 'Quero media'; perl -e 'for (1..10000) { print qq({"parentUuid":"p","type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"t$_","name":"Read","input":{"file_path":"/w/lib.sh"}}]}}\n{"parentUuid":"p","type":"user","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"t$_","content":"x"}]}}\n) }'; } > "$T"
SECONDS=0; pre "$T" "$N" "$CI"; dur=$SECONDS
assert_eq 2 "$code" "porta-anuncio/7 transcript de 20001 linhas sem anúncio → 2"
[ "$dur" -lt 10 ] && ok || ko "porta-anuncio/7 transcript de 20001 linhas em ${dur}s (teto 10)"

report
