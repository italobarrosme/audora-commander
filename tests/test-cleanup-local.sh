#!/usr/bin/env bash
# gitignore-padrao/13,/15,/16,/17 — hooks/cleanup com spec, plano, e2e e caçada fora do git.
source "$(dirname "$0")/lib.sh"
C="$ROOT/hooks/cleanup"
VS="$ROOT/hooks/versionamento"

# --- fixtures (mesmo molde de tests/test-skill-cleanup.sh) ---
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
# loc <dir> <caminho> [conteúdo] — escreve só no disco (fora do git)
loc() { mkdir -p "$(dirname "$1/$2")"; printf '%s\n' "${3:-x}" > "$1/$2"; }
# sumiu <dir> <caminho>... — cada caminho é versionado e depois removido
sumiu() {
  local d="$1" f; shift
  for f in "$@"; do mkdir -p "$(dirname "$d/$f")"; printf 'existiu\n' > "$d/$f"; git -C "$d" add -- "$f"; done
  git -C "$d" commit -qm "existiu: $*"; git -C "$d" rm -q -- "$@"; git -C "$d" commit -qm "sumiu: $*"
}
# runc <dir> <args…> — roda o script na raiz do projeto; define out (stdout+stderr) e code
runc() { local d="$1"; shift; out="$(cd "$d" && bash "$C" "$@" 2>&1)"; code=$?; }
# snap <dir> — HEAD + status + md5 da árvore (fora do .git)
snap() {
  ( cd "$1" && git rev-parse HEAD && git status --porcelain --ignored && \
    find . -path ./.git -prune -o -type f -print | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done )
}
assert_line()    { printf '%s\n' "$1" | grep -qxF -- "$2" && ok || ko "$3 — sem a linha '$2'"; }
secao() { printf '%s\n' "$1" | awk -v t="## $2" '$0==t {on=1; next} /^## |^total:|^cleanup:/ {on=0} on'; }

# ===================== T7 — gitignore-padrao/13 local: não é link =====================
p="$SP/l13"; mkproj "$p"
printf '\n## e2e\n\n- d/1 · passou · ok\nrelatório: local: docs/audora/e2e/e2e-d.md\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
git -C "$p" add -A; git -C "$p" commit -qm 'nó cita relatório local'
runc "$p" varrer
assert_eq 'cleanup: nada a limpar' "$out" "gitignore-padrao/13 local: nunca versionado não vira aviso"

p="$SP/l13b"; mkproj "$p"; sumiu "$p" docs/audora/e2e/e2e-d.md
printf '\nrelatório: local: `docs/audora/e2e/e2e-d.md`\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
git -C "$p" add -A; git -C "$p" commit -qm 'nó cita relatório local com crase'
runc "$p" varrer
assert_empty "$(secao "$out" 'link quebrado')" "gitignore-padrao/13 local: com crase não é link quebrado"
assert_eq 'cleanup: nada a limpar' "$out" "gitignore-padrao/13 local: com crase → nada a limpar"

p="$SP/l13c"; mkproj "$p"
printf '\nrelatório: local: docs/audora/e2e/e2e-d.md e veja docs/audora/e2e/nunca.md\n' >> "$p/docs/audora/arquivo/2026-01-01-d.md"
git -C "$p" add -A; git -C "$p" commit -qm 'token solto'
runc "$p" varrer
assert_line "$(secao "$out" 'nunca existiu')" '- docs/audora/arquivo/2026-01-01-d.md:13 | aponta docs/audora/e2e/nunca.md nunca versionado' "gitignore-padrao/13 regressão: token solto segue em nunca existiu"
assert_not_contains "$out" 'e2e-d.md' "gitignore-padrao/13 o local: da mesma linha fica fora"

# ===================== T9 — varrer: sobras locais em "sem volta (fora do git)" =====================
SV='sem volta (fora do git)'
# mkloc <dir> — mkproj + bloco do audora commitado + sobras locais de d (delivered)
mkloc() {
  mkproj "$1"; (cd "$1" && bash "$VS" aplicar >/dev/null); git -C "$1" add .gitignore; git -C "$1" commit -qm bloco
  loc "$1" docs/audora/specs/d-escopo.md; loc "$1" docs/audora/planos/arquivo/plano-d.md; loc "$1" docs/audora/e2e/e2e-d.md
  loc "$1" docs/audora/e2e/d/a.png; loc "$1" docs/audora/e2e/d/b.png
}

# --- gitignore-padrao/15 delivered ---
p="$SP/v15"; mkloc "$p"; antes="$(snap "$p")"
runc "$p" varrer
assert_eq 0 "$code" "gitignore-padrao/15 varrer → exit 0"
assert_eq "- docs/audora/e2e/d/ | nó d delivered (2 arquivo(s))
- docs/audora/e2e/e2e-d.md | nó d delivered
- docs/audora/planos/arquivo/plano-d.md | nó d delivered
- docs/audora/specs/d-escopo.md | nó d delivered" "$(secao "$out" "$SV")" "gitignore-padrao/15 sobras locais de nó delivered na seção própria"
assert_contains "$out" "## $SV" "gitignore-padrao/15 seção marcada sem volta (fora do git)"
assert_not_contains "$out" '## não tocado' "gitignore-padrao/15 local não vai para não tocado"
assert_eq 'total: 4 item(ns) no lote' "$(printf '%s\n' "$out" | tail -1)" "gitignore-padrao/15 total conta as sobras locais"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/15 varrer só lê"
runc "$p" contar
assert_eq 4 "$out" "gitignore-padrao/15 contar soma as sobras locais"

