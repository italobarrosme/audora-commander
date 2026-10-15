---
id: review-avulsa
estado: planned
origem: humano
depende-de: [agentes-dedicados]
arquivos: []
keywords: [review, code-review, revisor, avulsa, criterios, disciplina]
resumo: Skill de review chamável fora do fluxo (pedir e receber review), que usa o revisor e lê os critérios do nó quando há MEMORY.
atualizado-em: 2026-10-15
---

# review-avulsa

## objetivo

Oferecer uma skill de review que o humano chama fora do fluxo de fases, para
pedir review de um diff ou receber e triar o feedback de um review. Ela
despacha o agente `revisor` e, quando o projeto tem `MEMORY.md` e o diff
pertence a um nó, confere o diff contra os critérios `<id>/<n>` desse nó.
Sem MEMORY, roda só como review de diff.

Origem: comparação audora × Superpowers (2026-10-15). O Superpowers tem
`requesting-code-review` e `receiving-code-review` sem estado; aqui a
disciplina reusa o estado do produto quando ele existe.
Categoria: MEDIUM (nenhuma pergunta de risco SIM; skill nova).

## criterios-aceite

<!-- pendente — fase scope -->

## fora-de-escopo

Postar comentário em PR, review multiagente, substituir a revisão adversarial
da validate.
Régua de corte: 5 demandas reais sem uso ou sem achado aceito → corta.

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
