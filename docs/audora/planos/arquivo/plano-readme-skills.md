# Plano — readme-skills: README por skill

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive.

**Objetivo:** READMEs EN e PT com seção detalhada por skill.

**Nó do MEMORY:** `readme-skills`

**Arquitetura da mudança:** seção nova `## Skills in detail` / `## As skills
em detalhe` logo depois da tabela-resumo, com `### \`<skill>\`` por skill e
os 5 rótulos em negrito. Sem bloco de código cercado nas subseções (o teste
de blocos idênticos EN/PT compara só blocos cercados). Guarda em
`tests/test-docs.sh` itera `skills/*/` — skill nova sem doc reprova.

**Arquivos lidos antes de planejar:** `README.md`, `README.pt-BR.md` (tabela
das 9 skills, fluxo de uso, artefatos), `tests/test-docs.sh` (blocos
idênticos, asserts de seção), os 9 `skills/*/SKILL.md` e as references de
memory e validate (fonte do conteúdo, 0.9.0).

**Conflitos MEMORY vs código encontrados:** nenhum.

## Notas de sessão

---

## Tarefa 1: guarda da seção por skill

- **depende-de**: []
- **requisito**: **readme-skills/1**, **readme-skills/2**, **readme-skills/3** (ver nó); **readme-skills/5** (tabela e link).
- **arquivos**: Teste `tests/test-docs.sh`.

- [x] **1. Red** — antes do `report` de `test-docs.sh`:
  ```bash
  # readme-skills/1,/2,/3 — toda skill tem subseção com os 5 rótulos nos 2 READMEs
  sec() { awk -v h="### \`$2\`" '$0==h{f=1;next} /^##/{f=0} f' "$1"; }
  for d in skills/*/; do
    s="$(basename "$d")"
    en="$(sec README.md "$s")"; pt="$(sec README.pt-BR.md "$s")"
    [ -n "$en" ] && ok || ko "readme-skills/3 README.md sem subseção da skill $s"
    [ -n "$pt" ] && ok || ko "readme-skills/3 README.pt-BR.md sem subseção da skill $s"
    for l in '**When it fires**' '**What it does**' '**What it leaves on disk**' '**Human gates**' '**Next**'; do
      assert_contains "$en" "$l" "readme-skills/1 $s EN tem $l"
    done
    for l in '**Quando dispara**' '**O que faz**' '**O que deixa no disco**' '**Portões humanos**' '**Próxima**'; do
      assert_contains "$pt" "$l" "readme-skills/2 $s PT tem $l"
    done
  done
  assert_contains "$en" '## Skills in detail' "readme-skills/5 EN tem a seção"
  assert_contains "$(cat README.md)" '(#skills-in-detail)' "readme-skills/5 tabela EN linka o detalhe"
  assert_contains "$(cat README.pt-BR.md)" '(#as-skills-em-detalhe)' "readme-skills/5 tabela PT linka o detalhe"
  ```
  (corrigir: o assert da seção lê `$(cat README.md)`, não `$en`.)
- [x] **2. Rodar** `bash tests/test-docs.sh` → FAIL por skill ausente.

## Tarefa 2: conteúdo EN + PT

- **depende-de**: [Tarefa 1]
- **requisito**: **readme-skills/1**, **/2**, **/4**, **/5**.
- **decisões relevantes**: fonte = SKILL.md 0.9.0 (portões da tabela de roteamento; `references/` da memory e da validate; `plano-<id>.md` com teste + assinaturas; `hooks/loop`; `/clear` recomendado); sem cercas de código.
- **arquivos**: Modificar `README.md`, `README.pt-BR.md`.
- **done quando**: test-docs verde; leitura cruzada /4 no roteiro; gate.

- [x] **3. Implementar** — seção EN e PT; linha abaixo da tabela: "Details per skill: [Skills in detail](#skills-in-detail)" / "Detalhe por skill: [As skills em detalhe](#as-skills-em-detalhe)".
- [x] **4. Rodar** test-docs → verde; gate.
- [x] **5. Commit** `docs(readme-skills/1,2,3,5): seção detalhada por skill nos 2 READMEs + guarda`.
