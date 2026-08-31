# Template — bloco de fechamento de fase

> Formato canônico do bloco que TODA skill de fase imprime no terminal ao
> terminar (`audora-commander`, `scope`, `plan`, `execute`, `e2e`, `validate`,
> `debug`). Skill-ferramenta (`memory`, `worktree`) NÃO imprime bloco próprio:
> devolve à fase chamadora e quem imprime é ela.
>
> O bloco é **saída de terminal**, nunca arquivo versionado. Markdown puro —
> sem cor, sem TUI, sem emoji obrigatório.

## Bloco de fase (todas as fases)

Cinco partes, nesta ordem:

```markdown
### <id> · <fase> → <próxima>

- [x] **<fase concluída>** — <resumo de até 8 palavras>
- [x] <fase anterior> — <resumo de até 8 palavras>
- [ ] <fase pendente>

**Produzido** — <o que esta fase entregou, 1-2 linhas>

**Arquivos** — `<caminho real>` (<tamanho ou contagem>)

**Próximo** — <a próxima ação concreta>
```

Regras:

1. **Título**: id da demanda, fase que acabou, próxima fase. A fase que acabou
   leva `✅` ou nada; a próxima leva `⏳` ou nada — enfeite é opcional, o texto
   não.
2. **Checkbox**: `[x]` para concluída, `[ ]` para pendente. A fase **em foco**
   vai em **negrito** — a recém-concluída; ou, se a fase foi interrompida,
   bloqueada ou aguarda portão, a própria fase em curso. Cada concluída leva um resumo de até 8
   palavras ao lado; pendente vai sem resumo.
3. **Arquivos**: sempre **caminho real** e existente, com tamanho ou contagem
   quando ajudar. Caminho prometido, planejado ou inventado é falha do bloco —
   se o arquivo ainda não existe, ele não entra.
4. **Próximo**: uma ação concreta, não "continuar". Se a próxima ação é um
   portão humano, diga isso.

## Categoria LIGHT e HOTFIX

LIGHT percorre `execute → validate`; HOTFIX percorre `execute → validate` com
registro retroativo. As fases que a categoria **não percorre** ficam FORA da
lista — nunca aparecem como `[ ]` pendente eterna. Exemplo LIGHT:

```markdown
### corrigir-timeout · execute → validate

- [x] **execute** — teste red, fix, suíte verde
- [ ] validate

**Produzido** — 1 teste de reprodução + fix; suíte 364 asserts, exit 0.

**Arquivos** — `src/http/client.ts`, `src/http/client.test.ts`

**Próximo** — portão final (validate)
```

## Fase interrompida, bloqueada ou reprovada

O bloco é impresso do mesmo jeito — **nunca omitido**. A fase fica NÃO marcada
e o motivo aparece em 1 linha:

```markdown
### migrar-cobranca · execute ⛔ → bloqueado

- [x] scope — 6 critérios, aprovado
- [x] plan — 5 tarefas
- [ ] **execute** — BLOQUEADO: SDK de pagamento sem versão compatível
- [ ] validate

**Produzido** — T1 e T2 verdes; T3 parou na dependência.

**Arquivos** — `docs/audora/planos/plano-migrar-cobranca.md` (notas de sessão)

**Próximo** — decisão humana: reverter, esperar release do SDK, ou trocar de lib
```

Vale para portão reprovada, escalada de debug (3 hipóteses refutadas) e
falha irrecuperável de execute.

## Bloco de entrega (só a validate, após aprovação)

Soma ao bloco de fase. Duas partes:

```markdown
**Entrega** — <id>: <o que a demanda passou a fazer, 1-2 linhas>

| critério | veredito | evidência |
|---|---|---|
| <id>/1 | passou | <comando + resultado, 1 linha> |
| <id>/2 | passou | <comando + resultado, 1 linha> |

**Arquivos tocados** — de `git diff --name-only <base>..HEAD`, nunca de memória:

- `caminho/real/um.ts`
- `caminho/real/dois.ts`
```

Regras:

1. A tabela cobre **todos** os critérios do nó, um por linha. Critério sem
   evidência não vira linha bonita — ele reprova o portão antes de chegar aqui.
2. A lista de arquivos sai do `git diff --name-only` real da demanda. Lista
   escrita de memória é falha do bloco.
3. Não entra medição antes/depois nem "o que ficou de fora": a medição vive no
   corpo do nó quando a demanda tiver, e o fora-de-escopo é campo do nó.
