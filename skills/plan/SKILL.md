---
name: plan
description: 'Use quando o escopo de uma demanda MEDIUM ou HIGH estiver aprovado e for hora de planejar o "Como" — ler o código atual, mapear arquivos e gerar o plano-arquivo com tarefas autossuficientes.'
---

# plan — a fase "Como", just-in-time

```
LEI DE FERRO: PLANO SEM LEITURA DO CÓDIGO ATUAL É PLANO INVÁLIDO
```

**Anuncie ao começar:** "Usando plan para planejar [demanda]."

Plano cobre UMA demanda — nunca o projeto inteiro. Formato canônico:
`templates/plano-template.md` na raiz do plugin (dois níveis acima desta
skill). Saída obrigatória: `docs/audora/planos/plano-<id>.md`. Plano que vive
só na conversa morre no primeiro /clear — por isso é ARQUIVO.

## Fluxo

1. **Contexto**: carregar nó da demanda + constituição (skill memory). Ler o
   artefato de escopo aprovado (nó ou spec dedicada). Retomada (`plan de <id>`)
   com id fora do índice ou nó sem critérios aprovados → recusar nomeando o que falta e voltar ao scope.
2. **Passada 1 — localizar**: a partir do escopo, achar onde a mudança mora
   (símbolos, rotas, nomes de domínio) pela busca do símbolo — só listar.
   Pergunta ampla sobre código que você não conhece → subagente de exploração
   com UMA pergunta delimitada, que devolve `caminho:linha`; confira
   o trecho com leitura própria antes de gravar no mapa.
3. **Passada 2 — ler**: ler por trecho o que o plano vai tocar (pontos da
   passada 1 + vizinhos de import, herança, registro e configuração).
   Listar no header CADA leitura como `caminho:início-fim`,
   com o que foi relevante nela. Etapa que tocar arquivo fora dessa lista
   invalida o plano naquele ponto → parar, ler, atualizar o header, seguir.
4. **Conflito MEMORY vs código**: leitura contradiz um nó do MEMORY? Parar,
   registrar a divergência no nó (skill memory), apresentar ao humano. Ele
   decide qual é a verdade antes do plano continuar.
5. **Escrever o plano** pelo template:
   - Header: objetivo, nó do MEMORY, arquitetura da mudança, trechos lidos.
   - Tarefa é MAPA, sem o corpo do teste nem o da implementação:
     requisito (critério EARS verbatim, com o endereço `<id>/<n>`),
     decisões, interfaces com assinaturas exatas, ponto de mudança
     `caminho:linha`, arquivo e caso de teste, trechos a ler e done.
   - Critério que não fixa o valor exato (formato, ordem, mensagem, código
     de saída, borda) → a tarefa traz a asserção exata `entrada → saída esperada` de cada caso.
   - `depende-de` explícito entre tarefas: "qual a próxima?" é resposta
     mecânica — nunca uma tarefa bloqueada.
   - Passos com checkbox: red → green → commit, com comandos exatos.
   - Tarefa complexa: marcar `expandir: sim` e quebrar em subtarefas SÓ
     quando chegar a vez dela (just-in-time — não detalhe tudo no dia 1).
6. **Proibição de placeholders** — falhas de plano, nunca escreva: "TBD",
   "tratar erros adequadamente", "adicionar validação", "similar à tarefa N"
   (repita a asserção), passo sem arquivo, `caminho:linha` ou comando exatos,
   referência a função/tipo não definido em nenhuma tarefa.
7. **Self-review** (rodar você mesmo, corrigir inline):
   - Cobertura: cada critério de aceite do nó tem tarefa que o implementa?
   - Scan de placeholder (lista do item 6).
   - Consistência: nomes/assinaturas iguais entre tarefa que produz e tarefa
     que consome.
8. **Portão** (categoria HIGH): apresentar o plano ao humano e ESPERAR
   aprovação. MEDIUM: plano salvo, seguir direto.
9. **Fechar a fase**:
   > Fase de plano fechada. Artefato salvo: docs/audora/planos/plano-<id>.md.
   > PARADA: rode /clear e, na sessão nova: `execute de <id>`.

## Replanejamento (durante a execução)

Gatilhos legítimos — SOMENTE estes:
- (a) arquivo/símbolo que a etapa referencia não existe ou mudou de forma
  incompatível;
- (b) o teste da etapa é impossível de escrever como especificado;
- (c) a descoberta altera escopo → isso NÃO é replanejar: volte à skill scope
  (reabertura formal).
- (d) a execute precisa modificar arquivo fora do mapa — replanejar só aquela etapa.

Teste falhando por bug da implementação é DEBUG, não replanejamento. Replaneje
a etapa afetada, não o plano inteiro.

## Notas de sessão

Antes de sinalizar /clear no meio da demanda: despejar na seção "Notas de
sessão" do plano as abordagens descartadas (e por quê), o estado parcial e os
próximos passos. A próxima sessão lê isso primeiro.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Conheço o projeto, planejo de memória" | Memória é de outra sessão. Código mudou. Leia primeiro — Lei de Ferro. |
| "Detalho essa tarefa quando chegar nela... mentira, detalho tudo já" | Detalhar tudo agora é especulação. Expanda só quando chegar a vez. |
| "O plano na conversa basta, arquivo é burocracia" | /clear ou compactação matam a conversa. Arquivo sobrevive. |
| "Esse arquivo eu não li, mas sei o que tem" | Então o plano é chute. Leia e liste no header. |
| "Tarefa referencia helper que crio depois" | Referência órfã = plano quebrado. Defina na tarefa que produz. |
| "O subagente disse que é em X:42, gravo no mapa" | Resposta de subagente é pista. Leia o trecho antes de gravar. |

## Bloco de fechamento

Ao terminar, imprima no terminal o bloco de fechamento pelo formato canônico
de `templates/bloco-fechamento-template.md` (raiz do plugin; já lido nesta sessão
→ não reler). Nesta fase:

- **Produzido**: quantas tarefas, quantos passos, e quais ficaram marcadas
  `expandir: sim` (não detalhadas ainda, por design).
- **Arquivos**: `docs/audora/planos/plano-<id>.md`, com tamanho.
- **Próximo**: execute na primeira tarefa sem `depende-de` pendente.

## PRÓXIMA SKILL

Plano salvo (e aprovado, se HIGH) → **execute**.
