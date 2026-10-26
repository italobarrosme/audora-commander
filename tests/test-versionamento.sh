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

report
