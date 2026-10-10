#!/usr/bin/env bash
# Graders, fixtures e casos dos evals de comportamento — sem chamar o
# orquestrador (esse tem arquivo próprio); tudo offline (evals-comportamento/12).
source "$(dirname "$0")/lib.sh"
. "$ROOT/tests/evals-lib.sh"
. "$ROOT/tests/evals-testlib.sh"

# --- evals-comportamento/6: grader do tdd pela ordem no transcript ---
# tdd_caso <esperado> <passo>... — roda o grader sobre o fluxo
tdd_caso() {
  local esp="$1"; shift
  fluxo "$SP/tdd.jsonl" "$@"
  assert_eq "$esp" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 [$*]"
}
tdd_caso "passou" $TT B- $LB B+
tdd_caso "reprovou: código editado antes do teste falhando" $LB $TT B+
tdd_caso "reprovou: código editado antes do teste falhando" $TT $LB B- B+
tdd_caso "reprovou: faltou teste passando depois do código" $TT B- $LB
tdd_caso "reprovou: faltou teste novo"
tdd_caso "reprovou: faltou código editado depois do teste falhando" $TT B-
tdd_caso "reprovou: faltou teste falhando depois do teste novo" $TT B+ $LB B+
tdd_caso "passou" E:/ws/cwd/docs/audora/memory/dobro.md E:/ws/cwd/MEMORY.md $TT B- $LB B+
tdd_caso "passou" B- $TT B- $LB B+
tdd_caso "passou" 'W:C:\x\cwd\tests\test-dobro.sh' B- 'E:C:\x\cwd\lib.sh' B+
tdd_caso "reprovou: faltou teste novo" $LB B- B+
tdd_caso "passou" $TT B- $LB B- E:/ws/cwd/lib.sh B+
# teste rodado é Bash que cita tests/; outro Bash falhando não conta
fluxo "$SP/tdd.jsonl" $TT; ev_tool x1 Bash '{"command":"ls"}' >> "$SP/tdd.jsonl"; ev_result x1 true >> "$SP/tdd.jsonl"
ev_tool x2 Edit '{"file_path":"/ws/cwd/lib.sh"}' >> "$SP/tdd.jsonl"
assert_eq "reprovou: faltou teste falhando depois do teste novo" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 Bash sem tests/ não é teste rodado"
# vários tool_use no mesmo evento, Windows com tests\ no comando
printf '%s\n' '{"type":"assistant","message":{"content":[{"type":"text","text":"x"},{"type":"tool_use","id":"a","name":"Write","input":{"file_path":"C:\\w\\tests\\test-x.sh"}},{"type":"tool_use","id":"b","name":"Bash","input":{"command":"bash tests\\run.sh"}}]}}' \
  '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"a","is_error":false},{"type":"tool_result","tool_use_id":"b","is_error":true}]}}' > "$SP/tdd.jsonl"
