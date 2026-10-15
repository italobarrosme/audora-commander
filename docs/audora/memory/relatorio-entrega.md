---
id: relatorio-entrega
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [relatorio, entrega, bloco-fechamento, validate, chat, markdown]
resumo: Relatório de entrega estruturado no chat, deixando claro a demanda pedida e o que foi entregue.
atualizado-em: 2026-10-15
---

# relatorio-entrega

## objetivo

Ao decidir o portão final, a validate imprime no chat um relatório de entrega
em Markdown por seções que deixe claro ao humano qual foi a demanda (objetivo
do nó) e o que foi de fato entregue, critério a critério, com evidência,
mudanças de rota, decisões da IA, como conferir e arquivos tocados.

Categoria: MEDIUM (nenhum SIM de risco; saída de conversa, não dado persistido).

## criterios-aceite

- **relatorio-entrega/1** — QUANDO o portão final da validate for decidido
  (aprovado, parcial ou reprovado), em QUALQUER categoria (LIGHT, MEDIUM,
  HIGH, HOTFIX) O SISTEMA DEVE imprimir no chat o relatório de entrega com as
  seções nesta ordem: Demanda · Mudanças no caminho · Entregue · Evidência ·
  Como conferir · Decisões tomadas pela IA · Arquivos tocados
- **relatorio-entrega/2** — QUANDO o relatório for impresso O SISTEMA DEVE
  abrir com a seção Demanda trazendo categoria, total de critérios e o
  objetivo copiado do campo `objetivo` do nó (1-2 frases), nunca reescrito de
  memória
- **relatorio-entrega/3** — QUANDO o relatório for impresso O SISTEMA DEVE
  listar em Entregue uma linha por critério do nó (TODOS), com o endereço
  `<id>/<n>`, o veredito (✅ entregue, ⏳ pendente ou ❌ reprovado) e o
  comportamento em linguagem de usuário ("o sistema agora ...")
- **relatorio-entrega/4** — QUANDO o relatório for impresso O SISTEMA DEVE
  trazer a tabela Evidência com uma linha por critério: comando executado
  nesta sessão + resultado em 1 linha, ou link para o teste com âncora de
  linha; critério ⏳ ou ❌ leva o motivo no lugar da evidência
- **relatorio-entrega/5** — QUANDO o nó tiver entradas em `## delta` O
  SISTEMA DEVE imprimir Mudanças no caminho com uma linha por entrada
  (ADICIONADO / MODIFICADO antes → depois / REMOVIDO + motivo); QUANDO não
  houver delta O SISTEMA DEVE omitir a seção
- **relatorio-entrega/6** — QUANDO houver decisões de implementação tomadas
  pela IA na demanda O SISTEMA DEVE listá-las em Decisões tomadas pela IA,
  uma linha por decisão; QUANDO não houver O SISTEMA DEVE omitir a seção
- **relatorio-entrega/7** — QUANDO o relatório for impresso O SISTEMA DEVE
  trazer Como conferir com ≥ 1 item: comando em code block ` ```text ` (botão
  de copiar) ou tela/rota a abrir, cada um ligado ao critério que confere
- **relatorio-entrega/8** — QUANDO o relatório for impresso O SISTEMA DEVE
  fechar com Arquivos tocados tirado do `git diff --numstat` real da demanda
  (arquivo, +, −, total somado da saída), link clicável para arquivo
  existente e arquivo removido sem link
- **relatorio-entrega/9** — QUANDO o portão reprovar ou aprovar parcialmente
  O SISTEMA DEVE imprimir o relatório mesmo assim, com veredito por critério,
  e o Próximo do bloco de fase apontando a decisão humana ou a fase de
  retorno — nunca omitir o relatório
- **relatorio-entrega/10** — QUANDO um dado do relatório não tiver fonte
  lida nesta sessão (nó, saída de comando, diff) O SISTEMA DEVE marcar a
  célula como `[SEM FONTE]` e o critério ligado como ⏳, nunca preencher de
  memória
- **relatorio-entrega/11** — QUANDO o relatório for impresso O SISTEMA DEVE
  ser a última parte da resposta do turno, sem chamada de ferramenta depois
  (prosa ≥ 200 chars entre ferramentas vira narração — aprendizado
  2026-10-12)

## fora-de-escopo

Seção "Fora de escopo / não entregue" no relatório (humano descartou);
roteiro de validação do portão (item 3 da validate) segue livre; relatório
como arquivo versionado ou dentro de nó, CHANGELOG, PRD; medição
antes/depois; blocos de fechamento das outras fases; hook que imponha o
formato; onde as decisões da IA são armazenadas durante a demanda (nó
contratos-de-texto); encolher o template (cerimonia-enxuta).

## decisoes

- 2026-10-15 (humano): relatório sai só após a decisão do portão. Descartado: no portão como roteiro; nos dois momentos (duplicação).
- 2026-10-15 (humano): layout em seções verticais. Descartado: tabela pedido × entregue; compacto.
- 2026-10-15 (humano): seções extras = Decisões tomadas pela IA, Como conferir, Mudanças no caminho. Descartado: Fora de escopo.
- 2026-10-15 (humano): parcial e reprovação também imprimem, veredito por critério. Descartado: só com tudo aprovado.
- 2026-10-15 (IA, escopo): seções condicionais (Mudanças, Decisões) omitidas quando vazias; Como conferir sempre.
- 2026-10-15 (IA, escopo): onde o formato vive (template vs reference da validate) é do plan; restrição: carga BASE pinada em `tests/test-carga.sh`.
- 2026-10-15 (IA, plan): guardas de carga pinadas (BASE/FULL em tests/test-carga.sh e test-parada-revisao.sh; validate 6139 → 6300) sobem no commit que as cresce — o relatório entra no template da BASE por decisão humana de layout em seções.

## delta

## e2e

pendente

## feedback-reprovacao
