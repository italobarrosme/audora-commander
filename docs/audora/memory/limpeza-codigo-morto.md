---
id: limpeza-codigo-morto
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [limpeza, codigo-morto, legado, grafo, federacao, fundamentos, breaking]
resumo: Remove legado GRAFO, federação reservada e nós travados; alinha fundamentos à nomenclatura atual.
atualizado-em: 2026-09-26
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

Ver spec: arquivos históricos, tokens e README (nós próprios), instalar
Graphify, comunicar breaking, versionar roadmap.

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

## delta

## e2e

pendente

## feedback-reprovacao
