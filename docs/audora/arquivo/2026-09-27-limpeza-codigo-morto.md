---
id: limpeza-codigo-morto
estado: delivered
origem: humano
depende-de: []
arquivos: [.claude-plugin/, MEMORY.md, PRD.md, README.md, README.pt-BR.md, docs/fundamentos.md, docs/audora/decisoes-vivas.md, docs/audora/arquivo/, docs/audora/planos/arquivo/, docs/audora/e2e/e2e-limpeza-codigo-morto.md, docs/audora/specs/limpeza-codigo-morto-escopo.md, hooks/memory-validate, skills/audora-commander/SKILL.md, skills/memory/SKILL.md, templates/MEMORY-template.md, templates/no-template.md, tests/]
keywords: [limpeza, codigo-morto, legado, grafo, federacao, fundamentos, breaking]
resumo: Remove legado GRAFO, federação reservada e nós travados; alinha fundamentos à nomenclatura atual.
atualizado-em: 2026-09-27
---

# limpeza-codigo-morto

## objetivo

Tirar da superfície do plugin todo resto de compatibilidade com versões
anteriores e todo código especulativo, e alinhar memória e docs ao estado
real. Breaking change aceito sem comunicação (adesão pequena, ninguém
impactado).

## criterios-aceite

Spec dedicada (HIGH): `../specs/limpeza-codigo-morto-escopo.md` — 9
critérios `limpeza-codigo-morto/1..9`.

## fora-de-escopo

Ver spec: arquivos históricos, tokens e README (nós próprios), comunicar
breaking, versionar roadmap.

## decisoes

- 2026-09-26 (humano): breaking change NÃO é reportado — sem seção de
  renomeação, sem aviso de versão anterior.
- 2026-09-26 (humano, lote de entrada): entram legado GRAFO inteiro, fechar
  nós travados, remover federação `chave:id`, atualizar `fundamentos.md`.
  Federação muda schema → categoria HIGH.
- 2026-09-26 (humano): demanda original decomposta em 3 — esta,
  `otimizacao-tokens` e `readme-skills` (nessa ordem); cadência normal, sem
  autopilot.
- 2026-09-26 (humano, lote do escopo): fundamentos = nomes + mecânica;
  guarda anti-GRAFO removida; roadmap sai do PRD. Detalhe na spec.
- 2026-09-27 (humano): portão de escopo aprovado ("continue"), incluindo as
  2 decisões da IA (bump 0.8.0 só aqui; contagem de skills migra para
  `test-skills.sh`).
- 2026-09-27 (humano): portão de plano aprovado ("pode seguir").
- 2026-09-27 (humano, parada fora de portão): T2 commitada com o gate
  reprovando por UM motivo — `arquivo de teste apagado:
  tests/test-no-grafo.sh` (remoção aprovada no escopo; o gate não tem válvula
  para arquivo apagado). Descartados: criar válvula `gate-apagados:`; manter
  o arquivo morto. Suíte verde (548 asserts).
- 2026-09-27 (IA): exceção declarada ao grep do done da T2 — `grafo-v2` em
  `tests/test-dogfood.sh` é id de nó arquivado (história imutável), não
  guarda.
- 2026-09-27 (humano): portão final aprovado ("continue") — inclui a ressalva do e2e (fixB), a decisão viva proposta e o merge local na main.

gate-asserts: queda aprovada no escopo (/3) — guarda anti-GRAFO (test-no-grafo.sh) e asserts de migração removidos; comportamento vivo reescrito sem nome legado.

## delta

## e2e

relatorio: ../e2e/e2e-limpeza-codigo-morto.md (2026-09-27; 2 corridas `claude -p` com 0.8.0 do cache; /1 passou, borda com arquivo antigo passou com ressalva)

## feedback-reprovacao
