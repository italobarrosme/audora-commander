---
id: resumo-de-fase
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [feedback, visibilidade, resumo, checkbox, terminal, fase]
resumo: Toda fase fecha imprimindo no terminal um bloco Markdown com o que foi feito, o que falta e as tarefas em checkbox — hoje o humano não enxerga o que está sendo entregue.
atualizado-em: 2026-08-31
---

# resumo-de-fase

## objetivo

Hoje o humano não enxerga o que cada fase entregou: o progresso vive em prosa
corrida e em arquivos que ele teria de abrir. Toda fase deve fechar imprimindo
no terminal um bloco Markdown curto e padronizado — o que foi feito, o que
falta, e as tarefas em checkbox — para que o estado da demanda seja legível
sem abrir nenhum arquivo.

## criterios-aceite

- **resumo-de-fase/1** — QUANDO uma fase terminar O SISTEMA DEVE imprimir no
  terminal um bloco Markdown de fechamento com cinco partes: título (`<id da
  demanda> · <fase concluída> → <próxima fase>`), lista de checkbox das fases,
  o que a fase produziu, arquivos tocados e próximo passo
- **resumo-de-fase/2** — QUANDO o bloco de fechamento listar as fases O
  SISTEMA DEVE marcar `[x]` nas concluídas e `[ ]` nas pendentes, com a fase
  recém-concluída em negrito e um resumo de até 8 palavras ao lado de cada
  concluída
- **resumo-de-fase/3** — QUANDO a fase execute terminar O SISTEMA DEVE
  imprimir a lista de TAREFAS do plano em checkbox, uma linha por tarefa com o
  resultado ao lado, e NÃO imprimir esse bloco a cada tarefa individual
- **resumo-de-fase/4** — QUANDO a fase validate terminar com aprovação O
  SISTEMA DEVE imprimir um bloco de entrega com (a) tabela critério → veredito
  com a evidência em 1 linha e (b) a lista de arquivos tocados obtida de
  `git diff --name-only` real, nunca de memória
- **resumo-de-fase/5** — QUANDO a demanda for LIGHT ou HOTFIX O SISTEMA DEVE
  imprimir o bloco mesmo assim, omitindo da lista as fases que aquela
  categoria não percorre — nunca deixá-las como pendentes eternas
- **resumo-de-fase/6** — QUANDO o bloco citar um arquivo O SISTEMA DEVE citar
  caminho real e existente; caminho prometido ou inventado é falha do bloco
- **resumo-de-fase/7** — QUANDO uma fase for interrompida, bloqueada ou
  reprovada no portão O SISTEMA DEVE imprimir o bloco com a fase NÃO marcada e
  o motivo em 1 linha, em vez de omitir o bloco
- **resumo-de-fase/8** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se qualquer uma das 7 skills que fecham fase (`audora-commander`,
  `scope`, `plan`, `execute`, `e2e`, `validate`, `debug`) não contiver a seção
  que define o bloco de fechamento
- **resumo-de-fase/9** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se `memory` ou `worktree` definirem bloco de fechamento próprio —
  são skills-ferramenta, devolvem à fase chamadora e quem imprime é ela

## fora-de-escopo

Mudar o que as fases FAZEM — esta demanda muda só o que elas IMPRIMEM. Bloco
próprio para `memory` e `worktree` (critério /9 proíbe). Cor, emoji
obrigatório, spinner ou qualquer TUI — é Markdown puro, o terminal que
renderiza. Bloco de antes/depois medido no fechamento e seção "o que ficou de
fora" no bloco final — ambos cortados no portão de escopo; a medição segue
vivendo no corpo do nó e o fora-de-escopo segue sendo campo do nó. Persistir
os blocos em arquivo (é saída de terminal, não artefato versionado).
Tradução dos blocos para inglês. Alterar o hook SessionStart ou os manifests.

## decisoes

- 2026-08-31 (humano): formato **Padrão** — checkbox das fases + o que a fase
  produziu + arquivos tocados + próximo passo. Enxuto foi descartado por não
  dizer o que foi produzido; Rico por ocupar tela demais a cada fase.
- 2026-08-31 (humano): na execute o checkbox de tarefas sai **só no fim da
  fase**, não a cada tarefa verde — menos ruído.
- 2026-08-31 (humano): bloco final de entrega leva critério → veredito e
  arquivos tocados. Antes/depois medido e "o que ficou de fora" ficam fora.

## delta

- MODIFICADO (2026-08-31): **/2** — de "com a fase recém-concluída em negrito"
  para "com a fase EM FOCO em negrito (a recém-concluída; ou, quando a fase foi
  interrompida, bloqueada ou aguarda portão, a própria fase em curso)". Motivo:
  /7 manda imprimir o bloco em fase interrompida, situação em que NÃO existe fase
  recém-concluída para destacar. As duas corridas do e2e destacaram a fase em
  foco, que é a informação útil. /2 e /7 se contradiziam na letra.

## e2e

relatorio: ../e2e/e2e-resumo-de-fase.md

## feedback-reprovacao
