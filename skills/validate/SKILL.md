---
name: validate
description: 'Use quando a execução (e o e2e, se rodado) de uma demanda terminar — portão humano final com evidência mapeada aos critérios, e sync de MEMORY e PRD após o merge.'
---

# validate — o portão final

```
LEI DE FERRO: NENHUMA AFIRMAÇÃO DE SUCESSO SEM EVIDÊNCIA FRESCA DE EXECUÇÃO
```

**Anuncie ao começar:** "Usando validate para fechar [demanda]."

A IA executa; o humano decide — aqui. "Pronto",
"passou", "funciona" — nenhuma dessas palavras sai da sua boca sem comando
executado NESTA sessão com saída lida. Confiança não é evidência.

## Onde mora cada parte

Esta skill é um roteador: o fluxo até o portão está inline; o resto vive em
`references/`, ao lado deste arquivo, e só é lido quando usado. **Leia uma
reference por uso — nunca a pasta inteira.**

| uso | onde |
|---|---|
| fluxo até o portão (e2e, evidência, roteiro, portão) | inline |
| filtro de entrada das decisões vivas (roteiro, item 3) | references/decisoes-vivas.md |
| revisão adversarial (roteiro, item 3; só HIGH) | references/revisao-adversarial.md |
| demanda LIGHT | references/fechamento-light.md |
| sync pós-aprovação (item 6) | references/sync.md |

**Reference ausente** ou ilegível → avisar em 1 linha qual arquivo faltou;
a validate mantém o portão humano e NÃO roda o sync de memória de cabeça — pede ao humano para reinstalar o plugin.

## Fluxo

Contexto: carregar-contexto (skill memory) antes de qualquer Read;
`MEMORY.md` nunca inteiro.

1. **Oferecer o e2e** (se ainda não rodou): "Recomendo fortemente rodar o e2e
   da demanda — levanto o projeto e exercito os critérios de verdade. Rodar?"
   Aceitou → skill e2e, volte aqui com o relatório. Recusou → registrar no nó
   `e2e: pulado-pelo-humano` e seguir.
   Categoria LIGHT: a oferta é condicional — `references/fechamento-light.md`.
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
   - **Diff de teste** (sempre, toda categoria): listar o diff dos
     arquivos de teste separado do resto — teste apagado ou skip/only é a
     fraude que o gate reprova; o roteiro a expõe ao humano.
   - **Decisões vivas propostas** (sempre): quais decisões do nó seguem
     valendo para demandas futuras, passadas pelo filtro de entrada de
     `references/decisoes-vivas.md` — o humano aprova/corta no portão; o sync
     (item 6) só executa.
   - **Categoria HIGH** (soma ao anterior): sumário de mudanças por arquivo,
     trechos sensíveis destacados (auth, dinheiro, dados, migração) para
     revisão de código — comportamento E código, não ou.
   - **Revisão adversarial** (HIGH): siga `references/revisao-adversarial.md`
     — despacho, bloqueante, parada e o que entra no roteiro.
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
   direto): seguir `references/sync.md`, NA ORDEM — julgamento, estado e
   movimento, `arquivos:` do diff real, PRD + CHANGELOG, HOTFIX.
7. **Efeito irreversível fora do repo** (migração em ambiente compartilhado,
   deploy, e-mail, cobrança) — em QUALQUER categoria: preparar o comando
   exato + rollback, apresentar, e o HUMANO executa ou autoriza aquele
   comando específico. Você nunca dispara sozinho.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Deve passar" / "provavelmente funciona" | Rode o comando. Leia a saída. Depois fale. |
| "Evidência de um critério basta, o resto é igual" | 1:1 é 1:1. Critério sem evidência = buraco no portão. |
| "O humano confia em mim, pulo o roteiro" | Confiança se mantém COM roteiro. Sem ele, drift silencioso. |
| "Atualizo o PRD e o MEMORY outro dia" | Outro dia a memória já era. Sync faz parte do fechar, não é extra. |
| "Reprovou, mas o problema é pequeno, sigo direto" | Reprovação tem fluxo: registrar feedback, voltar à fase certa. |
| "A migração é pequena, eu mesmo executo" | Irreversível fora do repo = mão do humano. Sem exceção. |
| "A reference do sync sumiu, faço de cabeça" | Sync de memória de cabeça é memória corrompida. Portão sim, sync não — reinstalar. |

## Bloco de fechamento

Ao terminar, imprima no terminal o bloco de fechamento pelo formato canônico
de `templates/bloco-fechamento-template.md` (raiz do plugin; já lido nesta sessão
→ não reler). Nesta fase:

- **Produzido**: o veredito do portão e o que o sync consolidou.
- **Arquivos**: nó arquivado, plano arquivado, `PRD.md` atualizado e
  `CHANGELOG.md` com a linha da entrega.
- **Próximo**: nenhum — o fluxo da demanda encerra aqui.

Aprovada, o bloco de fase é seguido do bloco **Entrega**: tabela
critério → veredito com a evidência em 1 linha, e a lista de arquivos tocados
tirada de `git diff --name-only` real. Formato no mesmo template.

## PRÓXIMA SKILL

Nenhuma. Nova demanda → skill audora-commander classifica do zero.
