---
id: entrega-clara
estado: in-progress
origem: humano
depende-de: [relatorio-entrega]
arquivos: []
keywords: [entrega, done, relatorio, validate, sync, chat, bloco-fechamento]
resumo: Fechamento da demanda no chat deixa claro que ela está DONE, o que foi entregue e como foi feito.
atualizado-em: 2026-10-22
---

# entrega-clara

## objetivo

Decidido o portão final, o chat mostra num relance se a demanda está DONE, o
que foi entregue e como foi feito, num cartão único em vez de prosa do sync +
bloco de fase + relatório longo que repete o roteiro.

Categoria: MEDIUM (nenhum SIM de risco; saída de conversa, vários arquivos).
Diagnóstico (agentes-dedicados, 2026-10-15): relatório em `####` abaixo do
bloco de fase, evidência e decisões repetidas, arquivos de outra demanda.

## criterios-aceite

- **entrega-clara/1** — QUANDO o portão final da validate for aprovado, em
  QUALQUER categoria, O SISTEMA DEVE fechar o turno com um cartão único de
  título `## 🏁 DONE — <id>`, no lugar do bloco de fase + relatório
- **entrega-clara/2** — QUANDO o cartão for impresso O SISTEMA DEVE trazer
  sob o título 1 linha de estado: categoria · `<entregues>/<total>`
  critérios · `na main` ou `na branch <nome>`
- **entrega-clara/3** — QUANDO o cartão for impresso O SISTEMA DEVE trazer
  "O que mudou": 1 a 3 bullets em linguagem de usuário ("o sistema agora …")
- **entrega-clara/4** — QUANDO o cartão for impresso O SISTEMA DEVE trazer
  "Como foi": trilha das fases percorridas, em ordem, resumo de até 8
  palavras cada, e2e marcado como rodado ou pulado
- **entrega-clara/5** — QUANDO houver ressalva (e2e pulado, prova parcial,
  ressalva aceita no portão) O SISTEMA DEVE listar 1 linha por ressalva;
  QUANDO não houver O SISTEMA DEVE escrever "Ressalvas — nenhuma"
- **entrega-clara/6** — QUANDO o nó tiver `## delta` com entradas O SISTEMA
  DEVE listar Mudanças no caminho, 1 linha por entrada; sem delta, omitir
- **entrega-clara/7** — QUANDO o cartão for impresso O SISTEMA DEVE listar
  "Por critério" com TODOS os critérios do nó, endereço `<id>/<n>`, ícone e
  palavra (✅ entregue, ⏳ pendente, ❌ reprovado) e comportamento de usuário
- **entrega-clara/8** — QUANDO o cartão for impresso O SISTEMA DEVE resumir
  a evidência em 1 linha (com evidência / total + suíte ou gate desta sessão
  + "detalhe no roteiro do portão") e as Decisões da IA em 1 linha
  (quantidade + "revisadas no portão"; nenhuma → omitir), sem repetir tabela
  de evidência nem lista de decisões do roteiro
- **entrega-clara/9** — QUANDO o cartão for impresso O SISTEMA DEVE trazer
  Como conferir com ≥ 1 item ligado a critério: comando em ` ```text ` ou
  tela/rota a abrir
- **entrega-clara/10** — QUANDO o cartão for impresso O SISTEMA DEVE trazer
  os arquivos só como 1 linha `<n> arquivos · +<a> −<r>`, somada do
  `git diff --numstat` real da demanda, sem arquivo de outra demanda
- **entrega-clara/11** — QUANDO o sync tiver rodado O SISTEMA DEVE fechar o
  cartão com 1 linha de rodapé da memória (nó arquivado, PRD, CHANGELOG,
  decisões vivas; sobras de limpeza se N > 0), sem resumo do sync fora dele
- **entrega-clara/12** — QUANDO o portão for aprovado com o trabalho numa
  branch fora da main O SISTEMA DEVE imprimir o cartão DONE com o Próximo
  perguntando, em opções numeradas, se faz o merge na main agora; aceito →
  merge, sync e confirmação em 1 linha, sem segundo cartão
- **entrega-clara/13** — QUANDO o portão for reprovado ou parcial O SISTEMA
  DEVE imprimir o mesmo cartão com título `## ❌ NÃO ENTREGUE — <id>` ou
  `## ⚠️ PARCIAL — <id>`, veredito e motivo por critério e Próximo na
  decisão humana ou fase de retorno — sem a palavra DONE
- **entrega-clara/14** — QUANDO um dado do cartão não tiver fonte lida nesta
  sessão (nó, saída de comando, diff) O SISTEMA DEVE marcar `[SEM FONTE]` e o
  critério ligado como ⏳, nunca preencher de memória
- **entrega-clara/15** — QUANDO o cartão for impresso O SISTEMA DEVE ser a
  última parte da resposta do turno, sem chamada de ferramenta depois

## fora-de-escopo

Blocos de fechamento das outras fases (porta, scope, plan, execute, e2e,
debug); roteiro do portão (segue completo, com evidência e decisões);
hash de commit ou versão no cartão; tabela de arquivos; hook que imponha o
formato do cartão; encolher o template em geral (cerimonia-enxuta).

## decisoes

- 2026-10-22 (humano): cartão DONE único substitui bloco de fase + relatório. Descartado: banner DONE sobre o formato atual (mantém o ruído); só cartão curto (perde o por-critério).
- 2026-10-22 (humano): evidência e decisões da IA em 1 linha cada no cartão. Descartado: completas (repetem o roteiro); fora (some a referência).
- 2026-10-22 (humano): arquivos só como contagem. Descartado: produto + rodapé de memória em tabela; diff inteiro como hoje.
- 2026-10-22 (humano): "Como foi" = trilha de fases + ressalvas + mudanças no caminho. Descartado: commit na main no cartão.
- 2026-10-22 (humano): reprovado/parcial usam o mesmo cartão como NÃO ENTREGUE/PARCIAL. Descartado: só bloco de fase ❌.
- 2026-10-22 (humano): aprovado em branch já é DONE, e o cartão pergunta se faz o merge. Descartado: "APROVADO · aguarda merge".
- 2026-10-22 (IA, escopo): Ressalvas sempre impressa ("nenhuma" explícito); após merge pedido no cartão, sync confirma em 1 linha sem segundo cartão.
- 2026-10-22 (IA, escopo): substitui relatorio-entrega/1 (ordem de seções), /4 (tabela de evidência) e /8 (tabela de arquivos); /2, /3, /5, /7, /9, /10, /11 seguem em nova forma.

## delta

## e2e

pendente

## feedback-reprovacao
