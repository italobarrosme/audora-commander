# Plano — gate-mecanico: gate mecânico por projeto

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** Comando único por projeto que responde passou/não passou (suíte,
lint, typecheck, anti-fraude de teste); GREEN da execute vira gate verde; este
repo gera o próprio gate.

**Nó do MEMORY:** `gate-mecanico` (MEMORY.md)

**Arquitetura da mudança:** O gate tem duas metades: (1) o schema canônico em
`templates/gate-template.md` — esqueleto de script bash com config no topo
(suíte/lint/typecheck/globs/padrões) e bloco anti-fraude genérico sobre
`git diff HEAD`; (2) a instância dogfood `hooks/gate` deste repo, gerada do
template, com toda config sobrescrevível por env `GATE_*` — é isso que permite
a suíte testar o gate com fixture sem recursão (gate real roda `tests/run.sh`,
que roda `test-gate.sh`; o teste injeta `GATE_SUITE_CMD=true`). As skills
ganham edições pontuais: bootstrap e carregar-contexto ofertam o gate; execute
redefine GREEN; validate separa o diff de teste no roteiro.

**Arquivos lidos antes de planejar:**
- `templates/e2e-infra-template.md` — padrão de template de artefato gerado no projeto-alvo
- `templates/plano-template.md` — formato deste plano
- `templates/no-template.md` — onde a justificativa de asserts NÃO entra (schema do nó intacto; marcador definido no gate-template)
- `skills/memory/SKILL.md` — op carregar-contexto inline (T3 edita); 143/250 linhas
- `skills/memory/references/bootstrap.md` — etapa Graphify é o padrão da etapa gate (T3); 39/250
- `skills/execute/SKILL.md` — bullet GREEN do fluxo item 3 (T4); 101/250
- `skills/validate/SKILL.md` — item 3 roteiro + Fechamento LIGHT (T5); 166/250
- `hooks/graphify-status` — padrão de script auxiliar (shebang, set -uo, exit)
- `hooks/run-hook.cmd` — despacho por nome já cobre gate; sem .cmd novo
- `hooks/hooks.json` — gate NÃO entra (não é hook do Claude)
- `tests/lib.sh` — `$SP`, `assert_*`, `report`
- `tests/test-templates.sh`, `tests/test-graphify-status.sh` — padrão de assert de conteúdo e de fixture
- `tests/test-skills.sh` — teto 250 por skill/reference; asserts de conteúdo por arquivo certo
- `tests/test-no-grafo.sh` — crava 9 skills (não mudamos contagem)
- `tests/test-docs.sh`, `tests/run.sh` — descoberta por glob `tests/test-*.sh`
- `.gitattributes` — `hooks/*` e `tests/*` já são LF forçado
- `MEMORY.md` — Constituição (bullet `gate:` novo em T6)

**Conflitos MEMORY vs código encontrados:** nenhum

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

## Decisões tomadas pela IA

- Config do gate por env `GATE_*` com default no arquivo — única forma de
  testar o gate na própria suíte sem recursão.
- Anti-fraude roda ANTES da suíte (barato primeiro, falha rápido) e acumula
  TODOS os motivos antes de sair 1 (não para no primeiro).
- Marcador de justificativa: linha `gate-asserts: <motivo>` no arquivo do nó
  da demanda (`docs/audora/memory/<id>.md`); id chega como `$1` do gate.
- Sem `.cmd` novo: `run-hook.cmd gate` já despacha; skills citam
  `bash hooks/gate` (padrão graphify-status).
- `GATE_ROOT` entra na família de env (descoberto na expansão da T2): sem
  ele, o `cd "$(dirname $0)/.."` do gate ignora a fixture e examina o repo do
  plugin. Template atualizado junto (mesmo commit da T2a).
- Expansão T2: T2a esqueleto+exit+pulos (/3,/4); T2b arquivo apagado (/5);
  T2c skip/only (/6); T2d asserts+válvula (/7,/8). Ciclos red-green: A =
  T2a; B = T2b+T2c+T2d (fixture única, cenários independentes).

---

## Tarefa 1: templates/gate-template.md

- **depende-de**: []
- **requisito**: gate-mecanico/1 (o template que a oferta gera) — "QUANDO o
  bootstrap rodar em projeto sem `gate:` na Constituição O SISTEMA DEVE
  oferecer gerar o gate a partir de `templates/gate-template.md` e registrar a
  escolha na Constituição (`gate: <comando>` ou `gate: recusado`)"
- **decisões relevantes**: schema só em `templates/` (Constituição); padrão
  e2e-infra-template (bloco de código + regras de preenchimento em comentário)
