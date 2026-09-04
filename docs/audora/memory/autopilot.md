---
id: autopilot
estado: in-progress
origem: humano
depende-de: [gate-mecanico]
arquivos: []
keywords: [autopilot, loop-engineering, portao-antecipado, elegibilidade, paradas-humanas]
resumo: Humano declara autopilot na entrada e o framework antecipa os portões do meio (mantendo o final); só demanda com critérios 100% automatizáveis; HIGH recusa.
atualizado-em: 2026-09-04
---

# autopilot

## objetivo

O humano declara na entrada da demanda ("autopilot" / "roda até o validate") e
o framework antecipa os portões do meio, mantendo SEMPRE o portão final da
validate. Elegibilidade pela pergunta que decide: todos os critérios EARS têm
verificação automatizável? HIGH nunca roda em autopilot (catraca recusa e
explica). D2 do roadmap `docs/specs/2026-09-02-loop-engineering-roadmap.md`.

## criterios-aceite

<!-- Na spec (HIGH): docs/audora/specs/autopilot-escopo.md — autopilot/1..14. -->

## fora-de-escopo

Motor headless (D3); mudar o que é HIGH; reduzir perguntas do scope; remover o
portão final da validate.

## decisoes

- 2026-09-04 (humano): aberta como terceira demanda do roadmap, após D0 e D1
  entregues; depende de D1 (sem gate, autopilot é confiança sem evidência) —
  satisfeita.
- 2026-09-04 (humano, scope): LIGHT + MEDIUM aceitam autopilot; só HIGH
  recusa. Descartado: só MEDIUM (terceira regra desnecessária).
- 2026-09-04 (humano, scope): ativação SÓ por declaração espontânea; framework
  nunca oferece. Descartado: oferta quando elegível (parada humana nova).
- 2026-09-04 (humano, scope): declaração tardia vale — antecipa só os portões
  ainda não cruzados. Descartado: só na entrada.
- 2026-09-04 (humano, scope): `paradas humanas: N` conta toda espera de input,
  discriminada, em toda demanda. Descartado: só portões.

## delta

## e2e

pendente

## feedback-reprovacao