ev_tool c Edit '{"file_path":"C:\\w\\lib.sh"}' >> "$SP/tdd.jsonl"; ev_tool d Bash '{"command":"bash tests/run.sh"}' >> "$SP/tdd.jsonl"; ev_result d false >> "$SP/tdd.jsonl"
assert_eq "passou" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 vários tool_use num evento"
assert_eq "reprovou: faltou teste novo" "$(grader_tdd "$SP/nao-existe.jsonl")" "evals-comportamento/6 stream ausente reprova"
# rodada real 2026-10-10: `bash tests/run.sh; echo "exit=$?"` sai 0 com a suíte falhando,
# e `git add tests/...` não é teste rodado
RUN_ECHO='{"command":"bash tests/run.sh; echo \"exit=$?\""}'
{ ev_tool a Write '{"file_path":"/w/tests/test-dobro.sh"}'; ev_saida a false ok
  ev_tool b Bash "$RUN_ECHO"; ev_saida b false 'FALHOU: tests/test-dobro.sh\nok: tests/test-soma.sh\n1 teste(s) falhando\nexit=1'
  ev_tool c Edit '{"file_path":"/w/lib.sh"}'; ev_saida c false ok
  ev_tool d Bash "$RUN_ECHO"; ev_saida d false 'ok: tests/test-dobro.sh\n0 teste(s) falhando\nexit=0'
  ev_tool e Bash '{"command":"git add lib.sh tests/test-dobro.sh && git commit -qm x"}'; ev_saida e true 'Author identity unknown'
} > "$SP/tdd.jsonl"
assert_eq "passou" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 falha lida na saída (; echo) e git add não é teste rodado"
{ ev_tool a Write '{"file_path":"/w/tests/test-dobro.sh"}'
  ev_tool b Bash "$RUN_ECHO"; ev_saida b false '0 teste(s) falhando\nexit=0'
  ev_tool c Edit '{"file_path":"/w/lib.sh"}'
  ev_tool d Bash "$RUN_ECHO"; ev_saida d false '0 teste(s) falhando\nexit=0'
} > "$SP/tdd.jsonl"
assert_eq "reprovou: faltou teste falhando depois do teste novo" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 suíte verde na saída não é RED"
{ ev_tool a Write '{"file_path":"/w/tests/test-dobro.sh"}'
  ev_tool b Bash '{"command":"bash tests/test-dobro.sh; echo exit=$?"}'; ev_saida b false 'dobro: command not found\nexit=127'
  ev_tool c Edit '{"file_path":"/w/lib.sh"}'
  ev_tool d Bash '{"command":"./tests/run.sh"}'; ev_saida d false '0 teste(s) falhando'
} > "$SP/tdd.jsonl"
assert_eq "passou" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 teste isolado com exit≠0 na saída e ./tests/ rodado"
printf '%s\n' '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"b","is_error":false,"content":[{"type":"text","text":"1 teste(s) falhando"}]}]}}' > "$SP/tdd-c.jsonl"
{ ev_tool a Write '{"file_path":"/w/tests/t.sh"}'; ev_tool b Bash '{"command":"bash tests/run.sh"}'; cat "$SP/tdd-c.jsonl"
  ev_tool c Edit '{"file_path":"/w/lib.sh"}'; ev_tool d Bash '{"command":"bash tests/run.sh"}'; ev_saida d false '0 teste(s) falhando'
} > "$SP/tdd.jsonl"
assert_eq "passou" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 conteúdo do tool_result em blocos de texto"
# rodada real 2026-10-10: com Bash livre o modelo escreve teste e código por heredoc,
# e roda a suíte no mesmo comando
H_TESTE=$'cat > tests/test-dobro.sh <<\'EOF\'\n#!/usr/bin/env bash\n[ "$(dobro 4)" = 8 ] || { echo falhou >&2; exit 1; }\nEOF\nbash tests/run.sh'
H_COD=$'cat >> lib.sh <<\'EOF\'\ndobro() { echo $(( $1 * 2 )) > /dev/stdout; echo x > tests/nao-conta; }\nEOF\nbash tests/run.sh 2>&1'
{ ev_bash a "$H_TESTE"; ev_saida a true '1 teste(s) falhando'; ev_bash b "$H_COD"; ev_saida b false '0 teste(s) falhando'; } > "$SP/tdd.jsonl"
assert_eq "passou" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 teste e código por heredoc no Bash, com run no mesmo comando"
{ ev_bash a "$H_COD"; ev_saida a false '0 teste(s) falhando'; ev_bash b "$H_TESTE"; ev_saida b true '1 teste(s) falhando'
  ev_bash c "$H_COD"; ev_saida c false '0 teste(s) falhando'; } > "$SP/tdd.jsonl"
assert_eq "reprovou: código editado antes do teste falhando" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 código por heredoc antes do teste reprova"
{ ev_bash a $'echo "[ 1 = 2 ]" | tee tests/test-x.sh >/dev/null && bash tests/run.sh'; ev_saida a true '1 teste(s) falhando'
  ev_bash b $'printf "x() { :; }\\n" >> lib.sh; bash tests/run.sh'; ev_saida b false '0 teste(s) falhando'; } > "$SP/tdd.jsonl"
assert_eq "passou" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 tee em tests/ e >> em código"
{ ev_bash a $'cat > tests/test-dobro.sh <<EOF\nx\nEOF'; ev_saida a false ''; ev_bash b 'bash tests/run.sh > saida.log 2>&1; echo "exit=$?"'; ev_saida b false 'exit=1'
  ev_tool c Edit '{"file_path":"/w/lib.sh"}'; ev_bash d 'bash tests/run.sh'; ev_saida d false '0 teste(s) falhando'; } > "$SP/tdd.jsonl"
assert_eq "passou" "$(grader_tdd "$SP/tdd.jsonl")" "evals-comportamento/6 log redirecionado (saida.log) depois do run não conta como código antes"

