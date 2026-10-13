---
id: agentes-dedicados
estado: planned
origem: humano
depende-de: []
arquivos: []
keywords: [agentes, subagent, revisor, refutador, explorador, pretooluse, plataforma]
resumo: Agentes read-only no plugin (explorador, revisor-diff, refutador) e memory-guard em PreToolUse.
atualizado-em: 2026-10-09
---

# agentes-dedicados

## objetivo

Usar recursos nativos do Claude Code: `agents/` do plugin com subagentes
read-only de modelo fixo — `explorador` (plan), `revisor-diff` de contexto
zerado (só diff + critérios) e `refutador` (filtra achado antes do portão) —,
regra "só um agente escreve", e memory-guard barrando a escrita em
`PreToolUse` em vez de reclamar depois em `PostToolUse`.

Origem: grupo E do estudo `docs/study/2026-10-09-estudo-aprimoramento.md` (local);
nó planned antigo "Subagent types customizados por fase" absorvido aqui.
Categoria: MEDIUM (nenhuma pergunta de risco SIM; vários arquivos).

## criterios-aceite

<!-- pendente — fase scope -->

## fora-de-escopo

Implementadores paralelos, worktrees, debate entre agentes, agent teams.
Régua de corte: 5 demandas reais sem uso ou sem achado aceito → corta.

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
