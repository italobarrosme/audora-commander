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
mkvazio; perl -pi -e 'print "- **graphify**: recusado\n" if /^- \*\*gate\*\*:/' "$P/MEMORY.md"; fake '' ''; lim .   # dentro da Constituição
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
# A3 (/5,/6) — hook com marcador start sem end: falha com comando à mão, arquivo intocado
mkvazio; printf '%s\n' '#!/bin/sh' '# graphify-hook-start' 'python rebuild' 'echo meu-hook-depois' > "$P/.git/hooks/post-commit"
antes_h="$(md5sum < "$P/.git/hooks/post-commit")"; fake '' ''; lim --remover .
assert_eq 1 "$code" "remover-graphify/6 A3 hook sem marcador end sai 1"
assert_contains "$out" 'falhou git-hook .git/hooks/post-commit — à mão:' "remover-graphify/6 A3 hook sem end vira comando à mão"
assert_eq "$antes_h" "$(md5sum 2>/dev/null < "$P/.git/hooks/post-commit")" "remover-graphify/5 A3 hook sem end fica intocado"
# A4 (/4) — arquivo versionado REMOVIDO também sai como versionado (pasta rastreada; hook em core.hooksPath versionado)
mkproj; mkdir -p "$P/.githooks"
printf '%s\n' '#!/bin/sh' '# graphify-checkout-hook-start' 'x' '# graphify-checkout-hook-end' > "$P/.githooks/post-checkout"
printf '%s\n' '#!/bin/sh' 'echo meu' '# graphify-hook-start' 'x' '# graphify-hook-end' > "$P/.githooks/post-commit"
git -C "$P" add -A; git -C "$P" add -f graphify-out/graph.json   # pasta versionada antes do .gitignore
git -C "$P" -c core.hooksPath="$SP/sem-hooks" commit -qm hooks-versionados; git -C "$P" config core.hooksPath .githooks
fake '' ''; lim --remover .
assert_eq 0 "$code" "remover-graphify/4 A4 remoção com hooks versionados sai 0"
for v in graphify-out/graph.json .githooks/post-checkout .githooks/post-commit; do
  assert_contains "$out" "versionado $v" "remover-graphify/4 A4 relata versionado $v"
done
# menores (/5) — CRLF e ausência de newline final preservados; números do settings literais
vis() { perl -0777 -pe 's/\r/\\r/g; s/\n/\\n/g' 2>/dev/null < "$1"; }
mkvazio; mkdir -p "$P/.claude"
printf '## Constituição\r\n- **stack**: bash\r\n- **graphify**: ativo\r\n- **gate**: x' > "$P/MEMORY.md"
printf 'node_modules/\r\ngraphify-out/\r\n*.log' > "$P/.gitignore"
printf '# P\r\n## graphify\r\nx\r\n## Outra\r\nfim' > "$P/CLAUDE.md"
printf '#!/bin/sh\r\necho meu\r\n# graphify-hook-start\r\nx\r\n# graphify-hook-end\r\necho fim' > "$P/.git/hooks/post-commit"
printf '{\r\n  "n": 1.50,\r\n  "big": 10000000000000000000000,\r\n  "e": 1e3,\r\n  "hooks": {"PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "graphify x"}]}]}\r\n}' > "$P/.claude/settings.json"
fake '' ''; lim --remover .
assert_eq 0 "$code" "remover-graphify/5 CRLF remoção sai 0"
assert_eq '## Constituição\r\n- **stack**: bash\r\n- **gate**: x' "$(vis "$P/MEMORY.md")" "remover-graphify/5 MEMORY.md mantém CRLF e sem newline final"
assert_eq 'node_modules/\r\n*.log' "$(vis "$P/.gitignore")" "remover-graphify/5 .gitignore mantém CRLF e sem newline final"
assert_eq '# P\r\n## Outra\r\nfim' "$(vis "$P/CLAUDE.md")" "remover-graphify/5 CLAUDE.md mantém CRLF e sem newline final"
assert_eq '#!/bin/sh\r\necho meu\r\necho fim' "$(vis "$P/.git/hooks/post-commit")" "remover-graphify/5 hook mantém CRLF e sem newline final"
assert_eq '{\r\n  "big": 10000000000000000000000,\r\n  "e": 1e3,\r\n  "n": 1.50\r\n}' "$(vis "$P/.claude/settings.json")" "remover-graphify/5 settings mantém CRLF, sem newline final e números literais"
mkvazio; printf 'node_modules/\r\ngraphify-out/' > "$P/.gitignore"; fake '' ''; lim --remover .
assert_eq 'node_modules/' "$(vis "$P/.gitignore")" "remover-graphify/5 última linha removida não deixa \\r\\n sobrando"
mkvazio; printf 'a\ngraphify-out/\nb\n' > "$P/.gitignore"; lim --remover .
assert_eq 'a\nb\n' "$(vis "$P/.gitignore")" "remover-graphify/5 LF com newline final continua igual"
# menores (/2,/5) — bullet graphify: só DENTRO da Constituição é resto
mkvazio; printf '%s\n' '' '## Notas' '- **graphify**: citado em nota, não é Constituição' >> "$P/MEMORY.md"; fake '' ''; lim .
assert_empty "$out" "remover-graphify/2 bullet graphify fora da Constituição não é resto"
printf '%s\n' '## Constituição' '- **graphify**: ativo' '- **gate**: x' '## Notas' '- **graphify**: nota' > "$P/MEMORY.md"; lim --remover .
assert_eq "$(printf '%s\n' '## Constituição' '- **gate**: x' '## Notas' '- **graphify**: nota')" "$(cat "$P/MEMORY.md")" "remover-graphify/5 só o bullet da Constituição sai"
# menores — dir inexistente: erro no stderr e exit 2, coerente com o cabeçalho
lim "$SP/nao-existe"
assert_eq 2 "$code" "graphify-limpeza dir inexistente sai 2"
assert_contains "$out" 'diretório inexistente' "graphify-limpeza dir inexistente avisa"
lim --remover "$SP/nao-existe"
assert_eq 2 "$code" "graphify-limpeza --remover dir inexistente sai 2"
assert_contains "$(sed -n '1,25p' "$L")" 'dir inexistente' "graphify-limpeza cabeçalho documenta dir inexistente"
# B1 (/2,/5) — hook do Graphify = binário graphify no 1º token (formato REAL: caminho
# absoluto entre aspas, .EXE), com ou sem caminho/aspas/.exe, ou via uvx; nome parecido não é
hk1() { printf '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"%s"}]}]}}\n' "$1"; }
REAL='\"C:\\Users\\Italo Barros\\.local\\bin\\graphify.EXE\" hook-guard search'
for c in "$REAL" '/usr/local/bin/graphify hook-guard read' 'uvx graphify hook-guard glob' 'graphify.exe hook-guard grep'; do
  mkvazio; mkdir -p "$P/.claude"; hk1 "$c" > "$P/.claude/settings.local.json"; fake '' ''; lim .
  assert_eq 'settings .claude/settings.local.json' "$out" "remover-graphify/2 B1 hook do Graphify detectado: $c"