# --- gitignore-padrao/15 discarded ---
p="$SP/v15x"; mkloc "$p"
printf -- '- x | discarded | X → docs/audora/arquivo/2026-01-01-x.md\n' >> "$p/MEMORY.md"
printf -- '---\nid: x\nestado: discarded\n---\n# x\n' > "$p/docs/audora/arquivo/2026-01-01-x.md"
git -C "$p" add -A; git -C "$p" commit -qm 'x discarded'
loc "$p" docs/audora/specs/x-escopo.md; loc "$p" docs/audora/planos/plano-x.md
runc "$p" varrer
assert_line "$(secao "$out" "$SV")" '- docs/audora/specs/x-escopo.md | nó x discarded' "gitignore-padrao/15 spec local de nó discarded"
assert_line "$(secao "$out" "$SV")" '- docs/audora/planos/plano-x.md | nó x discarded' "gitignore-padrao/15 plano ativo local de nó discarded"

# --- gitignore-padrao/15 caçada sem nó vivo ---
p="$SP/v15c"; mkproj "$p"; (cd "$p" && bash "$VS" aplicar >/dev/null)
printf -- '- v | in-progress | V | r | k | src/\n' >> "$p/MEMORY.md"
printf -- '---\nid: v\nestado: in-progress\n---\n# v\n\nver local: docs/audora/depuracao/cacada-2026-01-02.md\n' > "$p/docs/audora/memory/v.md"
git -C "$p" add -A; git -C "$p" commit -qm 'v vivo'
loc "$p" docs/audora/depuracao/cacada-2026-01-01.md; loc "$p" docs/audora/depuracao/cacada-2026-01-02.md
runc "$p" varrer
assert_eq '- docs/audora/depuracao/cacada-2026-01-01.md | caçada sem nó vivo' "$(secao "$out" "$SV")" "gitignore-padrao/15 caçada local sem nó vivo (a citada por nó vivo fica)"

# --- gitignore-padrao/15 critério sem cópia → mantido ---
p="$SP/v15m"; mkloc "$p"; loc "$p" docs/audora/specs/d-escopo.md 'critério d/9 só aqui'
runc "$p" varrer
assert_line "$(secao "$out" 'mantido')" '- docs/audora/specs/d-escopo.md | mantido: cita d/9 sem cópia no nó arquivado' "gitignore-padrao/15 local com critério sem cópia fica (mantido)"
assert_not_contains "$(secao "$out" "$SV")" 'd-escopo.md' "gitignore-padrao/15 mantido fora do lote"

# --- gitignore-padrao/17 planned, in-progress e blocked nunca ---
p="$SP/v17"; mkproj "$p"; (cd "$p" && bash "$VS" aplicar >/dev/null)
printf -- '- pp | planned | P | r | k | src/\n- vv | in-progress | V | r | k | src/\n- bb | blocked | B | r | k | src/\n' >> "$p/MEMORY.md"
for i in vv bb; do printf -- '---\nid: %s\n---\n# %s\n' "$i" "$i" > "$p/docs/audora/memory/$i.md"; done
git -C "$p" add -A; git -C "$p" commit -qm vivos
for i in pp vv bb; do
  loc "$p" "docs/audora/specs/$i-escopo.md"; loc "$p" "docs/audora/planos/plano-$i.md"; loc "$p" "docs/audora/planos/arquivo/plano-$i.md"
  loc "$p" "docs/audora/e2e/e2e-$i.md"; loc "$p" "docs/audora/e2e/$i/shot.png"
done
runc "$p" varrer
for i in pp vv bb; do
  assert_not_contains "$out" "$i-escopo" "gitignore-padrao/17 spec de $i nunca listada"
  assert_not_contains "$out" "plano-$i" "gitignore-padrao/17 plano de $i nunca listado"
  assert_not_contains "$out" "e2e-$i" "gitignore-padrao/17 relatório e2e de $i nunca listado"
  assert_not_contains "$out" "e2e/$i/" "gitignore-padrao/17 evidência de $i nunca listada"
done
assert_eq 'cleanup: nada a limpar' "$out" "gitignore-padrao/17 só vivos → nada a limpar"

# --- gitignore-padrao/15 rastreado segue no tipo antigo ---
p="$SP/v15r"; mkproj "$p"; addc "$p" docs/audora/specs/d-escopo.md x
runc "$p" varrer
assert_line "$(secao "$out" 'spec de nó entregue')" '- docs/audora/specs/d-escopo.md | nó d delivered' "gitignore-padrao/15 spec rastreada segue em spec de nó entregue"
assert_empty "$(secao "$out" "$SV")" "gitignore-padrao/15 rastreado não vai para sem volta"

report
