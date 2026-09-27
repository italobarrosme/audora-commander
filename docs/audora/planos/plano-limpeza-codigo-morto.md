# Plano — limpeza-codigo-morto: Limpeza de código morto

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** tirar legado GRAFO, federação `chave:id` e guardas de migração;
fechar os nós travados; alinhar fundamentos, versão e PRD ao estado real.

**Nó do MEMORY:** `limpeza-codigo-morto` (spec `docs/audora/specs/limpeza-codigo-morto-escopo.md`)

**Arquitetura da mudança:** remoção pura, sem comportamento novo — exceto
`memory-validate`, que passa a tratar `depende-de` com `:` como id comum
(some o `continue` da federação). Cada remoção de texto é guiada pelo teste
que assere o texto novo (red) ou pela retirada do assert que exigia o velho;
ausência é provada por comando `grep` no roteiro da validate, NUNCA por teste
permanente (critério /3 proíbe guarda de ausência). Graphify ausente nesta
máquina → localização por grep (consultar-codigo degradado, avisado).

**Arquivos lidos antes de planejar:**
- `skills/memory/SKILL.md` — passo 2 do carregar-contexto é o aviso GRAFO.
- `skills/audora-commander/SKILL.md` — passo 1 cita "memória de versão anterior".
- `hooks/memory-validate` — `case "$d" in *:*) continue` (federação).
- `templates/MEMORY-template.md` (regra 6), `templates/no-template.md` (comentário `depende-de`).
- `README.md`, `README.pt-BR.md` — seção "Renamed/Renomeado em 0.4.0".
- `docs/fundamentos.md` — P1..Transversais e Mapa com nomes pré-0.3.0.
- `tests/test-no-grafo.sh`, `test-skills.sh`, `test-templates.sh`,
  `test-session-start.sh`, `test-worktree.sh`, `test-docs.sh`,
  `test-dogfood.sh`, `test-memory-guard.sh`, `test-memory-validate.sh`,
  `test-autopilot.sh` (tabela do P4 em fundamentos).
- `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` (0.7.0).
- `docs/audora/memory/memory-graphify.md`, `plugin-v0.1.0.md`,
  `docs/audora/e2e/e2e-memory-graphify.md` (evidência de bootstrap).
- `MEMORY.md` — aprendizados que citam `test-no-grafo.sh` e o guarda.

**Conflitos MEMORY vs código encontrados:** Constituição `graphify: ativo`,
mas o comando `graphify` não está no PATH desta máquina (hook git do Graphify
roda) — fora de escopo por decisão do escopo; nenhum outro.

## Notas de sessão

---

## Tarefa 1: federação `chave:id` sai do schema

- **depende-de**: []
- **requisito**: **limpeza-codigo-morto/4** — QUANDO um nó declarar em
  `depende-de` um id contendo `:` O SISTEMA DEVE tratá-lo como id comum:
  `memory-validate` sai com exit 2 acusando dependência inexistente se o id
  não estiver no índice; `MEMORY-template.md` e `no-template.md` não reservam
  mais a sintaxe `chave:id`.
- **decisões relevantes**: sem sintaxe especial, `:` em id deixa de ser
  proibido — a regra 6 do template some inteira (a 7 vira 6).
- **interfaces**: produz `memory-validate` sem ramo de federação.
- **arquivos**: Modificar `hooks/memory-validate`,
  `templates/MEMORY-template.md`, `templates/no-template.md`; Teste
  `tests/test-memory-validate.sh`.
- **done quando**: caso `ext:x` sai 2 com "depende de 'ext:x'"; suíte verde.

- [ ] **1. Teste red** — em `test-memory-validate.sh`, antes do bloco `ciclo`:
  ```bash
  mk fed 'memory-schema: 1' '- x | planned | X | r | k | —'; no fed x planned 'ext:x'
  run_hook memory-validate "$SP/fed/MEMORY.md";           assert_eq 2 "$code" "limpeza-codigo-morto/4 dep com ':' é id comum → 2"; assert_contains "$out" "depende de 'ext:x'" "limpeza-codigo-morto/4 msg"
  ```
