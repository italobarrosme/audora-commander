#!/usr/bin/env bash
# Estrutura das 9 skills + contratos de conteúdo (memory: /2,/3,/6,/10-17; fases: /14,/18).
# memory-fatiada/1,/2,/3,/4,/6,/7 — a skill memory é roteador + references: cada
# string é asserida no arquivo CERTO, não num cat único que não distingue local.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
for s in audora-commander memory scope plan execute e2e validate debug worktree; do
  f="skills/$s/SKILL.md"
  assert_file "$f" "skill $s existe"
  [ -f "$f" ] || continue
  for g in "$f" "skills/$s/references"/*.md; do
    [ -f "$g" ] || continue
    [ "$(wc -l < "$g")" -le 250 ] && ok || ko "memory-fatiada/6 $g > 250 linhas"
  done
  grep -q "^name: $s\$" "$f" && ok || ko "$s name:"
  grep -q "^description: 'Use quando" "$f" && ok || ko "$s description entre aspas simples"
  grep -q 'LEI DE FERRO' "$f" && ok || ko "$s Lei de Ferro"
  grep -q 'Anuncie ao começar' "$f" && ok || ko "$s Anuncie"
  grep -q '^## PRÓXIMA SKILL' "$f" && ok || ko "$s PRÓXIMA SKILL"
done
MS="skills/memory/SKILL.md"; MR="skills/memory/references"
m="$(cat "$MS" 2>/dev/null)"
# /3 — a tabela do roteador nomeia as 6 operações
for op in carregar-contexto bootstrap registrar-no registrar-delta \
          registrar-aprendizado compactar; do
  assert_contains "$m" "$op" "/3 tabela do roteador cita $op"
done
# /1 — as 3 quentes ficam com o CORPO no roteador
assert_contains "$m" '### 1. carregar-contexto' "/1 carregar-contexto inline"
assert_contains "$m" '### 4. registrar-delta' "/1 registrar-delta inline"
assert_contains "$m" '### 5. registrar-aprendizado' "/1 registrar-aprendizado inline"
# /3 — a tabela é tabela: cada linha casa operação com localização
for op in carregar-contexto registrar-delta registrar-aprendizado; do
  assert_contains "$m" "| $op | inline |" "/3 linha de tabela: $op inline"
done
# /7 — as 3 movidas existem e estão na tabela, com a linha completa
for b in bootstrap registrar-no compactar; do
  assert_file "$MR/$b.md" "/7 reference $b existe"
  assert_contains "$m" "| $b | references/$b.md |" "/7 linha de tabela: $b"
done
# /7 — nenhuma reference órfã (arquivo fora da tabela)
for g in "$MR"/*.md; do
  [ -f "$g" ] || continue
  assert_contains "$m" "references/$(basename "$g")" "/7 sem órfã: $(basename "$g")"
done
# /2 — conteúdo de cada operação movida está na SUA reference
# remover-graphify/1 — bootstrap não oferece nem instala o Graphify; o gate fecha o bootstrap
grep -qi 'graphify' "$MR/bootstrap.md" && ko "remover-graphify/1 bootstrap cita graphify" || ok
assert_contains "$(cat "$MR/bootstrap.md")" '**Etapa gate** (sempre, ao fim do bootstrap)' "remover-graphify/1 gate fecha o bootstrap"
for s in 'hooks/graphify-status' 'Instalo o Graphify' 'inclui oferta e ativação do Graphify'; do
  assert_not_contains "$m" "$s" "remover-graphify/1,10 memory sem '$s'"
done
for s in 'docs/audora/arquivo/' 'aprendizados-historico.md' 'git mv'; do
  assert_contains "$(cat "$MR/compactar.md" 2>/dev/null)" "$s" "/2 compactar cita '$s'"
done
for s in 'no-template.md' 'hotfix-pending-record' 'planned | in-progress'; do
  assert_contains "$(cat "$MR/registrar-no.md" 2>/dev/null)" "$s" "/2 registrar-no cita '$s'"
done
# /2 — o roteador NÃO carrega o corpo movido (move, não copia)
for s in 'uv tool install graphifyy' 'pipx install graphifyy' 'graphify hook install' '--budget' 'graphify path' 'aprendizados-historico.md'; do
  assert_not_contains "$m" "$s" "/2 roteador sem corpo movido: '$s'"
done
# /1 — o que É do roteador continua nele
for s in 'memory-schema: 1' 'docs/audora/memory/' 'memory-validate' 'memory-guard' 'Aprendizados' '| <fase> |'; do
  assert_contains "$m" "$s" "/1 roteador cita '$s'"
done
# /4 — degradação declarada no roteador
assert_contains "$m" 'reference ausente' "/4 roteador declara reference ausente"
assert_contains "$m" 'sem travar a fase' "/4 roteador degrada sem travar"
# remover-graphify/9,/10 — fases e worktree sem Graphify e sem consulta ao índice de código
for s in audora-commander scope plan execute e2e validate debug worktree; do
  grep -qiE 'graphify|consultar-codigo' "skills/$s/SKILL.md" && ko "remover-graphify/9 $s cita graphify/consultar-codigo" || ok
  grep -qiE '(í|Í|i)ndice de c(ó|o)digo' "skills/$s/SKILL.md" && ko "remover-graphify/10 $s cita índice de código" || ok
done
assert_no_file "$MR/consultar-codigo.md" "remover-graphify/9 reference consultar-codigo removida"
for s in 'consultar-codigo' 'operação 7' 'graphify query' 'graphify update'; do
  assert_not_contains "$m" "$s" "remover-graphify/9 memory sem '$s'"
done
for s in scope execute debug e2e; do
  assert_contains "$(cat skills/$s/SKILL.md)" 'registrar-aprendizado' "/6 $s registra aprendizado"
done
a="$(cat skills/audora-commander/SKILL.md)"
assert_contains "$a" 'skill `memory`' "/2 porta de entrada usa skill memory"
assert_eq "9" "$(ls -d skills/*/ | wc -l | tr -d ' ')" "limpeza-codigo-morto/3 9 skills"
assert_contains "$a" 'de qualquer outra coisa. Nunca seguir sem MEMORY' "limpeza-codigo-morto/1 porta de entrada oferece bootstrap sem aviso legado"
assert_contains "$a" 'MEMORY ausente → oferecer bootstrap antes' "memory-graphify/2 porta de entrada oferece bootstrap"
v="$(cat skills/validate/references/sync.md 2>/dev/null)"
assert_contains "$v" 'docs/audora/memory/<id>.md docs/audora/arquivo/' "/7 validate arquiva por git mv"
assert_contains "$v" 'aprendizados' "/7 validate consolida aprendizados"
assert_contains "$v" 'MEMORY → PRD' "/7 direção única"
# resumo-de-fase/8 — as 7 skills de fase definem o bloco de fechamento
for s in audora-commander scope plan execute e2e validate debug; do
  c="$(cat "skills/$s/SKILL.md" 2>/dev/null)"
  assert_contains "$c" '## Bloco de fechamento' "/8 $s define o bloco"
  assert_contains "$c" 'bloco-fechamento-template.md' "/8 $s aponta o template"
