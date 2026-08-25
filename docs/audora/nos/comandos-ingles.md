---
id: comandos-ingles
estado: em-curso
origem: humano
depende-de: [plugin-v0.1.0]
arquivos: []
keywords: [ingles, i18n, rename, skills, categorias, contrato]
resumo: Nomes das skills (comandos) e categorias de risco (LEVE/MÉDIA/ALTA/HOTFIX) passam a ser em inglês.
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

Spec dedicada (ALTA): `../specs/comandos-ingles-escopo.md` — critérios
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

## delta

- ADICIONADO (2026-08-25): emenda à Constituição (aplicar no sync) —
  "conteúdo em português" ganha exceção para nomes de skills, categorias de
  risco e enum de estado em inglês.

## e2e

pendente

## feedback-reprovacao
