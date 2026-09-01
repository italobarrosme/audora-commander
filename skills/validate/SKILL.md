---
name: validate
description: 'Use quando a execução (e o e2e, se rodado) de uma demanda terminar — portão humano final com evidência mapeada aos critérios, e sync de MEMORY e PRD após o merge.'
---

# validate — o portão final

```
LEI DE FERRO: NENHUMA AFIRMAÇÃO DE SUCESSO SEM EVIDÊNCIA FRESCA DE EXECUÇÃO
```

**Anuncie ao começar:** "Usando validate para fechar [demanda]."

A IA executa; o humano decide. Este é o ponto onde ele decide. "Pronto",
"passou", "funciona" — nenhuma dessas palavras sai da sua boca sem comando
executado NESTA sessão com saída lida. Confiança não é evidência.

## Fluxo

1. **Oferecer o e2e** (se ainda não rodou): "Recomendo fortemente rodar o e2e
   da demanda — levanto o projeto e exercito os critérios de verdade. Rodar?"
   Aceitou → skill e2e, volte aqui com o relatório. Recusou → registrar no nó
   `e2e: pulado-pelo-humano` e seguir.
   Categoria LIGHT: a oferta é condicional — ver `## Fechamento LIGHT`.
2. **Gate de evidência 1:1** — para CADA critério de aceite do nó, citado
   pelo endereço `<id>/<n>`:
   - evidência automatizada: comando executado agora + saída correspondente
     (teste, chamada, relatório e2e); OU
   - item explícito no roteiro de validação humana (critério
     não-automatizável);
   - nenhum dos dois → a demanda NÃO está pronta. Volte à execute e feche o
     buraco. Um teste feliz verde não cobre os outros critérios.
3. **Montar o roteiro de validação** para o humano:
   - **Comportamento** (sempre): comandos para rodar, telas/rotas para abrir,
     casos de erro para provocar — mapeados critério a critério, com a
     evidência já coletada ao lado.
   - **Decisões vivas propostas** (sempre): quais decisões do nó seguem
     valendo para demandas futuras (candidatas a `docs/audora/decisoes-vivas.md`)
     — o humano aprova/corta no portão; o sync (item 6) só executa.
     **Filtro de entrada**: só é candidata a decisão que NÃO dá para
     impor por teste, hook ou config. Dá para escrever um teste que a
     imponha? Então o lugar dela é o teste — prosa duplicada deriva do que
     descreve e passa a mentir. Descartou por esse motivo? Diga em 1 linha
     qual artefato já impõe a decisão.
   - **Categoria HIGH** (soma ao anterior): sumário de mudanças por arquivo,
     trechos sensíveis destacados (auth, dinheiro, dados, migração) para
     revisão de código — comportamento E código, não ou.
   - **Revisão adversarial** (HIGH): despachar subagente de contexto limpo
     com o diff + critérios, instruído a ATACAR (refutar que os critérios
     foram atendidos, procurar furo de segurança/borda). Resumo condensado
     entra no roteiro. Autor não revisa a si mesmo.
4. **Decisões tomadas pela IA**: listar as micro-decisões acumuladas no plano
   para o humano revisar em lote.
5. **Portão humano** — apresentar roteiro e ESPERAR decisão explícita:
   - **Aprovou** → item 6.
   - **Reprovou** → nó fica `in-progress` + `feedback-reprovacao` preenchido.
     Motivo é escopo errado → skill scope (reabertura). Motivo é execução →
     skill plan, replanejar a etapa afetada.
   - **Aprovação parcial** → o aceito segue o item 6; o resto vira etapas
     novas no plano, demanda continua `in-progress`.
