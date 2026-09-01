---
id: sync-mecanizado
estado: in-progress
origem: humano
depende-de: [light-enxuto]
arquivos: []
keywords: [validate, sync, hooks, bookkeeping, memoria]
resumo: Os passos mecanicos do sync da validate saem da mao do modelo e viram ferramenta em hooks/, deixando ao modelo so os de julgamento.
atualizado-em: 2026-09-01
---

# sync-mecanizado

## objetivo

O sync da validate tem 8 passos. Tres sao julgamento puro (consolidar delta no
corpo, escolher decisoes vivas, redigir o resumo do PRD) e cinco sao braco:
preencher `arquivos:` do diff, virar o estado para `delivered`, `git mv` do no
(e do `-historico.md`, se houver) para `docs/audora/arquivo/` com prefixo de
data, reescrever a linha do indice, e arquivar o plano. Os cinco rodam DEPOIS
da aprovacao humana, nao exigem decisao nenhuma, e sao feitos a mao pelo
modelo — caros em token e erraveis.

Escopo em spec dedicada (HIGH): `docs/audora/specs/sync-mecanizado-escopo.md`.

## criterios-aceite

<!-- Na spec (HIGH). -->

## fora-de-escopo

<!-- Na spec. -->

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
