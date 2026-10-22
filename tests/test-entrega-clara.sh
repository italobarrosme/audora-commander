#!/usr/bin/env bash
# entrega-clara — decidido o portão, a validate fecha o turno com um cartão
# único (🏁 DONE, ❌ NÃO ENTREGUE ou ⚠️ PARCIAL) no lugar do bloco de fase.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# sec <arquivo> '<cabeçalho exato>' → corpo da seção, sem \r (checkout CRLF).
# `## ` dentro de fence de 4 crases (o esqueleto do cartão) não fecha a seção.
sec() {
  tr -d '\r' 2>/dev/null < "$1" |
    awk -v h="$2" '/^````/{q=!q} $0==h{f=1;next} !q && /^## /{f=0} f'
}
# flat <arquivo> [cabeçalho] → texto (da seção, se dado) numa linha só,
# espaços colapsados: frase que quebra linha no Markdown ainda casa.
flat() {
  if [ -n "${2:-}" ]; then sec "$1" "$2"; else tr -d '\r' 2>/dev/null < "$1"; fi |
    tr '\n' ' ' | tr -s ' '
}

T=templates/bloco-fechamento-template.md
H='## Cartão de entrega (só a validate, decidido o portão)'
r="$(sec "$T" "$H")"
f="$(flat "$T" "$H")"
b="$(flat "$T")"
esq="$(printf '%s\n' "$r" | awk '/^````markdown/{f=1;next} /^````/{f=0} f')"

# --- /1 — cartão único de título DONE, em toda categoria, no lugar do bloco de fase ---
[ -n "$r" ] && ok || ko "entrega-clara/1 template sem a seção '$H'"
for s in '## 🏁 DONE — <id>' 'no lugar do bloco de fase' 'em TODA categoria (LIGHT, MEDIUM, HIGH, HOTFIX)'; do
  assert_contains "$f" "$s" "entrega-clara/1 cartão DONE no lugar do bloco de fase"
done
ordem="$(printf '%s\n' "$esq" | grep -oE '^\*\*[^*]+\*\*' | tr '\n' '|')"
assert_eq '**O que mudou**|**Como foi**|**Ressalvas**|**Mudanças no caminho**|**Por critério**|**Evidência**|**Decisões da IA**|**Como conferir**|**Arquivos**|**Memória**|' "$ordem" "entrega-clara/1 rótulos do esqueleto em ordem"
assert_contains "$b" 'a validate, decidido o portão, imprime o cartão de entrega no lugar do bloco' "entrega-clara/1 header do template aponta o cartão"
for s in '## Relatório de entrega' '#### Relatório de entrega — <id>' '| critério | evidência' '~~caminho/antigo.ts~~'; do
  assert_not_contains "$b" "$s" "entrega-clara/1 regressão: relatório velho sumiu"
done
assert_contains "$b" '## Parada entre fases' "entrega-clara/1 regressão: seção vizinha intocada"

# --- /2 — linha de estado: categoria · entregues/total critérios · main ou branch ---
for s in '<categoria> · <entregues>/<total> critérios · na main' 'ou `na branch <nome>`'; do
  assert_contains "$f" "$s" "entrega-clara/2 linha de estado"
done

# --- /15 — cartão é a última parte do turno ---
for s in 'última parte da resposta do turno' 'nenhuma chamada de ferramenta depois dele'; do
  assert_contains "$f" "$s" "entrega-clara/15 última parte do turno"
done

# --- /3 — O que mudou: 1 a 3 bullets em linguagem de usuário ---
for s in '1 a 3 bullets' 'o sistema agora'; do
  assert_contains "$f" "$s" "entrega-clara/3 O que mudou"
done

# --- /4 — Como foi: trilha das fases, em ordem, até 8 palavras, e2e rodado ou pulado ---
for s in 'em ordem cronológica' 'até 8 palavras' 'e2e marcado `rodado` ou `pulado`' 'fases que a categoria não percorre ficam fora' 'cada resumo vem de fonte lida nesta sessão (nó, plano, `git log`, campo `## e2e` do nó)'; do
  assert_contains "$f" "$s" "entrega-clara/4 Como foi"
done

# --- /5 — Ressalvas: 1 linha por ressalva; sem nenhuma, "nenhuma" explícito ---
for s in '**Ressalvas** — nenhuma' '1 linha por ressalva' 'e2e pulado, prova parcial, ressalva aceita no portão'; do
  assert_contains "$f" "$s" "entrega-clara/5 Ressalvas"
done

# --- /6 — Mudanças no caminho: 1 linha por delta; omitida sem delta ---
for s in '1 linha por entrada de `## delta` do nó' 'Sem delta, a seção não é impressa'; do
  assert_contains "$f" "$s" "entrega-clara/6 Mudanças no caminho"
done

# --- /7 — Por critério: todos, endereço, ícone com palavra ---
for s in 'TODOS os critérios do nó' '✅ entregue' '⏳ pendente' '❌ reprovado' '`<id>/<n>`'; do
  assert_contains "$f" "$s" "entrega-clara/7 Por critério"
done

# --- /8 — Evidência e Decisões da IA em 1 linha cada, sem repetir o roteiro ---
for s in 'detalhe no roteiro do portão' '**Decisões da IA** — <n>, revisadas no portão' 'Sem decisão da IA, a linha não é impressa' 'nunca repete a tabela de evidência nem a lista de decisões do roteiro'; do
  assert_contains "$f" "$s" "entrega-clara/8 Evidência e Decisões da IA"
done

