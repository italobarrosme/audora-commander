---
id: memory-fatiada
estado: in-progress
origem: humano
depende-de: [memory-graphify]
arquivos: []
keywords: [memory, tokens, references, overhead, performance]
resumo: Skill memory vira roteador fino + references carregáveis por operação — corta o maior bloco de overhead fixo por demanda.
atualizado-em: 2026-08-30
---

# memory-fatiada

## objetivo

Cortar o maior bloco de overhead de contexto do framework: `skills/memory/SKILL.md`
tem 13.331 bytes (~3,3k tokens, 226 linhas, 7 operações num arquivo só) e é
chamada por 7 das 9 skills em 18 pontos. Numa demanda MEDIUM com `/clear` entre
fases ela é recarregada ~5 vezes (~17k tokens), o que responde por 26-41% do
overhead fixo de 40k-65k tokens gasto antes de ler uma linha de código do
produto. A skill deve virar roteador fino com o corpo de cada operação em
`references/`, carregado só quando a operação é usada.

## criterios-aceite

<!-- Vazio até a fase scope (exceção declarada: nó aberto pela porta de
     entrada para demanda MEDIUM). -->

## fora-de-escopo

<!-- Definido na fase scope. -->

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
