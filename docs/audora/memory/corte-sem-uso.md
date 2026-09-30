---
id: corte-sem-uso
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [corte, autopilot, loop, worktree, graphify-limpeza, simplificacao, breaking]
resumo: Remover do plugin o que não tem uso medido — autopilot, motor de loop, skill worktree e graphify-limpeza (após limpar os 12 projetos).
atualizado-em: 2026-09-30
---

# corte-sem-uso

## objetivo

Simplificar o audora-commander removendo mecanismos sem uso medido.
Medição de 2026-09-30 em 112 sessões de 11 projetos que usam o plugin:
autopilot 0 usos, motor de loop (`hooks/loop`) 0 execuções, skill
`worktree` 2 invocações. `hooks/graphify-limpeza` só existe para limpar
restos do Graphify — os 12 projetos locais são limpos uma vez e o script
sai. Fundamentação: pesquisa de 2026-09-29 (contexto é orçamento; texto de
framework sem uso é contexto irrelevante; multi-agente em código sem ganho
medido).

## criterios-aceite

12 critérios EARS (`corte-sem-uso/1`–`/12`) na spec dedicada:
[../specs/corte-sem-uso-escopo.md](../specs/corte-sem-uso-escopo.md).

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

## delta

## e2e

pendente

## feedback-reprovacao