# --- /9 — Como conferir: ≥ 1 item ligado a critério; text ou tela/rota ---
for s in '≥ 1 item, cada um ligado ao critério que confere' 'code block ` ```text `' 'tela/rota a abrir'; do
  assert_contains "$f" "$s" "entrega-clara/9 Como conferir"
done

# --- /10 — Arquivos: 1 linha somada do numstat real, só dos commits da demanda ---
for s in '**Arquivos** — <n> arquivos · +<a> −<r>' 'Saída vazia → `[SEM FONTE]`' 'sem tabela de arquivos'; do
  assert_contains "$f" "$s" "entrega-clara/10 Arquivos em 1 linha"
done
# integração: o comando do template roda num repo com commits de duas demandas
cmd="$(printf '%s\n' "$r" | awk '/^```bash/{f=1;next} /^```/{f=0} f')"
R="$SP/repo"; mkdir -p "$R" && cd "$R" || exit 1
git init -q . && git config user.name t && git config user.email t@t &&
  git config core.autocrlf false && git config core.excludesFile "$SP/nada" &&
  git config commit.gpgsign false && git config core.hooksPath "$SP/nada"
c() { git add -A && git commit -qm "$1"; }
echo r > README; c 'chore: init'
mkdir -p docs/audora/memory docs/audora/arquivo
printf '1\n2\n3\n' > docs/audora/memory/demo.md; c 'docs(demo): escopo e plano'
printf 'a\nb\n' > a.txt; c 'feat(demo/1): a'
printf '1\n2\n3\n4\n5\n' > b.txt; c 'feat(outra/1): b'
printf 'a\nB\n' > a.txt; c 'fix(demo/2): a'
echo c > c.txt; c 'docs(outra): cita demo/1'
echo d > d.txt; c 'feat(demo-x/1): d'
git mv docs/audora/memory/demo.md docs/audora/arquivo/2026-10-22-demo.md && git commit -qm 'docs(demo): sync'
assert_eq '2 arquivos · +5 −0' "$(printf '%s\n' "$cmd" | sed 's/<id>/demo/g' | bash 2>&1)" "entrega-clara/10 comando do template no repo fixture"
assert_eq '' "$(printf '%s\n' "$cmd" | sed 's/<id>/nada/g' | bash 2>&1)" "entrega-clara/10 demanda sem nó: saída vazia, sem erro"
cd "$ROOT" || exit 1

# --- /11 — rodapé Memória só quando o sync rodou; sync não fala fora do cartão ---
for s in '**Memória** —' 'só quando o sync rodou' 'nenhum resumo do sync fora do cartão'; do
  assert_contains "$f" "$s" "entrega-clara/11 rodapé da memória"
done
y="$(flat skills/validate/references/sync.md)"
for s in 'no rodapé **Memória** do cartão de entrega' 'Sobras do processo: N — rode a skill cleanup quando quiser.'; do
  assert_contains "$y" "$s" "entrega-clara/11 sync manda as sobras ao rodapé"
done
assert_not_contains "$y" '1 linha ao humano' "entrega-clara/11 sync sem linha solta ao humano"

# --- /12 — aprovado em branch: DONE e Próximo pergunta o merge ---
for s in '> ⏸️ **Próximo** — fazer o merge na main agora?' '> 1. sim — merge, sync e confirmação em 1 linha' '> 2. não — fica na branch <nome>' 'sem segundo cartão'; do
  assert_contains "$f" "$s" "entrega-clara/12 merge perguntado no cartão"
done

# --- /13 — reprovado ou parcial: mesmo cartão, sem DONE ---
for s in '## ❌ NÃO ENTREGUE — <id>' '## ⚠️ PARCIAL — <id>' 'veredito e motivo por critério' 'fase de retorno (scope ou plan)' 'sem a palavra DONE'; do
  assert_contains "$f" "$s" "entrega-clara/13 não entregue e parcial"
done
assert_not_contains "$b" 'Vale para portão reprovado' "entrega-clara/13 portão reprovado sai do bloco interrompido"

# --- /14 — dado sem fonte → [SEM FONTE] e critério ⏳ ---
for s in '[SEM FONTE]' 'o critério ligado fica ⏳' 'nunca preencher de memória'; do
  assert_contains "$f" "$s" "entrega-clara/14 sem fonte"
done

# --- validate — fecha o turno com o cartão, no lugar do bloco de fase; merge em branch ---
V=skills/validate/SKILL.md
v="$(flat "$V" '## Bloco de fechamento')"
for s in 'fecha o turno com o **cartão de entrega**' '— `🏁 DONE`, `❌ NÃO ENTREGUE` ou `⚠️ PARCIAL` —' 'no lugar do bloco de fase' 'bloco-fechamento-template.md'; do
  assert_contains "$v" "$s" "entrega-clara/1 validate fecha com o cartão"
done
assert_contains "$v" 'nenhuma ferramenta depois dele' "entrega-clara/15 validate: cartão fecha o turno"
for s in 'seguido do relatório de **Entrega**' '**Produzido**: o veredito do portão'; do
  assert_not_contains "$v" "$s" "entrega-clara/1 regressão: bloco de fase + relatório saíram da validate"
done
assert_contains "$(flat "$V")" 'branch fora da main → o cartão pergunta o merge' "entrega-clara/12 validate: merge perguntado no cartão"
vb="$(tr -d '\r' < "$V" | wc -c)"
[ "$vb" -le 6300 ] && ok || ko "entrega-clara/1 validate '$vb' B > 6300"

report
