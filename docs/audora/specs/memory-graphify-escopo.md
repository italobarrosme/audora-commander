# Escopo — memory-graphify (HIGH)

> Data: 2026-08-26. Nó: `docs/audora/nos/memory-graphify.md`. Fase scope.
> Breaking change aceito pelo humano (1 usuário, projeto no começo): sem
> compat com GRAFO v1/v2 em projetos-alvo.

## Objetivo

O GRAFO deixa de existir. A memória do produto passa a se chamar **MEMORY**:
`MEMORY.md` na raiz (propósito, constituição, aprendizados, índice de nós) +
`docs/audora/memory/<id>.md` por demanda — tudo que o GRAFO guardava MAIS os
aprendizados/preferências do projeto (absorve o nó planejado `skill-memory`).
Por baixo dos panos, o **Graphify** indexa o código do projeto-alvo (só
código, tree-sitter, sem API key) e as fases `plan`, `debug` e `execute`
consultam o grafo antes de ler arquivos — com instalação oferecida, git hook
de atualização e degradação avisada quando ausente.

## Critérios de aceite (EARS, numerados)

### Lote A — MEMORY substitui GRAFO

- **memory-graphify/1** — QUANDO o plugin for instalado O SISTEMA DEVE listar
  8 skills com `memory` no lugar de `graph`, e `grep -ri grafo` sobre
  `skills/ hooks/ templates/ .claude-plugin/ README*.md PRD.md` DEVE
  retornar vazio (histórico em `docs/audora/arquivo/` e `docs/specs/` fica).
- **memory-graphify/2** — QUANDO a porta de entrada rodar em projeto sem
  `MEMORY.md` O SISTEMA DEVE oferecer bootstrap do MEMORY, nunca seguir sem
  ele nem inventar um.
- **memory-graphify/3** — QUANDO a porta de entrada encontrar `GRAFO.md` e
  nenhum `MEMORY.md` O SISTEMA DEVE avisar que GRAFO não é mais lido e
  oferecer bootstrap do MEMORY (o que fazer com o GRAFO antigo é do humano).
- **memory-graphify/4** — QUANDO o bootstrap rodar O SISTEMA DEVE criar
  `MEMORY.md` pelo template (Propósito, Constituição, Aprendizados, Índice de
  nós) e `docs/audora/memory/` vazia, perguntando ao humano o que faltar.
- **memory-graphify/5** — QUANDO uma fase registrar nó ou delta O SISTEMA DEVE
  escrever `docs/audora/memory/<id>.md` E a linha rica do índice na mesma
  edição, no schema do template de nó (frontmatter grep-ável, critérios EARS
  numerados `<id>/<n>`).
- **memory-graphify/6** — QUANDO qualquer fase descobrir um aprendizado
  (como-rodar, armadilha, preferência do humano, padrão do projeto)
  O SISTEMA DEVE registrá-lo na hora na seção `Aprendizados` do `MEMORY.md`
  (1 linha: data | fase | aprendizado), não só no sync final.
- **memory-graphify/7** — QUANDO a validate concluir o sync pós-merge
  O SISTEMA DEVE promover decisões vivas, consolidar aprendizados da demanda
  e arquivar o nó por `git mv` para `docs/audora/arquivo/`.
- **memory-graphify/8** — QUANDO uma escrita em `MEMORY.md` ou
  `docs/audora/memory/*.md` quebrar o schema (índice↔pasta divergente,
  `depende-de` inexistente, ciclo, estado fora do enum, teto de linhas)
  O SISTEMA DEVE devolver o erro ao modelo via hook (exit 2), como hoje.
- **memory-graphify/9** — QUANDO a demanda for entregue O SISTEMA DEVE ter
  este repositório migrado (dogfood): `MEMORY.md` + `docs/audora/memory/`
  com os nós ativos e planejados de hoje; `GRAFO.md`, `docs/audora/nos/` e
  `GRAFO-ARQUIVO.md` removidos; histórico de nós entregues preservado em
  `docs/audora/arquivo/` (conteúdo intocado).

### Lote B — Graphify por baixo dos panos

