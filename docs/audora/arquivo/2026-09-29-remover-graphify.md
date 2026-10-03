---
id: remover-graphify
estado: delivered
origem: humano
depende-de: []
arquivos: [.claude-plugin/marketplace.json, .claude-plugin/plugin.json, .gitignore, MEMORY.md, README.md, README.pt-BR.md, docs/audora/planos/plano-remover-graphify.md, docs/audora/specs/remover-graphify-escopo.md, docs/fundamentos.md, hooks/graphify-limpeza, hooks/graphify-status, hooks/session-start, skills/debug/SKILL.md, skills/execute/SKILL.md, skills/memory/SKILL.md, skills/memory/references/bootstrap.md, skills/memory/references/consultar-codigo.md, skills/plan/SKILL.md, skills/worktree/SKILL.md, templates/MEMORY-template.md, tests/lib.sh, tests/test-carga.sh, tests/test-docs.sh, tests/test-dogfood.sh, tests/test-graphify-limpeza.sh, tests/test-graphify-status.sh, tests/test-session-start.sh, tests/test-skills.sh, tests/test-templates.sh, docs/audora/decisoes-vivas.md, PRD.md]
keywords: [graphify, remocao, indice, consultar-codigo, breaking]
resumo: Remover o Graphify por completo do plugin — oferta, índice, consulta e status.
atualizado-em: 2026-09-29
---

# remover-graphify

## objetivo

Remover o Graphify por completo do audora-commander. Medição de 2026-09-29
nos 12 projetos que usam o plugin: 78 consultas ao índice contra 1.044 Read
e 181 Grep (~6% das buscas de código), e 10 de 41 checagens de status
davam `ausente` por PATH. Custo de reconstrução a cada commit sem retorno
proporcional.

## criterios-aceite

13 critérios EARS (`remover-graphify/1`–`/13`) na spec dedicada:
`docs/audora/specs/remover-graphify-escopo.md` removido em 2026-10-03 pela cleanup — recuperável no git.

## fora-de-escopo

Ver a spec: os 12 projetos locais, arquivos históricos, substituto de busca
e gravação da recusa.

## decisoes

- 2026-09-29 (IA): classificada HIGH — remove contrato consumido pelos
  projetos que usam o plugin (bullet `graphify:` da Constituição e
  post-commit instalado pelo bootstrap).
- 2026-09-29: decisões do scope (6 do humano, 4 da IA) na spec.
- 2026-09-29 (humano): autorizada a remoção de `tests/test-graphify-status.sh`
  na T6 (humano: "sim") — o script testado sai; detecção coberta por
  `tests/test-graphify-limpeza.sh`.
- 2026-09-29 (incidente): a revisão adversarial rodou `--remover` com o `uv`
  real no PATH e desinstalou o `graphifyy` da máquina sem autorização.
  Humano: não reinstalar. Teste de `--remover` só com `uv`/`pipx` falsos.
- 2026-09-29 (humano): portão final reprovado; correção A1–A5 aprovada com
  as correções sugeridas pela revisão — dispensa novo portão de plano
  para essa rodada.

- 2026-09-29 (humano): portão final APROVADO na 3ª passagem. Bloqueantes
  teóricos (husky `.husky/_`, `core.hooksPath` custom ou worktree ligado,
  hook inline antigo no settings) ausentes nos 12 projetos (levantamento só
  leitura) e fora da letra do /2 — viram meta futura. `.claude/CLAUDE.md` e
  `.claude/skills/graphify/` (só SellInfoTurbo) limpos à mão. Regra "nunca
  varrer o repo para entender" (saiu da execute e da memory) fica em aberto
  para conversa — não promover decisão viva sobre localização de código.

gate-asserts: queda aprovada no escopo (/13) — asserts de graphify-status, consultar-codigo, etapa Graphify do bootstrap e dogfood antigo saem com o comportamento; limpeza (/2–/8) coberta por tests/test-graphify-limpeza.sh.

## delta

## e2e

pulado-pelo-humano (2026-09-29: "pula o e2e passa so o validate")

## feedback-reprovacao

- 2026-09-29 (portão final, humano: reprovar e corrigir A1–A5). Gate
  passou (861 asserts), 10/13 critérios passaram; /4, /5, /10 refutados
  pela revisão adversarial, reproduzidos em fixture:
  - A1 (/5): filtro do settings age no GRUPO — apaga hook alheio do mesmo
    grupo; substring `graphify` em comando alheio (`rm -rf
    old-graphify-backup`) dá falso positivo. Filtrar por
    `hooks[].command` casando `^graphify\b`.
  - A2 (/5): seção `## graphify` do CLAUDE.md só termina em `^## ` — H1
    seguinte é apagado. Parar em `^#{1,2} `.
  - A3 (/5): hook de git com marcador start sem end perde tudo até o fim
    do arquivo. Sem end → `falhou` com comando à mão, arquivo intocado.
  - A4 (/4): arquivo versionado removido (pasta `graphify-out/`, hook em
    `core.hooksPath` versionado) não sai como `versionado`. Relatar pelo
    `git status --porcelain`.
  - A5 (/10): `skills/worktree/SKILL.md` item 4 "Índice de código" ainda
    cita reindexar/degradar. Remover e guardar no assert do /9.
  - Menores baratos na mesma rodada: preservar CRLF e newline final; não
    reescrever settings que não tem hook do Graphify e não normalizar
    números; bullet `graphify:` casado só dentro da Constituição;
    diretório inexistente coerente com o cabeçalho do script.

- 2026-09-29 (2º portão final, humano: "A" — reprovar e corrigir). Gate
  passou (898 asserts); A1–A5 e menores da 1ª rodada confirmados
  corrigidos. Refutados de novo /2, /4, /5:
  - B1 (bloqueante): filtro `^\s*graphify\b` do settings não casa o
    formato REAL do Graphify — `"\"C:\Users\...\.local\bin\graphify.EXE\"
    hook-guard search"` (caminho absoluto entre aspas); também escapam
    `/usr/local/bin/graphify ...` e `uvx graphify ...`. Casar o binário
    `graphify` (`.exe`/`.EXE`, qualquer caixa) no primeiro token, com ou sem
    aspas e caminho; fixture com o formato real.
  - Falso positivo: `graphify-backup.sh` casa `^graphify\b` e vira resto.
  - M1 (/5): comentário do Graphify acima de `graphify-out/` no
    `.gitignore` fica órfão.
  - M2 (/5): `## graphify` dentro de bloco de código cercado no CLAUDE.md
    apaga até o fim do arquivo — ignorar cabeçalho dentro de cerca.
  - M3 (/3): pacote no uv E no pipx — só o do uv é removido; remover dos
    dois.
  - M4 (/6): `Permission denied` vaza no stderr; relatar só pela linha
    `falhou`.
  - Cosmético (/4): nome não-ASCII com escape octal — `-c
    core.quotePath=false`.
