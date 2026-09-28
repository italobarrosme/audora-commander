---
id: readme-skills
estado: in-progress
origem: humano
depende-de: [otimizacao-tokens]
arquivos: []
keywords: [readme, docs, skills]
resumo: READMEs EN e PT ganham seção detalhada por skill: gatilho, passos, artefatos, portões, próxima.
atualizado-em: 2026-09-28
---

# readme-skills

## objetivo

Quem lê o README entende o que cada uma das 9 skills faz — quando dispara, o
que executa, o que deixa no disco, onde o humano decide e para onde segue —
sem abrir os SKILL.md.

## criterios-aceite

- **readme-skills/1** — QUANDO o leitor abrir `README.md` O SISTEMA DEVE
  mostrar, para cada skill de `skills/`, uma subseção `### <skill>` com os
  cinco rótulos **When it fires**, **What it does**, **What it leaves on
  disk**, **Human gates** e **Next**.
- **readme-skills/2** — QUANDO o leitor abrir `README.pt-BR.md` O SISTEMA
  DEVE mostrar a mesma subseção por skill com **Quando dispara**, **O que
  faz**, **O que deixa no disco**, **Portões humanos** e **Próxima**.
- **readme-skills/3** — QUANDO uma skill existir em `skills/` sem subseção
  em algum dos dois READMEs O SISTEMA DEVE reprovar a suíte nomeando a skill
  e o README (skill nova não entra sem doc).
- **readme-skills/4** — QUANDO a subseção citar artefato, comando ou portão
  O SISTEMA DEVE refletir o comportamento vigente (0.9.0): caminhos reais
  (`docs/audora/...`, `references/`), portões da tabela de roteamento, e
  nenhuma mecânica que as skills não têm.
- **readme-skills/5** — QUANDO a seção nova entrar O SISTEMA DEVE manter a
  tabela-resumo das 9 skills (visão rápida, com link para as subseções) e os
  blocos de código idênticos entre EN e PT.

## fora-de-escopo

Mudar comportamento de skill; traduzir `docs/fundamentos.md` ou `docs/audora/`;
bump de versão (README não é carregado pelo plugin em runtime); reescrever
as demais seções do README.

## decisoes

- 2026-09-26 (humano, lote de entrada): formato = seção por skill nos 2
  READMEs (descartados: `docs/skills.md` separado; seção só no EN).
- 2026-09-28 (IA): sem bump de versão — README não entra no runtime do plugin.
- 2026-09-28 (IA): /4 verificado por leitura cruzada com os SKILL.md no
  roteiro (não há teste mecânico honesto para "descreve só o que existe").
- 2026-09-28 (humano): escopo aprovado ("continue").

## delta

## e2e

pendente

## feedback-reprovacao
