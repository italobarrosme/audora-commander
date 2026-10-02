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

report
