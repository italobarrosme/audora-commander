# Plano — validate-estado-no: Estado validado no nó

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** `hooks/memory-validate` passa a validar o `estado:` do frontmatter
de cada arquivo de nó (enum + presença em toda escrita; igualdade com o índice
só na escrita do `MEMORY.md`), e a documentação ensina a ordem nó → índice.

**Nó do MEMORY:** `validate-estado-no` (MEMORY.md)

**Arquitetura da mudança:** o laço que já varre `docs/audora/memory/*.md`
(pulando `-historico`) ganha a leitura do `estado:` restrita ao frontmatter,
com `\r` e espaços removidos. O laço do índice passa a guardar `id estado` para
consulta. Uma flag diz se o arquivo escrito é o `MEMORY.md`; só então a
divergência índice × nó é cobrada — o índice é o ponto de fechamento de uma
transição. Docs: 1 frase de ordem em `registrar-no.md` e `sync.md`, lista de
checagens atualizada em `skills/memory/SKILL.md`, cabeçalho do hook e 2 READMEs.

**Arquivos lidos antes de planejar:** (Graphify ativo na Constituição, mas
`graphify` fora do PATH do Bash nesta máquina — consulta degradada para grep,
com aviso)
- `hooks/memory-validate` — laço do índice (enum, sem estado, ativo sem arquivo)
  e laço da pasta (órfão, depende-de); `case "$file_path"` distingue MEMORY.md
  de nó; erros acumulados em `$erros`, exit 2 no fim.
- `tests/test-memory-validate.sh` — helpers `mk` (MEMORY com índice) e `no`
  (nó com estado); asserts por cenário via `run_hook`.
- `tests/lib.sh` — `run_hook`, `assert_eq/contains/not_contains/empty`.
- `tests/test-autopilot.sh` — caracterização /12: nó com campo `autopilot:`
  passa (tem que continuar passando).
- `tests/test-dogfood.sh` — hook sobre o MEMORY real do repo tem que dar 0.
- `tests/test-carga.sh` — teto BASE 54900 (atual 53274); `registrar-no.md`,
  `skills/memory/SKILL.md` estão na BASE, `sync.md` na FULL (teto 60300,
  atual 58483).
- `tests/test-skills.sh`, `tests/test-docs.sh` — onde asserts de texto moram;
  terminam em `report`.
- `skills/memory/references/registrar-no.md` (passo 2), `skills/validate/references/sync.md`
  (passo 2), `skills/memory/SKILL.md` (linha 26), `README.md:150`,
  `README.pt-BR.md:151`, `hooks/loop:203-205` (transição por `sed`, não
  dispara hook — intocado).

**Conflitos MEMORY vs código encontrados:** nenhum.

## Notas de sessão

---

## Tarefa 1: enum e presença do estado no arquivo de nó

- **depende-de**: []
- **requisito**:
  - validate-estado-no/1 — QUANDO um arquivo de nó em `docs/audora/memory/`
    tem `estado:` com valor fora do enum O SISTEMA DEVE rejeitar a escrita
    (exit 2) nomeando o arquivo, o valor encontrado e o enum válido
  - validate-estado-no/2 — QUANDO um arquivo de nó não tem a linha `estado:`
    no frontmatter O SISTEMA DEVE rejeitar a escrita nomeando o arquivo
  - validate-estado-no/4 — QUANDO qualquer escrita no `MEMORY.md` ou em
    arquivo de nó dispara o hook O SISTEMA DEVE conferir o estado de TODOS os
    arquivos de nó da pasta, não só o do arquivo escrito (/1 e /2 em toda
    escrita; /3 nas escritas do índice)
  - validate-estado-no/5 — QUANDO todo arquivo de nó tem estado no enum e
    igual ao do índice — inclusive com fim de linha CRLF ou espaço sobrando ao
    redor do valor — O SISTEMA DEVE aceitar a escrita (exit 0)
  - validate-estado-no/6 — QUANDO o arquivo é `<id>-historico.md` O SISTEMA
    DEVE ignorá-lo nas checagens de estado
- **decisões relevantes**: nó sem `estado:` bloqueia; toda escrita confere
  todos os nós; `estado:` só vale DENTRO do frontmatter (linha 1 `---` até o
  próximo `---`).
- **interfaces**:
  - produz (em `hooks/memory-validate`): `fm_estado <arquivo>` — imprime
    `=<valor>` se há `estado:` no frontmatter (valor sem `\r` e sem espaço nas
    pontas), nada se não há. Usada também na Tarefa 2.
- **arquivos**:
  - Modificar: `hooks/memory-validate`
  - Teste: `tests/test-memory-validate.sh`
