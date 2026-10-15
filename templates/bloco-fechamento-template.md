# Template — bloco de fechamento de fase

> Formato canônico do bloco que TODA skill de fase imprime ao terminar
> (`audora-commander`, `scope`, `plan`, `execute`, `e2e`, `validate`, `debug`).
> Skill-ferramenta (`memory`) NÃO imprime bloco próprio: devolve à fase
> chamadora e quem imprime é ela.
>
> O bloco é **saída da conversa**, nunca arquivo versionado. Alvo principal:
> painel do Claude Code no VS Code (markdown renderizado, links clicáveis,
> tabelas, botão de copiar em code block). Tudo aqui degrada legível no
> terminal — por isso todo ícone vem acompanhado de texto.

## Recursos visuais usados (e por quê)

| recurso                             | onde entra                | o que ganha no VS Code                             |
| ----------------------------------- | ------------------------- | -------------------------------------------------- |
| `---` (régua)                       | antes do bloco            | separa o fechamento do resto da resposta           |
| `###` título com ícones             | 1ª linha                  | estado da demanda num relance                      |
| tabela                              | trilha, arquivos, entrega | alinhamento, leitura em coluna                     |
| link markdown `[nome](caminho#L42)` | arquivos, evidências      | clique abre o arquivo na linha certa               |
| `> ` citação                        | Próximo / PARADA          | destaque com barra lateral — é a chamada para ação |
| code block ` ```text `              | comando da próxima fase   | botão de copiar                                    |
| `inline code`                       | comandos, ids, flags      | distingue o literal do texto                       |

Não usar — não renderizam de forma confiável no painel nem no terminal:
diagrama `mermaid`, HTML (`<details>`, `<br>`, `<span style>`), alertas
`> [!NOTE]`, cores, checkbox `- [x]` (pode sair como texto cru).

## Ícones de estado

| ícone | estado                   | texto obrigatório ao lado |
| ----- | ------------------------ | ------------------------- |
| ✅    | concluída                | resumo de até 8 palavras  |
| ⏳    | próxima / pendente       | —                         |
| ⏸️    | aguardando portão humano | `AGUARDA PORTÃO: <qual>`  |
| ⛔    | bloqueada                | `BLOQUEADO: <motivo>`     |
| ❌    | reprovada / escalada     | `REPROVADO: <motivo>`     |
| 🛑    | parada entre fases       | `PARADA`                  |
| ▶️    | próxima ação             | —                         |

O ícone nunca carrega o significado sozinho: a palavra em caixa alta ou o
resumo sempre vem junto.

## Bloco de fase (todas as fases)

Cinco partes, nesta ordem: **título · trilha · produzido · arquivos · próximo**.

```markdown
---

### ✅ <id> · <fase> → ⏳ <próxima>

|     | fase                 | resumo           |
| :-: | -------------------- | ---------------- |
| ✅  | <fase anterior>      | <até 8 palavras> |
| ✅  | **<fase concluída>** | <até 8 palavras> |
| ⏳  | <fase pendente>      |                  |

**Produzido** — <o que esta fase entregou, 1-2 linhas>

**Arquivos**

| arquivo                | o quê                               | tamanho          |
| ---------------------- | ----------------------------------- | ---------------- |
| [<nome>](caminho/real) | <papel do arquivo, poucas palavras> | <KB ou contagem> |

> ▶️ **Próximo** — <a próxima ação concreta>
```

Regras:

1. **Régua**: o bloco abre com `---` em linha própria, com linha em branco
   antes e depois.
2. **Título**: `### <ícone> <id> · <fase que acabou> → <ícone> <próxima>`. O
   ícone da fase que acabou segue a tabela de estados (✅, ⛔, ❌, ⏸️); a
   próxima leva ⏳. O `<id>` vai sem crase no título.
3. **Trilha**: tabela com uma linha por fase que a categoria percorre, em
   **ordem cronológica**. A fase **em foco** vai em **negrito** — a
   recém-concluída; ou, se a fase foi interrompida, bloqueada ou aguarda
   portão, a própria fase em curso. Concluída leva resumo de até 8 palavras;
   pendente fica com a célula de resumo vazia.
