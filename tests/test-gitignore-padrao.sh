#!/usr/bin/env bash
# gitignore-padrao/1,/4-/16 — contratos de texto das skills e o sync com pastas efêmeras fora do git.
# O mecânico do .gitignore é provado em tests/test-versionamento.sh; a cleanup local em tests/test-cleanup-local.sh.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
achata() { cat "$@" 2>/dev/null | tr -d '\r' | tr '\n' ' ' | tr -s ' '; }

# ===================== T5 — skill memory: bootstrap e oferta única =====================
MS=skills/memory/SKILL.md; MR=skills/memory/references; VR="$MR/versionamento.md"
assert_file "$VR" "gitignore-padrao/4 reference versionamento existe"
[ "$(wc -l < "$VR" 2>/dev/null || echo 999)" -le 250 ] && ok || ko "gitignore-padrao/4 reference ≤ 250 linhas"
v="$(achata "$VR")"
assert_contains "$v" 'bash "<raiz do plugin>/hooks/versionamento"' "gitignore-padrao/4 reference chama o script"
assert_contains "$v" 'Bootstrap: rode `aplicar` sem perguntar e registre `versionamento: aplicado` na Constituição.' "gitignore-padrao/1 bootstrap aplica sem perguntar"
assert_contains "$v" 'Oferta (carregar-contexto, item 7): mostre o que passa a ser ignorado — `docs/audora/specs/`, `docs/audora/planos/`, `docs/audora/e2e/`, `docs/audora/depuracao/` — e a saída do `checar`; pergunte UMA vez.' "gitignore-padrao/4 oferta única mostra o ignorado"
assert_contains "$v" 'Recusou → registre `versionamento: recusado` e não reoferte, salvo pedido do humano.' "gitignore-padrao/5 recusado não reoferta"
assert_contains "$v" 'Linha `memória ignorada:` → mostre a regra, a linha `quebra:` e proponha o ajuste; `--desligar` só com sim.' "gitignore-padrao/6 regra que esconde a memória"
assert_contains "$v" '`fonte fora do projeto — não edito` → nomeie a fonte e não a edite.' "gitignore-padrao/7 fonte externa"
assert_contains "$v" 'Linha `versionado em pasta efêmera:` → liste-os e pergunte; `--remover` só com sim; sem sim, nada sai do git.' "gitignore-padrao/8 versionados com sim"
assert_contains "$v" '`commit falhou` → repasse a linha ao humano: o script já desfez as remoções.' "gitignore-padrao/9 commit falhou"
assert_contains "$v" 'Fora do git → repasse em 1 linha a saída do script.' "gitignore-padrao/10 fora do git"
m="$(achata "$MS")"
assert_contains "$m" '| versionamento | references/versionamento.md |' "gitignore-padrao/4 tabela do roteador"
assert_contains "$m" '7. Constituição sem bullet `versionamento:` → ANTES de ofertar, leia `references/versionamento.md` e rode o `checar`; oferte UMA vez o bloco do `.gitignore` mostrando as 4 pastas que passam a ser ignoradas e a saída do `checar`; `versionamento: recusado` → não reofertar, só se o humano pedir.' "gitignore-padrao/4,/5 item 7 manda ler a reference e mostrar pastas + checar (debug do e2e)"
b="$(achata "$MR/bootstrap.md")"
assert_contains "$b" '**Etapa versionamento** (sempre, antes da etapa gate)' "gitignore-padrao/1 bootstrap tem a etapa"
assert_contains "$b" 'references/versionamento.md' "gitignore-padrao/1 bootstrap aponta a reference"
assert_contains "$(achata templates/MEMORY-template.md)" '- **versionamento**: aplicado | recusado (skill memory, `references/versionamento.md`)' "gitignore-padrao/1 template da Constituição"

# ===================== T6 — e2e: veredito por critério no nó, evidência em docs/audora/e2e/ =====================
e="$(achata skills/e2e/SKILL.md)"
assert_contains "$e" '`- <id>/<n> · passou · <evidência em 1 frase>`' "gitignore-padrao/11 linha por critério no nó"
assert_contains "$e" 'no campo `## e2e` do nó' "gitignore-padrao/11 grava no campo ## e2e do nó"
assert_contains "$e" 'relatório: local: docs/audora/e2e/e2e-<id>.md' "gitignore-padrao/11 relatório como local:"
assert_contains "$e" 'screenshot, vídeo ou trace em `docs/audora/e2e/<id>/`' "gitignore-padrao/12 evidência binária em docs/audora/e2e/<id>/"
assert_not_contains "$e" '`falhou`' "gitignore-padrao/11 veredito reprovou, não falhou"
nt="$(achata templates/no-template.md)"
assert_contains "$nt" 'relatório: local: docs/audora/e2e/e2e-<id>.md' "gitignore-padrao/11 no-template: relatório local:"
assert_contains "$nt" '`- <id>/<n> · passou|reprovou|não-automatizável · <evidência em 1 frase>`' "gitignore-padrao/11 no-template: linha por critério"
assert_not_contains "$nt" '../e2e/e2e-<id>.md' "gitignore-padrao/13 no-template sem link relativo ao relatório"
[ "$(wc -l < skills/e2e/SKILL.md)" -le 250 ] && ok || ko "gitignore-padrao/11 e2e ≤ 250 linhas"

