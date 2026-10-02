#!/usr/bin/env bash
# skill-cleanup/1..16 — hooks/cleanup (varrer/contar/aplicar), skill cleanup e sugestão no sync da validate.
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
```
docs/audora/x/sumiu-fence.md
```
[ok](../decisoes-vivas.md) e [w](https://x.y/z.md) e [a](../decisoes-vivas.md#topo) e [b](#topo) e [c](<x.md>)
`docs/audora/e2e/velho.md` removido em 2026-01-01 pela cleanup — recuperável no git
EOF
}
p="$SP/t4"; mkt2 "$p"; corpo_d "$p"
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

# --- skill-cleanup/3,4,5 planned órfão (--orfao e alvo ausente) e mantido ---
# mkt5 <dir> — planned p q r r2 s; v (vivo) depende de r2; d (arquivado) depende de s
mkt5() {
  local d="$1"; mkproj "$d"
  printf -- '%s\n' '- p | planned | P | r | k | —' '- q | planned | Q | r | k | src/sumiu.ts, README.md' \
    '- r | planned | R | r | k | —' '- r2 | planned | R2 | r | k | src/nada.ts' '- s | planned | S | r | k | —' \
    '- v | in-progress | V | r | k | —' >> "$d/MEMORY.md"
  nov "$d" v in-progress 'r2'
  sed -i 's/^depende-de: \[\]/depende-de: [s]/' "$d/docs/audora/arquivo/2026-01-01-d.md"
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

# --- skill-cleanup/11 não tocado: fora do git e mudança não commitada ---
p="$SP/t6"; mkt2 "$p"
printf '\n[p](../planos/arquivo/plano-d.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
git -C "$p" add -A; git -C "$p" commit -qm 'arquivo linka plano-d'
git -C "$p" rm -q --cached docs/audora/e2e/e2e-d.md; git -C "$p" commit -qm 'e2e-d fora do git'
printf 'docs/audora/tmp/\n' > "$p/.gitignore"; mkdir -p "$p/docs/audora/tmp"; printf '# x\n' > "$p/docs/audora/tmp/x.md"
printf '# editado\n' >> "$p/docs/audora/specs/d-escopo.md"
printf '[q](../e2e/nao-existe.md)\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
LQ="$(grep -n 'nao-existe' "$p/docs/audora/arquivo/2026-01-01-d.md" | cut -d: -f1)"
mkdir -p "$p/docs/audora/notas"; printf '[c](../depuracao/cacada-2026-01-01.md)\n' > "$p/docs/audora/notas/rascunho.md"
antes="$(snap "$p")"
runc "$p" varrer
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
assert_eq "$antes" "$(snap "$p")" "skill-cleanup/11 varrer com árvore suja não altera nada"
p="$SP/t6m"; mkt5 "$p"; printf '\n' >> "$p/MEMORY.md"
runc "$p" varrer --orfao 'p=absorvido por d'
assert_line "$(secao "$out" 'não tocado')" '- p | não tocado: mudança não commitada em MEMORY.md' "skill-cleanup/11 planned com MEMORY.md sujo"
assert_empty "$(secao "$out" 'planned órfão')" "skill-cleanup/11 MEMORY sujo tira todo planned do lote"
assert_eq 'cleanup: nada a limpar' "$(printf '%s\n' "$out" | tail -1)" "skill-cleanup/11 lote vazio com só não tocados → nada a limpar"

# --- skill-cleanup/9,13 aplicar: apaga, troca link pela nota, 1 commit só com o lote ---
HOJE="$(date +%F)"
nota() { printf '`%s` removido em %s pela cleanup — recuperável no git' "$1" "$HOJE"; }
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

report
