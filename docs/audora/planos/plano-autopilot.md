# Plano — autopilot: portão antecipado por declaração

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** Declaração explícita do humano antecipa os portões do meio
(LIGHT/MEDIUM; HIGH recusa), com elegibilidade checada no scope, e2e sem
oferta na validate, contador `paradas humanas: N` e campo `autopilot:` no
schema do nó.

**Nó do MEMORY:** `autopilot` (MEMORY.md); spec
`docs/audora/specs/autopilot-escopo.md` (autopilot/1..14)

**Arquitetura da mudança:** Autopilot é PROSA de skill + 1 campo de schema —
zero código novo. Cada skill de fase ganha um bloco curto condicionado a
`autopilot: declarado|elegivel` no nó; o campo é documentado em
`templates/no-template.md` e o hook `memory-validate` NÃO muda (ele só lê
`depende-de` do frontmatter — campo desconhecido já é ignorado, e a suíte
prova isso ANTES por teste de caracterização, como o roadmap exige). O
portão final da validate fica declarado DENTRO da seção de autopilot da
validate e um teste negativo assere lá dentro (awk na seção, padrão
test-skills linha 124).

**Arquivos lidos antes de planejar:**
- `docs/audora/specs/autopilot-escopo.md` — os 14 critérios
- `skills/audora-commander/SKILL.md` (98 linhas) — fluxo item 3-5 e Regras de categoria (T2 insere seção após)
- `skills/scope/SKILL.md` (107) — item 6 auto-revisão e item 7 portão (T3)
- `skills/plan/SKILL.md` (106) — sem mudança (MEDIUM já segue direto; só lê o campo)
- `skills/e2e/SKILL.md` (114) — sem mudança (a OFERTA vive na validate; decisão registrada abaixo)
- `skills/validate/SKILL.md` (169) — item 1 oferta, item 3 roteiro, `## Fechamento LIGHT`, `## Bloco de fechamento` (T4/T5)
- `templates/no-template.md` (71) — frontmatter comentado (T1 adiciona `autopilot:`)
- `templates/bloco-fechamento-template.md` (111) — sem mudança (contador é linha da validate, não do formato canônico)
- `hooks/memory-validate` (111) — só lê `depende-de`; campo novo passa (T1 prova)
- `tests/test-memory-validate.sh` (41) — padrão mk/no/run_hook para a fixture do T1
- `tests/test-skills.sh` (182) — padrão de assert por localização + awk de seção
- `docs/fundamentos.md` (271; P4 tabela linha 146-151, P5 regras linha 182-204) — T6; nomes pré-0.3.0 mantidos (aviso declarado no README)
- `MEMORY.md` — Constituição (teto 250 por skill; schema só em templates/)

**Conflitos MEMORY vs código encontrados:** nenhum

## Notas de sessão

## Decisões tomadas pela IA

- `skills/e2e/SKILL.md` intocada: a oferta de e2e mora no item 1 da validate;
  o e2e continua "opcional por decisão do humano" — a declaração de autopilot
  É a decisão do humano, antecipada.
- `bloco-fechamento-template.md` intocado: `paradas humanas: N` é conteúdo do
  bloco DA VALIDATE (seção Bloco de fechamento da skill), não parte do
  formato canônico de toda fase.
- Contador com formato fixo:
  `paradas humanas: N (X lotes de scope, Y ofertas, Z portões)`.

---

## Tarefa 1: schema — campo autopilot: no nó

- **depende-de**: []
- **requisito**: autopilot/12 verbatim — "QUANDO `hooks/memory-validate`
  validar nó com o campo `autopilot:` O SISTEMA DEVE aceitar os valores
  `declarado | elegivel | inelegivel (<id>/<n>)` sem exit 2;
  `templates/no-template.md` documenta o campo comentado — e a suíte prova
  ANTES da mudança como o hook trata campo desconhecido hoje"
- **decisões relevantes**: schema só em `templates/`; hook não muda
- **interfaces**:
  - produz: enum documentado `autopilot: declarado | elegivel |
    inelegivel (<id>/<n>)` (T2/T3 escrevem esses valores)
