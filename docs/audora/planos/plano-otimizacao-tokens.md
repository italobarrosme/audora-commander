# Plano — otimizacao-tokens: Otimização de tokens

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** cortar o custo de token do framework (contexto, plano, loop)
sem tirar portão nem evidência.

**Nó do MEMORY:** `otimizacao-tokens` (critérios no nó, MEDIUM)

**Arquitetura da mudança:** quatro frentes independentes. (1) `hooks/loop`
monta `{{PLANO}}` com cabeçalho + notas em vez do plano inteiro. (2) `plan`
e `plano-template` trocam "código real nos passos" por teste + assinaturas.
(3) `validate` vira roteador + `references/` (padrão já provado na skill
memory, decisão viva 2026-08-31): `sync.md`, `decisoes-vivas.md`,
`fechamento-light.md`; asserts da suíte migram para o arquivo onde o texto
mora (movimento, nunca perda). (4) Regra "já carregado → não reler" na
memory e nos blocos de fechamento; `/clear` recomendado no bloco. Teto de
bytes em `tests/test-carga.sh` fecha a porta para reinchar.

**Linha de base (medida em `main`, bytes):** BASE até o portão = 56237
(audora-commander + memory + registrar-no + no-template + scope + plan +
consultar-codigo + plano-template + execute + validate + bloco-fechamento);
FULL MEDIUM aprovado = 58036 (+ compactar); `validate/SKILL.md` = 11603.

**Arquivos lidos antes de planejar:**
- `hooks/loop` — linhas 143-148 montam o prompt com o plano inteiro.
- `templates/loop-prompt-template.md` — `=== PLANO ===` + `{{PLANO}}`.
- `tests/test-loop.sh` — fixture `mkloop` (notas no FIM do plano), asserts do prompt (81-85, 142-144), placeholders (9-11).
- `skills/plan/SKILL.md` (itens 5 e 6), `templates/plano-template.md` (passos, proibições).
- `skills/validate/SKILL.md` inteiro; asserts dele em `tests/test-skills.sh` (86-89, 104-106, 114-127, 160-173), `tests/test-autopilot.sh` (54-72), `tests/test-gate.sh` (87-91), `tests/test-loop.sh` (199-201).
- `skills/memory/SKILL.md` (roteador, leitura seletiva), `templates/bloco-fechamento-template.md`, seções `## Bloco de fechamento` das 7 skills de fase, "Fechar a fase" de scope e plan.
- `.claude-plugin/*.json`, `tests/test-docs.sh` (versão).

**Conflitos MEMORY vs código encontrados:** nenhum.

## Notas de sessão

---

## Tarefa 1: prompt de volta enxuto no motor de loop

- **depende-de**: []
- **requisito**: **otimizacao-tokens/6** — QUANDO o motor de loop montar o prompt de uma volta O SISTEMA DEVE incluir o cabeçalho do plano (até a primeira `## Tarefa`), a seção da tarefa escolhida e `## Notas de sessão` (onde estiver), e NÃO o texto das outras tarefas; plano sem notas monta o prompt sem erro.
- **interfaces**: produz função `plano_base()` em `hooks/loop` (stdout = cabeçalho + notas); `{{PLANO}}` passa a significar esse recorte.
- **arquivos**: Modificar `hooks/loop`, `templates/loop-prompt-template.md`; Teste `tests/test-loop.sh`.
- **done quando**: prompt da volta 1 sem `## Tarefa 2`, com `# Plano — d1` e `## Notas de sessão`; fixture sem notas → rodada DONE.

- [ ] **1. Red** — em `test-loop.sh`, após o assert `/5 tarefa 2 fora da seção da volta 1`:
  ```bash
  assert_not_contains "$(cat "$p1")" '## Tarefa 2' "otimizacao-tokens/6 prompt inteiro sem a tarefa 2"
  assert_contains "$(cat "$p1")" '# Plano — d1' "otimizacao-tokens/6 prompt leva o cabeçalho"
  assert_contains "$(cat "$p1")" '## Notas de sessão' "otimizacao-tokens/6 prompt leva as notas (no fim do plano)"
  ```
  e um caso novo sem notas (antes do bloco `/8`):
  ```bash
  mkloop; sed -i '/^## Notas de sessão/d' "$lproj/docs/audora/planos/plano-d1.md"; git -C "$lproj" commit -qam sem-notas
  runloop d1
  assert_eq 0 "$code" "otimizacao-tokens/6 plano sem notas → DONE"
  assert_not_contains "$(cat "$lproj/docs/audora/planos/loop/d1/rodada1-volta1-prompt.txt")" '## Tarefa 2' "otimizacao-tokens/6 sem notas, sem tarefa 2"
  ```
  E placeholder: trocar o loop da linha 9 para também exigir a frase `outras tarefas omitidas`.
