---
id: decisoes-vivas-auditoria
estado: planned
origem: humano
depende-de: [decisoes-vivas-poda]
arquivos: []
keywords: [decisoes-vivas, auditoria, marcacao, criterio-binario]
resumo: Auditar as 17 decisões vivas sob critério binário — só marca se um teste da suíte reprovaria a violação, provado por mutação.
atualizado-em: 2026-09-01
---

# decisoes-vivas-auditoria

## objetivo

A auditoria das 17 entradas de `docs/audora/decisoes-vivas.md` foi separada do
nó `decisoes-vivas-poda` depois de DUAS revisões adversariais reprovarem por
erro de classificação em conjuntos diferentes de entradas. A causa: o critério
"já declarada normativamente" não é operável — admite julgamento e o julgamento
errou duas vezes.

O critério desta demanda é **binário e verificável**: só marca a entrada se um
teste da suíte REPROVARIA caso a decisão fosse violada — e a prova é por
mutação, entrada por entrada, com a saída lida. Decisão que nenhum teste guarda
fica, ou ganha o teste na mesma demanda (regra /8, já entregue).

Achados que este critério precisa reclassificar, das duas revisões:
as 3 de `skill-worktree` (6 asserts em `tests/test-worktree.sh`), a de
`docs-bilingues` sobre placeholders (`tests/test-docs.sh` força md5 idêntico
dos blocos EN/PT), e a metade viva da de `skill-depurar` ("dois modos" não tem
teste nenhum). Relatórios completos em
`docs/audora/memory/decisoes-vivas-poda-historico.md`.

## criterios-aceite

<!-- Vazio até a fase scope. -->

## fora-de-escopo

<!-- Definido na fase scope. -->

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
