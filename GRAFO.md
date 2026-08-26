versao-schema: 2

# GRAFO — audora-commander

> Memória externa do produto. Requisito não escrito aqui é requisito que não
> existe. Schema v2: este arquivo é o ÍNDICE MESTRE; o corpo de cada nó vive
> em `docs/audora/nos/<id>.md`.

## Propósito [carga: sempre]

Plugin de Claude Code que implementa um framework de desenvolvimento assistido
por IA com 5 princípios: GRAFO vivo, planejamento just-in-time, separação
O-Quê/Como, processo proporcional ao risco, e IA executa / humano decide.
Público: dev solo ou time pequeno em projetos web/mobile/api.

## Constituição [carga: sempre]

- **stack**: Markdown (skills, templates, docs) + JSON (manifests, hook) +
  bash (scripts de hook). Sem código executável além dos hooks.
- **restricoes**: cada SKILL.md ≤ 250 linhas; conteúdo em português (exceções
  aprovadas: 2026-08-24 README.md principal em inglês, com README.pt-BR.md
  linkado; 2026-08-25 nomes de skills, categorias de risco e enum de estado
  em inglês — identificadores EN, prosa PT); schemas vivem só em
  `templates/`; hook injeta ponteiro curto, nunca o framework inteiro;
  Windows suportado via wrapper polyglot `.cmd`.
- **padroes**: toda skill tem frontmatter `name`+`description` ("Use
  quando..."), Lei de Ferro em bloco de código no topo, "Anuncie ao começar",
  fluxo numerado, tabela de red flags e seção "PRÓXIMA SKILL".
- **como-rodar**: plugin não "roda" — validação é instalação real em sessão
  interativa do Claude Code (`/plugin marketplace add <pasta deste repo>` +
  `/plugin install audora-commander@audora-commander-dev`) seguida do
  checklist do README.md.

## Índice de nós [carga: sempre]

- plugin-v0.1.0 | in-progress | Plugin v0.1.0 | Plugin instalável com 8 skills, hook SessionStart, templates e marketplace local | plugin, skills, marketplace, hook, instalacao | skills/, hooks/, templates/
- memory-graphify | in-progress | Memory + Graphify | GRAFO vira MEMORY (memorys.md) e Graphify indexa o código por baixo dos panos para consulta barata nas fases | memory, graphify, grafo, consulta, tokens, breaking | skills/, hooks/, templates/
- comandos-ingles | delivered | Comandos em inglês → docs/audora/arquivo/2026-08-25-comandos-ingles.md
- grafo-v2 | delivered | GRAFO v2 → docs/audora/arquivo/2026-08-25-grafo-v2.md
- grafo-inicio-fim | planned | GRAFO no início e fim | GRAFO escrito/atualizado no início e no fim de toda demanda | grafo, ciclo, enforcement | skills/
- skill-memory | planned | Skill MEMORY | Memória inteligente da audora por projeto (preferências e aprendizados, distinta do GRAFO) | memoria, aprendizado, skill | skills/
- skill-poc | planned | Skill POC | ≥3 POCs por demanda exploratória, usuário escolhe 1 para desenvolver | poc, estudo, prototipo | skills/
- porte-multi-harness | planned | Porte multi-harness | Porte para outros harnesses (Codex, Cursor) | porte, harness | —
- marketplace-publico | planned | Marketplace público | Publicação em marketplace público | marketplace, publicacao | —
- agentes-dedicados | planned | Agentes dedicados | Subagent types customizados por fase | agentes, subagent | —
- docs-bilingues | delivered | README bilíngue → ver docs/audora/GRAFO-ARQUIVO.md
- e2e-playwright-docker | delivered | e2e Playwright + compose → ver docs/audora/GRAFO-ARQUIVO.md
- skill-depurar | delivered | Skill de debug → ver docs/audora/GRAFO-ARQUIVO.md

<!-- Regras de manutenção: ver templates/GRAFO-template.md (skill graph).
     Nós entregues acima de 2026-08-24 vivem no legado GRAFO-ARQUIVO.md;
     entregas novas vão para docs/audora/arquivo/AAAA-MM-DD-<id>.md. -->
