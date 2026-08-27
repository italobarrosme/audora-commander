memory-schema: 1

# MEMORY — audora-commander

> Memória do produto: o que ele faz, regras inegociáveis, o que aprendemos e
> o estado de cada demanda. Requisito não escrito aqui é requisito que não
> existe. Este arquivo é o ÍNDICE MESTRE; o corpo de cada nó vive em
> `docs/audora/memory/<id>.md` (1 nó = 1 arquivo, ver
> templates/no-template.md). O CÓDIGO não vive aqui: é indexado pelo
> Graphify em `graphify-out/` (fora do git) e consultado pela skill memory.

## Propósito [carga: sempre]

Plugin de Claude Code que implementa um framework de desenvolvimento assistido
por IA com 5 princípios: MEMORY vivo (com o código indexado por baixo pelo
Graphify), planejamento just-in-time, separação O-Quê/Como, processo
proporcional ao risco, e IA executa / humano decide. Público: dev solo ou
time pequeno em projetos web/mobile/api.

## Constituição [carga: sempre]

- **stack**: Markdown (skills, templates, docs) + JSON (manifests, hooks) +
  bash (hooks, script `graphify-status`, suíte `tests/`).
- **restricoes**: cada SKILL.md ≤ 250 linhas; conteúdo em português (exceções
  aprovadas: 2026-08-24 README.md principal em inglês, com README.pt-BR.md
  linkado; 2026-08-25 nomes de skills, categorias de risco e enum de estado
  em inglês — identificadores EN, prosa PT); schemas vivem só em
  `templates/`; hook injeta ponteiro curto, nunca o framework inteiro;
  Windows suportado via wrapper polyglot `.cmd`; código executável só em
  `hooks/` (hooks + `graphify-status`) e `tests/` (suíte bash).
- **padroes**: toda skill tem frontmatter `name`+`description` ("Use
  quando..."), Lei de Ferro em bloco de código no topo, "Anuncie ao começar",
  fluxo numerado, tabela de red flags e seção "PRÓXIMA SKILL".
- **como-rodar**: `bash tests/run.sh` (suíte do plugin; exit 1 se algo
  falha). Validação de instalação = `claude plugin uninstall
  audora-commander@audora-commander-dev && ./install.sh` seguido do
  checklist do README.md em sessão interativa.
- **graphify**: ativo

## Aprendizados [carga: sempre]

- 2026-08-25 | validate | `claude plugin update` só refaz o cache com bump de versão — sem bump: uninstall + `./install.sh`; hooks que rodam na sessão são os do cache, não os do repo.
- 2026-08-25 | execute | Fixtures de hook em `mktemp -d` (path POSIX) e JSON com backslash escapado — path `C:\...` sem escape faz o hook sair 0 em silêncio (falso verde).
- 2026-08-26 | execute | Heredoc grande (>~90 linhas, aspas mistas) no Bash tool do Claude Code falha no parse ("unexpected EOF") — gravar o script no scratchpad via Write e executar por caminho.
- 2026-08-26 | execute | `graphify hook install` grava `_PINNED=''` quando o caminho do Python tem espaço (allowlist do Graphify; usuário "Italo Barros") e o post-commit falha em silêncio ("could not locate a Python") — pinar à mão em `.git/hooks/post-commit` e `post-checkout`, e sempre rodar o hook uma vez (`GIT_DIR=.git bash .git/hooks/post-commit`) para conferir.

## Índice de nós [carga: sempre]

- plugin-v0.1.0 | in-progress | Plugin v0.1.0 | Plugin instalável com 8 skills, hook SessionStart, templates e marketplace local | plugin, skills, marketplace, hook, instalacao | skills/, hooks/, templates/
- memory-graphify | in-progress | Memory + Graphify | GRAFO vira MEMORY (memorys.md) e Graphify indexa o código por baixo dos panos para consulta barata nas fases | memory, graphify, grafo, consulta, tokens, breaking | skills/, hooks/, templates/
- comandos-ingles | delivered | Comandos em inglês → docs/audora/arquivo/2026-08-25-comandos-ingles.md
- grafo-v2 | delivered | GRAFO v2 → docs/audora/arquivo/2026-08-25-grafo-v2.md
- grafo-inicio-fim | planned | GRAFO no início e fim | Memória escrita/atualizada no início e no fim de toda demanda | memory, ciclo, enforcement | skills/
- skill-memory | discarded | Skill MEMORY | Absorvido por memory-graphify em 2026-08-26 (memory = memória do produto + aprendizados) | memoria, aprendizado, skill | —
- skill-poc | planned | Skill POC | ≥3 POCs por demanda exploratória, usuário escolhe 1 para desenvolver | poc, estudo, prototipo | skills/
- porte-multi-harness | planned | Porte multi-harness | Porte para outros harnesses (Codex, Cursor) | porte, harness | —
- marketplace-publico | planned | Marketplace público | Publicação em marketplace público | marketplace, publicacao | —
- agentes-dedicados | planned | Agentes dedicados | Subagent types customizados por fase | agentes, subagent | —
- docs-bilingues | delivered | README bilíngue → docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md
- e2e-playwright-docker | delivered | e2e Playwright + compose → docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md
- skill-depurar | delivered | Skill de debug → docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md

<!-- Regras de manutenção: ver templates/MEMORY-template.md (skill memory).
     Nós entregues até 2026-08-24 vivem no legado
     docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md (conteúdo
     intocado); entregas novas vão para docs/audora/arquivo/AAAA-MM-DD-<id>.md. -->
