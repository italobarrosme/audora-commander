---
id: comandos-ingles
estado: delivered
origem: humano
depende-de: [plugin-v0.1.0]
arquivos: [.claude-plugin/, GRAFO.md, README.md, README.pt-BR.md, docs/audora/GRAFO-ARQUIVO.md, docs/audora/arquivo/, docs/audora/decisoes-vivas.md, docs/audora/e2e/e2e-comandos-ingles.md, docs/audora/nos/plugin-v0.1.0.md, docs/audora/specs/comandos-ingles-escopo.md, hooks/grafo-guard, hooks/grafo-validate, hooks/session-start, skills/, templates/]
keywords: [ingles, i18n, rename, skills, categorias, contrato]
resumo: Nomes das skills (comandos), categorias de risco (LIGHT/MEDIUM/HIGH/HOTFIX) e enum de estado dos nós passam a ser em inglês.
atualizado-em: 2026-08-25
---

# comandos-ingles

## objetivo

Identificadores que o usuário digita e o framework anuncia passam a ser em
inglês — comandos (`graph, scope, plan, execute, e2e, validate, debug`),
categorias de risco (LIGHT/MEDIUM/HIGH/HOTFIX) e enum de estado dos nós —
com prosa em português. Breaking (0.3.0): sem alias; GRAFOs de projetos-alvo
migram integralmente no primeiro toque de escrita.

## criterios-aceite

Spec dedicada (HIGH): `../specs/comandos-ingles-escopo.md` — critérios
`comandos-ingles/1.1`–`4.3` (comandos, categorias, estados, docs/versão).

## fora-de-escopo

Ver spec. Resumo: prosa, chaves de frontmatter, nomes de seção/arquivo/pasta
e `versao-schema` ficam; sem alias; prosa histórica não é reescrita.

## decisoes

- 2026-08-25 (IA): classificada ALTA — nomes de skills e categorias são o
  contrato do plugin consumido fora deste repo (hook, instaladores, GRAFOs de
  projetos-alvo); Lei de Ferro: na dúvida, a mais pesada.
- 2026-08-25 (humano): dicionário aprovado — ver spec; migração total de
  estados no primeiro toque; corte seco sem alias; plugin 0.3.0.
- 2026-08-25 (humano): emenda à Constituição — exceção de idioma para nomes
  de skills, categorias de risco e enum de estado (aplicada no sync).
- 2026-08-25 (humano): portão final aprovado; hook `grafo-validate` segue
  validando estado SÓ no índice (spec 3.4) — estender aos arquivos de nó é
  nó futuro, não delta desta demanda.
- 2026-08-25 (IA): `docs/fundamentos.md` fica em português (fora da lista
  1.3/2.2), com aviso na seção de renomeação dos READMEs.

## delta

<!-- consolidado no sync de 2026-08-25 (emenda à Constituição aplicada) -->

## e2e

relatorio: ../e2e/e2e-comandos-ingles.md

## feedback-reprovacao
