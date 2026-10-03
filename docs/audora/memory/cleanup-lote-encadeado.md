---
id: cleanup-lote-encadeado
estado: in-progress
origem: humano
depende-de: [skill-cleanup]
arquivos: []
keywords: [cleanup, lote, link, git-rm, hotfix]
resumo: O aplicar da cleanup não falha quando um item do lote cita outro item do mesmo lote
atualizado-em: 2026-10-03
---

# cleanup-lote-encadeado

## objetivo

HOTFIX: o `aplicar` do `hooks/cleanup` aplica o lote mesmo quando um arquivo
apagado no lote cita outro arquivo apagado no mesmo lote. Hoje a troca de
link modifica o arquivo citador, o `git rm` dele recusa e o lote inteiro é
desfeito (achado ao rodar a cleanup neste repo em 2026-10-03).

## criterios-aceite

- **cleanup-lote-encadeado/1** — QUANDO o lote aprovado apaga um arquivo A e também um arquivo B que tem link para A O SISTEMA DEVE apagar A e B e fazer o commit do lote, em qualquer ordem dos itens no lote
- **cleanup-lote-encadeado/2** — QUANDO o lote aprovado apaga um arquivo A citado por um arquivo C fora do lote O SISTEMA DEVE continuar trocando o link de C pela nota "removido … recuperável no git", como antes
- **cleanup-lote-encadeado/3** — QUANDO o lote aprovado traz um link quebrado dentro de um arquivo que o mesmo lote apaga O SISTEMA DEVE apagar o arquivo e fazer o commit do lote sem falhar, em qualquer ordem dos itens no lote
- **cleanup-lote-encadeado/4** — QUANDO a cleanup roda neste repositório com o lote da varredura de 2026-10-03 (sem o item `MEMORY.md:94`) O SISTEMA DEVE aplicar o lote num commit só, com o `memory-validate` verde

## fora-de-escopo

- Falso positivo de link quebrado: caminho citado entre crases em prosa (ex.:
  aprendizado `MEMORY.md:94`) é tratado como link — candidato a nó próprio.
- A nota "recuperável no git" em link que já nasceu quebrado (ressalva do
  `skill-cleanup`, meta futura do `PRD.md`).

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
