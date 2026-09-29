#!/usr/bin/env bash
# remover-graphify/2..8 — hooks/graphify-limpeza detecta e remove restos do Graphify.
# Fixture: repo git real + uv/pipx falsos no PATH (controlados por FAKE_*).
source "$(dirname "$0")/lib.sh"
L="$ROOT/hooks/graphify-limpeza"
B="$SP/bin"; mkdir -p "$B"; export FAKE_LOG="$SP/fake.log"
printf '%s\n' '#!/usr/bin/env bash' 'echo "uv $*" >> "$FAKE_LOG"' \
  'case "$1 $2" in "tool list") printf "%s\n" "${FAKE_UV_LIST:-}" ;; "tool uninstall") exit "${FAKE_UV_EXIT:-0}" ;; esac' > "$B/uv"
printf '%s\n' '#!/usr/bin/env bash' 'echo "pipx $*" >> "$FAKE_LOG"' \
  'case "$1" in list) printf "%s\n" "${FAKE_PIPX_LIST:-}" ;; uninstall) exit "${FAKE_PIPX_EXIT:-0}" ;; esac' > "$B/pipx"
chmod +x "$B/uv" "$B/pipx"
fake() { export FAKE_UV_LIST="$1" FAKE_PIPX_LIST="$2" FAKE_UV_EXIT="${3:-0}" FAKE_PIPX_EXIT="${4:-0}"; : > "$FAKE_LOG"; }
P="$SP/proj"
lim() { out="$(cd "$P" && PATH="$B:$PATH" bash "$L" "$@" 2>&1)"; code=$?; }
mkvazio() {
  rm -rf "$P"; mkdir -p "$P"
  git -C "$P" init -q; git -C "$P" config user.email t@t; git -C "$P" config user.name t
  git -C "$P" config core.autocrlf false
  printf '%s\n' 'memory-schema: 1' '' '## Constituição [carga: sempre]' '' '- **stack**: bash' \
    '- **gate**: `bash gate`' '' '## Aprendizados [carga: sempre]' '' \
    '- 2026-08-26 | execute | graphify hook install grava _PINNED vazio' > "$P/MEMORY.md"
  printf '%s\n' 'node_modules/' '*.log' > "$P/.gitignore"
  git -C "$P" add -A; git -C "$P" commit -qm base
}
mkproj() {
  mkvazio; mkdir -p "$P/.claude" "$P/graphify-out"
  printf '%s\n' 'memory-schema: 1' '' '## Constituição [carga: sempre]' '' '- **stack**: bash' \
    '- **graphify**: ativo — índice em' '  `graphify-out/` + git hook post-commit' \
    '- **gate**: `bash gate`' '' '## Aprendizados [carga: sempre]' > "$P/MEMORY.md"
  printf '%s\n' 'node_modules/' 'graphify-out/' '*.log' > "$P/.gitignore"
  printf '%s\n' '{"permissions":{"allow":["Bash(ls:*)"]},"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"graphify hook-guard search"}]},{"matcher":"Edit","hooks":[{"type":"command","command":"meu-lint"}]}]}}' > "$P/.claude/settings.json"
  printf '%s\n' '{"hooks":{"PreToolUse":[{"matcher":"Read|Glob","hooks":[{"type":"command","command":"graphify hook-guard read"}]}]}}' > "$P/.claude/settings.local.json"
  printf '%s\n' '# Projeto' '' '## Regras' 'use tabs' '' '## graphify' 'Grafo de conhecimento do graphify.' '### detalhe' 'x' '' '## Outra' 'fim' > "$P/CLAUDE.md"
  echo '{}' > "$P/graphify-out/graph.json"
  git -C "$P" add -A; git -C "$P" commit -qm restos
  printf '%s\n' '#!/bin/sh' 'echo meu-hook' '# graphify-hook-start' 'python rebuild' '# graphify-hook-end' > "$P/.git/hooks/post-commit"
  printf '%s\n' '#!/bin/sh' '# graphify-checkout-hook-start' 'python rebuild' '# graphify-checkout-hook-end' > "$P/.git/hooks/post-checkout"
}
RESTOS="$(printf '%s\n' 'constituicao MEMORY.md' 'git-hook .git/hooks/post-commit' 'git-hook .git/hooks/post-checkout' 'pasta graphify-out/' 'gitignore .gitignore' 'settings .claude/settings.json' 'settings .claude/settings.local.json' 'claude-md CLAUDE.md')"