done
# resumo-de-fase/9 — skills-ferramenta NAO definem bloco proprio
for s in memory worktree; do
  c="$(cat "skills/$s/SKILL.md" 2>/dev/null)"
  assert_not_contains "$c" '## Bloco de fechamento' "/9 $s (ferramenta) sem bloco proprio"
done
# /3 e /4 — as duas fases com regra propria declaram a regra
e="$(cat skills/execute/SKILL.md)"
assert_contains "$e" 'só no fim da fase' "/3 execute imprime tarefas so no fim"
v="$(cat skills/validate/SKILL.md)"
assert_contains "$v" 'git diff --name-only' "/4 validate tira arquivos do diff real"
assert_contains "$v" '**Entrega**' "/4 validate imprime o bloco de entrega"
# scope-batch/7,/8 — perguntas em lote, com teste de dependencia declarado
sc="$(cat skills/scope/SKILL.md)"
assert_not_contains "$sc" 'Nunca duas perguntas na mesma mensagem' "/7 scope sem a regra antiga"
for s in 'Perguntas — em lote' 'independentes' 'no máximo 4' 'teste de dependência' 'em série'; do
  assert_contains "$sc" "$s" "/8 scope declara '$s'"
done
# light-enxuto/7,/8 — caminho de fechamento LIGHT, asserido DENTRO da secao
vl="$(cat skills/validate/references/fechamento-light.md 2>/dev/null)"
assert_contains "$vl" '# validate — Fechamento LIGHT' "/7 validate declara o caminho LIGHT"
lt="$(cat skills/validate/references/fechamento-light.md 2>/dev/null)"
for s in 'portão humano' 'evidência 1:1'; do
  assert_contains "$lt" "$s" "/8 caminho LIGHT preserva '$s'"