- [ ] **2. Rodar** `bash tests/test-loop.sh` (background) → FAIL no `prompt inteiro sem a tarefa 2`.
- [ ] **3. Implementar** — não-óbvio, vai o código:
  ```bash
  plano_base() {
    awk '/^## Tarefa [0-9]+:/{exit} {print}' "$plano"
    awk '/^## Tarefa [0-9]+:/{t=1} t && /^## Notas de sessão/{f=1; print; next} /^## /{f=0} f' "$plano"
  }
  ```
  (a 2ª awk só imprime notas que estejam DEPOIS da 1ª tarefa — as de antes já saíram no cabeçalho). Gravar em `$loopdir/.plano` e ler no lugar de `$plano` no `awk -v pl=`. Template: `=== PLANO (cabeçalho + notas de sessão; outras tarefas omitidas) ===` e regra 1 do rodapé.
- [ ] **4. Rodar** test-loop → verde; gate.
- [ ] **5. Commit** `feat(otimizacao-tokens/6): volta do loop recebe cabeçalho + tarefa + notas`.

## Tarefa 2: plano sem código de implementação duplicado

- **depende-de**: []
- **requisito**: **otimizacao-tokens/5** — QUANDO a fase plan escrever uma tarefa O SISTEMA DEVE trazer o código completo do teste, assinaturas exatas e comandos, e código de implementação SÓ quando não-óbvio (algoritmo, regex, SQL, formato exato); placeholder segue proibido.
- **arquivos**: Modificar `skills/plan/SKILL.md`, `templates/plano-template.md`; Teste `tests/test-skills.sh`.
- **done quando**: asserts abaixo verdes.

- [ ] **1. Red** — `test-skills.sh`, fim do arquivo antes de `report`:
  ```bash
  pl="$(cat skills/plan/SKILL.md)"; pt="$(cat templates/plano-template.md)"
  assert_contains "$pl" 'implementação só quando não-óbvio' "otimizacao-tokens/5 plan: implementação só se não-óbvia"
  assert_contains "$pl" 'código completo do TESTE' "otimizacao-tokens/5 plan: teste completo"
  assert_not_contains "$pl" 'Código real nos passos' "otimizacao-tokens/5 plan: regra antiga fora"
  assert_contains "$pt" 'implementação só quando não-óbvio' "otimizacao-tokens/5 template: idem"
  assert_contains "$pt" 'TBD' "otimizacao-tokens/5 template mantém a proibição de placeholder"
  ```
- [ ] **2. Rodar** → FAIL.
- [ ] **3. Implementar** — plan item 5: passos com "código completo do TESTE, assinaturas exatas e comandos com saída esperada; implementação só quando não-óbvio (algoritmo, regex, SQL, formato exato) — a execute escreve o resto UMA vez"; item 6: "passo sem arquivo, assinatura ou comando exatos" no lugar de "passo que descreve sem mostrar como". Template: cabeçalho dos passos e passo 3 no mesmo espírito.
- [ ] **4. Rodar** → verde; gate.
- [ ] **5. Commit** `feat(otimizacao-tokens/5): plano carrega teste e assinaturas, não implementação óbvia`.

## Tarefa 3: validate vira roteador + references

