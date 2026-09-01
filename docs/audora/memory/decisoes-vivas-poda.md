---
id: decisoes-vivas-poda
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [decisoes-vivas, poda, duplicacao, drift, regra-de-entrada]
resumo: Regra de entrada nova para decisoes-vivas.md (so entra o que nao da pra impor por teste/hook/config) e poda das entradas ja impostas ou mortas.
atualizado-em: 2026-09-01
---

# decisoes-vivas-poda

## objetivo

`docs/audora/decisoes-vivas.md` tem 17 entradas e cerca de metade e copia em
prosa de algo ja imposto por teste, hook ou config, ou esta morta (fala de uma
migracao removida na 0.4.0). O furo e a regra de entrada: o arquivo exige
"decisao que segue valendo", mas nao exige "decisao que NAO da pra impor por
teste". Prosa duplicada deriva do que ela descreve.

Escopo em spec dedicada (categoria HIGH): `docs/audora/specs/decisoes-vivas-poda-escopo.md`.

## criterios-aceite

<!-- Em docs/audora/specs/decisoes-vivas-poda-escopo.md (HIGH). -->

## fora-de-escopo

<!-- Na spec. -->

## decisoes

## delta

- MODIFICADO (2026-09-01): **/1** — de "já imposta por teste, hook ou config"
  para "já declarada normativamente, para o MESMO ESCOPO DE APLICAÇÃO, em
  artefato que o framework lê (teste, hook, config, template, Constituição ou
  SKILL.md)". Motivo: 2 entradas foram marcadas apontando `skills/e2e/SKILL.md`
  (prosa normativa, sem teste) — o critério antigo não cobria isso.
- MODIFICADO (2026-09-01): **/3** — acrescenta: artefato que declara a matéria
  FORA do próprio escopo NÃO é ponteiro válido. Motivo: `corte de tokens` foi
  apontada para `memory-fatiada`, que diz na linha 68 "/9 mede esta skill, não
  o framework" — ele se recusa a substituí-la.
- MODIFICADO (2026-09-01): **/4** — acrescenta o discriminador: a entrada FICA
  se a regra dela vale ALÉM do artefato que seria o ponteiro. Motivo: sem isso,
  `roteador + references` (regra para skills futuras) e `description em aspas
  simples` (regra imposta por assert) caem no mesmo balde.
- ADICIONADO (2026-09-01): **/8** — QUANDO uma decisão PUDER virar teste mas o
  teste ainda não existir O SISTEMA DEVE escrever o teste na mesma demanda OU
  manter a entrada até que exista; sumir em silêncio é proibido.
- ADICIONADO (2026-09-01): **/9** — QUANDO a suíte rodar O SISTEMA DEVE
  reprovar se `docs/audora/decisoes-vivas.md` não existir ou não tiver nenhuma
  entrada. Motivo: o guarda antigo dava verde com o arquivo APAGADO.
- ADICIONADO (2026-09-01): **/10** — QUANDO a suíte rodar O SISTEMA DEVE
  reprovar `substituido-por` vazio, apontando diretório, ou fora do par de
  colchetes. Motivo: `[substituido-por: ]` escapava dos dois guardas.

- REMOVIDO (2026-09-01): **/2**, **/3** e **/4** saem desta demanda para o nó
  `decisoes-vivas-auditoria`. Motivo: duas revisões adversariais reprovaram a
  AUDITORIA por erro de classificação, em conjuntos diferentes de entradas, e o
  diagnóstico é que o critério "já declarada normativamente" não é operável. A
  infraestrutura (regra na validate + guardas) fechou e é o que esta demanda
  entrega. As 8 marcações foram revertidas: `decisoes-vivas.md` voltou
  byte-idêntico ao estado pré-demanda (17 entradas, 0 marcadas).
- MODIFICADO (2026-09-01): o guarda de /6 e /10 deixa de ancorar em
  `[invalidado-em: 20` e passa a excluir o bloco de comentário HTML por `awk`.
  Motivo: a âncora `20` fechava o D4 mas abria o N1 — marcador com data
  não-`20xx`, e até a linha do rodapé copiada literal, escapavam do guarda.

## e2e

pendente

## feedback-reprovacao

Reprovada na revisão adversarial de 2026-09-01. Achados completos em
`decisoes-vivas-poda-historico.md` (mesma pasta); a ação está no `## delta`.
