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
FIXPATH="$B:$(path_sem_uv)"
guarda_sem_uv "$FIXPATH" "$B"   # remover-graphify/13 — só uv/pipx falsos alcançáveis
lim() { out="$(cd "$P" && PATH="$FIXPATH" bash "$L" "$@" 2>&1)"; code=$?; }
mkvazio() {
  rm -rf "$P"; mkdir -p "$P"
  git -C "$P" init -q; git -C "$P" config user.email t@t; git -C "$P" config user.name t
  git -C "$P" config core.autocrlf false
  git -C "$P" config core.excludesFile "$SP/sem-ignore-global"   # ignore global da máquina não vaza na fixture
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
# /4 — aprovado: remove tudo, relata item a item, lista versionados, não commita
mkproj; fake 'graphifyy v0.9.11' ''; lim --remover .
assert_eq 0 "$code" "remover-graphify/4 remoção completa sai 0"
while IFS= read -r l; do assert_contains "$out" "removido $l" "remover-graphify/4 relata $l"; done <<< "$RESTOS"
assert_contains "$out" 'removido pacote graphifyy (uv)' "remover-graphify/3,4 relata o pacote"
assert_contains "$(cat "$FAKE_LOG")" 'uv tool uninstall graphifyy' "remover-graphify/3,4 desinstala pelo instalador que o tem"
for v in MEMORY.md .gitignore .claude/settings.json .claude/settings.local.json CLAUDE.md; do
  assert_contains "$out" "versionado $v" "remover-graphify/4 relata versionado $v"
done
assert_eq 2 "$(git -C "$P" rev-list --count HEAD)" "remover-graphify/4 não commita"
fake '' ''; lim .
assert_empty "$out" "remover-graphify/4 depois da remoção não sobra resto"
# /5 — só a parte do Graphify sai; o resto fica
pc="$(cat "$P/.git/hooks/post-commit" 2>/dev/null)"
assert_contains "$pc" 'echo meu-hook' "remover-graphify/5 hook preserva o conteúdo alheio"
assert_not_contains "$pc" 'graphify' "remover-graphify/5 bloco do Graphify saiu do hook"
assert_no_file "$P/.git/hooks/post-checkout" "remover-graphify/5 hook só do Graphify sai inteiro"
assert_no_file "$P/graphify-out" "remover-graphify/4 pasta graphify-out/ removida"
assert_eq "$(printf '%s\n' 'node_modules/' '*.log')" "$(cat "$P/.gitignore")" "remover-graphify/5 .gitignore preserva as outras linhas"
for s in .claude/settings.json .claude/settings.local.json; do
  perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' < "$P/$s" 2>/dev/null && ok || ko "remover-graphify/5 $s JSON inválido"
  assert_not_contains "$(cat "$P/$s")" 'graphify' "remover-graphify/5 $s sem hook do Graphify"
done
sj="$(cat "$P/.claude/settings.json")"
assert_contains "$sj" 'meu-lint' "remover-graphify/5 settings preserva hook alheio"
assert_contains "$sj" 'Bash(ls:*)' "remover-graphify/5 settings preserva permissions"
cm="$(cat "$P/CLAUDE.md")"
for s in '# Projeto' '## Regras' 'use tabs' '## Outra' 'fim'; do assert_contains "$cm" "$s" "remover-graphify/5 CLAUDE.md preserva '$s'"; done
assert_not_contains "$cm" 'graphify' "remover-graphify/5 seção do Graphify saiu do CLAUDE.md"
assert_not_contains "$cm" '### detalhe' "remover-graphify/5 subseção do Graphify saiu junto"
mm="$(cat "$P/MEMORY.md")"
assert_not_contains "$mm" 'graphify' "remover-graphify/5 bullet e continuação saíram da Constituição"
assert_contains "$mm" '- **stack**: bash' "remover-graphify/5 Constituição preserva stack"
assert_contains "$mm" '- **gate**: `bash gate`' "remover-graphify/5 Constituição preserva gate"
# /6 — falha num item não trava os demais; relata o comando à mão
mkproj; printf '{"hooks": graphify quebrado' > "$P/.claude/settings.json"; fake 'graphifyy v0.9.11' '' 1; lim --remover .
assert_eq 1 "$code" "remover-graphify/6 falha parcial sai 1"
assert_contains "$out" 'falhou settings .claude/settings.json — à mão:' "remover-graphify/6 JSON inválido vira comando à mão"
assert_eq '{"hooks": graphify quebrado' "$(cat "$P/.claude/settings.json")" "remover-graphify/6 arquivo que falhou fica intocado"
assert_contains "$out" 'falhou pacote graphifyy (uv) — à mão: uv tool uninstall graphifyy' "remover-graphify/6 desinstalação com erro vira comando à mão"
assert_contains "$out" 'removido settings .claude/settings.local.json' "remover-graphify/6 segue no item seguinte"
assert_contains "$out" 'removido claude-md CLAUDE.md' "remover-graphify/6 segue até o fim"
assert_not_contains "$out" 'versionado .claude/settings.json' "remover-graphify/6 arquivo que falhou não é relatado como alterado"
# /3,/4 — pacote via pipx é desinstalado pelo pipx
mkvazio; mkdir "$P/graphify-out"; fake '' 'graphifyy 0.9.11'; lim --remover .
assert_contains "$(cat "$FAKE_LOG")" 'pipx uninstall graphifyy' "remover-graphify/3,4 desinstala via pipx"
assert_contains "$out" 'removido pacote graphifyy (pipx)' "remover-graphify/4 relata o pacote pipx"
# /8 — --remover sem resto: silêncio; /4 — fora de repo git: sem versionado
mkvazio; fake 'graphifyy v0.9.11' ''; lim --remover .
assert_eq 0 "$code" "remover-graphify/8 --remover em projeto limpo sai 0"
assert_empty "$out" "remover-graphify/8 --remover em projeto limpo é silencioso"
rm -rf "$P"; mkdir -p "$P/graphify-out"; fake '' ''; lim --remover .
assert_eq 'removido pasta graphify-out/' "$out" "remover-graphify/4 fora de repo git remove sem versionado"
assert_no_file "$ROOT/hooks/graphify-status" "remover-graphify/10 classificador do índice removido"
# A1 (/2,/5) — hook do Graphify = hooks[].command casando ^graphify\b: hook alheio no
# MESMO grupo fica; substring em comando alheio não é resto e o arquivo não é reescrito
mkvazio; mkdir -p "$P/.claude"; printf 'graphify-out/\n' >> "$P/.gitignore"
printf '%s\n' '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"graphify hook-guard search"},{"type":"command","command":"meu-guard"}]}]}}' > "$P/.claude/settings.json"
printf '%s\n' '{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"rm -rf old-graphify-backup"}]}]}}' > "$P/.claude/settings.local.json"
git -C "$P" add -A; git -C "$P" commit -qm a1; fake '' ''; lim .
assert_eq "$(printf '%s\n' 'gitignore .gitignore' 'settings .claude/settings.json')" "$out" "remover-graphify/2 A1 substring graphify em comando alheio não é resto"
antes_l="$(md5sum < "$P/.claude/settings.local.json")"; lim --remover .
sj="$(cat "$P/.claude/settings.json")"
assert_contains "$sj" '"meu-guard"' "remover-graphify/5 A1 hook alheio do mesmo grupo fica"
assert_contains "$sj" '"matcher": "Bash"' "remover-graphify/5 A1 grupo com hook alheio mantém o matcher"
assert_not_contains "$sj" 'graphify' "remover-graphify/5 A1 só o hook do Graphify sai do grupo"
assert_eq "$antes_l" "$(md5sum < "$P/.claude/settings.local.json")" "remover-graphify/5 A1 settings sem hook do Graphify não é reescrito"
# A2 (/5) — a seção do Graphify no CLAUDE.md termina no próximo H1 ou H2; o H1 seguinte fica
mkvazio; printf '%s\n' '# Projeto' '## graphify' 'x' '# Anexo' 'y' > "$P/CLAUDE.md"; fake '' ''; lim --remover .
assert_eq "$(printf '%s\n' '# Projeto' '# Anexo' 'y')" "$(cat "$P/CLAUDE.md")" "remover-graphify/5 A2 H1 depois da seção do Graphify fica"
report
