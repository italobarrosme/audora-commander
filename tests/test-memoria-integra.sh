#!/usr/bin/env bash
# memoria-integra/1..21 — critérios de HIGH no nó, ordem nó→índice, cleanup que não apaga o que o framework lê, aprendizados em arquivo próprio.
source "$(dirname "$0")/lib.sh"
mk() { # mk <nome> <linha1> <índice...>
  d="$SP/$1"; mkdir -p "$d/docs/audora/memory"
  printf '%s\n\n## Propósito [carga: sempre]\n\nx\n\n## Constituição [carga: sempre]\n\n- **stack**: x\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n%s\n' "$2" "$3" > "$d/MEMORY.md"
}
no() { printf -- '---\nid: %s\nestado: %s\norigem: humano\ndepende-de: [%s]\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-08-26\n---\n# %s\n' "$2" "$3" "$4" "$2" > "$SP/$1/docs/audora/memory/$2.md"; }
# achata <arq...> → texto sem \r, quebras viram espaço, espaços colapsados
achata() { cat "$@" 2>/dev/null | tr -d '\r' | tr '\n' ' ' | tr -s ' '; }
# casa_ci <regex perl> <arq...> → nomes dos arquivos cujo texto achatado casa, sem caixa (UTF-8)
casa_ci() { local re="$1"; shift; RE="$re" perl -CSD -Mutf8 -0777 -ne 'BEGIN{$r=$ENV{RE}; utf8::decode($r)} s/\s+/ /g; print "$ARGV\n" if /$r/i' "$@"; }

# /5 e /6 — órfão (arquivo sem linha no índice) só é cobrado na escrita do índice
mk n5 'memory-schema: 1' '- x | in-progress | X | r | k | —'; no n5 x in-progress ''; no n5 novo planned ''
run_hook memory-validate "$SP/n5/docs/audora/memory/novo.md"
assert_eq 0 "$code" "memoria-integra/5 nó novo planned antes da linha → 0"; assert_empty "$out" "memoria-integra/5 nó novo planned sem saída"
no n5 novo in-progress ''
run_hook memory-validate "$SP/n5/docs/audora/memory/novo.md"
assert_eq 0 "$code" "memoria-integra/5 nó novo in-progress antes da linha → 0"; assert_empty "$out" "memoria-integra/5 nó novo in-progress sem saída"
no n5 novo planejado ''
run_hook memory-validate "$SP/n5/docs/audora/memory/novo.md"
assert_eq 2 "$code" "memoria-integra/5 enum segue cobrado na escrita do nó → 2"
assert_contains "$out" "planejado" "memoria-integra/5 msg do enum"
assert_not_contains "$out" "sem linha no índice" "memoria-integra/5 só o órfão é adiado"
no n5 novo planned ''
run_hook memory-validate "$SP/n5/MEMORY.md"
assert_eq 2 "$code" "memoria-integra/6 escrita do índice com órfão → 2"
assert_contains "$out" "novo.md sem linha no índice mestre" "memoria-integra/6 msg do órfão"

# /7 — regra única: arquivo do nó primeiro, linha do índice logo depois
cd "$ROOT"
assert_empty "$(casa_ci 'mesma edição' skills/memory/SKILL.md skills/memory/references/*.md templates/MEMORY-template.md templates/no-template.md)" "memoria-integra/7 sem 'mesma edição'"
assert_contains "$(achata skills/memory/references/registrar-no.md)" 'arquivo do nó primeiro, linha do índice logo depois — na criação e na transição de estado' "memoria-integra/7 registrar-no traz a regra"
assert_contains "$(achata skills/memory/SKILL.md)" 'Arquivo do nó primeiro, linha do índice logo depois.' "memoria-integra/7 red flag da memory"
assert_contains "$(achata templates/MEMORY-template.md)" 'Arquivo do nó primeiro, linha do índice logo depois (criação e transição)' "memoria-integra/7 regra 1 do MEMORY-template"
assert_contains "$(achata templates/no-template.md)" '(arquivo do nó primeiro, linha do índice logo depois)' "memoria-integra/7 no-template"