- **arquivos**:
  - Modificar: `templates/no-template.md` (comentário do frontmatter ganha a
    linha do campo e o enum, ao lado de `origem:`/`depende-de:`)
  - Teste: `tests/test-autopilot.sh` (novo)
- **done quando**: fixture `mk`/`no` com nó contendo `autopilot: declarado` →
  `run_hook memory-validate` exit 0 (caracterização, roda ANTES da mudança e
  fica como regressão); assert de conteúdo do template red→green; suíte
  verde; commit citando /12

Passos:

- [ ] **1.** Criar `tests/test-autopilot.sh` (source lib.sh; helpers mk/no
  copiados de test-memory-validate.sh com o campo extra `autopilot: %s` no
  printf do nó): caso `autopilot-ok` → exit 0 + stderr vazio (caracterização
  do hook, VERDE de primeira por design — anotar no comentário do teste);
  assert `assert_contains "$(cat templates/no-template.md)" 'autopilot:'` e
  `'inelegivel (<id>/<n>)'` (red).
- [ ] **2.** Rodar, ver red só nos asserts de template.
- [ ] **3.** Editar o comentário do `no-template.md`:
  `autopilot: (opcional) declarado | elegivel | inelegivel (<id>/<n>) — preenchido pela porta de entrada e pela auto-revisão do scope`.
- [ ] **4.** `bash tests/test-autopilot.sh` verde; `bash tests/run.sh` verde.
- [ ] **5.** Commit `feat(autopilot/12): ...`.

## Tarefa 2: porta de entrada — declaração e catraca

- **depende-de**: [Tarefa 1]
- **requisito**: autopilot/1, /2, /3 verbatim (spec, lote A)
- **decisões relevantes**: ativação só espontânea (nunca ofertar); tardia
  vale; teto 250 (98 → ~112)
- **interfaces**: consome o enum da T1; produz a frase de recusa que T5 pode
  citar
- **arquivos**:
  - Modificar: `skills/audora-commander/SKILL.md` — seção nova
    `## Autopilot (declaração do humano)` após "Regras de categoria":
    reconhecer "autopilot"/"roda até o validate" (entrada OU meio da
    demanda); LIGHT/MEDIUM → registrar `autopilot: declarado` no nó e avisar
    que os portões do meio estão antecipados (o final NUNCA); HIGH → recusar
    nomeando o motivo (P4: portão nunca escala para baixo) e seguir o fluxo
    normal; tardia → elegibilidade na hora (critérios já existem), antecipa
    só os portões ainda não cruzados, linha em `## decisoes` do nó; NUNCA
    ofertar autopilot por iniciativa própria.
  - Teste: `tests/test-autopilot.sh` — asserts: `'## Autopilot'`,
    `'roda até o validate'`, `'autopilot: declarado'`, `'HIGH → recusar'`
    (ou frase equivalente numa linha), `'nunca ofertar'`, `'ainda não
    cruzados'`.
- **done quando**: asserts red→green; ≤ 250 linhas; suíte verde; commit
  citando /1,/2,/3

## Tarefa 3: scope — elegibilidade e portão antecipado

- **depende-de**: [Tarefa 2]
- **requisito**: autopilot/5, /6, /7 verbatim (spec, lote B)
- **decisões relevantes**: `[PRECISA-CLARIFICAR]` é parada, nunca suposição
  (P3.2); teto 250 (107 → ~121)
- **interfaces**: consome enum T1; grava `autopilot: elegivel | inelegivel
  (<id>/<n>)` que T4/T5 leem
- **arquivos**:
  - Modificar: `skills/scope/SKILL.md` — item 6 (auto-revisão) ganha a
    checagem: nó com `autopilot: declarado` → todo critério tem verificação
    automatizável (teste, e2e, comando)? sim → gravar `autopilot: elegivel`;
    não → `autopilot: inelegivel (<id>/<n>)` citando o primeiro culpado,
    avisar e seguir fluxo normal. Item 7 (portão) ganha o desvio: elegível e
    sem marcador aberto → portão ANTECIPADO (aprovado na entrada): registrar
    em `## decisoes` e seguir para plan; a validate ratifica. Marcador
    aberto → parar com o bloco de fechamento (fase desmarcada + marcador).
  - Teste: `tests/test-autopilot.sh` — asserts: `'autopilot: elegivel'`,
    `'autopilot: inelegivel (<id>/<n>)'`, `'portão antecipado'` (na scope),
    `'a validate ratifica'`.
