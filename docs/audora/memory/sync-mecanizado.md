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

Revisão adversarial do PLANO (2026-09-02) derrubou 11 pontos altos. Achados
completos em `sync-mecanizado-historico.md`. Reabertura:

- MODIFICADO: **desenho** — de "escreve direto" para "**emite os comandos**;
  o modelo aplica via Edit/Write". Motivo mecânico, não cautela: aplicando por
  Edit/Write, os hooks `memory-validate` e `memory-guard` voltam a disparar
  sozinhos no `PostToolUse`. Escrita por script sai do alcance deles — e o
  achado 8 provou que apontar os hooks para o nó arquivado sai 0 (eles só
  casam `MEMORY.md` e `docs/audora/memory/*.md`), o que tornava /4 impossível.
- REMOVIDO: **/4** (o script valida o próprio resultado) — desnecessário no
  desenho novo. Substituído por: o script NÃO escreve, e a suíte prova isso.
- MODIFICADO: **/5** — cai a pré-condição de árvore limpa. O achado 6 provou
  que ela abortaria 100% das vezes: o sync real é UM commit no fim (`d0b89eb`
  traz estado, `arquivos:`, os dois renames e o PRD juntos), então a árvore
  está suja por construção quando o script roda.
- MODIFICADO: **/1** — a base do diff deixa de vir de `git log --grep <id>`
  (achado 1: dava 43 arquivos contra 5 em três ids reais, porque casava commit
  de outra demanda que só CITA o id) e passa a ser o **pai do commit que criou
  o arquivo do nó**: `git log --diff-filter=A -- docs/audora/memory/<id>.md
  docs/audora/arquivo/*-<id>.md | tail -1`, depois `^`. Verificado no
  momento do sync: bate 5/5 em `light-enxuto` e `scope-batch`.
- ADICIONADO: **/1b** — a lista exclui `docs/audora/memory/<id>.md`, o caminho
  do próprio nó antes do arquivamento (achado 20).
- ADICIONADO: **/10** — QUANDO o script rodar O SISTEMA DEVE deixar o
  repositório inalterado; a suíte prova comparando `git status --porcelain`
  antes e depois.
- ADICIONADO: **/11** — QUANDO a fixture do teste falhar ao montar O SISTEMA
  DEVE abortar o arquivo de teste, nunca seguir com o cwd no repositório real
  (achado 7: os casos 4, 5 e 6 commitariam no repo de verdade).

## e2e

pendente

## feedback-reprovacao

Reprovada na 2ª revisão adversarial (do diff, 2026-09-03): 4 altos e 24 de 44
mutações passando verde. Detalhe em `sync-mecanizado-historico.md`.