- **depende-de**: []
- **requisito**: **otimizacao-tokens/2** — QUANDO a skill validate for carregada O SISTEMA DEVE trazer inline só o fluxo até o portão; sync pós-merge, filtro de decisões vivas e Fechamento LIGHT vivem em `skills/validate/references/`, lidos UMA por uso, e a prosa histórica sai. **otimizacao-tokens/3** — QUANDO uma reference da validate estiver ausente O SISTEMA DEVE avisar nomeando o arquivo, manter o portão humano e NÃO executar o sync de memória — pede reinstalação do plugin. **otimizacao-tokens/8** — invariantes de portão e evidência seguem asseridos, no arquivo onde moram.
- **decisões relevantes**: padrão da skill memory (tabela operação → onde; "leia uma reference por uso"). Inline fica: itens 1-5 do fluxo, item 7 (irreversível), Autopilot no portão, red flags, bloco, próxima. Sai para references: item 6 inteiro → `sync.md`; filtro de entrada das decisões vivas → `decisoes-vivas.md`; seção Fechamento LIGHT → `fechamento-light.md`. Sai de vez: parágrafo "Mecanizar isso foi tentado e abandonado…".
- **arquivos**: Modificar `skills/validate/SKILL.md`; Criar `skills/validate/references/{sync,decisoes-vivas,fechamento-light}.md`; Teste `tests/test-skills.sh`, `tests/test-autopilot.sh`, `tests/test-gate.sh`.
- **done quando**: suíte verde, contagem de asserts não cai, `validate/SKILL.md` < 6500 bytes.

- [ ] **1. Red** — relocar os asserts (texto idêntico, arquivo novo) e somar os de estrutura:
  ```bash
  VR=skills/validate/references; vv="$(cat skills/validate/SKILL.md)"
  for r in sync decisoes-vivas fechamento-light; do
    assert_file "$VR/$r.md" "otimizacao-tokens/2 reference $r existe"
    assert_contains "$vv" "references/$r.md" "otimizacao-tokens/2 roteador aponta $r"
  done
  assert_contains "$vv" 'Reference ausente' "otimizacao-tokens/3 declara reference ausente"
  assert_contains "$vv" 'mantém o portão humano e NÃO roda o sync' "otimizacao-tokens/3 portão fica, sync não roda"
  assert_not_contains "$vv" '--diff-filter=A' "otimizacao-tokens/2 corpo do sync fora do roteador"
  assert_not_contains "$vv" 'Mecanizar isso foi tentado' "otimizacao-tokens/2 prosa histórica fora"
  [ "$(wc -c < skills/validate/SKILL.md)" -lt 6500 ] && ok || ko "otimizacao-tokens/2 validate < 6500 bytes"
  ```
  Relocação: test-skills 87-89 e 160-173 leem `$VR/sync.md`; 114-121 (`lt`) lê `$VR/fechamento-light.md` inteiro e `'## Fechamento LIGHT'` vira o título `# validate — Fechamento LIGHT`; 124-127 leem `$VR/decisoes-vivas.md`; test-autopilot 60-61 e test-gate 90-91 leem `fechamento-light.md`.
- [ ] **2. Rodar** test-skills/test-autopilot/test-gate → FAIL (references ausentes).
- [ ] **3. Implementar** — `git mv` não se aplica (é corte de seção): mover os blocos por recorte, sem reescrever o texto normativo; roteador ganha a tabela `| uso | onde |` e a regra de reference ausente numa linha só.
- [ ] **4. Rodar** suíte → verde; comparar total de asserts (≥ antes).
- [ ] **5. Commit** `refactor(otimizacao-tokens/2,3,8): validate vira roteador + references`.

## Tarefa 4: não reler na sessão + /clear recomendado

- **depende-de**: [Tarefa 3]
- **requisito**: **otimizacao-tokens/1** — QUANDO uma fase precisar da skill memory, do `MEMORY.md` ou do template do bloco de fechamento e eles já tiverem sido carregados nesta sessão (sem `/clear` nem compactação depois) O SISTEMA DEVE reusar o que está no contexto, sem reinvocar a skill nem reler o arquivo; após `/clear` ou compactação, recarrega normalmente. **otimizacao-tokens/4** — QUANDO uma fase fechar e a próxima se reancorar só pelos artefatos O SISTEMA DEVE recomendar `/clear` no bloco de fechamento, deixando a decisão com o humano (em autopilot, sem pausa, a recomendação não aparece).
- **arquivos**: Modificar `skills/memory/SKILL.md`, as 7 skills de fase (seção `## Bloco de fechamento`), `skills/scope/SKILL.md` e `skills/plan/SKILL.md` ("Fechar a fase"), `templates/bloco-fechamento-template.md`; Teste `tests/test-skills.sh`, `tests/test-templates.sh`.

