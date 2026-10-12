# Plano — porta-anuncio: Anúncio da porta obrigatório

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** a porta sempre escreve ao humano "Demanda classificada como
<CATEGORIA> porque … — me corrija se discordar" antes do 1º registro no
MEMORY, e o eval `porta` prova isso (3/3 com o plugin, 0/3 sem).

**Nó do MEMORY:** `porta-anuncio` (MEMORY.md)

**Arquitetura da mudança:** duas frentes. (1) Texto: o passo 4 da porta
vira regra dura — frase própria, escrita ANTES do passo 5, que o bloco de
fechamento não substitui —, toda dentro do trecho que a mutação
`porta-anuncio` corta (âncoras do `mutacoes.tsv` intactas). (2) Prova: o
grader `categoria` passa a exigir categoria + `porque` + `me corrija` num
bloco de texto de evento `assistant` (o corpo da skill carregada chega em
evento `user` e não conta) e antes de qualquer Write/Edit em `MEMORY.md` ou
em `docs/audora/memory/`. Antes do grader, 1 run real confirma o formato do
trace do `claude plugin eval`. Depois, 3 rodadas reais em série: completo do
`porta`, mutação e rápida dos outros 3 casos.

**Arquivos lidos antes de planejar:**
- `docs/audora/memory/porta-anuncio.md:1-68` — critérios /1–/6, fora-de-escopo, 4 decisões do humano.
- `skills/audora-commander/SKILL.md:1-96` — passo 4 (40-41) é o anúncio; passo 5 (42-46) registra o nó; bloco de fechamento (82-91) cita a categoria em "Produzido".
- `tests/evals/mutacoes.tsv:1-7` — regra `porta-anuncio` corta de `4. **Anunciar**:` até `Correção do humano vale na hora.`
- `tests/evals/porta/case.yaml:1-5`, `fixture.sh:1-4`, `prompt.md:1-10` — caso MEDIUM (media/mediana + `bin/estat`), 40 turnos, Write/Edit permitidos.
- `tests/evals/porta/graders/categoria.md:1-9` — hoje só `classificada como \**MEDIUM\b`, `target: trace`, `flags: i`, sem ordem nem restrição a texto do assistente.
- `tests/evals/porta/graders/primeira-skill.md:1-8`, `fase-seguinte.md:1-9` — padrão tempered `(?:(?!X)[\s\S])*` sobre o trace.
- `tests/evals/escopo-antes/graders/sem-write-fora.md:1-12` — precedente de caminho escapado no trace: `docs(?:\\\\|/)audora`.
- `tests/test-evals-graders.sh:1-331` — 163-205 caso porta; 198-202 são os 5 casos do `categoria` que o contrato novo quebra (199 "Classificada como MEDIUM — me corrija" passa hoje, sem `porque`); 177-179 exigem `arm: both`; 268-276 âncoras do `mutacoes.tsv`; 292-302 guarda: só `test-evals.sh`/`test-evals-harness.sh` citam o orquestrador; 319-328 calibração precisa de REPROVOU.
- `tests/evals-lib.sh:105-111` — `limpa_temp_eval <tracePath>` apaga o `claude-eval-*` 2 níveis acima do trace.
- `tests/evals-lib.sh:183-260` — `emula_grader` (perl; regex, tool_used, tool_order; flags `ims`); `:384-440` — `busca_mutacao`, `copia_plugin`, `aplica_mutacao <arq> <início> <fim>`, `relatorio_mutacao` ("com a regra x/n · sem a regra y/n · efeito"); `:465-500` — `agrega_caso` ("PASSOU · porta · com 3/3 · sem 0/3 · Δ +100 pp · …").
- `tests/evals-testlib.sh:1-117` — `ev_tool`, `jesc`, `na_fixture`, `EV`; precisa de `$SP` (de `lib.sh`); cria shims que denunciam claude real.
- `tests/lib.sh:1-21` — `ROOT`, `SP`, asserts, `report`.
- `tests/test-plano-mapa.sh:1-20` — `flat <arquivo> [cabeçalho]`.
- `tests/test-skills.sh:1-30,60-85` — porta: só `skill \`memory\``, bootstrap e bloco; nada sobre o passo 4.
- `tests/test-carga.sh:1-22` — porta está na carga BASE; base hoje 53752, teto 54900 (folga 1148 bytes).
- `tests/evals/README.md:1-102` — linha 42 (caso porta), 89-94 calibração (93 = porta), 96-102 achados.
- `tests/evals.sh:80-110,191,233-234` — invocação real do `claude plugin eval` (`--keep-temp`, `--ablation none|with-without`), `--mutar` e completo.
- `hooks/gate:15-52` — anti-fraude: contagem de linhas `assert_*|ok|ko` não pode cair sem `gate-asserts:` no nó.
- `templates/no-template.md:1-60` — seções do nó (sem campo novo).

