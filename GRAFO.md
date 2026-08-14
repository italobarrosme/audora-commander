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
- **restricoes**: cada SKILL.md ≤ 250 linhas; conteúdo em português; schemas
  vivem só em `templates/`; hook injeta ponteiro curto, nunca o framework
  inteiro; Windows suportado via wrapper polyglot `.cmd`.
- **padroes**: toda skill tem frontmatter `name`+`description` ("Use
  quando..."), Lei de Ferro em bloco de código no topo, "Anuncie ao começar",
  fluxo numerado, tabela de red flags e seção "PRÓXIMA SKILL".
- **como-rodar**: plugin não "roda" — validação é instalação real em sessão
  interativa do Claude Code (`/plugin marketplace add <pasta deste repo>` +
  `/plugin install audora-commander@audora-commander-dev`) seguida do
  checklist do README.md.

## Índice de nós [carga: sempre]

- plugin-v0.1.0 | em-curso | Plugin funcional com 7 skills, hook, templates e marketplace
- skill-depurar | em-curso | Skill de debug: causa raiz com sintoma, caçada sem sintoma
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
- **e2e**: pendente — critérios 1, 2 e 5 dependem de sessão interativa do
  humano (checklist do README).
- **feedback-reprovacao**:
- **atualizado-em**: 2026-08-14

### skill-depurar

- **id**: skill-depurar
- **estado**: em-curso
- **origem**: humano
- **depende-de**: [plugin-v0.1.0]
- **objetivo**: Skill `depurar` no plugin: debug sistemático com causa raiz
  demonstrada quando há sintoma, e caçada de bugs por classes de defeito
  quando não há. Testada rodando a caçada no próprio repositório.
- **criterios-aceite**:
  - QUANDO a skill depurar for invocada com sintoma conhecido O SISTEMA DEVE
    conduzir reprodução → hipóteses → causa raiz demonstrada ANTES de qualquer
    correção
  - QUANDO a skill depurar for invocada sem sintoma (caçada) O SISTEMA DEVE
    varrer classes de defeito definidas e verificar cada achado antes de
    reportar
  - QUANDO a caçada rodar no repositório audora-commander O SISTEMA DEVE
    produzir relatório com achados verificados (ou lista vazia comprovada) e
    correção dos confirmados
  - QUANDO a verificação estrutural padrão rodar O SISTEMA DEVE aprovar a
    skill (frontmatter, Lei de Ferro, red flags, ≤ 250 linhas, sem
    placeholder)
  - QUANDO as referências do plugin forem varridas O SISTEMA DEVE refletir a
    nova skill (hook, README, contagem de skills) sem menção órfã
- **fora-de-escopo**: profiling/performance; debug de infraestrutura externa
  ao repo; renumerar a spec histórica de v0.1.0 (nota de adendo basta).
- **decisoes**:
  - 2026-08-14 (humano): criar a skill e testá-la rodando no próprio projeto
    (instrução direta = portão de escopo aprovado).
  - 2026-08-14 (IA): nome `depurar`, dois modos (sintoma/caçada), posição de
    skill-ferramenta (como grafo), não fase do roteamento.
- **delta**:
- **e2e**: a caçada no próprio repo É o teste de ponta a ponta desta demanda
- **feedback-reprovacao**:
- **atualizado-em**: 2026-08-14

<!-- Regras de manutenção: ver templates/GRAFO-template.md (skill grafo). -->