- **interfaces**:
  - produz: contrato do script gate — `uso: gate [<id-da-demanda>]`; config
    `GATE_SUITE_CMD`, `GATE_LINT_CMD`, `GATE_TYPECHECK_CMD`, `GATE_TEST_ERE`,
    `GATE_SKIP_ERE`, `GATE_ASSERT_ERE` (env sobrepõe default); exit 0 com
    `GATE: passou`, exit 1 com `GATE: reprovado` + motivos; anti-fraude sobre
    `git diff HEAD` (working tree + staged); marcador `gate-asserts: <motivo>`
    no nó destrava queda de asserts
- **arquivos**:
  - Criar: `templates/gate-template.md`
  - Teste: `tests/test-gate.sh` (novo; seção de asserts de conteúdo)
- **done quando**: asserts de conteúdo do template verdes; suíte toda verde;
  commit citando gate-mecanico/1

Passos:

- [ ] **1. Red** — criar `tests/test-gate.sh` com asserts: arquivo existe;
  contém `GATE_SUITE_CMD`, `GATE_TEST_ERE`, `GATE_SKIP_ERE`,
  `GATE_ASSERT_ERE`, `gate-asserts:`, `git diff HEAD`, `gate: <comando>`,
  `gate: recusado`, `exit 0`/`exit 1`, aviso de pulo de lint/typecheck.
  Rodar `bash tests/test-gate.sh` e ver FAIL por ausência.
