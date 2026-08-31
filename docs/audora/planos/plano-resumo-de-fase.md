# Plano — resumo-de-fase: bloco de fechamento em toda fase

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** toda fase passa a fechar imprimindo no terminal um bloco Markdown
padronizado — checkbox das fases, o que produziu, arquivos tocados, próximo
passo — para o humano enxergar a entrega sem abrir arquivo.

**Nó do MEMORY:** `resumo-de-fase` (MEMORY.md)

**Arquitetura da mudança:** o formato do bloco é **schema**, e a Constituição
manda que schema viva só em `templates/`. Então a spec canônica vai para
`templates/bloco-fechamento-template.md` e cada uma das 7 skills de fase ganha
uma seção `## Bloco de fechamento` **curta** (~6 linhas) que aponta para o
template e declara só o que é específico dela: o que entra em "Produzido" e o
que entra em "Próximo". Alternativa descartada: repetir a spec de ~18 linhas
nas 7 skills — 7 cópias que derivam na primeira edição.

**Arquivos lidos antes de planejar:**
- `skills/audora-commander/SKILL.md` (88 linhas), `skills/scope/SKILL.md` (84),
  `skills/plan/SKILL.md` (96), `skills/execute/SKILL.md` (90),
  `skills/e2e/SKILL.md` (104), `skills/validate/SKILL.md` (93),
  `skills/debug/SKILL.md` (103) — as 7 que recebem a seção; todas com folga
  larga para o teto de 250.
- `skills/memory/SKILL.md` (143) e `skills/worktree/SKILL.md` (207) — as 2 que
  NÃO podem receber (critério /9); worktree é a que tem menos folga.
- `tests/test-skills.sh` — loop das 9 skills (linhas 7-25) é onde entram os
  asserts de /8 e /9.
- `tests/test-templates.sh` — 22 linhas, padrão de assert de template (`cat` +
  `assert_contains` por seção). É onde o template novo é coberto.
- `tests/lib.sh` — `assert_contains` é `grep -qF`: literal, sensível a CAIXA,
  e string iniciada por `-` precisa de `--`. Toda string asserida cabe em UMA
  linha do arquivo.
- `MEMORY.md`, bullet `padroes` da Constituição — hoje lista 6 padrões
  obrigatórios de skill; o bloco vira o 7º.
- `README.md` / `README.pt-BR.md` — **não** listam templates individualmente
  (grep vazio), então não precisam mudar.

**Conflitos MEMORY vs código encontrados:** nenhum. Anotado o acoplamento com o
nó `light-enxuto` (planned): ele vai mudar o que LIGHT percorre, e o critério
/5 daqui já manda omitir da lista as fases que a categoria não percorre — os
dois são compatíveis, mas quem mexer em `light-enxuto` relê /5.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

---

## Tarefa 1: suíte cobra o bloco (RED)

- **depende-de**: []
- **requisito**:
  - **resumo-de-fase/8** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
    reprovar se qualquer uma das 7 skills que fecham fase
    (`audora-commander`, `scope`, `plan`, `execute`, `e2e`, `validate`,
    `debug`) não contiver a seção que define o bloco de fechamento
  - **resumo-de-fase/9** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
    reprovar se `memory` ou `worktree` definirem bloco de fechamento próprio —
    são skills-ferramenta, devolvem à fase chamadora e quem imprime é ela
- **decisões relevantes**: schema vive em `templates/` (Constituição), então a
  skill aponta e não copia; `assert_contains` é `grep -qF` literal e sensível
  a caixa — toda string asserida cabe em uma linha.
- **interfaces**:
  - consome: `tests/lib.sh` — `assert_contains`, `assert_not_contains`,
    `assert_file`, `ok`, `ko`, `report`.
  - produz: nada para outras tarefas (é teste).
- **arquivos**:
  - Modificar: `tests/test-skills.sh`
  - Modificar: `tests/test-templates.sh`
- **done quando**: `bash tests/run.sh > /dev/null 2>&1; echo $?` devolve **1**
  e as falhas citam a seção ausente nas 7 skills e o template inexistente —
  falha por feature ausente, nunca por sintaxe do teste.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever teste que falha** — em `tests/test-skills.sh`, ANTES da
  linha `report`, acrescentar:

