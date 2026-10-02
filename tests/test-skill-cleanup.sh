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

report
