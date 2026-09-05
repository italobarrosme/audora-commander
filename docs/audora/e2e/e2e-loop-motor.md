# E2E — loop-motor

> Data: 2026-09-05. Por desenho da spec (loop-motor/14), o e2e do motor NUNCA
> chama o modelo real: o produto é o script `hooks/loop`, e ele roda DE
> VERDADE — repo git real, gate real invocado fora do agente, commits reais —
> com `claude` falso no PATH imprimindo o JSON do CLI. A primeira rodada com
> modelo real é atividade pós-merge (exige `sandbox:` na Constituição e
> branch de demanda), fora deste e2e.

## Receita (regressão)

1. `bash tests/test-loop.sh` — 97 asserts sobre fixtures git reais (recusas,
   voltas, violações, paradas, retomada).
2. Demo manual: `scratchpad/demo-loop.sh` — fixture com 2 tarefas e vereditos
   `vermelho, verde, verde`; ler a saída completa do motor.

## Critérios × evidência (tudo executado nesta sessão)

| Critério | Evidência | Veredito |
|---|---|---|
| /1-/4 pré-condições | 8 cenários de recusa: cada ausência nomeada, acumuladas numa saída só; teto com vírgula recusado; `gate: recusado — sufixo` recusado; zero volta gasta | passou |
| /5 prompt/contexto zerado | prompt salvo por volta; seção "SUA TAREFA" contém SÓ a tarefa da vez; `claude` chamado com `--output-format json` e `--max-budget-usd` | passou |
| /6 gate fora do agente | fake-gate consome vereditos externos; ordem provada: gate ANTES do commit (anti-fraude do gate vê diff não commitado) | passou |
| /7 verde commita e marca | demo real: `loop(demo1): volta 2 verde — tarefa 1 [demo1/1]` + marcador no plano no MESMO commit | passou |
| /8 vermelho patcheia | patch inclui até arquivo NOVO (staged antes do diff); árvore restaurada; nota com a saída do gate DENTRO de `## Notas de sessão` | passou |
| /9 DONE | demo: `DONE` + "preparação de evidência da validate"; plano sem tarefa → DONE imediato com zero claude | passou |
| /10 blocked | nunca-verde → nó `estado: blocked` E linha do índice viradas, commitadas | passou |
| /11 tetos | teto de voltas e de custo (soma awk dos JSON) param deixando o plano retomável | passou |
| /12 marcador | `[PRECISA-CLARIFICAR` no plano → "aguardando humano", zero volta | passou |
| /13 métricas | `- rodada 1: voltas=3 verdes=2 vermelhos=1 custo-usd=0.21 tempo=5s parada=DONE` no plano, COMMITADA (sobrevive ao vermelho da rodada seguinte — provado) | passou |
| /14 claude falso | todos os cenários via PATH da fixture; modelo real jamais invocado | passou |
| /15 retomada | rodada 2 numera certo e retoma na Tarefa 2 sem refazer a 1 | passou |
| violações (delta) | claude exit≠0, commit rogue (desfeito da história), fraude no plano (restaurado), volta vazia — 4 fixtures do revisor adversarial, todas vermelhas com nota | passou |

## Notas

- Revisão adversarial: 15 achados (4 ALTO), 14 corrigidos com red-green; o
  15º (limite de argv no Windows + parse do custo byte-exato) registrado no
  delta do nó como limitação conhecida.
- Saída completa da demo em anexo de sessão (scratchpad
  `demo-loop-out.txt`); commits da demo: volta verde cita `demo1/1`, métricas
  commitadas pelo motor.
