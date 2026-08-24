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
- docs-bilingues | entregue | README bilíngue (inglês na raiz + pt-BR linkado) → ver GRAFO-ARQUIVO.md
- grafo-v2 | planejada | Redesenho do GRAFO para travessia rápida (estudo de mercado)
- grafo-inicio-fim | planejada | GRAFO escrito/atualizado no início e no fim de toda demanda
- skill-memory | planejada | Skill MEMORY: memória inteligente da audora por projeto
- e2e-playwright-docker | em-curso | e2e com Playwright + docker compose como infra default
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

### e2e-playwright-docker

- **id**: e2e-playwright-docker
- **estado**: em-curso
- **origem**: humano
- **depende-de**: []
- **objetivo**: A skill e2e passa a adotar Playwright como ferramenta padrão
  para exercitar a demanda e docker compose como infra default para levantar
  o projeto durante o teste de ponta a ponta.
- **criterios-aceite**:
  - QUANDO a demanda validada tiver interface web O SISTEMA DEVE usar
    Playwright como ferramenta default para exercitar os critérios no e2e
  - QUANDO o projeto-alvo não for web (API pura, CLI, worker) O SISTEMA DEVE
    perguntar ao usuário qual ferramenta usar antes de exercitar — nunca
    escolher sozinho
  - QUANDO o e2e for iniciado e o projeto tiver docker compose O SISTEMA
    DEVE levantar a infra do teste por ele (default)
  - QUANDO o projeto não tiver docker compose O SISTEMA DEVE gerar um
    compose de e2e a partir da stack/constituição (app + dependências) e
    usá-lo como default
  - QUANDO Docker não estiver disponível na máquina O SISTEMA DEVE cair para
    o como-rodar da constituição, com aviso explícito ao usuário
  - QUANDO o e2e gerar artefatos (compose de e2e, specs Playwright) O SISTEMA
    DEVE versioná-los no projeto-alvo, e QUANDO já existirem O SISTEMA DEVE
    estendê-los/reaproveitá-los em vez de recriar do zero
  - QUANDO a infra do compose falhar ao subir (porta ocupada, imagem
    indisponível, serviço unhealthy) O SISTEMA DEVE reportar o log do erro e
    perguntar ao usuário (corrigir, fallback como-rodar, ou abortar) — nunca
    silenciar a falha nem seguir com infra parcial
  - QUANDO o e2e terminar (sucesso ou falha) O SISTEMA DEVE derrubar a infra
    que ele mesmo levantou (compose down), deixando a máquina limpa
- **fora-de-escopo**: rodar e2e em CI/CD (pipeline); testes de
  carga/performance; mobile nativo; geração de compose de produção (só infra
  de teste); instalar Docker/Playwright na máquina do usuário (pré-requisito
  — a skill só avisa); alterar o fluxo das demais skills (a validar continua
  oferecendo o e2e como hoje).
- **decisoes**:
  - 2026-08-24 (humano): demanda aberta com prioridade máxima da fila nova
    (escopo em paralelo ao estudo do grafo-v2).
  - 2026-08-24 (humano): Playwright é default SÓ para web; projeto não-web →
    a skill pergunta ao usuário qual ferramenta usar no passo do e2e.
  - 2026-08-24 (humano): sem compose no projeto → a skill GERA compose de
    e2e pela stack/constituição; Docker indisponível → fallback como-rodar
    com aviso.
  - 2026-08-24 (humano): artefatos de e2e (compose de teste, specs
    Playwright) versionados no projeto-alvo — regressão reaproveitável.
  - 2026-08-24 (humano): escopo aprovado no portão (8 critérios EARS).
- **delta**:
- **e2e**: pendente
- **feedback-reprovacao**:
- **atualizado-em**: 2026-08-24

<!-- Regras de manutenção: ver templates/GRAFO-template.md (skill grafo). -->