- **memory-graphify/10** — QUANDO o bootstrap do MEMORY rodar e `graphify`
  não estiver no PATH O SISTEMA DEVE oferecer instalar; aceito → instala
  (`uv tool install graphifyy`, fallback `pipx install graphifyy`) e confirma
  com `graphify --version`; recusado → registra `graphify: recusado` na
  Constituição e avisa que as fases rodam degradadas.
- **memory-graphify/11** — QUANDO a instalação falhar (sem uv/pipx, sem
  rede, Python < 3.10) O SISTEMA DEVE mostrar o erro real, NÃO marcar
  recusado, e seguir degradado avisando — nunca afirmar que instalou.
- **memory-graphify/12** — QUANDO o Graphify estiver disponível no bootstrap
  O SISTEMA DEVE rodar `graphify .` (só código, sem API key), instalar o git
  hook (`graphify hook install`), adicionar `graphify-out/` ao `.gitignore`
  e registrar `graphify: ativo` na Constituição.
- **memory-graphify/13** — QUANDO `graphify .` produzir grafo sem nós de
  código (projeto sem linguagem suportada) O SISTEMA DEVE avisar, não
  instalar git hook, e registrar `graphify: sem-codigo` na Constituição.
- **memory-graphify/14** — QUANDO `plan`, `debug` ou `execute` precisarem
  localizar código com `graphify: ativo` O SISTEMA DEVE consultar
  `graphify query` / `graphify path` antes de qualquer Read e ler só os
  arquivos apontados; Read fora do apontado só com exceção declarada
  ("grafo não cobre X").
- **memory-graphify/15** — QUANDO a consulta ao Graphify falhar (comando
  ausente, `graph.json` ausente/corrompido, erro de execução) O SISTEMA DEVE
  avisar e cair para grep/Read na mesma fase, sem travar a demanda.
- **memory-graphify/16** — QUANDO o grafo não contiver um arquivo que existe
  no repositório O SISTEMA DEVE rodar `graphify update .` uma única vez antes
  de consultar de novo; persistindo, degradar com aviso.
- **memory-graphify/17** — QUANDO `graphify: recusado` ou `sem-codigo` estiver
  na Constituição O SISTEMA DEVE NÃO oferecer instalação/indexação de novo
  nas demandas seguintes — só se o humano pedir.
- **memory-graphify/18** — QUANDO scope, e2e ou validate rodarem O SISTEMA
  DEVE NÃO consultar o Graphify (fases que não exploram código cru).

### Documentação

- **memory-graphify/19** — QUANDO a demanda for entregue O SISTEMA DEVE ter
  `README.md`, `README.pt-BR.md` e `PRD.md` descrevendo MEMORY + Graphify,
  versão 0.4.0 no manifest, e seção "Renamed in 0.4.0" (GRAFO → MEMORY,
  `graph` → `memory`, paths novos).

## Fora de escopo

- Indexar markdown/docs/MEMORY no Graphify (exige API key e tokens).
- Hooks always-on do Graphify (`graphify claude install`, CLAUDE.md,
  PreToolUse) — framework chama só CLI nas skills.
- Servidor MCP do Graphify.
- Compat/migração automática de GRAFO v1/v2 em projetos-alvo (só aviso, /3).
- Federação/monorepo.
- Benchmark de tokens antes/depois (segue estimativa; humano pode puxar).
- Versionar `graphify-out/` (gitignore, /12).

## Decisões de escopo (humano, 2026-08-26)

- Memory = GRAFO + aprendizados; absorve `skill-memory` (nó vira `discarded`
  com `substituido-por: memory-graphify`).
- Forma: `MEMORY.md` índice + `docs/audora/memory/<id>.md` (não arquivo único;
  nome MAIÚSCULO, não `memorys.md`).
- Graphify: oferece, instala se aceito, degrada avisando se recusado.
- Só código; bootstrap + git hook; consulta em plan/debug/execute; sem hooks
  próprios do Graphify; `graphify-out/` no gitignore.
- Categoria HIGH; 1 nó, plano em 2 lotes (A memory, B graphify).
