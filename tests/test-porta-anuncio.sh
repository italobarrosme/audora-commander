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

report