4. **Arquivos**: sempre **caminho real** e existente, como link markdown
   relativo à raiz do workspace — `[client.ts](src/http/client.ts)`. Regras do
   link:
   - texto do link = nome do arquivo (sem crase dentro dos colchetes);
   - destino = caminho relativo, sem `file://`, sem `./`, espaço vira `%20`;
   - âncora `#L42` ou `#L42-L60` só quando a linha importa (ponto do fix,
     onde travou);
   - tamanho/contagem vem de comando (`wc -c`, `wc -l`, `ls -lh`), não de
     estimativa.

   Caminho prometido, planejado ou inventado é falha do bloco — se o arquivo
   ainda não existe, ele não entra. Um único arquivo pode ir em linha:
   `**Arquivos** — [plano.md](docs/audora/planos/plano.md) (4,2 KB)`.

5. **Próximo**: sempre em citação (`> `), uma ação concreta, nunca
   "continuar". Se a próxima ação é um portão humano, diga isso
   (`> ⏸️ **Próximo** — portão humano: aprovar o escopo`). Quando a ação é um
   comando para o humano rodar, ele vai num code block ` ```text ` dentro da
   citação, para ganhar o botão de copiar. Fim de scope, plan ou execute de
   MEDIUM/HIGH → PARADA (seção abaixo).

## Parada entre fases

Fim de scope, plan ou execute de MEDIUM/HIGH é PARADA: a fase NÃO emenda a
fase seguinte na mesma resposta. O **Próximo** do bloco fica:

````markdown
> 🛑 **PARADA** — rode `/clear` e, na sessão nova, cole:
>
> ```text
> <fase> de <id>
> ```
````

Sem parada: porta de entrada → 1ª fase; LIGHT, HOTFIX; e2e ↔ validate.

- Humano diz "agente", "continua" ou "sem clear" → a fase seguinte roda em
  subagente de contexto zerado pelo
  [fase-subagente-template.md](templates/fase-subagente-template.md); a sessão
  principal recebe só o bloco dele.
- Retomada (`<fase> de <id>`) com id fora do índice ou artefato da fase
  ausente → recusar nomeando o que falta e a fase certa.
- Fase interrompida, bloqueada ou reprovada não tem PARADA: o **Próximo** é a
  decisão humana pendente.

## Categoria LIGHT e HOTFIX

LIGHT percorre `execute → validate`; HOTFIX percorre `execute → validate` com
registro retroativo. As fases que a categoria **não percorre** ficam FORA da
trilha — nunca aparecem como ⏳ pendente eterna. Exemplo LIGHT:

```markdown
---

### ✅ corrigir-timeout · execute → ⏳ validate

|     | fase        | resumo                      |
| :-: | ----------- | --------------------------- |
| ✅  | **execute** | teste red, fix, suíte verde |
| ⏳  | validate    |                             |

**Produzido** — 1 teste de reprodução + fix; suíte 364 asserts, exit 0.

**Arquivos**

