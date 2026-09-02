# Plano — sync-mecanizado: hooks/memory-sync

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** `hooks/memory-sync <id>` preenche `arquivos:` do diff real,
reescreve a linha do índice para o formato `delivered` e arquiva o plano —
abortando sem escrever se qualquer pré-condição não bater.

**Nó do MEMORY:** `sync-mecanizado` (HIGH) · escopo em
`docs/audora/specs/sync-mecanizado-escopo.md`

**Arquitetura da mudança:** script bash em `hooks/`, no padrão do
`graphify-status` (auxiliar chamado por skill, não hook do harness). Ordem
imposta pelo escopo: o MODELO já virou `estado: delivered` e moveu o nó; o
script roda depois. Ele valida pré-condições ANTES de qualquer escrita, escreve
as 3 coisas, e então invoca `memory-validate` e `memory-guard` ele mesmo —
porque o `PostToolUse` do harness não dispara para escrita de script.

**Arquivos lidos antes de planejar:**
- `hooks/graphify-status` (25 linhas) — padrão de script auxiliar: cabeçalho
  com uso e exit codes, `set -uo pipefail`, `perl -MJSON::PP` no lugar de `jq`.
- `hooks/memory-guard` (35 linhas) — padrão de mensagem em stderr + exit code;
  lê JSON do stdin com `tool_input.file_path`; **pula `-historico.md`**
  (linha 27), detalhe que o /4 precisa respeitar.
- `hooks/memory-validate` (4360 bytes) — mesmo contrato de stdin; é o que
  valida índice↔pasta, e é ele que reprovaria se a linha do índice apontasse
  `arquivo/` com o nó ainda em `memory/`.
- `tests/lib.sh` — `SP` é o `mktemp -d` com trap de limpeza; `run_hook` monta o
  JSON de stdin e captura `out`/`code`. A fixture do /8 usa `SP`.
- `MEMORY.md` — formato da linha de índice, ativa e `delivered`.

**Conflitos MEMORY vs código encontrados:** nenhum. A Constituição permite
executável em `hooks/`, e `graphify-status` já é precedente de script auxiliar
que não é hook do harness.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

---

## Tarefa 1: fixture git real e os 6 caminhos (RED)

- **depende-de**: []
- **requisito**:
  - **sync-mecanizado/8** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
    exercitar o script em fixture git real (`mktemp -d`) cobrindo, no mínimo:
    caminho feliz, nó não arquivado, id ausente do índice, árvore suja,
    ausência de plano, e segunda execução
- **decisões relevantes**: fixture em `$SP` (o `mktemp -d` de `tests/lib.sh`,
  já com trap de limpeza); path POSIX e JSON com backslash escapado
  (aprendizado de 2026-08-25 — path `C:\...` sem escape faz hook sair 0 em
  silêncio, falso verde).
- **interfaces**:
  - consome: `tests/lib.sh` — `SP`, `assert_eq`, `assert_contains`,
    `assert_empty`, `assert_file`, `assert_no_file`, `ok`, `ko`, `report`.
  - produz: `tests/test-memory-sync.sh` — arquivo novo; `tests/run.sh` já roda
    `tests/test-*.sh` por glob, então não precisa registrar.
- **arquivos**:
  - Criar: `tests/test-memory-sync.sh`
- **done quando**: `bash tests/run.sh > /dev/null 2>&1; echo $?` devolve **1**
  e as falhas citam `hooks/memory-sync` ausente — nunca erro de sintaxe da
  fixture.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever a função que monta a fixture**, em
  `tests/test-memory-sync.sh`:

