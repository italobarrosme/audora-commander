# Template — bloco de fechamento de fase

> Formato canônico do bloco que TODA skill de fase imprime ao terminar
> (`audora-commander`, `scope`, `plan`, `execute`, `e2e`, `validate`, `debug`).
> Exceção: a validate, decidido o portão, imprime o cartão de entrega no lugar do bloco.
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

## Cartão de entrega (só a validate, decidido o portão)

Decidido o portão, a validate fecha o turno com este cartão, no lugar do
bloco de fase, em TODA categoria (LIGHT, MEDIUM, HIGH, HOTFIX). É a última
parte da resposta do turno: nenhuma chamada de ferramenta depois dele (prosa
no meio do turno vira narração e some). Régua, link e ícone com palavra
seguem as regras do bloco de fase.

````markdown
---

## 🏁 DONE — <id>

<categoria> · <entregues>/<total> critérios · na main

**O que mudou**

- o sistema agora <comportamento como o usuário o vê>

**Como foi**

1. scope — <até 8 palavras>
2. plan — <até 8 palavras>
3. execute — <até 8 palavras>
4. e2e — rodado: <até 8 palavras>
5. validate — <até 8 palavras>

**Ressalvas** — nenhuma

**Mudanças no caminho**

- MODIFICADO (<data>): <antes> → <depois>

**Por critério**

- `<id>/1` ✅ entregue — o sistema agora <comportamento>

**Evidência** — <c>/<total> critérios · `<suíte ou gate>` nesta sessão → <resultado> · detalhe no roteiro do portão

**Decisões da IA** — <n>, revisadas no portão

**Como conferir**

- `<id>/1`:

```text
<comando>
```

**Arquivos** — <n> arquivos · +<a> −<r>

**Memória** — nó arquivado · PRD atualizado · CHANGELOG +1 · decisões vivas +<k> · Sobras do processo: <N> — rode a skill cleanup quando quiser.

> ▶️ **Próximo** — nenhum: demanda entregue.
````

Regras:

1. **Título e estado**: `## 🏁 DONE — <id>` com o portão aprovado; logo
   abaixo, 1 linha: categoria (do nó ou do anúncio da porta) · critérios
   entregues/total do nó · `na main` ou `na branch <nome>`.
2. **O que mudou**: 1 a 3 bullets em linguagem de usuário ("o sistema
   agora ..."), do objetivo e dos critérios do nó.
3. **Como foi**: as fases percorridas, em ordem cronológica, 1 linha cada
   com até 8 palavras; e2e marcado `rodado` ou `pulado`; fases que a
   categoria não percorre ficam fora. Sem invenção: cada resumo vem de fonte
   lida nesta sessão (nó, plano, `git log`, campo `## e2e` do nó).
4. **Ressalvas**: 1 linha por ressalva (e2e pulado, prova parcial, ressalva
   aceita no portão); sem nenhuma, `**Ressalvas** — nenhuma`.
5. **Mudanças no caminho**: 1 linha por entrada de `## delta` do nó
   (ADICIONADO / MODIFICADO antes → depois / REMOVIDO + motivo). Sem delta,
   a seção não é impressa.
6. **Por critério**: TODOS os critérios do nó, um por linha, pelo endereço
   `<id>/<n>`, com ícone e palavra (✅ entregue, ⏳ pendente, ❌ reprovado)
   e o comportamento em linguagem de usuário.
7. **Evidência** e **Decisões da IA**: 1 linha cada. Evidência = critérios
   com evidência / total, a suíte ou o gate rodado nesta sessão com o
   resultado, e "detalhe no roteiro do portão". Decisões = quantas (lista do
   plano + linhas `(IA` do `## decisoes` do nó). Sem decisão da IA, a linha
   não é impressa. O cartão nunca repete a tabela de evidência nem a lista
   de decisões do roteiro.
8. **Como conferir**: ≥ 1 item, cada um ligado ao critério que confere —
   comando em code block ` ```text ` (botão de copiar) ou tela/rota a abrir.
9. **Arquivos**: 1 linha, sem tabela de arquivos, somada do
   `git diff --numstat` real só dos commits da demanda (escopo `(<id>)` ou
   `(<id>/<n>)`), desde o pai do commit que criou o nó:

```bash
cria=$(git log --diff-filter=A --format=%H -- "docs/audora/memory/<id>.md" "docs/audora/arquivo/"*"-<id>.md" | tail -1)
[ -n "$cria" ] && git log --format= --name-only -E --grep='^[a-z]+[(]<id>[/)]' "$cria^..HEAD" | sort -u | xargs -r -d '\n' git diff --numstat "$cria^" HEAD -- | awk '{a+=$1; r+=$2; n++} END {if (n) print n " arquivos · +" a " −" r}'
```

   Saída vazia → `[SEM FONTE]`.
