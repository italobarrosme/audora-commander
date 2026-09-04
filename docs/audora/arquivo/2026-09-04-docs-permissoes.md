---
id: docs-permissoes
estado: delivered
origem: humano
depende-de: []
arquivos: [README.md, README.pt-BR.md, tests/test-docs.sh, MEMORY.md]
keywords: [docs, readme, permissoes, permission-prompts, loop-engineering]
resumo: READMEs (EN+PT) ganham seção sobre reduzir prompts de permissão do harness com as três opções e o risco de cada uma.
atualizado-em: 2026-09-04
---

# docs-permissoes

## objetivo

Tirar da conta do framework a dor que não é dele: documentar nos READMEs
(EN + PT) como reduzir os prompts de permissão do harness — `permissions.allow`
em `settings.json`, `--permission-mode acceptEdits` e `bypassPermissions` só em
sandbox ou worktree descartável — com o nível de risco de cada opção e o aviso
do loop engineering (regra no prompt é pedido; bloqueio real é permissão).
D0 do roadmap `docs/specs/2026-09-02-loop-engineering-roadmap.md`.

## criterios-aceite

- **docs-permissoes/1** — QUANDO o leitor procurar "permission" no `README.md`
  (EN) O SISTEMA DEVE apresentar uma seção sobre reduzir prompts de permissão
  com as três opções (`permissions.allow` em `settings.json`,
  `--permission-mode acceptEdits`, `bypassPermissions`) e o nível de risco de
  cada uma
- **docs-permissoes/2** — QUANDO o leitor procurar "permission" no
  `README.pt-BR.md` (PT) O SISTEMA DEVE apresentar a mesma seção espelhada em
  português, com as mesmas três opções e riscos
- **docs-permissoes/3** — QUANDO a seção apresentar `bypassPermissions` O
  SISTEMA DEVE restringir o uso a sandbox ou worktree descartável e incluir o
  aviso do loop engineering: regra no prompt é pedido; bloqueio real é
  permissão

## fora-de-escopo

Qualquer mudança em skill ou hook; o framework configurar permissões do
harness por conta própria; as demais demandas do roadmap (D1..D4).

## decisoes

- 2026-09-04 (humano): roadmap de loop engineering aprovado como ordem de
  trabalho; D0 aberta primeiro (sem dependência, alívio imediato).
- 2026-09-04 (IA): seção posicionada após "Usage flow"/"Fluxo de uso" nos dois
  READMEs; risco em tabela com inline code, sem bloco de código novo — o
  teste `/19` exige blocos EN/PT byte-idênticos e tabela não paga esse custo.
- 2026-09-04 (IA): asserts de conteúdo adicionados a `tests/test-docs.sh`
  (arquivo existente de docs), não em arquivo de teste novo.
- 2026-09-04 (validate): PRD não muda — seção nova de README não é
  comportamento que o PRD descreve.

## delta

## e2e

não ofertado — LIGHT interno (doc pura, sem caminho de usuário); regra do
Fechamento LIGHT da validate. Aprovado no portão em 2026-09-04.

## feedback-reprovacao
