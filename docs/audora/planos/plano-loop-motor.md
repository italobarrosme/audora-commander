# Plano — loop-motor: motor headless de voltas

> Reler no início de CADA sessão de execução e após compactação.

**Objetivo:** `hooks/loop` roda o plano de uma demanda elegível volta a volta
(`claude -p` novo por volta), com gate fora do agente, commit no verde, patch
no vermelho, tetos e paradas explícitas.

**Nó do MEMORY:** `loop-motor`; spec `docs/audora/specs/loop-motor-escopo.md`
(loop-motor/1..15)

**Arquitetura da mudança:** um script bash (`hooks/loop`) + um template de
prompt. TUDO que o motor toca é injetável por env para a suíte: comando do
claude (`LOOP_CLAUDE_CMD`), raiz (`LOOP_ROOT`) — mesmo padrão `GATE_*` do
gate. O veredito vem do comando `gate:` da Constituição do projeto-alvo
(placeholder `<id-da-demanda>` substituído pelo id); a suíte usa Constituição
de fixture apontando um fake-gate dirigido por arquivo de vereditos, e um
`claude` FALSO no PATH que imprime JSON com `total_cost_usd` — o modelo real
NUNCA roda na suíte. Custo somado por awk (bash não faz float).

**Contrato motor ↔ plano-arquivo** (vira texto no loop-prompt-template):
- Tarefa = seção `## Tarefa <n>:`; deps na linha `- **depende-de**: [Tarefa a, Tarefa b]`.
- Tarefa CONCLUÍDA = linha `- [x] concluida-pelo-motor (rodada R, volta V)`
  logo abaixo do header — quem escreve é o MOTOR, nunca o agente.
- Próxima tarefa = primeira seção sem marcador cujas deps têm marcador.
  Nenhuma aberta → `DONE`; abertas mas deps insatisfeitas → parada
  "dependência insatisfeita" (retomável).
- Vermelho: patch em `docs/audora/planos/loop/<id>/rodada<R>-volta<V>.patch`;
  descarte com `git checkout -- .` + `git clean -fd -e docs/audora/planos/loop`;
  diagnóstico em `## Notas de sessão` do plano (append, sem commit).
- Métricas: seção `## Métricas de rodada (loop)` no plano (append por rodada).

