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

**Replanejamento (2026-10-12, escopo reaberto /7–/11):** o texto não basta
(debug: sonnet e opus narram o anúncio no thinking). Novo hook
`hooks/anuncio-guard` (PreToolUse, matcher `Write`) recusa com exit 2 a
criação de nó novo `in-progress`/`hotfix-pending-record` quando o transcript,
desde a última mensagem do humano, não tem o anúncio completo num bloco de
texto do assistente; qualquer falha → exit 0. Tudo em perl (`JSON::PP`, como
o `memory-guard`), lendo o transcript do fim para o começo e parando na
última mensagem do humano. T7 hook + testes, T8 registro + READMEs, T9 1 run
real confirmando que o `plugin eval` roda o hook; depois T4–T6 como antes.

**Replanejamento (2026-10-12, 3ª reabertura — narração por sentido):** o
servidor troca a prosa entre ferramentas por resumo em bloco `thinking` com
a marca `\x42\x09narration` na assinatura (debug T9). Grader e hook ganham
um 2º ramo, sem tocar no ramo texto: bloco `thinking` cuja assinatura tem a
marca e cujo texto tem `classifi(c|qu)…` → `como <CAT>` → `me corrija`/`me
avise` → `discordar`. Grader: regex JS, marca pelos 3 núcleos base64
(`QgluYXJyYXRp`, `IJbmFycmF0aW9u`, `CCW5hcnJhdGlv`), ordem real de chaves
`type, thinking, signature`. Hook: `MIME::Base64` decodifica a assinatura e
procura a marca. T10 grader, T11 hook + READMEs; T4–T6 depois.

