---
id: corte-sem-uso
estado: delivered
origem: humano
depende-de: []
arquivos: [.claude-plugin/marketplace.json, .claude-plugin/plugin.json, MEMORY.md, PRD.md, README.md, README.pt-BR.md, docs/audora/decisoes-vivas.md, docs/audora/e2e/e2e-corte-sem-uso.md, docs/audora/e2e/limpeza-graphify-projetos.md, docs/audora/planos/plano-corte-sem-uso.md, docs/audora/specs/corte-sem-uso-escopo.md, docs/fundamentos.md, hooks/graphify-limpeza, hooks/loop, hooks/session-start, skills/audora-commander/SKILL.md, skills/e2e/SKILL.md, skills/execute/SKILL.md, skills/memory/SKILL.md, skills/plan/SKILL.md, skills/scope/SKILL.md, skills/validate/SKILL.md, skills/validate/references/fechamento-light.md, skills/worktree/SKILL.md, templates/bloco-fechamento-template.md, templates/fase-subagente-template.md, templates/loop-prompt-template.md, templates/no-template.md, tests/lib.sh, tests/test-autopilot.sh, tests/test-carga.sh, tests/test-contexto-por-fase.sh, tests/test-corte-sem-uso.sh, tests/test-docs.sh, tests/test-dogfood.sh, tests/test-graphify-limpeza.sh, tests/test-loop.sh, tests/test-session-start.sh, tests/test-skills.sh, tests/test-templates.sh, tests/test-worktree.sh]
keywords: [corte, autopilot, loop, worktree, graphify-limpeza, simplificacao, breaking]
resumo: Remover do plugin o que não tem uso medido — autopilot, motor de loop, skill worktree e graphify-limpeza (após limpar os 13 projetos locais com resto).
atualizado-em: 2026-09-30
---

# corte-sem-uso

## objetivo

Simplificar o audora-commander removendo mecanismos sem uso medido.
Medição de 2026-09-30 em 112 sessões de 11 projetos que usam o plugin:
autopilot 0 usos, motor de loop (`hooks/loop`) 0 execuções, skill
`worktree` 2 invocações. `hooks/graphify-limpeza` só existe para limpar
restos do Graphify — os projetos locais com resto (13 de 15) são limpos uma vez e o script
sai. Fundamentação: pesquisa de 2026-09-29 (contexto é orçamento; texto de
framework sem uso é contexto irrelevante; multi-agente em código sem ganho
medido).

## criterios-aceite

12 critérios EARS (`corte-sem-uso/1`–`/12`) na spec dedicada:
`docs/audora/specs/corte-sem-uso-escopo.md` removido em 2026-10-03 pela cleanup — recuperável no git.

## fora-de-escopo

Ver a spec: plano-mapa, localização, PRD-foto, parada da revisão, régua
de categoria, históricos, commit nos projetos limpos.

## decisoes

- 2026-09-30 (IA): classificada HIGH — remove contrato (skill `worktree`,
  campo `autopilot:` do nó, motor de loop) e tem efeito irreversível fora
  do repo (hooks de git não versionados dos 12 projetos).
- 2026-09-30 (IA): uma demanda só, não três — mesmo tema (remover sem uso),
  proposta aprovada pelo humano assim.
- 2026-09-30 (humano): escopo aprovado ("aprovado") — autoriza apagar
  `tests/test-graphify-limpeza.sh`, `tests/test-loop.sh`,
  `tests/test-autopilot.sh` e `tests/test-worktree.sh` (/11).
- 2026-09-30 (humano): autorizada a limpeza dos 13 projetos pelo comando
  `bash "$SCRATCH/limpeza-projetos.sh" "$SCRATCH" --remover`.
- gate-asserts: queda aprovada no escopo (/11) — asserts de test-graphify-limpeza, test-loop, test-autopilot e test-worktree saem com o comportamento removido; ausência guardada por tests/test-corte-sem-uso.sh.
- 2026-09-30 (humano): portão final APROVADO ("aprovar") — e2e 12/12, revisão adversarial sem bloqueante; ressalvas (guardas de /5 e /11 enganáveis por variação de texto, gate compara contra HEAD) aceitas como estão. Decisões vivas aprovadas como propostas: invalidar as 3 `skill-worktree`; promover "corte inteiro de mecanismo sem uso" e "apagar teste exige autorização no scope".

## medicao

Bytes (blobs LF). skills: 74760 → 58010; templates: 26128 → 23626;
test-carga BASE 51800 → 46575, FULL 57040 → 51815. Saíram skills/worktree
(1 skill), hooks/loop, hooks/graphify-limpeza,
templates/loop-prompt-template.md.

## delta

## e2e

passou (2026-09-30) — 12/12 critérios; relatório `docs/audora/e2e/e2e-corte-sem-uso.md` removido em 2026-10-03 pela cleanup — recuperável no git. Plugin via `--plugin-dir` (cache global intocado, escolha do humano).

## feedback-reprovacao