done
for s in 'não tem plano' 'caminho percorrido pelo usuário' 'PRD'; do
  assert_contains "$lt" "$s" "/7 caminho LIGHT trata '$s'"
done
# decisoes-vivas-poda/1,/5,/6,/7,/8,/9,/10 — regra de entrada e marcadores
vd="$(cat skills/validate/references/decisoes-vivas.md 2>/dev/null)"
assert_contains "$vd" 'impor por teste, hook ou config' "/5 validate declara a regra de entrada"
assert_contains "$vd" 'mesmo escopo de aplicação' "/1 validate declara o discriminador de escopo"
assert_contains "$vd" 'escreva o teste' "/8 validate manda escrever o teste ou manter a entrada"
dv='docs/audora/decisoes-vivas.md'
assert_file "$dv" "/9 arquivo de decisoes vivas existe"
ents="$(grep '^- 20' "$dv" 2>/dev/null || true)"
[ -n "$ents" ] && ok || ko "/9 decisoes-vivas.md sem nenhuma entrada"
# exclui o bloco de comentario HTML (o rodape cita os marcadores no texto das
# regras); assim o guarda pega marcador com QUALQUER data e em linha indentada
corpo="$(awk '/<!--/{c=1} !c; /-->/{c=0}' "$dv" 2>/dev/null || true)"
marc="$(printf '%s
' "$corpo" | grep '\[invalidado-em:' || true)"
if [ -n "$marc" ]; then
  bad="$(printf '%s
' "$marc" | grep -v '\[substituido-por: [^] ]' || true)"
  assert_empty "$bad" "/6+/10 invalidado-em sem substituido-por preenchido"
  printf '%s
' "$marc" | grep -o '\[substituido-por: [^]]*\]' | sed 's/\[substituido-por: //; s/\]$//' > "$SP/refs.txt"
  falta=""
  while IFS= read -r ref; do
    [ -f "$ref" ] || falta="$falta|$ref"
  done < "$SP/refs.txt"
  assert_empty "$falta" "/7+/10 substituido-por deve apontar ARQUIVO existente"
else
  ok; ok
fi
# decisoes-vivas-poda/8 — as 2 decisoes que apontam skills/e2e/SKILL.md ganham
# guarda de verdade: sem isto o ponteiro e prosa->prosa e pode derivar (achado B3).
e2s="$(cat skills/e2e/SKILL.md)"
assert_contains "$e2s" 'docker-compose.e2e.yml' "/8 e2e fixa o nome do compose de e2e"
assert_contains "$e2s" 'nunca escolher sozinho' "/8 e2e exige perguntar a ferramenta nao-web"
assert_contains "$e2s" 'Registrar a escolha na' "/8 e2e registra a escolha na Constituicao"
# sync-mecanizado/9 — o conhecimento das 4 revisoes adversariais vira COMANDO
# documentado na validate, nao script. Quatro rodadas nao converjiram: taxa de
# mutacao ficou em ~45% verde e cada correcao abria buraco novo.
vs="$(cat skills/validate/references/sync.md 2>/dev/null)"
assert_contains "$vs" '--diff-filter=A' "/9 validate documenta a derivacao da base"
assert_contains "$vs" 'nunca por `--grep`' "/9 validate avisa contra derivar por --grep"
assert_contains "$vs" 'pode conter commits de outra demanda' "/9 validate avisa da super-inclusao"
assert_contains "$vs" 'o `PRD.md` ainda não foi tocado' "/9 validate avisa que o PRD nao aparece"
assert_no_file hooks/memory-arquivos "/9 script revertido"
assert_no_file hooks/memory-sync "/9 script antigo tambem fora"

# sync-mecanizado/9 — o item 6 nao pode ter DUAS ordens. A lista antiga mandava
# preencher arquivos: ANTES do delivered; seguindo ela depois do git mv, o
# memory-validate BLOQUEIA qualquer Edit no MEMORY.md (indice x pasta).
v6="$(cat skills/validate/references/sync.md 2>/dev/null)"
assert_not_contains "$v6" 'Preencher `arquivos:` do nó via `git diff --name-only` da demanda' "/9 bullet antigo de arquivos: removido do item 6"
assert_contains "$v6" 'ordem importa' "/9 item 6 declara que a ordem importa"
# otimizacao-tokens/5 — plano carrega teste e assinaturas, não implementação óbvia
pl="$(cat skills/plan/SKILL.md)"; pt="$(cat templates/plano-template.md)"
assert_contains "$pl" 'implementação só quando não-óbvio' "otimizacao-tokens/5 plan: implementação só se não-óbvia"
assert_contains "$pl" 'código completo do TESTE' "otimizacao-tokens/5 plan: teste completo"
assert_not_contains "$pl" 'Código real nos passos' "otimizacao-tokens/5 plan: regra antiga fora"
assert_contains "$pt" 'implementação só quando não-óbvio' "otimizacao-tokens/5 template: idem"
assert_contains "$pt" 'TBD' "otimizacao-tokens/5 template mantém a proibição de placeholder"
# otimizacao-tokens/2,/3 — validate é roteador + references (texto asserido onde mora)
VR=skills/validate/references; vv="$(cat skills/validate/SKILL.md)"
for r in sync decisoes-vivas fechamento-light; do
  assert_file "$VR/$r.md" "otimizacao-tokens/2 reference $r existe"
  assert_contains "$vv" "references/$r.md" "otimizacao-tokens/2 roteador aponta $r"
done
assert_contains "$vv" 'Reference ausente' "otimizacao-tokens/3 declara reference ausente"
assert_contains "$vv" 'mantém o portão humano e NÃO roda o sync' "otimizacao-tokens/3 portão fica, sync não roda"
assert_not_contains "$vv" '--diff-filter=A' "otimizacao-tokens/2 corpo do sync fora do roteador"
assert_not_contains "$vv" 'Mecanizar isso foi tentado' "otimizacao-tokens/2 prosa histórica fora"
assert_not_contains "$(cat "$VR/sync.md" 2>/dev/null)" 'Mecanizar isso foi tentado' "otimizacao-tokens/2 prosa histórica fora do sync"
[ "$(tr -d '\r' < skills/validate/SKILL.md | wc -c)" -lt 7700 ] && ok || ko "otimizacao-tokens/2 validate < 7700 bytes (era 11603)"
# otimizacao-tokens/1,/4 — não reler na sessão; /clear recomendado entre fases
assert_contains "$(cat skills/memory/SKILL.md)" 'Já carregado nesta sessão' "otimizacao-tokens/1 memory: não reinvocar/reler"
for s in audora-commander scope plan execute e2e validate debug; do
  bf="$(awk '/^## Bloco de fechamento/{f=1;next} /^## /{f=0} f' "skills/$s/SKILL.md")"
  assert_contains "$bf" 'já lido nesta sessão' "otimizacao-tokens/1 $s não relê o template"
done
for s in scope plan; do assert_contains "$(cat skills/$s/SKILL.md)" 'PARADA: rode /clear' "contexto-por-fase/1 $s para (substitui otimizacao-tokens/4)"; done
# validate-estado-no/10 — ordem da transição: nó primeiro, índice depois
assert_contains "$(cat skills/memory/references/registrar-no.md)" 'nó primeiro, índice depois' "validate-estado-no/10 registrar-no ensina a ordem"
assert_contains "$(cat skills/validate/references/sync.md)" 'nó primeiro, índice depois' "validate-estado-no/10 sync ensina a ordem"
assert_contains "$(cat skills/memory/SKILL.md)" 'estado índice↔nó' "validate-estado-no/10 memory lista a checagem nova"
report
