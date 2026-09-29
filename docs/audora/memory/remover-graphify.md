---
id: remover-graphify
estado: in-progress
origem: humano
depende-de: []
arquivos: []
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
[../specs/remover-graphify-escopo.md](../specs/remover-graphify-escopo.md).

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

gate-asserts: queda aprovada no escopo (/13) — asserts de graphify-status, consultar-codigo, etapa Graphify do bootstrap e dogfood antigo saem com o comportamento; limpeza (/2–/8) coberta por tests/test-graphify-limpeza.sh.

## delta

## e2e

pulado-pelo-humano (2026-09-29: "pula o e2e passa so o validate")

## feedback-reprovacao