```bash
#!/usr/bin/env bash
# sync-mecanizado/8 — hooks/memory-sync em fixture git real.
source "$(dirname "$0")/lib.sh"
SYNC="$ROOT/hooks/memory-sync"

# monta um repo git descartavel com um no JA arquivado e um plano
fixture() {
  F="$SP/fx$$_$RANDOM"; rm -rf "$F"; mkdir -p "$F/docs/audora/arquivo" "$F/docs/audora/planos/arquivo" "$F/docs/audora/memory"
  cd "$F" || return 1
  git init -q
  git config user.email e2e@x; git config user.name e2e
  cat > MEMORY.md <<'M'
memory-schema: 1

# MEMORY — fixture

## Propósito [carga: sempre]

Fixture.

## Constituição [carga: sempre]

- **graphify**: recusado

## Aprendizados [carga: sempre]

## Índice de nós [carga: sempre]

- no-x | in-progress | Titulo do X | resumo | k1, k2 | src/
M
  printf 'a\n' > alfa.txt
  git add -A >/dev/null 2>&1; git commit -qm "base"
  printf 'b\n' > beta.txt
  cat > docs/audora/arquivo/2026-09-01-no-x.md <<'N'
---
id: no-x
estado: delivered
origem: humano
depende-de: []
arquivos: []
keywords: [k1, k2]
resumo: resumo
atualizado-em: 2026-09-01
---

# no-x

## objetivo

x

## criterios-aceite

- **no-x/1** — QUANDO a O SISTEMA DEVE b

## fora-de-escopo

nada

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
N
  printf '# plano\n' > docs/audora/planos/plano-no-x.md
  git add -A >/dev/null 2>&1; git commit -qm "feat(no-x/1): trabalho da demanda no-x"
}
```

- [ ] **2. Escrever os 6 casos** (cada um chama `fixture` do zero):

```bash
# CASO 1 — caminho feliz
fixture
bash "$SYNC" no-x > "$SP/o1" 2>&1; c1=$?
assert_eq 0 "$c1" "/1 caminho feliz sai 0"
assert_contains "$(cat docs/audora/arquivo/2026-09-01-no-x.md)" 'beta.txt' "/1 arquivos: pegou o diff real"
assert_contains "$(cat MEMORY.md)" '- no-x | delivered | Titulo do X → docs/audora/arquivo/2026-09-01-no-x.md' "/2 linha do indice no formato delivered"
assert_file docs/audora/planos/arquivo/plano-no-x.md "/3 plano arquivado"
assert_no_file docs/audora/planos/plano-no-x.md "/3 plano saiu de planos/"

# CASO 2 — segunda execucao e idempotente
bash "$SYNC" no-x > "$SP/o2" 2>&1; c2=$?
assert_eq 0 "$c2" "/6 segunda execucao sai 0"
assert_contains "$(cat "$SP/o2")" 'nada a fazer' "/6 segunda execucao diz que ja esta feito"

# CASO 3 — no NAO arquivado (ainda em memory/)
fixture
git mv docs/audora/arquivo/2026-09-01-no-x.md docs/audora/memory/no-x.md >/dev/null 2>&1
git commit -qm "volta"
bash "$SYNC" no-x > "$SP/o3" 2>&1; c3=$?
[ "$c3" -ne 0 ] && ok || ko "/5 no nao arquivado deve abortar"
assert_contains "$(cat "$SP/o3")" 'docs/audora/arquivo' "/5 aborto explica que espera o no arquivado"
assert_contains "$(cat MEMORY.md)" '- no-x | in-progress |' "/5 indice INTOCADO apos aborto"

# CASO 4 — id ausente do indice
fixture
perl -0pi -e 's/^- no-x \|.*\n//m' MEMORY.md
git commit -aqm "tira do indice"
bash "$SYNC" no-x > "$SP/o4" 2>&1; c4=$?
[ "$c4" -ne 0 ] && ok || ko "/5 id fora do indice deve abortar"
assert_contains "$(cat docs/audora/arquivo/2026-09-01-no-x.md)" 'arquivos: []' "/5 no INTOCADO apos aborto"

# CASO 5 — arvore suja no arquivo que ele ia tocar
fixture
printf '\nsujeira\n' >> MEMORY.md
bash "$SYNC" no-x > "$SP/o5" 2>&1; c5=$?
[ "$c5" -ne 0 ] && ok || ko "/5 arvore suja deve abortar"
assert_contains "$(cat "$SP/o5")" 'commitad' "/5 aborto explica a arvore suja"

# CASO 6 — sem plano (caso LIGHT): nao reclama
fixture
git rm -q docs/audora/planos/plano-no-x.md
git commit -qm "sem plano"
bash "$SYNC" no-x > "$SP/o6" 2>&1; c6=$?
assert_eq 0 "$c6" "/3 ausencia de plano nao e erro"
assert_contains "$(cat MEMORY.md)" '→ docs/audora/arquivo/2026-09-01-no-x.md' "/3 indice atualizado mesmo sem plano"

cd "$ROOT" || exit 1
report
```

