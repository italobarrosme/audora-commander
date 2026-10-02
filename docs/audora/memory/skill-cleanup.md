---
id: skill-cleanup
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [limpeza, faxina, arquivo, skill]
resumo: Skill nova que acha e remove nós planned órfãos, specs de nós entregues e arquivo morto, em qualquer projeto
atualizado-em: 2026-10-02
---

# skill-cleanup

## objetivo

Skill nova `cleanup`, invocada pelo humano em qualquer projeto com MEMORY,
que varre o que sobrou do processo (nós planned órfãos, artefatos de nós
entregues, arquivo sem referência e links quebrados), apresenta um relatório
e, com aprovação, remove tudo num commit só, revertível por `git revert`.

## criterios-aceite

- **skill-cleanup/1** — QUANDO o humano invoca a cleanup num projeto com `MEMORY.md` O SISTEMA DEVE apresentar um relatório agrupado por tipo (planned órfão, spec de nó entregue, plano arquivado, relatório e2e, depuração velha, sem referência, link quebrado), cada item com caminho e motivo em 1 linha, sem alterar nenhum arquivo antes da aprovação
- **skill-cleanup/2** — QUANDO o projeto não tem `MEMORY.md` O SISTEMA DEVE recusar a varredura, apontar o bootstrap da skill memory e não alterar nada
- **skill-cleanup/3** — QUANDO um nó planned tem objetivo já entregue ou absorvido por um nó delivered O SISTEMA DEVE listá-lo como planned órfão, citando o nó que o absorveu
- **skill-cleanup/4** — QUANDO um nó planned cita skill, arquivo ou feature que não existe mais no repo O SISTEMA DEVE listá-lo como planned órfão, citando o alvo ausente
- **skill-cleanup/5** — QUANDO um planned órfão está no `depende-de` de outro nó não arquivado O SISTEMA DEVE deixá-lo fora do lote e reportar "mantido: <dependente> depende dele"
- **skill-cleanup/6** — QUANDO o humano aprova a remoção de um planned órfão O SISTEMA DEVE apagar a linha dele do índice e, se existir, o arquivo do nó em `docs/audora/memory/`
- **skill-cleanup/7** — QUANDO existe spec de escopo, plano arquivado ou relatório e2e de nó delivered, ou relatório de depuração sem nó vivo ligado O SISTEMA DEVE listá-lo no tipo correspondente
- **skill-cleanup/8** — QUANDO um arquivo de `docs/audora/` não é referenciado por nenhum documento vivo (índice, nós de `docs/audora/memory/`, decisões vivas, skills, PRD, READMEs; nós arquivados não contam) O SISTEMA DEVE listá-lo como sem referência
- **skill-cleanup/9** — QUANDO o humano aprova a remoção de um arquivo O SISTEMA DEVE apagá-lo e trocar todo link que apontava para ele pela nota "`<caminho>` removido em AAAA-MM-DD pela cleanup — recuperável no git"
- **skill-cleanup/10** — QUANDO a varredura acha em `MEMORY.md` ou `docs/audora/` um link para arquivo inexistente O SISTEMA DEVE listá-lo como link quebrado e, aprovado, trocá-lo pela mesma nota
- **skill-cleanup/11** — QUANDO um candidato está fora do git (untracked ou ignorado) ou tem mudança não commitada O SISTEMA DEVE deixá-lo fora do lote e reportá-lo como "não tocado: fora do git" ou "não tocado: mudança não commitada"
- **skill-cleanup/12** — QUANDO o relatório é apresentado O SISTEMA DEVE esperar aprovação explícita do lote, aceitar que o humano tire itens e, se ele reprovar ou tirar todos, não alterar nada nem commitar
- **skill-cleanup/13** — QUANDO o lote aprovado é aplicado O SISTEMA DEVE fazer 1 commit só com os caminhos do lote, com mensagem listando o que saiu por tipo, e deixar o MEMORY válido no schema (índice↔pasta, `depende-de`)
- **skill-cleanup/14** — QUANDO uma alteração do lote falha no meio O SISTEMA DEVE parar antes do commit, desfazer o que já aplicou (árvore volta ao estado de antes do lote) e reportar o item que falhou
- **skill-cleanup/15** — QUANDO a varredura não acha nada O SISTEMA DEVE dizer "nada a limpar" e não commitar
- **skill-cleanup/16** — QUANDO o sync da validate termina e há ≥1 sobra que a cleanup listaria O SISTEMA DEVE sugerir em 1 linha rodar a cleanup, com a contagem, sem executá-la

## fora-de-escopo

- Nós em `docs/audora/arquivo/` (entregues/descartados) e o legado nunca são
  removidos; só recebem a nota no lugar de links.
- Aprendizados e decisões vivas invalidados: poda é da operação compactar.
- Arquivos fora de `docs/audora/` (código, `docs/specs/`, `docs/study/`)
  nunca entram como sem referência.
- Remoção de arquivo fora do git ou com mudança não commitada.
- Execução automática: a validate só sugere.
- Planned parado por tempo, e divergência índice↔pasta (já é do
  `memory-validate`).
- Rodar a limpeza no próprio repo audora-commander: passo pós-entrega, fora
  do nó.

## decisoes

- 2026-10-02 (porta de entrada): classificada MEDIUM — nenhuma pergunta de
  risco deu sim; skill nova com lógica nova em múltiplos arquivos. Se o
  escopo permitir remoção fora do git (irreversível), sobe para HIGH.
- 2026-10-02 (humano): planned órfão = absorvido/superado OU alvo sumiu.
  Descartados: parado há N dias, divergência índice↔pasta.
- 2026-10-02 (humano): spec de nó entregue é apagada com nota no link.
  Descartados: mover para `arquivo/`, incorporar no nó.
- 2026-10-02 (humano): arquivo morto = planos arquivados + relatórios e2e de
  delivered + depuração sem nó vivo + qualquer arquivo de `docs/audora/` sem
  referência viva.
- 2026-10-02 (humano): relatório + aprovação em lote, com retirada de itens.
  Descartados: item a item, só relatório.
- 2026-10-02 (humano): planned órfão tem a linha APAGADA do índice.
  Descartado: virar discarded com motivo; o histórico fica no git.
- 2026-10-02 (humano): fora do git ou sujo → pula e avisa. Mantém a demanda
  MEDIUM. Descartados: incluir com aviso (HIGH), recusar rodar.
- 2026-10-02 (humano): gatilho manual + sugestão de 1 linha no sync da
  validate. Descartado: só manual.
- 2026-10-02 (humano): links já quebrados entram no lote e são corrigidos com
  nota. Descartados: só reportar, ignorar.
- 2026-10-02 (humano): 1 commit próprio da limpeza. Descartados: deixar
  staged, não tocar no índice.
- 2026-10-02 (humano): planned órfão com dependente vivo → pula e avisa.
  Descartado: remover e limpar o `depende-de`.
- 2026-10-02 (humano, plan): o lote é aplicado pelo script `hooks/cleanup`
  (varrer/contar só leem; aplicar apaga, troca link, apaga linha do índice,
  roda `memory-validate`, faz 1 commit e desfaz com `git checkout HEAD`).
  Exceção à decisão viva grafo-v2 ("índice editado pelo LLM, nunca gerado
  por script"): o script só APAGA linha aprovada e valida antes do commit;
  sem bash, a cleanup fica indisponível. Descartado: script só varre e o
  LLM aplica.

## delta

## e2e

pendente

## feedback-reprovacao
