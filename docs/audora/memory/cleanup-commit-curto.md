---
id: cleanup-commit-curto
estado: in-progress
origem: humano
depende-de: [skill-cleanup]
arquivos: []
keywords: [cleanup, commit, commitlint, mensagem, corpo]
resumo: O commit do lote da cleanup tem linhas de até 100 caracteres e passa no commitlint config-conventional, qualquer que seja o tamanho do lote
atualizado-em: 2026-10-07
---

# cleanup-commit-curto

## objetivo

O `aplicar` do `hooks/cleanup` gera mensagem de commit que um hook `commit-msg` com commitlint
`config-conventional` aceita: hoje o corpo põe todos os caminhos de um tipo numa linha só e o
lote grande (pepity, 189 itens) é recusado por `body-max-line-length` — a cleanup desfaz tudo.

## criterios-aceite

- **cleanup-commit-curto/1** — QUANDO o `aplicar` commita um lote de qualquer tamanho O SISTEMA
  DEVE gerar mensagem em que o header e cada linha do corpo têm no máximo 100 caracteres
- **cleanup-commit-curto/2** — QUANDO a lista de um tipo (`<tipo>: a, b, c`) passaria de 100
  caracteres O SISTEMA DEVE continuar os itens em linhas seguintes recuadas com 2 espaços, sem
  perder nenhum item, mantendo a mensagem "listando o que saiu por tipo" (skill-cleanup/13)
- **cleanup-commit-curto/3** — QUANDO o projeto tem hook `commit-msg` que recusa linha de corpo
  acima de 100 caracteres O SISTEMA DEVE commitar o lote grande com sucesso (`cleanup: commit
  <hash> — N item(ns) removido(s)`)
- **cleanup-commit-curto/4** — QUANDO um item sozinho não cabe numa linha de 100 caracteres O
  SISTEMA DEVE deixá-lo fora da lista do corpo e acrescentar ao tipo a linha
  `  (+N caminho(s) longo(s) — ver git show --stat)`, com o item ainda apagado e no commit

## fora-de-escopo

Outras regras do commitlint (tipo, escopo, caixa do subject); mudança no relatório do `varrer`.

## decisoes

- 2026-10-07 (agente): classificada LIGHT — 4 perguntas de risco "não"; ajuste localizado em
  `commita` de `hooks/cleanup` + teste. Origem: cleanup do pepity recusada pelo commitlint
  (`body's lines must not be longer than 100 characters`), humano escolheu corrigir o script.

## delta

- MODIFICADO (2026-10-07): /2 "uma linha por tipo com a contagem" → lista por tipo quebrada em
  linhas de continuação de até 100 caracteres. Motivo: `skill-cleanup/13` (entregue) exige a
  mensagem listando o que saiu por tipo; só contagem violaria. ADICIONADO /4 (item mais longo que
  a linha).

## e2e

pendente

## feedback-reprovacao