# ===================== T7 — regra local: no roteador da skill memory =====================
assert_contains "$(achata skills/memory/SKILL.md)" 'Pastas efêmeras (`docs/audora/specs/`, `planos/`, `e2e/`, `depuracao/`) ficam fora do git: em nó, índice, PRD, CHANGELOG, decisões vivas e aprendizados, cite caminho delas só como texto `local: <caminho>`, nunca link — e nunca no `git add`.' "gitignore-padrao/13 regra local: no roteador"

# ===================== T8 — gitignore-padrao/14 sync com spec, plano e e2e fora do git =====================
# bloco <arquivo> <termo> → corpo do 1º bloco ```bash do arquivo que contém <termo> (sem \r)
bloco() { tr -d '\r' < "$1" | T="$2" perl -0ne 'while (/```bash\n(.*?)```/sg) { my $b = $1; if (index($b, $ENV{T}) >= 0) { print $b; last } }'; }
SY=skills/validate/references/sync.md
PL="$(bloco "$SY" 'plano-<id>')"
CR="$(bloco "$SY" 'cria=')"
CA="$(bloco templates/bloco-fechamento-template.md 'numstat')"
assert_contains "$PL" 'git ls-files --error-unmatch -- "$p"' "gitignore-padrao/14 sync move o plano conforme o git"
assert_contains "$(achata "$SY")" 'O commit do sync leva só a memória versionada.' "gitignore-padrao/14 commit do sync só com a memória versionada"
assert_contains "$CA" 'numstat' "gitignore-padrao/14 comando de arquivos do cartão extraído"
# mkz <dir> <com-bloco 1|0> — repo com nó z criado em docs(z): escopo, feat(z/1) e spec/plano/e2e de z no disco
mkz() {
  local d="$1"; rm -rf "$d"; mkdir -p "$d/docs/audora/memory" "$d/docs/audora/arquivo"
  git -C "$d" init -q; git -C "$d" config user.email z@t; git -C "$d" config user.name z
  git -C "$d" config core.autocrlf false; git -C "$d" config core.excludesFile "$d/.nao-existe"; git -C "$d" config core.hooksPath "$d/.nao-existe"
  printf '# MEMORY\n\n## Índice de nós\n\n' > "$d/MEMORY.md"
  [ "$2" = 1 ] && (cd "$d" && bash "$ROOT/hooks/versionamento" aplicar >/dev/null)
  git -C "$d" add -A; git -C "$d" commit -qm 'chore: base'
  printf -- '- z | in-progress | Z | r | k | src/\n' >> "$d/MEMORY.md"
  printf '# z\n\n## criterios-aceite\n\n- **z/1** — QUANDO a O SISTEMA DEVE b\n' > "$d/docs/audora/memory/z.md"
  mkdir -p "$d/docs/audora/specs" "$d/docs/audora/planos" "$d/docs/audora/e2e/z"
  printf 'spec\n' > "$d/docs/audora/specs/z-escopo.md"; printf 'plano\n' > "$d/docs/audora/planos/plano-z.md"
  git -C "$d" add -A; git -C "$d" commit -qm 'docs(z): escopo e plano'
  mkdir -p "$d/src"; printf 'a\nb\n' > "$d/src/a.txt"; git -C "$d" add -A; git -C "$d" commit -qm 'feat(z/1): a'
  printf 'rel\n' > "$d/docs/audora/e2e/e2e-z.md"; printf 'png\n' > "$d/docs/audora/e2e/z/shot.png"
}
# syncz <dir> → roda o movimento do sync (nó + bloco do plano) e o commit do sync; define rc_pl, rc_sy
syncz() {
  ( cd "$1" && git mv docs/audora/memory/z.md docs/audora/arquivo/2026-01-01-z.md &&
    sed -i 's#^- z | in-progress | .*#- z | delivered | Z → docs/audora/arquivo/2026-01-01-z.md#' MEMORY.md ); rc_mv=$?
  ( cd "$1" && printf '%s\n' "$PL" | sed 's/<id>/z/g' | bash ) > "$SP/pl.out" 2>&1; rc_pl=$?
  ( cd "$1" && git add -A && git commit -qm 'docs(z): sync' ) > "$SP/sy.out" 2>&1; rc_sy=$?
}

