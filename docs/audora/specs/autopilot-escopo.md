# Escopo — autopilot (HIGH)

> Data: 2026-09-04. Nó: `docs/audora/memory/autopilot.md`. Fase scope.
> D2 do roadmap `docs/specs/2026-09-02-loop-engineering-roadmap.md`.
> Invariantes do roadmap valem inteiros: portão final NUNCA sai; HIGH nunca
> roda em autopilot; `[PRECISA-CLARIFICAR]` nunca vira suposição.

## Objetivo

O humano declara na entrada da demanda ("autopilot" / "roda até o validate")
e o framework antecipa os portões do meio — o humano já aprovou na entrada —
mantendo SEMPRE o portão final da validate. Vale para LIGHT e MEDIUM; HIGH
recusa e explica (catraca). Elegibilidade pela pergunta que decide: todos os
critérios EARS do nó têm verificação automatizável (teste, e2e, comando)?
Não → inelegível, fluxo normal, critério culpado nomeado. O bloco de
fechamento da validate ganha o contador `paradas humanas: N` — a métrica da
dor que o roadmap manda medir.

## Critérios de aceite (EARS, numerados)

### Lote A — declaração e catraca

- **autopilot/1** — QUANDO o humano declarar autopilot ("autopilot" / "roda
  até o validate") na entrada de demanda LIGHT ou MEDIUM O SISTEMA DEVE
  registrar `autopilot: declarado` no nó e antecipar os portões do meio,
  mantendo o portão final da validate.
- **autopilot/2** — QUANDO o humano declarar autopilot em demanda HIGH O
  SISTEMA DEVE recusar, dizer o motivo (P4: portão nunca escala para baixo) e
  seguir o fluxo HIGH normal.
- **autopilot/3** — QUANDO o humano declarar autopilot no MEIO da demanda O
  SISTEMA DEVE aceitar, checar elegibilidade na hora e antecipar somente os
  portões ainda não cruzados, registrando a declaração tardia em
  `## decisoes` do nó.
- **autopilot/4** — QUANDO autopilot valer em demanda LIGHT O SISTEMA DEVE
  aplicar o efeito no e2e (rodar sem oferta com `ferramenta-e2e`; sem ela,
  registrar o pulo) mantendo o portão final — único portão do meio de LIGHT.

### Lote B — elegibilidade e scope

- **autopilot/5** — QUANDO a auto-revisão do scope rodar em demanda com
  `autopilot: declarado` O SISTEMA DEVE gravar `autopilot: elegivel` se todo
  critério tiver verificação automatizável, ou `autopilot: inelegivel
  (<id>/<n>)` citando o primeiro critério culpado e seguindo o fluxo normal.
- **autopilot/6** — QUANDO o scope fechar sem marcador aberto em demanda
  elegível O SISTEMA DEVE seguir para plan sem esperar aprovação (portão
  antecipado), registrando a antecipação em `## decisoes` do nó para
  ratificação na validate.
- **autopilot/7** — QUANDO restar `[PRECISA-CLARIFICAR]` em demanda com
  autopilot O SISTEMA DEVE parar e imprimir o bloco de fechamento com a fase
  desmarcada e o marcador — parada legítima, nunca licença para chutar.

### Lote C — e2e e validate

- **autopilot/8** — QUANDO a validate rodar em autopilot com `ferramenta-e2e`
  na Constituição O SISTEMA DEVE executar o e2e sem perguntar.
- **autopilot/9** — QUANDO a validate rodar em autopilot sem `ferramenta-e2e`
  O SISTEMA DEVE registrar `e2e: pulado-por-autopilot-sem-ferramenta` no nó,
  visível no portão final.
- **autopilot/10** — QUANDO a validate montar o roteiro em autopilot O
  SISTEMA DEVE incluir a seção "Premissas e decisões tomadas sem portão"
  (escopo antecipado apresentado para ratificação).
- **autopilot/11** — QUANDO a validate imprimir o bloco de fechamento O
  SISTEMA DEVE incluir `paradas humanas: N` discriminado (lotes de perguntas,
  ofertas respondidas, portões) — em TODA demanda, com ou sem autopilot, para
  a métrica ter baseline.

### Lote D — schema e docs

- **autopilot/12** — QUANDO `hooks/memory-validate` validar nó com o campo
  `autopilot:` O SISTEMA DEVE aceitar os valores `declarado | elegivel |
  inelegivel (<id>/<n>)` sem exit 2; `templates/no-template.md` documenta o
  campo comentado — e a suíte prova ANTES da mudança como o hook trata campo
  desconhecido hoje.
- **autopilot/13** — QUANDO a suíte rodar O SISTEMA DEVE provar por teste
  negativo que o portão final continua declarado na seção de autopilot da
  validate.
- **autopilot/14** — QUANDO o leitor consultar `docs/fundamentos.md` O
  SISTEMA DEVE encontrar no P5 o "portão antecipado por declaração" e na
  tabela do P4 a coluna autopilot.

## Fora de escopo

Motor headless (D3); mudar o que é HIGH; reduzir perguntas do scope; remover
o portão final da validate; oferta proativa de autopilot pelo framework
(ativação é só por declaração espontânea do humano).

## Decisões de escopo (portão da entrada, 2026-09-04)

1. LIGHT + MEDIUM (descartado: só MEDIUM — criaria terceira regra; modelo
   único: só HIGH recusa).
2. Ativação só por declaração espontânea (descartado: oferta quando elegível
   — adicionaria parada humana nova em toda demanda, contra a métrica).
3. Declaração tardia vale e antecipa o restante (descartado: só na entrada —
   humano que esqueceu pagaria todos os portões).
4. `paradas humanas: N` conta toda espera de input, discriminada (descartado:
   só portões — esconderia metade da espera real).