**Conflitos MEMORY vs código encontrados:** nenhum.

## Notas de sessão

- Spike do plan (2026-10-12): uma regex com a estrutura da Tarefa 3 passou
  as 24 asserções dela no `emula_grader` (perl), inclusive trace de 6000
  linhas em <1 s. Estrutura: prefixo tempered desde `^` que não atravessa
  `"name":"(Write|Edit)","input":{"file_path":"…(MEMORY\.md|docs(\\\\|/)audora(\\\\|/)memory(\\\\|/))`;
  depois `"type":"assistant"`, o mesmo tempered só em `[^\n]` (mesma linha),
  `"type":"text","text":"`, e o conteúdo da string `(?:[^"\\\n]|\\.)*?`
  com `classificada como \**MEDIUM\b`, `porque`, `me corrija` nessa ordem.
  Falta conferir no trace REAL (Tarefa 2) — o emulador só conhece o formato
  do spike do `claude -p`.
- Armadilha: o Bash tool corta pela metade cada par de barras invertidas,
  até em `<<'EOF'`. O grader e o teste vão para o disco pelo Write.
- Custo previsto das rodadas reais: ~US$ 0,4 (T2) + ~3 (T4) + ~3 (T5) +
  ~1,5 (T6). Não editar NADA no repo durante uma rodada (ISOLAMENTO
  VIOLADO). `claude` fica em `~/.local/bin/claude.exe`.

- T2 (spike real, 2026-10-12, 1 run, US$ 0,17, 34 s, 76 linhas de trace,
  CLI 2.1.284), com o passo 4 da T1 já carregado:
  - (a) ✓ texto do assistente: `{"type":"assistant","message":{"model":…,"type":"message","role":"assistant","content":[{"type":"text","text":"Usando audora-commander para classificar…`
  - (b) ✓ corpo da skill: `{"type":"user","message":{"role":"user","content":[{"type":"text","text":"Base directory for this skill: …` (sem `"type":"assistant"` na linha)
  - (c) ✗ Edit: `"name":"Edit","input":{"replace_all":false,"file_path":"…\\MEMORY.md",…` — `file_path` NÃO é a 1ª chave. Write: `"input":{"file_path":…` (1ª). Replanejo da T3 (gatilho a): o prefixo tempered aceita `file_path` em qualquer posição do input (pula chaves e strings antes dele); asserção nova: Edit com `replace_all` antes de `file_path` em `MEMORY.md`, antes do anúncio → `reprovou`.
  - achado de produto: sequência real = Skill porta → texto "Usando audora-commander…" → Skill memory → Bash/Read → Read `registrar-no.md` e `no-template.md` → Write do nó → Edit do `MEMORY.md` → Skill scope. NENHUM texto entre a classificação e o Write: o passo 4 endurecido não bastou neste run. Vai para debug com a rodada da T4 (3+3 runs) como evidência.
  - custo real por run ~US$ 0,17 (não 0,4–0,6): completo do porta ≈ US$ 1.

- T4 (2026-10-12): `bash tests/evals.sh --completo --caso porta` →
  `REPROVOU · porta · com 0/3 · sem 0/3 · Δ +0 pp · US$ 0.8051 · tokens 732378 · motivo: categoria: pattern not found in trace`, exit 1.
  Asserção /4 escrita em `tests/test-porta-anuncio.sh` (RED, não commitada).
