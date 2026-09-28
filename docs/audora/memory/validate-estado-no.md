---
id: validate-estado-no
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [memory-validate, hook, estado, enum, frontmatter]
resumo: memory-validate passa a validar o campo estado do frontmatter dos arquivos de nó, não só a coluna do índice.
atualizado-em: 2026-09-28
---

# validate-estado-no

## objetivo

Fechar a meta 1 do PRD: o hook `memory-validate` hoje só confere o estado na
coluna do índice (`MEMORY.md`); o campo `estado:` do frontmatter de
`docs/audora/memory/<id>.md` passa sem checagem. A demanda estende a
validação aos arquivos de nó.

## criterios-aceite

- **validate-estado-no/1** — QUANDO um arquivo de nó em `docs/audora/memory/`
  tem `estado:` com valor fora do enum O SISTEMA DEVE rejeitar a escrita
  (exit 2) nomeando o arquivo, o valor encontrado e o enum válido
- **validate-estado-no/2** — QUANDO um arquivo de nó não tem a linha `estado:`
  no frontmatter O SISTEMA DEVE rejeitar a escrita nomeando o arquivo
- **validate-estado-no/3** — QUANDO o `MEMORY.md` é escrito e o `estado:` de
  algum arquivo de nó difere da coluna de estado da linha dele no índice O
  SISTEMA DEVE rejeitar a escrita nomeando o nó e os dois valores (índice e
  arquivo)
- **validate-estado-no/4** — QUANDO qualquer escrita no `MEMORY.md` ou em
  arquivo de nó dispara o hook O SISTEMA DEVE conferir o estado de TODOS os
  arquivos de nó da pasta, não só o do arquivo escrito (/1 e /2 em toda
  escrita; /3 nas escritas do índice)
- **validate-estado-no/9** — QUANDO um arquivo de nó é escrito com estado
  válido mas diferente do índice (primeira metade de uma transição) O SISTEMA
  DEVE aceitar a escrita (exit 0)
- **validate-estado-no/10** — QUANDO a skill `memory` (registrar-no) ou o sync
  da `validate` descrevem uma transição de estado O SISTEMA DEVE instruir a
  ordem nó primeiro, índice depois
- **validate-estado-no/5** — QUANDO todo arquivo de nó tem estado no enum e
  igual ao do índice — inclusive com fim de linha CRLF ou espaço sobrando ao
  redor do valor — O SISTEMA DEVE aceitar a escrita (exit 0)
- **validate-estado-no/6** — QUANDO o arquivo é `<id>-historico.md` O SISTEMA
  DEVE ignorá-lo nas checagens de estado
- **validate-estado-no/7** — QUANDO um arquivo de nó não tem linha no índice O
  SISTEMA DEVE acusar só a ausência da linha (erro já existente), sem erro de
  divergência duplicado para o mesmo nó
- **validate-estado-no/8** — QUANDO o usuário lê o que o `memory-validate`
  confere nos dois READMEs O SISTEMA DEVE listar a checagem de estado nos
  arquivos de nó

## fora-de-escopo

Nós arquivados em `docs/audora/arquivo/` (não são validados); outros campos do
frontmatter (`origem`, `atualizado-em`, formato de `keywords`); estados
legados em português; correção automática (o hook só acusa); mudança do enum;
o erro transitório já existente na CRIAÇÃO de nó ("arquivo sem linha no
índice" ao escrever o nó antes do índice) — fica como está, candidato a nó
próprio.

## decisoes

- 2026-09-28 (humano): divergência índice × arquivo de nó BLOQUEIA
  (descartado: validar só o enum — índice e pasta divergentes já é "PARAR e
  corrigir" no registrar-no).
- 2026-09-28 (humano): nó sem linha `estado:` BLOQUEIA (descartado: ignorar
  — campo obrigatório pelo `no-template.md`).
- 2026-09-28 (humano): toda escrita confere TODOS os nós (descartado: só o
  arquivo escrito — as checagens atuais já varrem a pasta inteira).
- 2026-09-28 (humano): divergência só bloqueia na escrita do ÍNDICE, que é o
  ponto de fechamento; ordem canônica nó → índice (descartado: bloquear em
  toda escrita — cada transição geraria 1 erro transitório).

## delta

## e2e

relatorio: ../e2e/e2e-validate-estado-no.md

## feedback-reprovacao
