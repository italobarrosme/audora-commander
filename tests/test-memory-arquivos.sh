#!/usr/bin/env bash
# sync-mecanizado/1,/1b,/5,/7,/8,/10,/11 — hooks/memory-arquivos em fixture git real.
# O script faz UMA coisa: descobre a base da demanda e imprime a linha
# `arquivos:`. Nao escreve nada.
source "$(dirname "$0")/lib.sh"
SYNC="$ROOT/hooks/memory-arquivos"
REAL_HEAD="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo sem-git)"

# Snapshot de TODA a arvore, .git incluso, mais um sentinela FORA do repo.
# Guarda por lista negra de string ('sed -i', ' > ') e peneira: a 3a revisao
# provou 9 escritas escapando, uma delas comentando a linha 1 do MEMORY.md e
# desarmando memory-validate e memory-guard para sempre.
SENT="$SP/sentinela"
snap() { mkdir -p "$SENT"; { find . -type f -newermt '1970-01-01' -printf '%p %s %T@\n' 2>/dev/null | sort; find "$SENT" -type f 2>/dev/null | sort; } | md5sum; }

fixture() {
  F="$SP/fx_$RANDOM$RANDOM"
  mkdir -p "$F/docs/audora/arquivo" "$F/docs/audora/planos" "$F/docs/audora/memory" || return 1
  cd "$F" || return 1
  git init -q || return 1
  git config user.email e2e@x || return 1
  git config user.name e2e || return 1
  printf 'memory-schema: 1\n\n# MEMORY\n\n## Índice de nós [carga: sempre]\n\n- no-x | in-progress | Migrar CSV → Parquet | resumo com | pipe | k1 | src/\n- no-x-historico | planned | Vizinho | nao tocar | k | s/\n' > MEMORY.md
  printf 'a\n' > alfa.txt
  # cita 'no-x' de proposito ANTES da criacao do no (cenario do achado 1 da
  # 1a revisao: derivar por --grep pegaria ESTE commit)
  git add -A >/dev/null 2>&1 && git commit -qm "chore(memory): registra os nos no-x e no-x-historico" >/dev/null 2>&1 || return 1
  printf -- '---\nid: no-x\nestado: in-progress\narquivos: []\n---\n\n# no-x\n' > docs/audora/memory/no-x.md
  printf -- '# frio\n' > docs/audora/memory/no-x-historico.md
  git add -A >/dev/null 2>&1 && git commit -qm "docs(no-x): abre o no" >/dev/null 2>&1 || return 1
  # DOIS commits de trabalho: assim base..HEAD != HEAD~1..HEAD, e a mutacao
  # diff-head1 (que passava verde nas rodadas 2 e 3) reprova.
  printf 'b\n' > beta.txt
  git add -A >/dev/null 2>&1 && git commit -qm "feat(no-x/1): primeira parte" >/dev/null 2>&1 || return 1
  printf 'c\n' > gama.txt
  git add -A >/dev/null 2>&1 && git commit -qm "feat(no-x/2): segunda parte" >/dev/null 2>&1 || return 1
  git mv docs/audora/memory/no-x.md docs/audora/arquivo/2026-09-04-no-x.md >/dev/null 2>&1 || return 1
  git mv docs/audora/memory/no-x-historico.md docs/audora/arquivo/2026-09-04-no-x-historico.md >/dev/null 2>&1 || return 1
  return 0
}
fx() { fixture || { ko "/11 fixture falhou ao montar — abortando"; cd "$ROOT" || true; report; exit 1; }; }

# CASO 1 — a LISTA EXATA. Antes so 'alfa.txt' era asserido e trocar a base por
# HEAD~1..HEAD passava verde; com dois commits de trabalho, nao passa mais.
fx
antes="$(snap)"
bash "$SYNC" no-x > "$SP/o1" 2>&1; c1=$?
o1="$(cat "$SP/o1")"
assert_eq 0 "$c1" "/1 caminho feliz sai 0"
assert_contains "$o1" 'arquivos: [beta.txt, gama.txt]' "/1 lista EXATA: base certa, ambos os commits de trabalho"
assert_not_contains "$o1" 'alfa.txt' "/1 base nao pega commit anterior a criacao do no"
assert_not_contains "$o1" 'docs/audora/memory/no-x.md' "/1b exclui o proprio no"
assert_not_contains "$o1" 'no-x-historico.md' "/1b exclui o historico do no"
assert_not_contains "$o1" 'AVISO' "/1 caminho feliz NAO avisa (todo commit cita o id)"

# CASO 2 — /10: nada mudou na arvore, no .git, nem no sentinela fora do repo
assert_eq "$antes" "$(snap)" "/10 arvore inteira intocada (inclui .git e sentinela)"

