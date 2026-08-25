# Escopo — comandos-ingles (ALTA)

> Nó: `comandos-ingles` (GRAFO.md). Depende de `plugin-v0.1.0`. Data:
> 2026-08-25.

## Objetivo

Os identificadores que o usuário digita e o framework anuncia passam a ser
em inglês — nomes dos comandos (skills), categorias de risco e enum de estado
dos nós do GRAFO — mantendo a prosa do framework em português. Mudança é
breaking (plugin 0.3.0): comandos antigos deixam de existir e GRAFOs de
projetos-alvo migram integralmente no primeiro toque de escrita.

## Dicionário (aprovado no portão de escopo)

| Tipo | Antes (PT) | Depois (EN) |
|---|---|---|
| comando | `audora-commander` | `audora-commander` (inalterado) |
| comando | `grafo` | `graph` |
| comando | `escopo` | `scope` |
| comando | `plano` | `plan` |
| comando | `executar` | `execute` |
| comando | `e2e` | `e2e` (inalterado) |
| comando | `validar` | `validate` |
| comando | `depurar` | `debug` |
| categoria | LEVE / MÉDIA / ALTA / HOTFIX | LIGHT / MEDIUM / HIGH / HOTFIX |
| estado | planejada | planned |
| estado | em-curso | in-progress |
| estado | bloqueada | blocked |
| estado | entregue | delivered |
| estado | descartada | discarded |
| estado | hotfix-pendente-registro | hotfix-pending-record |

## Critérios de aceite (endereço citável `comandos-ingles/<n>`)

### Comandos

- **comandos-ingles/1.1** — QUANDO o plugin for instalado O SISTEMA DEVE
  listar exatamente 8 skills com prefixo `audora-commander:`:
  `audora-commander`, `graph`, `scope`, `plan`, `execute`, `e2e`,
  `validate`, `debug` — e nenhuma com nome antigo (corte seco, sem alias).
- **comandos-ingles/1.2** — QUANDO uma sessão iniciar com o plugin ativo
  O SISTEMA DEVE injetar o ponteiro do hook citando os comandos pelos nomes
  em inglês.
- **comandos-ingles/1.3** — QUANDO uma skill referenciar outra (roteamento,
  "PRÓXIMA SKILL", chamada de operação) O SISTEMA DEVE usar só o nome em
  inglês — zero ocorrências dos nomes antigos como identificador de comando
  em `skills/`, `hooks/`, `templates/`, `README*.md`, `PRD.md`, `install.*`.

### Categorias

- **comandos-ingles/2.1** — QUANDO a porta de entrada classificar uma demanda
  O SISTEMA DEVE anunciar e registrar a categoria como LIGHT, MEDIUM, HIGH
  ou HOTFIX; a tabela de roteamento e as regras de catraca usam esses nomes.
- **comandos-ingles/2.2** — QUANDO skills, templates, hook e READMEs
  mencionarem categoria de risco O SISTEMA DEVE usar só os nomes em inglês
  (zero LEVE/MÉDIA/ALTA como categoria nos artefatos vivos do plugin).

### Estados do GRAFO

- **comandos-ingles/3.1** — QUANDO um nó for criado ou atualizado
  O SISTEMA DEVE gravar `estado:` com valor do enum em inglês
  (`planned | in-progress | blocked | delivered | discarded`, mais o
  transitório `hotfix-pending-record`), no arquivo do nó E na linha do índice.
- **comandos-ingles/3.2** — QUANDO a primeira escrita no GRAFO de um projeto
  (registrar-no, registrar-delta, compactar) encontrar qualquer estado em
  português O SISTEMA DEVE converter TODOS os estados PT→EN na mesma
  demanda — índice mestre, `docs/audora/nos/*.md`, `docs/audora/arquivo/*.md`,
  `GRAFO-ARQUIVO.md` legado e nós inline legados — antes de concluir a
  operação pedida. Em projeto v1 (monólito) a conversão cobre todos os
  estados do monólito na mesma edição, sem exigir migração v1→v2 além da
  on-touch já existente.
- **comandos-ingles/3.3** — QUANDO uma operação só de leitura
  (carregar-contexto, consulta estrutural por grep) encontrar estados em
  português O SISTEMA DEVE ler normalmente e avisar que a migração ocorrerá
  na primeira escrita — leitura nunca migra.
