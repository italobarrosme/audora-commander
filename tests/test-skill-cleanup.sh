#!/usr/bin/env bash
# skill-cleanup/1..16 — hooks/cleanup (varrer/contar/aplicar), skill cleanup e sugestão no sync da validate.
# cleanup-alvo-ausente/1..10 — alvo ausente só se o caminho existiu no histórico do HEAD.
# cleanup-lote-encadeado/1..3 — aplicar não falha quando um item do lote cita outro item do lote.
# cleanup-link-preciso/1..13 — link para caminho nunca versionado vira aviso fora do lote; nota própria do link quebrado; Aprendizados fora.
# cleanup-commit-curto/1..4 — corpo do commit com linhas de até 100 caracteres (commit-msg tipo commitlint).
source "$(dirname "$0")/lib.sh"
C="$ROOT/hooks/cleanup"

# --- fixtures: repo git real por cenário ---
# mkproj <dir> — MEMORY válido com 1 nó delivered, arquivo do nó, decisões vivas, README e commit base
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
# addc <dir> <caminho> <conteúdo> — escreve, git add e commit
addc() { mkdir -p "$(dirname "$1/$2")"; printf '%s\n' "$3" > "$1/$2"; git -C "$1" add -- "$2"; git -C "$1" commit -qm "add $2"; }
# sumiu <dir> <caminho>... — cada caminho é versionado e depois removido (alvo de link quebrado de verdade)
sumiu() {
  local d="$1" f; shift
  for f in "$@"; do mkdir -p "$(dirname "$d/$f")"; printf 'existiu\n' > "$d/$f"; git -C "$d" add -- "$f"; done
  git -C "$d" commit -qm "existiu: $*"; git -C "$d" rm -q -- "$@"; git -C "$d" commit -qm "sumiu: $*"
}
# runc <dir> <args…> — roda o script na raiz do projeto; define out (stdout+stderr) e code
runc() { local d="$1"; shift; out="$(cd "$d" && bash "$C" "$@" 2>&1)"; code=$?; }
# snap <dir> — HEAD + status + md5 da árvore (fora do .git): "estado igual"
snap() {
  ( cd "$1" && git rev-parse HEAD && git status --porcelain && \
    find . -path ./.git -prune -o -type f -print | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done )
}

# --- uso ---
p="$SP/uso"; mkproj "$p"
runc "$p"
assert_eq 1 "$code" "uso sem argumento → exit 1"
assert_contains "$out" 'uso: cleanup varrer' "uso sem argumento imprime o uso"
runc "$p" faxinar
assert_eq 1 "$code" "uso subcomando desconhecido → exit 1"
assert_contains "$out" 'uso: cleanup varrer [--orfao <id>=<motivo>]... | contar | aplicar <lote>' "uso completo"

# --- skill-cleanup/2 sem MEMORY recusa ---
p="$SP/semmem"; rm -rf "$p"; mkdir -p "$p"; git -C "$p" init -q
git -C "$p" config core.excludesFile "$p/.nao-existe"; printf 'x\n' > "$p/a.txt"
antes="$(git -C "$p" status --porcelain)"
runc "$p" varrer
assert_eq 1 "$code" "skill-cleanup/2 sem MEMORY varrer → exit 1"
assert_contains "$out" 'cleanup: sem MEMORY.md — rode o bootstrap da skill memory; nada foi alterado' "skill-cleanup/2 sem MEMORY aponta o bootstrap"
assert_eq "$antes" "$(git -C "$p" status --porcelain)" "skill-cleanup/2 sem MEMORY nada alterado"
runc "$p" contar
assert_eq 1 "$code" "skill-cleanup/2 sem MEMORY contar → exit 1"
assert_contains "$out" 'cleanup: sem MEMORY.md — rode o bootstrap da skill memory; nada foi alterado' "skill-cleanup/2 contar sem MEMORY"
p="$SP/semgit"; rm -rf "$p"; mkdir -p "$p"; printf 'memory-schema: 1\n' > "$p/MEMORY.md"
runc "$p" varrer
assert_eq 1 "$code" "skill-cleanup/2 sem git → exit 1"
assert_contains "$out" 'cleanup: não é repositório git — nada foi alterado' "skill-cleanup/2 sem git recusa"

# --- skill-cleanup/15 nada a limpar ---
p="$SP/limpo"; mkproj "$p"
runc "$p" varrer
assert_eq 0 "$code" "skill-cleanup/15 nada a limpar → exit 0"
assert_eq 'cleanup: nada a limpar' "$out" "skill-cleanup/15 saída é só 'nada a limpar'"
assert_eq 1 "$(git -C "$p" rev-list --count HEAD)" "skill-cleanup/15 nada commitado"
runc "$p" contar
assert_eq 0 "$code" "skill-cleanup/15 contar → exit 0"
assert_eq 0 "$out" "skill-cleanup/15 contar → 0"

# --- fixture T2: nó vivo v + artefatos de d (delivered) e de v (vivo) ---
# assert_line <texto> <linha exata> <msg>
assert_line()    { printf '%s\n' "$1" | grep -qxF -- "$2" && ok || ko "$3 — sem a linha '$2'"; }
assert_no_line() { printf '%s\n' "$1" | grep -qxF -- "$2" && ko "$3 — tem a linha '$2'" || ok; }
# secao <texto> <título> — itens sob '## <título>' até a próxima seção
secao() { printf '%s\n' "$1" | awk -v t="## $2" '$0==t {on=1; next} /^## |^total:|^cleanup:/ {on=0} on'; }
# nov <dir> <id> <estado> <deps> [corpo] — arquivo de nó em docs/audora/memory (sem commit)
nov() {
  mkdir -p "$1/docs/audora/memory"
  printf -- '---\nid: %s\nestado: %s\norigem: humano\ndepende-de: [%s]\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-01-01\n---\n# %s\n\n%s\n' "$2" "$3" "$4" "$2" "${5:-}" > "$1/docs/audora/memory/$2.md"
}
mkt2() {
  local d="$1" f; mkproj "$d"
  printf -- '- v | in-progress | V | r | k | —\n' >> "$d/MEMORY.md"
  nov "$d" v in-progress '' 'Caçada ligada: docs/audora/depuracao/cacada-2026-02-02.md'
  for f in specs/d-escopo.md specs/v-escopo.md planos/arquivo/plano-d.md planos/plano-v.md \
           e2e/e2e-d.md e2e/e2e-v.md depuracao/cacada-2026-01-01.md depuracao/cacada-2026-02-02.md; do
    mkdir -p "$(dirname "$d/docs/audora/$f")"; printf '# %s\n' "$f" > "$d/docs/audora/$f"
  done
  git -C "$d" add -A; git -C "$d" commit -qm t2
}

# --- skill-cleanup/7 artefatos de nó entregue e depuração velha ---
p="$SP/t2"; mkt2 "$p"
antes="$(snap "$p")"
runc "$p" varrer
assert_eq 0 "$code" "skill-cleanup/7 varrer → exit 0"
assert_eq '## spec de nó entregue;## plano arquivado;## relatório e2e;## depuração velha;' \
  "$(printf '%s\n' "$out" | grep '^## ' | tr '\n' ';')" "skill-cleanup/1 seções agrupadas por tipo, na ordem"
assert_line "$out" '- docs/audora/specs/d-escopo.md | nó d delivered' "skill-cleanup/7 spec de nó entregue"
assert_line "$out" '- docs/audora/planos/arquivo/plano-d.md | nó d delivered' "skill-cleanup/7 plano arquivado"
assert_line "$out" '- docs/audora/e2e/e2e-d.md | nó d delivered' "skill-cleanup/7 relatório e2e"
assert_line "$out" '- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado' "skill-cleanup/7 depuração velha"
assert_line "$(secao "$out" 'spec de nó entregue')" '- docs/audora/specs/d-escopo.md | nó d delivered' "skill-cleanup/7 spec sob a seção certa"
assert_line "$(secao "$out" 'depuração velha')" '- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado' "skill-cleanup/7 depuração sob a seção certa"
for n in specs/v-escopo.md plano-v.md e2e-v.md cacada-2026-02-02.md; do
  assert_not_contains "$out" "$n" "skill-cleanup/7 artefato de nó vivo/ligado fora: $n"
