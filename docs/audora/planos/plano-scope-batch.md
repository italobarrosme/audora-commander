# Plano — scope-batch: perguntas em lote na fase scope

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** trocar a regra "nunca duas perguntas na mesma mensagem" por
agrupamento de perguntas independentes (máx. 4), com teste de dependência
explícito para o que continua em série.

**Nó do MEMORY:** `scope-batch` (MEMORY.md)

**Arquitetura da mudança:** demanda de superfície pequena — o item 2 do fluxo
de `skills/scope/SKILL.md` é reescrito e ganha o teste de dependência; a red
flag correspondente é ajustada; a suíte passa a cobrar a ausência da regra
antiga e a presença do teste. Nada de novo arquivo: o formato da pergunta é
capacidade do harness (`AskUserQuestion`), não schema do framework, então NÃO
vira template.

**Arquivos lidos antes de planejar:**
- `skills/scope/SKILL.md` (94 linhas) — item 2 do fluxo nas linhas 23-25
  (`**Perguntas — uma por vez.**` … `Nunca duas perguntas na mesma mensagem.`)
  e a tabela de red flags; a seção `## Bloco de fechamento` (nova) fica
  intocada.
- `tests/test-skills.sh` — bloco final é onde entram os asserts de /7 e /8;
  `assert_not_contains` já existe em `tests/lib.sh`.
- `tests/lib.sh` — `assert_contains` é `grep -qF`: literal, sensível a caixa,
  string com `-` inicial precisa de `--`.

**Conflitos MEMORY vs código encontrados:** nenhum. A red flag atual
*"Apresento o escopo e já começo o plano"* é sobre o PORTÃO, não sobre a
cadência das perguntas — fica como está (fora-de-escopo do nó protege o
portão).

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

---

## Tarefa 1: suíte cobra a regra nova (RED)

- **depende-de**: []
- **requisito**:
  - **scope-batch/7** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
    reprovar se `skills/scope/SKILL.md` ainda contiver a regra antiga "Nunca
    duas perguntas na mesma mensagem"
  - **scope-batch/8** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
    reprovar se `skills/scope/SKILL.md` não declarar o teste de dependência
    entre perguntas (o critério que decide série vs lote)
- **decisões relevantes**: teto de 4 é limite do harness (`AskUserQuestion`
  aceita 1-4), documentado como tal para não parecer número mágico.
- **interfaces**:
  - consome: `tests/lib.sh` — `assert_contains`, `assert_not_contains`.
  - produz: nada para outras tarefas.
- **arquivos**:
  - Modificar: `tests/test-skills.sh`
- **done quando**: `bash tests/run.sh > /dev/null 2>&1; echo $?` devolve **1**
  com falha em `/7 scope sem a regra antiga` e `/8 scope declara o teste de
  dependência`.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever teste que falha** — em `tests/test-skills.sh`, antes de
  `report`:

```bash
# scope-batch/7,/8 — perguntas em lote, com teste de dependencia declarado
sc="$(cat skills/scope/SKILL.md)"
assert_not_contains "$sc" 'Nunca duas perguntas na mesma mensagem' "/7 scope sem a regra antiga"
for s in 'Perguntas — em lote' 'independentes' 'no máximo 4' 'teste de dependência' 'em série'; do
  assert_contains "$sc" "$s" "/8 scope declara '$s'"
done
```

- [ ] **2. Rodar e ver falhar** — `bash tests/run.sh > /tmp/r.log 2>&1; echo $?`
  → **1**; esperado `FAIL: /7 scope sem a regra antiga — contém '...'` e as 5
  de `/8`.
- [ ] **3. Commit** — `git add tests/test-skills.sh && git commit -m "test(scope-batch/7,8): RED — suite cobra lote e teste de dependencia"`

---

## Tarefa 2: reescrever a regra na skill scope (GREEN)

- **depende-de**: [Tarefa 1]
- **requisito**:
  - **scope-batch/1** — QUANDO a fase scope tiver 2 ou mais esclarecimentos
    independentes entre si O SISTEMA DEVE apresentá-los num único lote, no
    máximo 4 por vez
  - **scope-batch/2** — QUANDO duas perguntas forem dependentes (a resposta de
    uma muda o enunciado, as opções ou a própria existência da outra) O
    SISTEMA DEVE mantê-las em série, nunca no mesmo lote
  - **scope-batch/3** — QUANDO um lote for apresentado O SISTEMA DEVE usar
    múltipla escolha com opções enumeradas sempre que as opções forem
    enumeráveis
  - **scope-batch/4** — QUANDO uma pergunta do lote for decisão de formato ou
    layout com alternativas concretas O SISTEMA DEVE mostrar preview de cada
    alternativa em vez de descrevê-las em prosa
  - **scope-batch/5** — QUANDO houver mais de 4 lacunas independentes O
    SISTEMA DEVE priorizar as que mais mudam escopo e deixar as demais para o
    lote seguinte, dizendo que há lote seguinte
  - **scope-batch/6** — QUANDO o lote for respondido O SISTEMA DEVE registrar
    cada escolha como decisão no nó, uma linha por escolha, incluindo a
    alternativa descartada e por quê
- **decisões relevantes**: a mudança é de CADÊNCIA; o direito de não responder
  (`[PRECISA-CLARIFICAR]`) e o portão de escopo ficam intocados
  (fora-de-escopo do nó).
- **interfaces**:
  - consome: as strings exatas que a Tarefa 1 assere.
  - produz: `skills/scope/SKILL.md` com o item 2 reescrito.
- **arquivos**:
  - Modificar: `skills/scope/SKILL.md` (item 2 do fluxo + 1 linha da tabela de
    red flags)
- **done quando**: `bash tests/run.sh > /dev/null 2>&1; echo $?` devolve **0**
  e `wc -l skills/scope/SKILL.md` ≤ 250.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Substituir o item 2** por:

```markdown
2. **Perguntas — em lote.** Só sobre comportamento: o que o usuário vê, o que
   o sistema faz, o que acontece no erro. Prefira múltipla escolha quando as
   opções são enumeráveis; decisão de formato ou layout vai com PREVIEW de
   cada alternativa, nunca descrita em prosa.
   - **Teste de dependência** (o que decide lote vs série): a resposta de uma
     pergunta muda o enunciado, as opções ou a própria existência da outra?
     **Sim** → série, uma de cada vez. **Não** → mesmo lote.
   - Perguntas independentes vão juntas, **no máximo 4** por lote (limite da
     ferramenta do harness, não preferência).
   - Mais de 4 lacunas independentes → priorize as que mais mudam o escopo e
     diga que há lote seguinte. Truncar em silêncio é pior que perguntar duas
     vezes.
   - Respondido o lote, cada escolha vira uma linha em `## decisoes` do nó,
     com a alternativa descartada e o motivo.
```

- [ ] **2. Ajustar a red flag** — trocar a linha da tabela que defende a
  cadência antiga, se houver, por:

```markdown
| "Mando as 4 perguntas de uma vez, ganho tempo" | Só se forem independentes. Pergunta que depende de outra, em lote, gera resposta baseada em premissa errada. |
```

- [ ] **3. Rodar e ver passar** — `bash tests/run.sh > /dev/null 2>&1; echo $?`
  → **0**; conferir também `bash tests/test-skills.sh` com `FAIL=0`.
- [ ] **4. Commit** — `git add skills/scope/SKILL.md && git commit -m "feat(scope-batch/1-6): perguntas em lote com teste de dependencia"`