# CASO 3 — AVISO discrimina: commit de outra demanda dentro do range
fx
printf 'd\n' > delta.txt
git add -A >/dev/null 2>&1; git commit -qm "feat(outra-coisa/1): demanda diferente" >/dev/null 2>&1
bash "$SYNC" no-x > "$SP/o3" 2>&1
o3="$(cat "$SP/o3")"
assert_contains "$o3" '# AVISO: 1 commits no intervalo não citam' "/1 conta CERTO os commits alheios"
assert_contains "$o3" 'feat(outra-coisa/1)' "/1 nomeia o commit alheio"

# CASO 4 — AVISO nao se engana com id que e SUBSTRING
fx
printf 'e\n' > eps.txt
git add -A >/dev/null 2>&1; git commit -qm "feat(no-x-historico/9): outra demanda, id parecido" >/dev/null 2>&1
bash "$SYNC" no-x > "$SP/o4" 2>&1
assert_contains "$(cat "$SP/o4")" 'eps.txt' "/1 o arquivo da outra demanda entra na lista (o range e ate HEAD)"

# CASO 5 — /5: no ainda em memory/
fx
# git nao versiona pasta vazia: depois do arquivamento docs/audora/memory/ sumiu,
# e sem o mkdir o git mv falha em silencio — o no seguiria arquivado e o caso
# provaria o contrario do que diz.
mkdir -p docs/audora/memory
git mv docs/audora/arquivo/2026-09-04-no-x.md docs/audora/memory/no-x.md >/dev/null 2>&1 || ko "/5 fixture: mv de volta falhou"
bash "$SYNC" no-x > "$SP/o5" 2>&1; c5=$?
[ "$c5" -ne 0 ] && ok || ko "/5 no nao arquivado deve abortar"
assert_contains "$(cat "$SP/o5")" 'ainda não arquivado' "/5 die proprio: nao arquivado"
# 'arquivos:' sozinho casaria o proprio prefixo da mensagem (memory-arquivos:)
assert_not_contains "$(cat "$SP/o5")" 'arquivos: [' "/5 aborto NAO emite lista"

# CASO 6 — /5: glob ambiguo de verdade (duas datas)
fx
cp docs/audora/arquivo/2026-09-04-no-x.md docs/audora/arquivo/2026-08-01-no-x.md
bash "$SYNC" no-x > "$SP/o6" 2>&1; c6=$?
[ "$c6" -ne 0 ] && ok || ko "/5 glob ambiguo deve abortar"
assert_contains "$(cat "$SP/o6")" 'ambíguo' "/5 die proprio: ambiguidade"

# CASO 7 — /5: MEMORY.md ausente tem die PROPRIO (antes mascarava o de git)
fx
rm -f MEMORY.md
bash "$SYNC" no-x > "$SP/o7" 2>&1; c7=$?
[ "$c7" -ne 0 ] && ok || ko "/5 MEMORY.md ausente deve abortar"
assert_contains "$(cat "$SP/o7")" 'MEMORY.md não encontrado' "/5 die proprio: MEMORY.md"

# CASO 8 — /7: fora de repo git. Monta MEMORY.md para NAO mascarar com o die
# anterior — na 3a revisao a mutacao die-sem-git passava por causa disso.
naogit="$SP/naogit_$RANDOM"
mkdir -p "$naogit" && cd "$naogit" || { ko "/7 nao montou o dir"; cd "$ROOT" || true; report; exit 1; }
printf 'memory-schema: 1\n' > MEMORY.md
bash "$SYNC" no-x > "$SP/o8" 2>&1; c8=$?
[ "$c8" -ne 0 ] && ok || ko "/7 fora de repo git deve abortar"
assert_contains "$(cat "$SP/o8")" 'não é um repositório git' "/7 die proprio: sem git"

# CASO 9 — argumento faltando e argumento a mais
cd "$SP" || exit 1
bash "$SYNC" > "$SP/o9a" 2>&1; [ $? -ne 0 ] && ok || ko "/5 sem argumento deve abortar"
assert_contains "$(cat "$SP/o9a")" 'uso: memory-arquivos' "/5 die proprio: sem argumento"
bash "$SYNC" no-x extra > "$SP/o9b" 2>&1; [ $? -ne 0 ] && ok || ko "/5 argumento extra deve abortar"
assert_contains "$(cat "$SP/o9b")" 'argumento extra' "/5 die proprio: argumento extra"

cd "$ROOT" || exit 1
assert_eq "$REAL_HEAD" "$(git rev-parse HEAD 2>/dev/null || echo sem-git)" "/11 repositorio real intocado pelos testes"
report
