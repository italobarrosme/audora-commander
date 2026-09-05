---
id: loop-motor
estado: in-progress
origem: humano
depende-de: [gate-mecanico, autopilot]
arquivos: []
keywords: [loop, motor, headless, claude-p, contexto-zerado, teto, blocked, ralph]
resumo: Motor headless que roda o plano de uma demanda em autopilot volta a volta — claude -p novo por volta, gate fora do agente, commit no verde, tetos e condições de parada.
atualizado-em: 2026-09-05
---

# loop-motor

## objetivo

Script `hooks/loop` que roda o plano-arquivo de uma demanda em autopilot
volta a volta: cada volta é um `claude -p` NOVO (contexto zerado) com prompt
gerado de `templates/loop-prompt-template.md` (nó + plano + UMA tarefa +
regras). O MOTOR — não o agente — roda o gate, commita no verde, marca o
checkbox, grava diagnóstico no vermelho. Para por: plano sem tarefa (`DONE`),
N vermelhos na mesma tarefa (nó → `blocked`), teto de voltas, teto de custo,
marcador aberto. D3 do roadmap
`docs/specs/2026-09-02-loop-engineering-roadmap.md`.

## criterios-aceite

<!-- Na spec (HIGH): docs/audora/specs/loop-motor-escopo.md — loop-motor/1..15. -->

## fora-de-escopo

Paralelismo (D4); instalar docker/VM; escolher modelo por tarefa (parâmetro
simples); rodar demanda HIGH; modificar o gate (D1) ou o autopilot (D2);
substituir a suíte do projeto-alvo.

## decisoes

- 2026-09-05 (humano): aberta como quarta demanda do roadmap; depende de D1 e
  D2 — ambas entregues. Instrução do humano: seguir sem paradas extras —
  recomendações do roadmap (decisões 2, 3, 4, 6) adotadas como decisão de
  entrada; tetos default entram como PROPOSTA a ratificar no portão.
- 2026-09-05 (humano, override): instrução direta "continua" — portões de
  escopo e plano cruzados por override registrado (instrução do usuário vale
  mais que o framework); TUDO apresentado para ratificação no portão FINAL,
  que fica. Tetos default (`loop: voltas-tarefa=3 voltas-rodada=12
  custo-usd=10`) idem.
- 2026-09-05 (roadmap, dec. 2): motor = bash + `claude -p` (contexto zerado
  por volta). Descartado: /loop nativo do harness (mesma sessão, contexto
  acumula).
- 2026-09-05 (roadmap, dec. 3): quem commita é o MOTOR, depois do gate —
  veredito fora do alcance do agente. Descartado: agente commita.
- 2026-09-05 (roadmap, dec. 4): volta vermelha guarda o diff como patch em
  `docs/audora/planos/loop/<id>/` e descarta da árvore; patches limpos no fim
  da rodada. Descartado: descartar sem guardar.
- 2026-09-05 (roadmap, dec. 6): `sandbox: nenhum` roda SÓ com confirmação
  explícita por rodada, aviso impresso no bloco. Descartado: recusar sempre.

## delta

## e2e

pendente

## feedback-reprovacao
