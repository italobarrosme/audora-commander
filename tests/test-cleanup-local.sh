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

report