- [ ] **2. Rodar** `bash tests/test-memory-validate.sh` → FAIL (hoje sai 0: `continue`).
- [ ] **3. Implementar** — apagar a linha `case "$d" in *:*) continue ;; esac`
  do hook; apagar a regra 6 do MEMORY-template (renumerar 7→6); no
  no-template, `depende-de: lista de ids de nós do índice`.
- [ ] **4. Rodar** o arquivo e depois `bash tests/run.sh > log; echo $?` → 0.
- [ ] **5. Commit** `feat(limpeza-codigo-morto/4): depende-de sem sintaxe reservada chave:id`.

## Tarefa 2: legado GRAFO e guardas de migração saem

- **depende-de**: [Tarefa 1]
- **requisito**: **limpeza-codigo-morto/1** — QUANDO a porta de entrada ou a
  skill memory carregar contexto num projeto sem `MEMORY.md` O SISTEMA DEVE
  oferecer o bootstrap sem mencionar GRAFO, versão anterior do framework ou
  arquivo de memória legado. **limpeza-codigo-morto/2** — QUANDO o leitor
  abrir `README.md` ou `README.pt-BR.md` O SISTEMA DEVE não exibir seção de
  renomeação/breaking nem nome de versão anterior. **limpeza-codigo-morto/3**
  — QUANDO a suíte rodar O SISTEMA DEVE não conter guarda anti-GRAFO nem
  assert de migração; fixture que usava nome legado para provar comportamento
  vivo é reescrita sem o nome.
