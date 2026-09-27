---
id: memory-graphify
estado: delivered
origem: humano
depende-de: []
arquivos: [skills/, hooks/, templates/, tests/, README.md, README.pt-BR.md, PRD.md, MEMORY.md]
keywords: [memory, graphify, consulta, tokens, breaking]
resumo: A memória do produto vira MEMORY (MEMORY.md + docs/audora/memory/) e o Graphify indexa o código por baixo para consulta barata nas fases.
atualizado-em: 2026-09-27
---

# memory-graphify

## objetivo

A memória do produto vira MEMORY (`MEMORY.md` + `docs/audora/memory/<id>.md`),
guardando requisitos, estado e decisões mais aprendizados/preferências do
projeto. Graphify indexa o código por baixo dos panos (só código, sem API key)
e plan/debug/execute consultam o índice antes de ler arquivos. Breaking change
aceito.

## criterios-aceite

Spec dedicada (HIGH, histórica): `../specs/memory-graphify-escopo.md` — 19
critérios `memory-graphify/1..19`, com o delta consolidado abaixo:

- /1 vale sem exceções: zero menção ao nome antigo na superfície do plugin
  (as exceções do aviso e da tabela de renomeação saíram com /3 e /19).
- /3 REMOVIDO (2026-09-27, `limpeza-codigo-morto`): aviso sobre o arquivo de
  memória antigo aposentado — breaking não é mais comunicado.
- /19 MODIFICADO (2026-09-27, `limpeza-codigo-morto`): READMEs e PRD
  descrevem MEMORY + Graphify; a seção de renomeação saiu; versão vigente
  0.8.0.

## fora-de-escopo

Ver spec: indexar docs no Graphify; hooks always-on do Graphify; MCP;
compat/migração automática em projetos-alvo; benchmark de tokens;
versionar `graphify-out/`.

## decisoes

- 2026-08-26 (humano): breaking change aceito — sem compat, sem migração de
  projetos-alvo além deste repositório.
- 2026-08-26 (humano): categoria HIGH (dado persistido + contrato consumido
  pelas outras skills); 1 nó, plano em 2 lotes (memory; graphify).
- 2026-08-26 (humano, escopo): `skill-memory` absorvido por este nó
  (memory = memória do produto + aprendizados); vira `discarded` no sync.
- 2026-08-26 (humano, escopo): `MEMORY.md` + `docs/audora/memory/<id>.md`;
  Graphify só código, oferecido/instalado, git hook, consulta em
  plan/debug/execute, sem hooks always-on, `graphify-out/` no gitignore.
- 2026-09-27 (humano, via `limpeza-codigo-morto`): nó fechado como
  `delivered` — ficou `in-progress` depois da entrega da 0.4.0.

## delta

## e2e

relatorio: ../e2e/e2e-memory-graphify.md (2026-08-26; 7 corridas `claude -p`,
11 critérios exercitados, 0 falhou). Evidência de fechamento (2026-09-27):
/2, /4, /6, /10, /12, /13, /14 no relatório; /5, /7, /8, /9, /11, /15, /16,
/18, /19 na suíte (`bash tests/run.sh`, 548 asserts, 0 falhas); /17 regra
escrita (roteiro humano); /1 grep vazio no roteiro de `limpeza-codigo-morto`.

## feedback-reprovacao