```bash
# resumo-de-fase/8 — as 7 skills de fase definem o bloco de fechamento
for s in audora-commander scope plan execute e2e validate debug; do
  c="$(cat "skills/$s/SKILL.md" 2>/dev/null)"
  assert_contains "$c" '## Bloco de fechamento' "/8 $s define o bloco"
  assert_contains "$c" 'bloco-fechamento-template.md' "/8 $s aponta o template"
done
# resumo-de-fase/9 — skills-ferramenta NAO definem bloco proprio
for s in memory worktree; do
  c="$(cat "skills/$s/SKILL.md" 2>/dev/null)"
  assert_not_contains "$c" '## Bloco de fechamento' "/9 $s (ferramenta) sem bloco proprio"
done
# /3 e /4 — as duas fases com regra propria declaram a regra
e="$(cat skills/execute/SKILL.md)"
assert_contains "$e" 'só no fim da fase' "/3 execute imprime tarefas so no fim"
v="$(cat skills/validate/SKILL.md)"
assert_contains "$v" 'git diff --name-only' "/4 validate tira arquivos do diff real"
assert_contains "$v" '**Entrega**' "/4 validate imprime o bloco de entrega"
```

- [ ] **2. Escrever teste do template** — em `tests/test-templates.sh`, ANTES
  de `report`:

```bash
# resumo-de-fase/1,/2,/5,/6,/7 — formato canonico do bloco de fechamento
b="$(cat templates/bloco-fechamento-template.md 2>/dev/null)"
assert_file templates/bloco-fechamento-template.md "/1 template do bloco existe"
for parte in '### <id> · <fase> → <próxima>' '- [x]' '- [ ]' '**Produzido**' '**Arquivos**' '**Próximo**'; do
  assert_contains "$b" "$parte" "/1 template tem a parte '$parte'"
done
assert_contains "$b" '**Entrega**' "/4 template define o bloco de entrega"
assert_contains "$b" '| critério | veredito | evidência |' "/4 tabela criterio-veredito"
assert_contains "$b" 'LIGHT' "/5 template trata LIGHT/HOTFIX"
assert_contains "$b" 'caminho real' "/6 template proibe caminho inventado"
assert_contains "$b" 'reprovada' "/7 template trata fase interrompida ou reprovada"
```

- [ ] **3. Rodar e ver falhar pelo motivo certo** —
  `bash tests/run.sh > /tmp/red.log 2>&1; echo $?` deve dar **1**
  (nunca ler o exit de um pipe — aprendizado de 2026-08-31). Esperado em
  `/tmp/red.log`: `FAIL: /8 audora-commander define o bloco` e irmãs (7×2),
  `FAIL: /1 template do bloco existe — arquivo ausente`.
- [ ] **4. Não implementar nada aqui** — o green vem nas Tarefas 2 e 3.
- [ ] **5. Commit** — `git add tests/test-skills.sh tests/test-templates.sh && git commit -m "test(resumo-de-fase/1,3,4,8,9): RED — suite cobra o bloco de fechamento"`

---

## Tarefa 2: template canônico do bloco

- **depende-de**: [Tarefa 1]
- **requisito**:
  - **resumo-de-fase/1** — QUANDO uma fase terminar O SISTEMA DEVE imprimir no
    terminal um bloco Markdown de fechamento com cinco partes: título (`<id da
    demanda> · <fase concluída> → <próxima fase>`), lista de checkbox das
    fases, o que a fase produziu, arquivos tocados e próximo passo
  - **resumo-de-fase/2** — QUANDO o bloco de fechamento listar as fases O
    SISTEMA DEVE marcar `[x]` nas concluídas e `[ ]` nas pendentes, com a fase
    recém-concluída em negrito e um resumo de até 8 palavras ao lado de cada
    concluída
  - **resumo-de-fase/5** — QUANDO a demanda for LIGHT ou HOTFIX O SISTEMA DEVE
    imprimir o bloco mesmo assim, omitindo da lista as fases que aquela
    categoria não percorre — nunca deixá-las como pendentes eternas
  - **resumo-de-fase/6** — QUANDO o bloco citar um arquivo O SISTEMA DEVE
    citar caminho real e existente; caminho prometido ou inventado é falha do
    bloco
  - **resumo-de-fase/7** — QUANDO uma fase for interrompida, bloqueada ou
    reprovada no portão O SISTEMA DEVE imprimir o bloco com a fase NÃO marcada
    e o motivo em 1 linha, em vez de omitir o bloco