# --- fixtures: projeto-base e caso tdd (evals-comportamento/6,7) ---
F="$SP/fx-base"
na_fixture "$F" "$EV/_lib/projeto-base.sh"
assert_eq "memory-schema: 1" "$(head -1 "$F/MEMORY.md" 2>/dev/null | tr -d '\r')" "fixture base: MEMORY.md com schema na linha 1"
for sec in 'Propósito' 'Constituição' 'Aprendizados' 'Índice de nós'; do
  assert_contains "$(grep "^## " "$F/MEMORY.md" 2>/dev/null)" "## $sec" "fixture base: seção $sec"
done
const="$(sed -n '/^## Constituição/,/^## Aprendizados/p' "$F/MEMORY.md" 2>/dev/null)"
assert_contains "$const" "- **stack**: bash" "fixture base: stack bash"
assert_contains "$const" '- **como-rodar**: `bash tests/run.sh`' "fixture base: como-rodar"
assert_contains "$const" "- **gate**: recusado" "fixture base: gate recusado (porta não desvia oferecendo gate)"
assert_eq "$(cat "$ROOT/templates/aprendizados-template.md")" "$(cat "$F/docs/audora/aprendizados.md" 2>/dev/null)" "fixture base: aprendizados.md = template"
assert_contains "$(cat "$F/lib.sh" 2>/dev/null)" "soma()" "fixture base: lib.sh com soma"
assert_file "$F/tests/test-soma.sh" "fixture base: teste da soma"
( cd "$F" && bash tests/run.sh ) >/dev/null 2>&1; assert_eq 0 "$?" "fixture base: suíte da fixture passa"
run_hook memory-validate "$F/MEMORY.md"; assert_eq 0 "$code" "fixture base: memory-validate aceita o MEMORY ($out)"
assert_no_file "$F/.git" "fixture base: não commita (o caso commita)"
printf '#!/usr/bin/env bash\nfalse\n' > "$F/tests/test-falha.sh"
( cd "$F" && bash tests/run.sh ) >/dev/null 2>&1; assert_eq 1 "$?" "fixture base: run.sh sai 1 se algum teste falha"

F="$SP/fx-tdd"
na_fixture "$F" "$EV/tdd/fixture.sh"
assert_eq "estado: in-progress" "$(grep '^estado:' "$F/docs/audora/memory/dobro.md" 2>/dev/null | tr -d '\r')" "fixture tdd: nó dobro in-progress"
no="$(tr '\n' ' ' < "$F/docs/audora/memory/dobro.md" 2>/dev/null | tr -s ' ')"
assert_contains "$no" '**dobro/1** — QUANDO `dobro 4` é chamado O SISTEMA DEVE imprimir 8' "fixture tdd: critério dobro/1"
assert_contains "$no" '**dobro/2** — QUANDO o argumento não é numérico O SISTEMA DEVE imprimir "erro: não numérico" no stderr e sair 1' "fixture tdd: critério dobro/2"
assert_contains "$(grep '^- dobro | in-progress |' "$F/MEMORY.md" 2>/dev/null)" "dobro" "fixture tdd: linha do nó no índice"
run_hook memory-validate "$F/MEMORY.md"; assert_eq 0 "$code" "fixture tdd: memory-validate aceita ($out)"
assert_eq 0 "$(grep -c dobro "$F/lib.sh" 2>/dev/null)" "fixture tdd: dobro ainda não existe na lib"
( cd "$F" && bash tests/run.sh ) >/dev/null 2>&1; assert_eq 0 "$?" "fixture tdd: suíte passa antes da demanda"
assert_eq 1 "$(git -C "$F" log --oneline 2>/dev/null | wc -l | tr -d ' ')" "fixture tdd: 1 commit"
assert_empty "$(git -C "$F" status --porcelain 2>&1)" "fixture tdd: árvore limpa depois do commit"
assert_eq "execute de dobro" "$(tr -d '\r' < "$EV/tdd/harness.md" 2>/dev/null)" "fixture tdd: harness.md é o prompt"
assert_eq "$(printf 'tdd\tharness')" "$(lista_casos "$ROOT" | grep '^tdd')" "fixture tdd: tdd é caso harness"

