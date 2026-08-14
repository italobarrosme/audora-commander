---
name: executar
description: Use quando houver plano aprovado (MÉDIA/ALTA) ou demanda LEVE/HOTFIX pronta para código — implementação TDD red-green com evidência real de execução.
---

# executar — TDD com evidência

```
LEI DE FERRO: NENHUM CÓDIGO DE PRODUÇÃO SEM TESTE FALHANDO ANTES
```

**Anuncie ao começar:** "Usando executar para implementar [demanda/tarefa]."

Escreveu código antes do teste? Apague e recomece pelo teste. Não guarde "de
referência", não adapte — apague. Violar a letra da regra é violar a regra.

## Fluxo

1. **Reancorar**: reler o plano (`docs/audora/planos/plano-<id>.md`) e o nó do
   GRAFO. MÉDIA/ALTA sem plano-arquivo → volte à skill plano. LEVE/HOTFIX:
   sem plano; os critérios do nó guiam direto. Repetir esta releitura no
   início de CADA sessão e após qualquer compactação de contexto.
2. **Ordem mecânica**: próxima tarefa = a que tem todas as `depende-de`
   concluídas. Tarefa marcada `expandir: sim` → quebrar em subtarefas AGORA
   (chegou a vez dela), pelo formato do template.
3. **Ciclo por tarefa**:
   - **RED**: escrever UM teste mínimo do comportamento (nome claro, uma
     coisa só, código real — mock apenas se inevitável). Rodar. Confirmar na
     SAÍDA REAL que falha pelo motivo certo (feature ausente, não typo).
     Passou de primeira? Você testou comportamento existente — conserte o
     teste. Erro em vez de falha? Conserte até falhar direito.
   - **GREEN**: mínimo para passar. Sem feature extra, sem "melhorar" além do
     teste (YAGNI). Rodar; confirmar na saída real: teste passa E suíte toda
     verde E saída limpa (sem warning novo).
   - **REFACTOR**: só depois do green — duplicação, nomes, extração. Testes
     continuam verdes. Sem comportamento novo.
   - **COMMIT**: etapa verde → `git add <arquivos> && git commit`. Cada commit
     é checkpoint de rollback barato.
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
   Sim → skill escopo (reabertura). Não → pergunta pontual, registra no nó,
   segue.
6. **HOTFIX**: escrever ANTES o teste que reproduz o defeito (red), depois o
   fix (green). Sem teste de reprodução não há hotfix — há chute.

## Quando algo dá errado

- **Teste falha por motivo desconhecido** → skill **depurar** (modo sintoma):
  causa raiz demonstrada antes de qualquer correção. Chute empilhado vira
  pântano.
- **Gatilho de replanejamento** (arquivo sumiu, teste impossível como
  especificado) → skill plano, replanejar SÓ a etapa afetada.
- **Falha irrecuperável** (dependência quebrada, etapa sem saída) → PARAR.
  Nó → `bloqueada` + diagnóstico registrado (skill grafo). Apresentar ao
  humano: reverter branch, replanejar do último checkpoint, ou abandonar
  (nó → `descartada` com motivo). Nunca forçar caminho pela metade.

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

## PRÓXIMA SKILL

Todas as tarefas verdes → **validar** (que oferece o e2e antes do portão).
