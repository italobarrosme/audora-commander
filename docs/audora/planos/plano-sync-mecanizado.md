# Plano — sync-mecanizado: hooks/memory-sync (gerador)

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** `hooks/memory-sync <id>` descobre e IMPRIME o que o sync
mecânico precisa — a linha `arquivos:`, a linha nova do índice e o `git mv` do
plano — sem escrever nada. O modelo lê e aplica.

**Nó do MEMORY:** `sync-mecanizado` (HIGH) · escopo em
`docs/audora/specs/sync-mecanizado-escopo.md` + delta de reabertura no nó

**Arquitetura da mudança:** script bash em `hooks/`, padrão `graphify-status`.
Ele **só lê e imprime**. O modelo aplica as duas linhas com `Edit` (o que faz
`memory-validate`/`memory-guard` dispararem sozinhos no `PostToolUse`) e o
`git mv` com `Bash`. Consequência de projeto que resolve 3 achados da revisão:
o script imprime a **linha nova literal**, não um `sed` — então `|` no
replacement e `&` no título deixam de existir como problema.

**Arquivos lidos antes de planejar:**
- `hooks/graphify-status` — padrão de script auxiliar (cabeçalho com uso e
  exit codes, `set -uo pipefail`, sem `jq`).
- `hooks/memory-guard` / `hooks/memory-validate` — só casam `MEMORY.md` e
  `docs/audora/memory/*.md`; **saem 0 para `docs/audora/arquivo/`** (achado 8),
  por isso o script não os chama: quem dispara é o `Edit` do modelo.
- `tests/lib.sh` — `SP` é `mktemp -d` **fora** do repo (confirmado pela
  revisão), com trap de limpeza. `assert_not_contains` existe e não estava
  sendo usado (achado 11).
- `MEMORY.md` — formato da linha de índice; título é o 3º campo por ` | `.
- Histórico real: `git diff --name-only <base>..<último commit da demanda>`
  com base = pai do commit que criou o arquivo do nó devolve **5** para
  `light-enxuto` e **5** para `scope-batch` — idênticas às listas escritas à
  mão. Verificado antes de planejar.

**Conflitos MEMORY vs código encontrados:** nenhum.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

---

## Tarefa 1: fixture blindada e os 8 casos (RED)

- **depende-de**: []
- **requisito**:
  - **/8** — suíte exercita em fixture git real cobrindo os caminhos
  - **/10** — o script deixa o repositório inalterado
  - **/11** — fixture que falha ao montar aborta o arquivo de teste
- **decisões relevantes**: a revisão provou que sem `/11` os casos com
  `git commit` rodariam com cwd na raiz e **commitariam no repositório real**.
  `run.sh` chama cada teste com cwd na raiz do repo, e `lib.sh` usa
  `set -uo pipefail` **sem `-e`** — nada aborta sozinho.
- **interfaces**:
  - consome: `tests/lib.sh` — `SP`, `ROOT`, `assert_eq`, `assert_contains`,
    `assert_not_contains`, `assert_empty`, `assert_file`, `ok`, `ko`, `report`.
  - produz: `tests/test-memory-sync.sh` (novo; `run.sh` pega por glob).
- **arquivos**:
  - Criar: `tests/test-memory-sync.sh`
- **done quando**: `bash tests/run.sh > "$SP/r.log" 2>&1; echo $?` devolve
  **1**, com falhas de `hooks/memory-sync` inexistente — nunca de sintaxe, e
  **nunca** com commit novo no repositório real (conferir `git log --oneline -1`
  antes e depois).

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Fixture blindada** — o `|| { ko; return 1; }` é o que impede o
  desastre do achado 7:

```bash
#!/usr/bin/env bash
# sync-mecanizado/8,/10,/11 — hooks/memory-sync em fixture git real.
source "$(dirname "$0")/lib.sh"
SYNC="$ROOT/hooks/memory-sync"
REAL_HEAD="$(git -C "$ROOT" rev-parse HEAD)"

fixture() {
  F="$SP/fx_$RANDOM$RANDOM"
  mkdir -p "$F/docs/audora/arquivo" "$F/docs/audora/planos/arquivo" "$F/docs/audora/memory" || return 1
  cd "$F" || return 1
  git init -q || return 1
  git config user.email e2e@x && git config user.name e2e || return 1
  cat > MEMORY.md <<'M'
memory-schema: 1

# MEMORY — fixture

## Propósito [carga: sempre]

Fixture.

## Constituição [carga: sempre]

- **graphify**: recusado

## Aprendizados [carga: sempre]

## Índice de nós [carga: sempre]

- no-x | in-progress | Titulo & Co | resumo com | pipe dentro | k1, k2 | src/
- no-x-historico | planned | Vizinho | nao pode ser tocado | k | s/
M
  printf 'a\n' > alfa.txt
  git add -A >/dev/null 2>&1 && git commit -qm base || return 1
  # commit que CRIA o arquivo do no — daqui sai a base do diff
  mkdir -p docs/audora/memory
  printf -- '---\nid: no-x\nestado: in-progress\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: [k1]\nresumo: r\natualizado-em: 2026-09-02\n---\n\n# no-x\n' > docs/audora/memory/no-x.md
  git add -A >/dev/null 2>&1 && git commit -qm "docs(no-x): abre o no" || return 1
  printf 'b\n' > beta.txt
  printf '# plano\n' > docs/audora/planos/plano-no-x.md
  git add -A >/dev/null 2>&1 && git commit -qm "feat(no-x/1): trabalho" || return 1
  # o modelo ja arquivou o no (passo 1 do fluxo)
  git mv docs/audora/memory/no-x.md docs/audora/arquivo/2026-09-02-no-x.md >/dev/null 2>&1 || return 1
  return 0
}

fx() { fixture || { ko "fixture falhou ao montar — abortando"; cd "$ROOT"; report; exit 1; }; }
```

- [ ] **2. Os 8 casos**:

```bash
# CASO 1 — caminho feliz: emite as 3 coisas, e DISCRIMINA (achado 11)
fx
st_antes="$(git status --porcelain)"
bash "$SYNC" no-x > "$SP/o1" 2>&1; c1=$?
o1="$(cat "$SP/o1")"
assert_eq 0 "$c1" "/1 caminho feliz sai 0"
assert_contains "$o1" 'beta.txt' "/1 arquivos: pega o arquivo da demanda"
assert_not_contains "$o1" 'alfa.txt' "/1 arquivos: NAO pega commit anterior a demanda"
assert_not_contains "$o1" 'docs/audora/memory/no-x.md' "/1b exclui o proprio no"
assert_contains "$o1" '- no-x | delivered | Titulo & Co → docs/audora/arquivo/2026-09-02-no-x.md' "/2 linha do indice, titulo com & preservado"
assert_contains "$o1" 'git mv docs/audora/planos/plano-no-x.md docs/audora/planos/arquivo/' "/3 comando de arquivar o plano"
assert_not_contains "$o1" 'no-x-historico' "/2 nao encosta na linha vizinha"

# CASO 2 — /10: o script NAO escreve
assert_eq "$st_antes" "$(git status --porcelain)" "/10 repositorio inalterado apos rodar"

# CASO 3 — /6 idempotencia: com o indice ja em delivered, diz que nao ha o que fazer
perl -0pi -e 's/^- no-x \| in-progress \|.*$/- no-x | delivered | Titulo & Co → docs\/audora\/arquivo\/2026-09-02-no-x.md/m' MEMORY.md
perl -0pi -e 's/^arquivos: \[\]$/arquivos: [beta.txt]/m' docs/audora/arquivo/2026-09-02-no-x.md
git mv docs/audora/planos/plano-no-x.md docs/audora/planos/arquivo/ >/dev/null 2>&1
bash "$SYNC" no-x > "$SP/o3" 2>&1; c3=$?
assert_eq 0 "$c3" "/6 idempotente sai 0"
assert_contains "$(cat "$SP/o3")" 'nada a fazer' "/6 diz que ja esta feito"

# CASO 4 — /5: no ainda em memory/, nao arquivado
fx
git mv docs/audora/arquivo/2026-09-02-no-x.md docs/audora/memory/no-x.md >/dev/null 2>&1
bash "$SYNC" no-x > "$SP/o4" 2>&1; c4=$?
[ "$c4" -ne 0 ] && ok || ko "/5 no nao arquivado deve abortar"
assert_contains "$(cat "$SP/o4")" 'docs/audora/arquivo' "/5 aborto explica o que espera"
assert_not_contains "$(cat "$SP/o4")" 'arquivos:' "/5 aborto NAO emite comando nenhum"

# CASO 5 — /5: id ausente do indice
fx
perl -0pi -e 's/^- no-x \|.*\n//m' MEMORY.md
bash "$SYNC" no-x > "$SP/o5" 2>&1; c5=$?
[ "$c5" -ne 0 ] && ok || ko "/5 id fora do indice deve abortar"

# CASO 6 — /3: sem plano (caso LIGHT) nao e erro
fx
rm -f docs/audora/planos/plano-no-x.md
bash "$SYNC" no-x > "$SP/o6" 2>&1; c6=$?
assert_eq 0 "$c6" "/3 ausencia de plano nao e erro"
assert_not_contains "$(cat "$SP/o6")" 'git mv docs/audora/planos/plano-no-x.md' "/3 sem plano, sem comando de plano"
assert_contains "$(cat "$SP/o6")" '- no-x | delivered |' "/3 indice sai mesmo sem plano"

# CASO 7 — /7: nao e repositorio git
naogit="$SP/naogit_$RANDOM"; mkdir -p "$naogit"; cd "$naogit" || exit 1
bash "$SYNC" no-x > "$SP/o7" 2>&1; c7=$?
[ "$c7" -ne 0 ] && ok || ko "/7 fora de repo git deve abortar"
assert_not_contains "$(cat "$SP/o7")" 'arquivos: []' "/7 nunca emite lista vazia"

# CASO 8 — achado 19: glob ambiguo (no + historico + spec no arquivo)
fx
printf -- '---\nid: no-x\n---\n' > docs/audora/arquivo/2026-09-02-no-x-historico.md
printf -- '# spec\n' > docs/audora/arquivo/2026-09-02-no-x-escopo.md
git add -A >/dev/null 2>&1; git commit -qm "irmaos"
bash "$SYNC" no-x > "$SP/o8" 2>&1; c8=$?
assert_eq 0 "$c8" "/2 glob ambiguo nao confunde o script"
assert_contains "$(cat "$SP/o8")" '→ docs/audora/arquivo/2026-09-02-no-x.md' "/2 aponta o NO, nao o historico nem a spec"

cd "$ROOT" || exit 1
assert_eq "$REAL_HEAD" "$(git rev-parse HEAD)" "/11 repositorio real intocado pelos testes"
report
```