# --- emulador offline dos graders nativos (base de evals-comportamento/3,4,5) ---
# gr <arquivo> <linha-de-frontmatter>... — grader .md
gr() { local f="$1"; shift; mkdir -p "$(dirname "$f")"; { echo ---; printf '%s\n' "$@"; echo ---; } > "$f"; }
# emula <esperado> <descrição> — roda o emulador com $G, $SP/em.jsonl e $SP/emws
emula() { assert_eq "$1" "$(emula_grader "$G" "$SP/em.jsonl" "$SP/emws")" "emulador: $2"; }
rm -rf "$SP/emws"; mkdir -p "$SP/emws"; : > "$SP/em.jsonl"; G="$SP/gr/g.md"
gr "$G" "type: regex" "pattern: banana" "target: { source: file, path: saida.txt }"
emula reprovou "regex em arquivo ausente reprova"
echo banana > "$SP/emws/saida.txt"; emula passou "regex em arquivo"
gr "$G" "type: regex" "pattern: banana" "target: { source: file, path: saida.txt }" "match: not_contains"
emula reprovou "not_contains inverte"
printf 'x\n- 2026-01-01 | y\n' > "$SP/emws/m.md"
gr "$G" "type: regex" "pattern: '^- \\d{4}'" "target: { source: file, path: m.md }"
emula reprovou "sem flag m, ^ só casa no início"
gr "$G" "type: regex" "pattern: '^- \\d{4}'" "flags: m" "target: { source: file, path: m.md }"
emula passou "flag m faz ^ casar no meio"
gr "$G" "type: regex" "pattern: BANANA" "flags: i" "target: { source: file, path: saida.txt }"
emula passou "flag i"
gr "$G" "type: regex" "pattern: 'a''b'" "target: { source: file, path: saida.txt }"
emula reprovou "aspas simples YAML com '' escapado"
ev_tool t1 Write '{"file_path":"C:\\w\\a\\x.md","content":"oi"}' > "$SP/em.jsonl"
gr "$G" "type: regex" "pattern: 'a\\\\\\\\x\\.md'" "target: trace"
emula passou "regex no trace vê o JSON escapado"
gr "$G" "type: tool_used" "tool: Write" "input_match: 'x\\.md'" "min: 0" "max: 0"
emula reprovou "tool_used max 0 com chamada que casa"
: > "$SP/em.jsonl"; emula passou "tool_used max 0 sem chamada"
gr "$G" "type: tool_used" "tool: Write"
emula reprovou "tool_used min padrão 1"
ev_tool t1 Write '{"file_path":"/w/b.sh"}' > "$SP/em.jsonl"; emula passou "tool_used sem input_match"
gr "$G" "type: tool_used" "tool: Write" "input_match: '\"file_path\":\"/w/b'"
emula passou "input_match vê o input como no trace"
gr "$G" "type: tool_used" "tool: Write" "min: 2"
emula reprovou "tool_used abaixo do min"
gr "$G" "type: tool_order" "before: { tool: Skill, input_match: 'a' }" "after: { tool: Skill, input_match: 'b' }"
{ ev_tool s1 Skill '{"skill":"a"}'; ev_tool s2 Skill '{"skill":"b"}'; } > "$SP/em.jsonl"; emula passou "tool_order [a,b]"
{ ev_tool s1 Skill '{"skill":"b"}'; ev_tool s2 Skill '{"skill":"a"}'; } > "$SP/em.jsonl"; emula reprovou "tool_order [b,a]"
ev_tool s1 Skill '{"skill":"a"}' > "$SP/em.jsonl"; emula reprovou "tool_order só [a]"
gr "$G" "type: tool_order" "before: Read" "after: Skill"
{ ev_tool r Read '{"file_path":"x"}'; ev_tool s Skill '{"skill":"a"}'; } > "$SP/em.jsonl"; emula passou "tool_order por nome"
printf '%s\n' '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"a","name":"Skill","input":{"skill":"b"}},{"type":"tool_use","id":"b","name":"Read","input":{"x":{"y":1}}}]}}' > "$SP/em.jsonl"
gr "$G" "type: tool_used" "tool: Read" "input_match: '\\{\"y\":1\\}'"
emula passou "vários tool_use no evento e input aninhado"
gr "$G" "type: llm"; emula "erro: tipo não emulado: llm" "tipo llm é erro"
gr "$G" "type: regex" "pattern: x" "focus: trace"; emula "erro: chave desconhecida: focus" "chave desconhecida é erro"
gr "$G" "type: regex" "pattern: x" "target: last_message"; emula "erro: alvo não emulado: last_message" "alvo não emulado é erro"
gr "$G" "type: tool_used" "tool: Write" "arm: both" "weight: 2"; : > "$SP/em.jsonl"
emula reprovou "arm e weight aceitos"

