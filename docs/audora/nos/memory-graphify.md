---
id: memory-graphify
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [memory, graphify, grafo, consulta, tokens, breaking]
resumo: GRAFO vira MEMORY (memória do produto em memorys.md) e Graphify indexa o código por baixo dos panos para consulta barata nas fases.
atualizado-em: 2026-08-26
---

# memory-graphify

## objetivo

O GRAFO deixa de existir: a memória do produto vira MEMORY (`MEMORY.md` +
`docs/audora/memory/<id>.md`), guardando tudo que o GRAFO guardava mais
aprendizados/preferências do projeto. Graphify indexa o código por baixo dos
panos (só código, sem API key) e plan/debug/execute consultam o grafo antes de
ler arquivos. Breaking change aceito (1 usuário, projeto no começo).

## criterios-aceite

Spec dedicada (HIGH): `../specs/memory-graphify-escopo.md` — 19 critérios
`memory-graphify/1..19` (lote A memory /1-9, lote B graphify /10-18,
docs /19).

## fora-de-escopo

Ver spec: indexar docs no Graphify; hooks always-on do Graphify; MCP;
compat/migração automática de GRAFO em projetos-alvo; federação; benchmark
de tokens; versionar `graphify-out/`.

## decisoes

- 2026-08-26 (humano): breaking change aceito — sem compat v1/v2, sem
  migração de projetos-alvo além deste repositório.
- 2026-08-26 (humano): categoria HIGH (dado persistido + contrato consumido
  pelas outras skills); 1 nó, plano em 2 lotes (memory; graphify).
- 2026-08-26 (humano, escopo): `skill-memory` absorvido por este nó
  (memory = GRAFO + aprendizados); vira `discarded` no sync.
- 2026-08-26 (humano, escopo): `MEMORY.md` + `docs/audora/memory/<id>.md`
  (não `memorys.md` único); Graphify só código, oferecido/instalado, git
  hook, consulta em plan/debug/execute, sem hooks always-on, `graphify-out/`
  no gitignore.

## delta

- MODIFICADO (2026-08-26, fase plan): critério /1 "grep -ri grafo vazio em
  skills/…" → tolera UMA menção a `GRAFO.md` em `skills/memory/SKILL.md`, a
  do aviso exigido pelo /3 (os dois se contradizem ao pé da letra). Aprovado
  junto com o plano.

## e2e

pendente

## feedback-reprovacao
