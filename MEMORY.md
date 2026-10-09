memory-schema: 1

# MEMORY — audora-commander

> Memória do produto: o que ele faz, regras inegociáveis, o que aprendemos e
> o estado de cada demanda. Requisito não escrito aqui é requisito que não
> existe. Este arquivo é o ÍNDICE MESTRE; o corpo de cada nó vive em
> `docs/audora/memory/<id>.md` (1 nó = 1 arquivo, ver
> templates/no-template.md).

## Propósito [carga: sempre]

Plugin de Claude Code que implementa um framework de desenvolvimento assistido
por IA com 5 princípios: MEMORY vivo, planejamento just-in-time, separação O-Quê/Como, processo
proporcional ao risco, e IA executa / humano decide. Público: dev solo ou
time pequeno em projetos web/mobile/api.

## Constituição [carga: sempre]

- **stack**: Markdown (skills, templates, docs) + JSON (manifests, hooks) +
  bash (hooks, suíte `tests/`).
- **restricoes**: cada SKILL.md e cada arquivo de `skills/*/references/`
  ≤ 250 linhas; conteúdo em português (exceções
  aprovadas: 2026-08-24 README.md principal em inglês, com README.pt-BR.md
  linkado; 2026-08-25 nomes de skills, categorias de risco e enum de estado
  em inglês — identificadores EN, prosa PT); schemas vivem só em
  `templates/`; hook injeta ponteiro curto, nunca o framework inteiro;
  Windows suportado via wrapper polyglot `.cmd`; código executável só em
  `hooks/` e `tests/` (suíte bash).