# --- evals-comportamento/3: caso porta ---
ev_text() { printf '{"type":"assistant","message":{"content":[{"type":"text","text":"%s"}]}}\n' "$1"; }
# skills <arquivo> <skill>... — trace com uma chamada Skill por nome, em ordem
skills() { local f="$1" s n=0; shift; : > "$f"; for s in "$@"; do n=$((n+1)); ev_tool "k$n" Skill "{\"skill\":\"$s\",\"args\":\"x\"}" >> "$f"; done; }
CP="$EV/porta"
# gp <grader> <esperado> <descrição> — emula um grader do caso porta sobre $SP/em.jsonl
gp() { assert_eq "$2" "$(emula_grader "$CP/graders/$1.md" "$SP/em.jsonl" "$SP/emws")" "evals-comportamento/3 $1: $3"; }
assert_contains "$(tr -d '\r' < "$CP/prompt.md" 2>/dev/null | tr '\n' ' ')" "Quero acrescentar à lib as funções media e mediana sobre os números passados como argumento, com erro claro para lista vazia ou valor não numérico, e um comando bin/estat que expõe as duas. Com testes." "evals-comportamento/3 prompt do caso porta"
for k in 'max_turns: 40' 'timeout_seconds: 600' 'tags: [comportamento]' 'allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, AskUserQuestion, TodoWrite]'; do
  assert_contains "$(cat "$CP/prompt.md" 2>/dev/null)" "$k" "evals-comportamento/3 frontmatter $k"
done
for k in 'schema_version: "1.1"' 'name: porta' 'scaffold_script: fixture.sh'; do
  assert_contains "$(cat "$CP/case.yaml" 2>/dev/null)" "$k" "evals-comportamento/3 case.yaml $k"
done
for g in primeira-skill categoria fase-seguinte; do
  assert_contains "$(cat "$CP/graders/$g.md" 2>/dev/null)" "arm: both" "evals-comportamento/3 $g com arm: both"
done
skills "$SP/em.jsonl" audora-commander:audora-commander audora-commander:memory audora-commander:scope
gp primeira-skill passou "porta primeiro"; gp fase-seguinte passou "porta, memory, scope"
skills "$SP/em.jsonl" audora-commander:memory audora-commander:audora-commander audora-commander:scope
gp primeira-skill reprovou "memory antes da porta"
skills "$SP/em.jsonl" audora-commander audora-commander:scope
gp primeira-skill passou "porta sem prefixo"; gp fase-seguinte passou "porta, scope"
: > "$SP/em.jsonl"; gp primeira-skill reprovou "nenhum Skill"; gp fase-seguinte reprovou "nenhum Skill"
skills "$SP/em.jsonl" audora-commander:audora-commander audora-commander:execute
gp fase-seguinte reprovou "porta, execute"
skills "$SP/em.jsonl" audora-commander:audora-commander audora-commander:plan audora-commander:scope
gp fase-seguinte reprovou "porta, plan, scope"
skills "$SP/em.jsonl" audora-commander:audora-commander
gp fase-seguinte reprovou "só porta"
skills "$SP/em.jsonl" superpowers:brainstorming audora-commander:audora-commander audora-commander:scope
gp primeira-skill reprovou "outra skill antes da porta"
printf '%s\n' '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"a","name": "Skill","input": {"skill": "audora-commander:audora-commander"}}]}}' > "$SP/em.jsonl"
ev_tool b Skill '{"skill":"audora-commander:scope"}' >> "$SP/em.jsonl"
gp fase-seguinte passou "tolera espaço entre chave e valor"
ev_text "Demanda classificada como **MEDIUM** porque nenhuma pergunta de risco deu SIM" > "$SP/em.jsonl"; gp categoria passou "MEDIUM em negrito"
ev_text "Classificada como MEDIUM — me corrija" > "$SP/em.jsonl"; gp categoria passou "MEDIUM sem negrito"
ev_text "Demanda classificada como **LIGHT** porque" > "$SP/em.jsonl"; gp categoria reprovou "LIGHT"
ev_text "Demanda classificada como **HIGH** porque" > "$SP/em.jsonl"; gp categoria reprovou "HIGH"
ev_text "não seria MEDIUM" > "$SP/em.jsonl"; gp categoria reprovou "MEDIUM sem o anúncio"
F="$SP/fx-porta"; na_fixture "$F" "$CP/fixture.sh"
run_hook memory-validate "$F/MEMORY.md"; assert_eq 0 "$code" "evals-comportamento/3 fixture porta: memory-validate ($out)"
assert_eq 1 "$(git -C "$F" log --oneline 2>/dev/null | wc -l | tr -d ' ')" "evals-comportamento/3 fixture porta: commitada"