done
assert_eq 'cleanup: relatório — nada foi alterado' "$(printf '%s\n' "$out" | head -1)" "skill-cleanup/1 1ª linha do relatório"
assert_eq 'total: 4 item(ns) no lote' "$(printf '%s\n' "$out" | tail -1)" "skill-cleanup/1 última linha = total"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/1 varrer não altera nenhum arquivo nem o git"
runc "$p" contar
assert_eq 4 "$out" "skill-cleanup/7 contar → 4"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/1 contar não altera nada"

# --- skill-cleanup/8 sem referência (só documento vivo conta; arquivo/ não conta) ---
p="$SP/t3"; mkt2 "$p"
for n in solta citada viva so-arquivo da-skill da-claude do-prd do-no do-ptbr; do
  mkdir -p "$p/docs/audora/notas"; printf '# %s\n' "$n" > "$p/docs/audora/notas/$n.md"
done
mkdir -p "$p/docs/specs" "$p/skills/x" "$p/.claude/skills/y"; printf '# fora\n' > "$p/docs/specs/fora.md"
printf '# proj\n\nVer docs/audora/notas/citada.md.\n' > "$p/README.md"
printf '# Decisões vivas\n\n- ver viva.md\n' > "$p/docs/audora/decisoes-vivas.md"
printf '\nCitado: docs/audora/notas/so-arquivo.md\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
printf '# x\n\nda-skill.md\n' > "$p/skills/x/SKILL.md"
printf '# y\n\nda-claude.md\n' > "$p/.claude/skills/y/SKILL.md"
printf '# PRD\n\ndo-prd.md\n' > "$p/PRD.md"
printf '# pt\n\ndo-ptbr.md\n' > "$p/README.pt-BR.md"
printf '\nNota: do-no.md\n' >> "$p/docs/audora/memory/v.md"
git -C "$p" add -A; git -C "$p" commit -qm t3
runc "$p" varrer
sr="$(secao "$out" 'sem referência')"
assert_line "$sr" '- docs/audora/notas/solta.md | nenhum documento vivo o cita' "skill-cleanup/8 arquivo sem citação listado"
assert_line "$sr" '- docs/audora/notas/so-arquivo.md | nenhum documento vivo o cita' "skill-cleanup/8 citado só em nó arquivado conta como sem referência"
for n in citada.md viva.md da-skill.md da-claude.md do-prd.md do-no.md do-ptbr.md docs/specs/fora.md '2026-01-01-d.md |' 'decisoes-vivas.md |' 'v.md |' plano-v.md; do
  assert_not_contains "$out" "$n" "skill-cleanup/8 não lista $n"
done
assert_eq 'total: 6 item(ns) no lote' "$(printf '%s\n' "$out" | tail -1)" "skill-cleanup/8 total soma os sem referência"