- **done quando**: asserts red→green; ≤ 250; suíte verde; commit /5,/6,/7

## Tarefa 4: validate — e2e sem oferta em autopilot

- **depende-de**: [Tarefa 3]
- **requisito**: autopilot/4, /8, /9 verbatim (spec, lotes A e C)
- **decisões relevantes**: `skills/e2e/SKILL.md` intocada (decisão da IA
  acima); enum de e2e do nó ganha o valor novo
- **interfaces**: consome `autopilot: elegivel` (T3)
- **arquivos**:
  - Modificar: `skills/validate/SKILL.md` — item 1 (oferta) ganha: nó com
    autopilot → SEM pergunta: Constituição com `ferramenta-e2e` → rodar o
    e2e direto; sem → registrar `e2e: pulado-por-autopilot-sem-ferramenta`
    no nó, visível no portão. No `## Fechamento LIGHT`, mesma regra em 1
    frase (único portão do meio de LIGHT).
  - Teste: `tests/test-autopilot.sh` — asserts:
    `'pulado-por-autopilot-sem-ferramenta'` no arquivo e
    `'sem-ferramenta'` DENTRO da seção LIGHT (awk).
- **done quando**: asserts red→green; suíte verde; commit /4,/8,/9

## Tarefa 5: validate — roteiro, contador e teste negativo

- **depende-de**: [Tarefa 4]
- **requisito**: autopilot/10, /11, /13 verbatim (spec, lotes C e D)
- **decisões relevantes**: contador em TODA demanda (baseline da métrica);
  formato fixo do contador (decisão da IA acima); teto 250 (validate ~180
  após T4)
- **interfaces**: nenhuma nova
- **arquivos**:
  - Modificar: `skills/validate/SKILL.md` — item 3 (roteiro) ganha bullet:
    demanda em autopilot → seção "Premissas e decisões tomadas sem portão"
    (o escopo antecipado apresentado para ratificação). `## Bloco de
    fechamento` ganha: em TODA demanda, Produzido inclui
    `paradas humanas: N (X lotes de scope, Y ofertas, Z portões)`. A seção
    de autopilot declara na primeira linha: o portão final NUNCA é
    antecipado.
  - Teste: `tests/test-autopilot.sh` — asserts:
    `'Premissas e decisões tomadas sem portão'`, `'paradas humanas: N'`, e o
    TESTE NEGATIVO do /13: awk extrai o trecho de autopilot da validate e
    assere `'portão final'` + `'NUNCA'` lá dentro (fora da seção não conta —
    padrão do guarda LIGHT, test-skills.sh:124).
- **done quando**: asserts red→green; suíte verde; commit /10,/11,/13

## Tarefa 6: fundamentos — P4 e P5

- **depende-de**: [Tarefa 5]
- **requisito**: autopilot/14 verbatim (spec, lote D)
- **decisões relevantes**: fundamentos mantém nomes pré-0.3.0 (LEVE/MÉDIA/
  ALTA) — a coluna nova segue o estilo do arquivo
- **interfaces**: nenhuma
- **arquivos**:
  - Modificar: `docs/fundamentos.md` — tabela do P4 (linha 146) ganha a
    coluna `Autopilot`: LEVE `resultado (e2e sem oferta)`; MÉDIA
    `resultado`; ALTA `recusado`; HOTFIX `—`. P5 ganha a regra 8:
    "**Portão antecipado por declaração**: o humano pode declarar autopilot
    (LEVE/MÉDIA) — os portões do meio ficam aprovados na entrada; o portão
    final NUNCA é antecipado; ALTA recusa (catraca do P4)."
  - Teste: `tests/test-autopilot.sh` — asserts: `'| Autopilot |'` (header da
    tabela) e `'Portão antecipado por declaração'` no fundamentos.
- **done quando**: asserts red→green; suíte verde; commit /14

<!-- Proibições (falhas de plano): TBD; TODO; "tratar erros adequadamente";
"similar à tarefa N"; passo sem como; referência órfã. -->
