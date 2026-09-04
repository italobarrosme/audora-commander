# PRD — audora-commander

> Última atualização: 2026-09-04

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
  `memory-validate`; scripts auxiliares `graphify-status` e `gate`; sem jq —
  awk/sed/grep/perl do Git for Windows).
- Suíte de regressão do plugin em bash: `tests/run.sh` + `tests/test-*.sh`
  (fixtures em `mktemp -d`, `tests/lib.sh` com asserts e `run_hook`).
- Dependência externa opcional: [Graphify](https://github.com/safishamsi/graphify)
  (`graphifyy` no PyPI, Python 3.10+; índice de código local via tree-sitter,
  sem API key). Oferecido pela skill `memory`; ausência degrada para
  grep/Read com aviso.
- Formato de plugin do Claude Code: `.claude-plugin/` + `skills/` + `hooks/`.
  Versão 0.7.0.

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

Gate mecânico entregue em 2026-09-04 (nó `gate-mecanico`, MEDIUM, D1 do
roadmap de loop engineering em `docs/specs/2026-09-02-loop-engineering-roadmap.md`):
um comando por projeto que responde passou/não passou — suíte, lint e
typecheck (etapa sem ferramenta na stack é pulada com aviso, nunca falha) mais
**anti-fraude de teste** sobre o diff não commitado (`git diff HEAD`): arquivo
de teste apagado reprova nomeando o arquivo; skip/only adicionado reprova com
arquivo e linha; queda na contagem de asserts reprova com antes → depois,
salvo justificativa `gate-asserts: <motivo>` no nó da demanda. O schema vive
em `templates/gate-template.md` (config `GATE_*` com env sobrepondo defaults —
é o que permite testar o gate na própria suíte sem recursão); a instância
dogfood deste repo é `hooks/gate`, registrada na Constituição
(`gate: bash hooks/gate <id-da-demanda>`). A skill `memory` oferta o gate no
bootstrap (etapa 5) e no início de demanda em projeto sem `gate:` — uma vez,
recusa registrada gruda; a `execute` passa a tratar GREEN como gate verde
quando o bullet existe; a `validate` lista o diff dos arquivos de teste
separado do resto em toda categoria. Suíte 415 → 467 asserts, com fixture de
repo git real exercitando as três fraudes red-green; e2e com sessão
`claude -p` real provou a oferta no carregar-contexto e o controle negativo
(Graphify recusado não reofertado) — relatório em
`docs/audora/e2e/e2e-gate-mecanico.md`.

Mecanização do sync da validate: **tentada e abandonada** em 2026-09-04 (nó
`sync-mecanizado`, HIGH). O que ficou é conhecimento documentado, não código.

A ideia era tirar da mão do modelo os passos mecânicos do sync. Quatro
revisões adversariais reprovaram — uma no plano, antes de virar código, e três
no diff. A taxa de mutação não se moveu: 55% → 45% → 44% das mutações
passando verdes, e cada correção abria buraco novo, inclusive uma regressão
(o corte de título que matava a seta dupla mutilava título legítimo). Os últimos
bugs vivos foram colisão de sufixo no glob — o id `batch` casava o nó de
`scope-batch` e o script apontava a demanda errada — e nó renomeado perdendo
trabalho em silêncio. Diagnóstico: o script fazia cirurgia de string num
formato Markdown desenhado para humano e LLM, e toda a cirurgia vivia na parte
de menor valor.

O que sobrou, no item 6.3 da skill `validate`, são os dois comandos e as três
armadilhas que as revisões acharam: a base da demanda é o **pai do commit que
criou o arquivo do nó** (nunca `--grep` na mensagem, que casa commit de outra
demanda que só cita o id); o range vai até HEAD e pode conter outra demanda; o
`PRD.md` ainda não foi tocado quando o comando roda; e o nó e o `-historico.md`
aparecem no caminho de antes do `git mv`. O item 6 também foi reescrito numa
ordem só — antes tinha duas, e seguir a antiga fazia `memory-validate` bloquear
a escrita seguinte. Suíte 395 asserts.

Regra de entrada e guardas das decisões vivas entregues em 2026-09-01 (nó
`decisoes-vivas-poda`, HIGH). A skill `validate` passa a filtrar o que entra em
`docs/audora/decisoes-vivas.md`: só é candidata a decisão que NÃO esteja já
declarada normativamente, **para o mesmo escopo de aplicação**, em artefato que
o framework lê — e regra que vale para skills futuras não é duplicata de um
SKILL.md que só a aplica a si mesmo. Se a decisão PODERIA virar teste e o teste
não existe, a skill manda escrever o teste na mesma demanda ou manter a
entrada; sumir em silêncio virou proibido. Artefato que trata a matéria como
fora do próprio escopo não serve de ponteiro. A suíte ganhou guardas para os
marcadores `[invalidado-em:]` / `[substituido-por:]`: reprovam arquivo ausente
ou vazio, ponteiro vazio, ponteiro apontando diretório ou arquivo inexistente,
marcador sem par, marcador em linha indentada e marcador com qualquer formato
de data — cada caso provado por mutação. Suíte 380 → 387 asserts.

**A auditoria das 17 entradas NÃO foi entregue** e virou o nó
`decisoes-vivas-auditoria` (`planned`). Duas revisões adversariais reprovaram a
classificação, em conjuntos diferentes de entradas, e o diagnóstico foi que o
critério "já declarada normativamente" admite julgamento demais. As 8 marcações
foram revertidas e `decisoes-vivas.md` voltou byte-idêntico ao estado
pré-demanda. O nó novo troca julgamento por prova: só marca se um teste da
suíte reprovaria a violação, verificado por mutação entrada por entrada.

Fechamento proporcional do LIGHT entregue em 2026-09-01 (nó `light-enxuto`,
MEDIUM): a skill `validate` ganhou a seção `## Fechamento LIGHT`. Uma demanda
LIGHT não tem plano, escopo escrito nem, quase sempre, delta ou decisão
durável — mas vinha pagando o sync de 8 operações desenhado para MEDIUM/HIGH,
com um passo vácuo (arquivar plano inexistente) e outros quase sempre vazios.
Agora: a oferta de e2e só aparece quando a demanda toca caminho percorrido
pelo usuário; o roteiro vira versão curta (evidência 1:1 + diff + 1 linha de
como conferir); o sync roda só os passos com conteúdo real; o plano
inexistente não vira pendência; e o `PRD.md` só recebe promoção se o ajuste
alterar comportamento que ele já descreve — com silêncio sobre o PRD
explicitamente proibido. O que NÃO encolhe está na primeira linha da seção:
portão humano com aprovação explícita e evidência 1:1 por critério. O critério
/8 é guarda contra erosão futura: a suíte assere DENTRO da seção (extraída por
`awk`), porque no arquivo inteiro as duas frases já aparecem no fluxo geral e o
guarda passaria por acidente. MEDIUM e HIGH intocados. Suíte 371 → 377
asserts, com teste negativo. e2e pulado por decisão humana.

Perguntas em lote entregues em 2026-09-01 (nó `scope-batch`, MEDIUM): a fase
`scope` deixa de mandar "uma por vez / nunca duas perguntas na mesma mensagem"
e passa a agrupar as INDEPENDENTES, no máximo 4 por lote (limite do
`AskUserQuestion`, documentado como limite de ferramenta e não preferência).
O que decide lote vs série é um **teste de dependência** explícito: a resposta
de uma pergunta muda o enunciado, as opções ou a própria existência da outra?
Sim, série; não, mesmo lote. Decisão de formato ou layout passa a exigir
PREVIEW de cada alternativa; mais de 4 lacunas prioriza as que mais mudam
escopo e AVISA que há lote seguinte, em vez de truncar em silêncio; cada
escolha vira uma linha em `## decisoes` do nó com a alternativa descartada.
Red flag nova cobre o excesso oposto (agrupar perguntas dependentes gera
resposta sobre premissa errada). O gargalo atacado é wall-clock: a fase
custava `N perguntas × tempo de resposta humana`. Intocados por
fora-de-escopo: o portão de escopo, o marcador `[PRECISA-CLARIFICAR]` e o
direito de não responder — mudou a cadência, nunca o direito. Suíte
365 → 371 asserts, com teste negativo. e2e pulado por decisão humana.

Bloco de fechamento entregue em 2026-08-31 (nó `resumo-de-fase`, MEDIUM,
versão 0.7.0): toda skill de FASE passa a encerrar imprimindo no terminal um
bloco Markdown padronizado — título `<id> · <fase> → <próxima>`, checkbox das
fases com resumo de até 8 palavras, o que a fase produziu, arquivos tocados
(caminho real e existente) e próximo passo. A execute fecha com a lista de
TAREFAS em checkbox, só no fim da fase; a validate aprovada soma o bloco
**Entrega** com tabela critério → veredito e arquivos do `git diff --name-only`
real. Categoria LIGHT/HOTFIX omite da lista as fases que não percorre, e fase
interrompida, bloqueada ou reprovada imprime o bloco mesmo assim, desmarcada e
com o motivo em 1 linha. O formato é schema, então vive só em
`templates/bloco-fechamento-template.md` (110 linhas) e cada skill de fase
aponta para ele em ~8 linhas — nunca cópia. `memory` e `worktree` NÃO imprimem:
são skills-ferramenta e devolvem à fase chamadora. A Constituição ganhou o
sétimo padrão obrigatório de skill de fase. Suíte 334 → 365 asserts, com teste
negativo provando os dois guardas. e2e em duas sessões reais 0.7.0 provou /1,
/5, /6 e /7 — o contraste LIGHT (3 fases listadas) vs HIGH (5) é a prova do /5;
/2 foi refinado por delta ao descobrir que contradizia /7 em fase interrompida.

Skill `memory` fatiada em 2026-08-31 (nó `memory-fatiada`, MEDIUM, versão
0.6.0): a skill mais chamada do framework (7 das 9 a invocam, 18 pontos de
chamada) virou **roteador + references**. `SKILL.md` caiu de 226 para 143
linhas (13.331 → 7.979 bytes, −40% por carga); `bootstrap`, `registrar-no`,
`compactar` e `consultar-codigo` viraram um arquivo cada em
`skills/memory/references/`, lidos UMA por operação; `carregar-contexto`,
`registrar-delta` e `registrar-aprendizado` ficaram inline por serem quentes e
curtos. Contrato das 7 operações preservado. Reference ausente avisa nomeando o
arquivo e degrada sem travar a fase. **Medido, não estimado**: 66.655 → 46.841
bytes de carga da skill por demanda MEDIUM (−29%, ~4.953 tokens) — a medição
existe porque uma decisão viva de 2026-08-25 mandava medir se a travessia
voltasse a doer. A suíte deixou de asserir por `cat` único e passou a asserir
por **localização** (arquivo certo), com assert negativo provando que é
movimento e não cópia; teto de 250 linhas estendido a `skills/*/references/` na
Constituição. Suíte 295 → 334 asserts. e2e em sessão real 0.6.0 fechou 8 dos 9
critérios; o /2 foi refinado por delta ao descobrir que o protocolo de
`consultar-codigo` encadeia `bootstrap` legitimamente.

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
