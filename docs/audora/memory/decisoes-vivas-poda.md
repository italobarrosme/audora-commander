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

## e2e

pendente

## feedback-reprovacao
