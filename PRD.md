# PRD — audora-commander

> Última atualização: 2026-08-14

## O que é e para que serve

Plugin de Claude Code (padrão Superpowers) que implementa um framework de
desenvolvimento de software assistido por IA, guiado por 5 Princípios de AI
Coding: mapa dinâmico de requisitos (GRAFO vivo), planejamento just-in-time,
separação "O Quê"/"Como", processo proporcional ao risco da demanda, e IA
executa / humano decide. Público-alvo: dev solo ou time pequeno construindo
web/mobile/api com Claude Code.

## Stack

- Markdown (skills, templates, docs) + JSON (plugin.json, marketplace.json,
  hooks.json). Sem código executável.
- Formato de plugin do Claude Code: `.claude-plugin/` + `skills/` + `hooks/`.

## Arquitetura

8 skills encadeadas por um roteador central:

- `audora-commander` — porta de entrada: classifica demanda (LEVE / MÉDIA /
  ALTA / HOTFIX) por perguntas binárias de risco e roteia pelas fases.
- `grafo` — mantém GRAFO.md (memória externa do produto): schema de nó,
  constituição, bootstrap brownfield, delta/sync.
- `escopo` — fase "O Quê": critérios EARS, marcador [PRECISA-CLARIFICAR].
- `plano` — fase "Como" just-in-time: plano-arquivo com tarefas autossuficientes.
- `executar` — TDD red-green com evidência real; commit por etapa verde.
- `e2e` — levanta o projeto e exercita a demanda de ponta a ponta (opcional,
  fortemente recomendada).
- `validar` — portão humano final: evidência 1:1 com critérios, sync
  GRAFO → PRD no merge.
- `depurar` — debug com causa raiz demonstrada (modo sintoma) ou caçada de
  defeitos por classes com verificação de cada achado (modo caçada).

Hook SessionStart injeta ponteiro curto para a porta de entrada.

Documentos de referência: `docs/fundamentos.md` (fundamentos v2 dos princípios)
e `docs/specs/2026-08-14-audora-commander-design.md` (spec de design).

## Estado atual

v0.1.0 implementada (2026-08-14) — 8 skills (7 originais + `depurar` em
2026-08-15), hook SessionStart, templates canônicos, marketplace local, README
com checklist, GRAFO.md do próprio repo (dogfooding). Verificações estruturais
e de JSON verdes; caçada de defeitos executada com a skill depurar. Aguardando
validação de instalação pelo usuário em sessão interativa (checklist no
README).

## Metas futuras de implementação

1. v0.1.0: 8 skills + hook + templates + marketplace local + README com
   checklist de validação (spec §6 + adendo).
2. Dry-run completo de uma demanda LEVE e uma MÉDIA em projeto de exemplo.
3. Futuro (fora do v0.1.0): porte para outros harnesses, marketplace público,
   agentes dedicados.