# --- evals-comportamento/4: caso escopo-antes ---
CE="$EV/escopo-antes"
# ge <Write|Edit> <caminho|-> <esperado> — 1 escrita (ou nenhuma) contra o grader da ferramenta
ge() {
  local g=sem-write-fora; [ "$1" = Edit ] && g=sem-edit-fora
  : > "$SP/em.jsonl"
  [ "$2" = - ] || ev_tool e1 "$1" "{\"file_path\":\"$(jesc "$2")\",\"content\":\"x\"}" > "$SP/em.jsonl"
  assert_eq "$3" "$(emula_grader "$CE/graders/$g.md" "$SP/em.jsonl" "$SP/emws")" "evals-comportamento/4 $g: $1 $2"
}
assert_contains "$(tr -d '\r' < "$CE/prompt.md" 2>/dev/null | tr '\n' ' ')" "Implemente o comando bin/conversor que converte temperatura entre Celsius e Fahrenheit (conversor c2f 100 imprime 212), com validação de entrada e testes." "evals-comportamento/4 prompt do caso"
for k in 'max_turns: 40' 'timeout_seconds: 600' 'allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, AskUserQuestion, TodoWrite]'; do
  assert_contains "$(cat "$CE/prompt.md" 2>/dev/null)" "$k" "evals-comportamento/4 frontmatter $k"
done
assert_contains "$(cat "$CE/case.yaml" 2>/dev/null)" "name: escopo-antes" "evals-comportamento/4 case.yaml"
for g in sem-write-fora sem-edit-fora; do
  assert_contains "$(cat "$CE/graders/$g.md" 2>/dev/null)" "arm: both" "evals-comportamento/4 $g com arm: both"
done
ge Write 'C:\Users\x\home\cwd\bin\conversor' reprovou
ge Write 'C:\Users\x\home\cwd\docs\audora\memory\conversor.md' passou
ge Edit 'C:\Users\x\home\cwd\MEMORY.md' passou
ge Edit /tmp/ws/cwd/lib.sh reprovou
ge Write /tmp/ws/cwd/docs/audora/aprendizados.md passou
ge Write /tmp/ws/cwd/docs/outro.md reprovou
ge Write 'C:\w\docs\audorax\a.md' reprovou
ge Write - passou
ge Edit - passou
ge Edit 'C:\w\tests\test-conversor.sh' reprovou
F="$SP/fx-escopo"; na_fixture "$F" "$CE/fixture.sh"; assert_file "$F/MEMORY.md" "evals-comportamento/4 fixture cria o projeto"
run_hook memory-validate "$F/MEMORY.md"; assert_eq 0 "$code" "evals-comportamento/4 fixture: memory-validate ($out)"

# --- evals-comportamento/5: caso memoria ---
CM="$EV/memoria"
# gm <grader> <esperado> <descrição> — emula sobre o workspace $SP/emws
gm() { assert_eq "$2" "$(emula_grader "$CM/graders/$1.md" "$SP/em.jsonl" "$SP/emws")" "evals-comportamento/5 $1: $3"; }
assert_contains "$(tr -d '\r' < "$CM/prompt.md" 2>/dev/null | tr '\n' ' ')" "Demanda dobro-negativo: a função dobro da lib deve aceitar números negativos (hoje recusa). E fica a dica para sempre neste projeto: a suíte só passa com LC_ALL=C bash tests/run.sh." "evals-comportamento/5 prompt do caso"
assert_contains "$(cat "$CM/case.yaml" 2>/dev/null)" "name: memoria" "evals-comportamento/5 case.yaml"
for g in no-com-ears aprendizado-fora-do-memory aprendizado-registrado; do
  assert_contains "$(cat "$CM/graders/$g.md" 2>/dev/null)" "arm: both" "evals-comportamento/5 $g com arm: both"
