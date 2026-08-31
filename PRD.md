# PRD — audora-commander

> Última atualização: 2026-08-31

## O que é e para que serve

Plugin de Claude Code (padrão Superpowers) que implementa um framework de
desenvolvimento de software assistido por IA, guiado por 5 Princípios de AI
Coding: memória dinâmica do produto (MEMORY vivo, com o código indexado por
baixo pelo Graphify), planejamento just-in-time, separação "O Quê"/"Como",
processo proporcional ao risco da demanda, e IA executa / humano decide.
Público-alvo: dev solo ou time pequeno construindo web/mobile/api com Claude
Code.

## Stack

- Markdown (skills, templates, docs) + JSON (plugin.json, marketplace.json,
  hooks.json) + bash (hooks: `session-start`, `memory-guard`,
  `memory-validate`; script auxiliar `graphify-status`; sem jq —
  awk/sed/grep/perl do Git for Windows).
- Suíte de regressão do plugin em bash: `tests/run.sh` + `tests/test-*.sh`
  (fixtures em `mktemp -d`, `tests/lib.sh` com asserts e `run_hook`).
- Dependência externa opcional: [Graphify](https://github.com/safishamsi/graphify)
  (`graphifyy` no PyPI, Python 3.10+; índice de código local via tree-sitter,
  sem API key). Oferecido pela skill `memory`; ausência degrada para
  grep/Read com aviso.
- Formato de plugin do Claude Code: `.claude-plugin/` + `skills/` + `hooks/`.
  Versão 0.6.0.

## Arquitetura

9 skills encadeadas por um roteador central:

- `audora-commander` — porta de entrada: classifica demanda (LIGHT / MEDIUM /
  HIGH / HOTFIX) por perguntas binárias de risco e roteia pelas fases.
  Projeto sem `MEMORY.md` → oferece bootstrap (arquivo de memória de versão
  anterior recebe aviso de que não é mais lido).
- `memory` — dona do MEMORY (memória externa do produto, `memory-schema: 1`):
  `MEMORY.md` é índice mestre (Propósito, Constituição — inclui o bullet
  `graphify: ativo | recusado | sem-codigo` —, Aprendizados, linha rica por
  nó); corpo de cada nó em `docs/audora/memory/<id>.md` com frontmatter
  grep-ável e critérios EARS numerados `<id>/<n>`; decisões duráveis em
  `docs/audora/decisoes-vivas.md`; arquivamento por `git mv` para
  `docs/audora/arquivo/`. Operações: carregar-contexto, bootstrap (com a
  etapa Graphify: oferta de instalação, `graphify update .`, git hook
  post-commit, `graphify-out/` no gitignore), registrar-no, registrar-delta,
  registrar-aprendizado (1 linha `data | fase | aprendizado`, na hora, por
  qualquer fase), compactar, e consultar-codigo — protocolo único de consulta
  ao índice (`graphify query/path/affected`, ler só os `src=` apontados,
  degradação avisada em falha). A skill é um **roteador**:
  `carregar-contexto`, `registrar-delta` e `registrar-aprendizado` ficam inline
  no `SKILL.md` (143 linhas); `bootstrap`, `registrar-no`, `compactar` e
  `consultar-codigo` vivem em `skills/memory/references/`, lidas UMA por
  operação — reference ausente avisa e degrada, sem travar a fase.
- `scope` — fase "O Quê": critérios EARS, marcador [PRECISA-CLARIFICAR].
- `plan` — fase "Como" just-in-time: plano-arquivo com tarefas autossuficientes;
  localiza código via consultar-codigo quando `graphify: ativo`.
- `execute` — TDD red-green com evidência real; commit por etapa verde;
  consultar-codigo antes de tocar código vizinho da tarefa.
- `e2e` — levanta o projeto e exercita a demanda de ponta a ponta (opcional,
  fortemente recomendada).
- `validate` — portão humano final: evidência 1:1 com critérios, sync
  MEMORY → PRD no merge (consolida delta, decisões vivas e aprendizados,
  arquiva o nó por movimento).
- `debug` — debug com causa raiz demonstrada (modo sintoma; caminho que falha
  via consultar-codigo quando ativo) ou caçada de defeitos por classes com
  verificação de cada achado (modo caçada).

scope, e2e e validate não consultam o Graphify (não exploram código cru).

Hook SessionStart injeta ponteiro curto para a porta de entrada. Hooks
PostToolUse (Edit|Write) validam escritas no MEMORY: `memory-guard` (tetos
de ~300 linhas no índice e ~100 por nó) e `memory-validate` (seções
obrigatórias do índice, índice↔pasta, depende-de existente, ciclo, estado
dentro do enum EN) — erro volta ao modelo via exit 2; arquivo sem
`memory-schema: 1` na linha 1 é ignorado; sem bash, as skills seguem sendo a
fonte normativa. `hooks/graphify-status [dir]` classifica o índice de código
(`ausente | sem-indice | sem-codigo | ativo`) lendo `file_type` do
`graphify-out/graph.json`.

Documentos de referência: `docs/fundamentos.md` (fundamentos v2 dos princípios)
e `docs/specs/2026-08-14-audora-commander-design.md` (spec de design).

## Estado atual

Skill `worktree` entregue em 2026-08-27 (nó `skill-worktree`, MEDIUM, versão
0.5.0): nona skill, isolamento de demanda em git worktree sob pedido
explícito, fan-out de N agentes com domínios de arquivo não-sobrepostos, e
integração em série. Orquestra o worktree nativo do harness
(`EnterWorktree`/`ExitWorktree`) em vez de embarcar plumbing de git. Portão
humano obrigatório na remoção; as checagens de "pode apagar?" cobrem sujo,
não integrado, ignorado copiado no preparo e junction apontando para fora —
as duas últimas vieram de verificação empírica (`git worktree remove` apaga o
alvo através de junction e não é bloqueado por arquivo ignorado). Suíte em 295
asserts; e2e em `docs/audora/e2e/e2e-skill-worktree.md`.

v0.1.0 implementada (2026-08-14) — oito skills (sete originais + a skill de debug
em 2026-08-15), hook SessionStart, templates canônicos, marketplace local, README
com checklist, memória do produto do próprio repo (dogfooding). Verificações
estruturais e de JSON verdes.

Nó `skill-depurar` entregue em 2026-08-15: a skill de debug (hoje `debug`) foi testada com
uma caçada de defeitos real no próprio repositório
(`docs/audora/depuracao/cacada-2026-08-15.md`), que confirmou e corrigiu 6
divergências de documentação viva (contagem de skills desatualizada em
PRD/memória/spec, referências e placeholders inconsistentes entre skills e
templates), descartou 1 falso-positivo por verificação e aplicou 1 melhoria.
Aguardando validação de instalação pelo usuário em sessão interativa
(checklist no README).

Comandos em inglês entregues em 2026-08-25 (nó `comandos-ingles`, HIGH,
versão 0.3.0, breaking): skills renomeadas por `git mv` para `graph, scope,
plan, execute, e2e, validate, debug`; categorias de risco LIGHT / MEDIUM /
HIGH / HOTFIX; enum de estado dos nós `planned | in-progress | blocked |
delivered | discarded` (+ `hotfix-pending-record`), com migração TOTAL dos
estados de um projeto na primeira escrita pela skill `graph` (tabela PT→EN em
`templates/no-template.md`) e leitura tolerante até lá; o hook de validação
da memória passou a acusar estado fora do enum na coluna do índice, linha sem
coluna de estado, e a citar o caminho absoluto de `templates/` do plugin;
READMEs com seção "Renamed in 0.3.0" (comandos, categorias, estados); prosa do
framework segue em português (`docs/fundamentos.md` mantém os nomes antigos,
com aviso). Corrigido de quebra um bug pré-existente: `description` do
frontmatter sem aspas quebrava `claude plugin validate` (skill carregava com
metadata vazia). Duas rodadas adversariais (plano e diff, 57 agentes, 43
achados confirmados e integrados); e2e real com sessão `claude -p` listando
as oito skills EN e o ponteiro do hook; este repositório migrado (dogfood).
(Migração PT→EN e nomes da 0.3.0 foram substituídos pelo corte seco da 0.4.0.)

Memória do produto v2 entregue em 2026-08-25 (nó arquivado em
`docs/audora/arquivo/2026-08-25-*`, HIGH, versão 0.2.0): redesenho a partir
de estudo de mercado multi-agente (2026-08-24, em `docs/specs/`) — índice
mestre + 1 nó = 1 arquivo (Candidato C), travessia por grep no frontmatter,
critérios EARS numerados e citáveis (`<id>/<n>`) em
teste/commit/e2e/roteiro, decisões vivas promovidas no sync, arquivamento
por movimento, migração gradual com compat v1 permanente, e hooks de
validação com degradação graciosa. Este repositório foi o primeiro projeto
migrado (dogfooding). Revisão adversarial de 3 lentes encontrou 20 furos
antes do portão (wrapper cmd engolindo exit code, CRLF em Linux, contagem de
critérios), todos corrigidos e re-testados. Benchmark de tokens foi pulado
por decisão humana — corte de 65-70% é estimativa. (A compat v1 foi removida
na 0.4.0.)

Skill e2e evoluída em 2026-08-24 (nó `e2e-playwright-docker`): Playwright
como ferramenta default para projetos web (não-web pergunta ao usuário, com
escolha registrada na Constituição do projeto-alvo); docker compose como
infra default do teste (compose existente usado, ausente é gerado pela
stack via `templates/e2e-infra-template.md`, Docker indisponível cai para o
como-rodar com aviso); artefatos de e2e versionados no projeto-alvo como
regressão reaproveitável; falha de infra nunca segue parcial; teardown
sempre.

Documentação bilíngue entregue em 2026-08-24 (nó `docs-bilingues`): README.md
principal em inglês na raiz + README.pt-BR.md em português, com links
cruzados no topo. Comandos e blocos de código idênticos entre os dois;
exceção de idioma registrada na Constituição do MEMORY (README em inglês,
demais docs do repositório seguem em português).

Instalador adicionado em 2026-08-16: `install.sh` (bash) + `install.cmd`
(wrapper polyglot Windows, mesmo padrão de `hooks/run-hook.cmd`) automatizam
`claude plugin marketplace add` + `claude plugin install` via CLI
não-interativa, dispensando sessão interativa para o passo de instalação em
si. Testados de ponta a ponta neste repositório (idempotentes). README
reorganizado com seção "Para que serve", pré-requisitos e instalação
automática (recomendada) vs. manual.

## Metas futuras de implementação

1. v0.1.0: oito skills + hook + templates + marketplace local + README com
   checklist de validação (spec §6 + adendo).
2. Dry-run completo de uma demanda LIGHT e uma MEDIUM em projeto de exemplo.
3. Estender `memory-validate` para validar `estado:` também nos arquivos de
   `docs/audora/memory/` (hoje só a coluna do índice) — nó futuro.
4. Futuro (fora do v0.1.0): porte para outros harnesses, marketplace público,
   agentes dedicados.