# /1 — scope grava critérios de HIGH no nó; spec só contexto
sc="$(achata skills/scope/SKILL.md)"
assert_contains "$sc" 'MEDIUM e HIGH: os três campos direto no nó, critérios numerados em `## criterios-aceite`' "memoria-integra/1 critérios no nó"
assert_contains "$sc" 'só com contexto (pesquisa, alternativas, diagramas) — nunca critério' "memoria-integra/1 spec só contexto"
assert_not_contains "$sc" 'nó aponta para ela' "memoria-integra/1 nó não aponta para a spec"
assert_not_contains "$sc" 'ou a spec dedicada (HIGH)' "memoria-integra/1 fechamento sem spec como artefato de critério"

# /2 e /3 — sync copia critérios da spec antes do git mv; sem critério, para
sy="$(achata skills/validate/references/sync.md)"
assert_contains "$sy" 'Antes do `git mv`' "memoria-integra/2 sync: Antes do git mv"
assert_contains "$sy" 'copie literalmente cada um (a linha e suas continuações) para `## criterios-aceite` do nó' "memoria-integra/2 sync copia literal da spec"
assert_contains "$sy" 'Nó <id> sem critério numerado — sync parado, nada arquivado.' "memoria-integra/3 sync para e nomeia o nó"
assert_contains "$sy" 'nó primeiro, índice depois' "memoria-integra/2 sync mantém a ordem da transição"
conta="$(tr -d '\r' < skills/validate/references/sync.md | perl -ne 'print "$1\n" if /`(awk \x27\/\^## criterios-aceite\/[^`]*)`/' | head -1)"
assert_contains "$conta" "docs/audora/memory/<id>.md | grep -cE '" "memoria-integra/2 comando de contagem no sync"
conta="${conta//<id>/z}"
fz="$SP/f23"; mkdir -p "$fz/docs/audora/memory"
printf -- '# z\n\n## criterios-aceite\n\n- **z/1** — QUANDO a O SISTEMA DEVE b\n- **z/2** — QUANDO c O SISTEMA DEVE d\n\n## delta\n\n- z/3 citado\n' > "$fz/docs/audora/memory/z.md"
assert_eq 2 "$(cd "$fz" && bash -c "$conta")" "memoria-integra/2 conta 2 critérios do nó"
printf -- '# z\n\n## criterios-aceite\n\n## delta\n\n- ADICIONADO z/3\n' > "$fz/docs/audora/memory/z.md"
assert_eq 0 "$(cd "$fz" && bash -c "$conta")" "memoria-integra/3 critério só no delta não conta"
printf -- '# z\n\n## criterios-aceite\n\n- **zz/1** — QUANDO a O SISTEMA DEVE b\n' > "$fz/docs/audora/memory/z.md"
assert_eq 0 "$(cd "$fz" && bash -c "$conta")" "memoria-integra/3 critério de outro id não conta"

# --- fixtures git da cleanup (copiadas de tests/test-skill-cleanup.sh) ---
C="$ROOT/hooks/cleanup"
mkproj() {
  local d="$1"; rm -rf "$d"; mkdir -p "$d/docs/audora/arquivo" "$d/docs/audora/memory"
  git -C "$d" init -q
  git -C "$d" config user.email cleanup@test; git -C "$d" config user.name cleanup
  git -C "$d" config core.autocrlf false; git -C "$d" config core.excludesFile "$d/.nao-existe"
  printf 'memory-schema: 1\n\n## Propósito [carga: sempre]\n\nx\n\n## Constituição [carga: sempre]\n\n- **stack**: x\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n- d | delivered | D → docs/audora/arquivo/2026-01-01-d.md\n' > "$d/MEMORY.md"
  printf -- '---\nid: d\nestado: delivered\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-01-01\n---\n# d\n' > "$d/docs/audora/arquivo/2026-01-01-d.md"
  printf '# Decisões vivas\n' > "$d/docs/audora/decisoes-vivas.md"
  printf '# proj\n' > "$d/README.md"
  git -C "$d" add -A; git -C "$d" commit -qm base
}
addc() { mkdir -p "$(dirname "$1/$2")"; printf '%s\n' "$3" > "$1/$2"; git -C "$1" add -- "$2"; git -C "$1" commit -qm "add $2"; }
runc() { local d="$1"; shift; out="$(cd "$d" && bash "$C" "$@" 2>&1)"; code=$?; }
snap() {
  ( cd "$1" && git rev-parse HEAD && git status --porcelain && \
    find . -path ./.git -prune -o -type f -print | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done )
}
secao() { printf '%s\n' "$1" | awk -v t="## $2" '$0==t {on=1; next} /^## |^total:|^cleanup:/ {on=0} on'; }
assert_line() { printf '%s\n' "$1" | grep -qxF -- "$2" && ok || ko "$3 — sem a linha '$2'"; }