- [ ] **1. Red**:
  ```bash
  assert_contains "$(cat skills/memory/SKILL.md)" 'Já carregado nesta sessão' "otimizacao-tokens/1 memory: não reinvocar/reler"
  for s in audora-commander scope plan execute e2e validate debug; do
    bf="$(awk '/^## Bloco de fechamento/{f=1;next} /^## /{f=0} f' "skills/$s/SKILL.md")"
    assert_contains "$bf" 'já lido nesta sessão' "otimizacao-tokens/1 $s não relê o template"
  done
  b="$(cat templates/bloco-fechamento-template.md)"
  assert_contains "$b" '/clear recomendado' "otimizacao-tokens/4 template recomenda /clear"
  assert_contains "$b" 'autopilot' "otimizacao-tokens/4 template omite em autopilot"
  for s in scope plan; do assert_contains "$(cat skills/$s/SKILL.md)" 'Recomendo /clear' "otimizacao-tokens/4 $s recomenda /clear"; done
  ```
- [ ] **2. Rodar** → FAIL.
- [ ] **3. Implementar** — memory, regra de leitura seletiva, item novo: "**Já carregado nesta sessão** (skill memory invocada, `MEMORY.md` lido, sem `/clear` nem compactação depois) → reusar do contexto; não reinvocar a skill nem reler o arquivo. Depois de `/clear` ou compactação, recarregar." Bloco das 7 fases: "(template já lido nesta sessão → não reler)". Template, regra 4 do Próximo: "próxima fase se reancora pelos artefatos → `— /clear recomendado`; o humano decide; na sessão nova basta `<fase> de <id>`. Autopilot: omitir (não há pausa)." scope/plan "Fechar a fase": "Seguro dar /clear" → "Recomendo /clear agora".
- [ ] **4. Rodar** → verde; gate.
- [ ] **5. Commit** `feat(otimizacao-tokens/1,4): não reler na sessão; /clear recomendado entre fases`.

## Tarefa 5: teto de carga na suíte + medição

- **depende-de**: [Tarefa 2, Tarefa 3, Tarefa 4]
- **requisito**: **otimizacao-tokens/7** — QUANDO a suíte rodar O SISTEMA DEVE reprovar se a carga base do caminho MEDIUM (SKILL.md das fases + references e templates que o caminho lê uma vez) passar do teto em bytes registrado; o nó registra antes → depois medido pela mesma conta.
- **interfaces**: produz `tests/test-carga.sh` com `carga()` (soma de `wc -c`) e as listas BASE/FULL; FULL passa a somar `validate/references/sync.md` + `decisoes-vivas.md`.
- **arquivos**: Criar `tests/test-carga.sh`; Modificar o nó (medição).
- **done quando**: teste verde com teto = depois medido + 3% (arredondado para cima em centenas); teste negativo: teto 1 byte abaixo do medido reprova.

- [ ] **1. Red** — criar `test-carga.sh` com teto provisório `TETO_BASE=1` → FAIL (prova que morde).
- [ ] **2. Medir** BASE/FULL depois; fixar `TETO_BASE`/`TETO_FULL`; registrar antes → depois no nó.
- [ ] **3. Rodar** → verde; gate.
- [ ] **4. Commit** `test(otimizacao-tokens/7): teto de carga do caminho MEDIUM`.

## Tarefa 6: versão 0.9.0 + gate final

- **depende-de**: [Tarefa 1, Tarefa 5]
- **requisito**: versão (decisão aprovada no escopo) e **otimizacao-tokens/8** (suíte inteira verde, invariantes presentes).
- **arquivos**: `.claude-plugin/*.json`, `tests/test-docs.sh`.
- [ ] **1. Red** test-docs `'"version": "0.9.0"'` → FAIL. **2.** bump. **3.** gate final → `GATE: passou`. **4. Commit** `chore(otimizacao-tokens): versão 0.9.0`.