- [ ] **3. Rodar e ver falhar** — `bash tests/run.sh > "$SP/r.log" 2>&1`, exit
  **1**, falhas por `hooks/memory-sync` inexistente. Conferir `git log --oneline -1`
  igual antes e depois.
- [ ] **4. Commit** — `git add tests/test-memory-sync.sh && git commit -m "test(sync-mecanizado/8,10,11): RED — fixture blindada com 8 casos"`

---

## Tarefa 2: o script `hooks/memory-sync`

- **expandir: sim** — quebrar em subtarefas (pré-condições, base do diff,
  linha do índice, plano, idempotência) SÓ quando chegar a vez dela.
- **depende-de**: [Tarefa 1]
- **requisito**: **/1**, **/1b**, **/2**, **/3**, **/5**, **/6**, **/7**
- **decisões relevantes**: base = `git log --diff-filter=A --format=%H --
  docs/audora/memory/<id>.md docs/audora/arquivo/*-<id>.md | tail -1`, depois
  `^` (com tratamento de commit-raiz: sem pai, usa o próprio commit vazio
  `git hash-object -t tree /dev/null`). Título = 3º campo por ` | ` via `awk
  -F'|'` (a revisão confirmou que pipe no RESUMO não atrapalha). Glob do
  arquivado é `*-<id>.md`, e o script exige **exatamente 1** match.
- **interfaces**:
  - consome: nada.
  - produz: `hooks/memory-sync`, invocado como `bash hooks/memory-sync <id>`
    da raiz do projeto-alvo. Só imprime; nunca escreve.
- **arquivos**:
  - Criar: `hooks/memory-sync`
- **done quando**: os 8 casos passam e `bash tests/run.sh` sai 0.

---

## Tarefa 3: a skill validate aponta o script

- **depende-de**: [Tarefa 2]
- **requisito**: **/9** — a `validate` aponta o script nos 2 grupos que ele
  cobre e mantém explícito que os 3 de julgamento seguem com o modelo
- **decisões relevantes**: o ponteiro tem de dizer que o modelo **aplica com
  Edit** — é isso que faz os hooks dispararem; um `Bash` com `sed` não faria.
- **interfaces**:
  - consome: `hooks/memory-sync`.
  - produz: nada.
- **arquivos**:
  - Modificar: `skills/validate/SKILL.md`
  - Modificar: `tests/test-skills.sh`
- **done quando**: suíte verde e `wc -l skills/validate/SKILL.md` ≤ 250.
