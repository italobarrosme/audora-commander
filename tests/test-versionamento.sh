#!/usr/bin/env bash
# gitignore-padrao/1,/2,/3,/6,/7,/8,/9,/10 — hooks/versionamento (checar | aplicar [--desligar] [--remover]).
source "$(dirname "$0")/lib.sh"
VS="$ROOT/hooks/versionamento"
USO='uso: versionamento checar | aplicar [--desligar <arquivo>:<linha>]... [--remover]'
BLOCO='# audora-commander: specs, planos, e2e e depuracao ficam so no disco
docs/audora/specs/
docs/audora/planos/
docs/audora/e2e/
docs/audora/depuracao/
# fim audora-commander'
FORA='versionamento: fora do git — checagem de regra e remoção puladas'

# --- fixtures ---
# mkrepo <dir> — repo git vazio, isolado do ignore global da máquina, com 1 commit
mkrepo() {
  local d="$1"; rm -rf "$d"; mkdir -p "$d"
  git -C "$d" init -q
  git -C "$d" config user.email v@test; git -C "$d" config user.name v
  git -C "$d" config core.autocrlf false; git -C "$d" config core.excludesFile "$d/.nao-existe"
  printf '# proj\n' > "$d/README.md"; git -C "$d" add -A; git -C "$d" commit -qm base
}
# runv <dir> <args…> — roda o script na raiz do projeto; define out (stdout+stderr) e code
runv() { local d="$1"; shift; out="$(cd "$d" && bash "$VS" "$@" 2>&1)"; code=$?; }
# snap <dir> — HEAD + status + md5 da árvore (fora do .git)
snap() {
  ( cd "$1" && { git rev-parse HEAD 2>/dev/null; git status --porcelain 2>/dev/null; git diff --cached --name-only 2>/dev/null; } && \
    find . -path ./.git -prune -o -type f -print | LC_ALL=C sort | while IFS= read -r f; do md5sum "$f"; done )
}
md5() { md5sum < "$1" | cut -d' ' -f1; }

# --- uso ---
p="$SP/uso"; mkrepo "$p"
runv "$p"
assert_eq 1 "$code" "uso sem sub → exit 1"
assert_eq "$USO" "$out" "uso sem sub imprime o uso"
runv "$p" xyz
assert_eq 1 "$code" "uso sub desconhecido → exit 1"
assert_eq "$USO" "$out" "uso sub desconhecido imprime o uso"

# --- gitignore-padrao/1 cria .gitignore ---
p="$SP/cria"; mkrepo "$p"
runv "$p" aplicar
assert_eq 0 "$code" "gitignore-padrao/1 cria → exit 0"
assert_eq 'versionamento: .gitignore criado com o bloco do audora' "$out" "gitignore-padrao/1 cria → mensagem"
assert_eq "$BLOCO" "$(cat "$p/.gitignore")" "gitignore-padrao/1 cria → arquivo = bloco"
assert_eq 0 "$(tr -cd '\r' < "$p/.gitignore" | wc -c)" "gitignore-padrao/1 cria → LF"
assert_eq '' "$(tail -c1 "$p/.gitignore" | tr -d '\n')" "gitignore-padrao/1 cria → termina em \\n"

# --- gitignore-padrao/1 acrescenta preservando o resto ---
p="$SP/acresc"; mkrepo "$p"; printf 'node_modules/' > "$p/.gitignore"
runv "$p" aplicar
assert_eq 0 "$code" "gitignore-padrao/1 acrescenta → exit 0"
assert_eq 'versionamento: bloco do audora acrescentado ao .gitignore' "$out" "gitignore-padrao/1 acrescenta → mensagem"
assert_eq "$(printf 'node_modules/\n\n%s\n' "$BLOCO" | md5sum | cut -d' ' -f1)" "$(md5 "$p/.gitignore")" "gitignore-padrao/1 acrescenta sem \\n final → node_modules/ + linha vazia + bloco"

# --- gitignore-padrao/1 CRLF ---
p="$SP/crlf"; mkrepo "$p"; printf 'a\r\nb\r\n' > "$p/.gitignore"
runv "$p" aplicar
assert_eq 0 "$code" "gitignore-padrao/1 CRLF → exit 0"
esperado="$( { printf 'a\r\nb\r\n\r\n'; printf '%s\n' "$BLOCO" | sed 's/$/\r/'; } | md5sum | cut -d' ' -f1)"
assert_eq "$esperado" "$(md5 "$p/.gitignore")" "gitignore-padrao/1 CRLF → bloco com \\r\\n"
assert_eq 9 "$(tr -cd '\r' < "$p/.gitignore" | wc -c)" "gitignore-padrao/1 CRLF → a, b, linha vazia + 6 linhas do bloco com \\r"