done
rm -rf "$SP/emws"; mkdir -p "$SP/emws/docs/audora/memory"; : > "$SP/em.jsonl"
NO="$SP/emws/docs/audora/memory/dobro-negativo.md"
gm no-com-ears reprovou "nó ausente"
printf -- '- **dobro-negativo/1** — QUANDO `dobro -3` é chamado O\n  SISTEMA DEVE imprimir -6\n' > "$NO"; gm no-com-ears passou "critério EARS quebrado em linha"
printf -- '- dobro-negativo/1 — aceitar negativos\n' > "$NO"; gm no-com-ears reprovou "critério sem EARS"
printf -- '- QUANDO x O SISTEMA DEVE y\n' > "$NO"; gm no-com-ears reprovou "EARS sem endereço <id>/<n>"
printf 'memory-schema: 1\n## Aprendizados\n- 2026-10-09 | execute | LC_ALL=C bash tests/run.sh\n' > "$SP/emws/MEMORY.md"
gm aprendizado-fora-do-memory reprovou "linha de aprendizado no MEMORY"
printf 'memory-schema: 1\n## Aprendizados\nAprendizados vivem em docs/audora/aprendizados.md\n- dobro | in-progress | x\n' > "$SP/emws/MEMORY.md"
gm aprendizado-fora-do-memory passou "MEMORY sem linha datada"
cp "$ROOT/templates/aprendizados-template.md" "$SP/emws/docs/audora/aprendizados.md"
gm aprendizado-registrado reprovou "aprendizados.md só com o cabeçalho"
echo "- 2026-10-09 | execute | suíte só passa com LC_ALL=C" >> "$SP/emws/docs/audora/aprendizados.md"
gm aprendizado-registrado passou "aprendizado com LC_ALL=C"
F="$SP/fx-memoria"; na_fixture "$F" "$CM/fixture.sh"; assert_file "$F/MEMORY.md" "evals-comportamento/5 fixture cria o projeto"
run_hook memory-validate "$F/MEMORY.md"; assert_eq 0 "$code" "evals-comportamento/5 fixture: memory-validate ($out)"
( cd "$F" && bash tests/run.sh ) >/dev/null 2>&1; assert_eq 0 "$?" "evals-comportamento/5 fixture: suíte passa"
r="$(cd "$F" && bash -c 'source lib.sh; dobro 4; dobro -3 2>&1; echo "rc=$?"')"
assert_eq "$(printf '8\nerro: não numérico ou negativo\nrc=1')" "$r" "evals-comportamento/5 fixture: dobro recusa negativo"
assert_eq 1 "$(git -C "$F" log --oneline 2>/dev/null | wc -l | tr -d ' ')" "evals-comportamento/5 fixture: commitada"


# todo registro real do mutacoes.tsv tem âncoras válidas e caso existente
while IFS=$'\t' read -r regra caso arq ini fim; do
  case "$regra" in ''|'#'*) continue ;; esac
  assert_eq 1 "$(grep -cF -- "$ini" "$ROOT/$arq")" "evals-comportamento/10 $regra: início único em $arq"
  n="$(grep -nF -- "$ini" "$ROOT/$arq" | head -1 | cut -d: -f1)"
  assert_contains "$(tail -n +"${n:-1}" "$ROOT/$arq")" "$fim" "evals-comportamento/10 $regra: fim depois do início"
  assert_contains "$(lista_casos "$ROOT" | cut -f1)" "$caso" "evals-comportamento/10 $regra: caso $caso existe"
done < <(tr -d '\r' < "$EV/mutacoes.tsv" 2>/dev/null)
assert_eq 6 "$(grep -cv '^#' "$EV/mutacoes.tsv" 2>/dev/null)" "evals-comportamento/10 mutacoes.tsv com as 6 regras"
d="$SP/mut1"; mkdir -p "$d"; printf 'a\nINI\nb\nFIM\nc\n' > "$d/f"
assert_eq "linhas 2-4" "$(aplica_mutacao "$d/f" INI FIM)" "aplica_mutacao imprime as linhas"
assert_eq "$(printf 'a\nc')" "$(cat "$d/f")" "aplica_mutacao remove o trecho"
printf 'a\r\nINI\r\nc\r\n' > "$d/g"; aplica_mutacao "$d/g" INI INI >/dev/null
assert_eq 2 "$(tr -cd '\r' < "$d/g" | wc -c | tr -d ' ')" "aplica_mutacao preserva CRLF"

# --- funções da Tarefa 2 ---
assert_eq "infra: timeout" "$(classifica_erro 'Timeout: run exceeded')" "classifica_erro timeout"
assert_eq "infra: API" "$(classifica_erro 'API Error: 500')" "classifica_erro API"
assert_eq "reprovado" "$(classifica_erro 'reached max turns (40)')" "classifica_erro max turns"
printf 'x\n' > "$SP/sem-result.jsonl"
assert_eq 0 "$(tokens_trace "$SP/sem-result.jsonl")" "tokens_trace sem evento result → 0"
assert_eq 0 "$(tokens_trace "$SP/nao-existe.jsonl")" "tokens_trace sem arquivo → 0"