- **padroes**: toda skill tem frontmatter `name`+`description` ("Use
  quando..."), Lei de Ferro em bloco de código no topo, "Anuncie ao começar",
  fluxo numerado, tabela de red flags e seção "PRÓXIMA SKILL"; skill de FASE
  tem também `## Bloco de fechamento` apontando
  `templates/bloco-fechamento-template.md` (skill-ferramenta não tem).
- **como-rodar**: `bash tests/run.sh` (suíte do plugin, em paralelo; exit 1
  se algo falha; `SUITE_JOBS=1` = em série). Validação de instalação = `claude plugin uninstall
  audora-commander@audora-commander-dev && ./install.sh` seguido do
  checklist do README.md em sessão interativa.
- **ferramenta-e2e**: `claude -p` (projeto não-web, sem docker) — sessão
  real do Claude Code com o plugin instalado do cache.
- **gate**: `bash hooks/gate <id-da-demanda>` — suíte + anti-fraude de teste;
  lint/typecheck ausentes na stack, pulados com aviso.

## Aprendizados [carga: sempre]

Aprendizados vivem em `docs/audora/aprendizados.md` (1 linha cada, só por grep — skill memory, registrar-aprendizado).

## Índice de nós [carga: sempre]

- docs-permissoes | delivered | Docs de permissões → docs/audora/arquivo/2026-09-04-docs-permissoes.md
- gate-mecanico | delivered | Gate mecânico → docs/audora/arquivo/2026-09-04-gate-mecanico.md
- autopilot | delivered | Autopilot → docs/audora/arquivo/2026-09-05-autopilot.md
- loop-motor | delivered | Motor de loop → docs/audora/arquivo/2026-09-05-loop-motor.md
- limpeza-codigo-morto | delivered | Limpeza de código morto → docs/audora/arquivo/2026-09-27-limpeza-codigo-morto.md
- otimizacao-tokens | delivered | Otimização de tokens → docs/audora/arquivo/2026-09-28-otimizacao-tokens.md
- readme-skills | delivered | README por skill → docs/audora/arquivo/2026-09-28-readme-skills.md
- plugin-v0.1.0 | delivered | Plugin v0.1.0 → docs/audora/arquivo/2026-09-27-plugin-v0.1.0.md
- resumo-de-fase | delivered | Resumo de fase → docs/audora/arquivo/2026-08-31-resumo-de-fase.md
- memory-fatiada | delivered | Memory fatiada → docs/audora/arquivo/2026-08-31-memory-fatiada.md
- skill-worktree | delivered | Skill worktree → docs/audora/arquivo/2026-08-27-skill-worktree.md
- comandos-ingles | delivered | Comandos em inglês → docs/audora/arquivo/2026-08-25-comandos-ingles.md
- grafo-v2 | delivered | GRAFO v2 → docs/audora/arquivo/2026-08-25-grafo-v2.md
- validate-estado-no | delivered | Estado validado no nó → docs/audora/arquivo/2026-09-28-validate-estado-no.md
- contexto-por-fase | delivered | Contexto zerado por fase → docs/audora/arquivo/2026-09-29-contexto-por-fase.md
- corte-sem-uso | delivered | Corte do sem uso → docs/audora/arquivo/2026-09-30-corte-sem-uso.md
- plano-mapa | delivered | Plano-mapa + localização → docs/audora/arquivo/2026-10-01-plano-mapa.md
- prd-foto | delivered | PRD-foto → docs/audora/arquivo/2026-10-01-prd-foto.md
- parada-revisao | delivered | Parada da revisão → docs/audora/arquivo/2026-10-01-parada-revisao.md
- leitura-por-secao | delivered | Leitura por seção → docs/audora/arquivo/2026-10-02-leitura-por-secao.md
- skill-cleanup | delivered | Skill de limpeza → docs/audora/arquivo/2026-10-02-skill-cleanup.md
- cleanup-alvo-ausente | delivered | Alvo ausente só se existiu → docs/audora/arquivo/2026-10-03-cleanup-alvo-ausente.md
- cleanup-lote-encadeado | delivered | Lote encadeado da cleanup → docs/audora/arquivo/2026-10-03-cleanup-lote-encadeado.md
- cleanup-link-preciso | delivered | Link preciso da cleanup → docs/audora/arquivo/2026-10-03-cleanup-link-preciso.md
- suite-paralela | delivered | Suíte em paralelo → docs/audora/arquivo/2026-10-05-suite-paralela.md
- cleanup-commit-curto | delivered | Commit curto da cleanup → docs/audora/arquivo/2026-10-07-cleanup-commit-curto.md
- memoria-integra | delivered | Memória íntegra → docs/audora/arquivo/2026-10-09-memoria-integra.md
- caminhos-sem-saida | planned | Caminhos sem saída | HOTFIX com regra única de registro; debug avulso passa pela porta; rota para pedido sem mudança; e2e volta após fix; retomada do sync pós-merge | roteamento, hotfix, debug, e2e, sync, porta | skills/audora-commander/SKILL.md, skills/debug/SKILL.md, skills/e2e/SKILL.md, skills/validate/
- contratos-de-texto | planned | Contratos de texto | Seção "Decisões tomadas pela IA" no template e destino em LIGHT; localização da execute sem mapa; PARADA clara no plan; cosméticos de numeração e skill-ferramenta | template, plano, execute, plan, decisoes | templates/plano-template.md, skills/execute/SKILL.md, skills/plan/SKILL.md, skills/memory/SKILL.md, templates/bloco-fechamento-template.md
- faxina-restos | delivered | Faxina do sem uso → docs/audora/arquivo/2026-10-08-faxina-restos.md
- memory-inicio-fim | planned | Memória no início e fim | Memória escrita/atualizada no início e no fim de toda demanda | memory, ciclo, enforcement | skills/
- scope-batch | delivered | Scope em lote → docs/audora/arquivo/2026-09-01-scope-batch.md
- sync-mecanizado | delivered | Sync mecanizado → docs/audora/arquivo/2026-09-04-sync-mecanizado.md
- light-enxuto | delivered | LIGHT enxuto → docs/audora/arquivo/2026-09-01-light-enxuto.md
- decisoes-vivas-poda | delivered | Poda das decisões vivas → docs/audora/arquivo/2026-09-01-decisoes-vivas-poda.md
- decisoes-vivas-auditoria | discarded | Auditoria das decisões vivas → docs/audora/arquivo/2026-09-28-decisoes-vivas-auditoria.md (descartado pelo humano em 2026-09-28, antes do scope)
- skill-memory | discarded | Skill MEMORY | Absorvido pela skill memory em 2026-08-26 (memory = memória do produto + aprendizados) | memoria, aprendizado, skill | —
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