# --- gitignore-padrao/2 não duplica ---
p="$SP/dup"; mkrepo "$p"; printf 'dist/\n' > "$p/.gitignore"
runv "$p" aplicar; antes="$(md5 "$p/.gitignore")"
runv "$p" aplicar
assert_eq 0 "$code" "gitignore-padrao/2 2ª execução → exit 0"
assert_eq 'versionamento: bloco do audora já presente — .gitignore intocado' "$out" "gitignore-padrao/2 2ª execução → já presente"
assert_eq "$antes" "$(md5 "$p/.gitignore")" "gitignore-padrao/2 2ª execução → arquivo intocado"
assert_eq 1 "$(grep -c '^# audora-commander:' "$p/.gitignore")" "gitignore-padrao/2 1 marcador só"

# --- gitignore-padrao/2 bloco editado pelo humano ---
p="$SP/editado"; mkrepo "$p"
printf '%s\n' "$BLOCO" | grep -v '^docs/audora/e2e/$' > "$p/.gitignore"; printf 'x/\n' >> "$p/.gitignore"
antes="$(md5 "$p/.gitignore")"
runv "$p" aplicar
assert_eq 'versionamento: bloco do audora já presente — .gitignore intocado' "$out" "gitignore-padrao/2 bloco editado → já presente"
assert_eq "$antes" "$(md5 "$p/.gitignore")" "gitignore-padrao/2 bloco editado → intocado"

# --- gitignore-padrao/2 marcador com \r (CRLF) conta como presente ---
p="$SP/marcacr"; mkrepo "$p"; printf '%s\n' "$BLOCO" | sed 's/$/\r/' > "$p/.gitignore"; antes="$(md5 "$p/.gitignore")"
runv "$p" aplicar
assert_eq 'versionamento: bloco do audora já presente — .gitignore intocado' "$out" "gitignore-padrao/2 marcador CRLF → já presente"
assert_eq "$antes" "$(md5 "$p/.gitignore")" "gitignore-padrao/2 marcador CRLF → intocado"

# --- gitignore-padrao/3 memória segue versionável ---
p="$SP/mem"; mkrepo "$p"; runv "$p" aplicar
for c in MEMORY.md PRD.md CHANGELOG.md docs/audora/memory/x.md docs/audora/arquivo/x.md docs/audora/decisoes-vivas.md \
         docs/audora/aprendizados.md docs/audora/GRAFO-ARQUIVO.md docs/audora/validacao/x.md docs/audora/nos/x.md README.md; do
  git -C "$p" check-ignore -q --no-index "$c"; assert_eq 1 "$?" "gitignore-padrao/3 $c segue versionável"
done
for c in docs/audora/specs/x-escopo.md docs/audora/planos/plano-x.md docs/audora/planos/arquivo/plano-x.md docs/audora/e2e/e2e-x.md \
         docs/audora/e2e/x/shot.png docs/audora/depuracao/cacada-2026-01-01.md; do
  git -C "$p" check-ignore -q --no-index "$c"; assert_eq 0 "$?" "gitignore-padrao/3 $c ignorado"
done

# --- gitignore-padrao/10 fora do git ---
p="$SP/semgit"; rm -rf "$p"; mkdir -p "$p"
runv "$p" aplicar
assert_eq 0 "$code" "gitignore-padrao/10 fora do git → exit 0"
assert_eq "versionamento: .gitignore criado com o bloco do audora
$FORA" "$out" "gitignore-padrao/10 fora do git → bloco + 1 linha de aviso"
assert_eq "$BLOCO" "$(cat "$p/.gitignore" 2>/dev/null)" "gitignore-padrao/10 fora do git → bloco escrito"

# ===================== checar (T2) =====================
QUEBRA='quebra: arquivamento do nó, comando de arquivos do cartão e cleanup'

# --- gitignore-padrao/6 regra do projeto ---
p="$SP/c6"; mkrepo "$p"; printf 'docs/\n' > "$p/.gitignore"
antes="$(snap "$p")"
runv "$p" checar
assert_eq 0 "$code" "gitignore-padrao/6 checar → exit 0"
assert_eq "bloco: ausente
memória ignorada: docs/audora/memory/ | regra .gitignore:1 docs/ | ajuste: aplicar --desligar .gitignore:1
memória ignorada: docs/audora/arquivo/ | regra .gitignore:1 docs/ | ajuste: aplicar --desligar .gitignore:1
memória ignorada: docs/audora/decisoes-vivas.md | regra .gitignore:1 docs/ | ajuste: aplicar --desligar .gitignore:1
memória ignorada: docs/audora/aprendizados.md | regra .gitignore:1 docs/ | ajuste: aplicar --desligar .gitignore:1
$QUEBRA
versionamento: 4 regra(s) escondendo a memória · 0 versionado(s) em pasta efêmera" "$out" "gitignore-padrao/6 checar → regra, arquivo:linha, ajuste e o que quebra"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/6 checar só lê"

