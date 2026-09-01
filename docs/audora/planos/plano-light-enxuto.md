# Plano — light-enxuto: fechamento proporcional para LIGHT

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** a validate ganha um caminho de fechamento LIGHT que roda só os
passos com conteúdo, preservando portão humano e evidência 1:1.

**Nó do MEMORY:** `light-enxuto` (MEDIUM)

**Arquitetura da mudança:** seção nova `## Fechamento LIGHT` em
`skills/validate/SKILL.md`, logo antes de `## Red flags`. O item 6 (sync) e o
item 1 (oferta de e2e) ganham cada um um ponteiro de 1 linha para ela —
MEDIUM/HIGH seguem lendo o fluxo como está. A suíte assere **dentro da seção**
(extraída por `awk`), não no arquivo inteiro: assert no arquivo todo passaria
por acidente, já que `portão humano` e `evidência 1:1` aparecem no fluxo geral.

**Arquivos lidos antes de planejar:**
- `skills/validate/SKILL.md` (106 linhas) — item 1 (oferta de e2e, linha ~20),
  item 6 (sync de 8 passos, linhas 55-74), tabela de red flags e a seção
  `## Bloco de fechamento` (nova, intocada).
- `skills/audora-commander/SKILL.md` — tabela de roteamento (LIGHT =
  `execute → validate`, portão `resultado`) e item 5 (LIGHT já entra com ≥1
  critério EARS). Ambos ficam como estão: fora-de-escopo do nó.
- `tests/test-skills.sh` — bloco final; `tests/lib.sh` (`assert_contains` é
  `grep -qF`, literal e sensível a caixa).

**Conflitos MEMORY vs código encontrados:** nenhum.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

---

## Tarefa 1: suíte cobra o caminho LIGHT, dentro da seção (RED)

- **depende-de**: []
- **requisito**:
  - **light-enxuto/7** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
    reprovar se `skills/validate/SKILL.md` não declarar o caminho de
    fechamento LIGHT
  - **light-enxuto/8** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
    reprovar se o caminho LIGHT declarado dispensar o portão humano ou a
    evidência 1:1
- **decisões relevantes**: assert DENTRO da seção extraída, nunca no arquivo
  inteiro — senão `/8` passa por acidente pelo texto do fluxo geral.
- **interfaces**:
  - consome: `tests/lib.sh` — `assert_contains`, `assert_not_contains`.
  - produz: nada para outras tarefas.
- **arquivos**:
  - Modificar: `tests/test-skills.sh`
- **done quando**: `bash tests/run.sh > /dev/null 2>&1; echo $?` devolve **1**
  com falhas citando a seção `## Fechamento LIGHT` ausente.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever teste que falha** — em `tests/test-skills.sh`, antes de
  `report`:

```bash
# light-enxuto/7,/8 — caminho de fechamento LIGHT, asserido DENTRO da secao
vl="$(cat skills/validate/SKILL.md)"
assert_contains "$vl" '## Fechamento LIGHT' "/7 validate declara o caminho LIGHT"
lt="$(awk '/^## Fechamento LIGHT/{f=1;next} /^## /{f=0} f' skills/validate/SKILL.md)"
for s in 'portão humano' 'evidência 1:1'; do
  assert_contains "$lt" "$s" "/8 caminho LIGHT preserva '$s'"
done
for s in 'não tem plano' 'caminho percorrido pelo usuário' 'PRD'; do
  assert_contains "$lt" "$s" "/7 caminho LIGHT trata '$s'"
done
```

- [ ] **2. Rodar e ver falhar** — `bash tests/run.sh > /tmp/r.log 2>&1; echo $?`
  → **1**; esperado `FAIL: /7 validate declara o caminho LIGHT` e as 5 irmãs
  (a extração `awk` devolve vazio quando a seção não existe).
- [ ] **3. Commit** — `git add tests/test-skills.sh && git commit -m "test(light-enxuto/7,8): RED — suite cobra o caminho LIGHT dentro da secao"`

---

## Tarefa 2: validate ganha o caminho LIGHT (GREEN)

- **depende-de**: [Tarefa 1]
- **requisito**:
  - **light-enxuto/1** — sync roda só os passos com conteúdo real
  - **light-enxuto/2** — PRD só se alterar comportamento já descrito; não
    alterando, dizer em 1 linha por quê
  - **light-enxuto/3** — sem plano-arquivo, pular arquivamento sem listar como
    pendência
  - **light-enxuto/4** — oferta de e2e só se tocar caminho de usuário
  - **light-enxuto/5** — roteiro curto: evidência 1:1 + diff + 1 linha de como
    conferir
  - **light-enxuto/6** — portão humano e evidência 1:1 preservados
- **decisões relevantes**: as 3 do portão de escopo (PRD condicional, e2e
  condicional, portão fica e roteiro encolhe); "sem portão" foi apresentada e
  descartada explicitamente.
- **interfaces**:
  - consome: as strings exatas que a Tarefa 1 assere dentro da seção.
  - produz: `skills/validate/SKILL.md` com `## Fechamento LIGHT` + 2 ponteiros
    de 1 linha (item 1 e item 6).
- **arquivos**:
  - Modificar: `skills/validate/SKILL.md`
- **done quando**: `bash tests/run.sh > /dev/null 2>&1; echo $?` devolve **0**
  e `wc -l skills/validate/SKILL.md` ≤ 250.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Inserir a seção** antes de `## Red flags`, com o conteúdo que
  satisfaz as 6 strings asseridas e as 3 decisões do portão.
- [ ] **2. Ponteiro no item 1** (oferta de e2e) e **no item 6** (sync),
  1 linha cada, remetendo à seção.
- [ ] **3. Rodar** — `bash tests/run.sh > /dev/null 2>&1; echo $?` → **0**.
- [ ] **4. Negativo** — apagar `portão humano` da seção e conferir que `/8`
  reprova; restaurar **do backup em `/tmp`**, nunca por `git checkout`
  (aprendizado de 2026-08-31: checkout restaura do índice e apaga trabalho não
  commitado).
- [ ] **5. Commit** — `git add skills/validate/SKILL.md && git commit -m "feat(light-enxuto/1-6): caminho de fechamento LIGHT na validate"`