**Arquivos lidos antes de planejar:**
- `hooks/hooks.json:1-36` — SessionStart + PostToolUse (Edit|Write: memory-guard, memory-validate) via `"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" <nome>`, `shell: bash`; sem PreToolUse.
- `hooks/memory-guard:1-47` — padrão: stdin JSON por `perl -MJSON::PP`, `file_path` com `\`→`/`, exit 2 + stderr de 1 linha, "falha do hook NUNCA quebra o fluxo".
- `hooks/run-hook.cmd:1-44` — wrapper polyglot; Unix: `exec bash hooks/<nome>`; exit do hook atravessa.
- `.gitattributes:1-6` — `hooks/*` e `tests/*` em LF.
- `tests/lib.sh:17-21` — `run_hook <hook> <caminho>` só manda `{"tool_name":"Edit","tool_input":{"file_path":…}}` (sem `transcript_path`): o hook novo precisa de helper próprio.
- `tests/test-memory-guard.sh:1-16` — fixture em `$SP`, asserção de exit e de trecho da mensagem.
- `tests/test-session-start.sh:1-12` — asserta `memory-guard`/`memory-validate` em `hooks.json`.
- `tests/test-docs.sh:9-44` (grep) — blocos de código idênticos EN/PT; subseção por skill com 5 rótulos.
- `README.md:107-128,140-148`, `README.pt-BR.md:107-128,140-150` — porta "Announces the category (you can correct it), registers the node" / "Anuncia a categoria (você pode corrigir), registra o nó"; hooks citados na seção da memory.
- transcript real desta sessão (`~/.claude/projects/…/2da9e288-….jsonl`, 860 linhas, 2,1 MB): linha = 1 evento JSON; `"type"` NÃO é a 1ª chave (vem `parentUuid` antes) → decodificar, não casar regex; mensagem do humano = `type: user`, sem `isMeta`, conteúdo string ou blocos sem `tool_result` (ex.: `execute de porta-anuncio`, `/clear`); skill carregada = `type: user` + `isMeta: true` ("Base directory for this skill"); resposta do AskUserQuestion = `tool_result`; assistente = `type: assistant`, 1 bloco por linha (`thinking`, `text`, `tool_use`), o `text` gravado antes do `tool_use` da mesma mensagem.
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
- (3ª reabertura) `hooks/anuncio-guard:1-50` — laço `for my $b (@$c)` em 36-39 só olha `type: text`; comentário de cabeçalho 2-9; `perl -MJSON::PP -0777` em 12.
- (3ª reabertura) `tests/evals/porta/graders/categoria.md:1-13` — pattern 6 = prefixo tempered (sem Write/Edit no MEMORY/nó) + `"type":"assistant"` + tempered na linha + ramo texto; descrição 9-13.
- (3ª reabertura) `tests/test-porta-anuncio.sh:36-156` — `ev_text`/`ev_meta`/`ga` (44-48), casos do grader (52-76), `js`/`tr_*` (80-86), `pre` (88-91), `A`, `MSG`, `N`, `T`, `CI`, casos /7–/11 (97-142), registro e READMEs (144-154), `report` (156).
- (3ª reabertura) `tests/evals-lib.sh:183-245` — `emula_grader` lê o trace inteiro, CRLF→LF, `qr/(?i)…/`.
- (3ª reabertura) `tests/evals-testlib.sh:95-97` — `jesc`, `ev_tool`, `ev_result`.
- (3ª reabertura) `README.md:114-124`, `README.pt-BR.md:114-124` — "in visible text — the `anuncio-guard` hook (PreToolUse) refuses…" / "em texto visível — o hook `anuncio-guard` (PreToolUse) recusa…" (119-121).
- (3ª reabertura) 10 traces do debug (`h2-1..3`, `h3-1..3`, `hk-1`, `op-1..3` no scratchpad `2da9e288-…`) e `js-check.js` de lá.

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

- T9 (2026-10-12, 1 run `sonnet`, US$ 0,158, cópia `p5` no scratchpad do
  debug, trace `hk-1.jsonl` de 105 linhas): `categoria=X fase-seguinte=X
  primeira-skill=ok`.
  - ✓ o `plugin eval` roda o hook: 2 `tool_result` `PreToolUse:Write hook
    error: [… run-hook.cmd" anuncio-guard]: anuncio-guard: antes de registrar
    o nó, …` (linhas 72 e 100).
  - ✗ o modelo não anuncia depois: antes de cada Write ([54] e [98]) narra
    no thinking "Classifico essa demanda como MEDIUM: … — me avise se
    discordar"; texto visível só de processo ([12] "Usando audora-commander…",
    [70] "Escrevo primeiro o arquivo do nó…").
  - fim [105], texto: "O hook `anuncio-guard` … rejeitou a escrita … duas
    vezes. … Eu já escrevi esse anúncio nas duas vezes, na forma pedida. O
    hook não o reconheceu, e não sei dizer por quê. Não vou tentar contornar
    o hook." + `**Classificação:** MEDIUM …` (sem convite) e para: nó não
    criado, `MEMORY.md` intocado. O modelo crê que a narração é visível.
  - → debug (gatilho da T9). Gasto da demanda ≈ US$ 3,7.
- DEBUG T9 (modo sintoma, 2026-10-12, sem custo — só leitura):
  - reprodução: 10/10 runs (9 do debug anterior + `hk-1`).
  - evidência 1: no `hk-1`, os blocos do anúncio ([54], [98]) são `thinking`
    com assinatura `block_kind` = `narration` e texto; os de raciocínio
    ([11], [29], [104]) têm `block_kind` = `thinking` e vêm VAZIOS.
  - evidência 2: o `claude.exe` 2.1.284 descreve esses blocos como "thinking
    blocks whose signature the server tagged block_kind 'narration' (server
    summaries of the prose between tool calls, not the model's own
    reasoning)"; no VSCode ganham `narration_hint: hidden|faint`.
  - evidência 3: a ferramenta `SendUserMessage` (modo Brief, ausente no eval:
    `tools=Task,Edit,Glob,Grep,NotebookEdit,Read,Skill,TaskStop,TodoWrite,ToolSearch,Write`)
    existe "for content they need to see exactly as written between tool
    calls"; texto de fim de turno chega normal ([105] chegou como `text`).
  - evidência 4: sessões interativas do VSCode deste usuário também gravam
    `narration` (176 de 313 transcripts locais).
  - CAUSA RAIZ: o modelo ESCREVE o anúncio; o servidor troca a prosa entre
    ferramentas por resumo em bloco narration. Explica H1–H3 refutadas (o
    texto da skill não governa o servidor), o "Eu já escrevi esse anúncio"
    do [105] e o hook nunca ver o `text`. Sintoma em aberto: por que [12] e
    [70] (prosa curta de processo) ficaram `text` — o critério do servidor
    não é observável daqui.
  - efeito colateral do hook: com narração ativa ele trava o registro do nó
    e o modelo para (hk-1). NÃO mergear o hook como está.
  - ESCALADA ao humano: a correção muda critério (/7, /10) ou fora-de-escopo.
- PLAN da 2ª reabertura (2026-10-12, sem custo — só leitura dos 10 traces
  do debug e de transcripts de sessão):
  - ✓ marca: assinatura = base64 de protobuf; `block_kind` no campo 8
    (`\x42\x09narration` / `\x42\x08thinking`), byte 13 em todos os 57
    blocos thinking dos traces (12 narration com texto, 45 thinking vazios);
    mesmo formato no transcript de sessão que o hook lê. Núcleos base64 de
    `\x42\x09narration` nos 3 alinhamentos: `QgluYXJyYXRp`,
    `IJbmFycmF0aW9u` (o real), `CCW5hcnJhdGlv`.
  - ✗ texto: a narração é RESUMO do servidor, não a frase do modelo. Nas 6
    narrações de classificação: 0/6 com `classificada como` (vem
    "Classifico a demanda como MEDIUM"), 0/6 com `porque` (vem ":" ou "já
    que"), 1/6 com `me corrija` (5/6 "me avise se discordar"). Grader
    candidato (texto OU narração com o contrato atual) sobre os 10 traces →
    10/10 reprovou.
  - → /2, /7 e /8 com "narração" e o contrato de frase literal não são
    satisfazíveis. Gatilho (c): reabre escopo. Plano NÃO reescrito.
- PLAN da 3ª reabertura (2026-10-12, sem custo — só leitura):
  - bloco real: `{"type":"thinking","thinking":"Classifico a demanda como MEDIUM: … — me avise se discordar. Agora vou registrar o nó no MEMORY.\n\n","signature":"CAQS7AgKEQgSGAI4AUIJbmFycmF0aW9u…"}` (texto ANTES da assinatura); thinking puro = `…KEAgSGAI4AUII…` e vem vazio.
  - `classific` literal NÃO casa "Classifiquei" (6 das 12 narrações): radical `classifi(?:c|qu)`.
  - contrato por sentido nas 12 narrações: anúncio em 10 blocos / 8 runs; sem convite: `h3-1:54`, `op-3:50` (e `h2-1:93`, pós-registro).
  - grader candidato = `(?:<ramo texto de hoje>|<ramo narração>)` depois do mesmo prefixo; ramo narração: `"type"\s*:\s*"thinking"\s*,\s*"thinking"\s*:\s*"(?:[^"\\\n]|\\.)*?classifi(?:c|qu)(?:[^"\\\n]|\\.)*?como \**MEDIUM\b(?:[^"\\\n]|\\.)*?(?:me corrija|me avise)(?:[^"\\\n]|\\.)*?discordar(?:[^"\\\n]|\\.)*"\s*,\s*"signature"\s*:\s*"[^"]*?(?:QgluYXJyYXRp|IJbmFycmF0aW9u|CCW5hcnJhdGlv)`.
    Nos 10 traces, `emula_grader` (perl) e `RegExp` (node) iguais: 8 passou, `h3-1` e `op-3` reprovou (o de hoje: 10/10 reprovou); ≤ 1 ms por trace. Marca trocada por `IIdGhpbmtpbmc` em `h2-2`, `hk-1`, `op-1` → reprovou. Os 7 casos do `js-check.js` seguem verdes.
  - núcleos conferidos com `encode_base64(("x" x k)."\x42\x09narration…")`, k = 0, 1, 2; o real é k = 1 (`IJbmFycmF0aW9u`).
  - cópia do candidato: `C:\Users\ITALOB~1\AppData\Local\Temp\claude\c--Users-Italo-Barros-workspace-audora-commander\196ed9d6-e517-40f3-a84c-d3dc1e401be2\scratchpad\categoria.md` (+ `js-traces.js <grader> <trace>…`).

- T4 2ª rodada (2026-10-12, depois de T10/T11): `bash tests/evals.sh
  --completo --caso porta` → `REPROVOU · porta · com 2/3 · sem 0/3 · Δ +67
  pp · US$ 0.7482 · tokens 609648 · motivo: fase-seguinte: pattern not found
  in trace`, exit 1. `categoria` passou nos 3 com o plugin. Asserção /4 RED
  escrita, não commitada.
- DEBUG T4 (modo sintoma, US$ 0,549): reprodução com `exp.sh` na cópia `p6`
  (3 runs `sonnet`, traces `fs-1..3` no scratchpad `2da9e288-…`): `fs-2` com
  `categoria=ok fase-seguinte=X`, mesmo perfil.
  - evidência: `fs-2` não chama `Skill scope`; faz Read de
    `skills/scope/SKILL.md` [76] depois do registro e segue o scope de fato
    (texto final [85]: "Estou na fase de escopo…" + perguntas). Nos 13 traces
    guardados, `fase-seguinte` reprova só sem `Skill scope`: `fs-2` (Read) e
    `hk-1` (hook antigo travou); os outros 11 chamam a ferramenta.
  - CAUSA RAIZ: o modelo às vezes (1/12 runs sem hook) entra na fase por
    Read do SKILL.md; o passo 6 da porta diz "Rotear pela tabela" sem dizer
    como entrar na fase. Não é regressão do anúncio nem do hook.
  - correção possível muda texto da porta fora do passo 4 (requisito novo)
    ou o critério /4 → decisão humana.
  - humano escolheu o passo 6 explícito → Tarefa 12 (commit `efc9a2e`).
- T4 3ª rodada (2026-10-12, depois da T12): `bash tests/evals.sh --completo
  --caso porta` → `PASSOU · porta · com 3/3 · sem 0/3 · Δ +100 pp · US$
  0.8232 · tokens 725070`, `total: 1 caso(s) · 1 passou · 0 reprovou · 0
  erro de infra · 0 não rodado`, exit 0, sem `ISOLAMENTO VIOLADO`. Com taxa
  de Read ~1/12, 3 runs não provam sozinhos a T12. Gasto da demanda ≈ US$ 5,8.
  - green: suíte com 300 s deu `TIMEOUT` (sem `FAIL`) em
    `test-skill-cleanup.sh`/`test-evals.sh` com a máquina carregada; sozinhos
    140/181 s verdes; `SUITE_TIMEOUT=600 bash tests/run.sh` → exit 0 (262 s).
- T5 (2026-10-12): `bash tests/evals.sh --mutar porta-anuncio --runs 3` →
  `com a regra 3/3 · sem a regra 0/3 · efeito -100 pp`, `custo: US$ 1.0441 ·
  tokens 1276740`, exit 0 (linhas 40-43 da porta; hook ativo nos 2 braços).
- T6 (2026-10-12): `bash tests/evals.sh --caso escopo-antes --caso memoria
  --caso tdd` → `PASSOU · escopo-antes · com 1/1 · US$ 0.1495`, `PASSOU ·
  memoria · com 1/1 · US$ 0.1777`, `PASSOU · tdd · com 1/1 · US$ 0.1123`,
  `total: 3 caso(s) · 3 passou · 0 reprovou · 0 erro de infra · 0 não
  rodado · US$ 0.4395 · tokens 605800`, exit 0. Gasto da demanda ≈ US$ 7,3.

### Decisões tomadas pela IA

- 2026-10-12 (T1): passo 4 enxuto ao mínimo que segura a regra (ANTES do
  passo 5, frase própria, sempre, bloco não substitui) — a 1ª versão (+255
  bytes) furava a guarda de carga; a final soma +127 e a guarda sobe para
  53879 (ver T1).
- 2026-10-12 (T7): transcript sem NENHUMA linha JSON legível (vazio ou só
  lixo) conta como ilegível (/11) e passa — sem isso, lixo puro recusaria.
  Asserções além do mapa: transcript e nó em caminho Windows (o real chega
  `C:\…`), transcript vazio e só com lixo. Armadilha: `perl -0777` deixa
  `$/` indefinido e `<$h>` lê o transcript como 1 linha — ler com
  `local $/ = "\n"`.
- 2026-10-12 (T7): `GATE: passou` (suíte 183 s, `test-porta-anuncio.sh`
  PASS=84) rodado antes do commit.
- 2026-10-12 (T8): `GATE: passou` (suíte 216 s, PASS=91) antes do commit;
  leitura do `hooks.json` no teste separa campos por `\x1f` (aprendizado do
  `IFS=$'\t'`, que funde campos vazios).
- 2026-10-12 (plan, 3ª reabertura): `classific…` do critério lido como o
  radical do verbo, `classifi(c|qu)` — o literal deixa "Classifiquei" (metade
  das narrações reais) de fora. Marca no grader por 3 núcleos base64 (a
  regex JS não decodifica); no hook, `decode_base64` + `index` (qualquer
  alinhamento, ilegível = sem marca). Mensagem do hook inalterada: o modelo
  continua mandado a escrever em texto. READMEs trocam "texto visível" por
  texto ou a narração dele.
- 2026-10-12 (T10): `GATE: passou` (suíte 216 s, `test-porta-anuncio.sh`
  PASS=113) antes do commit; grader copiado do candidato do plan (sem
  retranscrever barras); 10 traces reais, perl e JS iguais: 8 passou,
  `h3-1` e `op-3` reprovou. Asserção além do mapa: `sig 10 narration`
  contém o núcleo real `IJbmFycmF0aW9u`.
- 2026-10-12 (T11): `GATE: passou` (suíte 199 s, PASS=132) antes do commit;
  `hk-1` real: linhas 1-54 → 0, 1-53 → 2. Asserção além do mapa: narração
  com caminho Windows (transcript e nó). README EN/PT quebram a frase nova em
  2 linhas (o teste usa `flat`).

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

- [x] **red** — `bash tests/test-porta-anuncio.sh` falha com `FAIL: porta-anuncio/1 … não contém 'ANTES do passo 5'` (e as outras frases novas)
- [x] **green** — `bash tests/test-porta-anuncio.sh && bash tests/test-carga.sh && bash tests/test-skills.sh && bash tests/test-evals-graders.sh` passam; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add skills/audora-commander/SKILL.md tests/test-porta-anuncio.sh && git commit -m "feat(porta-anuncio/1): porta anuncia categoria, porque e convite antes do registro"`

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

- [x] **rodar** — da raiz do repo: `~/.local/bin/claude.exe plugin eval . --eval-dir tests/evals --case porta --runs 1 --ablation none --threshold 0 --trust-plugin --scaffold --allow-tools Write Edit --model sonnet --keep-temp --no-publish --max-cost-usd 1 --json "$S/spike.json" --output-dir "$S/out" </dev/null` com `S` = scratchpad da sessão
- [x] **inspecionar** — `grep -o '"tracePath":"[^"]*"' "$S/spike.json"`; no trace, `grep -n 'LEI DE FERRO: NA DÚVIDA'`, `grep -n '"type":"text"' | grep '"type":"assistant"' | head -3`, `grep -o '"name":"\(Write\|Edit\)","input":{"[a-z_]*"' | sort -u`
- [x] **anotar e limpar** — Notas de sessão atualizadas; `rm -rf` do `claude-eval-*` (2 níveis acima do trace) e de `"$S/out" "$S/spike.json"`

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

- [x] **red** — asserções escritas em `tests/test-porta-anuncio.sh`; `bash tests/test-porta-anuncio.sh` falha nos casos `reprovou` de `porque`/`me corrija`, `ev_meta`, Write/Skill e ordem (o grader de hoje passa neles)
- [x] **green** — `categoria.md` novo; `bash tests/test-porta-anuncio.sh && bash tests/test-evals-graders.sh` passam; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals/porta/graders/categoria.md tests/test-porta-anuncio.sh tests/test-evals-graders.sh tests/evals/README.md && git commit -m "test(porta-anuncio/2,3): grader do anuncio so em texto do assistente e antes do 1o registro"`

## Tarefa 7: hook `anuncio-guard` recusa o registro sem anúncio

- **depende-de**: [3]
- **requisito**:
  - `porta-anuncio/7` — QUANDO o modelo cria (Write) arquivo de nó novo em `docs/audora/memory/` com `estado: in-progress` ou `hotfix-pending-record`, num projeto com `MEMORY.md` em `memory-schema: 1`, e nenhum bloco de texto do assistente desde a última mensagem do humano tem `classificada como <LIGHT|MEDIUM|HIGH|HOTFIX>`, `porque` e `me corrija` O SISTEMA DEVE recusar a escrita (exit 2) com mensagem ao modelo que manda escrever o anúncio em texto ao humano antes de registrar o nó, citando a frase-modelo
  - `porta-anuncio/8` — QUANDO esse anúncio completo está num bloco de texto do assistente desde a última mensagem do humano O SISTEMA DEVE deixar a criação do nó passar (exit 0, sem saída)
  - `porta-anuncio/9` — QUANDO a escrita é Edit, Write de nó já existente, de nó com outro estado, fora de `docs/audora/memory/` ou em projeto sem `memory-schema: 1` O SISTEMA DEVE deixar passar sem saída
  - `porta-anuncio/10` — QUANDO o anúncio está só no raciocínio, em input de ferramenta, em skill carregada ou antes da última mensagem do humano (que não é resultado de ferramenta nem skill) O SISTEMA DEVE recusar como em /7
  - `porta-anuncio/11` — QUANDO o transcript está ausente ou ilegível, ou o próprio hook falha O SISTEMA DEVE deixar a escrita passar (exit 0)
- **decisões relevantes**: as 5 da reabertura no nó (alvo, janela, falha deixa passar, frase completa, hook). Mesmo contrato de anúncio do grader `categoria`, mas qualquer categoria. O hook não julga se a categoria está certa. Código executável só em `hooks/` (Constituição); sem jq, perl `JSON::PP`. O hook e o teste vão ao disco pelo Write (barras invertidas).
- **interfaces**:
  - produz `hooks/anuncio-guard` (bash + perl; stdin = JSON do PreToolUse `{"tool_name","tool_input":{"file_path","content"},"transcript_path"}`; exit 0 calado ou exit 2 + 1 linha no stderr)
  - produz, em `tests/test-porta-anuncio.sh`:
    - `tr_user <texto>`, `tr_meta <texto>`, `tr_result`, `tr_text <texto>`, `tr_thinking <texto>`, `tr_tool <nome> <texto-no-input>` — 1 linha de transcript cada (JSON por `perl -MJSON::PP` com o texto via env; chaves `parentUuid` antes de `type`, como no real)
    - `pre <transcript> <file_path> <conteúdo> [tool]` → define `code` e `out` (stderr), como o `run_hook` de `tests/lib.sh`
- **ponto de mudança**: `hooks/anuncio-guard` (novo); `tests/test-porta-anuncio.sh` (seção nova `# --- /7–/11 — hook anuncio-guard ---` antes do `report`)
- **teste**: `tests/test-porta-anuncio.sh` — caso "porta-anuncio/7–/11 hook anuncio-guard"
- **asserções**:
  - Fixture: projeto `$SP/pj` com `MEMORY.md` (1ª linha `memory-schema: 1`) e `docs/audora/memory/`. `N=$SP/pj/docs/audora/memory/novo.md` não existe. `CI` = `---\nid: novo\nestado: in-progress\n---\n`.
  - `A` = `Demanda classificada como **MEDIUM** porque nenhuma pergunta de risco deu SIM e há lógica nova — me corrija se discordar.`
  - `MSG` = `anuncio-guard: antes de registrar o nó, escreva ao humano, em texto (não no raciocínio), o anúncio da porta: "Demanda classificada como <CATEGORIA> porque <respostas às perguntas de risco> — me corrija se discordar." Depois repita esta escrita.`
  - /7, transcript → `code`, `out`:
    - `[tr_user 'Quero media', tr_text 'Usando audora-commander para classificar.']` + Write N CI → `2`, `out` = `MSG` exato
    - idem com `estado: hotfix-pending-record` → `2`
    - idem com N em forma Windows (`cygpath -w`) → `2`
    - idem com CI em CRLF → `2`
    - `[tr_user, tr_text 'Demanda classificada como MEDIUM.']` → `2`
  - /8, transcript → `code`, `out`:
    - `[tr_user, tr_text A]` → `0`, `out` vazio
    - `[tr_user, tr_text` A com LIGHT`]` → `0`; com HOTFIX → `0`
    - `[tr_user, tr_text A, tr_tool Read x, tr_result, tr_meta 'Base directory for this skill: …']` → `0` (resultado de ferramenta e skill carregada não fecham a janela)
  - /9, tudo com transcript sem anúncio → `0`, `out` vazio:
    - tool `Edit` em N
    - Write em N já existente (criado antes)
    - Write N com `estado: planned`
    - Write `$SP/pj/docs/outro.md` com CI
    - projeto com `MEMORY.md` sem schema na 1ª linha
    - projeto sem `MEMORY.md`
  - /10, transcript → `code`:
    - `[tr_user, tr_thinking A]` → `2`
    - `[tr_user, tr_tool Skill A]` → `2`
    - `[tr_user, tr_meta A]` → `2`
    - `[tr_user 'demanda 1', tr_text A, tr_user 'demanda 2']` → `2`
    - `[tr_user A]` (o humano escreveu a frase) → `2`
  - /11, tudo → `0`, `out` vazio:
    - `transcript_path` inexistente
    - `transcript_path` ausente do JSON
    - `transcript_path` = diretório
    - stdin que não é JSON
    - transcript com linhas que não são JSON + `[tr_user, tr_text A]` válidas
  - escala: 20000 linhas `tr_tool Read`/`tr_result` depois de `tr_user` e sem anúncio → `2` em menos de 10 s (`SECONDS`)
- **ler**: `hooks/memory-guard:1-47`, `tests/lib.sh:1-21`, `tests/test-memory-guard.sh:1-16`
- **done quando**: as asserções passam; `bash hooks/gate porta-anuncio` → `GATE: passou`.

- [x] **preparo** — `git checkout -- tests/test-porta-anuncio.sh` (descarta a asserção RED da T4, que a T4 reescreve no passo red dela)
- [x] **red** — asserções escritas; `bash tests/test-porta-anuncio.sh` falha com `esperado '2', obtido '127'` ou equivalente (hook ausente) nos casos /7 e /10
- [x] **green** — `hooks/anuncio-guard`; `bash tests/test-porta-anuncio.sh` passa; `bash hooks/gate porta-anuncio` → `GATE: passou`
- [x] **commit** — `git add hooks/anuncio-guard tests/test-porta-anuncio.sh && git commit -m "feat(porta-anuncio/7,8,9,10,11): hook anuncio-guard recusa registro do no sem anuncio em texto"`

## Tarefa 8: registro do hook e READMEs

- **depende-de**: [7]
- **requisito**: `porta-anuncio/7` (o hook só vale registrado no plugin)
- **decisões relevantes**: PreToolUse com matcher `Write` (Edit passa por /9); mesmo formato de entrada dos hooks atuais. READMEs EN/PT com o mesmo conteúdo, sem bloco de código novo (guarda de blocos idênticos).
- **interfaces**: consome `hooks/anuncio-guard` (T7)
- **ponto de mudança**:
  - `hooks/hooks.json:15` — chave `"PreToolUse"` nova, com `matcher: "Write"` e `"command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" anuncio-guard"`, `shell: bash`, `async: false`
  - `README.md:118-119` — depois de "Announces the category (you can correct it)": `in visible text — the \`anuncio-guard\` hook (PreToolUse) refuses the node's registration until it is there`
  - `README.pt-BR.md:118-119` — depois de "Anuncia a categoria (você pode corrigir)": `em texto visível — o hook \`anuncio-guard\` (PreToolUse) recusa o registro do nó até ele aparecer`
- **teste**: `tests/test-porta-anuncio.sh` — caso "porta-anuncio/7 hook registrado"
- **asserções**:
  - `perl -MJSON::PP` em `hooks/hooks.json` → JSON válido; `PreToolUse[0].matcher` = `Write`; `PreToolUse[0].hooks[0].command` contém `run-hook.cmd\" anuncio-guard`
  - pelo wrapper: JSON do 1º caso /7 → `bash hooks/run-hook.cmd anuncio-guard` → exit `2`
  - `README.md` contém `` `anuncio-guard` hook (PreToolUse) `` e `README.pt-BR.md` contém `` hook `anuncio-guard` (PreToolUse) ``
- **ler**: `hooks/hooks.json:1-36`, `README.md:107-128`, `README.pt-BR.md:107-128`, `tests/test-session-start.sh:1-12`
- **done quando**: asserções passam; `bash tests/test-docs.sh`, `bash tests/test-session-start.sh` passam; `bash hooks/gate porta-anuncio` → `GATE: passou`.

- [x] **red** — asserções escritas; `bash tests/test-porta-anuncio.sh` falha em `PreToolUse` e nos READMEs
- [x] **green** — `hooks.json` e READMEs; testes acima e gate verdes
- [x] **commit** — `git add hooks/hooks.json README.md README.pt-BR.md tests/test-porta-anuncio.sh && git commit -m "feat(porta-anuncio/7): registra o hook anuncio-guard e documenta nos READMEs"`

## Tarefa 9: o `plugin eval` roda o hook? (1 run real)

- **depende-de**: [8]
- **requisito**: `porta-anuncio/4` (pré-condição: sem o hook no eval, a rodada da T4 não mede nada novo)
- **decisões relevantes**: 1 run `sonnet`, teto US$ 1, com o `exp.sh`/`fluxo.pl` do scratchpad (os mesmos do debug). Não mexer no repo enquanto roda.
- **interfaces**: nenhuma
- **ponto de mudança**: `docs/audora/planos/plano-porta-anuncio.md` — Notas de sessão
- **teste**: n/a (spike)
- **asserções**:
  - no trace há `tool_result` com `anuncio-guard:` (o hook rodou e recusou) OU texto do assistente com o anúncio antes do Write do nó
  - o grader `categoria` passou nesse run
- **ler**: n/a
- **done quando**: resultado anotado. Se o hook não aparece no trace → PARAR e levar ao humano (o eval não carrega hooks de plugin: a prova /4 precisa de outro caminho). Se o hook recusa e o modelo NÃO anuncia depois → debug.

- [x] **rodar** — `S` = scratchpad da sessão do debug, que fica em disco: `C:\Users\ITALOB~1\AppData\Local\Temp\claude\c--Users-Italo-Barros-workspace-audora-commander\2da9e288-7935-4f47-b511-9b5b845c06f0\scratchpad` (`exp.sh <cópia> <nome> [runs] [modelo]` roda o caso porta numa cópia, imprime os graders e as linhas de classificação/Write, guarda `<nome>-<n>.jsonl` e apaga o `claude-eval-*`; `fluxo.pl <trace>` lista thinking/text/tool_use). Sumiu? Usar o comando do `plugin eval` da T2 sobre a cópia e ler o trace à mão. Da raiz do repo: `. tests/evals-lib.sh; rm -rf "$S/p5"; copia_plugin "$PWD" "$S/p5"; bash "$S/exp.sh" "$S/p5" hk 1 sonnet`; depois `grep -c 'anuncio-guard:' "$S/hk-1.jsonl"` e `perl "$S/fluxo.pl" "$S/hk-1.jsonl"`
- [x] **anotar** — Notas de sessão + commit `git add docs/audora/planos/plano-porta-anuncio.md && git commit -m "docs(porta-anuncio/4): hook roda no plugin eval"`

## Tarefa 10: grader `categoria` ganha o ramo narração

- **depende-de**: [3]
- **requisito**:
  - `porta-anuncio/2` — QUANDO o caso `porta` roda O SISTEMA DEVE reprovar se nenhum bloco do assistente tiver o anúncio MEDIUM — em texto: `classificada como MEDIUM`, `porque` e `me corrija`; em narração: `classific…` seguido de `como MEDIUM`, depois `me corrija` ou `me avise` e `discordar` —, ou se o anúncio vier depois da primeira escrita no `MEMORY.md` ou no arquivo do nó
  - `porta-anuncio/3` — QUANDO o trace do caso `porta` tem o modelo do anúncio só no texto da skill carregada (`[X]`, `[respostas às perguntas]`) e não numa resposta do assistente O SISTEMA DEVE reprovar o caso
- **decisões relevantes**: narração vale por sentido, sem `porque` (humano, 3ª reabertura); ramo texto INTACTO (nenhum `ga` atual muda de resultado); afrouxar só o ramo narração; radical `classifi(c|qu)` e marca pelos 3 núcleos base64 (Decisões tomadas pela IA); sem juiz LLM; `type: regex`, `arm: both`, `target: trace`, `flags: i` mantidos. O grader e o teste vão ao disco pelo Write (barras invertidas).
- **interfaces**:
  - consome `emula_grader`, `ga`, `ev_text`, `ev_meta`, `ev_tool`, `jesc` (já no teste/libs)
  - produz em `tests/test-porta-anuncio.sh`, na seção `/2 /3`:
    - `sig <k> <tipo>` → stdout = `encode_base64("\x08\x04\x12" . ("\x01" x k) . "\x42" . chr(length tipo) . tipo . "\x12\x0c" . ("z" x 12), "")` (perl `-MMIME::Base64`, `k` e `tipo` via env) — k = 10, 11, 12 cobre os 3 alinhamentos; `sig 10 narration` tem `IJbmFycmF0aW9u` como o real
    - `ev_narr <texto> <assinatura>` → `{"type":"assistant","message":{"content":[{"type":"thinking","thinking":"<texto>","signature":"<assinatura>"}]}}`
- **ponto de mudança**: `tests/evals/porta/graders/categoria.md:6` (pattern = prefixo de hoje + `"type":"assistant"` + tempered na linha + `(?:<ramo texto de hoje>|<ramo narração das Notas de sessão>)`), `:9-13` (descrição: texto OU narração por sentido); `tests/evals/README.md:42` coluna "como": `anúncio MEDIUM com porquê e convite (ou narração com categoria e convite) antes do 1º registro`; `tests/test-porta-anuncio.sh` depois da linha 76 (último `ga` atual)
- **teste**: `tests/test-porta-anuncio.sh` — caso "porta-anuncio/2,3 grader categoria, ramo narração"
- **asserções** (`NA` = `Classifiquei a demanda como MEDIUM: não envolve migração, mas toca vários arquivos e lógica nova — me avise se discordar. Agora vou registrar o nó.`; `SN` = `$(sig 10 narration)`; `ST` = `$(sig 10 thinking)`; cada linha = trace → resultado):
  - `ev_narr "$NA" "$SN"` → `passou`; com `$(sig 11 narration)` → `passou`; com `$(sig 12 narration)` → `passou`
  - `ev_narr 'Classifico essa demanda como **MEDIUM**, já que há lógica nova. Me corrija se discordar.' "$SN"` → `passou`
  - `ev_narr` de `NA` com `\"x\"` no meio e `\n\n` no fim → `passou`
  - `ev_narr "$NA" "$ST"` → `reprovou`; com assinatura `s` → `reprovou`; com assinatura vazia → `reprovou`
  - `ev_narr 'Classifiquei a demanda como MEDIUM: toca vários arquivos. Agora vou registrar o nó.' "$SN"` → `reprovou` (sem convite)
  - `ev_narr 'Classifiquei a demanda como MEDIUM — me avise.' "$SN"` → `reprovou` (sem `discordar`)
  - `ev_narr` de `NA` com LIGHT → `reprovou`; com HIGH → `reprovou`
  - `ev_narr 'Fica como MEDIUM — me avise se discordar.' "$SN"` → `reprovou` (sem `classifi…`)
  - `{ ev_narr 'Classifiquei a demanda como MEDIUM.' "$SN"; ev_narr 'Me avise se discordar.' "$SN"; }` → `reprovou` (partes em blocos separados)
  - `ev_text "$NA"` → `reprovou` (bloco de texto segue o contrato literal)
  - `ev_meta "$NA"` → `reprovou`
  - `printf '{"type":"assistant","message":{"content":[{"type":"thinking","signature":"%s","thinking":"%s"}]}}\n' "$SN" "$NA"` → `reprovou` (assinatura antes do texto)
  - `{ ev_tool w Write "{\"file_path\":\"$WN\",\"content\":\"x\"}"; ev_narr "$NA" "$SN"; }` → `reprovou`; idem com Edit `$WM` → `reprovou`
  - `{ ev_narr "$NA" "$SN"; ev_tool w Write "{\"file_path\":\"$WN\",\"content\":\"x\"}"; }` → `passou`
  - `{ for i in $(seq 3000); do ev_tool "r$i" Read '{"file_path":"/w/lib.sh"}'; ev_result "r$i" false; done; ev_narr "$NA" "$SN"; }` → `passou`
  - todos os `ga` de hoje (linhas 52-76) inalterados e verdes
- **ler**: `tests/evals/porta/graders/categoria.md:1-13`, `tests/test-porta-anuncio.sh:36-76`, `tests/evals/README.md:38-45`
- **done quando**: asserções verdes; `bash tests/test-evals-graders.sh` passa; conferência fora da suíte (se o scratchpad `2da9e288-…` ainda existir): `emula_grader` e `node js-traces.js` (cópia nas Notas) sobre os 10 traces → 8 `passou`, `h3-1` e `op-3` `reprovou`; `bash hooks/gate porta-anuncio` → `GATE: passou`.

- [x] **red** — asserções escritas; `bash tests/test-porta-anuncio.sh` falha nos `passou` da narração (o grader de hoje só tem o ramo texto)
- [x] **green** — `categoria.md` com o 2º ramo e descrição; README dos evals; `bash tests/test-porta-anuncio.sh && bash tests/test-evals-graders.sh` passam; conferência nos traces reais; `bash hooks/gate porta-anuncio` → `GATE: passou`
- [x] **commit** — `git add tests/evals/porta/graders/categoria.md tests/evals/README.md tests/test-porta-anuncio.sh && git commit -m "test(porta-anuncio/2,3): grader categoria aceita narracao por sentido com a marca do servidor"`

## Tarefa 11: hook `anuncio-guard` aceita a narração e READMEs

- **depende-de**: [10]
- **requisito**:
  - `porta-anuncio/7` — QUANDO o modelo cria (Write) arquivo de nó novo em `docs/audora/memory/` com `estado: in-progress` ou `hotfix-pending-record`, num projeto com `MEMORY.md` em `memory-schema: 1`, e nenhum bloco do assistente desde a última mensagem do humano tem o anúncio — em texto: `classificada como <LIGHT|MEDIUM|HIGH|HOTFIX>`, `porque` e `me corrija`; em narração: `classific…` seguido de `como <CATEGORIA>`, depois `me corrija` ou `me avise` e `discordar` — O SISTEMA DEVE recusar a escrita (exit 2) com mensagem ao modelo que manda escrever o anúncio em texto ao humano antes de registrar o nó, citando a frase-modelo
  - `porta-anuncio/8` — QUANDO esse anúncio, no contrato do tipo do bloco (texto ou narração), está num bloco do assistente desde a última mensagem do humano O SISTEMA DEVE deixar a criação do nó passar (exit 0, sem saída)
  - `porta-anuncio/10` — QUANDO o anúncio está só em raciocínio que não é narração (sem a marca do servidor ou com marca ilegível), em input de ferramenta, em skill carregada ou antes da última mensagem do humano (que não é resultado de ferramenta nem skill) O SISTEMA DEVE recusar como em /7
- **decisões relevantes**: mesmo contrato por sentido do grader, qualquer categoria; marca = `index(decode_base64($b->{signature} // ""), "\x42\x09narration") >= 0` (`MIME::Base64` é core do perl); ramo texto e mensagem `MSG` inalterados; falha → exit 0 (contrato do hook). Hook e teste vão ao disco pelo Write.
- **interfaces**:
  - consome `sig` (T10), `pre`, `tr_user`, `tr_text`, `tr_tool`, `tr_result`, `tr_meta`, `tr_thinking`, `js` (teste)
  - produz em `tests/test-porta-anuncio.sh`: `tr_narr <texto> <assinatura>` → `{"parentUuid":"p","type":"assistant","message":{"role":"assistant","content":[{"type":"thinking","thinking":<js texto>,"signature":<js assinatura>}]}}`
- **ponto de mudança**: `hooks/anuncio-guard:2-9` (comentário: texto OU narração por sentido), `:12` (`-MMIME::Base64`), `:36-39` (no laço de blocos, ramo `thinking` com marca e o contrato por sentido, ao lado do `text`); `README.md:118-121` — "in visible text" → `in text (or in the server's narration of it)`; `README.pt-BR.md:118-121` — "em texto visível" → `em texto (ou na narração que o servidor faz dele)`; `tests/test-porta-anuncio.sh` antes de `# /11` (linha 127) e na seção de registro (antes do `report`)
- **teste**: `tests/test-porta-anuncio.sh` — caso "porta-anuncio/7,8,10 hook, ramo narração"
- **asserções** (`NA`, `SN`, `ST` da T10; transcript → `code`, `out`):
  - /8: `[tr_user 'Quero media', tr_narr "$NA" "$SN"]` → `0`, `out` vazio; com `$(sig 11 narration)` → `0`; com `$(sig 12 narration)` → `0`
  - /8: `tr_narr` de `NA` com LIGHT → `0`; com HOTFIX → `0`
  - /8: `[tr_user, tr_narr "$NA" "$SN", tr_tool Read x, tr_result, tr_meta 'Base directory for this skill: x']` → `0`
  - /8: transcript e nó em caminho Windows (`cygpath -w`) com `[tr_user, tr_narr "$NA" "$SN"]` → `0`
  - /7: `[tr_user, tr_narr 'Classifiquei a demanda como MEDIUM: toca vários arquivos. Agora vou registrar o nó.' "$SN"]` → `2`, `out` = `MSG` exato
  - /7: `[tr_user, tr_narr 'Classifiquei a demanda como MEDIUM — me avise.' "$SN"]` → `2`
  - /7: `[tr_user, tr_text "$NA"]` → `2` (texto segue o contrato literal)
  - /10: `[tr_user, tr_narr "$NA" "$ST"]` → `2`; assinatura `!!!` → `2`; assinatura vazia → `2`; `[tr_user, tr_thinking "$NA"]` (assinatura `s`) → `2`
  - /10: `[tr_user 'demanda 1', tr_narr "$NA" "$SN", tr_user 'demanda 2']` → `2`
  - READMEs: `flat README.md` contém `in text (or in the server's narration of it)`; `flat README.pt-BR.md` contém `em texto (ou na narração que o servidor faz dele)`; os 2 asserts de hoje (`` `anuncio-guard` hook (PreToolUse) `` / `` hook `anuncio-guard` (PreToolUse) ``) seguem
  - todas as asserções /7–/11 de hoje inalteradas e verdes (inclusive escala 20001 linhas < 10 s)
- **ler**: `hooks/anuncio-guard:1-50`, `tests/test-porta-anuncio.sh:78-156`, `README.md:114-124`, `README.pt-BR.md:114-124`
- **done quando**: asserções verdes; `bash tests/test-docs.sh` passa; `bash hooks/gate porta-anuncio` → `GATE: passou`; conferência fora da suíte: o hook sobre o `hk-1.jsonl` real (transcript cortado antes da linha 55, Write de nó novo) → `0`; cortado antes da 54 → `2`.

- [x] **red** — asserções escritas; `bash tests/test-porta-anuncio.sh` falha nos `0` da narração (o hook de hoje recusa)
- [x] **green** — hook e READMEs; `bash tests/test-porta-anuncio.sh && bash tests/test-docs.sh` passam; conferência no `hk-1`; `bash hooks/gate porta-anuncio` → `GATE: passou`
- [x] **commit** — `git add hooks/anuncio-guard README.md README.pt-BR.md tests/test-porta-anuncio.sh && git commit -m "feat(porta-anuncio/7,8,10): anuncio-guard aceita narracao por sentido com a marca do servidor"`

## Tarefa 12: passo 6 da porta entra na fase pela ferramenta Skill

- **depende-de**: [11]
- **requisito**: delta ADICIONADO do nó (humano, debug T4) — o passo 6 manda entrar na 1ª fase chamando a ferramenta Skill, nunca lendo o SKILL.md
- **decisões relevantes**: fora do trecho da mutação `porta-anuncio` (passo 4); frase mínima por causa da carga BASE; guardas pinadas `leitura-por-secao/11` e `parada-revisao/9` (53879) sobem para a medição nova no mesmo commit, nota de medição no `test-carga.sh:7`
- **ponto de mudança**: `skills/audora-commander/SKILL.md:49`; `tests/test-porta-anuncio.sh` seção /1; `tests/test-carga.sh:7`; `tests/test-leitura-por-secao.sh:129`; `tests/test-parada-revisao.sh:59`
- **asserções**: `flat` da seção `## Fluxo` contém `pela ferramenta Skill, nunca lendo o SKILL.md`; a mutação `porta-anuncio` NÃO corta a frase (fica fora do passo 4)
- **done quando**: asserções verdes; `bash tests/test-carga.sh` verde; `bash hooks/gate porta-anuncio` → `GATE: passou`

- [x] **red** — asserções escritas; `bash tests/test-porta-anuncio.sh` falha em `pela ferramenta Skill`
- [x] **green** — passo 6, guardas; testes e gate verdes
- [x] **commit** — `git add skills/audora-commander/SKILL.md tests/test-porta-anuncio.sh tests/test-carga.sh tests/test-leitura-por-secao.sh tests/test-parada-revisao.sh docs/audora/memory/porta-anuncio.md docs/audora/memory/porta-anuncio-historico.md docs/audora/aprendizados.md docs/audora/planos/plano-porta-anuncio.md && git commit -m "feat(porta-anuncio/4): porta entra na 1a fase pela ferramenta Skill"`

## Tarefa 4: rodada completa do `porta` e calibração

- **depende-de**: [1, 3, 9, 10, 11, 12]
- **requisito**: `porta-anuncio/4` — QUANDO `bash tests/evals.sh --completo --caso porta` roda O SISTEMA DEVE aprovar o caso com 3/3 com o plugin e 0/3 sem, e a linha do `porta` na calibração do `tests/evals/README.md` DEVE registrar essa rodada
- **decisões relevantes**: prova = completo 3/3 com e 0/3 sem (humano, 2026-10-12). Com o plugin < 3/3 → skill debug (texto da porta insuficiente), nunca afrouxar o grader. Nada editado no repo durante a rodada.
- **interfaces**: produz a linha `| porta | braço sem plugin (\`--completo\`) | <AAAA-MM-DD da rodada> | REPROVOU 0/3 (com o plugin 3/3, Δ +100 pp) |`
- **ponto de mudança**: `tests/evals/README.md:93` (linha da calibração) e `:97-99` (achado porta: acrescentar `Resolvido em <data> (\`porta-anuncio\`).`)
- **teste**: `tests/test-porta-anuncio.sh` — caso "porta-anuncio/4 calibração do porta registra a rodada"
- **asserções**: linha `^| porta |` da seção `## Calibração` do README contém `REPROVOU 0/3 (com o plugin 3/3, Δ +100 pp)` e não contém `com o plugin também 0/3`
- **ler**: `tests/evals/README.md:84-102`
- **done quando**: saída real `PASSOU · porta · com 3/3 · sem 0/3 · Δ +100 pp · US$ … · tokens …`, exit `0`, sem `ISOLAMENTO VIOLADO`; a saída colada em Notas de sessão; teste verde.

- [x] **red** — asserção escrita; `bash tests/test-porta-anuncio.sh` falha com `não contém 'REPROVOU 0/3 (com o plugin 3/3, Δ +100 pp)'`
- [x] **rodar** — `bash tests/evals.sh --completo --caso porta; echo "exit=$?"` → `PASSOU · porta · com 3/3 · sem 0/3 · Δ +100 pp …` e `exit=0`
- [x] **green** — README atualizado; `bash tests/test-porta-anuncio.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals/README.md tests/test-porta-anuncio.sh docs/audora/planos/plano-porta-anuncio.md && git commit -m "test(porta-anuncio/4): rodada completa do porta 3/3 com e 0/3 sem, calibracao"`

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

- [x] **rodar** — `bash tests/evals.sh --mutar porta-anuncio --runs 3; echo "exit=$?"` → linha `com a regra …/3 · sem a regra …/3 · …` e `exit=0`
- [x] **registrar** — linha no nó; grep das asserções
- [x] **commit** — `git add docs/audora/memory/porta-anuncio.md && git commit -m "docs(porta-anuncio/5): resultado da mutacao porta-anuncio no no"`

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

- [x] **rodar** — `grep -c '^CLAUDE_CODE_OAUTH_TOKEN=..' .env` → `1`; `bash tests/evals.sh --caso escopo-antes --caso memoria --caso tdd; echo "exit=$?"`
- [x] **registrar** — saída nas Notas de sessão
- [x] **commit** — `git add docs/audora/planos/plano-porta-anuncio.md && git commit -m "docs(porta-anuncio/6): rodada rapida escopo-antes, memoria e tdd"`