6. **Sync pós-aprovação** (quando o trabalho entra na main — merge ou commit
   direto):
   - Consolidar o bloco `delta` no corpo do nó (skill memory).
   - Preencher `arquivos:` do nó via `git diff --name-only` da demanda — do
     diff real, nunca de memória.
   - Promover para `docs/audora/decisoes-vivas.md` as decisões vivas
     aprovadas no portão (propostas no roteiro, item 3) — só as que passaram
     no filtro de entrada; o sync não reabre o que o item 3 descartou.
   - Consolidar os aprendizados da demanda na seção Aprendizados do
     `MEMORY.md` (skill memory, compactar — dedupe por grep; o que já foi
     registrado na hora pelas fases só é conferido).
   - Nó → `delivered`; arquivar por movimento (skill memory, compactar):
     `git mv docs/audora/memory/<id>.md docs/audora/arquivo/AAAA-MM-DD-<id>.md`
     + linha do índice atualizada.
   - **Promover ao PRD.md**: resumo do que foi entregue + data de última
     atualização. Direção única MEMORY → PRD, sempre (vale para toda camada
     derivada: decisoes-vivas e afins fluem DO nó, nunca de volta).
   - Arquivar o plano em `docs/audora/planos/arquivo/`.
   - HOTFIX: regularizar o registro retroativo (nó `hotfix-pending-record`
     → nó completo).
   - Categoria LIGHT: rode só os passos com conteúdo — ver `## Fechamento LIGHT`.
7. **Efeito irreversível fora do repo** (migração em ambiente compartilhado,
   deploy, e-mail, cobrança) — em QUALQUER categoria: preparar o comando
   exato + rollback, apresentar, e o HUMANO executa ou autoriza aquele
   comando específico. Você nunca dispara sozinho.

## Fechamento LIGHT

Demanda LIGHT percorre `execute → validate` e não tem plano-arquivo, escopo
escrito nem, quase sempre, delta ou decisão durável. O fechamento acompanha o
risco — mas o que ele NUNCA corta é o **portão humano** com aprovação
explícita e a **evidência 1:1** por critério. Enxugar é tirar material de
revisão, nunca tirar a revisão.

- **Oferta de e2e** (item 1): só quando a demanda toca
  **caminho percorrido pelo usuário** — tela, rota, fluxo, saída de CLI.
  LIGHT interno (refactor,
  doc, config, teste) não recebe a oferta. Pedido explícito do humano roda
  sempre, em qualquer caso.
- **Roteiro** (item 3): versão curta — evidência 1:1 por critério, o diff, e
  1 linha de como conferir. Sem sumário por arquivo; sem seção de decisões
  vivas quando não há nenhuma.
- **Sync** (item 6): rode só os passos com conteúdo real — `arquivos:` do
  diff, aprendizados, e nó → `delivered` com arquivamento. Consolidar delta e
  promover decisões vivas rodam SOMENTE se houver delta ou decisão.
- **Plano**: LIGHT **não tem plano** para arquivar. Pule a etapa sem listá-la
  como pendência.
- **PRD**: promova apenas se o ajuste alterar comportamento que o `PRD.md` já
  descreve. Não alterando, registre no nó e diga em 1 linha que o PRD não
  mudou e por quê — silêncio sobre o PRD é proibido.

HOTFIX não usa este caminho: tem o dele, com registro retroativo.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Deve passar" / "provavelmente funciona" | Rode o comando. Leia a saída. Depois fale. |
| "Evidência de um critério basta, o resto é igual" | 1:1 é 1:1. Critério sem evidência = buraco no portão. |
| "O humano confia em mim, pulo o roteiro" | Confiança se mantém COM roteiro. Sem ele, drift silencioso. |
| "Atualizo o PRD e o MEMORY outro dia" | Outro dia a memória já era. Sync faz parte do fechar, não é extra. |
| "Reprovou, mas o problema é pequeno, sigo direto" | Reprovação tem fluxo: registrar feedback, voltar à fase certa. |
| "A migração é pequena, eu mesmo executo" | Irreversível fora do repo = mão do humano. Sem exceção. |

## Bloco de fechamento

Ao terminar, imprima no terminal o bloco de fechamento pelo formato canônico
de `templates/bloco-fechamento-template.md` (raiz do plugin). Nesta fase:

- **Produzido**: o veredito do portão e o que o sync consolidou.
- **Arquivos**: nó arquivado, plano arquivado, `PRD.md` atualizado.
- **Próximo**: nenhum — o fluxo da demanda encerra aqui.

Aprovada, o bloco de fase é seguido do bloco **Entrega**: tabela
critério → veredito com a evidência em 1 linha, e a lista de arquivos tocados
tirada de `git diff --name-only` real. Formato no mesmo template.

## PRÓXIMA SKILL

Nenhuma — o fluxo da demanda encerra aqui. Nova demanda → skill
audora-commander classifica do zero.
