---
name: execute
description: 'Use quando houver plano aprovado (MEDIUM/HIGH) ou demanda LIGHT/HOTFIX pronta para código — implementação TDD red-green com evidência real de execução.'
---

# execute — TDD com evidência

```
LEI DE FERRO: NENHUM CÓDIGO DE PRODUÇÃO SEM TESTE FALHANDO ANTES
```

**Anuncie ao começar:** "Usando execute para implementar [demanda/tarefa]."

Escreveu código antes do teste? Apague e recomece pelo teste. Não guarde "de
referência", não adapte — apague. Violar a letra da regra é violar a regra.

## Fluxo

1. **Reancorar**: carregar-contexto (skill memory) antes de qualquer Read;
   `MEMORY.md` nunca inteiro. Reler o plano
   (`docs/audora/planos/plano-<id>.md`) e o nó. MEDIUM/HIGH
   sem plano-arquivo → recusar nomeando o que falta e voltar à skill plan.
   LIGHT/HOTFIX: sem plano; os critérios do nó guiam direto. Repetir no
   início de CADA sessão e após compactação.
2. **Ordem mecânica**: próxima tarefa = a que tem todas as `depende-de`
   concluídas. Tarefa marcada `expandir: sim` → quebrar em subtarefas AGORA
   (chegou a vez dela), pelo formato do template.
3. **Ciclo por tarefa**:
   - **RED**: escrever UM teste mínimo do comportamento (o caso e as
     asserções vêm do mapa; nome claro citando o endereço do critério `<id>/<n>` quando houver, uma coisa só, código real
     — mock apenas se inevitável). Rodar. Confirmar na
     SAÍDA REAL que falha pelo motivo certo (feature ausente, não typo).
     Passou de primeira? Você testou comportamento existente — conserte o
     teste. Erro em vez de falha? Conserte até falhar direito.
   - **GREEN**: mínimo para passar. Sem feature extra, sem "melhorar" além do
     teste (YAGNI). Rodar; confirmar na saída real: teste passa E suíte toda
     verde E saída limpa (sem warning novo).
     Constituição com `gate:` → verde é o GATE saindo 0 (rodar o comando
     do bullet e ler a saída), não só a suíte; sem `gate:`, suíte toda.
   - **REFACTOR**: só depois do green — duplicação, nomes, extração. Testes
     continuam verdes. Sem comportamento novo.
   - **COMMIT**: etapa verde → `git add <arquivos> && git commit`; a mensagem
     cita o(s) endereço(s) de critério cobertos (ex.: `feat(no-x/2): ...`).
     Cada commit é checkpoint de rollback barato.
4. **Profundidade de teste** (regra global — inegociável):
   - **Integrações reais**: banco, APIs, filas, SDKs — cubra o caminho de
     integração de verdade sempre que possível, não só unidades com tudo
     mockado.
   - **Erros e bordas**: entrada inválida, falha de rede, timeout, estado
     parcial/concorrente, limite, dado ausente, retry, rollback. Cada caminho
     de erro relevante tem teste que o exercita.
   - Cobertura significativa, não numérica: exercitar o que importa, não
     inflar métrica.
5. **Micro-decisões**: decisão de implementação (não afeta critérios) →
   decidir e ADICIONAR à lista "Decisões tomadas pela IA" no plano. Requisito
   de produto faltante → teste discriminante: muda critérios/fora-de-escopo?
   Sim → skill scope (reabertura). Não → pergunta pontual, registra no nó,
   segue. Aprendizado (armadilha, como-rodar, preferência do humano, padrão
   do projeto) → skill memory, registrar-aprendizado, na hora.
6. **HOTFIX**: escrever ANTES o teste que reproduz o defeito (red), depois o
   fix (green). Sem teste de reprodução não há hotfix — há chute.

## Localização de código

1. **Mapa**: ao começar a tarefa, ler os trechos que o mapa aponta.
   Arquivo com mais de 200 linhas é lido pelo trecho, nunca inteiro.
2. **Fora do mapa**: buscar o símbolo e ler só o trecho apontado.
3. **Ligações**: a mudança toca import, herança, registro ou configuração →
   seguir a ligação e ler o trecho ligado, mesmo fora do mapa.
4. **Orçamento**: na 3ª leitura fora do mapa na mesma tarefa,
   acrescentar ao mapa do plano os `caminho:linha` lidos e seguir.
5. **Modificar arquivo fora do mapa** → parar a tarefa e voltar ao plan
   para replanejar só aquela etapa.
6. **Mapa desatualizado** (`caminho:linha` não bate): relocalizar pela
   busca do símbolo e corrigir o mapa, sem ler o arquivo inteiro.
7. **Plano no formato antigo** (código completo do teste): executar como
   está, sem pedir conversão.

## Quando algo dá errado

- **Teste falha por motivo desconhecido** → skill **debug** (modo sintoma):
  causa raiz demonstrada antes de qualquer correção. Chute empilhado vira
  pântano.
- **Gatilho de replanejamento** (arquivo sumiu, teste impossível como
  especificado) → skill plan, replanejar SÓ a etapa afetada.
- **Falha irrecuperável** (dependência quebrada, etapa sem saída) → PARAR.
  Nó → `blocked` + diagnóstico registrado (skill memory). Apresentar ao
  humano: reverter branch, replanejar do último checkpoint, ou abandonar
  (nó → `discarded` com motivo). Nunca forçar caminho pela metade.

## Red flags — pare, apague, recomece pelo teste

| Racionalização | Realidade |
|---|---|
| "Simples demais pra testar" | Código simples quebra. Teste leva 30 segundos. |
| "Testo depois de implementar" | Teste depois passa de primeira — e não prova nada. Você nunca o viu falhar. |
| "Já testei manualmente" | Manual não repete, não cobre borda, não vira regressão. |
| "Mantenho o código como referência e escrevo o teste" | Você vai adaptar. Isso é testar depois. Apagar é apagar. |
| "Mocko tudo que é mais rápido" | Teste de mock prova o mock. Integração real ou o caminho não está coberto. |
| "A suíte quebrou em outro lugar, arrumo depois" | Verde é a suíte TODA. Arrume agora. |
| "Só dessa vez" | Não existe só dessa vez. |

## Bloco de fechamento

Ao terminar, imprima no terminal o bloco de fechamento pelo formato canônico
de `templates/bloco-fechamento-template.md` (raiz do plugin; já lido nesta sessão
→ não reler). Nesta fase:

- **Produzido**: a lista de TAREFAS do plano em checkbox — uma linha por
  tarefa, com o resultado ao lado (red/green, asserts, exit code). Essa lista
  sai **só no fim da fase**, nunca a cada tarefa verde.
- **Arquivos**: os que a execução tocou, do diff real.
- **Próximo**: MEDIUM/HIGH → PARADA: rode /clear e, na sessão nova: `validate de <id>`; LIGHT/HOTFIX → validate na mesma sessão (sem parada).

## PRÓXIMA SKILL

Todas as tarefas verdes → **validate** (que oferece o e2e antes do portão).