- DEBUG (modo sintoma), ESCALADO — 3 hipóteses refutadas, cada uma numa
  cópia do plugin no scratchpad (repo intocado), 3 runs `sonnet`:
  - evidência: em TODO run o modelo compõe o anúncio num bloco `thinking`
    cuja assinatura decodifica `narration` ("Classifiquei a demanda como
    MEDIUM: … — me avise se discordar. Vou registrar esse nó") e vai direto
    para a ferramenta. Texto visível só sai como processo ("Usando …",
    "Nó registrado. … scope").
  - H1 "em texto visível — classificar no raciocínio não é anunciar" no
    passo 4 → 0/3 (refutada).
  - H2 lembrete no topo de `registrar-no.md` (lido logo antes do Write em
    todos os runs) → 0/3 (refutada).
  - H3 anúncio na abertura ("Anuncie ao começar" com a categoria, classificar
    antes do contexto) → 0/3; o modelo carrega o contexto antes mesmo assim
    e narra a classificação no thinking (refutada).
  - gasto do debug: US$ 0,17 + 0,50 + 0,49 + 0,46; da demanda até aqui ≈ US$ 2,6.
  - estado: T1, T2, T3 commitadas; T4 RED; T5, T6 não rodadas. Decisão humana pendente.
  - humano escolheu o diagnóstico (opção 1): texto da T1, `--model opus`, 3
    runs (`claude-opus-5-5` confirmado no trace), US$ 0,86 → categoria 0/3;
    mesmo padrão: anúncio narrado no thinking ("Classifico essa demanda como
    MEDIUM: … Me avise se discordar — agora vou registrar o nó"), texto
    visível só de processo. Não é do sonnet: é da família atual neste
    harness. Gasto da demanda ≈ US$ 3,5. Próxima decisão: hook (2), aceitar
    a narração (3) ou parar (4).

### Decisões tomadas pela IA

- 2026-10-12 (T1): passo 4 enxuto ao mínimo que segura a regra (ANTES do
  passo 5, frase própria, sempre, bloco não substitui) — a 1ª versão (+255
  bytes) furava a guarda de carga; a final soma +127 e a guarda sobe para
  53879 (ver T1).

---

## Tarefa 1: passo 4 da porta vira regra dura

- **depende-de**: []
- **requisito**: `porta-anuncio/1` — QUANDO a porta de entrada classifica uma demanda O SISTEMA DEVE escrever ao humano, antes de registrar o nó, uma frase própria `Demanda classificada como <CATEGORIA> porque <respostas às perguntas de risco> — me corrija se discordar`
- **decisões relevantes**: anúncio como frase própria antes do 1º registro, não só no bloco de fechamento (humano, 2026-10-12); toda a regra fica DENTRO do trecho de `4. **Anunciar**:` até a 1ª linha com `Correção do humano vale na hora.` (a mutação /5 tem de cortar a regra inteira — nada de linha nova em red flags); SKILL ≤ 250 linhas; carga BASE ≤ 54900; fora-de-escopo: pausar depois do anúncio, mexer nas perguntas de risco.
- **interfaces**: consome `flat <arquivo> [cabeçalho]` (cópia da de `tests/test-plano-mapa.sh:7-13`) e `aplica_mutacao <arquivo> <início> <fim>` (`tests/evals-lib.sh`) · produz `tests/test-porta-anuncio.sh` (fonte `lib.sh`, `evals-lib.sh`, `evals-testlib.sh`; termina em `report`; NUNCA escreve o nome do orquestrador `tests/evals` + `.sh` — guarda `evals-comportamento/12`)
- **ponto de mudança**: `skills/audora-commander/SKILL.md:40-41` — passo 4 reescrito, começando com `4. **Anunciar**:` e terminando na linha com `Correção do humano vale na hora.`
  - replanejado na execute (gatilho d, 2026-10-12): o passo 4 novo soma
    +127 bytes à carga BASE (53752 → 53879) e duas guardas travam em 53752.
    Guardas sobem, como `memoria-integra` fez 4 vezes:
    `tests/test-parada-revisao.sh:59` e `tests/test-leitura-por-secao.sh:129`
    (53752 → 53879), `tests/test-carga.sh:7` (comentário da medição:
    `porta-anuncio/1: BASE 53752 → 53879.`); motivo no nó, em `## decisoes`.
    Lidos: `tests/test-parada-revisao.sh:56-59`, `tests/test-leitura-por-secao.sh:126-129`, `tests/test-carga.sh:1-22`.
- **teste**: `tests/test-porta-anuncio.sh` — caso "porta-anuncio/1 passo 4 é regra dura e cabe inteiro na mutação"
- **asserções** (sobre `flat skills/audora-commander/SKILL.md '## Fluxo'`):
  - contém `Demanda classificada como <CATEGORIA> porque <respostas às perguntas de risco> — me corrija se discordar.`
  - contém `ANTES do passo 5`
  - contém `frase própria`
  - contém `o bloco de fechamento não substitui`
  - não contém `[X]` nem `[respostas às perguntas]` (modelo antigo)
  - posição de `4. **Anunciar**:` < posição de `5. **Registrar o nó**`
  - `grep -cF '4. **Anunciar**:'` no SKILL = `1`
  - cópia do SKILL em `$SP` + `aplica_mutacao "$SP/porta.md" '4. **Anunciar**:' 'Correção do humano vale na hora.'` → a cópia não contém `classificada como`, `me corrija`, `frase própria` nem `ANTES do passo 5`
- **ler**: `skills/audora-commander/SKILL.md:21-56`, `tests/test-plano-mapa.sh:1-13`, `tests/evals-lib.sh:400-421`
- **done quando**: `bash tests/test-porta-anuncio.sh` passa, `bash tests/test-carga.sh` e `bash tests/test-skills.sh` passam, `bash tests/test-evals-graders.sh` passa (âncoras do `mutacoes.tsv`).

- [ ] **red** — `bash tests/test-porta-anuncio.sh` falha com `FAIL: porta-anuncio/1 … não contém 'ANTES do passo 5'` (e as outras frases novas)
- [ ] **green** — `bash tests/test-porta-anuncio.sh && bash tests/test-carga.sh && bash tests/test-skills.sh && bash tests/test-evals-graders.sh` passam; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [ ] **commit** — `git add skills/audora-commander/SKILL.md tests/test-porta-anuncio.sh && git commit -m "feat(porta-anuncio/1): porta anuncia categoria, porque e convite antes do registro"`

## Tarefa 2: spike do formato do trace real

- **depende-de**: []
- **requisito**: `porta-anuncio/3` — QUANDO o trace do caso `porta` tem o modelo do anúncio só no texto da skill carregada (`[X]`, `[respostas às perguntas]`) e não numa resposta do assistente O SISTEMA DEVE reprovar o caso
- **decisões relevantes**: o grader da Tarefa 3 assume 3 formas do trace; confirmar antes de gastar ~US$ 3 na Tarefa 4. Sem commit de código.
- **interfaces**: produz o registro em "Notas de sessão" das formas (a), (b), (c) abaixo, com 1 linha real de exemplo de cada (cortada em 200 caracteres).
- **ponto de mudança**: `docs/audora/planos/plano-porta-anuncio.md` — seção "Notas de sessão"
- **teste**: n/a (spike) — o comando abaixo, 1 run real
- **asserções** (no `trace.jsonl` apontado pelo `tracePath` do JSON):
  - (a) texto do assistente = linha que contém `"type":"assistant"` e um bloco `{"type":"text","text":"…"}`
  - (b) o corpo da skill carregada (procurar `LEI DE FERRO: NA DÚVIDA`) está numa linha SEM `"type":"assistant"`
  - (c) Write/Edit = `"name":"Write","input":{"file_path":"…"` (chave `file_path` primeiro)
- **ler**: `tests/evals.sh:88-110`, `tests/evals-lib.sh:105-111` (`limpa_temp_eval`)
- **done quando**: (a), (b), (c) conferidos e anotados; diretório `claude-eval-*` e saída do spike apagados; `git status --porcelain` igual ao de antes. Forma divergente → replanejar só a Tarefa 3 (gatilho a), ajustando a estrutura da regex e as asserções.

- [ ] **rodar** — da raiz do repo: `~/.local/bin/claude.exe plugin eval . --eval-dir tests/evals --case porta --runs 1 --ablation none --threshold 0 --trust-plugin --scaffold --allow-tools Write Edit --model sonnet --keep-temp --no-publish --max-cost-usd 1 --json "$S/spike.json" --output-dir "$S/out" </dev/null` com `S` = scratchpad da sessão
- [ ] **inspecionar** — `grep -o '"tracePath":"[^"]*"' "$S/spike.json"`; no trace, `grep -n 'LEI DE FERRO: NA DÚVIDA'`, `grep -n '"type":"text"' | grep '"type":"assistant"' | head -3`, `grep -o '"name":"\(Write\|Edit\)","input":{"[a-z_]*"' | sort -u`
- [ ] **anotar e limpar** — Notas de sessão atualizadas; `rm -rf` do `claude-eval-*` (2 níveis acima do trace) e de `"$S/out" "$S/spike.json"`

## Tarefa 3: grader `categoria` exige anúncio do assistente antes do 1º registro

- **depende-de**: [2]
- **requisito**: `porta-anuncio/2` — QUANDO o caso `porta` roda O SISTEMA DEVE reprovar se o texto do assistente não tiver o anúncio com `classificada como MEDIUM`, `porque` e `me corrija`, ou se o anúncio vier depois da primeira escrita no `MEMORY.md` ou no arquivo do nó · `porta-anuncio/3` — QUANDO o trace do caso `porta` tem o modelo do anúncio só no texto da skill carregada (`[X]`, `[respostas às perguntas]`) e não numa resposta do assistente O SISTEMA DEVE reprovar o caso
- **decisões relevantes**: eval exige categoria + porquê + convite (humano, 2026-10-12); só MEDIUM, caso existente; sem juiz LLM; nunca afrouxar grader; o arquivo continua `categoria.md` com `type: regex`, `arm: both`, `target: trace`, `flags: i` (motivo no relatório segue "categoria: …"). O grader vai ao disco pelo Write (barras invertidas).
- **interfaces**: consome `emula_grader <grader> <trace> <ws>` (`tests/evals-lib.sh:183`), `ev_tool <id> <nome> <input-json>` (`tests/evals-testlib.sh:96`) · produz em `tests/test-porta-anuncio.sh`: `ev_text <texto>` → `{"type":"assistant","message":{"content":[{"type":"text","text":"<texto>"}]}}`, `ev_meta <texto>` → `{"type":"user","message":{"role":"user","content":[{"type":"text","text":"<texto>"}]},"isMeta":true}` (ajustar ao formato (b) da Tarefa 2), `ga <esperado> <descrição>` (emula `categoria.md` sobre `$SP/em.jsonl`)
- **ponto de mudança**: `tests/evals/porta/graders/categoria.md:6` (pattern) e `:9` (descrição); `tests/test-evals-graders.sh:198-202` — os 5 casos do `categoria` saem dali (viram as asserções abaixo; linhas `ev_text …; gp …` não contam no gate); `tests/evals/README.md:42` — coluna "como": `anúncio MEDIUM com porquê e convite, antes do 1º registro`
- **teste**: `tests/test-porta-anuncio.sh` — caso "porta-anuncio/2,3 grader categoria"
- **asserções** (`A` = `Demanda classificada como **MEDIUM** porque nenhuma pergunta de risco deu SIM e há lógica nova — me corrija se discordar.`; cada linha = trace → resultado):
  - `ev_text A` → `passou`
  - `ev_text 'Classificada como MEDIUM porque toca vários arquivos; me corrija'` → `passou`
  - `ev_text` com `\"x\"` e `\\n` entre `porque` e `me corrija` → `passou`
  - `ev_text 'Demanda classificada como **MEDIUM**.'` → `reprovou`
  - `ev_text 'classificada como MEDIUM porque x'` → `reprovou`
  - `ev_text 'Classificada como MEDIUM — me corrija'` → `reprovou` (era `passou` na linha 199)
  - `ev_text 'classificada como MEDIUM porque x'` + `ev_text 'me corrija'` (blocos separados) → `reprovou`
  - `ev_text` de `A` com LIGHT → `reprovou`; com HIGH → `reprovou`; `ev_text 'não seria MEDIUM'` → `reprovou`; trace vazio → `reprovou`
  - `ev_meta 'Demanda classificada como [X] porque [respostas às perguntas] — me corrija se discordar.'` → `reprovou`
  - `ev_meta A` → `reprovou`
  - `ev_tool w Write` com `file_path` `/w/docs/audora/memory/media.md` e `content` = A → `reprovou`
  - `ev_tool s Skill` com `args` = A → `reprovou`
  - Write `C:\w\docs\audora\memory\media.md` (escapado com `jesc`) e depois `ev_text A` → `reprovou`
  - Edit `C:\w\MEMORY.md` e depois `ev_text A` → `reprovou`; Edit `/w/MEMORY.md` e depois `ev_text A` → `reprovou`
  - Read `C:\w\MEMORY.md`, `ev_text A`, Write `C:\w\MEMORY.md` → `passou`
  - Write `C:\w\docs\audora\aprendizados.md` e depois `ev_text A` → `passou`
  - 1 evento `assistant` com `[tool_use Write /w/MEMORY.md, text A]` → `reprovou`; com `[text A, tool_use Write /w/MEMORY.md]` → `passou`
  - 3000 pares Read + tool_result e depois `ev_text A` → `passou`
- **ler**: `tests/evals/porta/graders/categoria.md:1-9`, `tests/test-evals-graders.sh:163-205`, `tests/evals-lib.sh:183-245`, `tests/evals-testlib.sh:95-97`, `tests/evals/README.md:38-45`
- **done quando**: as asserções passam, `bash tests/test-evals-graders.sh` passa (sem as linhas 198-202, `arm: both` mantido), `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`; `bash hooks/gate porta-anuncio` sem queda de asserts.

- [ ] **red** — asserções escritas em `tests/test-porta-anuncio.sh`; `bash tests/test-porta-anuncio.sh` falha nos casos `reprovou` de `porque`/`me corrija`, `ev_meta`, Write/Skill e ordem (o grader de hoje passa neles)
- [ ] **green** — `categoria.md` novo; `bash tests/test-porta-anuncio.sh && bash tests/test-evals-graders.sh` passam; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [ ] **commit** — `git add tests/evals/porta/graders/categoria.md tests/test-porta-anuncio.sh tests/test-evals-graders.sh tests/evals/README.md && git commit -m "test(porta-anuncio/2,3): grader do anuncio so em texto do assistente e antes do 1o registro"`

## Tarefa 4: rodada completa do `porta` e calibração

- **depende-de**: [1, 3]
- **requisito**: `porta-anuncio/4` — QUANDO `bash tests/evals.sh --completo --caso porta` roda O SISTEMA DEVE aprovar o caso com 3/3 com o plugin e 0/3 sem, e a linha do `porta` na calibração do `tests/evals/README.md` DEVE registrar essa rodada
- **decisões relevantes**: prova = completo 3/3 com e 0/3 sem (humano, 2026-10-12). Com o plugin < 3/3 → skill debug (texto da porta insuficiente), nunca afrouxar o grader. Nada editado no repo durante a rodada.
- **interfaces**: produz a linha `| porta | braço sem plugin (\`--completo\`) | <AAAA-MM-DD da rodada> | REPROVOU 0/3 (com o plugin 3/3, Δ +100 pp) |`
- **ponto de mudança**: `tests/evals/README.md:93` (linha da calibração) e `:97-99` (achado porta: acrescentar `Resolvido em <data> (\`porta-anuncio\`).`)
- **teste**: `tests/test-porta-anuncio.sh` — caso "porta-anuncio/4 calibração do porta registra a rodada"
- **asserções**: linha `^| porta |` da seção `## Calibração` do README contém `REPROVOU 0/3 (com o plugin 3/3, Δ +100 pp)` e não contém `com o plugin também 0/3`
- **ler**: `tests/evals/README.md:84-102`
- **done quando**: saída real `PASSOU · porta · com 3/3 · sem 0/3 · Δ +100 pp · US$ … · tokens …`, exit `0`, sem `ISOLAMENTO VIOLADO`; a saída colada em Notas de sessão; teste verde.

- [ ] **red** — asserção escrita; `bash tests/test-porta-anuncio.sh` falha com `não contém 'REPROVOU 0/3 (com o plugin 3/3, Δ +100 pp)'`
- [ ] **rodar** — `bash tests/evals.sh --completo --caso porta; echo "exit=$?"` → `PASSOU · porta · com 3/3 · sem 0/3 · Δ +100 pp …` e `exit=0`
- [ ] **green** — README atualizado; `bash tests/test-porta-anuncio.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [ ] **commit** — `git add tests/evals/README.md tests/test-porta-anuncio.sh docs/audora/planos/plano-porta-anuncio.md && git commit -m "test(porta-anuncio/4): rodada completa do porta 3/3 com e 0/3 sem, calibracao"`

## Tarefa 5: mutação da regra `porta-anuncio`

- **depende-de**: [4]
- **requisito**: `porta-anuncio/5` — QUANDO `bash tests/evals.sh --mutar porta-anuncio --runs 3` roda O SISTEMA DEVE ter o resultado (taxa com e sem a regra) registrado no nó, caia a taxa ou não
- **decisões relevantes**: o relatório não corta a regra — o corte é decisão do humano (README). "sem efeito" também é registrado.
- **interfaces**: produz no nó, seção `## decisoes`, a linha `- <AAAA-MM-DD> (medição, porta-anuncio/5): \`--mutar porta-anuncio --runs 3\` → <linha do relatório verbatim>; manter ou cortar a regra é decisão do humano.`
- **ponto de mudança**: `docs/audora/memory/porta-anuncio.md` — fim da seção `## decisoes` (antes de `## delta`); `atualizado-em:` do frontmatter
- **teste**: n/a (medição real) — conferência por grep
- **asserções**: `grep -c -- '--mutar porta-anuncio --runs 3' docs/audora/memory/porta-anuncio.md` → `1`; a mesma linha contém `com a regra ` e `sem a regra `
- **ler**: `docs/audora/memory/porta-anuncio.md:50-68`, `tests/evals-lib.sh:423-437`
- **done quando**: rodada real terminou com `com a regra x/3 · sem a regra y/3 · …` (exit `0`) e a linha está no nó; o `memory-validate` aceita a escrita.

- [ ] **rodar** — `bash tests/evals.sh --mutar porta-anuncio --runs 3; echo "exit=$?"` → linha `com a regra …/3 · sem a regra …/3 · …` e `exit=0`
- [ ] **registrar** — linha no nó; grep das asserções
- [ ] **commit** — `git add docs/audora/memory/porta-anuncio.md && git commit -m "docs(porta-anuncio/5): resultado da mutacao porta-anuncio no no"`

## Tarefa 6: rodada rápida dos outros casos

- **depende-de**: [5]
- **requisito**: `porta-anuncio/6` — QUANDO a rodada rápida roda os casos `escopo-antes`, `memoria` e `tdd` depois da mudança O SISTEMA DEVE manter os três `PASSOU` (a porta endurecida não quebra o resto do fluxo)
- **decisões relevantes**: `tdd` exige `CLAUDE_CODE_OAUTH_TOKEN` no `.env` (senão RECUSADO = erro de infra, não prova). `tdd` reprovado por não reconhecer `execute de dobro` é o achado conhecido `retomada-execute`: mostrar ao humano com o motivo do trace, sem mexer no grader.
- **interfaces**: nenhuma
- **ponto de mudança**: `docs/audora/planos/plano-porta-anuncio.md` — Notas de sessão recebem a saída
- **teste**: n/a (rodada real)
- **asserções**: saída tem `PASSOU · escopo-antes · com 1/1`, `PASSOU · memoria · com 1/1`, `PASSOU · tdd · com 1/1` e `total: 3 caso(s) · 3 passou · 0 reprovou · 0 erro de infra · 0 não rodado`; `exit=0`
- **ler**: `tests/evals/README.md:8-36`
- **done quando**: as 3 linhas `PASSOU` e o total acima, coladas nas Notas de sessão.

- [ ] **rodar** — `grep -c '^CLAUDE_CODE_OAUTH_TOKEN=..' .env` → `1`; `bash tests/evals.sh --caso escopo-antes --caso memoria --caso tdd; echo "exit=$?"`
- [ ] **registrar** — saída nas Notas de sessão
- [ ] **commit** — `git add docs/audora/planos/plano-porta-anuncio.md && git commit -m "docs(porta-anuncio/6): rodada rapida escopo-antes, memoria e tdd"`