# /2 — cada tipo, na ordem fixa; sem pacote na máquina, sem linha de pacote
mkproj; fake '' ''; lim .
assert_eq 0 "$code" "remover-graphify/2 detecção sai 0"
assert_eq "$RESTOS" "$out" "remover-graphify/2 lista os 8 restos"
# /2 — SÓ o que existe, um tipo por vez
mkvazio; printf '%s\n' '- **graphify**: recusado' >> "$P/MEMORY.md"; fake '' ''; lim .
assert_eq 'constituicao MEMORY.md' "$out" "remover-graphify/2 bullet graphify com qualquer valor"
mkvazio; printf 'graphify-out/\n' >> "$P/.gitignore"; fake 'graphifyy v0.9.11' ''; lim .
assert_eq "$(printf '%s\n' 'gitignore .gitignore' 'pacote graphifyy (uv)')" "$out" "remover-graphify/2,3 só o .gitignore + pacote uv"
mkvazio; mkdir "$P/graphify-out"; fake '' 'graphifyy 0.9.11'; lim .
assert_eq "$(printf '%s\n' 'pasta graphify-out/' 'pacote graphifyy (pipx)')" "$out" "remover-graphify/3 pacote via pipx"
mkvazio; printf '%s\n' '#!/bin/sh' '# graphify-checkout-hook-start' 'x' '# graphify-checkout-hook-end' > "$P/.git/hooks/post-checkout"; fake '' ''; lim .
assert_eq 'git-hook .git/hooks/post-checkout' "$out" "remover-graphify/2 hook post-checkout sozinho"
mkvazio; mkdir -p "$P/.claude"; printf '%s\n' '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"graphify hook-guard search"}]}]}}' > "$P/.claude/settings.local.json"; fake '' ''; lim .
assert_eq 'settings .claude/settings.local.json' "$out" "remover-graphify/2 settings.local.json sozinho"
mkvazio; printf '%s\n' '# P' '## graphify' 'x' > "$P/CLAUDE.md"; fake '' ''; lim .
assert_eq 'claude-md CLAUDE.md' "$out" "remover-graphify/2 seção do CLAUDE.md sozinha"
# /2 borda — graphify fora de hooks não é resto; JSON inválido citando graphify é
mkvazio; mkdir -p "$P/.claude"; printf '%s\n' '{"permissions":{"allow":["Bash(graphify:*)"]}}' > "$P/.claude/settings.json"; fake '' ''; lim .
assert_empty "$out" "remover-graphify/2 graphify em permissions não é hook"
printf '{"hooks": graphify quebrado' > "$P/.claude/settings.json"; lim .
assert_eq 'settings .claude/settings.json' "$out" "remover-graphify/2 JSON inválido citando graphify é listado"
# /2 borda — fora de repo git: sem git-hook, sem erro
rm -rf "$P"; mkdir -p "$P"; printf 'graphify-out/\n' > "$P/.gitignore"; fake '' ''; lim .
assert_eq 0 "$code" "remover-graphify/2 fora de repo git sai 0"
assert_eq 'gitignore .gitignore' "$out" "remover-graphify/2 fora de repo git lista só o que há"
# /8 — projeto limpo: silêncio, e o pacote nem é consultado
mkvazio; fake 'graphifyy v0.9.11' 'graphifyy 0.9.11'; lim .
assert_eq 0 "$code" "remover-graphify/8 projeto limpo sai 0"
assert_empty "$out" "remover-graphify/8 projeto limpo não cita Graphify (aprendizado com a palavra não conta)"
assert_empty "$(cat "$FAKE_LOG")" "remover-graphify/8 pacote sozinho nem é consultado"
# /7 — detectar não altera nada; a oferta volta na carga seguinte
mkproj; fake 'graphifyy v0.9.11' ''
snap() { (cd "$P" && find . -path ./.git/objects -prune -o -type f -print | sort | xargs md5sum); }
antes="$(snap)"; lim .; lim .
assert_eq "$antes" "$(snap)" "remover-graphify/7 detecção (2x) não altera arquivo nenhum"
assert_contains "$out" 'pacote graphifyy (uv)' "remover-graphify/7 a oferta volta na carga seguinte"
report