# /4 — artefato que cita critério sem cópia no nó arquivado fica em ## mantido
mk4() {
  mkproj "$1"
  printf -- '\n## criterios-aceite\n\n- **d/1** — QUANDO x O SISTEMA DEVE y\n' >> "$1/docs/audora/arquivo/2026-01-01-d.md"
  git -C "$1" add -A; git -C "$1" commit -qm crit
  addc "$1" docs/audora/specs/d-escopo.md 'Critérios: d/1 e d/2.'
  addc "$1" docs/audora/planos/arquivo/plano-d.md 'Cobre d/1.'
  addc "$1" docs/audora/e2e/e2e-d.md 'd/10 passou; d/3, d/2, d/3 e dd/7 também.'
}
p="$SP/c4"; mk4 "$p"
antes="$(snap "$p")"
runc "$p" varrer
assert_eq 0 "$code" "memoria-integra/4 varrer → 0"
assert_eq 'cleanup: relatório — nada foi alterado
## plano arquivado
- docs/audora/planos/arquivo/plano-d.md | nó d delivered
## mantido
- docs/audora/e2e/e2e-d.md | mantido: cita d/2, d/3, d/10 sem cópia no nó arquivado
- docs/audora/specs/d-escopo.md | mantido: cita d/2 sem cópia no nó arquivado
total: 1 item(ns) no lote' "$out" "memoria-integra/4 spec com d/2 em mantido, e2e com dedupe e ordem numérica, plano no lote"
runc "$p" contar
assert_eq 1 "$out" "memoria-integra/4 contar → 1"
assert_eq "$antes" "$(snap "$p")" "memoria-integra/4 varrer e contar não alteram nada"
addc "$p" docs/audora/specs/d-escopo.md 'Sem critério citado.'
runc "$p" varrer
assert_line "$(secao "$out" 'spec de nó entregue')" '- docs/audora/specs/d-escopo.md | nó d delivered' "memoria-integra/4 spec sem critério segue no lote"
p="$SP/c4b"; mk4 "$p"
git -C "$p" rm -q docs/audora/arquivo/2026-01-01-d.md; git -C "$p" commit -qm "sem arquivo"
runc "$p" varrer
assert_line "$(secao "$out" 'mantido')" '- docs/audora/specs/d-escopo.md | mantido: cita d/1, d/2 sem cópia no nó arquivado' "memoria-integra/4 nó arquivado ausente: nenhum critério tem cópia"
p="$SP/c4c"; mk4 "$p"
addc "$p" docs/audora/arquivo/2026-01-01-d-historico.md '- **d/2** — QUANDO a O SISTEMA DEVE b'
runc "$p" varrer
assert_line "$(secao "$out" 'spec de nó entregue')" '- docs/audora/specs/d-escopo.md | nó d delivered' "memoria-integra/4 critério no -historico conta como cópia"
p="$SP/c4d"; mk4 "$p"
perl -i -pe 's/ D → .*$/ D/' "$p/MEMORY.md"; git -C "$p" commit -qam "sem seta"
runc "$p" varrer
assert_line "$(secao "$out" 'mantido')" '- docs/audora/specs/d-escopo.md | mantido: cita d/2 sem cópia no nó arquivado' "memoria-integra/4 sem seta: acha o nó em arquivo/ pelo id"
assert_contains "$(achata skills/cleanup/SKILL.md)" 'spec, plano arquivado ou relatório e2e que cita critério `<id>/<n>` sem cópia no nó arquivado' "memoria-integra/4 skill explica o mantido por critério"

