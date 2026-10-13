---
id: status-retomada
estado: planned
origem: humano
depende-de: []
arquivos: []
keywords: [status, retomada, session-start, versao, release, migracao, brownfield]
resumo: Ver o que está em aberto e retomar sem lembrar o comando; versão sobe a cada entrega com nota de migração.
atualizado-em: 2026-10-09
---

# status-retomada

## objetivo

Uso real do dia a dia: o SessionStart mostra os nós em andamento e um
`status` deduz a fase (branch, commits `<id>/<n>`, plano) e imprime o comando
de retomada; toda entrega sobe a versão do plugin com nota de migração, para
os projetos que usam o plugin receberem os fixes (0.16.0 parada há 49
commits).

Origem: grupo D do estudo `docs/study/2026-10-09-estudo-aprimoramento.md` (local).
Categoria: MEDIUM (nenhuma pergunta de risco SIM; lógica nova em hook e skill).
Sobreposição a decidir no scope: `memory-inicio-fim` e a retomada do sync de
`caminhos-sem-saida`.

## criterios-aceite

<!-- pendente — fase scope -->

## fora-de-escopo

Bootstrap brownfield que detecta stack (candidato a nó próprio);
marketplace público (`marketplace-publico`).

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