- [ ] **2. Green** — escrever o template: prosa curta (o que é, onde vive no
  projeto-alvo, registro na Constituição, marcador de justificativa) + bloco
  ```bash com o esqueleto completo do script (config no topo, funções
  anti-fraude, ordem: fraude → lint → typecheck → suíte) + comentário de
  regras de preenchimento. Rodar `tests/test-gate.sh` e a suíte inteira.
- [ ] **3. Commit** — `git add templates/gate-template.md tests/test-gate.sh
  && git commit -m "feat(gate-mecanico/1): gate-template canônico"`.

## Tarefa 2: hooks/gate (instância dogfood) — expandir: sim

- **depende-de**: [Tarefa 1]
- **requisito**: gate-mecanico/3 a /8, verbatim no nó — exit 0/1 com motivo;
  pular lint/typecheck ausente avisando; reprovar arquivo de teste apagado
  nomeando; reprovar skip/only com arquivo e linha; reprovar queda de asserts
  sem justificativa (antes → depois); passar com justificativa imprimindo-a
- **decisões relevantes**: diff não commitado vs HEAD (portão de escopo);
  executável só em `hooks/` e `tests/`; env `GATE_*` sobrepõe default
- **interfaces**:
  - consome: contrato do template (Tarefa 1), verbatim — o script É o
    template instanciado para este repo: `GATE_SUITE_CMD` default
    `bash tests/run.sh`, `GATE_TEST_ERE` default `^tests/test-.*\.sh$`,
    `GATE_ASSERT_ERE` default `^[[:space:]]*(assert_[a-z_]+|ok|ko)\b`, lint e
    typecheck default vazios (pula avisando)
  - produz: `hooks/gate` chamável como `bash hooks/gate [<id>]` (Tarefa 6 e
    Constituição consomem)
- **arquivos**:
  - Criar: `hooks/gate`
  - Modificar: `tests/test-gate.sh` (seção fixture)
- **done quando**: fixture em `$SP` (repo git real) exercita os 6 critérios,
  cada um red antes e green depois; suíte toda verde; commits por critério
- **expandir: sim** — quebrar em subtarefas red-green POR CRITÉRIO quando
  chegar a vez (3-4: esqueleto+exit+pulos; 5: arquivo apagado; 6: skip/only;
  7-8: asserts e válvula). A fixture base: `git init` em `$SP/proj`, arquivo
  `tests/test-a.sh` com 3 linhas `assert_eq ...`, commit inicial, e gate
  rodado com `GATE_SUITE_CMD=true` (e `false` para o caminho vermelho de
  suíte). NUNCA rodar o gate com suíte real dentro da suíte (recursão).

## Tarefa 3: oferta do gate (bootstrap + carregar-contexto)

- **depende-de**: [Tarefa 1]
- **requisito**: gate-mecanico/1 e /2, verbatim no nó — oferta no bootstrap;
  oferta UMA vez no início de demanda em projeto sem `gate:`; recusado fica
  recusado
- **decisões relevantes**: padrão Graphify (etapa 4 do bootstrap: bullet já
  existe → não pergunta; recusado registrado); teto 250 linhas
- **interfaces**:
  - consome: `templates/gate-template.md` (Tarefa 1)
  - produz: etapa "gate" no bootstrap.md (espelho da etapa Graphify); passo
    novo na op carregar-contexto do SKILL.md da memory
- **arquivos**:
  - Modificar: `skills/memory/references/bootstrap.md` (etapa 5 nova, após a
    Graphify: bullet `gate:` presente → pular; ausente → oferecer gerar de
    `templates/gate-template.md`, preencher config pela Constituição
    como-rodar/stack, registrar `gate: <comando>` | `gate: recusado`)
  - Modificar: `skills/memory/SKILL.md` (op carregar-contexto, passo novo:
    MEMORY presente sem bullet `gate:` → ofertar uma vez via etapa gate do
    bootstrap.md; `gate: recusado` → não ofertar de novo)
  - Teste: `tests/test-gate.sh` (asserts de conteúdo nos dois arquivos)
- **done quando**: asserts red→green; ambos arquivos ≤ 250 linhas; suíte
  verde; commit citando gate-mecanico/1 e /2

## Tarefa 4: execute — GREEN = gate verde

- **depende-de**: [Tarefa 1]
- **requisito**: gate-mecanico/9 verbatim — "QUANDO a Constituição tiver
  `gate:` O SISTEMA DEVE (skill execute) tratar GREEN como gate verde — etapa
  só é verde com gate saindo 0"
- **decisões relevantes**: teto 250 (execute está em 101)
- **interfaces**: consome o contrato `bash hooks/gate` / bullet `gate:`
- **arquivos**:
  - Modificar: `skills/execute/SKILL.md` — no bullet **GREEN** do fluxo item
    3, acrescentar: "Constituição com `gate:` → verde é o GATE saindo 0
    (rodar o comando do bullet), não só a suíte; sem `gate:`, suíte toda"
  - Teste: `tests/test-gate.sh` (assert de conteúdo em execute/SKILL.md)
- **done quando**: assert red→green; suíte verde; commit citando /9

## Tarefa 5: validate — diff de teste separado

- **depende-de**: [Tarefa 1]
- **requisito**: gate-mecanico/10 verbatim — "QUANDO a validate montar o
  roteiro O SISTEMA DEVE listar o diff dos arquivos de teste separado do
  resto, em toda categoria"
- **decisões relevantes**: teto 250 (validate está em 166); Fechamento LIGHT
  também recebe (— "em toda categoria")
- **interfaces**: nenhuma
- **arquivos**:
  - Modificar: `skills/validate/SKILL.md` — item 3 (Comportamento) ganha
    bullet: "Diff de teste (toda categoria): listar o diff dos arquivos de
    teste separado do resto — teste apagado/skip é onde mora a fraude"; e no
    Fechamento LIGHT, o bullet do roteiro passa a citar "o diff (arquivos de
    teste separados)"
  - Teste: `tests/test-gate.sh` (asserts de conteúdo, incluindo dentro da
    seção LIGHT via awk como em test-skills.sh linha 124)
- **done quando**: asserts red→green; suíte verde; commit citando /10

## Tarefa 6: Constituição gate: + prova dogfood

- **depende-de**: [Tarefa 2]
- **requisito**: gate-mecanico/11 verbatim — "QUANDO esta demanda for
  entregue O SISTEMA DEVE ter o gate deste próprio repo gerado do template,
  vivendo em `hooks/` e registrado como `gate:` na Constituição"
- **decisões relevantes**: registrar-delta item 4 (editar bullet direto na
  Constituição); NÃO rodar gate-com-suíte-real dentro da suíte
- **interfaces**: consome `bash hooks/gate` (Tarefa 2)
- **arquivos**:
  - Modificar: `MEMORY.md` — Constituição, bullet novo:
    `- **gate**: bash hooks/gate <id-da-demanda> (suíte + anti-fraude; lint/typecheck: ausentes, pulados com aviso)`
  - Teste: `tests/test-gate.sh` — asserts: MEMORY.md contém `**gate**:`;
    `hooks/gate` existe e é o template instanciado (contém as mesmas vars
    `GATE_*`)
- **done quando**: asserts red→green; suíte verde; evidência manual UMA vez
  (fora da suíte): `bash hooks/gate gate-mecanico` em working tree limpo →
  `GATE: passou`, exit 0 (guardar saída para a validate); commit citando /11

<!-- Proibições (falhas de plano): TBD; TODO; "tratar erros adequadamente";
"similar à tarefa N"; passo sem como; referência órfã. -->
