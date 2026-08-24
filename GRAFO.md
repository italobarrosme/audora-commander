versao-schema: 1

# GRAFO — audora-commander

> Memória externa do produto. Requisito não escrito aqui é requisito que não
> existe. Atualizado por delta durante a demanda; sincronizado na validação.

## Propósito [carga: sempre]

Plugin de Claude Code que implementa um framework de desenvolvimento assistido
por IA com 5 princípios: GRAFO vivo, planejamento just-in-time, separação
O-Quê/Como, processo proporcional ao risco, e IA executa / humano decide.
Público: dev solo ou time pequeno em projetos web/mobile/api.

## Constituição [carga: sempre]

- **stack**: Markdown (skills, templates, docs) + JSON (manifests, hook) +
  bash (scripts de hook). Sem código executável além dos hooks.
- **restricoes**: cada SKILL.md ≤ 250 linhas; conteúdo em português (exceção
  aprovada 2026-08-24: README.md principal em inglês, com README.pt-BR.md
  linkado); schemas vivem só em `templates/`; hook injeta ponteiro curto,
  nunca o framework inteiro; Windows suportado via wrapper polyglot `.cmd`.
- **padroes**: toda skill tem frontmatter `name`+`description` ("Use
  quando..."), Lei de Ferro em bloco de código no topo, "Anuncie ao começar",
  fluxo numerado, tabela de red flags e seção "PRÓXIMA SKILL".
- **como-rodar**: plugin não "roda" — validação é instalação real em sessão
  interativa do Claude Code (`/plugin marketplace add <pasta deste repo>` +
  `/plugin install audora-commander@audora-commander-dev`) seguida do
  checklist do README.md.

## Índice de nós [carga: sempre]

- plugin-v0.1.0 | em-curso | Plugin funcional com 8 skills, hook, templates e marketplace
- docs-bilingues | em-curso | README bilíngue: principal em inglês na raiz, README.pt-BR.md em português
- grafo-v2 | planejada | Redesenho do GRAFO para travessia rápida (estudo de mercado)
- grafo-inicio-fim | planejada | GRAFO escrito/atualizado no início e no fim de toda demanda
- skill-memory | planejada | Skill MEMORY: memória inteligente da audora por projeto
- e2e-playwright-docker | planejada | e2e com Playwright + docker compose como infra default
- skill-poc | planejada | Skill POC: ≥3 POCs por demanda exploratória, usuário escolhe 1
- skill-depurar | entregue | Skill de debug (sintoma/caçada) → ver GRAFO-ARQUIVO.md
- porte-multi-harness | planejada | Porte para outros harnesses (Codex, Cursor)
- marketplace-publico | planejada | Publicação em marketplace público
- agentes-dedicados | planejada | Subagent types customizados por fase

## Nós [carga: auto — carregar somente os nós tocados pela demanda]

### plugin-v0.1.0

- **id**: plugin-v0.1.0
- **estado**: em-curso
- **origem**: humano
- **depende-de**: []
- **objetivo**: Plugin instalável do Claude Code com as 7 skills do framework,
  hook de SessionStart, templates canônicos e marketplace local de
  desenvolvimento.
- **criterios-aceite**:
  - QUANDO o marketplace local for adicionado e o plugin instalado O SISTEMA
    DEVE listar as 7 skills com prefixo `audora-commander:`
  - QUANDO uma sessão nova iniciar com o plugin ativo O SISTEMA DEVE injetar o
    ponteiro do hook no contexto
  - QUANDO a skill audora-commander for invocada num projeto sem GRAFO.md
    O SISTEMA DEVE oferecer bootstrap em vez de travar ou inventar conteúdo
  - QUANDO cada skill for invocada isoladamente O SISTEMA DEVE carregar seu
    conteúdo sem erro e sem placeholders
  - QUANDO uma demanda LEVE e uma MÉDIA forem simuladas O SISTEMA DEVE
    produzir os artefatos esperados (nó no GRAFO, plano-arquivo na MÉDIA,
    roteiro de validação)
- **fora-de-escopo**: porte multi-harness; marketplace público; agentes
  dedicados; automação de git hooks (nós próprios ou v futura).
- **decisoes**:
  - 2026-08-14 (humano): formato plugin padrão Superpowers; 6→7 skills com
    adição do e2e opcional-recomendado; nomes em português.
  - 2026-08-14 (humano): fundamentos v2 aprovados (crítica adversarial +
    acertos do gênero integrados).
  - 2026-08-14 (IA): verificação de placeholder case-sensitive com exceção
    para listas de proibição (falso positivo com "todo" em português).
- **delta**:
  - MODIFICADO (2026-08-15): critério 1 — "listar as 7 skills" → "listar as
    8 skills" (skill depurar adicionada pelo nó skill-depurar); objetivo
    idem. Motivo: caçada A3, divergência nó vs README.
- **e2e**: pendente — critérios 1, 2 e 5 dependem de sessão interativa do
  humano (checklist do README).
- **feedback-reprovacao**:
- **atualizado-em**: 2026-08-14

### docs-bilingues

- **id**: docs-bilingues
- **estado**: em-curso
- **origem**: humano
- **depende-de**: []
- **objetivo**: README.md principal reescrito em inglês (idioma padrão do
  projeto open-source) na raiz, com link para README.pt-BR.md contendo a
  versão em português.
- **criterios-aceite**:
  - QUANDO alguém abrir o README.md na raiz do repositório O SISTEMA DEVE
    apresentar todo o conteúdo em inglês, com paridade completa ao conteúdo
    hoje existente em português (propósito, pré-requisitos, instalação,
    tabela das 8 skills, fluxo de uso, artefatos, checklist de validação,
    desenvolvimento) — nenhuma seção omitida
  - QUANDO o README.md em inglês for aberto O SISTEMA DEVE exibir, logo
    abaixo do título, um link visível para a versão em português apontando
    para README.pt-BR.md
  - QUANDO README.pt-BR.md for aberto O SISTEMA DEVE apresentar o mesmo
    conteúdo em português, com paridade ao README.md em inglês, e um link de
    volta para a versão em inglês apontando para README.md
  - QUANDO um comando, nome de arquivo, flag ou trecho de código aparecer em
    qualquer um dos dois READMEs O SISTEMA DEVE mantê-lo inalterado (só prosa
    é traduzida, comandos não)
  - QUANDO o README.md em inglês referenciar outro documento do repositório
    (ex.: docs/fundamentos.md) O SISTEMA DEVE preservar o link funcional,
    mesmo que o documento referenciado continue só em português
- **fora-de-escopo**: tradução de outros documentos do repositório
  (docs/fundamentos.md, specs, skills, templates); i18n de mensagens de
  hook/skill; suporte a mais de 2 idiomas.
- **decisoes**:
  - 2026-08-24 (humano): inglês é o idioma principal (README.md na raiz);
    português vira README.pt-BR.md linkado.
  - 2026-08-24 (IA): nome do arquivo em português segue convenção padrão do
    GitHub, README.pt-BR.md (decisão de implementação, não de produto —
    não muda comportamento observável além do já coberto pelos critérios).
  - 2026-08-24 (humano): escopo aprovado no portão, incluindo exceção da
    constituição — README em inglês; demais docs do repo seguem em português.
- **delta**:
- **e2e**: pendente
- **feedback-reprovacao**:
- **atualizado-em**: 2026-08-24

<!-- Regras de manutenção: ver templates/GRAFO-template.md (skill grafo). -->