- **done quando**: asserts novos verdes, `tests/run.sh` exit 0 (dogfood e
  autopilot/12 inclusos).

Passos:

- [ ] **1. Escrever teste que falha** — inserir antes do `report` final de
  `tests/test-memory-validate.sh`:

```bash
# validate-estado-no/1 — estado do NÓ fora do enum (índice válido) → 2
mk nenum 'memory-schema: 1' '- x | planned | X | r | k | —'; no nenum x planejado ''
run_hook memory-validate "$SP/nenum/docs/audora/memory/x.md"
assert_eq 2 "$code" "validate-estado-no/1 estado do nó fora do enum → 2"
assert_contains "$out" "docs/audora/memory/x.md" "validate-estado-no/1 msg nomeia o arquivo"
assert_contains "$out" "'planejado'" "validate-estado-no/1 msg nomeia o valor"
assert_contains "$out" "planned|in-progress|blocked|delivered|discarded|hotfix-pending-record" "validate-estado-no/1 msg cita o enum"
run_hook memory-validate "$SP/nenum/MEMORY.md"
assert_eq 2 "$code" "validate-estado-no/1 idem via MEMORY.md → 2"

# validate-estado-no/2 — nó sem estado: no frontmatter → 2 (estado: no CORPO não conta)
sem_estado() { printf -- '---\nid: %s\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-09-28\n---\n# %s\n\nestado: planned\n' "$2" "$2" > "$SP/$1/docs/audora/memory/$2.md"; }
mk nsem 'memory-schema: 1' '- x | planned | X | r | k | —'; sem_estado nsem x
run_hook memory-validate "$SP/nsem/docs/audora/memory/x.md"
assert_eq 2 "$code" "validate-estado-no/2 nó sem estado: → 2"
assert_contains "$out" "docs/audora/memory/x.md sem campo 'estado:'" "validate-estado-no/2 msg nomeia o arquivo"

# validate-estado-no/4 — escrita num nó BOM acusa OUTRO nó ruim
mk todos 'memory-schema: 1' $'- x | planned | X | r | k | —\n- y | planned | Y | r | k | —'; no todos x planned ''; no todos y planejado ''
run_hook memory-validate "$SP/todos/docs/audora/memory/x.md"
assert_eq 2 "$code" "validate-estado-no/4 escrita em x acusa y → 2"
assert_contains "$out" "docs/audora/memory/y.md" "validate-estado-no/4 msg nomeia o outro nó"

# validate-estado-no/5 — CRLF + espaços ao redor do valor → 0, sem falso positivo
mk crlf 'memory-schema: 1' '- x | in-progress | X | r | k | —'
printf -- '---\r\nid: x\r\nestado:   in-progress  \r\norigem: humano\r\ndepende-de: []\r\narquivos: []\r\nkeywords: []\r\nresumo: r\r\natualizado-em: 2026-09-28\r\n---\r\n# x\r\n' > "$SP/crlf/docs/audora/memory/x.md"
run_hook memory-validate "$SP/crlf/MEMORY.md"
assert_eq 0 "$code" "validate-estado-no/5 CRLF e espaços via MEMORY.md → 0"; assert_empty "$out" "validate-estado-no/5 stderr vazio"
run_hook memory-validate "$SP/crlf/docs/audora/memory/x.md"
assert_eq 0 "$code" "validate-estado-no/5 CRLF e espaços via nó → 0"

# validate-estado-no/6 — <id>-historico.md sem frontmatter é ignorado
printf '# x — histórico\n\nsem frontmatter\n' > "$SP/ok/docs/audora/memory/x-historico.md"
run_hook memory-validate "$SP/ok/MEMORY.md"
assert_eq 0 "$code" "validate-estado-no/6 histórico ignorado → 0"; assert_empty "$out" "validate-estado-no/6 stderr vazio"
```

- [ ] **2. Rodar e ver falhar pelo motivo certo** —
  `bash tests/test-memory-validate.sh; echo "exit=$?"` → FAIL em /1 (esperado
  2, obtido 0 — hoje o hook não lê o estado do nó), /2 e /4 idem; /5 e /6
  passam já (caracterização: não podem quebrar depois). `exit=1`.
- [ ] **3. Implementar** em `hooks/memory-validate`:
  - Função (antes do laço da pasta) — formato exato, não-óbvio:

```bash
# estado: do FRONTMATTER (linha 1 '---' até o próximo '---'); "=<valor>" ou nada
fm_estado() {
  tr -d '\r' < "$1" | awk 'NR==1 { if ($0 != "---") exit; next }
    /^---$/ { exit }
    /^estado:/ { sub(/^estado:[ \t]*/, ""); sub(/[ \t]*$/, ""); print "=" $0; exit }'
}
```
  - No laço `for f in "$dir"/*.md`, depois do `case "$b" in *-historico)`:
    `fe="$(fm_estado "$f")"`; vazio → erro
    `- arquivo docs/audora/memory/$b.md sem campo 'estado:' no frontmatter ($tpl/no-template.md)`;
    senão `ve="${fe#=}"` e, fora do enum, erro
    `- arquivo docs/audora/memory/$b.md com estado '$ve' fora do enum (planned|in-progress|blocked|delivered|discarded|hotfix-pending-record) ($tpl/no-template.md)`.
  - Atualizar o comentário de cabeçalho do hook (lista do que acusa).
- [ ] **4. Rodar e ver passar** — `bash tests/run.sh > "$TMPDIR/r.log" 2>&1; echo "exit=$?"`
  → `exit=0`; `grep FAIL=[1-9] "$TMPDIR/r.log"` vazio.
- [ ] **5. Commit** — `git add hooks/memory-validate tests/test-memory-validate.sh && git commit -m "feat(validate-estado-no/1,2,4,5,6): memory-validate confere enum e presença do estado em todo arquivo de nó"`.

## Tarefa 2: divergência índice × nó só na escrita do índice

- **depende-de**: [Tarefa 1]
- **requisito**:
  - validate-estado-no/3 — QUANDO o `MEMORY.md` é escrito e o `estado:` de
    algum arquivo de nó difere da coluna de estado da linha dele no índice O
    SISTEMA DEVE rejeitar a escrita nomeando o nó e os dois valores (índice e
    arquivo)
  - validate-estado-no/7 — QUANDO um arquivo de nó não tem linha no índice O
    SISTEMA DEVE acusar só a ausência da linha (erro já existente), sem erro de
    divergência duplicado para o mesmo nó
  - validate-estado-no/9 — QUANDO um arquivo de nó é escrito com estado
    válido mas diferente do índice (primeira metade de uma transição) O SISTEMA
    DEVE aceitar a escrita (exit 0)
- **decisões relevantes**: divergência só bloqueia na escrita do ÍNDICE; ordem
  canônica nó → índice. Divergência só é cobrada quando o estado do nó é
  válido (enum inválido ou ausente já tem erro próprio da Tarefa 1).
- **interfaces**:
  - consome: `fm_estado <arquivo>` (Tarefa 1).
  - produz: variável `idx_estados` (linhas `id estado`, montada no laço do
    índice) e flag `escreveu_indice` (1 se `$file_path` casa `*MEMORY.md`).
- **arquivos**:
  - Modificar: `hooks/memory-validate`
  - Teste: `tests/test-memory-validate.sh`
- **done quando**: asserts novos verdes, suíte exit 0.

Passos:

- [ ] **1. Escrever teste que falha** — inserir antes do `report` final:

```bash
# validate-estado-no/3 — índice in-progress, nó delivered, escrita no ÍNDICE → 2
mk div 'memory-schema: 1' '- x | in-progress | X | r | k | —'; no div x delivered ''
run_hook memory-validate "$SP/div/MEMORY.md"
assert_eq 2 "$code" "validate-estado-no/3 divergência na escrita do índice → 2"
assert_contains "$out" "nó 'x' com estado divergente: índice 'in-progress', arquivo 'delivered'" "validate-estado-no/3 msg nomeia nó e os dois valores"
# validate-estado-no/9 — mesma divergência, escrita no NÓ (1ª metade da transição) → 0
run_hook memory-validate "$SP/div/docs/audora/memory/x.md"
assert_eq 0 "$code" "validate-estado-no/9 divergência na escrita do nó → 0"; assert_empty "$out" "validate-estado-no/9 stderr vazio"
# validate-estado-no/7 — nó sem linha no índice: só o erro de órfão, sem divergência
run_hook memory-validate "$SP/orfao/MEMORY.md"
assert_contains "$out" "sem linha no índice" "validate-estado-no/7 órfão continua acusado"
assert_not_contains "$out" "divergente" "validate-estado-no/7 sem divergência duplicada"
```

- [ ] **2. Rodar e ver falhar pelo motivo certo** —
  `bash tests/test-memory-validate.sh; echo "exit=$?"` → FAIL em /3 (esperado
  2, obtido 0); /9 e /7 passam já (caracterização). `exit=1`.
- [ ] **3. Implementar** em `hooks/memory-validate`:
  - `escreveu_indice=0` no `case "$file_path"` ramo `*MEMORY.md)` → `=1`.
  - No laço do índice, após extrair `id` e `estado` não vazio:
    `idx_estados="$idx_estados$id $estado
"`.
  - No laço da pasta, com `ve` válido (enum ok) e `escreveu_indice=1`:
    `vi="$(printf '%s' "$idx_estados" | awk -v i="$b" '$1==i {print $2; exit}')"`;
    `[ -n "$vi" ] && [ "$vi" != "$ve" ]` → erro
    `- nó '$b' com estado divergente: índice '$vi', arquivo '$ve' — transição é nó primeiro, índice depois; alinhe os dois`.
    `vi` vazio (órfão) → nada (/7).