**Arquivos lidos antes de planejar:** `hooks/gate`, `hooks/run-hook.cmd`,
`hooks/graphify-status`, `templates/gate-template.md`,
`templates/plano-template.md`, `templates/no-template.md`, `tests/lib.sh`,
`tests/test-gate.sh`, `tests/test-memory-validate.sh`, `tests/run.sh`,
`skills/execute/SKILL.md`, `skills/validate/SKILL.md`, `MEMORY.md`
(Constituição), `.gitattributes` (hooks/* já LF), spec da demanda.

**Conflitos MEMORY vs código encontrados:** nenhum

## Notas de sessão

## Decisões tomadas pela IA

- Custo por `--output-format json` → `total_cost_usd` (grep -o); orçamento da
  volta = restante do teto via `--max-budget-usd`.
- Commit do verde inclui a marcação do plano no MESMO commit (marca antes do
  `git add`); endereços `<id>/<n>` citados = os grep-ados da seção da tarefa.
- Descarte do vermelho preserva `docs/audora/planos/loop/` (clean -e) e as
  Notas de sessão são escritas DEPOIS do descarte.
- `git add -A` só dentro do `LOOP_ROOT` da rodada (branch própria + sandbox
  são pré-condição; o risco do add -A registrado nos Aprendizados não se
  aplica a árvore isolada).

---

## Tarefa 1: templates/loop-prompt-template.md

- **depende-de**: []
- **requisito**: loop-motor/5 (o prompt da volta) — QUANDO uma volta iniciar
  O SISTEMA DEVE gerar o prompt de `templates/loop-prompt-template.md` (nó +
  plano + UMA tarefa + regras) e rodar um `claude -p` NOVO com
  `--max-budget-usd`
- **interfaces**: produz placeholders `{{NO}}`, `{{PLANO}}`, `{{TAREFA}}`,
  `{{ID}}` (linhas próprias, substituídas pelo motor) + bloco de regras: uma
  tarefa por volta; procurar antes de criar; placeholder proibido; NÃO
  commitar; NÃO marcar checkbox; NÃO tocar outra tarefa; NÃO rodar o gate
- **arquivos**: Criar `templates/loop-prompt-template.md`; Teste
  `tests/test-loop.sh` (novo, asserts de conteúdo)
- **done quando**: asserts red→green; suíte verde; commit citando /5

## Tarefa 2: hooks/loop — pré-condições (expandir: não)

- **depende-de**: [Tarefa 1]
- **requisito**: loop-motor/1, /2, /3, /4 verbatim da spec
- **interfaces**: produz `bash hooks/loop <id> [--voltas-tarefa N]
  [--voltas-rodada N] [--custo-usd N] [--model M] [--confirmo-sem-sandbox]`;
  lê da Constituição os bullets `gate:`, `sandbox:`, `loop:`
  (`voltas-tarefa=A voltas-rodada=B custo-usd=C`); env `LOOP_ROOT`,
  `LOOP_CLAUDE_CMD`
- **arquivos**: Criar `hooks/loop`; Teste `tests/test-loop.sh` (fixture git
  com MEMORY mínimo; cenários de recusa: sem autopilot elegível, sem gate:,
  na main, sem teto, sem sandbox:, sandbox nenhum sem flag, sem git, gate
  do bullet inexistente)
- **done quando**: cada recusa exercitada com mensagem nomeando o que falta;
  exit 1; nenhuma volta executada; suíte verde; commit /1-/4

## Tarefa 3: hooks/loop — a volta (verde/vermelho) — expandir: sim

- **depende-de**: [Tarefa 2]
- **requisito**: loop-motor/5, /6, /7, /8 verbatim
- **interfaces**: consome T1 (prompt) e o contrato motor↔plano; fake `claude`
  no PATH (imprime JSON `total_cost_usd`, faz edição scriptada) e fake-gate
  por arquivo de vereditos
- **arquivos**: Modificar `hooks/loop`; `tests/test-loop.sh` (fixture ganha
  plano de 2 tarefas e fake claude/gate)
- **done quando**: verde → commit com endereço + marcador no plano no mesmo
  commit; vermelho → sem commit, patch salvo, árvore limpa, nota no plano;
  gate SEMPRE chamado fora do fake claude; suíte verde; commit /5-/8
- **expandir: sim** — quebrar red-green por veredito quando chegar a vez

## Tarefa 4: hooks/loop — paradas e métricas — expandir: sim

- **depende-de**: [Tarefa 3]
- **requisito**: loop-motor/9, /10, /11, /12, /13 verbatim
- **arquivos**: Modificar `hooks/loop`; `tests/test-loop.sh` (cenários:
  DONE; nunca-verde → nó `blocked` no arquivo E na linha do índice; teto de
  voltas; teto de custo por soma awk dos JSON; `[PRECISA-CLARIFICAR]`
  plantado no plano; seção de métricas no plano com causa da parada)
- **done quando**: cada parada com bloco impresso e plano retomável; suíte
  verde; commit /9-/13

## Tarefa 5: retomada + varredura de cenários

- **depende-de**: [Tarefa 4]
- **requisito**: loop-motor/14, /15 verbatim
- **arquivos**: `tests/test-loop.sh` (segunda execução: rodada 2 retoma da
  primeira aberta sem refazer marcada; assert de que nenhum cenário chama
  claude real — `command -v claude` do PATH da fixture aponta o fake)
- **done quando**: retomada provada (tarefa 1 intocada, tarefa 2 executada);
  suíte verde; commit /14,/15

## Tarefa 6: skills + Constituição

- **depende-de**: [Tarefa 3]
- **requisito**: cobertura documental — roadmap D3: `skills/execute/SKILL.md`
  (seção "volta de loop": o que a volta NÃO faz), `skills/validate/SKILL.md`
  (relatório de rodada entra no roteiro), Constituição bullet
  `loop: voltas-tarefa=3 voltas-rodada=12 custo-usd=10` (proposta ratificável
  no portão final)
- **arquivos**: Modificar os 2 SKILL.md (tetos 250 ok: execute 105, validate
  193) e `MEMORY.md`; asserts em `tests/test-loop.sh`
- **done quando**: asserts red→green; suíte verde; commit citando o nó

<!-- Proibições: TBD; TODO; "similar à tarefa N"; passo sem como; órfã. -->