- **decisões relevantes**: formato **Padrão** aprovado no portão (não Enxuto,
  não Rico); sem cor, sem emoji obrigatório, sem TUI — Markdown puro; o bloco
  é saída de terminal, nunca arquivo versionado.
- **interfaces**:
  - consome: nada.
  - produz: `templates/bloco-fechamento-template.md` — as strings literais que
    a Tarefa 1 assere e que a Tarefa 3 referencia por nome.
- **arquivos**:
  - Criar: `templates/bloco-fechamento-template.md`
- **done quando**: `bash tests/test-templates.sh` sai 0 e o arquivo tem ≤ 250
  linhas (Constituição).

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Verificar o red desta parte** — `bash tests/test-templates.sh`;
  esperado `FAIL: /1 template do bloco existe — arquivo ausente`.
- [ ] **2. Escrever o template** — com as 6 partes literais do bloco de fase
  (título, `- [x]`, `- [ ]`, `**Produzido**`, `**Arquivos**`, `**Próximo**`),
  o bloco de entrega (`**Entrega**` + `| critério | veredito | evidência |`),
  a regra de LIGHT/HOTFIX, a proibição de `caminho real` inventado e o caso
  `reprovada`/interrompida. Um exemplo preenchido de cada bloco.
- [ ] **3. Rodar** — `bash tests/test-templates.sh`; esperado `FAIL=0`.
- [ ] **4. Suíte toda** — `bash tests/run.sh > /dev/null 2>&1; echo $?`; ainda
  **1**, porque as 7 skills (Tarefa 3) seguem sem a seção. Esperado e correto.
- [ ] **5. Commit** — `git add templates/bloco-fechamento-template.md && git commit -m "feat(resumo-de-fase/1,2,5,6,7): template canonico do bloco de fechamento"`

---

## Tarefa 3: as 7 skills apontam o template; Constituição ganha o 7º padrão

- **expandir: sim** — quebrar em subtarefas (uma por skill + a Constituição)
  SÓ quando chegar a vez dela. Não detalhar agora.
- **depende-de**: [Tarefa 2]
- **requisito**:
  - **resumo-de-fase/3** — QUANDO a fase execute terminar O SISTEMA DEVE
    imprimir a lista de TAREFAS do plano em checkbox, uma linha por tarefa com
    o resultado ao lado, e NÃO imprimir esse bloco a cada tarefa individual
  - **resumo-de-fase/4** — QUANDO a fase validate terminar com aprovação O
    SISTEMA DEVE imprimir um bloco de entrega com (a) tabela critério →
    veredito com a evidência em 1 linha e (b) a lista de arquivos tocados
    obtida de `git diff --name-only` real, nunca de memória
  - **resumo-de-fase/8** e **/9** (verbatim na Tarefa 1)
- **decisões relevantes**: seção curta (~6 linhas) apontando o template, nunca
  cópia da spec; `worktree` tem 207 linhas e NÃO recebe seção (critério /9),
  então o teto de 250 não corre risco em nenhuma skill.
- **interfaces**:
  - consome: `templates/bloco-fechamento-template.md` (Tarefa 2), citado pelo
    nome exato `bloco-fechamento-template.md` que a Tarefa 1 assere.
  - produz: nada para tarefas seguintes.
- **arquivos**:
  - Modificar: `skills/audora-commander/SKILL.md`, `skills/scope/SKILL.md`,
    `skills/plan/SKILL.md`, `skills/execute/SKILL.md`, `skills/e2e/SKILL.md`,
    `skills/validate/SKILL.md`, `skills/debug/SKILL.md`
  - Modificar: `MEMORY.md` (bullet `padroes`: acrescentar "seção `## Bloco de
    fechamento` apontando `templates/bloco-fechamento-template.md`" à lista de
    padrões obrigatórios — vale para skill de FASE; ferramenta não tem)
  - NÃO tocar: `skills/memory/SKILL.md`, `skills/worktree/SKILL.md`
- **done quando**: `bash tests/run.sh > /dev/null 2>&1; echo $?` devolve **0**,
  e `wc -l skills/*/SKILL.md` mostra todas ≤ 250.
