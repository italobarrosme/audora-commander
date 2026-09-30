# Plano — <id>: <título>

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** <1 frase — o que esta demanda entrega>

**Nó do MEMORY:** `<id>` (MEMORY.md)

**Arquitetura da mudança:** <2-3 frases: abordagem escolhida e por quê>

**Arquivos lidos antes de planejar:** <!-- Lei de Ferro: plano sem leitura do
código atual é plano inválido. Uma linha por leitura, `caminho:início-fim`.
Etapa que toca arquivo fora desta lista invalida o plano naquele ponto. -->
- `caminho/exato/arquivo1.ts:12-60` — <o que foi relevante nela>
- `caminho/exato/arquivo2.ts:1-40` — <o que foi relevante nela>

**Conflitos MEMORY vs código encontrados:** <nenhum | descrição + decisão do humano>

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda: abordagens descartadas
e por quê, estado parcial, próximos passos. Próxima sessão lê isto primeiro. -->

---

## Tarefa 1: <nome curto>

- **depende-de**: []
- **requisito**: `<id>/<n>` — <critério EARS copiado verbatim do nó>
- **decisões relevantes**: <decisões do nó/constituição que governam esta tarefa>
- **interfaces**: consome <assinatura exata> · produz <assinatura exata>
- **ponto de mudança**: `caminho/arquivo.ts:42` — <símbolo e o que muda>
- **teste**: `caminho/arquivo.test.ts` — caso "<nome citando `<id>/<n>`>"
- **asserções**: `entrada → saída esperada`, uma por caso — só quando o
  critério não fixa o valor (formato, ordem, mensagem, código de saída, borda)
- **ler**: `caminho/arquivo.ts:30-80`, `caminho/outro.ts:10-25`
- **done quando**: <condição objetiva verificável>

- [ ] **red** — `<comando>` falha com `<saída esperada>` (motivo certo)
- [ ] **green** — `<comando>` passa e a suíte toda fica verde
- [ ] **commit** — `git add <arquivos> && git commit -m "<tipo>(<id>/<n>): <msg>"`

<!-- Tarefa é mapa: sem o corpo do teste nem o da implementação — nascem na
execute, UMA vez. Complexa: `expandir: sim`, quebrar só quando chegar a vez.
Proibições: TBD; TODO; "tratar erros adequadamente"; "similar à tarefa N"
(repita a asserção); passo sem arquivo, `caminho:linha` ou comando exatos;
referência a função/tipo não definido em nenhuma tarefa. -->
