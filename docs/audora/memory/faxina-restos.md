---
id: faxina-restos
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [faxina, limpeza, historico, sem-uso]
resumo: Apagar do repo o que não é usado — estudo parado em docs/specs e toda menção à antiga ferramenta externa de índice de código.
atualizado-em: 2026-10-08
---

# faxina-restos

## objetivo

Apagar do repo o que não é usado: o estudo de mercado parado em `docs/specs/`
e toda menção à antiga ferramenta externa de índice de código (removida do
plugin na 0.10.0) — guardas de teste, PRD, aprendizados invalidados, nós
arquivados da ferramenta, CHANGELOG e menções soltas nos demais nós.

## criterios-aceite

- **faxina-restos/1** — QUANDO a faxina terminar O SISTEMA DEVE não ter
  arquivo versionado sem uso em `docs/specs/` além do spec de design
  (citado por PRD e READMEs)
- **faxina-restos/2** — QUANDO a faxina terminar O SISTEMA DEVE não ter
  nenhuma menção à ferramenta (nome, operação de consulta, nós dela) em
  arquivo versionado fora de `docs/audora/memory/` de outra demanda
- **faxina-restos/3** — QUANDO a faxina terminar O SISTEMA DEVE passar a
  suíte, o `memory-validate` no índice e a cleanup sem link quebrado novo

## fora-de-escopo

spec de design `docs/specs/2026-08-14-audora-commander-design.md` (humano:
fica); arquivos locais fora do git (`docs/study/`,
`docs/specs/2026-09-02-loop-engineering-roadmap.md`); nó `memoria-integra`
(outra demanda em andamento).

## decisoes

- 2026-10-08 (humano): apagar tudo sobre a ferramenta, inclusive nós
  arquivados (com a única cópia dos critérios da HIGH que a removeu) e o
  CHANGELOG — reescrever o histórico foi escolha explícita.
- gate-asserts: queda autorizada pelo humano em 2026-10-08 — saem as guardas
  de ausência da ferramenta (test-corte-sem-uso, test-docs, test-skills,
  test-session-start, test-templates, test-dogfood); asserts de comportamento
  vivo nas mesmas linhas ficam, só com rótulo novo.
- 2026-10-08 (humano): os templates `bloco-fechamento` (formato para o
  painel do VS Code) e `fase-subagente` ("agente" na PARADA, regra 6) são a
  verdade — os testes acompanham o texto novo. Teto da carga sobe pelo
  template maior: BASE 47741 → 53226 (teto 54900), FULL 55661 → 61146
  (teto 63000).