# --- evals-comportamento/12: evals fora da suíte, docs e envs ---
for f in "$ROOT"/tests/evals*.sh $(find "$ROOT/tests/evals" -type f); do
  case "${f#$ROOT/}" in tests/test-*.sh) ko "evals-comportamento/12 $f casa o glob da suíte" ;; *) ok ;; esac
done
# o nome vai por partes para este guarda não se contar
orq='tests/evals''.sh'
# o orquestrador é testado em 2 arquivos (o tempo de 1 só estoura o timeout da suíte)
assert_eq "$(printf 'tests/test-evals-harness.sh\ntests/test-evals.sh')" "$(cd "$ROOT" && grep -lF "$orq" tests/test-*.sh | LC_ALL=C sort)" "evals-comportamento/12 só os testes do orquestrador o citam"
for t in test-evals.sh test-evals-harness.sh; do
  assert_eq 1 "$(grep -cF "$orq" "$ROOT/tests/$t")" "evals-comportamento/12 $t chama o orquestrador só por roda_evals"
  assert_contains "$(grep -F "$orq" "$ROOT/tests/$t")" "roda_evals() { bash \"\$ROOT/$orq\" --claude \"\$STUB\"" "evals-comportamento/12 $t: roda_evals sempre com o stub"
  assert_contains "$(cat "$ROOT/tests/$t")" 'assert_no_file "$SP/chamou-claude"' "evals-comportamento/12 $t confere que nenhum claude real rodou"
done
LEIA="$(cat "$EV/README.md" 2>/dev/null)"
for t in PASSOU REPROVOU 'ERRO INFRA' RECUSADO 'NÃO RODADO' 'claude setup-token' --completo --mutar '## Calibração' '| caso | condição ruim | data | resultado |'; do
  assert_contains "$LEIA" "$t" "evals-comportamento/12 README cita $t"
done
for c in '| `0` |' '| `1` |' '| `2` |' '| `3` |' '| `4` |'; do
  assert_contains "$LEIA" "$c" "evals-comportamento/12 README: tabela de exits $c"
done
assert_contains "$(tr -d '\r' < "$ROOT/.gitignore")" ".env" "evals-comportamento/12 .gitignore com .env"
assert_eq 1 "$(tr -d '\r' < "$ROOT/.gitignore" | grep -cx '\.env')" "evals-comportamento/12 .env é linha própria"
assert_eq 1 "$(tr -d '\r' < "$ROOT/.gitignore" | grep -cx 'tests/evals/results/')" "evals-comportamento/12 .gitignore com tests/evals/results/"
assert_contains "$(cat "$ROOT/.env.example" 2>/dev/null)" "CLAUDE_CODE_OAUTH_TOKEN=__coloque_o_valor__" "evals-comportamento/12 .env.example com o token"
git -C "$ROOT" check-ignore -q .env; assert_eq 0 "$?" "evals-comportamento/12 .env ignorado pelo git"
assert_contains "$(sed -n '/^## Constituição/,/^## Aprendizados/p' "$ROOT/MEMORY.md")" "evals de comportamento: \`bash $orq\`" "evals-comportamento/12 Constituição como-rodar cita os evals"
assert_no_file "$SP/chamou-claude" "evals-comportamento/12 nenhum claude real chamado pelo test-evals.sh"

# --- evals-comportamento/13: todo caso tem calibração que reprova ---
# calibrado <readme> <caso> — exit 0 se a tabela ## Calibração tem linha do caso com REPROVOU
calibrado() { tr -d '\r' < "$1" | sed -n '/^## Calibração/,$p' | grep "^| $2 |" | grep -q REPROVOU; }
printf '## Calibração\n\n| caso | condição ruim | data | resultado |\n|---|---|---|---|\n| a | mutação x | 2026-10-10 | REPROVOU 0/3 |\n| b | braço sem plugin | 2026-10-10 | PASSOU 3/3 |\n' > "$SP/cal.md"
calibrado "$SP/cal.md" a; assert_eq 0 "$?" "evals-comportamento/13 guarda aceita caso que reprovou"
calibrado "$SP/cal.md" b; assert_eq 1 "$?" "evals-comportamento/13 guarda recusa linha sem REPROVOU"
calibrado "$SP/cal.md" c; assert_eq 1 "$?" "evals-comportamento/13 guarda recusa caso sem linha"
while IFS=$'\t' read -r caso _; do
  calibrado "$EV/README.md" "$caso" && ok || ko "evals-comportamento/13 caso $caso sem calibração que reprova no README"
done < <(lista_casos "$ROOT")


report