- [ ] **4. Rodar e ver passar** — `bash tests/run.sh > "$TMPDIR/r.log" 2>&1; echo "exit=$?"` → `exit=0`.
- [ ] **5. Commit** — `git add hooks/memory-validate tests/test-memory-validate.sh && git commit -m "feat(validate-estado-no/3,7,9): divergência índice × nó cobrada só na escrita do índice"`.

## Tarefa 3: documentação da checagem e da ordem nó → índice

- **depende-de**: [Tarefa 2]
- **requisito**:
  - validate-estado-no/8 — QUANDO o usuário lê o que o `memory-validate`
    confere nos dois READMEs O SISTEMA DEVE listar a checagem de estado nos
    arquivos de nó
  - validate-estado-no/10 — QUANDO a skill `memory` (registrar-no) ou o sync
    da `validate` descrevem uma transição de estado O SISTEMA DEVE instruir a
    ordem nó primeiro, índice depois
- **decisões relevantes**: frase asserida cabe em UMA linha do Markdown
  (aprendizado 2026-08-27); carga BASE ≤ 54900 e FULL ≤ 60300 bytes
  (`tests/test-carga.sh`) — acréscimo total previsto < 500 bytes.
- **interfaces**: nenhuma.
- **arquivos**:
  - Modificar: `README.md` (linha ~150), `README.pt-BR.md` (linha ~151),
    `skills/memory/SKILL.md` (linha ~26), `skills/memory/references/registrar-no.md`
    (passo 2), `skills/validate/references/sync.md` (passo 2)
  - Teste: `tests/test-docs.sh`, `tests/test-skills.sh`
- **done quando**: asserts novos verdes, suíte exit 0 com `test-carga` verde.

Passos:

- [ ] **1. Escrever teste que falha** — antes do `report` de `tests/test-docs.sh`:

```bash
# validate-estado-no/8 — READMEs listam a checagem de estado nos arquivos de nó
assert_contains "$(cat README.md)" 'state in each node file' "validate-estado-no/8 README EN cita estado no nó"
assert_contains "$(cat README.pt-BR.md)" 'estado em cada arquivo de nó' "validate-estado-no/8 README PT cita estado no nó"
```
  e antes do `report` de `tests/test-skills.sh`:

```bash
# validate-estado-no/10 — ordem da transição: nó primeiro, índice depois
assert_contains "$(cat skills/memory/references/registrar-no.md)" 'nó primeiro, índice depois' "validate-estado-no/10 registrar-no ensina a ordem"
assert_contains "$(cat skills/validate/references/sync.md)" 'nó primeiro, índice depois' "validate-estado-no/10 sync ensina a ordem"
assert_contains "$(cat skills/memory/SKILL.md)" 'estado índice↔nó' "validate-estado-no/10 memory lista a checagem nova"
```

- [ ] **2. Rodar e ver falhar** — `bash tests/test-docs.sh; bash tests/test-skills.sh`
  → 5 FAIL `não contém ...`.
- [ ] **3. Implementar** (cada frase asserida inteira numa linha):
  - `README.md`: `memory-validate` (schema, index ↔ folder, enum, cycles) →
    `(schema, index ↔ folder, enum, state in each node file, cycles)`.
  - `README.pt-BR.md`: idem com `(schema, índice ↔ pasta, enum, estado em cada arquivo de nó, ciclos)`.
  - `skills/memory/SKILL.md` linha 26: acrescentar `estado índice↔nó` à lista
    entre parênteses.
  - `registrar-no.md` passo 2: nova frase `Transição de estado: nó primeiro, índice depois — o \`memory-validate\` só cobra a igualdade na escrita do índice.`
  - `sync.md` passo 2: `nó → \`delivered\`` ganha `(nó primeiro, índice depois)`.
- [ ] **4. Rodar e ver passar** — `bash tests/run.sh > "$TMPDIR/r.log" 2>&1; echo "exit=$?"` → `exit=0`; conferir linha `carga MEDIUM` abaixo dos tetos.
- [ ] **5. Commit** — `git add README.md README.pt-BR.md skills/memory/SKILL.md skills/memory/references/registrar-no.md skills/validate/references/sync.md tests/test-docs.sh tests/test-skills.sh && git commit -m "docs(validate-estado-no/8,10): READMEs citam estado no nó; ordem nó → índice em registrar-no e sync"`.
