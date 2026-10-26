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

# ===================== T10 — aplicar: apaga do disco as sobras locais aprovadas =====================
LOCAIS='docs/audora/specs/d-escopo.md docs/audora/planos/arquivo/plano-d.md docs/audora/e2e/e2e-d.md docs/audora/e2e/d'
L="$SP/lote.txt"
# --- gitignore-padrao/16 apaga o aprovado ---
p="$SP/a16"; mkloc "$p"; h0="$(git -C "$p" rev-parse HEAD)"
runc "$p" varrer; printf '%s\n' "$out" > "$L"
runc "$p" aplicar "$L"
assert_eq 0 "$code" "gitignore-padrao/16 aplicar → exit 0"
assert_eq 'cleanup: 4 sobra(s) local(is) apagada(s) do disco — sem volta' "$out" "gitignore-padrao/16 aplicar → mensagem"
for f in $LOCAIS; do assert_no_file "$p/$f" "gitignore-padrao/16 $f apagado do disco"; done
[ -d "$p/docs/audora/e2e/d" ] && ko "gitignore-padrao/16 pasta de evidência ainda existe" || ok
assert_eq "$h0" "$(git -C "$p" rev-parse HEAD)" "gitignore-padrao/16 só local → sem commit"
assert_empty "$(git -C "$p" status --porcelain)" "gitignore-padrao/16 git intocado"

# --- gitignore-padrao/16 respeita a retirada de itens ---
p="$SP/a16r"; mkloc "$p"
runc "$p" varrer; printf '%s\n' "$out" | grep -vxF -- '- docs/audora/specs/d-escopo.md | nó d delivered' > "$L"
runc "$p" aplicar "$L"
assert_eq 'cleanup: 3 sobra(s) local(is) apagada(s) do disco — sem volta' "$out" "gitignore-padrao/16 item retirado → 3 apagados"
assert_file "$p/docs/audora/specs/d-escopo.md" "gitignore-padrao/16 item retirado fica no disco"
assert_no_file "$p/docs/audora/e2e/e2e-d.md" "gitignore-padrao/16 os outros saem"

# --- gitignore-padrao/16 sem aprovação nada é apagado ---
p="$SP/a16n"; mkloc "$p"; antes="$(snap "$p")"
runc "$p" varrer; printf '%s\n' "$out" | grep -v '^- ' > "$L"
runc "$p" aplicar "$L"
assert_eq 'cleanup: lote vazio — nada aplicado' "$out" "gitignore-padrao/16 humano tirou todos → lote vazio"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/16 sem aprovação → nada apagado"

# mkmisto <dir> — mkloc + nó d2 delivered com spec RASTREADA
mkmisto() {
  mkloc "$1"
  printf -- '- d2 | delivered | D2 → docs/audora/arquivo/2026-01-01-d2.md\n' >> "$1/MEMORY.md"
  printf -- '---\nid: d2\nestado: delivered\n---\n# d2\n' > "$1/docs/audora/arquivo/2026-01-01-d2.md"
  git -C "$1" add -A; git -C "$1" commit -qm d2
  git -C "$1" add -f docs/audora/specs/d2-escopo.md 2>/dev/null
  mkdir -p "$1/docs/audora/specs"; printf 'x\n' > "$1/docs/audora/specs/d2-escopo.md"
  git -C "$1" add -f docs/audora/specs/d2-escopo.md; git -C "$1" commit -qm 'spec d2 rastreada'
}
# --- gitignore-padrao/16 lote misto: 1 commit só com o rastreado, depois o local ---
p="$SP/a16m"; mkmisto "$p"; h0="$(git -C "$p" rev-parse HEAD)"
runc "$p" varrer; printf '%s\n' "$out" > "$L"
assert_line "$(secao "$out" 'spec de nó entregue')" '- docs/audora/specs/d2-escopo.md | nó d2 delivered' "gitignore-padrao/16 misto: spec rastreada no tipo próprio"
runc "$p" aplicar "$L"
assert_eq 0 "$code" "gitignore-padrao/16 misto → exit 0"
h="$(git -C "$p" rev-parse --short=7 HEAD)"
assert_eq "cleanup: commit $h — 1 item(ns) removido(s)
cleanup: 4 sobra(s) local(is) apagada(s) do disco — sem volta" "$out" "gitignore-padrao/16 misto → commit + apagados"
assert_eq "$h0" "$(git -C "$p" rev-parse HEAD^)" "gitignore-padrao/16 misto → 1 commit"
assert_eq 'D	docs/audora/specs/d2-escopo.md' "$(git -C "$p" show --name-status --format= HEAD)" "gitignore-padrao/16 misto → commit só com o rastreado"
assert_eq 'chore(cleanup): remove 1 sobra(s) do processo' "$(git -C "$p" log -1 --format=%s)" "gitignore-padrao/16 misto → commit conta só o rastreado"
for f in $LOCAIS; do assert_no_file "$p/$f" "gitignore-padrao/16 misto: $f apagado"; done

