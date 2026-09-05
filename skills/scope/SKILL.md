---
name: scope
description: 'Use quando uma demanda MEDIUM ou HIGH precisar de definição do "O Quê" — objetivo, critérios de aceite e fora-de-escopo — antes de qualquer código, ou quando outra fase reabrir o escopo.'
---

# scope — a fase "O Quê"

```
LEI DE FERRO: NENHUM CÓDIGO ANTES DO ESCOPO FECHADO EM ARTEFATO ESCRITO
```

**Anuncie ao começar:** "Usando scope para definir o O Quê de [demanda]."

Esta fase fala SÓ de comportamento observável. Proibido discutir arquivos,
funções, banco, biblioteca — isso é a fase plan. Se o humano puxar para o
"Como", anote a preferência como decisão e volte ao comportamento.

## Fluxo

1. **Contexto**: carregar constituição + nós relacionados (skill memory,
   operação carregar-contexto). Nó da demanda já existe (criado pela porta de
   entrada).
2. **Perguntas — em lote.** Só sobre comportamento: o que o usuário vê, o que
   o sistema faz, o que acontece no erro. Prefira múltipla escolha quando as
   opções são enumeráveis; decisão de formato ou layout vai com PREVIEW de
   cada alternativa, nunca descrita em prosa.
   - Antes de agrupar, aplique o **teste de dependência**, que decide lote vs
     série: a resposta de uma pergunta muda o enunciado, as opções ou a
     própria existência da outra?
     **Sim** → em série, uma de cada vez. **Não** → mesmo lote.
   - Perguntas independentes vão juntas, **no máximo 4** por lote (limite da
     ferramenta do harness, não preferência).
   - Mais de 4 lacunas independentes → priorize as que mais mudam o escopo e
     diga que há lote seguinte. Truncar em silêncio é pior que perguntar duas
     vezes.
   - Respondido o lote, cada escolha vira uma linha em `## decisoes` do nó,
     com a alternativa descartada e o motivo.
3. **Lacuna vira marcador, nunca suposição.** Informação que falta e você não
   consegue obter agora → escrever `[PRECISA-CLARIFICAR: <a dúvida exata>]` no
   artefato. É PROIBIDO substituir o marcador por uma suposição plausível — a
   suposição plausível é exatamente o bug que esta skill existe para matar.
4. **Critérios de aceite em EARS, numerados**, sempre:
   `QUANDO <condição> O SISTEMA DEVE <comportamento observável>`, cada um com
   endereço estável `<id-do-nó>/<n>` (número nunca reutilizado) — teste,
   commit, e2e e roteiro de validação citam o endereço.
   Cobrir também erro e borda: entrada inválida, falha de rede, estado vazio,
   limite. Critério que não cabe na sintaxe EARS é critério ambíguo — reescreva.
5. **Fechar os três campos** no nó do MEMORY: `objetivo` (1-2 frases),
   `criterios-aceite` (EARS), `fora-de-escopo` (explícito — o que NÃO entra).
   - Categoria MEDIUM: os três campos direto no nó.
   - Categoria HIGH: spec dedicada em `docs/audora/specs/<id>-escopo.md`,
     nó aponta para ela.
6. **Auto-revisão** (rodar você mesmo, corrigir inline):
   - Zero `[PRECISA-CLARIFICAR]` aberto?
   - Todo critério em EARS e testável?
   - Fora-de-escopo explícito (não vazio)?
   - Sem contradição com a constituição ou com nós vizinhos (`depende-de`)?
   - Nó com `autopilot: declarado` → todo critério tem verificação
     automatizável (teste, e2e, comando)? Sim → gravar `autopilot: elegivel`
     no nó; não → `autopilot: inelegivel (<id>/<n>)` citando o primeiro
     critério culpado, avisar e seguir o fluxo normal.
7. **Portão humano de escopo**: apresentar objetivo + critérios +
   fora-de-escopo e ESPERAR aprovação explícita. Apresentar e já começar o
   plano na mesma resposta é pular o portão. Reprovou → ajustar e reapresentar.
   Exceção — **portão antecipado** (autopilot): nó `autopilot: elegivel` e
   zero marcador aberto → o humano já aprovou na entrada; registrar a
   antecipação em `## decisoes` do nó e seguir para plan — a validate ratifica
   o escopo no portão final. Marcador aberto → parar e imprimir o bloco de
   fechamento com a fase desmarcada e o marcador (parada, nunca suposição).
8. **Fechar a fase** (após aprovação):
   > Fase de escopo fechada. Artefatos salvos: [nó/spec]. Seguro dar /clear
   > agora — nada importante vive só na conversa.

## Requisito de produto vs decisão de implementação

- Afeta comportamento observável ou critério de aceite → requisito de produto:
  pergunta ao humano AQUI, nesta fase.
- Não afeta (nome interno, estrutura de código) → decisão de implementação:
  não pertence a esta fase; a execute decide e lista para revisão.
- Vale para TODO o projeto, não só esta demanda (preferência do humano,
  padrão, armadilha) → aprendizado: skill memory, registrar-aprendizado, na
  hora — não fica só na conversa nem só no nó.

## Reabertura de escopo (vindo de outra fase)

Teste discriminante: a nova informação muda critérios de aceite ou
fora-de-escopo?
- **Sim** → reabertura formal: registrar delta no nó (skill memory), ajustar
  critérios, repassar pelo portão humano (item 7).
- **Não** → é esclarecimento, não reabertura: registrar no nó e devolver à
  fase que chamou. Não reexecutar o fluxo inteiro.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "O usuário obviamente quer X" | Óbvio pra você ≠ dito por ele. Pergunte ou marque `[PRECISA-CLARIFICAR]`. |
| "Detalhe esse depois, na implementação" | Depois o contexto é outro e a suposição vira código. Feche agora ou marque. |
| "O escopo tá claro na conversa, não preciso escrever" | Conversa morre no /clear. Artefato escrito ou escopo não existe. |
| "Critério em prosa serve, EARS é burocracia" | Prosa aceita ambiguidade; EARS não. Ambiguidade hoje é retrabalho amanhã. |
| "Mando as 4 perguntas de uma vez, ganho tempo" | Só se forem independentes. Pergunta que depende de outra, em lote, gera resposta sobre premissa errada. |
| "Apresento o escopo e já começo o plano" | Portão é portão. Apresente e ESPERE o sim. |

## Bloco de fechamento

Ao terminar, imprima no terminal o bloco de fechamento pelo formato canônico
de `templates/bloco-fechamento-template.md` (raiz do plugin). Nesta fase:

- **Produzido**: quantos critérios EARS, se o fora-de-escopo ficou explícito,
  e quantas decisões foram registradas.
- **Arquivos**: o nó (MEDIUM) ou a spec dedicada (HIGH), e a linha do índice.
- **Próximo**: o portão humano de escopo; aprovado, a fase plan.

## PRÓXIMA SKILL

Escopo aprovado → **plan**. Reabertura resolvida → devolver à fase chamadora.
