# Plano — decisoes-vivas-poda: regra de entrada e auditoria

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** acrescentar a regra de entrada (só entra decisão que não dá para
impor por teste/hook/config) e tirar de circulação, por marcação, as 8 entradas
já impostas ou mortas.

**Nó do MEMORY:** `decisoes-vivas-poda` (HIGH) · escopo em
`docs/audora/specs/decisoes-vivas-poda-escopo.md`

**Arquitetura da mudança:** três frentes independentes entre si — (a) a regra
vira texto normativo em `skills/validate/SKILL.md`, itens 3 e 6; (b) as 8
entradas ganham os marcadores na própria linha; (c) a suíte guarda a
consistência dos marcadores. Nada de script: a classificação "isto é imponível
por teste?" é julgamento (fora-de-escopo da spec) e a Constituição restringe
executável a `hooks/` e `tests/`.

**Arquivos lidos antes de planejar:**
- `docs/audora/decisoes-vivas.md` (32 linhas) — 17 entradas, cada uma em UMA
  linha começando por `- 20`, formato `data | nó | decisão`; rodapé com 3
  regras em bloco de comentário HTML.
- `skills/validate/SKILL.md` (135 linhas) — item 3 (decisões vivas propostas,
  linhas 37-39) e item 6 (promover ao arquivo, linhas 61-62); a seção
  `## Fechamento LIGHT` recém-entregue fica intocada.
- `tests/test-skills.sh` e `tests/lib.sh` — `assert_empty` e `assert_contains`
  (`grep -qF`, literal e sensível a caixa; string asserida cabe em UMA linha).
- `templates/decisoes-vivas-template.md` — NÃO muda (decisão do portão: a
  regra vive na skill, não no template).

**ARMADILHA verificada:** `grep -c invalidado-em docs/audora/decisoes-vivas.md`
devolve **1 hoje, com zero entradas marcadas** — o acerto vem do texto da regra
2 no rodapé. Todo assert de /6 e /7 tem de filtrar antes por `^- 20` (linhas de
entrada), senão o rodapé dá falso verde ou falso vermelho.

**Conflitos MEMORY vs código encontrados:** nenhum. A regra 2 do rodapé
("nunca apagar") não é contrariada — é justamente o mecanismo escolhido.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

---

## Tarefa 1: suíte guarda os marcadores e a regra (RED)

- **depende-de**: []
- **requisito**:
  - **decisoes-vivas-poda/5** — QUANDO a suíte de regressão rodar O SISTEMA
    DEVE reprovar se `skills/validate/SKILL.md` não declarar a regra de
    entrada: só entra decisão que NÃO dá para impor por teste, hook ou config
  - **decisoes-vivas-poda/6** — QUANDO a suíte de regressão rodar O SISTEMA
    DEVE reprovar se alguma linha de `docs/audora/decisoes-vivas.md` tiver
    `[invalidado-em:` sem o `[substituido-por:` correspondente
  - **decisoes-vivas-poda/7** — QUANDO a suíte de regressão rodar O SISTEMA
    DEVE reprovar se um `substituido-por` citar caminho de arquivo que não
    existe no repositório
- **decisões relevantes**: filtrar por `^- 20` antes de qualquer assert (a
  armadilha do rodapé, verificada acima).
- **interfaces**:
  - consome: `tests/lib.sh` — `assert_contains`, `assert_empty`.
  - produz: nada para outras tarefas.
- **arquivos**:
  - Modificar: `tests/test-skills.sh`
- **done quando**: `bash tests/run.sh > /dev/null 2>&1; echo $?` devolve **1**,
  falhando em `/5` (regra ainda não declarada) e passando em `/6` e `/7`
  (nenhuma entrada marcada ainda — vazio é válido).

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever teste que falha** — em `tests/test-skills.sh`, antes de
  `report`:

```bash
# decisoes-vivas-poda/5,/6,/7 — regra de entrada e consistencia dos marcadores
vd="$(cat skills/validate/SKILL.md)"
assert_contains "$vd" 'impor por teste, hook ou config' "/5 validate declara a regra de entrada"
dv='docs/audora/decisoes-vivas.md'
ents="$(grep '^- 20' "$dv" || true)"   # SO linhas de entrada; o rodape cita os marcadores
bad="$(printf '%s\n' "$ents" | grep 'invalidado-em' | grep -v 'substituido-por' || true)"
assert_empty "$bad" "/6 invalidado-em sem substituido-por"
falta=""
for ref in $(printf '%s\n' "$ents" | grep -o 'substituido-por: [^]]*' | sed 's/substituido-por: //'); do
  [ -e "$ref" ] || falta="$falta $ref"
done
assert_empty "$falta" "/7 substituido-por aponta arquivo inexistente"
```

- [ ] **2. Rodar e ver falhar** — `bash tests/run.sh > /tmp/r.log 2>&1; echo $?`
  → **1**, com `FAIL: /5 validate declara a regra de entrada`. `/6` e `/7`
  passam já agora (zero entradas marcadas), o que é correto: eles guardam a
  Tarefa 3.
- [ ] **3. Commit** — `git add tests/test-skills.sh && git commit -m "test(decisoes-vivas-poda/5,6,7): RED — regra de entrada e consistencia dos marcadores"`

---

## Tarefa 2: regra de entrada na skill validate

- **depende-de**: [Tarefa 1]
- **requisito**:
  - **decisoes-vivas-poda/1** — QUANDO a validate propuser decisões vivas no
    portão O SISTEMA DEVE excluir da proposta toda decisão que já seja imposta
    por teste, hook ou config, dizendo em 1 linha qual artefato a impõe
  - **decisoes-vivas-poda/5** (verbatim na Tarefa 1)
- **decisões relevantes**: a regra vive na skill, não no rodapé do arquivo nem
  no template (portão de escopo) — rodapé e template derivam; a skill viaja
  para todo projeto que usa o framework.
- **interfaces**:
  - consome: nada.
  - produz: a string literal `impor por teste, hook ou config` em UMA linha,
    que a Tarefa 1 assere.
- **arquivos**:
  - Modificar: `skills/validate/SKILL.md` (item 3 e item 6)
- **done quando**: `/5` passa e a suíte segue verde no resto.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Item 3** — acrescentar ao bullet "Decisões vivas propostas":
  filtro de entrada, com a frase asserida em uma linha só.
- [ ] **2. Item 6** — 1 linha lembrando que o sync só escreve o que passou no
  filtro do item 3.
- [ ] **3. Rodar** — `bash tests/run.sh > /dev/null 2>&1; echo $?` → **0**.
- [ ] **4. Commit** — `git add skills/validate/SKILL.md && git commit -m "feat(decisoes-vivas-poda/1,5): regra de entrada das decisoes vivas na validate"`

---

## Tarefa 3: auditar e marcar as 8 entradas

- **expandir: sim** — quebrar em subtarefas (uma por entrada) SÓ quando chegar
  a vez dela. Cada entrada exige confirmar, no artefato real, que ele de fato
  impõe a decisão — é o trabalho, não formalidade.
- **depende-de**: [Tarefa 2]
- **requisito**:
  - **decisoes-vivas-poda/2** — entrada já imposta ganha `[invalidado-em:]` +
    `[substituido-por: <caminho>]`, nunca apagada
  - **decisoes-vivas-poda/3** — entrada morta usa o mesmo par, apontando o que
    a tornou obsoleta
  - **decisoes-vivas-poda/4** — entrada que é racional arquitetural não
    imponível por teste fica INTOCADA
- **decisões relevantes**: marcar, não apagar (portão de escopo); os 7
  caminhos candidatos já foram verificados como existentes, mas a EXISTÊNCIA
  não basta — cada um precisa de confirmação de que o artefato realmente impõe
  a decisão.
- **interfaces**:
  - consome: a tabela de auditoria da spec de escopo.
  - produz: `docs/audora/decisoes-vivas.md` com 8 linhas marcadas e 9
    intocadas.
- **arquivos**:
  - Modificar: `docs/audora/decisoes-vivas.md`
- **done quando**: `grep -c '^- 20' docs/audora/decisoes-vivas.md` segue
  **17** (nenhuma apagada), `grep '^- 20' … | grep -c invalidado-em` dá **8**,
  e `bash tests/run.sh` sai **0**.