# --- skill-cleanup/10 detecta link quebrado (fora de frontmatter, fence e nota) ---
# corpo_d <dir> — nó arquivado d com as formas reais de link (frontmatter, corpo, fence, nota)
corpo_d() {
  sumiu "$1" docs/audora/e2e/nao-existe.md docs/audora/specs/sumiu.md
  cat > "$1/docs/audora/arquivo/2026-01-01-d.md" <<'EOF'
---
id: d
estado: delivered
origem: humano
depende-de: []
arquivos: [docs/audora/planos/plano-d.md]
keywords: []
resumo: r
atualizado-em: 2026-01-01
---
# d

L1 [r](../e2e/nao-existe.md) quebrado
L2 Ver `docs/audora/specs/sumiu.md` aqui.
L3 [n](../e2e/nunca.md) e `docs/audora/specs/nunca-token.md`
L4 [fora](../../../../fora.md)
```
docs/audora/x/sumiu-fence.md
```
[ok](../decisoes-vivas.md) e [w](https://x.y/z.md) e [a](../decisoes-vivas.md#topo) e [b](#topo) e [c](<x.md>)
`docs/audora/e2e/velho.md` removido em 2026-01-01 pela cleanup — recuperável no git
EOF
}
p="$SP/t4"; mkt2 "$p"; corpo_d "$p"; sumiu "$p" docs/audora/arquivo/sumiu.md
printf -- '- z | delivered | Z → docs/audora/arquivo/sumiu.md\n' >> "$p/MEMORY.md"
printf '# d-escopo\n\n[q](../nada/quebrado.md)\n' > "$p/docs/audora/specs/d-escopo.md"
git -C "$p" add -A; git -C "$p" commit -qm t4
L1="$(grep -n '^L1 ' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
L2="$(grep -n '^L2 ' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
LZ="$(grep -n '^- z |' "$p/MEMORY.md" | cut -d: -f1)"
runc "$p" varrer
lq="$(secao "$out" 'link quebrado')"
assert_line "$lq" "- docs/audora/arquivo/2026-01-01-d.md:$L1 | aponta ../e2e/nao-existe.md inexistente" "skill-cleanup/10 link markdown relativo quebrado"
assert_line "$lq" "- docs/audora/arquivo/2026-01-01-d.md:$L2 | aponta docs/audora/specs/sumiu.md inexistente" "skill-cleanup/10 token docs/audora com crases quebrado"
assert_line "$lq" "- MEMORY.md:$LZ | aponta docs/audora/arquivo/sumiu.md inexistente" "skill-cleanup/10 link quebrado no índice"
for n in plano-d.md sumiu-fence.md 'decisoes-vivas.md inexistente' 'z.md' '#topo' 'x.md inexistente' velho.md quebrado.md; do
  assert_not_contains "$lq" "$n" "skill-cleanup/10 não é link quebrado: $n"
done
assert_eq 3 "$(printf '%s\n' "$lq" | grep -c '^- ')" "skill-cleanup/10 exatamente 3 links quebrados"
assert_eq 'total: 7 item(ns) no lote' "$(printf '%s\n' "$out" | tail -1)" "skill-cleanup/10 total inclui os links quebrados"
# cleanup-link-preciso/1,2,3 — alvo nunca versionado vai para '## nunca existiu', fora do lote e do total
L3="$(grep -n '^L3 ' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
L4="$(grep -n '^L4 ' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
ne="$(secao "$out" 'nunca existiu')"
assert_line "$ne" "- docs/audora/arquivo/2026-01-01-d.md:$L3 | aponta ../e2e/nunca.md nunca versionado" "cleanup-link-preciso/1 link markdown nunca versionado"
assert_line "$ne" "- docs/audora/arquivo/2026-01-01-d.md:$L3 | aponta docs/audora/specs/nunca-token.md nunca versionado" "cleanup-link-preciso/1 token nunca versionado"
assert_line "$ne" "- docs/audora/arquivo/2026-01-01-d.md:$L4 | aponta ../../../../fora.md nunca versionado" "cleanup-link-preciso/1 caminho acima da raiz = nunca existiu"
assert_eq 3 "$(printf '%s\n' "$ne" | grep -c '^- ')" "cleanup-link-preciso/1 exatamente 3 em nunca existiu"
assert_not_contains "$lq" 'nunca' "cleanup-link-preciso/2 link quebrado só com alvo que existiu"
assert_not_contains "$lq" 'fora.md' "cleanup-link-preciso/2 caminho acima da raiz fora do link quebrado"
assert_eq '## spec de nó entregue;## plano arquivado;## relatório e2e;## depuração velha;## link quebrado;## nunca existiu;' \
  "$(printf '%s\n' "$out" | grep '^## ' | tr '\n' ';')" "cleanup-link-preciso/1 nunca existiu depois das seções do lote"
assert_not_contains "$out" 'fatal' "cleanup-link-preciso/1 caminho acima da raiz não chama o git"
runc "$p" contar
assert_eq 7 "$out" "cleanup-link-preciso/3 contar = total do varrer, sem nunca existiu"
# cleanup-link-preciso/4 lote vazio com só nunca existiu → avisos e 'nada a limpar'
p="$SP/t4n"; mkproj "$p"
printf '\n[n](../e2e/nunca.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"; git -C "$p" commit -qam nunca
LN="$(grep -n 'nunca' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
runc "$p" varrer
assert_eq 0 "$code" "cleanup-link-preciso/4 varrer → exit 0"
assert_eq "## nunca existiu
- docs/audora/arquivo/2026-01-01-d.md:$LN | aponta ../e2e/nunca.md nunca versionado
cleanup: nada a limpar" "$out" "cleanup-link-preciso/4 só avisos e nada a limpar"
runc "$p" contar
assert_eq 0 "$out" "cleanup-link-preciso/4 contar → 0"

# --- skill-cleanup/3,4,5 planned órfão (--orfao e alvo ausente) e mantido ---
# mkt5 <dir> — planned p q r r2 s; v (vivo) depende de r2; d (arquivado) depende de s
mkt5() {
  local d="$1"; mkproj "$d"
  printf -- '%s\n' '- p | planned | P | r | k | —' '- q | planned | Q | r | k | src/sumiu.ts, README.md' \
    '- r | planned | R | r | k | —' '- r2 | planned | R2 | r | k | src/nada.ts' '- s | planned | S | r | k | —' \
    '- v | in-progress | V | r | k | —' >> "$d/MEMORY.md"
  nov "$d" v in-progress 'r2'
  sed -i 's/^depende-de: \[\]/depende-de: [s]/' "$d/docs/audora/arquivo/2026-01-01-d.md"
  addc "$d" src/sumiu.ts x; addc "$d" src/nada.ts x; git -C "$d" rm -q src/sumiu.ts src/nada.ts
  git -C "$d" add -A; git -C "$d" commit -qm t5
}
p="$SP/t5"; mkt5 "$p"
runc "$p" varrer --orfao 'p=absorvido por d'
po="$(secao "$out" 'planned órfão')"
assert_eq 0 "$code" "skill-cleanup/3 varrer --orfao → exit 0"
assert_line "$po" '- p | absorvido por d' "skill-cleanup/3 planned absorvido cita o nó que o absorveu"
assert_line "$po" '- q | alvo ausente: src/sumiu.ts' "skill-cleanup/4 planned com alvo ausente cita o alvo"
assert_not_contains "$po" 'README.md' "skill-cleanup/4 alvo existente não entra no motivo"
assert_not_contains "$po" '- r |' "skill-cleanup/3 planned sem --orfao e sem alvo ausente fica fora"
runc "$p" varrer
po="$(secao "$out" 'planned órfão')"
assert_not_contains "$po" '- p |' "skill-cleanup/3 sem --orfao o semântico não é listado"
assert_line "$po" '- q | alvo ausente: src/sumiu.ts' "skill-cleanup/4 mecânico sem --orfao"
assert_line "$(secao "$out" 'mantido')" '- r2 | mantido: v depende dele' "skill-cleanup/5 órfão mecânico com dependente vivo é mantido"
runc "$p" varrer --orfao 'r2=absorvido por d'
assert_line "$(secao "$out" 'mantido')" '- r2 | mantido: v depende dele' "skill-cleanup/5 --orfao com dependente vivo → mantido"
assert_not_contains "$(secao "$out" 'planned órfão')" 'r2' "skill-cleanup/5 mantido fica fora do lote"
runc "$p" varrer --orfao 's=absorvido por d'
assert_line "$(secao "$out" 'planned órfão')" '- s | absorvido por d' "skill-cleanup/5 dependente arquivado não segura o órfão"
runc "$p" varrer --orfao 'q=absorvido por d'
po="$(secao "$out" 'planned órfão')"
assert_line "$po" '- q | absorvido por d' "skill-cleanup/3 motivo do --orfao prevalece sobre o mecânico"
assert_eq 1 "$(printf '%s\n' "$po" | grep -c '^- q |')" "skill-cleanup/3 id aparece uma vez só"
runc "$p" varrer --orfao 'd=x'
assert_eq 'aviso: --orfao d ignorado — não é planned no índice' "$(printf '%s\n' "$out" | head -1)" "skill-cleanup/3 --orfao de nó não planned avisa antes do relatório"
assert_not_contains "$(secao "$out" 'planned órfão')" '- d |' "skill-cleanup/3 nó não planned fora do lote"
runc "$p" varrer --orfao p
assert_eq 1 "$code" "skill-cleanup/3 --orfao sem <id>=<motivo> → uso, exit 1"
assert_contains "$out" 'uso: cleanup varrer' "skill-cleanup/3 --orfao malformado imprime o uso"
runc "$p" contar
assert_eq 1 "$out" "skill-cleanup/4 contar conta só o mecânico (q)"

# --- cleanup-alvo-ausente/1..8 alvo ausente só se existiu no HEAD ---
# mkalvo <dir> — caminhos que existiram e sumiram (direto, sob pasta, em branch mergeada),
# só em branch não alcançável, nunca criados e presentes; v (vivo) depende do nunca-existiu
mkalvo() {
  local d="$1"; mkproj "$d"
  addc "$d" src/velho.ts x; addc "$d" lib/antigo/x.ts x; addc "$d" app/s/page.tsx x
  git -C "$d" rm -q src/velho.ts lib/antigo/x.ts app/s/page.tsx; git -C "$d" commit -qm sumiram
  git -C "$d" checkout -q -b outro; addc "$d" src/ramo.ts x; git -C "$d" checkout -q -
  git -C "$d" checkout -q -b feat; addc "$d" src/feat.ts x
  git -C "$d" rm -q src/feat.ts; git -C "$d" commit -qm 'feat sumiu'; git -C "$d" checkout -q -
  git -C "$d" merge -q --no-ff feat -m merge
  printf -- '%s\n' '- nunca | planned | N | r | k | src/futuro.ts' '- sumiu | planned | S | r | k | src/velho.ts' \
    '- misto | planned | M | r | k | src/velho.ts, src/futuro.ts, README.md, lib/antigo/' \
    '- pasta | planned | P | r | k | lib/antigo/' '- pastanova | planned | PN | r | k | lib/nova/' \
    '- ramo | planned | R | r | k | src/ramo.ts' '- fundido | planned | F | r | k | src/feat.ts' \
    '- presente | planned | PR | r | k | README.md' '- slug | planned | SL | r | k | app/[slug]/page.tsx' \
    '- v | in-progress | V | r | k | —' >> "$d/MEMORY.md"
  nov "$d" v in-progress 'nunca'
  git -C "$d" add -A; git -C "$d" commit -qm alvo
}
p="$SP/alvo"; mkalvo "$p"
runc "$p" varrer
assert_eq 0 "$code" "cleanup-alvo-ausente/1 varrer → exit 0"
assert_eq "$(printf '%s\n' 'cleanup: relatório — nada foi alterado' '## planned órfão' \
  '- fundido | alvo ausente: src/feat.ts' '- misto | alvo ausente: src/velho.ts, lib/antigo/' \
  '- pasta | alvo ausente: lib/antigo/' '- sumiu | alvo ausente: src/velho.ts' 'total: 4 item(ns) no lote')" \
  "$out" "cleanup-alvo-ausente/1 relatório só com o que existiu e sumiu"
assert_not_contains "$out" 'nunca' "cleanup-alvo-ausente/1 nunca-existiu fora do relatório, nem em mantido"
assert_not_contains "$out" '- slug |' "cleanup-alvo-ausente/1 [slug] literal: glob não casa caminho que existiu"
po="$(secao "$out" 'planned órfão')"
assert_line "$po" '- sumiu | alvo ausente: src/velho.ts' "cleanup-alvo-ausente/2 existiu e sumiu → órfão"
assert_line "$po" '- fundido | alvo ausente: src/feat.ts' "cleanup-alvo-ausente/2 existiu em branch mergeada (alcançável)"
assert_line "$po" '- misto | alvo ausente: src/velho.ts, lib/antigo/' "cleanup-alvo-ausente/3 motivo só com os que existiram e sumiram"
assert_not_contains "$out" '- ramo |' "cleanup-alvo-ausente/4 só em branch não alcançável → fora"
assert_line "$po" '- pasta | alvo ausente: lib/antigo/' "cleanup-alvo-ausente/5 diretório com arquivo versionado sob ele"
assert_not_contains "$out" 'pastanova' "cleanup-alvo-ausente/5 diretório nunca versionado → fora"
assert_not_contains "$out" 'presente' "cleanup-alvo-ausente/6 caminho existente no disco → fora"
runc "$p" varrer --orfao 'pastanova=alvo ausente: lib/nova/'
assert_line "$(secao "$out" 'planned órfão')" '- pastanova | alvo ausente: lib/nova/' "cleanup-alvo-ausente/7 --orfao lista mesmo caminho que nunca existiu"
assert_eq 'total: 5 item(ns) no lote' "$(printf '%s\n' "$out" | tail -1)" "cleanup-alvo-ausente/7 total com o --orfao"
runc "$p" contar
assert_eq 0 "$code" "cleanup-alvo-ausente/8 contar → exit 0"
assert_eq 4 "$out" "cleanup-alvo-ausente/8 contar = total do varrer"

# --- cleanup-alvo-ausente/9 repositório sem commit ---
p="$SP/semcommit"; rm -rf "$p"; mkdir -p "$p"; git -C "$p" init -q; git -C "$p" config core.excludesFile "$p/.nao-existe"
printf 'memory-schema: 1\n\n## Propósito [carga: sempre]\n\nx\n\n## Constituição [carga: sempre]\n\n- **stack**: x\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n- x | planned | X | r | k | src/x.ts\n' > "$p/MEMORY.md"
runc "$p" varrer
assert_eq 0 "$code" "cleanup-alvo-ausente/9 sem commit varrer → exit 0"
assert_eq 'cleanup: nada a limpar' "$out" "cleanup-alvo-ausente/9 sem commit: caminho ausente = nunca existiu, sem erro"
runc "$p" contar
assert_eq 0 "$code" "cleanup-alvo-ausente/9 sem commit contar → exit 0"
assert_eq 0 "$out" "cleanup-alvo-ausente/9 sem commit contar → 0"
# cleanup-link-preciso/11 sem commit: todo link para caminho inexistente vai para nunca existiu, sem erro
printf -- '- z | delivered | Z → docs/audora/arquivo/sumiu.md\n' >> "$p/MEMORY.md"
LZ="$(grep -n '^- z |' "$p/MEMORY.md" | cut -d: -f1)"
runc "$p" varrer
assert_eq 0 "$code" "cleanup-link-preciso/11 sem commit varrer → exit 0"
assert_eq "## nunca existiu
- MEMORY.md:$LZ | aponta docs/audora/arquivo/sumiu.md nunca versionado
cleanup: nada a limpar" "$out" "cleanup-link-preciso/11 sem commit: link vira nunca existiu"
runc "$p" contar
assert_eq 0 "$code" "cleanup-link-preciso/11 sem commit contar → exit 0"
assert_eq 0 "$out" "cleanup-link-preciso/11 sem commit contar → 0"

# --- skill-cleanup/11 não tocado: fora do git e mudança não commitada ---
p="$SP/t6"; mkt2 "$p"; sumiu "$p" docs/audora/e2e/nao-existe.md
printf '\n[p](../planos/arquivo/plano-d.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
git -C "$p" add -A; git -C "$p" commit -qm 'arquivo linka plano-d'
git -C "$p" rm -q --cached docs/audora/e2e/e2e-d.md; git -C "$p" commit -qm 'e2e-d fora do git'
printf 'docs/audora/tmp/\n' > "$p/.gitignore"; mkdir -p "$p/docs/audora/tmp"; printf '# x\n' > "$p/docs/audora/tmp/x.md"
printf '# editado\n' >> "$p/docs/audora/specs/d-escopo.md"
printf '[q](../e2e/nao-existe.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
LQ="$(grep -n 'nao-existe' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
printf '[n](../e2e/nunca.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
LN="$(grep -n 'nunca' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
mkdir -p "$p/docs/audora/notas"; printf '[c](../depuracao/cacada-2026-01-01.md)\n' > "$p/docs/audora/notas/rascunho.md"
antes="$(snap "$p")"
runc "$p" varrer; out_v="$out"
nt="$(secao "$out" 'não tocado')"
assert_line "$nt" '- docs/audora/e2e/e2e-d.md | não tocado: fora do git' "skill-cleanup/11 untracked → fora do git"
assert_not_contains "$(secao "$out" 'relatório e2e')" 'e2e-d.md' "skill-cleanup/11 untracked fora do lote"
assert_line "$nt" '- docs/audora/tmp/x.md | não tocado: fora do git' "skill-cleanup/11 ignorado → fora do git"
assert_line "$nt" '- docs/audora/specs/d-escopo.md | não tocado: mudança não commitada' "skill-cleanup/11 candidato sujo"
assert_line "$nt" '- docs/audora/planos/arquivo/plano-d.md | não tocado: mudança não commitada em docs/audora/arquivo/2026-01-01-d.md' "skill-cleanup/11 referente sujo segura o candidato"
assert_line "$nt" "- docs/audora/arquivo/2026-01-01-d.md:$LQ | não tocado: mudança não commitada" "skill-cleanup/11 link quebrado em arquivo sujo"
assert_line "$nt" '- docs/audora/notas/rascunho.md | não tocado: fora do git' "skill-cleanup/11 .md não rastreado é não tocado"
assert_line "$(secao "$out" 'depuração velha')" '- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado' "skill-cleanup/11 link em .md não rastreado não bloqueia"
for s in 'spec de nó entregue' 'plano arquivado' 'relatório e2e' 'sem referência' 'link quebrado'; do
  assert_empty "$(secao "$out" "$s")" "skill-cleanup/11 nada de não tocado em '$s'"
done
assert_eq 'total: 1 item(ns) no lote' "$(printf '%s\n' "$out" | tail -1)" "skill-cleanup/11 total não conta os não tocados"
runc "$p" contar
assert_eq 1 "$out" "skill-cleanup/11 contar não conta os não tocados"
assert_line "$(secao "$out_v" 'nunca existiu')" "- docs/audora/arquivo/2026-01-01-d.md:$LN | aponta ../e2e/nunca.md nunca versionado" "cleanup-link-preciso/4 nunca existiu ao lado de não tocado (arquivo sujo não segura o aviso)"
assert_eq 1 "$out" "cleanup-link-preciso/3 contar ignora nunca existiu com não tocado"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/11 varrer com árvore suja não altera nada"
p="$SP/t6m"; mkt5 "$p"; printf '\n' >> "$p/MEMORY.md"
runc "$p" varrer --orfao 'p=absorvido por d'
assert_line "$(secao "$out" 'não tocado')" '- p | não tocado: mudança não commitada em MEMORY.md' "skill-cleanup/11 planned com MEMORY.md sujo"
assert_empty "$(secao "$out" 'planned órfão')" "skill-cleanup/11 MEMORY sujo tira todo planned do lote"
assert_eq 'cleanup: nada a limpar' "$(printf '%s\n' "$out" | tail -1)" "skill-cleanup/11 lote vazio com só não tocados → nada a limpar"

# --- skill-cleanup/9,13 aplicar: apaga, troca link pela nota, 1 commit só com o lote ---
HOJE="$(date +%F)"
nota() { printf '`%s` removido em %s pela cleanup — recuperável no git' "$1" "$HOJE"; }
notaq() { printf '`%s` já não existia em %s (link limpo pela cleanup) — recuperável no git' "$1" "$HOJE"; }
p="$SP/t7"; mkt2 "$p"
sed -i 's|^arquivos: \[\]|arquivos: [docs/audora/e2e/e2e-d.md]|' "$p/docs/audora/arquivo/2026-01-01-d.md"
printf '\nRelatório: [rel](../e2e/e2e-d.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
git -C "$p" add -A; git -C "$p" commit -qm t7
printf 'o\n' > "$p/outro.txt"; git -C "$p" add outro.txt
runc "$p" varrer; printf '%s\n' "$out" > "$SP/lote7.txt"
n0="$(git -C "$p" rev-list --count HEAD)"
runc "$p" aplicar "$SP/lote7.txt"
assert_eq 0 "$code" "skill-cleanup/13 aplicar → exit 0"
assert_contains "$out" 'cleanup: commit ' "skill-cleanup/13 imprime o commit"
assert_contains "$out" '— 4 item(ns) removido(s)' "skill-cleanup/13 imprime a contagem"
assert_eq $((n0 + 1)) "$(git -C "$p" rev-list --count HEAD)" "skill-cleanup/13 exatamente 1 commit novo"
for f in specs/d-escopo.md planos/arquivo/plano-d.md e2e/e2e-d.md depuracao/cacada-2026-01-01.md; do
  assert_no_file "$p/docs/audora/$f" "skill-cleanup/9 apagado: $f"
done
assert_eq "docs/audora/arquivo/2026-01-01-d.md
docs/audora/depuracao/cacada-2026-01-01.md
docs/audora/e2e/e2e-d.md
docs/audora/planos/arquivo/plano-d.md
docs/audora/specs/d-escopo.md" "$(git -C "$p" show --name-only --format= HEAD | LC_ALL=C sort)" "skill-cleanup/13 commit só com os caminhos do lote"
assert_eq 'chore(cleanup): remove 4 sobra(s) do processo' "$(git -C "$p" show -s --format=%s HEAD)" "skill-cleanup/13 título do commit"
corpo="$(git -C "$p" show -s --format=%b HEAD)"
assert_line "$corpo" 'spec de nó entregue: docs/audora/specs/d-escopo.md' "skill-cleanup/13 corpo lista spec por tipo"
assert_line "$corpo" 'depuração velha: docs/audora/depuracao/cacada-2026-01-01.md' "skill-cleanup/13 corpo lista depuração por tipo"
assert_line "$corpo" 'relatório e2e: docs/audora/e2e/e2e-d.md' "skill-cleanup/13 corpo lista e2e por tipo"
assert_line "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" "Relatório: $(nota docs/audora/e2e/e2e-d.md)" "skill-cleanup/9 link trocado pela nota"
assert_not_contains "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" 'já não existia' "cleanup-link-preciso/8 arquivo apagado pelo lote mantém a nota 'removido'"
assert_line "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" 'arquivos: [docs/audora/e2e/e2e-d.md]' "skill-cleanup/9 frontmatter arquivos: inalterado"
assert_eq 'outro.txt' "$(git -C "$p" diff --cached --name-only)" "skill-cleanup/13 o que já estava staged segue staged"
assert_not_contains "$(git -C "$p" show --name-only --format= HEAD)" 'outro.txt' "skill-cleanup/13 staged alheio fora do commit"
assert_empty "$(git -C "$p" status --porcelain | grep -v '^A  outro.txt$')" "skill-cleanup/13 árvore limpa depois do commit"
run_hook memory-validate "$p/MEMORY.md"
assert_eq 0 "$code" "skill-cleanup/13 MEMORY válido depois do aplicar"
# skill-cleanup/12 lote sem item acionável (humano tirou todos) → nada aplicado
p="$SP/t7v"; mkt2 "$p"
printf '%s\n' 'cleanup: relatório — nada foi alterado' '## spec de nó entregue' '## mantido' '- v | mantido: x depende dele' 'total: 0 item(ns) no lote' > "$SP/lote7v.txt"
antes="$(snap "$p")"
runc "$p" aplicar "$SP/lote7v.txt"
assert_eq 0 "$code" "skill-cleanup/12 lote vazio → exit 0"
assert_eq 'cleanup: lote vazio — nada aplicado' "$out" "skill-cleanup/12 lote vazio nada aplicado"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/12 lote vazio não altera nem commita"
runc "$p" aplicar /nao/existe
assert_eq 1 "$code" "skill-cleanup/12 lote inexistente → exit 1"
assert_contains "$out" 'cleanup: lote /nao/existe não encontrado' "skill-cleanup/12 lote inexistente nomeado"
runc "$p" aplicar
assert_eq 1 "$code" "skill-cleanup/12 aplicar sem lote → uso"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/12 lote inexistente não altera nada"
# skill-cleanup/12 humano tira itens: só o que ficou no lote sai; mantido e não tocado intocados
printf '%s\n' 'cleanup: relatório — nada foi alterado' '## depuração velha' '- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado' \
  '## mantido' '- v | mantido: x depende dele' '## não tocado' '- docs/audora/specs/d-escopo.md | não tocado: mudança não commitada' \
  'total: 1 item(ns) no lote' > "$SP/lote7m.txt"
runc "$p" aplicar "$SP/lote7m.txt"
assert_eq 0 "$code" "skill-cleanup/12 lote aparado → exit 0"
assert_no_file "$p/docs/audora/depuracao/cacada-2026-01-01.md" "skill-cleanup/12 item aprovado saiu"
assert_file "$p/docs/audora/specs/d-escopo.md" "skill-cleanup/12 não tocado fica"
assert_file "$p/docs/audora/e2e/e2e-d.md" "skill-cleanup/12 item tirado pelo humano fica"
assert_contains "$(cat "$p/MEMORY.md")" '- v | in-progress |' "skill-cleanup/12 mantido fica no índice"
assert_eq 'docs/audora/depuracao/cacada-2026-01-01.md' "$(git -C "$p" show --name-only --format= HEAD)" "skill-cleanup/12 commit só com o item aprovado"

# --- skill-cleanup/6,10,13 aplicar: planned órfão sai do índice, link quebrado vira nota, MEMORY válido ---
# mkt8 <dir> — planned p (sem arquivo) e s (com arquivo, linkado por v); links quebrados L1/L2; MEMORY em CRLF
mkt8() {
  local d="$1"; mkproj "$d"; corpo_d "$d"
  printf -- '%s\n' '- p | planned | P | r | k | —' '- s | planned | S | r | k | —' '- v | in-progress | V | r | k | —' >> "$d/MEMORY.md"
  nov "$d" s planned ''; nov "$d" v in-progress '' 'Depende do desenho de [s](s.md).'
  perl -pi -e 's/\n/\r\n/' "$d/MEMORY.md"
  printf '\n- ver [n](nunca-dv.md)\n' >> "$d/docs/audora/decisoes-vivas.md"
  git -C "$d" add -A; git -C "$d" commit -qm t8
}
p="$SP/t8"; mkt8 "$p"
L1="$(grep -n '^L1 ' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
runc "$p" varrer --orfao 'p=absorvido por d' --orfao 's=absorvido por d'; printf '%s\n' "$out" > "$SP/lote8.txt"
assert_eq 'total: 4 item(ns) no lote' "$(printf '%s\n' "$out" | tail -1)" "skill-cleanup/6 lote com 2 planned e 2 links"
assert_line "$out" '## nunca existiu' "cleanup-link-preciso/5 lote aprovado traz a seção nunca existiu"
# perl (não grep) para filtrar: grep do Git Bash perde o \r
git -C "$p" show HEAD:MEMORY.md | perl -ne 'print unless /^- [ps] \|/' > "$SP/mem8-esperado"
runc "$p" aplicar "$SP/lote8.txt"
assert_eq 0 "$code" "skill-cleanup/6 aplicar → exit 0"
assert_eq 0 "$(grep -c '^- p |' "$p/MEMORY.md")" "skill-cleanup/6 linha do planned p apagada"
assert_eq 0 "$(grep -c '^- s |' "$p/MEMORY.md")" "skill-cleanup/6 linha do planned s apagada"
cmp -s "$SP/mem8-esperado" "$p/MEMORY.md" && ok || ko "skill-cleanup/6 demais linhas do índice intactas (diff só remove as 2 linhas)"
assert_eq "$(wc -l < "$p/MEMORY.md")" "$(tr -cd '\r' < "$p/MEMORY.md" | wc -c)" "skill-cleanup/13 CRLF do MEMORY preservado (conta \\r com tr: o grep do Git Bash não vê \\r)"
assert_no_file "$p/docs/audora/memory/s.md" "skill-cleanup/6 arquivo do nó planned apagado"
assert_contains "$(cat "$p/docs/audora/memory/v.md")" "Depende do desenho de $(nota docs/audora/memory/s.md)." "skill-cleanup/9 link para o nó apagado vira nota"
assert_line "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" "L1 $(notaq docs/audora/e2e/nao-existe.md) quebrado" "cleanup-link-preciso/7 link markdown quebrado trocado pela nota 'já não existia' (caminho da raiz)"
assert_line "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" "L2 Ver $(notaq docs/audora/specs/sumiu.md) aqui." "cleanup-link-preciso/7 token quebrado trocado pela nota 'já não existia'"
assert_line "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" 'docs/audora/x/sumiu-fence.md' "skill-cleanup/10 fence intocado"
assert_line "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" 'L3 [n](../e2e/nunca.md) e `docs/audora/specs/nunca-token.md`' "cleanup-link-preciso/5 nunca existiu não é trocado (L3)"
assert_line "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" 'L4 [fora](../../../../fora.md)' "cleanup-link-preciso/5 nunca existiu não é trocado (L4)"
assert_eq "$(git -C "$p" show HEAD~1:docs/audora/decisoes-vivas.md)" "$(cat "$p/docs/audora/decisoes-vivas.md")" "cleanup-link-preciso/5 arquivo só com nunca existiu intacto"
assert_not_contains "$(git -C "$p" show --name-only --format= HEAD)" 'decisoes-vivas.md' "cleanup-link-preciso/5 arquivo só com nunca existiu fora do commit"
assert_not_contains "$(git -C "$p" show -s --format=%b HEAD)" 'nunca' "cleanup-link-preciso/5 corpo do commit sem nunca existiu"
run_hook memory-validate "$p/MEMORY.md"
assert_eq 0 "$code" "skill-cleanup/13 MEMORY válido depois de apagar planned"
corpo="$(git -C "$p" show -s --format=%b HEAD)"
assert_line "$corpo" 'planned órfão: p, s' "skill-cleanup/13 corpo lista planned órfão"
assert_contains "$corpo" "link quebrado: docs/audora/arquivo/2026-01-01-d.md:$L1" "skill-cleanup/13 corpo lista link quebrado com a linha"
assert_empty "$(git -C "$p" status --porcelain)" "skill-cleanup/13 tudo commitado"
runc "$p" varrer
assert_eq 'cleanup: nada a limpar' "$(printf '%s\n' "$out" | tail -1)" "skill-cleanup/13 idempotente: varrer logo após → nada a limpar"
assert_empty "$(secao "$out" 'link quebrado')" "skill-cleanup/13 idempotente: nenhum link quebrado depois do aplicar"
assert_not_contains "$out" 'nao-existe.md' "cleanup-link-preciso/7 a nota 'já não existia' não vira link (markdown)"
assert_not_contains "$out" 'specs/sumiu.md' "cleanup-link-preciso/7 a nota 'já não existia' não vira link (token)"
assert_eq 4 "$(secao "$out" 'nunca existiu' | grep -c '^- ')" "cleanup-link-preciso/5 nunca existiu segue com os 4 avisos (L3 x2, L4, decisões vivas)"
assert_line "$(secao "$out" 'nunca existiu')" "- docs/audora/decisoes-vivas.md:3 | aponta nunca-dv.md nunca versionado" "cleanup-link-preciso/5 aviso das decisões vivas"

# --- cleanup-commit-curto/1..4 lote grande: corpo quebrado em linhas de até 100 caracteres ---
p="$SP/t10"; mkt2 "$p"; mkdir -p "$p/docs/audora/notas"
for i in $(seq -w 1 40); do printf '# n\n' > "$p/docs/audora/notas/nota-sem-referencia-numero-$i.md"; done
LONGO="docs/audora/notas/$(printf 'x%.0s' $(seq 1 90)).md"
printf '# longo\n' > "$p/$LONGO"
git -C "$p" add -A; git -C "$p" commit -qm t10
# hook commit-msg como o body-max-line-length do commitlint: qualquer linha > 100 recusa
cat > "$p/.git/hooks/commit-msg" <<'HOOK'
#!/bin/sh
if LC_ALL=C awk 'length($0) > 100 { bad = 1 } END { exit bad }' "$1"; then exit 0; fi
echo "linha > 100" >&2; exit 1
HOOK
chmod +x "$p/.git/hooks/commit-msg"
runc "$p" varrer; printf '%s\n' "$out" > "$SP/lote10.txt"
assert_eq 'total: 45 item(ns) no lote' "$(printf '%s\n' "$out" | tail -1)" "cleanup-commit-curto lote grande montado (41 notas + 4 de d)"
runc "$p" aplicar "$SP/lote10.txt"
assert_eq 0 "$code" "cleanup-commit-curto/3 hook commit-msg com limite de 100 aceita → exit 0"
assert_contains "$out" '— 45 item(ns) removido(s)' "cleanup-commit-curto/3 commit do lote grande"
msg="$(git -C "$p" show -s --format=%B HEAD)"
assert_empty "$(printf '%s\n' "$msg" | LC_ALL=C awk 'length($0) > 100')" "cleanup-commit-curto/1 nenhuma linha da mensagem passa de 100"
corpo="$(git -C "$p" show -s --format=%b HEAD)"
assert_eq 1 "$(printf '%s\n' "$corpo" | grep -c '^sem referência: docs/audora/notas/nota-sem-referencia-numero-01.md')" "cleanup-commit-curto/2 tipo abre a lista na 1ª linha"
assert_empty "$(printf '%s\n' "$corpo" | grep -vE '^([^ :][^:]*: |  )' | grep .)" "cleanup-commit-curto/2 continuação recuada com 2 espaços"
faltam=0; for i in $(seq -w 1 40); do
  printf '%s\n' "$corpo" | grep -qF "docs/audora/notas/nota-sem-referencia-numero-$i.md" || faltam=$((faltam + 1))
done
assert_eq 0 "$faltam" "cleanup-commit-curto/2 nenhum item perdido na quebra"
assert_not_contains "$corpo" "$LONGO" "cleanup-commit-curto/4 item maior que a linha fora da lista"
assert_line "$corpo" '  (+1 caminho(s) longo(s) — ver git show --stat)' "cleanup-commit-curto/4 linha com a contagem dos longos"
assert_contains "$(git -C "$p" show --name-only --format= HEAD)" "$LONGO" "cleanup-commit-curto/4 item longo segue no commit"
assert_no_file "$p/$LONGO" "cleanup-commit-curto/4 item longo apagado"

# --- skill-cleanup/14 falha no meio desfaz o lote e nomeia o item ---
# lote_de <arq> <linha>... — lote mínimo com cabeçalho
lote_de() { local a="$1"; shift; printf '%s\n' 'cleanup: relatório — nada foi alterado' "$@" > "$a"; }
# (a) link reescrito depois do varrer: a spec já apagada volta
p="$SP/t9a"; mkt2 "$p"; corpo_d "$p"; git -C "$p" add -A; git -C "$p" commit -qm t9a
L1="$(grep -n '^L1 ' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
lote_de "$SP/lote9a.txt" '## spec de nó entregue' '- docs/audora/specs/d-escopo.md | nó d delivered' \
  '## link quebrado' "- docs/audora/arquivo/2026-01-01-d.md:$L1 | aponta ../e2e/nao-existe.md inexistente"
sed -i "${L1}s/.*/L1 reescrita sem link/" "$p/docs/audora/arquivo/2026-01-01-d.md"; git -C "$p" commit -qam 'reescreve L1'
antes="$(snap "$p")"
runc "$p" aplicar "$SP/lote9a.txt"
assert_eq 1 "$code" "skill-cleanup/14 link sumiu da linha → exit 1"
assert_contains "$out" "cleanup: falhou em: - docs/audora/arquivo/2026-01-01-d.md:$L1" "skill-cleanup/14 nomeia o item que falhou"
assert_contains "$out" 'link não encontrado na linha' "skill-cleanup/14 motivo link não encontrado"
assert_contains "$out" 'cleanup: lote desfeito, nada commitado' "skill-cleanup/14 avisa que desfez"
assert_file "$p/docs/audora/specs/d-escopo.md" "skill-cleanup/14 spec já apagada volta"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/14 (a) estado igual ao de antes do lote"
# (b) commit recusado pelo hook pre-commit
p="$SP/t9b"; mkt2 "$p"; corpo_d "$p"
printf '\n[rel](../e2e/e2e-d.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"; git -C "$p" add -A; git -C "$p" commit -qm t9b
runc "$p" varrer; printf '%s\n' "$out" > "$SP/lote9b.txt"
printf '#!/bin/sh\necho hook recusou >&2\nexit 1\n' > "$p/.git/hooks/pre-commit"; chmod +x "$p/.git/hooks/pre-commit"
antes="$(snap "$p")"
runc "$p" aplicar "$SP/lote9b.txt"
assert_eq 1 "$code" "skill-cleanup/14 pre-commit recusa → exit 1"
assert_contains "$out" 'cleanup: falhou em: commit — commit recusado' "skill-cleanup/14 commit recusado"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/14 (b) estado igual: arquivos e links voltam"
# (c) MEMORY inválido depois de apagar o planned: a linha volta
p="$SP/t9c"; mkt5 "$p"; nov "$p" z planned ''; git -C "$p" add -A; git -C "$p" commit -qm 'z sem linha no índice'
runc "$p" varrer --orfao 'p=absorvido por d'; printf '%s\n' "$out" > "$SP/lote9c.txt"
antes="$(snap "$p")"
runc "$p" aplicar "$SP/lote9c.txt"
assert_eq 1 "$code" "skill-cleanup/14 MEMORY inválido → exit 1"
assert_contains "$out" 'MEMORY inválido: arquivo docs/audora/memory/z.md sem linha no índice mestre' "skill-cleanup/14 motivo cita o erro do memory-validate"
assert_contains "$(cat "$p/MEMORY.md")" '- p | planned |' "skill-cleanup/14 linha do planned volta"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/14 (c) estado igual"
# (d)(e)(f) pré-checagem: item proibido ou sumido depois de um item válido → nada aplicado
p="$SP/t9d"; mkt2 "$p"
for caso in 'src/app.ts|fora de docs/audora/' 'docs/audora/arquivo/2026-01-01-d.md|arquivo/ e decisões vivas nunca são removidos' \
            'docs/audora/decisoes-vivas.md|arquivo/ e decisões vivas nunca são removidos'; do
  alvo="${caso%%|*}"; mot="${caso#*|}"
  lote_de "$SP/lote9d.txt" '## depuração velha' '- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado' \
    '## sem referência' "- $alvo | x"
  antes="$(snap "$p")"
  runc "$p" aplicar "$SP/lote9d.txt"
  assert_eq 1 "$code" "skill-cleanup/14 $alvo → exit 1"
  assert_contains "$out" "cleanup: falhou em: - $alvo | x — $mot" "skill-cleanup/14 $alvo → $mot"
  assert_eq "$antes" "$(snap "$p")" "skill-cleanup/14 $alvo → nada aplicado (item válido antes também não)"
done
git -C "$p" rm -q docs/audora/e2e/e2e-d.md; git -C "$p" commit -qm 'e2e-d some depois do varrer'
lote_de "$SP/lote9f.txt" '## depuração velha' '- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado' \
  '## relatório e2e' '- docs/audora/e2e/e2e-d.md | nó d delivered'
antes="$(snap "$p")"
runc "$p" aplicar "$SP/lote9f.txt"
assert_eq 1 "$code" "skill-cleanup/14 alvo sumido → exit 1"
assert_contains "$out" 'e2e-d.md | nó d delivered — alvo não existe mais' "skill-cleanup/14 alvo não existe mais"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/14 alvo sumido → estado igual"
# (g) referente sujo depois do varrer → recusado na pré-checagem
lote_de "$SP/lote9g.txt" '## depuração velha' '- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado'
printf '\n[c](../depuracao/cacada-2026-01-01.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"; git -C "$p" commit -qam 'linka cacada'
printf 'sujo\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
antes="$(snap "$p")"
runc "$p" aplicar "$SP/lote9g.txt"
assert_eq 1 "$code" "skill-cleanup/14 referente sujo → exit 1"
assert_contains "$out" 'mudança não commitada em docs/audora/arquivo/2026-01-01-d.md' "skill-cleanup/14 referente sujo nomeado"
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/14 referente sujo → trabalho em andamento intacto"

# --- cleanup-link-preciso/6 lote montado à mão com link quebrado de alvo nunca versionado → recusado ---
p="$SP/t12"; mkt2 "$p"
printf '\nN [n](../e2e/nunca.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"; git -C "$p" commit -qam nunca
LN="$(grep -n '^N ' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
lote_de "$SP/lote12.txt" '## depuração velha' '- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado' \
  '## link quebrado' "- docs/audora/arquivo/2026-01-01-d.md:$LN | aponta ../e2e/nunca.md inexistente"
antes="$(snap "$p")"
runc "$p" aplicar "$SP/lote12.txt"
assert_eq 1 "$code" "cleanup-link-preciso/6 alvo nunca versionado → exit 1"
assert_contains "$out" "cleanup: falhou em: - docs/audora/arquivo/2026-01-01-d.md:$LN | aponta ../e2e/nunca.md inexistente — link para caminho nunca versionado: docs/audora/e2e/nunca.md" "cleanup-link-preciso/6 recusa nomeando o item"
assert_contains "$out" 'cleanup: lote desfeito, nada commitado' "cleanup-link-preciso/6 nada commitado"
assert_eq "$antes" "$(snap "$p")" "cleanup-link-preciso/6 estado igual (item válido antes também não sai)"

# --- cleanup-link-preciso/9,10 seção Aprendizados do MEMORY fora da varredura e da troca ---
# (achado na varredura real deste repo: aprendizado que cita caminho de fixture saía como link quebrado)
p="$SP/t13"; mkproj "$p"; sumiu "$p" docs/audora/specs/velha.md
APR='- 2026-01-01 | execute | fixture cita `docs/audora/arquivo/2026-01-01-x.md` e [v](docs/audora/specs/velha.md)'
APR="$APR" perl -0pi -e 's/(## Aprendizados \[carga: sempre\]\n\n)/$1$ENV{APR}\n/' "$p/MEMORY.md"
git -C "$p" commit -qam aprendizado
assert_line "$(cat "$p/MEMORY.md")" "$APR" "cleanup-link-preciso/9 fixture: linha de Aprendizados no lugar"
runc "$p" varrer
assert_eq 'cleanup: nada a limpar' "$out" "cleanup-link-preciso/9 Aprendizados fora do relatório (versionado e nunca versionado)"
runc "$p" contar
assert_eq 0 "$out" "cleanup-link-preciso/9 contar → 0"
addc "$p" docs/audora/specs/d-escopo.md '# spec d'
APR="$APR e \`docs/audora/specs/d-escopo.md\`"
APR="$APR" perl -pi -e 's/^- 2026-01-01 \| execute \|.*$/$ENV{APR}/' "$p/MEMORY.md"
printf '\nSpec: docs/audora/specs/d-escopo.md\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
git -C "$p" commit -qam 'Aprendizados e d citam a spec'
runc "$p" varrer; printf '%s\n' "$out" > "$SP/lote13.txt"
assert_eq '- docs/audora/specs/d-escopo.md | nó d delivered' "$(secao "$out" 'spec de nó entregue')" "cleanup-link-preciso/10 spec no lote"
assert_not_contains "$out" 'MEMORY.md:' "cleanup-link-preciso/10 nada de Aprendizados no relatório"
runc "$p" aplicar "$SP/lote13.txt"
assert_eq 0 "$code" "cleanup-link-preciso/10 aplicar → exit 0"
assert_line "$(cat "$p/MEMORY.md")" "$APR" "cleanup-link-preciso/10 linha de Aprendizados intacta"
assert_line "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" "Spec: $(nota docs/audora/specs/d-escopo.md)" "cleanup-link-preciso/10 demais citadores ganham a nota"
assert_eq "docs/audora/arquivo/2026-01-01-d.md
docs/audora/specs/d-escopo.md" "$(git -C "$p" show --name-only --format= HEAD | LC_ALL=C sort)" "cleanup-link-preciso/10 MEMORY.md fora do commit"
run_hook memory-validate "$p/MEMORY.md"
assert_eq 0 "$code" "cleanup-link-preciso/10 MEMORY válido"

# --- skill-cleanup/10 mesmo link quebrado 2x na linha → 1 item só; aplicar troca os dois ---
# (achado na varredura real deste repo: item duplicado fazia o aplicar falhar no 2º e desfazer o lote)
p="$SP/t10d"; mkproj "$p"; sumiu "$p" docs/audora/e2e/x.md
printf '\nDois: [a](../e2e/x.md) e [b](../e2e/x.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
git -C "$p" commit -qam dup
LD="$(grep -n '^Dois:' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
runc "$p" varrer; printf '%s\n' "$out" > "$SP/lote10d.txt"
assert_eq 1 "$(printf '%s\n' "$out" | grep -cF -- "- docs/audora/arquivo/2026-01-01-d.md:$LD | aponta ../e2e/x.md inexistente")" "skill-cleanup/10 link repetido na linha vira 1 item"
assert_eq 'total: 1 item(ns) no lote' "$(printf '%s\n' "$out" | tail -1)" "skill-cleanup/10 total sem duplicata"
runc "$p" aplicar "$SP/lote10d.txt"
assert_eq 0 "$code" "skill-cleanup/10 aplicar com link repetido → exit 0"
assert_line "$(cat "$p/docs/audora/arquivo/2026-01-01-d.md")" "Dois: $(notaq docs/audora/e2e/x.md) e $(notaq docs/audora/e2e/x.md)" "skill-cleanup/10 as duas ocorrências viram nota"

# --- cleanup-lote-encadeado/1..3 item do lote que cita outro item do mesmo lote ---
# (achado na cleanup real deste repo: a troca de link sujava o plano que cita a spec e o git rm dele desfazia o lote)
# mkt11 <dir> — spec e plano de d (o plano cita a spec), nó d arquivado cita a spec, e2e de d com link quebrado
mkt11() {
  local d="$1"; mkproj "$d"; sumiu "$d" docs/audora/specs/sumiu.md
  mkdir -p "$d/docs/audora/specs" "$d/docs/audora/planos/arquivo" "$d/docs/audora/e2e"
  printf '# spec d\n' > "$d/docs/audora/specs/d-escopo.md"
  printf '# plano d\n\nEscopo: `docs/audora/specs/d-escopo.md` (d/1..2)\n\n- [spec](../../specs/d-escopo.md) — critérios\n' > "$d/docs/audora/planos/arquivo/plano-d.md"
  printf '\n- **d/1** — QUANDO x O SISTEMA DEVE y\n\nSpec: docs/audora/specs/d-escopo.md\n' >> "$d/docs/audora/arquivo/2026-01-01-d.md"
  printf '# e2e d\n\nVer [sumiu](../specs/sumiu.md).\n' > "$d/docs/audora/e2e/e2e-d.md"
  git -C "$d" add -A; git -C "$d" commit -qm t11
}
ESP11="docs/audora/arquivo/2026-01-01-d.md
docs/audora/e2e/e2e-d.md
docs/audora/planos/arquivo/plano-d.md
docs/audora/specs/d-escopo.md"
# confere11 <dir> <ordem> <n> — lote de n itens aplicado: os 3 arquivos saíram, d arquivado com nota, 1 commit só, árvore limpa
confere11() {
  local d="$1" o="$2" n="$3" f
  assert_eq 0 "$code" "cleanup-lote-encadeado/1,3 ($o) aplicar → exit 0"
  assert_contains "$out" "— $n item(ns) removido(s)" "cleanup-lote-encadeado/1,3 ($o) os $n itens aplicados"
  for f in specs/d-escopo.md planos/arquivo/plano-d.md e2e/e2e-d.md; do
    assert_no_file "$d/docs/audora/$f" "cleanup-lote-encadeado/1,3 ($o) apagado: $f"
  done
  assert_eq $((n0 + 1)) "$(git -C "$d" rev-list --count HEAD)" "cleanup-lote-encadeado/1 ($o) exatamente 1 commit novo"
  assert_eq "$ESP11" "$(git -C "$d" show --name-only --format= HEAD | LC_ALL=C sort)" "cleanup-lote-encadeado/1 ($o) commit só com o lote e o citador de fora"
  assert_line "$(cat "$d/docs/audora/arquivo/2026-01-01-d.md")" "Spec: $(nota docs/audora/specs/d-escopo.md)" "cleanup-lote-encadeado/2 ($o) citador fora do lote ganha a nota"
  assert_empty "$(git -C "$d" status --porcelain)" "cleanup-lote-encadeado/1 ($o) árvore limpa"
}
p="$SP/t11"; mkt11 "$p"
LQ="$(grep -n 'sumiu' "$p/docs/audora/e2e/e2e-d.md" | cut -d: -f1)"
runc "$p" varrer; printf '%s\n' "$out" > "$SP/lote11.txt"
for l in '- docs/audora/specs/d-escopo.md | nó d delivered' '- docs/audora/planos/arquivo/plano-d.md | nó d delivered' \
         '- docs/audora/e2e/e2e-d.md | nó d delivered'; do
  assert_line "$out" "$l" "cleanup-lote-encadeado/1,3 varrer lista: $l"
done
assert_not_contains "$out" "e2e-d.md:$LQ" "cleanup-lote-encadeado/3 varrer não lista link de arquivo que sai no lote (só lote montado à mão traz)"
n0="$(git -C "$p" rev-list --count HEAD)"
runc "$p" aplicar "$SP/lote11.txt"
confere11 "$p" 'ordem do varrer' 3
runc "$p" varrer
assert_eq 'cleanup: nada a limpar' "$out" "cleanup-lote-encadeado/1 idempotente: varrer logo após → nada a limpar"
# ordem invertida, lote montado à mão: link quebrado antes do arquivo que o contém, citador antes do citado
p="$SP/t11r"; mkt11 "$p"
lote_de "$SP/lote11r.txt" '## link quebrado' "- docs/audora/e2e/e2e-d.md:$LQ | aponta ../specs/sumiu.md inexistente" \
  '## relatório e2e' '- docs/audora/e2e/e2e-d.md | nó d delivered' \
  '## plano arquivado' '- docs/audora/planos/arquivo/plano-d.md | nó d delivered' \
  '## spec de nó entregue' '- docs/audora/specs/d-escopo.md | nó d delivered'
n0="$(git -C "$p" rev-list --count HEAD)"
runc "$p" aplicar "$SP/lote11r.txt"
confere11 "$p" 'ordem invertida' 4

# --- skill-cleanup/12 skill: relatório, aprovação explícita do lote, aplicar; /1 /2 /3 /4 pela skill ---
sk="$(tr -d '\r' 2>/dev/null < "$ROOT/skills/cleanup/SKILL.md")"
assert_file "$ROOT/skills/cleanup/SKILL.md" "skill-cleanup/12 skill cleanup existe"
for s in 'hooks/cleanup" varrer' 'hooks/cleanup" aplicar' '--orfao <id>=absorvido por <id-delivered>' \
         '--orfao <id>=alvo ausente: <alvo>' 'aprovação explícita' 'tirar itens' 'nada a limpar' 'git revert <hash>' \
         'bootstrap da skill memory' "grep -E '^- [^|]+ \\| (planned|delivered) \\|' MEMORY.md"; do
  assert_contains "$sk" "$s" "skill-cleanup/12 skill cita: $s"
done
assert_contains "$(printf '%s\n' "$sk" | grep -F 'reprovou ou tirou todos → não rode')" 'aplicar' "skill-cleanup/12 reprovado ou vazio → não roda aplicar (mesma linha)"
assert_not_contains "$sk" '## Bloco de fechamento' "skill-cleanup/12 skill-ferramenta sem bloco de fechamento"
[ "$(printf '%s\n' "$sk" | wc -l)" -le 250 ] && ok || ko "skill-cleanup/12 SKILL.md ≤ 250 linhas"
assert_contains "$sk" 'O script só acha o caminho da coluna arquivos-chave que existiu no histórico e sumiu do disco' "cleanup-alvo-ausente/10 skill: script só acha o que existiu e sumiu"
assert_contains "$(printf '%s\n' "$sk" | grep -F 'confira no histórico que o alvo existiu')" '--orfao <id>=alvo ausente: <alvo>' "cleanup-alvo-ausente/10 skill: --orfao alvo ausente só depois de conferir o histórico"
assert_contains "$(printf '%s\n' "$sk" | grep -F 'confira no histórico que o alvo existiu')" 'git --literal-pathspecs log -1 --full-history' "cleanup-alvo-ausente/10 skill: conferência com pathspec literal"
assert_not_contains "$sk" 'Caminho inexistente na coluna arquivos-chave o script já acha sozinho' "cleanup-alvo-ausente/10 skill: frase antiga removida"
assert_not_contains "$sk" 'alvo ausente conferido no repo' "cleanup-alvo-ausente/10 skill: red flag confere no histórico"
for s in '## nunca existiu' 'erro de digitação, exemplo ou fixture' 'corrige à mão' \
         'já não existia em AAAA-MM-DD (link limpo pela cleanup) — recuperável no git' \
         'removido em AAAA-MM-DD pela cleanup — recuperável no git' 'fora da seção Aprendizados'; do
  assert_contains "$sk" "$s" "cleanup-link-preciso/12 skill cita: $s"
done
assert_contains "$(printf '%s\n' "$sk" | grep -F '`## nunca existiu` —')" 'fora do lote' "cleanup-link-preciso/12 skill: nunca existiu é aviso fora do lote"
assert_contains "$(bash "$ROOT/hooks/session-start")" 'cleanup' "skill-cleanup/1 session-start aponta a cleanup"

# --- skill-cleanup/16 sync da validate sugere a cleanup (1 linha, com a contagem), sem rodar ---
sy="$(tr -d '\r' 2>/dev/null < "$ROOT/skills/validate/references/sync.md" | tr '\n' ' ' | tr -s ' ')"
for s in 'hooks/cleanup" contar' 'Sobras do processo: N — rode a skill cleanup quando quiser.' 'N = 0 → nada' \
         'depois do commit do sync'; do
  assert_contains "$sy" "$s" "skill-cleanup/16 sync: $s"
done
assert_contains "$(printf '%s' "$sy" | grep -o 'Nunca rode[^.]*')" 'aplicar' "skill-cleanup/16 sync nunca roda o aplicar"
assert_not_contains "$sy" 'hooks/cleanup" aplicar' "skill-cleanup/16 sync não chama o aplicar"
assert_not_contains "$(tr -d '\r' < "$ROOT/skills/validate/SKILL.md")" 'hooks/cleanup' "skill-cleanup/16 validate/SKILL.md intocado (guarda de carga)"

report
