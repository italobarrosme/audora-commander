---
id: grafo-v2
estado: em-curso
origem: humano
depende-de: []
arquivos: [skills/, templates/, hooks/, GRAFO.md, docs/audora/, .gitattributes]
keywords: [grafo, memoria, travessia, schema, indice, migracao]
resumo: Redesenho do GRAFO — índice mestre + 1 nó = 1 arquivo, travessia por grep, migração gradual.
atualizado-em: 2026-08-24
---

# grafo-v2

## objetivo

Redesenhar o GRAFO para travessia mais rápida e mais barata em tokens, com
base no estudo de mercado (../../specs/2026-08-24-estudo-grafo-mercado.md —
relativo a este arquivo), preservando os pontos fortes do v1 e com caminho
de migração a partir do schema v1.

## criterios-aceite

14 critérios numerados (grafo-v2/1.1 a grafo-v2/7.2) na spec dedicada
(ALTA): ../specs/grafo-v2-escopo.md — estrutura índice-mestre +
nó-por-arquivo, travessia por grep, ciclo de vida com decisoes-vivas e
arquivamento por mv, EARS numerado, migração gradual dual v1/v2, hooks com
degradação graciosa, limites.

## fora-de-escopo

federação (só sintaxe chave:id reservada); benchmark; .claude/rules geradas;
TSV/scripts de consulta; prefixo NNN-; skill MEMORY e grafo-inicio-fim;
script de migração em lote. Detalhe na spec.

## decisoes

- 2026-08-24 (humano): demanda classificada ALTA (toca dado persistido —
  GRAFO.md com versao-schema em todo projeto instalado).
- 2026-08-24 (IA): estudo multi-agente executado; 4 candidatos; síntese
  recomendou C sequenciado em 3 passos com portão de benchmark.
- 2026-08-24 (humano): direção = Candidato C COMPLETO direto, sem benchmark,
  migração gradual (fallback duas camadas).
- 2026-08-24 (humano): decisões vivas → docs/audora/decisoes-vivas.md;
  EARS numerado citável adotado.
- 2026-08-24 (humano): escopo (spec, 14 critérios) e plano (7 tarefas)
  aprovados nos portões.

## delta

## e2e

pendente

## feedback-reprovacao