- **comandos-ingles/3.4** — QUANDO o hook `grafo-validate` rodar sobre um
  GRAFO v2 cujo índice contenha estado fora do enum em inglês O SISTEMA DEVE
  acusar (exit 2) com mensagem apontando a migração PT→EN pela skill `graph`.
- **comandos-ingles/3.5** — QUANDO o hook rodar sem bash ou sobre GRAFO v1
  O SISTEMA DEVE manter o comportamento atual (exit 0 / degradação) — a
  skill segue sendo a fonte normativa da migração.

### Documentação, versão e dogfood

- **comandos-ingles/4.1** — QUANDO o usuário abrir `README.md` ou
  `README.pt-BR.md` O SISTEMA DEVE apresentar a tabela de renomeação PT→EN
  (comandos, categorias, estados) e a nota de breaking change 0.3.0.
- **comandos-ingles/4.2** — QUANDO o plugin for listado O SISTEMA DEVE
  exibir versão `0.3.0` (plugin.json, marketplace.json e PRD coerentes).
- **comandos-ingles/4.3** — QUANDO o GRAFO deste repositório for lido após a
  entrega O SISTEMA DEVE estar integralmente no enum EN (índice, nós ativos,
  arquivo, GRAFO-ARQUIVO.md) e os critérios ativos que citam categoria
  (`plugin-v0.1.0/5`) atualizados via delta MODIFICADO.

## Fora de escopo

- Prosa das skills, templates, hook, docs e PRD — segue em português.
- Chaves do frontmatter (`estado:`, `depende-de:`, `arquivos:`,
  `atualizado-em:`), nomes de seção (`## criterios-aceite`, `## delta`),
  cabeçalhos do índice (`## Índice de nós`) e nomes de arquivo/pasta
  (`GRAFO.md`, `docs/audora/nos/`, `arquivo/`, `planos/`,
  `decisoes-vivas.md`) — inalterados.
- O artefato continua se chamando GRAFO; só o comando vira `graph`.
- Aliases ou redirecionamentos dos comandos antigos.
- `versao-schema` permanece `2` (enum de estado não é versão de schema).
- Reescrita de prosa histórica: `docs/specs/*`, `docs/audora/planos/*`,
  `docs/audora/depuracao/*`, corpo dos nós arquivados — só o campo `estado:`
  é convertido (3.2), texto não.
- Categorias citadas em prosa de nós de projetos-alvo (histórico) — não são
  reescritas; só este repo atualiza critério ativo (4.3).
- Tradução de ids de nó (kebab-case semântico, idioma livre).

## Decisões

Humanas (portão de escopo, 2026-08-25):

- Nomes: `graph, scope, plan, execute, e2e, validate, debug`.
- Categorias: `LIGHT / MEDIUM / HIGH / HOTFIX`.
- Fronteira: comandos + categorias + enum de estado; prosa fica PT.
- GRAFOs existentes: migração total no primeiro toque de escrita; hook só
  aceita EN depois.
- Comandos antigos: corte seco, sem alias; plugin 0.3.0.

Defaults da IA (revisar neste portão):

- Enum EN de estado conforme dicionário acima (`in-progress` com hífen,
  espelhando `em-curso`; `hotfix-pending-record`).
- Emenda à Constituição deste repo, aplicada no sync da validar: "conteúdo
  em português (exceções: README.md principal em inglês; nomes de skills,
  categorias de risco e enum de estado em inglês)". A decisão viva de
  2026-08-24 ("tokens literais de comando nunca traduzem") permanece válida —
  ela fala de tradução de README, não de renomeação do produto.
- Leitura tolerante (3.3) existe para a porta de entrada conseguir carregar
  contexto ANTES da primeira escrita; sem ela nenhuma demanda nova
  conseguiria começar num projeto ainda em PT.

## Riscos anotados

- Teto de 250 linhas por SKILL.md: a skill `graph` (ex-`grafo`) é a mais
  pressionada; a tabela de migração de estado deve viver em
  `templates/no-template.md`, não na skill.
- Hook 3.4 passa a rejeitar estado PT no índice v2: projeto que editar um
  arquivo de nó antes do índice recebe o erro — é o comportamento desejado
  (força a migração), mas a mensagem precisa dizer exatamente o que fazer.
- Renomear diretórios de skill em Git no Windows (case/encoding) — usar
  `git mv` para preservar histórico.
