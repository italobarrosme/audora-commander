---
id: autopilot
estado: delivered
origem: humano
depende-de: [gate-mecanico]
arquivos: [skills/audora-commander/SKILL.md, skills/scope/SKILL.md, skills/validate/SKILL.md, skills/e2e/SKILL.md, templates/no-template.md, docs/fundamentos.md, tests/test-autopilot.sh, MEMORY.md, PRD.md, docs/audora/specs/autopilot-escopo.md, docs/audora/e2e/e2e-autopilot.md, docs/audora/planos/arquivo/plano-autopilot.md]
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
- 2026-09-05 (humano, portão — deltas ratificados): /8 inclui projeto web
  (Playwright default) como ferramenta; elegibilidade fora do scope (LIGHT,
  tardia) é gravada pela porta de entrada na hora; toda espera extra vira
  linha em `## decisoes` para o contador sobreviver ao /clear.
- 2026-09-05 (IA, revisão adversarial): enum PT do campo `autopilot:` mantido
  (achado BAIXO 15 aceito — convenção mista já existente, ex. `origem:`).

## delta

<!-- consolidado em ## decisoes no sync de 2026-09-05 (deltas ratificados no
     portão final). -->

## e2e

relatorio: ../e2e/e2e-autopilot.md

## feedback-reprovacao