# --- gitignore-padrao/6 regra em .gitignore de subpasta ---
p="$SP/c6sub"; mkrepo "$p"; mkdir -p "$p/docs"; printf 'audora/memory/\n' > "$p/docs/.gitignore"
runv "$p" checar
assert_line() { printf '%s\n' "$1" | grep -qxF -- "$2" && ok || ko "$3 — sem a linha '$2'"; }
assert_line "$out" 'memória ignorada: docs/audora/memory/ | regra docs/.gitignore:1 audora/memory/ | ajuste: aplicar --desligar docs/.gitignore:1' "gitignore-padrao/6 .gitignore de subpasta"
assert_contains "$out" 'versionamento: 1 regra(s) escondendo a memória' "gitignore-padrao/6 subpasta → 1 regra"

# --- gitignore-padrao/6 negação não conta ---
p="$SP/c6neg"; mkrepo "$p"; printf '*.md\n!MEMORY.md\n' > "$p/.gitignore"
runv "$p" checar
assert_not_contains "$out" 'memória ignorada: MEMORY.md' "gitignore-padrao/6 negação não conta"
assert_line "$out" 'memória ignorada: PRD.md | regra .gitignore:1 *.md | ajuste: aplicar --desligar .gitignore:1' "gitignore-padrao/6 *.md esconde PRD.md"

# --- gitignore-padrao/7 .git/info/exclude ---
p="$SP/c7exc"; mkrepo "$p"; printf 'CHANGELOG.md\n' > "$p/.git/info/exclude"
antes="$(snap "$p")"
runv "$p" checar
assert_line "$out" 'memória ignorada: CHANGELOG.md | regra .git/info/exclude:1 CHANGELOG.md | fonte fora do projeto — não edito' "gitignore-padrao/7 .git/info/exclude nomeado, não editado"
assert_line "$out" "$QUEBRA" "gitignore-padrao/7 exclude → o que quebra"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/7 checar não edita"

# --- gitignore-padrao/7 ignore global ---
p="$SP/c7glob"; mkrepo "$p"; printf 'PRD.md\n' > "$SP/global-ign"; git -C "$p" config core.excludesFile "$SP/global-ign"
runv "$p" checar
l="$(printf '%s\n' "$out" | grep '^memória ignorada: PRD.md | regra ')"
assert_contains "$l" 'global-ign:1 PRD.md | fonte fora do projeto — não edito' "gitignore-padrao/7 ignore global nomeado, não editado"
assert_eq 1 "$(printf '%s\n' "$out" | grep -c '^memória ignorada:')" "gitignore-padrao/7 global → 1 caminho só"

# --- gitignore-padrao/8 lista versionados em pasta efêmera ---
p="$SP/c8"; mkrepo "$p"; mkdir -p "$p/docs/audora/specs" "$p/docs/audora/e2e/a" "$p/docs/audora/memory"
printf 'x\n' > "$p/docs/audora/specs/a-escopo.md"; printf 'png\n' > "$p/docs/audora/e2e/a/shot.png"; printf 'n\n' > "$p/docs/audora/memory/a.md"
git -C "$p" add -A; git -C "$p" commit -qm efemeros
runv "$p" aplicar; runv "$p" checar
assert_eq "bloco: presente
versionado em pasta efêmera: docs/audora/e2e/a/shot.png
versionado em pasta efêmera: docs/audora/specs/a-escopo.md
versionamento: 0 regra(s) escondendo a memória · 2 versionado(s) em pasta efêmera" "$out" "gitignore-padrao/8 checar lista os versionados"

# --- repo limpo com bloco ---
p="$SP/climpo"; mkrepo "$p"; runv "$p" aplicar; runv "$p" checar
assert_eq "bloco: presente
versionamento: 0 regra(s) escondendo a memória · 0 versionado(s) em pasta efêmera" "$out" "checar repo limpo com bloco"

# --- gitignore-padrao/10 checar fora do git ---
p="$SP/csemgit"; rm -rf "$p"; mkdir -p "$p"; antes="$(snap "$p")"
runv "$p" checar
assert_eq 0 "$code" "gitignore-padrao/10 checar fora do git → exit 0"
assert_eq "bloco: ausente
$FORA" "$out" "gitignore-padrao/10 checar fora do git → bloco + 1 linha"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/10 checar fora do git só lê"

