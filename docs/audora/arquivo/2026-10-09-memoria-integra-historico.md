# memoria-integra — histórico frio

> Decisões do scope (2026-10-08), movidas do nó pela compactação (passo 4)
> antes da Tarefa 14. Seguem válidas.

## decisoes

- 2026-10-08 (humano): 12 pontos → 3 demandas, esta primeiro. Descartado: demanda única HIGH (portão gigante).
- 2026-10-08 (humano): critérios de HIGH sempre no nó; spec só contexto —
  esta demanda já segue isso, sem spec. Descartado: spec copiada no sync
  (duas cópias vivas); spec nunca apagada (critério fora da memória).
- 2026-10-08 (humano): não reparar arquivados; "nó primeiro, índice depois"
  ao criar e transicionar. Descartado: reparo; índice primeiro na criação.
- 2026-10-08 (humano): cleanup só apaga o que não é mais usado (/4, /12,
  /13). Plano arquivado e relatório e2e de nó entregue seguem saindo, salvo
  se citam critério ausente do nó.

## delta consolidado (sync 2026-10-09)

> Já aplicado no corpo do nó; registro de rastreabilidade.

- REMOVIDO (2026-10-08): /8–/11 (aviso > 40, compactação, histórico, ≤ 40 no repo) — humano não quer compactação.
- MODIFICADO (2026-10-08): /12 `aprendizados-historico.md` → `aprendizados.md`; fora-de-escopo sem a busca no histórico.
- ADICIONADO (2026-10-08): /14–/21. Já aplicado no corpo pela reabertura do scope, antes do plano.
- MODIFICADO (2026-10-08, plan): /18 perde a prova de linhas de ferramenta já removida — só "MEMORY sem aprendizado, todos em `docs/audora/aprendizados.md`".
- MODIFICADO (2026-10-08, validate): "critério numerado" = `<id>/<n>` → linha `- **<id>/<n>** — …`.
