---
name: plano
description: Use quando o escopo de uma demanda MÉDIA ou ALTA estiver aprovado e for hora de planejar o "Como" — ler o código atual, mapear arquivos e gerar o plano-arquivo com tarefas autossuficientes.
---

# plano — a fase "Como", just-in-time

```
LEI DE FERRO: PLANO SEM LEITURA DO CÓDIGO ATUAL É PLANO INVÁLIDO
```

**Anuncie ao começar:** "Usando plano para planejar [demanda]."

Plano cobre UMA demanda — nunca o projeto inteiro. Formato canônico:
`${CLAUDE_PLUGIN_ROOT}/templates/plano-template.md`. Saída obrigatória:
`docs/audora/planos/plano-<id-demanda>.md`. Plano que vive só na conversa
morre no primeiro /clear — por isso é ARQUIVO.

## Fluxo

1. **Contexto**: carregar nó da demanda + constituição (skill grafo). Ler o
   artefato de escopo aprovado (nó ou spec dedicada).
2. **Passada 1 — localizar**: a partir do escopo, achar candidatos por busca
   (grep/glob por símbolos, rotas, nomes de domínio). Não ler nada ainda —
   só listar onde a mudança provavelmente mora.
3. **Passada 2 — ler**: ler os arquivos que o plano vai tocar (e vizinhos de
   interface direta). Listar TODOS os lidos no header do plano. Etapa que
   tocar arquivo fora dessa lista invalida o plano naquele ponto → parar,
   ler, atualizar o header, seguir.
4. **Conflito GRAFO vs código**: leitura contradiz um nó do GRAFO? Parar,
   registrar a divergência no nó (skill grafo), apresentar ao humano. Ele
   decide qual é a verdade antes do plano continuar.
5. **Escrever o plano** pelo template:
   - Header: objetivo, nó do GRAFO, arquitetura da mudança, arquivos lidos.
   - Tarefas autossuficientes: cada uma embute requisito (critérios EARS
     copiados verbatim do nó), decisões relevantes, interfaces
     (consome/produz com assinaturas exatas), arquivos com caminhos exatos,
     critério de done.
   - `depende-de` explícito entre tarefas: "qual a próxima?" é resposta
     mecânica — nunca uma tarefa bloqueada.
   - Passos de 2-5 minutos com checkbox: teste red → verificar red →
     implementar → verificar green → commit. Código real nos passos.
   - Tarefa complexa: marcar `expandir: sim` e quebrar em subtarefas SÓ
     quando chegar a vez dela (just-in-time — não detalhe tudo no dia 1).
6. **Proibição de placeholders** — falhas de plano, nunca escreva: "TBD",
   "tratar erros adequadamente", "adicionar validação", "similar à tarefa N"
   (repita o código), passo que descreve sem mostrar como, referência a
   função/tipo não definido em nenhuma tarefa.
7. **Self-review** (rodar você mesmo, corrigir inline):
   - Cobertura: cada critério de aceite do nó tem tarefa que o implementa?
   - Scan de placeholder (lista do item 6).
   - Consistência: nomes/assinaturas iguais entre tarefa que produz e tarefa
     que consome.
8. **Portão** (categoria ALTA): apresentar o plano ao humano e ESPERAR
   aprovação. MÉDIA: plano salvo, seguir direto.
9. **Fechar a fase**:
   > Fase de plano fechada. Artefato salvo: docs/audora/planos/plano-<id>.md.
   > Seguro dar /clear agora — a execução começa relendo o plano.

## Replanejamento (durante a execução)

Gatilhos legítimos — SOMENTE estes:
- (a) arquivo/símbolo que a etapa referencia não existe ou mudou de forma
  incompatível;
- (b) o teste da etapa é impossível de escrever como especificado;
- (c) a descoberta altera escopo → isso NÃO é replanejar: volte à skill
  escopo (reabertura formal).

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

## PRÓXIMA SKILL

Plano salvo (e aprovado, se ALTA) → **executar**.
