---
id: cleanup-lote-encadeado
estado: delivered
origem: humano
depende-de: [skill-cleanup]
arquivos: [CHANGELOG.md, MEMORY.md, PRD.md, hooks/cleanup, tests/test-skill-cleanup.sh, docs/audora/arquivo/*, docs/audora/specs/*, docs/audora/planos/arquivo/*, docs/audora/e2e/*, docs/audora/depuracao/*]
keywords: [cleanup, lote, link, git-rm, hotfix]
resumo: O aplicar da cleanup não falha quando um item do lote cita outro item do mesmo lote
atualizado-em: 2026-10-03
---

# cleanup-lote-encadeado

## objetivo

HOTFIX: o `aplicar` do `hooks/cleanup` aplica o lote mesmo quando um arquivo
apagado no lote cita outro arquivo apagado no mesmo lote. Antes, a troca de
link modificava o arquivo citador, o `git rm` dele recusava e o lote inteiro
era desfeito (achado ao rodar a cleanup neste repo em 2026-10-03). Agora o
arquivo que sai no lote não recebe troca de link.

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

- 2026-10-03 (IA): /3 mantido como guarda, embora o `varrer` nunca o gere (já pula link de arquivo que sai no lote) — só lote montado à mão traz o caso.
- 2026-10-03 (IA): o commit da cleanup real (`5474530`, 62 itens: 57 arquivos removidos + 5 links trocados pela nota) entrou na mesma branch, como evidência do /4; `arquivos:` lista os removidos por pasta.
- 2026-10-03 (humano): portão aprovado; o /4 conta como e2e.

## delta

## e2e

pulado-pelo-humano (o /4 — cleanup real neste repo — fez as vezes do e2e)

## feedback-reprovacao