# /12 — arquivo que o framework lê nunca entra no lote; aplicar recusa lote à mão que o traga
lote_de() { local a="$1"; shift; printf '%s\n' 'cleanup: relatório — nada foi alterado' "$@" > "$a"; }
mk12() {
  local p="$1"; mkproj "$p"
  printf -- '- v | in-progress | V | r | k | —\n' >> "$p/MEMORY.md"
  printf -- '---\nid: v\nestado: in-progress\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-01-01\n---\n# v\n' > "$p/docs/audora/memory/v.md"
  mkdir -p "$p/docs/audora/depuracao"; printf '# velha\n' > "$p/docs/audora/depuracao/velha.md"
  printf '# Aprendizados\n\n- 2026-01-01 | execute | A1 x\n' > "$p/docs/audora/aprendizados.md"
  git -C "$p" add -A; git -C "$p" commit -qm c12
}
p="$SP/c12"; mk12 "$p"
runc "$p" varrer
assert_not_contains "$out" 'aprendizados.md' "memoria-integra/12 varrer não lista aprendizados.md"
for caso in 'sem referência|docs/audora/aprendizados.md|arquivo lido pelo framework nunca é removido' \
            'spec de nó entregue|docs/audora/memory/v.md|arquivo lido pelo framework nunca é removido' \
            'plano arquivado|MEMORY.md|fora de docs/audora/'; do
  sec="${caso%%|*}"; r="${caso#*|}"; alvo="${r%%|*}"; mot="${r#*|}"
  p="$SP/c12-$sec"; mk12 "$p"
  lote_de "$SP/lote12.txt" '## depuração velha' '- docs/audora/depuracao/velha.md | sem nó vivo ligado' "## $sec" "- $alvo | x"
  antes="$(snap "$p")"
  runc "$p" aplicar "$SP/lote12.txt"
  assert_eq 1 "$code" "memoria-integra/12 aplicar recusa $alvo → exit 1"
  assert_contains "$out" "cleanup: falhou em: - $alvo | x — $mot" "memoria-integra/12 aplicar recusa $alvo → $mot"
  assert_eq "$antes" "$(snap "$p")" "memoria-integra/12 $alvo → nada aplicado"
done

# /13 — princípio declarado na skill, com red flag
cs="$(achata skills/cleanup/SKILL.md)"
assert_contains "$cs" 'só sai o que não é mais usado: nunca arquivo que o framework lê nem conteúdo que afeta aprendizado ou critério sem outra cópia viva' "memoria-integra/13 princípio na skill"
assert_contains "$(grep -E '^\| "' skills/cleanup/SKILL.md)" 'sem outra cópia viva' "memoria-integra/13 red flag do princípio"
assert_contains "$cs" 'planned órfão aprovado segue apagando o próprio nó' "memoria-integra/13 órfão aprovado segue apagando o nó"

