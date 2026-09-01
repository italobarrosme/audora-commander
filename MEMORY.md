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
- **restricoes**: cada SKILL.md e cada arquivo de `skills/*/references/`
  ≤ 250 linhas; conteúdo em português (exceções
  aprovadas: 2026-08-24 README.md principal em inglês, com README.pt-BR.md
  linkado; 2026-08-25 nomes de skills, categorias de risco e enum de estado
  em inglês — identificadores EN, prosa PT); schemas vivem só em
  `templates/`; hook injeta ponteiro curto, nunca o framework inteiro;
  Windows suportado via wrapper polyglot `.cmd`; código executável só em
  `hooks/` (hooks + `graphify-status`) e `tests/` (suíte bash).
- **padroes**: toda skill tem frontmatter `name`+`description` ("Use
  quando..."), Lei de Ferro em bloco de código no topo, "Anuncie ao começar",
  fluxo numerado, tabela de red flags e seção "PRÓXIMA SKILL"; skill de FASE
  tem também `## Bloco de fechamento` apontando
  `templates/bloco-fechamento-template.md` (skill-ferramenta não tem).
- **como-rodar**: `bash tests/run.sh` (suíte do plugin; exit 1 se algo
  falha). Validação de instalação = `claude plugin uninstall
  audora-commander@audora-commander-dev && ./install.sh` seguido do
  checklist do README.md em sessão interativa.
- **ferramenta-e2e**: `claude -p` (projeto não-web, sem docker) — sessão
  real do Claude Code com o plugin instalado do cache.
- **graphify**: ativo

## Aprendizados [carga: sempre]

- 2026-08-25 | validate | `claude plugin update` só refaz o cache com bump de versão — sem bump: uninstall + `./install.sh`; hooks que rodam na sessão são os do cache, não os do repo.
- 2026-08-25 | execute | Fixtures de hook em `mktemp -d` (path POSIX) e JSON com backslash escapado — path `C:\...` sem escape faz o hook sair 0 em silêncio (falso verde).
- 2026-08-26 | execute | Heredoc grande (>~90 linhas, aspas mistas) no Bash tool do Claude Code falha no parse ("unexpected EOF") — gravar o script no scratchpad via Write e executar por caminho.
- 2026-08-26 | execute | `graphify hook install` grava `_PINNED=''` quando o caminho do Python tem espaço (allowlist do Graphify; usuário "Italo Barros") e o post-commit falha em silêncio ("could not locate a Python") — pinar à mão em `.git/hooks/post-commit` e `post-checkout`, e sempre rodar o hook uma vez (`GIT_DIR=.git bash .git/hooks/post-commit`) para conferir.
- 2026-08-27 | plan | Claude Code 2.1.247 tem worktree nativo (`-w/--worktree`, ferramentas `EnterWorktree`/`ExitWorktree`, worktree sob `.claude/worktrees/`, `.worktreeinclude` para arquivos ignorados) — skill do framework orquestra o nativo, nunca reimplementa plumbing de git (a Constituição já restringe executável a `hooks/` e `tests/`).
- 2026-08-27 | execute | Adicionar skill nova toca 8 pontos além de `skills/<nome>/SKILL.md`: `tests/test-no-grafo.sh` (contagem cravada), `tests/test-skills.sh` (loop), `tests/test-docs.sh` (versão), READMEs EN+PT (tabela e checklist), `PRD.md`, os 2 manifests e `hooks/session-start` — mais o delta de contagem no nó `plugin-v0.1.0`.
- 2026-08-27 | execute | Teste de conteúdo de skill usa `assert_contains` (grep -F): string que quebra de linha no Markdown NUNCA casa. Comando citado num SKILL.md que algum teste afirma deve caber em UMA linha — e o teste falhando assim é sinal de quebra, não de ausência.
- 2026-08-30 | validate | Arquivar nó que tem `<id>-historico.md`: `git mv` dos DOIS arquivos para `docs/audora/arquivo/` (mesmo prefixo de data) e corrigir o ponteiro relativo no corpo — mover só o nó quebra o link.
- 2026-08-31 | execute | `bash tests/run.sh 2>&1 | tail -N; echo $?` reporta o exit do **tail**, sempre 0 — falso verde na leitura da evidência. Rodar `run.sh > /dev/null 2>&1; echo $?` (ou `${PIPESTATUS[0]}`) para o código real.
- 2026-08-31 | validate | `assert_contains`/`grep -qF` é sensível a CAIXA e trata string iniciada por `-` como opção — "Reference ausente" não casa com 'reference ausente', e `grep -lF '--budget'` precisa do separador `--`. Vale para o teste E para o comando de evidência.
- 2026-08-31 | e2e | `claude -p` passa de 120s e o Bash tool joga para background — comando que restaura arquivo no fim deixa o repo quebrado nesse meio-tempo. Script com `trap restore EXIT INT TERM` ANTES do `mv`.
- 2026-08-31 | e2e | Capturar `claude -p` com `| tail -N` corta a evidência e leva a veredito parcial — redirecionar para arquivo e ler inteiro.
- 2026-08-31 | execute | Teste negativo que suja arquivo ainda NÃO commitado: `git checkout <arquivo>` restaura do ÍNDICE e apaga o trabalho em andamento. Commitar o green ANTES de provar que o guarda morde, ou copiar para o scratchpad e restaurar de lá.
- 2026-08-31 | validate | Total de asserts da suíte precisa ser SOMADO da saída real (`grep PASS= | awk`) — `run.sh` só imprime por arquivo, e citar o total de cabeça inflou o número em 30 no commit e no PRD. Comparar bases com `git archive` também subconta 3: `test-dogfood.sh` depende do repo git.
- 2026-08-31 | validate | O post-commit do Graphify dispara UMA reconstrução em background por commit; demanda com muitos commits empilha processos Python e a suíte parece TRAVAR (>5 min contra ~30s normais). Antes de debugar teste que "pendurou", rodar os arquivos isolados: se cada um passa, a causa é contenção, não o teste.
- 2026-09-01 | validate | `grep -c` sai **1** quando o count é 0, então encadear com `&&` quebra o comando exatamente quando a verificação de ausência PASSA — o resto não roda e você lê log velho achando que a suíte reprovou. Em bloco de evidência, separar com `;` ou nova linha, nunca `&&`.

## Índice de nós [carga: sempre]

- plugin-v0.1.0 | in-progress | Plugin v0.1.0 | Plugin instalável com 8 skills, hook SessionStart, templates e marketplace local | plugin, skills, marketplace, hook, instalacao | skills/, hooks/, templates/
- memory-graphify | in-progress | Memory + Graphify | GRAFO vira MEMORY (memorys.md) e Graphify indexa o código por baixo dos panos para consulta barata nas fases | memory, graphify, grafo, consulta, tokens, breaking | skills/, hooks/, templates/
- resumo-de-fase | delivered | Resumo de fase → docs/audora/arquivo/2026-08-31-resumo-de-fase.md
- memory-fatiada | delivered | Memory fatiada → docs/audora/arquivo/2026-08-31-memory-fatiada.md
- skill-worktree | delivered | Skill worktree → docs/audora/arquivo/2026-08-27-skill-worktree.md
- comandos-ingles | delivered | Comandos em inglês → docs/audora/arquivo/2026-08-25-comandos-ingles.md
- grafo-v2 | delivered | GRAFO v2 → docs/audora/arquivo/2026-08-25-grafo-v2.md
- grafo-inicio-fim | planned | GRAFO no início e fim | Memória escrita/atualizada no início e no fim de toda demanda | memory, ciclo, enforcement | skills/
- scope-batch | delivered | Scope em lote → docs/audora/arquivo/2026-09-01-scope-batch.md
- sync-mecanizado | planned | Sync mecanizado | Os 5 passos mecânicos do sync da validate viram hooks/memory-sync; modelo fica só com os 3 de julgamento | validate, sync, hooks, bookkeeping | skills/validate/, hooks/
- light-enxuto | planned | LIGHT enxuto | Demanda LIGHT deixa de pagar o fechamento completo de MEDIUM — evidência e portão sim, sync de 8 operações não | light, cerimonia, validate, roteamento | skills/audora-commander/, skills/validate/
- decisoes-vivas-poda | planned | Poda das decisões vivas | Regra de entrada nova (só entra decisão que NÃO dá pra impor por teste/hook/config) + poda das ~8 já impostas ou mortas, com invalidado-em apontando para o teste que virou a verdade | decisoes-vivas, poda, duplicacao, drift | docs/audora/decisoes-vivas.md, templates/
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