done
for c in 'rm -rf old-graphify-backup' 'graphify-backup.sh' './scripts/graphify-backup.sh' 'uvx graphify-backup run'; do
  mkvazio; mkdir -p "$P/.claude"; hk1 "$c" > "$P/.claude/settings.local.json"; fake '' ''; lim .
  assert_empty "$out" "remover-graphify/2 B1 comando alheio não é resto: $c"
done
mkvazio; mkdir -p "$P/.claude"
printf '%s\n' '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"'"$REAL"'"},{"type":"command","command":"meu-guard"}]},{"matcher":"Read","hooks":[{"type":"command","command":"/usr/local/bin/graphify hook-guard read"}]},{"matcher":"Glob","hooks":[{"type":"command","command":"uvx graphify hook-guard glob"}]},{"matcher":"Grep","hooks":[{"type":"command","command":"graphify.exe hook-guard grep"}]}],"Stop":[{"hooks":[{"type":"command","command":"rm -rf old-graphify-backup"},{"type":"command","command":"graphify-backup.sh"},{"type":"command","command":"./scripts/graphify-backup.sh"}]}]}}' > "$P/.claude/settings.json"
fake '' ''; lim --remover .
assert_eq 0 "$code" "remover-graphify/5 B1 remoção sai 0"
assert_eq 'removido settings .claude/settings.json' "$out" "remover-graphify/4 B1 relata o settings"
perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' < "$P/.claude/settings.json" 2>/dev/null && ok || ko "remover-graphify/5 B1 settings JSON inválido"
sj="$(cat "$P/.claude/settings.json")"
assert_not_contains "$sj" 'hook-guard' "remover-graphify/5 B1 as 4 variantes do Graphify saíram"
for s in '"meu-guard"' '"matcher": "Bash"' 'rm -rf old-graphify-backup' '"graphify-backup.sh"' './scripts/graphify-backup.sh'; do
  assert_contains "$sj" "$s" "remover-graphify/5 B1 preserva $s"
done
for s in '"Read"' '"Glob"' '"Grep"'; do
  assert_not_contains "$sj" "$s" "remover-graphify/5 B1 grupo $s que ficou vazio sai"
done
# M1 (/5) — comentário que cita graphify logo acima de graphify-out/ sai junto; o resto fica
mkvazio; printf '%s\n' 'node_modules/' '# comentário alheio' '# graphify: índice local' 'graphify-out/' '*.log' > "$P/.gitignore"; fake '' ''; lim --remover .
assert_eq "$(printf '%s\n' 'node_modules/' '# comentário alheio' '*.log')" "$(cat "$P/.gitignore")" "remover-graphify/5 M1 comentário do Graphify acima de graphify-out/ sai; alheio fica"
mkvazio; printf '%s\n' '# Graphify também gera cache' 'dist/' 'graphify-out/' > "$P/.gitignore"; lim --remover .
assert_eq "$(printf '%s\n' '# Graphify também gera cache' 'dist/')" "$(cat "$P/.gitignore")" "remover-graphify/5 M1 comentário que não está logo acima fica"
# M2 (/2,/5) — "## graphify" dentro de bloco cercado não é seção; cerca dentro da seção não a fecha
mkvazio; printf '%s\n' '# P' '```md' '## graphify' 'exemplo' '```' 'texto depois' '### sub' > "$P/CLAUDE.md"; fake '' ''; lim .
assert_empty "$out" "remover-graphify/2 M2 ## graphify dentro de cerca não é resto"
antes_c="$(md5sum < "$P/CLAUDE.md")"; printf 'graphify-out/\n' >> "$P/.gitignore"; lim --remover .
assert_eq 'removido gitignore .gitignore' "$out" "remover-graphify/4 M2 só o .gitignore sai"
assert_eq "$antes_c" "$(md5sum < "$P/CLAUDE.md")" "remover-graphify/5 M2 CLAUDE.md com ## graphify cercado fica intocado"
mkvazio; printf '%s\n' '# P' '## graphify' '~~~sh' '## x' '~~~' 'y' '## Outra' 'fim' > "$P/CLAUDE.md"; lim --remover .
assert_eq "$(printf '%s\n' '# P' '## Outra' 'fim')" "$(cat "$P/CLAUDE.md")" "remover-graphify/5 M2 cerca dentro da seção do Graphify sai junto; ## Outra fica"
report