- **decisões relevantes**: guarda removida de vez (humano); contagem de 9
  skills migra para `test-skills.sh` (aprovado); nó `planned`
  `grafo-inicio-fim` vira `memory-inicio-fim` (título "Memória no início e
  fim") — nome legado em linha viva do índice (IA).
- **arquivos**: Modificar `skills/memory/SKILL.md`,
  `skills/audora-commander/SKILL.md`, `README.md`, `README.pt-BR.md`,
  `MEMORY.md`; Apagar `tests/test-no-grafo.sh`; Modificar `tests/test-skills.sh`,
  `test-templates.sh`, `test-session-start.sh`, `test-worktree.sh`,
  `test-docs.sh`, `test-dogfood.sh`, `test-memory-guard.sh`,
  `test-memory-validate.sh`.
- **done quando**: `grep -rniE 'grafo|versão anterior|renamed in|renomeado em' skills hooks templates tests .claude-plugin README.md README.pt-BR.md` vazio; suíte verde.

- [ ] **1. Red** — `test-skills.sh`: acrescentar
  `assert_eq "9" "$(ls -d skills/*/ | wc -l | tr -d ' ')" "limpeza-codigo-morto/3 9 skills"`
  e trocar o assert `'MEMORY ausente'` da porta de entrada por
  `assert_contains "$a" 'MEMORY ausente → oferecer bootstrap antes' "/1 porta de entrada oferece bootstrap"`
  (frase nova, sem o parêntese legado). Rodar → FAIL no assert novo da porta.
- [ ] **2. Implementar /1** — memory: apagar o passo 2 do carregar-contexto e
  renumerar 3→2, 4→3, 5→4. Porta de entrada, passo 1: `MEMORY ausente →
  oferecer bootstrap antes de qualquer outra coisa. Nunca seguir sem MEMORY,
  nunca inventar um.`
- [ ] **3. Implementar /2** — apagar dos dois READMEs a seção
  `## Renamed in 0.4.0 (breaking)` / `## Renomeado em 0.4.0 (breaking)` até
  antes de `## Development` / `## Desenvolvimento`.
- [ ] **4. Implementar /3** — apagar `tests/test-no-grafo.sh`; remover:
  test-skills (bloco `if memory ... grafo` + linha `skill graph`, asserts
  `GRAFO.md`, `PT→EN`, `versao-schema`); test-templates (`PT→EN`,
  `GRAFO-template*`, `zero grafo`); test-session-start (`graph,`, `GRAFO`,
  `hooks.json sem grafo`); test-worktree (`worktree sem grafo`); test-docs
  (asserts das seções 0.4.0 e `Renamed in 0.3.0`); test-dogfood (GRAFO.md,
  `nos/`, GRAFO-ARQUIVO, md5 do legado; id `grafo-inicio-fim` →
  `memory-inicio-fim`). Reescrever fixtures vivas: memory-validate
  `semschema` com linha 1 `# MEMORY de outra ferramenta` (sem caso GRAFO.md —
  `qualquer.txt` já cobre "fora do MEMORY"); memory-guard idem e sem o caso
  `nos/`.
- [ ] **5. MEMORY.md** — linha `grafo-inicio-fim` → `memory-inicio-fim |
  planned | Memória no início e fim | …`; aprendizado 2026-09-05 do guarda e o
  de 2026-08-27 (8 pontos) recebem `[invalidado-em: 2026-09-27]
  [substituido-por: …]` + linha nova do de 8 pontos sem `test-no-grafo.sh`.
- [ ] **6. Rodar** suíte → 0; rodar o grep do done → vazio.
- [ ] **7. Commit** `refactor(limpeza-codigo-morto/1,2,3): legado GRAFO e guardas de migração removidos`.

## Tarefa 3: fundamentos com nomes e mecânica atuais

- **depende-de**: [Tarefa 2]
- **requisito**: **limpeza-codigo-morto/6** — QUANDO o leitor abrir
  `docs/fundamentos.md` O SISTEMA DEVE usar a nomenclatura atual e descrever
  só mecânica que existe (sem GRAFO-ARQUIVO, estado `validado`, schema
  v1/v2); princípios e tabela de acertos permanecem.
- **decisões relevantes**: nomes + mecânica (humano). Mapeamento: GRAFO →
  MEMORY; skill grafo → memory; escopo/plano/executar/validar/depurar →
  scope/plan/execute/validate/debug; LEVE/MÉDIA/ALTA → LIGHT/MEDIUM/HIGH;
  estados → `planned | in-progress | blocked | delivered | discarded`,
  `hotfix-pending-record`; GRAFO-ARQUIVO → nó arquivado por `git mv` em
  `docs/audora/arquivo/`; `inferido` vira `humano` quando confirmado (não
  existe `validado`); subagente "não edita GRAFO" → edita só os nós da
  demanda; P1 ganha Aprendizados e Graphify (código indexado por baixo).
- **arquivos**: Modificar `docs/fundamentos.md`, `tests/test-autopilot.sh`.
- **done quando**: `grep -nE 'GRAFO|grafo|LEVE|MÉDIA|ALTA|validado|em-curso|entregue|executar|validar|depurar' docs/fundamentos.md` vazio; suíte verde.

- [ ] **1. Red** — test-autopilot: trocar a linha asserida por
  `'| LIGHT | execute → validate | resultado | resultado (e2e sem oferta) |'`
  (label `/14 linha LIGHT completa na tabela`). Rodar → FAIL.
- [ ] **2. Implementar** — reescrever fundamentos pelo mapeamento acima.
- [ ] **3. Rodar** suíte → 0 e o grep do done → vazio.
- [ ] **4. Commit** `docs(limpeza-codigo-morto/6): fundamentos com nomenclatura e mecânica atuais`.

## Tarefa 4: versão 0.8.0

- **depende-de**: [Tarefa 3]
- **requisito**: **limpeza-codigo-morto/8** — QUANDO o plugin for reinstalado
  O SISTEMA DEVE declarar a versão `0.8.0` em `plugin.json` e
  `marketplace.json`.
- **arquivos**: Modificar os 2 manifests; Teste `tests/test-docs.sh`.
- **done quando**: test-docs verde com 0.8.0.

- [ ] **1. Red** — test-docs: `'"version": "0.8.0"'` (label `limpeza-codigo-morto/8`). Rodar → FAIL.
- [ ] **2. Implementar** — `"version": "0.8.0"` nos dois JSON.
- [ ] **3. Rodar** suíte → 0.
- [ ] **4. Commit** `chore(limpeza-codigo-morto/8): versão 0.8.0`.

## Tarefa 5: fechar nós travados

- **depende-de**: [Tarefa 4]
- **requisito**: **limpeza-codigo-morto/5** — QUANDO o índice do `MEMORY.md`
  for lido O SISTEMA DEVE mostrar `memory-graphify` e `plugin-v0.1.0` como
  `delivered`, nós em `docs/audora/arquivo/` com evidência por critério
  (critério aposentado vira delta REMOVIDO com motivo) e planos em
  `docs/audora/planos/arquivo/`.
- **decisões relevantes**: evidência de `plugin-v0.1.0` — /1 e /2 desta
  sessão (listagem com 9 skills `audora-commander:`; ponteiro do hook no
  contexto), /3 corrida C de `e2e-memory-graphify.md`, /4
  `claude plugin validate .` + estrutura em `test-skills.sh`, /5 demandas
  LIGHT (`light-enxuto`) e MEDIUM (`scope-batch`) arquivadas com nó, plano e
  roteiro. `memory-graphify`: /3 (aviso GRAFO) e a parte "tabela GRAFO →
  MEMORY" do /19 viram REMOVIDO por esta demanda; demais cobertos por suíte +
  relatório e2e.
- **arquivos**: `docs/audora/memory/memory-graphify.md`,
  `docs/audora/memory/plugin-v0.1.0.md` → `git mv` para
  `docs/audora/arquivo/2026-09-27-<id>.md`; `docs/audora/planos/plano-memory-graphify.md`,
  `plano-v0.1.0-bootstrap.md` → `git mv` para `docs/audora/planos/arquivo/`;
  `MEMORY.md` (2 linhas do índice); `tests/test-dogfood.sh` (`assert_file
  docs/audora/memory/memory-graphify.md` → caminho arquivado).
- **done quando**: `memory-validate`/`memory-guard` exit 0 no MEMORY.md;
  `grep -c '| in-progress |' MEMORY.md` = 1 (só esta demanda); suíte verde.

- [ ] **1. Red** — test-dogfood: `assert_file docs/audora/arquivo/2026-09-27-memory-graphify.md "limpeza-codigo-morto/5 memory-graphify arquivado"` e idem `plugin-v0.1.0`. Rodar → FAIL.
- [ ] **2. Coletar evidência** — `claude plugin validate .` (saída lida).
- [ ] **3. Implementar** — delta + evidência + `estado: delivered` em cada
  nó; consolidar delta no corpo (compactar item 0); `git mv` dos nós e
  planos; linhas do índice no formato arquivado.
- [ ] **4. Rodar** hooks no MEMORY.md → 0; suíte → 0.
- [ ] **5. Commit** `chore(limpeza-codigo-morto/5): memory-graphify e plugin-v0.1.0 entregues e arquivados`.

## Tarefa 6: gate da demanda

- **depende-de**: [Tarefa 5]
- **requisito**: **limpeza-codigo-morto/9** — QUANDO o gate rodar ao fim da
  demanda O SISTEMA DEVE sair 0: comportamento vivo mantém cobertura, e a
  queda de asserts dos guardas removidos passa só com `gate-asserts:`
  justificado no nó.
- **decisões relevantes**: o gate compara com HEAD (diff não commitado) — a
  queda de asserts acontece na Tarefa 2; lá, ANTES do commit, rodar o gate com
  a linha `gate-asserts:` no nó. Aqui: gate final na árvore limpa.
- **arquivos**: `docs/audora/memory/limpeza-codigo-morto.md` (linha
  `gate-asserts:` na Tarefa 2).
- **done quando**: `bash hooks/gate limpeza-codigo-morto` → `GATE: passou`, exit 0.

- [ ] **1.** Tarefa 2 passo 6: gate com `gate-asserts:` → saída lida.
- [ ] **2.** Gate final → exit 0.

/7 (PRD sem o roadmap) é executado no sync da validate, após o merge na
`main` (regra global: PRD só muda com a `main`).
