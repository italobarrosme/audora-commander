# Plano — <id>: <título>

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** <1 frase — o que esta demanda entrega>

**Nó do GRAFO:** `<id>` (GRAFO.md)

**Arquitetura da mudança:** <2-3 frases: abordagem escolhida e por quê>

**Arquivos lidos antes de planejar:** <!-- Lei de Ferro: plano sem leitura do
código atual é plano inválido. Etapa que toca arquivo fora desta lista invalida
o plano naquele ponto. -->
- `caminho/exato/arquivo1.ts` — <o que foi relevante>
- `caminho/exato/arquivo2.ts` — <o que foi relevante>

**Conflitos GRAFO vs código encontrados:** <nenhum | descrição + decisão do humano>

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda: abordagens descartadas
e por quê, estado parcial, próximos passos. Próxima sessão lê isto primeiro. -->

---

## Tarefa 1: <nome curto>

- **depende-de**: []
- **requisito**: <critério(s) de aceite do nó que esta tarefa cobre, copiados
  verbatim — QUANDO X O SISTEMA DEVE Y>
- **decisões relevantes**: <decisões do nó/constituição que governam esta tarefa>
- **interfaces**:
  - consome: <assinaturas exatas de tarefas anteriores>
  - produz: <funções/tipos exatos que tarefas seguintes usam>
- **arquivos**:
  - Criar: `caminho/exato/novo.ts`
  - Modificar: `caminho/exato/existente.ts`
  - Teste: `caminho/exato/novo.test.ts`
- **done quando**: <condição objetiva verificável>

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever teste que falha** — código do teste no plano, completo.
- [ ] **2. Rodar e ver falhar pelo motivo certo** — comando exato + saída esperada.
- [ ] **3. Implementar o mínimo para passar** — código no plano.
- [ ] **4. Rodar e ver passar (suíte toda verde)** — comando exato + saída esperada.
- [ ] **5. Commit** — `git add <arquivos> && git commit -m "<tipo>: <mensagem>"`.

<!-- Tarefa complexa: NÃO detalhar subtarefas agora. Marcar `expandir: sim` e
quebrar em subtarefas somente quando chegar a vez dela (just-in-time). -->

<!-- Proibições (falhas de plano): TBD; TODO; "tratar erros adequadamente";
"similar à tarefa N" (repita o código); passo que descreve sem mostrar como;
referência a função/tipo não definido em nenhuma tarefa. -->
