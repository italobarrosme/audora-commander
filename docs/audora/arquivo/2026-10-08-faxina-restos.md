---
id: faxina-restos
estado: delivered
origem: humano
depende-de: []
arquivos: [CHANGELOG.md, MEMORY.md, PRD.md, README.md, README.pt-BR.md, docs/audora/arquivo/2026-08-25-grafo-v2.md, docs/audora/arquivo/2026-08-31-memory-fatiada-historico.md, docs/audora/arquivo/2026-08-31-memory-fatiada.md, docs/audora/arquivo/2026-09-04-gate-mecanico.md, docs/audora/arquivo/2026-09-27-limpeza-codigo-morto.md, docs/audora/arquivo/2026-09-27-memory-graphify.md, docs/audora/arquivo/2026-09-27-plugin-v0.1.0.md, docs/audora/arquivo/2026-09-29-remover-graphify.md, docs/audora/arquivo/2026-09-30-corte-sem-uso.md, docs/audora/decisoes-vivas.md, docs/fundamentos.md, docs/specs/2026-08-24-estudo-grafo-mercado.md, templates/bloco-fechamento-template.md, templates/fase-subagente-template.md, tests/test-carga.sh, tests/test-contexto-por-fase.sh, tests/test-corte-sem-uso.sh, tests/test-docs.sh, tests/test-dogfood.sh, tests/test-leitura-por-secao.sh, tests/test-memory-guard.sh, tests/test-memory-validate.sh, tests/test-parada-revisao.sh, tests/test-plano-mapa.sh, tests/test-session-start.sh, tests/test-skills.sh, tests/test-templates.sh]
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
  template maior: BASE 47741 → 53227 (teto 54900), FULL 55661 → 61147
  (teto 63000).
- 2026-10-08 (humano): o comando da PARADA que despacha o subagente passa a ser
  "agente" em todo lugar (template, PRD, READMEs, fundamentos, aprendizado
  do e2e) — "segue" sai; CHANGELOG e nós arquivados ficam como história.

## evidencia

- faxina-restos/1 — `git ls-files docs/specs` → só o spec de design.
- faxina-restos/2 — `git grep -i -l -e graphify -e consultar-codigo` → vazio
  (fica 1 menção no nó `memoria-integra`, de outra demanda, não versionado).
- faxina-restos/3 — `bash tests/run.sh` → exit 0, 0 falha, 1238 asserts
  (`6cc10cb`); suíte em worktree limpo do `75add24` → 0 falha;
  `hooks/cleanup varrer` → nada a limpar.
- Portão: humano mandou commitar (2026-10-08) e fechar ("fecha").