# --- gitignore-padrao/16 commit falha → nada local apagado ---
p="$SP/a16f"; mkmisto "$p"; printf '#!/bin/sh\nexit 1\n' > "$p/.git/hooks/pre-commit"; chmod +x "$p/.git/hooks/pre-commit"
h0="$(git -C "$p" rev-parse HEAD)"; antes="$(snap "$p")"
runc "$p" varrer; printf '%s\n' "$out" > "$L"
runc "$p" aplicar "$L"
assert_eq 1 "$code" "gitignore-padrao/16 commit falha → exit 1"
assert_eq 'cleanup: falhou em: commit — commit recusado
cleanup: lote desfeito, nada commitado' "$out" "gitignore-padrao/16 commit falha → mensagem da cleanup"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/16 commit falha → nada local apagado, git como antes"

# --- gitignore-padrao/16 recusa rastreado, protegido e fora de docs/audora como sobra local ---
p="$SP/a16x"; mkmisto "$p"; antes="$(snap "$p")"
printf '## %s\n- docs/audora/specs/d2-escopo.md | nó d2 delivered\n' "$SV" > "$L"
runc "$p" aplicar "$L"
assert_eq 1 "$code" "gitignore-padrao/16 rastreado como local → exit 1"
assert_contains "$out" 'cleanup: falhou em: - docs/audora/specs/d2-escopo.md | nó d2 delivered — rastreado no git — use o tipo próprio' "gitignore-padrao/16 rastreado como local → recusa"
printf '## %s\n- docs/audora/arquivo/2026-01-01-d.md | x\n' "$SV" > "$L"; runc "$p" aplicar "$L"
assert_contains "$out" '— arquivo lido pelo framework nunca é removido' "gitignore-padrao/16 protegido como local → recusa"
printf '## %s\n- README.md | x\n' "$SV" > "$L"; runc "$p" aplicar "$L"
assert_contains "$out" '— fora de docs/audora/' "gitignore-padrao/16 fora de docs/audora como local → recusa"
printf '## %s\n- docs/audora/specs/nao-ha.md | x\n' "$SV" > "$L"; runc "$p" aplicar "$L"
assert_contains "$out" '— alvo não existe mais' "gitignore-padrao/16 local inexistente → recusa"
assert_eq "$antes" "$(snap "$p")" "gitignore-padrao/16 recusas → nada alterado"

# --- gitignore-padrao/16 falha ao apagar do disco (arquivo travado; só Windows com PowerShell) ---
if command -v powershell.exe >/dev/null 2>&1 && command -v cygpath >/dev/null 2>&1; then
  p="$SP/a16t"; mkmisto "$p"
  runc "$p" varrer; printf '%s\n' "$out" > "$L"
  alvo="$(cygpath -w "$p/docs/audora/specs/d-escopo.md")"
  powershell.exe -NoProfile -Command "\$f=[System.IO.File]::Open('$alvo','Open','Read','None'); New-Item -ItemType File -Path '$(cygpath -w "$SP/travou")' | Out-Null; Start-Sleep -Seconds 20; \$f.Close()" >/dev/null 2>&1 &
  lock=$!; for _ in $(seq 1 100); do [ -f "$SP/travou" ] && break; sleep 0.2; done
  runc "$p" aplicar "$L"
  wait "$lock" 2>/dev/null
  h="$(git -C "$p" rev-parse --short=7 HEAD)"
  assert_eq 1 "$code" "gitignore-padrao/16 falha ao apagar → exit 1"
  assert_eq "cleanup: commit $h — 1 item(ns) removido(s)
cleanup: falhou em: - docs/audora/specs/d-escopo.md | nó d delivered — não consegui apagar do disco
cleanup: commit mantido; sobras locais restantes no disco" "$out" "gitignore-padrao/16 falha ao apagar → commit mantido e aviso"
  assert_file "$p/docs/audora/specs/d-escopo.md" "gitignore-padrao/16 falha ao apagar → arquivo travado fica"
else
  echo "  (pulado: falha ao apagar do disco precisa de PowerShell)"
fi

report
