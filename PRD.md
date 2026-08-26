# PRD — audora-commander

> Última atualização: 2026-08-25

## O que é e para que serve

Plugin de Claude Code (padrão Superpowers) que implementa um framework de
desenvolvimento de software assistido por IA, guiado por 5 Princípios de AI
Coding: mapa dinâmico de requisitos (GRAFO vivo), planejamento just-in-time,
separação "O Quê"/"Como", processo proporcional ao risco da demanda, e IA
executa / humano decide. Público-alvo: dev solo ou time pequeno construindo
web/mobile/api com Claude Code.

## Stack

- Markdown (skills, templates, docs) + JSON (plugin.json, marketplace.json,
  hooks.json) + bash (hooks: `session-start`, `grafo-guard`,
  `grafo-validate`; sem jq — awk/sed/grep/perl do Git for Windows).
- Formato de plugin do Claude Code: `.claude-plugin/` + `skills/` + `hooks/`.
  Versão 0.3.0.

## Arquitetura

8 skills encadeadas por um roteador central:

- `audora-commander` — porta de entrada: classifica demanda (LIGHT / MEDIUM /
  HIGH / HOTFIX) por perguntas binárias de risco e roteia pelas fases.
- `graph` — mantém o GRAFO (memória externa do produto) no schema v2:
  `GRAFO.md` é índice mestre (Propósito, Constituição, linha rica por nó);
  corpo de cada nó em `docs/audora/nos/<id>.md` com frontmatter grep-ável;
  decisões duráveis em `docs/audora/decisoes-vivas.md`; arquivamento por
  `git mv` para `docs/audora/arquivo/`. Schema v1 (arquivo único) segue
  suportado como caso degenerado, com migração on-touch.
- `scope` — fase "O Quê": critérios EARS, marcador [PRECISA-CLARIFICAR].
- `plan` — fase "Como" just-in-time: plano-arquivo com tarefas autossuficientes.
- `execute` — TDD red-green com evidência real; commit por etapa verde.
- `e2e` — levanta o projeto e exercita a demanda de ponta a ponta (opcional,
  fortemente recomendada).
- `validate` — portão humano final: evidência 1:1 com critérios, sync
  GRAFO → PRD no merge.
- `debug` — debug com causa raiz demonstrada (modo sintoma) ou caçada de
  defeitos por classes com verificação de cada achado (modo caçada).

Hook SessionStart injeta ponteiro curto para a porta de entrada. Hooks
PostToolUse (Edit|Write) validam escritas no GRAFO v2: `grafo-guard` (tetos
de ~300 linhas no índice e ~100 por nó) e `grafo-validate` (índice↔pasta,
depende-de existente, ciclo, estado do índice dentro do enum EN — estado em
português = migração PT→EN pendente) — erro volta ao modelo via exit 2; sem
bash, as skills seguem sendo a fonte normativa.

Documentos de referência: `docs/fundamentos.md` (fundamentos v2 dos princípios)
e `docs/specs/2026-08-14-audora-commander-design.md` (spec de design).

## Estado atual

v0.1.0 implementada (2026-08-14) — 8 skills (7 originais + a skill de debug
em 2026-08-15), hook SessionStart, templates canônicos, marketplace local, README
com checklist, GRAFO.md do próprio repo (dogfooding). Verificações estruturais
e de JSON verdes.

Nó `skill-depurar` entregue em 2026-08-15: a skill de debug (hoje `debug`) foi testada com
uma caçada de defeitos real no próprio repositório
(`docs/audora/depuracao/cacada-2026-08-15.md`), que confirmou e corrigiu 6
divergências de documentação viva (contagem de skills desatualizada em
PRD/GRAFO/spec, referências e placeholders inconsistentes entre skills e
templates), descartou 1 falso-positivo por verificação e aplicou 1 melhoria.
Aguardando validação de instalação pelo usuário em sessão interativa
(checklist no README).

Comandos em inglês entregues em 2026-08-25 (nó `comandos-ingles`, HIGH,
versão 0.3.0, breaking): skills renomeadas por `git mv` para `graph, scope,
plan, execute, e2e, validate, debug`; categorias de risco LIGHT / MEDIUM /
HIGH / HOTFIX; enum de estado dos nós `planned | in-progress | blocked |
delivered | discarded` (+ `hotfix-pending-record`), com migração TOTAL dos
estados de um projeto na primeira escrita pela skill `graph` (tabela PT→EN em
`templates/no-template.md`) e leitura tolerante até lá; hook `grafo-validate`
acusa estado fora do enum na coluna do índice, linha sem coluna de estado, e
cita o caminho absoluto de `templates/` do plugin; READMEs com seção
"Renamed in 0.3.0" (comandos, categorias, estados); prosa do framework segue
em português (`docs/fundamentos.md` mantém os nomes antigos, com aviso).
Corrigido de quebra um bug pré-existente: `description` do frontmatter sem
aspas quebrava `claude plugin validate` (skill carregava com metadata vazia).
Duas rodadas adversariais (plano e diff, 57 agentes, 43 achados confirmados
e integrados); e2e real com sessão `claude -p` listando as 8 skills EN e o
ponteiro do hook; este repositório migrado (dogfood).

GRAFO v2 entregue em 2026-08-25 (nó `grafo-v2`, HIGH, versão 0.2.0):
redesenho da memória do produto a partir de estudo de mercado multi-agente
(`docs/specs/2026-08-24-estudo-grafo-mercado.md`) — índice mestre + 1 nó =
1 arquivo (Candidato C), travessia por grep no frontmatter, critérios EARS
numerados e citáveis (`<id>/<n>`) em teste/commit/e2e/roteiro, decisões
vivas promovidas no sync, arquivamento por movimento, migração gradual com
compat v1 permanente, e hooks de validação com degradação graciosa. Este
repositório foi o primeiro projeto migrado (dogfooding). Revisão adversarial
de 3 lentes encontrou 20 furos antes do portão (wrapper cmd engolindo exit
code, CRLF em Linux, contagem de critérios), todos corrigidos e re-testados.
Benchmark de tokens foi pulado por decisão humana — corte de 65-70% é
estimativa.

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
exceção de idioma registrada na constituição do GRAFO (README em inglês,
demais docs do repositório seguem em português).

Instalador adicionado em 2026-08-16: `install.sh` (bash) + `install.cmd`
(wrapper polyglot Windows, mesmo padrão de `hooks/run-hook.cmd`) automatizam
`claude plugin marketplace add` + `claude plugin install` via CLI
não-interativa, dispensando sessão interativa para o passo de instalação em
si. Testados de ponta a ponta neste repositório (idempotentes). README
reorganizado com seção "Para que serve", pré-requisitos e instalação
automática (recomendada) vs. manual.

## Metas futuras de implementação

1. v0.1.0: 8 skills + hook + templates + marketplace local + README com
   checklist de validação (spec §6 + adendo).
2. Dry-run completo de uma demanda LIGHT e uma MEDIUM em projeto de exemplo.
4. Estender `grafo-validate` para validar `estado:` também nos arquivos de
   `docs/audora/nos/` (hoje só a coluna do índice) — nó futuro.
3. Futuro (fora do v0.1.0): porte para outros harnesses, marketplace público,
   agentes dedicados.
