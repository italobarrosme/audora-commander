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

- plugin-v0.1.0 | em-curso | Plugin v0.1.0 | Plugin instalável com 8 skills, hook SessionStart, templates e marketplace local | plugin, skills, marketplace, hook | skills/, hooks/, templates/
- comandos-ingles | em-curso | Comandos em inglês | Nomes das skills (comandos) e categorias de risco (LEVE/MÉDIA/ALTA/HOTFIX) passam a ser em inglês | ingles, i18n, rename, skills, categorias, contrato | —
- grafo-v2 | entregue | GRAFO v2 → docs/audora/arquivo/2026-08-25-grafo-v2.md
- grafo-inicio-fim | planejada | GRAFO no início e fim | GRAFO escrito/atualizado no início e no fim de toda demanda | grafo, ciclo, enforcement | skills/
- skill-memory | planejada | Skill MEMORY | Memória inteligente da audora por projeto (preferências e aprendizados, distinta do GRAFO) | memoria, aprendizado, skill | skills/
- skill-poc | planejada | Skill POC | ≥3 POCs por demanda exploratória, usuário escolhe 1 para desenvolver | poc, estudo, prototipo | skills/
- porte-multi-harness | planejada | Porte multi-harness | Porte para outros harnesses (Codex, Cursor) | porte, harness | —
- marketplace-publico | planejada | Marketplace público | Publicação em marketplace público | marketplace, publicacao | —
- agentes-dedicados | planejada | Agentes dedicados | Subagent types customizados por fase | agentes, subagent | —
- docs-bilingues | entregue | README bilíngue → ver docs/audora/GRAFO-ARQUIVO.md
- e2e-playwright-docker | entregue | e2e Playwright + compose → ver docs/audora/GRAFO-ARQUIVO.md
- skill-depurar | entregue | Skill de debug → ver docs/audora/GRAFO-ARQUIVO.md

<!-- Regras de manutenção: ver templates/GRAFO-template.md (skill grafo).
     Nós entregues acima de 2026-08-24 vivem no legado GRAFO-ARQUIVO.md;
     entregas novas vão para docs/audora/arquivo/AAAA-MM-DD-<id>.md. -->