| arquivo                                   | o quê                | tamanho |
| ----------------------------------------- | -------------------- | ------- |
| [client.ts:42](src/http/client.ts#L42)    | timeout configurável | 3,1 KB  |
| [client.test.ts](src/http/client.test.ts) | teste de reprodução  | 1,4 KB  |

> ▶️ **Próximo** — portão final (validate)
```

## Fase interrompida, bloqueada ou reprovada

O bloco é impresso do mesmo jeito — **nunca omitido**. A fase leva ⛔ ou ❌
(nunca ✅), fica em negrito e o motivo aparece em 1 linha na coluna resumo:

```markdown
---

### ⛔ migrar-cobranca · execute → bloqueado

|     | fase        | resumo                                            |
| :-: | ----------- | ------------------------------------------------- |
| ✅  | scope       | 6 critérios, aprovado                             |
| ✅  | plan        | 5 tarefas                                         |
| ⛔  | **execute** | BLOQUEADO: SDK de pagamento sem versão compatível |
| ⏳  | validate    |                                                   |

**Produzido** — T1 e T2 verdes; T3 parou na dependência.

**Arquivos** — [plano-migrar-cobranca.md](docs/audora/planos/plano-migrar-cobranca.md) (notas de sessão)

> ⏸️ **Próximo** — decisão humana:
>
> 1. reverter T1–T2
> 2. esperar release do SDK
> 3. trocar de lib
```

Vale para portão reprovado (❌ `REPROVADO:`), escalada de debug — 3 hipóteses
refutadas (❌ `REPROVADO: 3 hipóteses refutadas`) — e falha irrecuperável de
execute (⛔ `BLOQUEADO:`). Quando a decisão humana tem opções, elas vão em
lista numerada dentro da citação, para o humano responder só com o número.

## Relatório de entrega (só a validate, decidido o portão)

Sai em TODA categoria (LIGHT, MEDIUM, HIGH, HOTFIX) e em TODA decisão do
portão — aprovado, parcial ou reprovado —, depois do bloco de fase, como a
última parte da resposta do turno: nenhuma chamada de ferramenta depois dele
(prosa no meio do turno vira narração e some). Seções nesta ordem; as
marcadas (opcional) são omitidas quando vazias, as outras saem sempre.

````markdown
#### Relatório de entrega — <id>

**Demanda** — <categoria> · <n> critérios

> <objetivo copiado do campo `objetivo` do nó, 1-2 frases>

**Mudanças no caminho** (opcional — só com entrada em `## delta` do nó)

- ADICIONADO (<data>): <o que entrou>
- MODIFICADO (<data>): <antes> → <depois>
- REMOVIDO (<data>): <o que saiu> — <motivo>

**Entregue**

- `<id>/1` ✅ entregue — o sistema agora <comportamento como o usuário o vê>
- `<id>/2` ⏳ pendente — o sistema <comportamento prometido>
- `<id>/3` ❌ reprovado — o sistema <comportamento prometido>

**Evidência**

| critério | evidência                                              |
| -------- | ------------------------------------------------------ |
| `<id>/1` | `<comando rodado nesta sessão>` → <resultado, 1 linha> |
| `<id>/2` | ⏳ <motivo: o que falta>                               |
| `<id>/3` | ❌ <motivo: o que reprovou>                            |

**Como conferir**

`<id>/1`:

```text
<comando>
```

`<id>/2` — abrir <tela ou rota>

**Decisões tomadas pela IA** (opcional — só quando a demanda tiver alguma)

- <decisão de implementação, 1 linha>

**Arquivos tocados** — `git diff --numstat <base>..HEAD`

| arquivo                     |      + |      − |
| --------------------------- | -----: | -----: |
| [um.ts](caminho/real/um.ts) |     42 |      7 |
| ~~caminho/antigo.ts~~       |      0 |     31 |
| **total: 2 arquivos**       | **42** | **38** |
````

Regras:

1. **Demanda**: categoria (do nó ou do anúncio da porta nesta sessão) e
   total de critérios do nó; o objetivo é cópia literal do campo `objetivo`,
   nunca reescrito de memória.
2. **Entregue**: TODOS os critérios do nó, um por linha, pelo endereço
   `<id>/<n>`, com ícone e palavra (✅ entregue, ⏳ pendente, ❌ reprovado)
   e o comportamento em linguagem de usuário ("o sistema agora ...").
3. **Evidência**: uma linha por critério — comando executado nesta sessão +
   resultado em 1 linha, ou link para o teste com âncora de linha. Critério
   ⏳ ou ❌ leva o motivo no lugar da evidência.
4. **Mudanças no caminho**: uma linha por entrada de `## delta` do nó
   (ADICIONADO / MODIFICADO antes → depois / REMOVIDO + motivo). Sem delta,
   a seção não é impressa.
5. **Como conferir**: ≥ 1 item, cada um ligado ao critério que confere —
   comando em code block ` ```text ` (botão de copiar) ou tela/rota a abrir.
6. **Decisões tomadas pela IA**: uma linha por decisão — a lista do plano
   (item 4 do fluxo) e as linhas `(IA` do `## decisoes` do nó. Sem nenhuma,
   a seção não é impressa.
7. **Arquivos tocados**: nomes, adições e remoções copiados da saída do
   `git diff --numstat` real, total somado dela; arquivo existente com link
   clicável, arquivo removido sem link (`~~caminho/antigo.ts~~`). Lista ou
   número de memória é falha do bloco.
8. Dado sem fonte lida nesta sessão (nó, saída de comando, diff) → a célula
   recebe `[SEM FONTE]` e o critério ligado fica ⏳; nunca preencher de
   memória.
9. Portão reprovado ou parcial imprime o relatório do mesmo jeito, veredito
   por critério; o bloco de fase leva ❌ e o Próximo aponta a decisão humana
   ou a fase de retorno (scope ou plan). Nunca omitir o relatório.
10. Não entra medição antes/depois nem "o que ficou de fora": a medição vive
    no corpo do nó quando a demanda tiver, e o fora-de-escopo é campo do nó.