- [ ] **3. Rodar e ver falhar** —
  `bash tests/run.sh > /tmp/r.log 2>&1; echo $?` → **1**, com falhas de
  `hooks/memory-sync` inexistente (`bash: ... No such file`), não de sintaxe.
- [ ] **4. Commit** — `git add tests/test-memory-sync.sh && git commit -m "test(sync-mecanizado/8): RED — fixture git real com os 6 caminhos"`

---

## Tarefa 2: o script `hooks/memory-sync`

- **expandir: sim** — quebrar em subtarefas (pré-condições, `arquivos:`, linha
  do índice, plano, idempotência) SÓ quando chegar a vez dela.
- **depende-de**: [Tarefa 1]
- **requisito**: **/1**, **/2**, **/3**, **/5**, **/6**, **/7** (verbatim na
  spec de escopo)
- **decisões relevantes**: escreve direto (decisão do portão); aborta sem
  escrever nada em pré-condição não batida; base do diff derivada do PRIMEIRO
  commit que cita o id (`git log --format=%H --grep <id> | tail -1`, depois
  `^`), com tratamento do caso commit-raiz.
- **interfaces**:
  - consome: nada.
  - produz: `hooks/memory-sync`, executável, invocado como
    `bash hooks/memory-sync <id>` a partir da raiz do projeto-alvo.
- **arquivos**:
  - Criar: `hooks/memory-sync`
- **done quando**: os 6 casos da Tarefa 1 passam e `bash tests/run.sh` sai 0.

---

## Tarefa 3: auto-validação (/4)

- **depende-de**: [Tarefa 2]
- **requisito**: **sync-mecanizado/4** — QUANDO terminar de escrever O SISTEMA
  DEVE rodar `memory-validate` e `memory-guard` sobre o resultado e sair com
  código ≠ 0 se algum acusar, dizendo qual
- **decisões relevantes**: os dois hooks leem JSON do stdin com
  `tool_input.file_path`; path com backslash tem de ser escapado (aprendizado
  de 2026-08-25). `memory-guard` pula `-historico.md` — o script não precisa
  tratar isso, mas o teste não deve depender do contrário.
- **interfaces**:
  - consome: `hooks/memory-validate` e `hooks/memory-guard`, irmãos do script
    (`$(dirname "$0")`).
  - produz: nada.
- **arquivos**:
  - Modificar: `hooks/memory-sync`
  - Modificar: `tests/test-memory-sync.sh` (caso 7)
- **done quando**: caso 7 verde — corromper o índice de propósito depois da
  escrita faz o script sair ≠ 0 citando qual hook acusou.

Passos:

- [ ] **1. Caso 7 no teste** — fixture com `depende-de: [inexistente]` no nó,
  que `memory-validate` reprova; rodar o script; esperar exit ≠ 0 e a saída
  citando `memory-validate`.
- [ ] **2. Rodar e ver falhar** (o script ainda não valida) — exit 0 indevido.
- [ ] **3. Implementar** a chamada aos dois hooks ao fim do script.
- [ ] **4. Rodar e ver passar**; suíte toda verde.
- [ ] **5. Commit** — `git add hooks/memory-sync tests/test-memory-sync.sh && git commit -m "feat(sync-mecanizado/4): script valida o proprio resultado"`

---

## Tarefa 4: a skill validate aponta o script

- **depende-de**: [Tarefa 3]
- **requisito**: **sync-mecanizado/9** — QUANDO a skill `validate` descrever o
  sync O SISTEMA DEVE apontar o script nos 2 grupos que ele cobre e deixar
  explícito que os 3 passos de julgamento seguem com o modelo
- **decisões relevantes**: a seção `## Fechamento LIGHT` (entregue) também
  cita o sync — conferir se precisa de ponteiro lá.
- **interfaces**:
  - consome: `hooks/memory-sync`.
  - produz: nada.
- **arquivos**:
  - Modificar: `skills/validate/SKILL.md`
  - Modificar: `tests/test-skills.sh` (assert de /9)
- **done quando**: suíte verde e `wc -l skills/validate/SKILL.md` ≤ 250.
