---
id: gate-anti-edicao
estado: planned
origem: humano
depende-de: []
arquivos: []
keywords: [gate, anti-fraude, assert, base, suite-completa, regressao, hotfix]
resumo: Gate compara contra a base da demanda, reprova assert editado e exige suíte completa; bug lista comportamento inalterado.
atualizado-em: 2026-10-09
---

# gate-anti-edicao

## objetivo

Fechar as brechas do anti-fraude: comparar contra a base gravada no início da
demanda (não HEAD), reprovar assert MODIFICADO em teste preexistente sem
justificativa, cobrar mudança no avaliador (`tests/lib.sh`, `run.sh`,
`hooks/gate`), exigir a suíte completa e, em bug/HOTFIX, listar o
comportamento que não pode mudar como teste de regressão.

Origem: grupo C do estudo `docs/study/2026-10-09-estudo-aprimoramento.md` (local)
(ImpossibleBench: Claude edita o teste em >79% das trapaças).
Categoria: HIGH (pergunta 1 provável SIM: base gravada no nó muda o schema;
pergunta 2: `hooks/gate` é contrato usado pelos projetos — na dúvida, a mais
pesada).

## criterios-aceite

<!-- pendente — fase scope -->

## fora-de-escopo

Monitor LLM do diff de teste (vai com agentes-dedicados); mutação dirigida
por LLM na validate.

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