p="$SP/s14"; mkz "$p" 1; syncz "$p"
assert_eq 0 "$rc_mv" "gitignore-padrao/14 git mv do nó"
assert_eq 0 "$rc_pl" "gitignore-padrao/14 bloco do plano sai 0 com plano fora do git ($(cat "$SP/pl.out"))"
assert_file "$p/docs/audora/planos/arquivo/plano-z.md" "gitignore-padrao/14 plano arquivado no disco"
assert_no_file "$p/docs/audora/planos/plano-z.md" "gitignore-padrao/14 plano saiu da pasta ativa"
assert_empty "$(git -C "$p" ls-files docs/audora/specs docs/audora/planos docs/audora/e2e)" "gitignore-padrao/14 nada efêmero no git"
assert_eq 0 "$rc_sy" "gitignore-padrao/14 commit do sync sai 0 ($(cat "$SP/sy.out"))"
assert_empty "$(git -C "$p" status --porcelain)" "gitignore-padrao/14 árvore limpa depois do sync"
cria=$(cd "$p" && git log --diff-filter=A --format=%H -- "docs/audora/memory/z.md" "docs/audora/arquivo/"*"-z.md" | tail -1)
assert_eq "MEMORY.md
docs/audora/arquivo/2026-01-01-z.md
src/a.txt" "$(git -C "$p" diff --name-only "$cria^..HEAD" | sort)" "gitignore-padrao/14 arquivos: do diff real sem pasta efêmera"
cr_out="$(cd "$p" && printf '%s\n' "$CR" | sed 's/<id>/z/g' | bash 2>&1)"; cr_rc=$?
assert_eq 0 "$cr_rc" "gitignore-padrao/14 comando arquivos: do sync sai 0"
assert_contains "$cr_out" 'src/a.txt' "gitignore-padrao/14 comando arquivos: do sync lista o código"
ca_err="$(cd "$p" && printf '%s\n' "$CA" | sed 's/<id>/z/g' | bash 2>&1 >/dev/null)"
ca_out="$(cd "$p" && printf '%s\n' "$CA" | sed 's/<id>/z/g' | bash 2>/dev/null)"; ca_rc=$?
assert_eq 0 "$ca_rc" "gitignore-padrao/14 comando de arquivos do cartão sai 0"
assert_empty "$ca_err" "gitignore-padrao/14 comando de arquivos do cartão sem erro"
printf '%s\n' "$ca_out" | grep -qE '^[0-9]+ arquivos · \+[0-9]+ −[0-9]+$' && ok || ko "gitignore-padrao/14 cartão: '$ca_out' fora do formato"

# plano rastreado (sem bloco) → git mv
p="$SP/s14t"; mkz "$p" 0; syncz "$p"
assert_eq 0 "$rc_pl" "gitignore-padrao/14 plano rastreado → bloco sai 0"
assert_eq 'docs/audora/planos/arquivo/plano-z.md' "$(git -C "$p" ls-files docs/audora/planos)" "gitignore-padrao/14 plano rastreado → git mv para o arquivo"
assert_eq 'R100	docs/audora/planos/plano-z.md	docs/audora/planos/arquivo/plano-z.md' "$(git -C "$p" show -M --name-status --format= HEAD | grep 'plano-z')" "gitignore-padrao/14 plano rastreado → renomeado no commit do sync"

# sem plano (LIGHT ou removido) → nada muda, sai 0
p="$SP/s14s"; mkz "$p" 1; rm -f "$p/docs/audora/planos/plano-z.md"
antes="$(cd "$p" && find docs/audora/planos -type f | sort)"
( cd "$p" && printf '%s\n' "$PL" | sed 's/<id>/z/g' | bash ) >/dev/null 2>&1; assert_eq 0 "$?" "gitignore-padrao/14 sem plano → bloco sai 0"
assert_eq "$antes" "$(cd "$p" && find docs/audora/planos -type f | sort)" "gitignore-padrao/14 sem plano → nada muda"

# ===================== T11 — skill cleanup e READMEs =====================
cl="$(achata skills/cleanup/SKILL.md)"
assert_contains "$cl" '| sem volta (fora do git) | spec, plano e e2e (com a pasta de evidência) de nó delivered ou discarded e caçada sem nó vivo, só no disco — apagar não tem volta no git |' "gitignore-padrao/15 skill cleanup: tipo sem volta na tabela"
assert_contains "$cl" 'cleanup: <M> sobra(s) local(is) apagada(s) do disco — sem volta' "gitignore-padrao/16 skill cleanup: reporta as sobras locais apagadas"
assert_contains "$cl" 'sem `git revert` para elas' "gitignore-padrao/16 skill cleanup: sem revert para o local"
[ "$(wc -l < skills/cleanup/SKILL.md)" -le 250 ] && ok || ko "gitignore-padrao/15 skill cleanup ≤ 250 linhas"
for r in README.md README.pt-BR.md; do
  assert_contains "$(cat "$r")" 'hooks/versionamento' "gitignore-padrao/1 $r cita hooks/versionamento"
done
assert_contains "$(achata README.md)" 'local only (kept out of git by the audora block in `.gitignore`)' "gitignore-padrao/1 README EN: pastas locais"
assert_contains "$(achata README.pt-BR.md)" 'só locais (fora do git pelo bloco do audora no `.gitignore`)' "gitignore-padrao/1 README PT: pastas locais"

report