# /19 — docs/audora/aprendizados.md fora da varredura e da troca de links
sumiu() {
  local d="$1" f; shift
  for f in "$@"; do mkdir -p "$(dirname "$d/$f")"; printf 'existiu\n' > "$d/$f"; git -C "$d" add -- "$f"; done
  git -C "$d" commit -qm "existiu: $*"; git -C "$d" rm -q -- "$@"; git -C "$d" commit -qm "sumiu: $*"
}
p="$SP/c19"; mkproj "$p"; sumiu "$p" docs/audora/specs/velha.md
addc "$p" docs/audora/notas/n.md '# nota'
addc "$p" docs/audora/aprendizados.md '- 2026-01-01 | execute | ver [v](specs/velha.md), `docs/audora/x/nunca.md` e notas/n.md'
runc "$p" varrer
assert_eq 'cleanup: nada a limpar' "$out" "memoria-integra/19 varrer → nada a limpar (sem link quebrado, nunca existiu nem sem referência)"
addc "$p" docs/audora/specs/d-escopo.md '# spec d'
printf -- '- 2026-01-02 | plan | contexto em [s](specs/d-escopo.md)\n' >> "$p/docs/audora/aprendizados.md"
git -C "$p" commit -qam "aprendizado cita a spec"
runc "$p" varrer; printf '%s\n' "$out" > "$SP/lote19.txt"
assert_line "$out" '- docs/audora/specs/d-escopo.md | nó d delivered' "memoria-integra/19 spec de d no lote"
runc "$p" aplicar "$SP/lote19.txt"
assert_eq 0 "$code" "memoria-integra/19 aplicar → 0"
assert_eq "$(git -C "$p" show HEAD~1:docs/audora/aprendizados.md)" "$(cat "$p/docs/audora/aprendizados.md")" "memoria-integra/19 aprendizados.md intocado pelo aplicar"
assert_not_contains "$(git -C "$p" show --name-only --format= HEAD)" 'aprendizados.md' "memoria-integra/19 commit da cleanup sem aprendizados.md"
assert_contains "$(achata skills/cleanup/SKILL.md)" 'fora da seção Aprendizados e de `docs/audora/aprendizados.md`' "memoria-integra/19 skill cita a exceção"

# /14 — registrar-aprendizado grava em docs/audora/aprendizados.md, nunca no MEMORY.md
P='Aprendizados vivem em `docs/audora/aprendizados.md` (1 linha cada, só por grep — skill memory, registrar-aprendizado).'
op5="$(tr -d '\r' < skills/memory/SKILL.md | awk '/^### 5\./{on=1} on && /^## /{on=0} on' | tr '\n' ' ' | tr -s ' ')"
assert_contains "$op5" '1 linha no fim de `docs/audora/aprendizados.md` (sem o arquivo, crie-o por `templates/aprendizados-template.md`), nunca no `MEMORY.md`' "memoria-integra/14 registrar-aprendizado grava em aprendizados.md"
assert_not_contains "$op5" '1 linha na seção `## Aprendizados` do `MEMORY.md`' "memoria-integra/14 registrar-aprendizado não grava no MEMORY"
assert_contains "$op5" "grep -si '<termo>' docs/audora/aprendizados.md MEMORY.md" "memoria-integra/14 dedupe busca nos dois arquivos"
assert_file templates/aprendizados-template.md "memoria-integra/14 template do arquivo de aprendizados"
assert_eq '# Aprendizados' "$(head -1 templates/aprendizados-template.md 2>/dev/null | tr -d '\r')" "memoria-integra/14 template linha 1"
assert_contains "$(cat templates/aprendizados-template.md 2>/dev/null)" '`- AAAA-MM-DD | <fase> | <aprendizado em 1 frase>`' "memoria-integra/14 template traz o formato"
assert_eq 0 "$(grep -cE '^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| ' templates/aprendizados-template.md 2>/dev/null)" "memoria-integra/14 template sem aprendizado de exemplo"
# /17 — bootstrap: seção Aprendizados só com o ponteiro, sem criar aprendizados.md
assert_eq "$P" "$(tr -d '\r' < templates/MEMORY-template.md | awk '/^## Aprendizados/{on=1; next} on && /^## /{on=0} on && NF')" "memoria-integra/17 seção Aprendizados do template = só o ponteiro"
assert_contains "$(achata skills/memory/references/bootstrap.md)" 'seção Aprendizados só com a linha de ponteiro do template, sem criar `docs/audora/aprendizados.md`' "memoria-integra/17 bootstrap não cria aprendizados.md"
b="$SP/boot"; mkdir -p "$b"; cp templates/MEMORY-template.md "$b/MEMORY.md"
run_hook memory-validate "$b/MEMORY.md"
assert_eq 0 "$code" "memoria-integra/17 MEMORY do bootstrap válido"
assert_no_file "$b/docs/audora/aprendizados.md" "memoria-integra/17 bootstrap sem aprendizados.md"