# ===================== aplicar --desligar (T3) =====================
# --- gitignore-padrao/6 desligar com sim ---
p="$SP/d6"; mkrepo "$p"; printf 'docs/\n' > "$p/.gitignore"
runv "$p" aplicar --desligar .gitignore:1
assert_eq 0 "$code" "gitignore-padrao/6 desligar → exit 0"
assert_line "$out" 'versionamento: regra desligada em .gitignore:1 (docs/)' "gitignore-padrao/6 desligar → mensagem"
assert_line "$out" 'versionamento: bloco do audora acrescentado ao .gitignore' "gitignore-padrao/6 desligar → bloco escrito"
assert_eq '# desligado pelo audora-commander: docs/' "$(head -1 "$p/.gitignore")" "gitignore-padrao/6 linha comentada"
runv "$p" checar
assert_line "$out" 'versionamento: 0 regra(s) escondendo a memória · 0 versionado(s) em pasta efêmera' "gitignore-padrao/6 depois do desligar nada esconde a memória"

# --- gitignore-padrao/6 desligar preserva CRLF e o resto ---
p="$SP/d6crlf"; mkrepo "$p"; printf 'dist/\r\ndocs/\r\nx/\r\n' > "$p/.gitignore"
runv "$p" aplicar --desligar .gitignore:2
assert_eq "$(printf 'dist/\r\n# desligado pelo audora-commander: docs/\r\nx/\r\n' | md5sum | cut -d' ' -f1)" \
  "$(head -3 "$p/.gitignore" | md5sum | cut -d' ' -f1)" "gitignore-padrao/6 desligar preserva CRLF e as outras linhas"

# --- gitignore-padrao/6 regra em subpasta ---
p="$SP/d6sub"; mkrepo "$p"; mkdir -p "$p/docs"; printf 'audora/memory/\n' > "$p/docs/.gitignore"
runv "$p" aplicar --desligar docs/.gitignore:1
assert_eq 0 "$code" "gitignore-padrao/6 desligar em docs/.gitignore → exit 0"
assert_eq '# desligado pelo audora-commander: audora/memory/' "$(cat "$p/docs/.gitignore")" "gitignore-padrao/6 docs/.gitignore comentado"

# --- gitignore-padrao/7 recusa .git/info/exclude ---
p="$SP/d7exc"; mkrepo "$p"; printf 'CHANGELOG.md\n' > "$p/.git/info/exclude"; antes="$(snap "$p")"; excl="$(md5 "$p/.git/info/exclude")"
runv "$p" aplicar --desligar .git/info/exclude:1
assert_eq 1 "$code" "gitignore-padrao/7 desligar exclude → exit 1"
assert_eq 'versionamento: .git/info/exclude fica fora do projeto — não edito; nada foi alterado' "$out" "gitignore-padrao/7 desligar exclude → recusa"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/7 recusa → nada alterado (nem o bloco)"
assert_eq "$excl" "$(md5 "$p/.git/info/exclude")" "gitignore-padrao/7 exclude intocado"

# --- gitignore-padrao/7 recusa caminho absoluto e fora da raiz ---
p="$SP/d7abs"; mkrepo "$p"; antes="$(snap "$p")"
runv "$p" aplicar --desligar "$SP/global-ign:1"
assert_eq 1 "$code" "gitignore-padrao/7 desligar absoluto → exit 1"
assert_eq "versionamento: $SP/global-ign fica fora do projeto — não edito; nada foi alterado" "$out" "gitignore-padrao/7 desligar absoluto → recusa"
runv "$p" aplicar --desligar ../.gitignore:1
assert_eq 'versionamento: ../.gitignore fica fora do projeto — não edito; nada foi alterado' "$out" "gitignore-padrao/7 desligar ../ → recusa"
runv "$p" aplicar --desligar README.md:1
assert_eq 'versionamento: README.md fica fora do projeto — não edito; nada foi alterado' "$out" "gitignore-padrao/7 desligar arquivo que não é .gitignore → recusa"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/7 recusas → nada alterado"

# --- gitignore-padrao/6 linha que não é regra ---
p="$SP/d6lin"; mkrepo "$p"; printf 'docs/\n# comentario\n\n' > "$p/.gitignore"; antes="$(snap "$p")"
for a in .gitignore:9 .gitignore:2 .gitignore:3 .gitignore:0; do
  runv "$p" aplicar --desligar "$a"
  assert_eq 1 "$code" "gitignore-padrao/6 $a → exit 1"
  assert_eq "versionamento: $a não é regra ativa — nada foi alterado" "$out" "gitignore-padrao/6 $a → não é regra ativa"
done
runv "$p" aplicar --desligar .gitignore:1 --desligar .gitignore:9
assert_eq 1 "$code" "gitignore-padrao/6 2º --desligar inválido → exit 1"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/6 um --desligar inválido → nada alterado (nem o 1º)"
runv "$p" aplicar --desligar
assert_eq 1 "$code" "--desligar sem argumento → exit 1"
assert_eq "$USO" "$out" "--desligar sem argumento → uso"
runv "$p" aplicar --desligar .gitignore
assert_eq "$USO" "$out" "--desligar sem :linha → uso"
assert_eq "$antes" "$(snap "$p")" "flag inválida → nada alterado"

report