# /15 — carregar-contexto busca em aprendizados.md e no MEMORY.md, sem invalidados, sem erro se faltar
cc="$(tr -d '\r' < skills/memory/SKILL.md | awk '/^### 1\. carregar-contexto/{on=1; next} on && /^### /{on=0} on')"
cmds() { printf '%s' "$cc" | grep -oE "\`$1 '[^\`]*\`" | tr -d '\`'; }
c_porta="$(cmds 'grep -shiE' | sed -n 1p)"; c_fase="$(cmds 'grep -shiE' | sed -n 2p)"
assert_contains "$c_porta" 'docs/audora/aprendizados.md MEMORY.md' "memoria-integra/15 comando da porta lê os dois arquivos"
assert_contains "$c_fase" 'docs/audora/aprendizados.md MEMORY.md' "memoria-integra/15 comando das fases lê os dois arquivos"
sub_fase()  { local c="${c_fase//"<fase>"/"$1"}"; printf '%s' "${c//"<termo>|<termo>"/"$2"}"; }
sub_porta() { printf '%s' "${c_porta//"<termo>|<termo>"/"$1"}"; }
roda()      { (cd "$1" && bash -c "$2" 2>&1) | tr -d '\r'; }
ids_apr()   { sed -E 's/^- [0-9-]{10} \| [a-z0-9]+ \| ([A-Z0-9]+) .*/\1/' | tr '\n' ' ' | sed 's/ $//'; }
memp() { # memp <dir> [linhas de aprendizado no MEMORY...]
  local d="$1"; shift; mkdir -p "$d/docs/audora"
  printf '%s\n' 'memory-schema: 1' '' '## Propósito [carga: sempre]' '' 'x' '' '## Constituição [carga: sempre]' '' '- **stack**: x' '' \
    '## Aprendizados [carga: sempre]' '' "$P" "$@" '' '## Índice de nós [carga: sempre]' '' '- z | planned | Z | r | k | —' > "$d/MEMORY.md"
}
memp "$SP/fa"; printf '%s\n' '# Aprendizados' '' '- 2026-01-01 | plan | A1 cache' '- 2026-01-02 | plan | A2 nada' \
  '- 2026-01-03 | plan | A3 cache [invalidado-em: 2026-02-01] [substituido-por: A1]' > "$SP/fa/docs/audora/aprendizados.md"
memp "$SP/fb" '- 2026-01-04 | execute | M1 cache'; printf '%s\n' '# Aprendizados' '' '- 2026-01-01 | plan | A1 cache' > "$SP/fb/docs/audora/aprendizados.md"
memp "$SP/fc"
mkdir -p "$SP/facr/docs/audora"
for f in MEMORY.md docs/audora/aprendizados.md; do perl -pe 's/\n/\r\n/' "$SP/fa/$f" > "$SP/facr/$f"; done
for d in fa facr; do
  o_plan="$(roda "$SP/$d" "$(sub_fase plan 'cache|deploy')")"; o_porta="$(roda "$SP/$d" "$(sub_porta 'cache|deploy')")"
  assert_eq 'A1 A2' "$(printf '%s\n' "$o_plan" | ids_apr)" "memoria-integra/15 $d plan → A1 A2"
  assert_eq 'A1' "$(printf '%s\n' "$o_porta" | ids_apr)" "memoria-integra/15 $d porta → A1"
  assert_not_contains "$o_plan$o_porta" 'A3' "memoria-integra/15 $d sem invalidado"
done
assert_eq 'A1 M1' "$(roda "$SP/fb" "$(sub_fase execute cache)" | ids_apr)" "memoria-integra/15 fb execute → aprendizados.md e depois MEMORY"
assert_eq '' "$(roda "$SP/fc" "$(sub_fase plan cache)")" "memoria-integra/15 fc sem aprendizados.md: fases → vazio, sem erro"
assert_eq '' "$(roda "$SP/fc" "$(sub_porta cache)")" "memoria-integra/15 fc sem aprendizados.md: porta → vazio, sem erro"
ccf="$(printf '%s' "$cc" | tr '\n' ' ' | tr -s ' ')"
assert_contains "$ccf" 'nada casou → seguir sem aprendizados, sem ler a seção' "memoria-integra/15 nada casou segue"
assert_contains "$ccf" 'arquivo ausente não é erro' "memoria-integra/15 arquivo ausente não é erro"

report
