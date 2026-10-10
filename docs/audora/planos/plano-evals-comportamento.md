# Plano — evals-comportamento: Evals de comportamento

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** comando manual `bash tests/evals.sh` que roda 4 casos de
comportamento (porta, escopo-antes, memoria, tdd) com e sem o plugin, isolado,
com teto de custo, relatório por caso e mutação de regra.

**Nó do MEMORY:** `evals-comportamento` (MEMORY.md)

**Arquitetura da mudança:** um orquestrador bash (`tests/evals.sh` +
funções em `tests/evals-lib.sh`, perl `JSON::PP` como os hooks) que chama
`claude plugin eval` UMA vez por caso para porta/escopo-antes/memoria
(isolamento, scaffold e graders nativos do host) e um harness próprio
`claude -p` para o tdd (Bash sem sandbox é recusado pelo `plugin eval` no
Windows nativo). O orquestrador soma custo e tokens, aplica o teto entre
invocações, classifica erro de infra, confere isolamento e decide o exit.
Suíte em `tests/evals/` (`--eval-dir tests/evals`): a Constituição só permite
código executável em `hooks/` e `tests/`, e os casos têm scripts de scaffold.
Toda lógica é testada offline em `tests/test-evals.sh` com um `claude` falso
(`--claude <stub>`); o real só roda na Tarefa 15.

**Decisões tomadas pela IA** (a validate apresenta):
- Suíte em `tests/evals/`, não `evals/` (Constituição: executável só em
  `hooks/`+`tests/`); manifest não ganha `experimental.evals`.
- Modelo padrão fixado em `sonnet` (`--modelo` troca): custo e comparabilidade.
- Ganchos de teste por FLAG, não env: `--claude <bin>`, `--raiz <dir>`,
  `--timeout-run <s>` — só `CLAUDE_CODE_OAUTH_TOKEN`/`ANTHROPIC_API_KEY` vêm
  do ambiente (ou do `.env`).
- Harness tdd isolado por `CLAUDE_CONFIG_DIR`/`HOME`/`USERPROFILE`
  temporários + `env -i`; sem token por env o caso é RECUSADO (copiar
  `.credentials.json` arriscaria rotacionar o refresh token do humano).
- Todo grader com `arm: both` (senão `tool_used: Skill` sai da nota no modo
  completo e o braço sem plugin vira comparação falsa).
- escopo-antes: num run não interativo o nó nunca tem critérios aprovados →
  QUALQUER escrita fora de `MEMORY.md`/`docs/audora/` no run reprova
  (mais estrito que "antes de o nó ter critérios").
- memoria: grader extra `aprendizado-registrado` (aprendizado do prompt em
  `docs/audora/aprendizados.md`) — sem ele o caso passa vazio quando nada é
  escrito (evals-comportamento/13).
- `--threshold 0` no `plugin eval`: o veredito é do orquestrador (score 1 e
  `error` nulo por run); exit 1 do host vira erro de infra.
- Mutação é relatório: sai 0 mesmo com `sem efeito`.
- (execute) Agregação por braço (`agrega_caso`) entrou já na Tarefa 2; a
  Tarefa 4 só trocou a invocação (`--runs 3 --ablation with-without`) — a
  mutação do ramo completo derruba 4 asserções (provado).
- (execute) Isolamento: run sem erro e sem evento `init` no trace → RECUSADO
  (`sem evento init no trace`); raiz fora de repo git → RECUSADO (sem como
  conferir o `git status`); `tool_result` sem `is_error` = sucesso
  (confirmado no trace real).
- (execute) Harness: fixture que sai ≠ 0 → ERRO INFRA `fixture saiu N`, sem
  chamar `-p`; teto checado entre runs do mesmo caso.
- (execute) Mutação: cabeçalho `evals: mutação · …`, linha final `custo:`;
  infra/teto/recusado reportados com as linhas de caso; cópia via
  `git ls-files -co --exclude-standard` + `tar` (<1 s no repo real).
- (execute) Graders de `trace` toleram espaço entre chave e valor
  (`"name"\s*:\s*"Skill"`): a doc diz "JSON, uma mensagem por linha", sem
  garantir o mesmo formato do `trace.jsonl`; a Tarefa 15 confirma.
- (execute) Emulador: `target` de arquivo ausente reprova (também com
  `not_contains`).
- (execute, rodada real 2026-10-10) Harness: `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1`
  (o `CLAUDE.md` global vazava apesar de HOME/config temporários — provado
  com marcadores) e Bash livre (decisão do humano; `Bash(bash *)` negava o
  comando composto e o run parava no RED).
- (execute, rodada real) `grader_tdd`: falha lida também na saída (`; echo
  "exit=$?"` zera o `is_error`), "teste rodado" = `bash|sh|./` em `tests/`
  (não `git add tests/…`), e escrita por Bash (`>`, `>>`, `tee`, corpo de
  heredoc descartado) conta como teste novo/código, na ordem do comando.
- (execute) Testes do orquestrador em 3 arquivos (`test-evals.sh`,
  `test-evals-harness.sh`, `test-evals-graders.sh` + `evals-testlib.sh`): 1
  só passava de 300 s na suíte paralela. O guarda de evals-comportamento/12
  passa a exigir, em CADA arquivo que cita o orquestrador, chamada só via
  `roda_evals` com o stub e o `assert_no_file chamou-claude`.
- (execute) Achados viram nós `planned`: `porta-anuncio` (decisão do humano)
  e `retomada-execute` (IA, mesmo critério).
- (execute) Commit do `MEMORY.md` só com as linhas desta demanda (blob sobre
  `HEAD`): as linhas de índice de cerimonia-enxuta, gate-anti-edicao,
  status-retomada, aprendizados-escopo e a mudança de agentes-dedicados
  seguem não commitadas, como estavam.

**Arquivos lidos antes de planejar:**
- `MEMORY.md:1-103` — Constituição (executável só em hooks/tests; como-rodar; ferramenta-e2e `claude -p`), índice (linha do nó com arquivos-chave `evals/, tests/`)
- `docs/audora/memory/evals-comportamento.md:1-95` — 13 critérios, fora-de-escopo, decisões do humano
- `docs/study/2026-10-09-estudo-aprimoramento.md:40-60` e `:90-180` — B1/B2, `plugin eval` recusa Bash no Windows nativo
- `docs/audora/aprendizados.md` (grep plan/eval/custo) — `claude` fora do PATH (`~/.local/bin/claude.exe`); `total_cost_usd` acumula; `git add` explícito; exit de pipe
- `templates/plano-template.md:1-50` — formato
- `tests/run.sh:1-68` — glob `tests/test-*.sh` só no topo; `int_env`; `timeout -k 5` com fallback
- `tests/lib.sh:1-21` — `ok/ko/assert_*`, `run_hook`, `report`, `$SP` temporário
- `hooks/memory-guard:1-40` — padrão perl `JSON::PP` para JSON
- `hooks/memory-validate:1-30` — contrato (exit 2 em índice/nó inválido)
- `hooks/session-start:1-12` — ponteiro injetado (âncora possível de mutação)
- `hooks/cleanup:254-266`, `:367` — fence ignorado; `## nunca existiu`
- `tests/test-dogfood.sh:1-27` — MEMORY deste repo validado; sem linha de aprendizado no MEMORY
- `skills/audora-commander/SKILL.md:1-96` — anúncio "Demanda classificada como [X]" (l.40-41), LIGHT com EARS no registro (l.42-46), tabela de roteamento (l.49-54)
- `skills/memory/SKILL.md:1-138` — carregar-contexto (oferta de gate sem `gate:`), registrar-aprendizado (l.113-116)
- `skills/scope/SKILL.md:1-64` — Lei de Ferro (l.9), portão (l.~58), PARADA
- `skills/execute/SKILL.md:1-50` — Lei de Ferro (l.9), "apague" (l.14-15), ciclo RED/GREEN
- `templates/bloco-fechamento-template.md:101-124` (grep) — porta → 1ª fase sem parada
- `templates/MEMORY-template.md:1-63`, `templates/no-template.md:1-72`, `templates/aprendizados-template.md:1-10` — schema da fixture
- `.gitignore:1-3`, `.claude-plugin/plugin.json:1-8` — sem `.env`; versão 0.16.0
- `claude --help`, `claude plugin eval --help` (CLI 2.1.284) — flags reais
- doc `code.claude.com/docs/en/plugin-evals.md` — schema de caso/grader, isolamento, exit 0/1/2/130/143, campos do JSON
- spikes (scratchpad desta sessão, 2026-10-09): JSON do `plugin eval` NÃO tem tokens; com `--keep-temp` o `out/trace.jsonl` termina numa linha com `total_cost_usd`+`usage`, e o diretório `claude-eval-*` fica para trás (Windows não sela — o orquestrador apaga); `--setting-sources project,local` NÃO isola (`CLAUDE.md` global e plugins `agents-md@builtin`/`telemetry@builtin` carregam); `CLAUDE_CONFIG_DIR` temporário isola mas dá `result.is_error` "Not logged in"; scaffold roda no Git Bash com `BASH_SOURCE` = caminho do caso, `git` e `perl` presentes

**Conflitos MEMORY vs código encontrados:** nenhum. Ajuste de metadado: os
arquivos-chave da linha do índice passam de `evals/, tests/` para
`tests/evals/, tests/evals.sh, tests/evals-lib.sh, tests/test-evals.sh`.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

- Pré-requisito humano da Tarefa 15: `claude setup-token` e o token em
  `.env` (`CLAUDE_CODE_OAUTH_TOKEN=`). Sem ele o caso tdd fica RECUSADO e
  evals-comportamento/13 não fecha para o tdd.
- Formatos a confirmar na 1ª execução real (gatilho de replanejamento (a)/(b)
  se divergirem): ordem das chaves do `tool_use` no trace, `is_error` do
  `tool_result` de Bash com exit ≠ 0, texto do `error` de limite de turnos,
  e se `dontAsk` + `--allowedTools` deixa o tdd rodar `bash tests/run.sh`.

---

## Contratos comuns (valem para todas as tarefas)

Uso:

```
bash tests/evals.sh [--completo] [--caso <nome>]... [--teto <usd>] [--modelo <m>]
                    [--mutar <regra-id> [--runs <n>]]
                    [--claude <bin>] [--raiz <dir>] [--timeout-run <s>]
```

- Padrões: modo rápido; todos os casos; `--teto 10`; `--modelo sonnet`;
  `--claude` = `claude` do PATH, senão `$HOME/.local/bin/claude.exe`;
  `--raiz` = raiz do repo; `--timeout-run 900`; `--runs 3` (só com `--mutar`).
- Casos = subpastas de `<raiz>/tests/evals/` com `prompt.md` (tipo
  plugin-eval) ou `harness.md` (tipo harness), fora as que começam com `_`,
  em ordem alfabética: `escopo-antes`, `memoria`, `porta`, `tdd`.
- Linha por caso (separador ` · `, sem alinhamento):

```
evals: modo rápido · modelo sonnet · teto US$ 10.00
PASSOU · porta · com 1/1 · US$ 0.4123 · tokens 16481
REPROVOU · memoria · com 0/1 · US$ 0.3011 · tokens 9800 · motivo: no-com-ears: no match
ERRO INFRA · tdd · causa: sem autenticação · US$ 0.0000 · tokens 0
RECUSADO · tdd · isolamento: <motivo>
NÃO RODADO · escopo-antes · não rodado: teto
total: 4 caso(s) · 1 passou · 1 reprovou · 2 erro de infra · 1 não rodado · US$ 0.7134 · tokens 26281
```

  Completo troca `com 1/1` por `com 3/3 · sem 1/3 · Δ +67 pp`
  (Δ = arredondado de 100×(com−sem)/runs, sinal sempre impresso).
  Custo `%.4f`; tokens = `input_tokens + cache_creation_input_tokens +
  cache_read_input_tokens + output_tokens` do evento `result`. RECUSADO conta
  como erro de infra no total.
- Exit: `0` tudo rodado passou e nenhum erro de infra · `1` algum reprovou ·
  `2` teto atingido · `3` erro de infra, RECUSADO ou isolamento violado ·
  `4` uso inválido. Precedência `3 > 2 > 1 > 0`.
- Funções de `tests/evals-lib.sh` são `source`-áveis sem efeito colateral;
  `tests/test-evals.sh` usa `source "$(dirname "$0")/lib.sh"` e chama o
  orquestrador SÓ pela função `roda_evals() { bash "$ROOT/tests/evals.sh" --claude "$STUB" --raiz "$RZ" "$@"; }`.
- Stub: script bash gerado pelo teste em `$SP`, comportamento por
  `STUB_CENARIO`, grava os argumentos de cada chamada (1 por linha) em
  `$SP/stub.log`, e escreve o JSON/trace canônico do cenário.

---

## Tarefa 1: Esqueleto do orquestrador — argumentos, .env, pré-checagem, exit

- **depende-de**: []
- **requisito**: `evals-comportamento/9` — QUANDO um run falha por infraestrutura (claude ausente ou abaixo da versão mínima, sem autenticação, timeout, erro de API) O SISTEMA DEVE marcar `erro de infra` com a causa, separado de reprovado, e nunca contar o run como aprovado (parte: claude ausente / versão) · `evals-comportamento/11` — QUANDO a rodada termina O SISTEMA DEVE sair 0 só se todos os casos rodados passaram e nenhum ficou em erro de infra (parte: exit e precedência)
- **decisões relevantes**: flags como gancho de teste; versão mínima `2.1.269` (doc do `plugin eval`); perl `JSON::PP`
- **interfaces**: produz `tests/evals.sh` (uso acima) · `tests/evals-lib.sh`: `acha_claude` → caminho ou vazio; `versao_ok <versao> <minima>` → exit 0/1 (`sort -V`); `carrega_env <arquivo>` → exporta `CHAVE=valor` só se a variável está unset, o valor não é vazio e não é `__coloque_o_valor__`; `lista_casos <raiz>` → `nome<TAB>tipo` por linha; `linha_total` e `exit_rodada` a partir dos contadores
- **ponto de mudança**: `tests/evals.sh` (novo), `tests/evals-lib.sh` (novo), `tests/test-evals.sh` (novo)
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/9 claude ausente", "/9 versão abaixo", "/11 exit de uso", "carrega_env"
- **asserções**:
  - `--teto abc` → exit 4, stderr `evals: --teto inválido ('abc')`; `--teto 0` → idem com `'0'`
  - `--caso nada` → exit 4, stderr `evals: caso desconhecido: nada`
  - `--runs 2` sem `--mutar` → exit 4, stderr `evals: --runs só vale com --mutar`
  - `--claude /nao/existe` (raiz com casos `a` e `b`) → `ERRO INFRA · a · causa: claude ausente (/nao/existe) · US$ 0.0000 · tokens 0` e o mesmo para `b`, exit 3
  - stub `--version` → `2.1.268 (Claude Code)` → `causa: claude 2.1.268 abaixo da mínima 2.1.269`, exit 3, nenhuma outra chamada no `stub.log`
  - `versao_ok 2.1.284 2.1.269` → 0; `versao_ok 2.1.268 2.1.269` → 1; `versao_ok 2.10.0 2.9.9` → 0
  - `.env` com `CLAUDE_CODE_OAUTH_TOKEN=__coloque_o_valor__` → variável segue unset; `X=1` com X unset → `X=1`; X já `=2` no ambiente → fica `2`; linha `# comentário` e linha vazia ignoradas
  - cabeçalho: `evals: modo rápido · modelo sonnet · teto US$ 10.00`
- **ler**: `tests/lib.sh:1-21`, `tests/run.sh:13-30`, `hooks/memory-guard:9-14`
- **done quando**: as asserções acima passam em `bash tests/test-evals.sh` e `bash tests/run.sh` sai 0

- [x] **red** — `bash tests/test-evals.sh` falha com `FAIL: ... evals-comportamento/9` (orquestrador inexistente)
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals.sh tests/evals-lib.sh tests/test-evals.sh && git commit -m "feat(evals-comportamento/9,11): esqueleto do orquestrador de evals"`

## Tarefa 2: Caso plugin-eval no modo rápido — invocação, custo, tokens, motivo, infra

- **depende-de**: [1]
- **requisito**: `evals-comportamento/1` — QUANDO o humano roda o comando de evals em modo rápido O SISTEMA DEVE rodar cada caso 1 vez com o plugin e imprimir, por caso, passou/reprovou com o motivo, custo e tokens, mais o total da rodada · `evals-comportamento/9` (parte: sem autenticação, timeout, erro de API)
- **decisões relevantes**: `--threshold 0`; veredito do run = `score == 1` e `error` nulo; `--keep-temp` para ler tokens do trace e depois apagar `claude-eval-*`
- **interfaces**: invocação exata (ordem importa: alvo antes de `--allow-tools`):
  `<claude> plugin eval <raiz> --eval-dir tests/evals --case <caso> --runs 1 --ablation none --threshold 0 --trust-plugin --scaffold --allow-tools Write Edit --model <m> --keep-temp --no-publish --max-cost-usd <restante %.4f> --json <tmp>/r.json --output-dir <tmp>/out`
  · `le_resultado <json>` → por run `braço<TAB>score<TAB>erro<TAB>custo<TAB>trace<TAB>motivo` (custo = `costUsd + judgeCostUsd`; motivo = `nome: explanation` dos graders `passed:false`, unidos por `; `) · `tokens_trace <trace.jsonl>` → inteiro (0 se sem linha com `total_cost_usd`) · `classifica_erro <texto>` → `infra: timeout` | `infra: API` | `reprovado` · `limpa_temp_eval <tracePath>` → apaga o diretório 2 níveis acima só se o nome casa `claude-eval-*`
- **ponto de mudança**: `tests/evals.sh` (laço de casos, tipo plugin-eval), `tests/evals-lib.sh` (funções acima)
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/1 …", "/9 …"
- **asserções** (JSON do stub no formato do spike: `cases[0].arms.with[]` com `score`, `error`, `costUsd`, `judgeCostUsd`, `tracePath`, `graders[]`):
  - score 1, error null, custo 0.4123, trace com `usage` {10, 7632, 8239, 600} → `PASSOU · porta · com 1/1 · US$ 0.4123 · tokens 16481`; total `total: 1 caso(s) · 1 passou · 0 reprovou · 0 erro de infra · 0 não rodado · US$ 0.4123 · tokens 16481`; exit 0
  - score 0.5, grader `categoria` `passed:false` explanation `no match` → `REPROVOU · porta · com 0/1 · US$ 0.4123 · tokens 16481 · motivo: categoria: no match`; exit 1
  - error `timed out after 600s`, score 1 → `ERRO INFRA · porta · causa: timeout (timed out after 600s) · US$ 0.4123 · tokens 16481`; exit 3
  - error `API Error: 529 overloaded` → `causa: API (API Error: 529 overloaded)`
  - error `reached max turns (40)` → `REPROVOU · … · motivo: run: reached max turns (40)` (não é infra)
  - stub sai 2 com `partial:true, partialReason:"auth_failed"` → `causa: sem autenticação`; exit 3
  - stub sai 1 sem JSON, stderr `No eval cases found` → `causa: plugin eval saiu 1: No eval cases found`; exit 3
  - `stub.log` contém a linha de invocação exata acima com `--max-cost-usd 10.0000`
  - após o run, `$SP/claude-eval-x1/` (pai de `out/trace.jsonl`) não existe; trace sob `$SP/outro/out/` → diretório mantido
  - dois casos: total soma custo e tokens dos dois
- **ler**: `tests/evals.sh` (Tarefa 1), doc plugin-evals seções "JSON result" e "Command options" (salva no plan; reconsultar com `claude plugin eval --help`)
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha nos casos `evals-comportamento/1`
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals.sh tests/evals-lib.sh tests/test-evals.sh && git commit -m "feat(evals-comportamento/1,9): caso plugin-eval no modo rapido"`

## Tarefa 3: Teto de custo da rodada

- **depende-de**: [2]
- **requisito**: `evals-comportamento/8` — QUANDO o custo acumulado da rodada passa o teto (padrão US$ 10, configurável) O SISTEMA DEVE parar antes do próximo run, marcar os casos restantes como `não rodado: teto` e sair com código diferente do de reprovação
- **decisões relevantes**: teto do humano US$ 10; dentro de uma invocação o próprio `--max-cost-usd` do host para antes do próximo run (exit 2, `partialReason: cost_ceiling`)
- **interfaces**: `restante = teto − gasto` passado como `--max-cost-usd %.4f` · `gasto >= teto` antes de um caso → caso não é invocado
- **ponto de mudança**: `tests/evals.sh` (laço de casos)
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/8 …"
- **asserções**:
  - `--teto 1`, caso 1 custa 1.2 → casos seguintes `NÃO RODADO · <caso> · não rodado: teto`, ausentes do `stub.log`; exit 2
  - teto 10, caso 1 custa 0.4123 → 2ª invocação com `--max-cost-usd 9.5877`
  - stub sai 2 com `partialReason:"cost_ceiling"` e `with[]` vazio → `NÃO RODADO · porta · não rodado: teto`, casos seguintes idem; exit 2
  - teto atingido + um REPROVOU antes → exit 2; teto + um ERRO INFRA → exit 3
  - total conta `não rodado` e mantém o custo já gasto
- **ler**: `tests/evals.sh` (laço da Tarefa 2)
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em `evals-comportamento/8`
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals.sh tests/evals-lib.sh tests/test-evals.sh && git commit -m "feat(evals-comportamento/8): teto de custo da rodada"`

## Tarefa 4: Modo completo — 3 com, 3 sem, taxa e diferença

- **depende-de**: [2]
- **requisito**: `evals-comportamento/2` — QUANDO o humano roda em modo completo O SISTEMA DEVE rodar cada caso 3 vezes com o plugin e 3 sem, aprovar o caso só se as 3 com o plugin passarem e mostrar a taxa sem o plugin e a diferença
- **decisões relevantes**: comparação sem plugin só no completo; passa só com 3/3; erro de infra em qualquer braço → caso ERRO INFRA
- **interfaces**: invocação troca `--runs 1 --ablation none` por `--runs 3 --ablation with-without`; runs do braço sem em `cases[0].arms.without[]`
- **ponto de mudança**: `tests/evals.sh` (parse de `--completo`, agregação por braço)
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/2 …"
- **asserções** (cada run do stub: custo 0.1, trace com usage {1,2,3,4}):
  - com [1,1,1], sem [1,0,0] → `PASSOU · porta · com 3/3 · sem 1/3 · Δ +67 pp · US$ 0.6000 · tokens 60`
  - com [1,1,0] (run 3 com grader `categoria` `passed:false`, explanation `no match`), sem [0,0,0] → `REPROVOU · porta · com 2/3 · sem 0/3 · Δ +67 pp · US$ 0.6000 · tokens 60 · motivo: categoria: no match`
  - com [1,1,1], sem [1,1,1] → `PASSOU · … · Δ +0 pp`
  - com [1,1,1], sem [1, error `timed out after 600s`, 0] → `ERRO INFRA · porta · causa: timeout (timed out after 600s) · …`
  - cabeçalho `evals: modo completo · modelo sonnet · teto US$ 10.00`
- **ler**: `tests/evals.sh`, `tests/evals-lib.sh` (`le_resultado`)
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em `evals-comportamento/2`
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals.sh tests/evals-lib.sh tests/test-evals.sh && git commit -m "feat(evals-comportamento/2): modo completo com e sem plugin"`

## Tarefa 5: Isolamento do caso plugin-eval e do repo

- **depende-de**: [2]
- **requisito**: `evals-comportamento/7` — QUANDO qualquer caso roda O SISTEMA DEVE executá-lo numa fixture temporária fora do repo, sem a configuração pessoal do usuário (CLAUDE.md global, outros plugins), e deixar o repo do plugin com o `git status` idêntico ao de antes; se o isolamento não puder ser garantido, DEVE recusar o caso com o motivo
- **decisões relevantes**: o host já dá home/config/workspace temporários; o orquestrador CONFERE: plugins do suite, plugins da sessão no `init` do trace (ignorando `source` terminado em `@builtin`), `git status --porcelain` antes/depois, `--output-dir` fora do repo
- **interfaces**: `plugins_sessao <trace>` → nomes não-builtin do evento `system/init`, separados por vírgula · `confere_git <antes> <depois>` → 0/1 + 1ª linha divergente
- **ponto de mudança**: `tests/evals.sh` (antes do 1º caso e no fim), `tests/evals-lib.sh`
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/7 …"
- **asserções**:
  - `suite.plugins` = [`audora-commander`, `outro`] → `RECUSADO · porta · isolamento: plugins carregados audora-commander,outro`; exit 3
  - trace do braço com, `init.plugins` com `outro@inline` → `RECUSADO · porta · isolamento: plugins na sessão audora-commander,outro`
  - braço sem com `audora-commander` no init → `RECUSADO · … · isolamento: plugins na sessão audora-commander`
  - `init.plugins` = audora-commander + `agents-md@builtin` + `telemetry@builtin` → aceito
  - stub cria `$RZ/sujeira.txt` → última linha antes do total `ISOLAMENTO VIOLADO · git status mudou: ?? sujeira.txt`; exit 3
  - `<tmp>` de `--json`/`--output-dir` não fica sob `$RZ`
- **ler**: `tests/evals.sh`, trace do spike (formato `system/init` com `plugins[].name`/`source`)
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em `evals-comportamento/7`
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals.sh tests/evals-lib.sh tests/test-evals.sh && git commit -m "feat(evals-comportamento/7): isolamento conferido no caso plugin-eval"`

## Tarefa 6: Grader do tdd sobre stream-json

- **depende-de**: [1]
- **requisito**: `evals-comportamento/6` — QUANDO o caso `tdd` roda (execute de demanda LIGHT numa fixture com suíte) O SISTEMA DEVE reprovar se o transcript não mostrar, nesta ordem: teste novo escrito → teste rodado falhando → código editado → teste rodado passando
- **decisões relevantes**: teste novo = `Write`/`Edit` com `file_path` casando `(^|[\\/])tests[\\/]`; teste rodado = `Bash` com `command` contendo `tests/` ou `tests\`; falhando = `tool_result.is_error` verdadeiro; código = `Write`/`Edit` fora de `tests/` e não terminado em `.md`; código ANTES do 1º teste falhando (depois do teste novo) reprova
- **interfaces**: `grader_tdd <stream.jsonl>` → stdout `passou` ou `reprovou: <motivo>`
- **ponto de mudança**: `tests/evals-lib.sh`
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/6 …", traces sintéticos montados por helper `ev_tool <id> <nome> <input-json>` / `ev_result <id> <true|false>` no formato do spike (`{"type":"assistant","message":{"content":[{"type":"tool_use","id":…,"name":…,"input":…}]}}` e `{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":…,"is_error":…}]}}`)
- **asserções** (W=Write, E=Edit, B✗/B✓=Bash `bash tests/run.sh` falhando/passando):

```
W tests/test-dobro.sh, B✗, E lib.sh, B✓                 → passou
E lib.sh, W tests/test-dobro.sh, B✓                     → reprovou: código editado antes do teste falhando
W tests/test-dobro.sh, E lib.sh, B✗, B✓                 → reprovou: código editado antes do teste falhando
W tests/test-dobro.sh, B✗, E lib.sh                     → reprovou: faltou teste passando depois do código
(nenhum evento)                                          → reprovou: faltou teste novo
W tests/test-dobro.sh, B✗                               → reprovou: faltou código editado depois do teste falhando
W tests/test-dobro.sh, B✓, E lib.sh, B✓                 → reprovou: faltou teste falhando depois do teste novo
E docs/audora/memory/dobro.md, E MEMORY.md, + 1ª linha  → passou
B✗ antes de tudo, + 1ª linha                            → passou
file_path C:\x\cwd\tests\test-dobro.sh (Windows), + 1ª  → passou
```

- **ler**: `tests/evals-lib.sh`, `hooks/memory-guard:9-14`
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em `evals-comportamento/6`
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals-lib.sh tests/test-evals.sh && git commit -m "feat(evals-comportamento/6): grader do tdd por ordem no transcript"`

## Tarefa 7: Fixtures — projeto-base e caso tdd

- **depende-de**: [1]
- **requisito**: `evals-comportamento/7` (parte: fixture temporária fora do repo) · `evals-comportamento/6` (parte: "demanda LIGHT numa fixture com suíte")
- **decisões relevantes**: fixture gerada por heredoc em script (nenhum `MEMORY.md` real dentro do repo — hooks e cleanup não o enxergam); Constituição da fixture com `gate: recusado` (porta não desvia oferecendo gate); scripts compartilhados via `. "$(dirname "${BASH_SOURCE[0]}")/../_lib/projeto-base.sh"` (spike confirmou)
- **interfaces**: `tests/evals/_lib/projeto-base.sh` — rodado com cwd = workspace vazio, cria o projeto e NÃO commita · cada `fixture.sh` de caso faz `source` dele, acrescenta o específico e termina com `git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm fixture` · `tests/evals/tdd/harness.md` — corpo = prompt, sem frontmatter
- **ponto de mudança**: `tests/evals/_lib/projeto-base.sh`, `tests/evals/tdd/fixture.sh`, `tests/evals/tdd/harness.md` (novos)
- **teste**: `tests/test-evals.sh` — casos "fixture base …", "fixture tdd …"
- **asserções** — conteúdo gerado no workspace (caminhos relativos à fixture):

```
MEMORY.md         linha 1 "memory-schema: 1"; seções Propósito, Constituição, Aprendizados, Índice de nós
                  Constituição: stack bash; como-rodar `bash tests/run.sh`; gate: recusado
docs/audora/aprendizados.md   = templates/aprendizados-template.md
lib.sh            função soma
tests/run.sh      roda tests/test-*.sh, exit 1 se algum falha
tests/test-soma.sh
base: bash tests/run.sh → exit 0; hooks/memory-validate sobre MEMORY.md → exit 0
tdd: docs/audora/memory/dobro.md estado in-progress, critérios
     dobro/1 QUANDO `dobro 4` é chamado O SISTEMA DEVE imprimir 8
     dobro/2 QUANDO o argumento não é numérico O SISTEMA DEVE imprimir "erro: não numérico" no stderr e sair 1
     linha "- dobro | in-progress | ..." no índice; memory-validate → 0
     grep -c dobro lib.sh → 0; bash tests/run.sh → 0; git log --oneline | wc -l → 1
harness.md        "execute de dobro"
```

- **ler**: `templates/MEMORY-template.md:1-63`, `templates/no-template.md:1-72`, `templates/aprendizados-template.md:1-10`, `hooks/memory-validate:1-141`, `tests/lib.sh:16-20` (`run_hook`)
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em "fixture base" (script ausente)
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals/_lib/projeto-base.sh tests/evals/tdd/fixture.sh tests/evals/tdd/harness.md tests/test-evals.sh && git commit -m "feat(evals-comportamento/6,7): fixtures base e tdd"`

## Tarefa 8: Harness próprio do caso tdd

- **depende-de**: [3, 5, 6, 7]
- **requisito**: `evals-comportamento/7` (parte: harness sem configuração pessoal; recusa) · `evals-comportamento/9` (parte: harness) · `evals-comportamento/2` (parte: harness com e sem plugin)
- **decisões relevantes**: workspace `mktemp -d` com `cwd/ home/ config/ tmp/`; `env -i` só com `PATH`, `SYSTEMROOT`, `COMSPEC`, `HOME=<ws>/home`, `USERPROFILE=<ws>/home` (forma Windows via `cygpath -w` se existir), `TEMP=TMP=<ws>/tmp`, `CLAUDE_CONFIG_DIR=<ws>/config` e o token; teto checado antes de cada run e `--max-budget-usd <restante>` por run; `timeout -k 5 <timeout-run>` com o mesmo fallback do `tests/run.sh`
- **interfaces**: invocação, cwd `<ws>/cwd`:
  `<claude> -p "<corpo de harness.md>" [--plugin-dir <raiz>] --model <m> --output-format stream-json --verbose --max-budget-usd <restante> --permission-mode dontAsk --strict-mcp-config --no-session-persistence --allowedTools Read Glob Grep Skill TodoWrite "Edit(./**)" "Write(./**)" "Bash(bash *)" "Bash(git *)"`
  · `roda_harness <caso> <braço> <restante>` → `status<TAB>custo<TAB>tokens<TAB>motivo`, status ∈ `passou|reprovou|infra|recusado|teto` · veredito = `grader_tdd` (Tarefa 6)
- **ponto de mudança**: `tests/evals.sh` (tipo harness no laço), `tests/evals-lib.sh`
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/7 harness …", "/9 harness …", "/2 harness …"
- **asserções** (stub escreve stream-json; `env` e `pwd` que o stub viu em `$SP/stub.env`):
  - sem `CLAUDE_CODE_OAUTH_TOKEN` e sem `ANTHROPIC_API_KEY` (ou com `__coloque_o_valor__`) → `RECUSADO · tdd · isolamento: sem CLAUDE_CODE_OAUTH_TOKEN nem ANTHROPIC_API_KEY (rode claude setup-token)`; nenhuma chamada `-p` no log; exit 3
  - com token: `stub.env` sem `EVALS_CANARIO` (exportado pelo teste), `HOME` ≠ HOME real, `CLAUDE_CONFIG_DIR` sob o workspace, `pwd` fora de `$RZ`; braço com tem `--plugin-dir <raiz>`, braço sem não tem
  - stream com o trace da 1ª linha da Tarefa 6 + `result` (`total_cost_usd` 0.3, usage {1,2,3,4}) → `PASSOU · tdd · com 1/1 · US$ 0.3000 · tokens 10`
  - `result.is_error` com `Not logged in · Please run /login` → `ERRO INFRA · tdd · causa: sem autenticação · …`
  - sem evento `result`, stub sai 1 → `causa: sem evento result (exit 1)`
  - `result.api_error_status` 529 → `causa: API (529)`
  - `result.subtype` `error_max_budget_usd` → `NÃO RODADO · tdd · não rodado: teto`; exit 2
  - `init.plugins` com `outro@inline` → `RECUSADO · tdd · isolamento: plugins na sessão audora-commander,outro`
  - stub dorme 5 s com `--timeout-run 1` → `causa: timeout (1 s)`
  - `--completo` → 6 chamadas `-p` (3 com `--plugin-dir`, 3 sem) e a linha `com x/3 · sem y/3 · Δ …`
  - workspace apagado após cada run
- **ler**: `tests/evals.sh`, `tests/evals-lib.sh`, `tests/run.sh:24-30`, `tests/evals/tdd/fixture.sh`
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha nos casos "harness"
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals.sh tests/evals-lib.sh tests/test-evals.sh && git commit -m "feat(evals-comportamento/2,7,9): harness proprio do caso tdd"`

## Tarefa 9: Emulador offline dos graders nativos

- **depende-de**: [1]
- **requisito**: `evals-comportamento/3`, `/4`, `/5` (parte: graders provados sem gastar — base das Tarefas 10–12)
- **decisões relevantes**: graders só nos 3 tipos usados (`regex` com `target: trace` ou `{ source: file, path: X }`, `flags`, `match: not_contains`; `tool_used` com `tool`, `input_match`, `min`, `max`; `tool_order`), frontmatter de 1 linha por chave; regex JS ≈ perl para o subconjunto usado (lookahead, `[\s\S]`, flags `i`/`m`); emulador NÃO é o veredito — o host é; a Tarefa 15 confirma com runs reais
- **interfaces**: `emula_grader <grader.md> <trace.jsonl> <workspace>` → `passou` | `reprovou` | `erro: <motivo>` (tipo/chave desconhecida = erro) · `tool_used` aplica `input_match` ao `input` re-serializado na ordem original do trace
- **ponto de mudança**: `tests/evals-lib.sh`
- **teste**: `tests/test-evals.sh` — casos "emulador …"
- **asserções**:
  - 1º passo: capturar 1 trace real curto (`claude plugin eval` do spike, `--model haiku --runs 1 --ablation none --keep-temp`, ~US$ 0.03) e conferir que `tool_use` sai como `"name":"<T>","input":{…}`; os helpers `ev_tool`/`ev_result` da Tarefa 6 seguem esse formato (divergiu → ajustar helpers antes de seguir)
  - grader `regex` `pattern: banana`, `target: { source: file, path: saida.txt }` + workspace com `saida.txt`=`banana` → `passou`; sem o arquivo → `reprovou`
  - `match: not_contains` inverte; `flags: m` faz `^` casar no meio do arquivo
  - `tool_used tool: Write, input_match: 'x\.md', min: 0, max: 0` + trace com Write em `a/x.md` → `reprovou`; sem Write → `passou`
  - `tool_order before: { tool: Skill, input_match: 'a' }, after: { tool: Skill, input_match: 'b' }` → `[a,b]` passou, `[b,a]` reprovou, `[a]` reprovou
  - `type: llm` → `erro: tipo não emulado: llm`
- **ler**: `tests/evals-lib.sh`, doc plugin-evals "Grader types" e "What a grader can look at"
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em "emulador"
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals-lib.sh tests/test-evals.sh && git commit -m "test(evals-comportamento): emulador offline dos graders"`

## Tarefa 10: Caso `porta`

- **depende-de**: [7, 9]
- **requisito**: `evals-comportamento/3` — QUANDO o caso `porta` roda (pedido de mudança num projeto com MEMORY) O SISTEMA DEVE reprovar se a skill de entrada não for a primeira skill invocada, se a categoria anunciada não for a esperada pelo caso ou se a fase seguinte não for a da tabela de roteamento
- **decisões relevantes**: categoria esperada MEDIUM (lógica nova em vários arquivos, nenhuma pergunta de risco SIM); fase seguinte = `scope`; `skill memory` é ferramenta, não fase (pode vir entre as duas); todo grader `arm: both`
- **interfaces**: `tests/evals/porta/prompt.md` frontmatter `max_turns: 40`, `timeout_seconds: 600`, `tags: [comportamento]`, `allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, AskUserQuestion, TodoWrite]`; `case.yaml` `schema_version: "1.1"`, `name: porta`, `context.scaffold_script: fixture.sh`; graders `primeira-skill`, `categoria`, `fase-seguinte` (regex sobre `trace`)
- **ponto de mudança**: `tests/evals/porta/{prompt.md,case.yaml,fixture.sh,graders/*.md}` (novos)
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/3 …" via `emula_grader`
- **asserções**:

```
prompt: "Quero acrescentar à lib as funções media e mediana sobre os números passados
         como argumento, com erro claro para lista vazia ou valor não numérico, e um
         comando bin/estat que expõe as duas. Com testes."
primeira-skill: Skill[audora-commander:audora-commander], Skill[memory], Skill[scope] → passou
                Skill[memory], Skill[audora-commander:audora-commander]            → reprovou
                Skill[audora-commander] (sem prefixo) primeiro                     → passou
                nenhum Skill                                                       → reprovou
categoria:      texto "Demanda classificada como **MEDIUM** porque"                → passou
                "classificada como MEDIUM" (sem negrito)                           → passou
                "classificada como **LIGHT**" / "**HIGH**"                         → reprovou
fase-seguinte:  porta, memory, scope        → passou
                porta, execute              → reprovou
                porta, plan, scope          → reprovou
                só porta                    → reprovou
fixture.sh: source da base + commit; memory-validate → 0
```

- **ler**: `skills/audora-commander/SKILL.md:28-56`, `templates/bloco-fechamento-template.md:101-124`, `tests/evals/_lib/projeto-base.sh`
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em `evals-comportamento/3`
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals/porta tests/test-evals.sh && git commit -m "feat(evals-comportamento/3): caso porta"`

## Tarefa 11: Caso `escopo-antes`

- **depende-de**: [7, 9]
- **requisito**: `evals-comportamento/4` — QUANDO o caso `escopo-antes` roda (pedido MEDIUM ou HIGH) O SISTEMA DEVE reprovar se algum arquivo fora de `MEMORY.md` e `docs/audora/` for criado ou editado antes de o nó ter critérios
- **decisões relevantes**: qualquer escrita fora no run reprova (ver Decisões da IA); `Write` e `Edit` têm grader cada; `arm: both`; mesmo frontmatter/`case.yaml` da Tarefa 10 (`name: escopo-antes`)
- **interfaces**: graders `sem-write-fora`, `sem-edit-fora` — `tool_used`, `min: 0`, `max: 0`, `input_match` = `file_path` que NÃO contém `MEMORY.md` nem `docs` + separador (`\\` JSON-escapado ou `/`) + `audora` + separador
- **ponto de mudança**: `tests/evals/escopo-antes/{prompt.md,case.yaml,fixture.sh,graders/*.md}` (novos)
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/4 …"
- **asserções**:

```
prompt: "Implemente o comando bin/conversor que converte temperatura entre Celsius e
         Fahrenheit (conversor c2f 100 imprime 212), com validação de entrada e testes."
Write C:\Users\x\home\cwd\bin\conversor                      → reprovou
Write C:\Users\x\home\cwd\docs\audora\memory\conversor.md    → passou
Edit  C:\Users\x\home\cwd\MEMORY.md                          → passou
Edit  /tmp/ws/cwd/lib.sh                                     → reprovou
Write /tmp/ws/cwd/docs/audora/aprendizados.md                → passou
Write /tmp/ws/cwd/docs/outro.md                              → reprovou
nenhum Write/Edit                                            → passou
```

- **ler**: `skills/scope/SKILL.md:1-64`, `tests/evals/porta/case.yaml`
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em `evals-comportamento/4`
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals/escopo-antes tests/test-evals.sh && git commit -m "feat(evals-comportamento/4): caso escopo-antes"`

## Tarefa 12: Caso `memoria`

- **depende-de**: [7, 9]
- **requisito**: `evals-comportamento/5` — QUANDO o caso `memoria` roda O SISTEMA DEVE reprovar se o nó da demanda não tiver ao menos 1 critério `<id>/<n>` em EARS (`QUANDO … O SISTEMA DEVE …`) ou se um aprendizado for escrito no `MEMORY.md` em vez de `docs/audora/aprendizados.md`
- **decisões relevantes**: demanda LIGHT (porta registra o nó já com critério EARS, `skills/audora-commander/SKILL.md:42-46`); o prompt fixa o id `dobro-negativo` (o caminho do nó precisa ser conhecido pelo grader); grader extra `aprendizado-registrado` (Decisões da IA); fixture acrescenta à base uma `dobro` que recusa negativo
- **interfaces**: graders `no-com-ears` (regex no arquivo do nó, padrão `dobro-negativo/\d+[\s\S]{0,20}?QUANDO[\s\S]{1,400}?O\s+SISTEMA\s+DEVE`), `aprendizado-fora-do-memory` (regex em `MEMORY.md`, `^- \d{4}-\d{2}-\d{2} \| `, `flags: m`, `match: not_contains`), `aprendizado-registrado` (regex em `docs/audora/aprendizados.md`, `^- \d{4}-\d{2}-\d{2} \| [^\n]*LC_ALL=C`, `flags: m`)
- **ponto de mudança**: `tests/evals/memoria/{prompt.md,case.yaml,fixture.sh,graders/*.md}` (novos)
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/5 …"
- **asserções** (workspace sintético):

```
prompt: "Demanda dobro-negativo: a função dobro da lib deve aceitar números negativos
         (hoje recusa). E fica a dica para sempre neste projeto: a suíte só passa com
         LC_ALL=C bash tests/run.sh."
docs/audora/memory/dobro-negativo.md com
  "- **dobro-negativo/1** — QUANDO `dobro -3` é chamado O\n  SISTEMA DEVE imprimir -6"  → no-com-ears passou
  "- dobro-negativo/1 — aceitar negativos"                                            → reprovou
  arquivo ausente                                                                      → reprovou
MEMORY.md com "- 2026-10-09 | execute | LC_ALL=C ..."   → aprendizado-fora-do-memory reprovou
MEMORY.md sem linha datada                               → passou
aprendizados.md com "- 2026-10-09 | execute | suíte só passa com LC_ALL=C" → aprendizado-registrado passou
aprendizados.md só com o cabeçalho do template           → reprovou
fixture: lib.sh com dobro que recusa negativo; memory-validate → 0; bash tests/run.sh → 0
```

- **ler**: `skills/memory/SKILL.md:105-125`, `skills/audora-commander/SKILL.md:40-46`, `tests/evals/_lib/projeto-base.sh`
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em `evals-comportamento/5`
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals/memoria tests/test-evals.sh && git commit -m "feat(evals-comportamento/5): caso memoria"`

## Tarefa 13: Mutação de regra

- **depende-de**: [2, 8]
- **requisito**: `evals-comportamento/10` — QUANDO o humano pede a mutação de uma regra coberta por um caso O SISTEMA DEVE rodar esse caso com uma cópia da skill sem a regra, reportar a taxa com e sem a regra e marcar `sem efeito` quando a taxa não cair — sem alterar a skill do repo e sem cortar nada
- **decisões relevantes**: mutação gera relatório, humano corta; registro em `tests/evals/mutacoes.tsv` (`regra<TAB>caso<TAB>arquivo<TAB>início<TAB>fim`, `#` = comentário); remove da 1ª linha que contém `início` até a 1ª linha seguinte (inclusive) que contém `fim`; os dois braços com o plugin (`--ablation none`, `--runs <n>`): original = `<raiz>`, mutado = cópia temporária de `git ls-files -co --exclude-standard`
- **interfaces**: `copia_plugin <raiz> <destino>` · `aplica_mutacao <arquivo> <início> <fim>` → exit 0 e imprime `linhas A-B`, ou exit 1 + stderr · saída:

```
mutação <regra> · caso <caso> · <arquivo> (linhas A-B)
com a regra 3/3 · sem a regra 1/3 · efeito -67 pp
```

  ou `… · sem efeito` quando sem ≥ com; exit 0 (relatório completo), 2 (teto), 3 (infra)
- **ponto de mudança**: `tests/evals.sh` (`--mutar`, `--runs`), `tests/evals-lib.sh`, `tests/evals/mutacoes.tsv` (novo) com as linhas:

```
porta-anuncio             porta         skills/audora-commander/SKILL.md  4. **Anunciar**:                              Correção do humano vale na hora.
porta-criterio-light      memoria       skills/audora-commander/SKILL.md  5. **Registrar o nó**                         esses endereços.
scope-lei-de-ferro        escopo-antes  skills/scope/SKILL.md             LEI DE FERRO: NENHUM CÓDIGO ANTES DO ESCOPO FECHADO EM ARTEFATO ESCRITO  (mesma)
memory-aprendizado-local  memoria       skills/memory/SKILL.md            2. Registrar NA HORA em que foi descoberto    (grep-ável).
execute-lei-de-ferro      tdd           skills/execute/SKILL.md           LEI DE FERRO: NENHUM CÓDIGO DE PRODUÇÃO SEM TESTE FALHANDO ANTES  (mesma)
execute-apague            tdd           skills/execute/SKILL.md           Escreveu código antes do teste?               Violar a letra da regra é violar a regra.
```

  (separador real é TAB; "(mesma)" = fim igual ao início)
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/10 …"
- **asserções**:
  - `--mutar nada` → exit 4, `evals: regra desconhecida: nada`
  - início ausente → exit 4, `evals: mutação inválida: início não encontrado em <arquivo>`; início em 2 linhas → `… início ambíguo (2 ocorrências) em <arquivo>`; fim ausente → `… fim não encontrado depois do início em <arquivo>`
  - válida, stub com [1] na raiz e [0] na cópia, `--runs 1` → 2 invocações (alvo `<raiz>` e alvo da cópia), ambas `--runs 1 --ablation none`; saída `com a regra 1/1 · sem a regra 0/1 · efeito -100 pp`; exit 0
  - [1]/[1] → `· sem efeito`; [0]/[1] → `· sem efeito`
  - sem `--runs` → `--runs 3` no log
  - sha1 do arquivo da regra em `<raiz>` igual antes/depois; `git status --porcelain` de `<raiz>` igual; cópia apagada no fim
  - toda linha do `mutacoes.tsv` real: âncoras presentes e início único no arquivo do repo; caso existe em `tests/evals/`
  - caso harness (`execute-lei-de-ferro`) → chamadas `-p` com `--plugin-dir <raiz>` e `--plugin-dir <cópia>`
- **ler**: `tests/evals.sh`, `tests/evals-lib.sh`, `skills/audora-commander/SKILL.md:40-46`, `skills/scope/SKILL.md:9`, `skills/memory/SKILL.md:113-116`, `skills/execute/SKILL.md:9-15`
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em `evals-comportamento/10`
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals.sh tests/evals-lib.sh tests/evals/mutacoes.tsv tests/test-evals.sh && git commit -m "feat(evals-comportamento/10): mutacao de regra"`

## Tarefa 14: Fora da suíte + docs + envs

- **depende-de**: [1]
- **requisito**: `evals-comportamento/12` — QUANDO `bash tests/run.sh` roda O SISTEMA DEVE terminar sem invocar `claude` nem nenhum caso de eval
- **decisões relevantes**: rodar evals é manual (fora do `run.sh` por custo); regra global de env: `.env` local com placeholder + `.env.example` + docs
- **interfaces**: `tests/evals/README.md` (PT: como rodar, modos, flags, saída, exits 0–4, `claude setup-token`, custo, tabela `## Calibração` com cabeçalho `| caso | condição ruim | data | resultado |`) · `.gitignore` += `.env`, `tests/evals/results/` · `.env.example` e `.env` com `CLAUDE_CODE_OAUTH_TOKEN=__coloque_o_valor__` · Constituição `como-rodar` += "evals de comportamento: `bash tests/evals.sh` (manual, custa; fora do `run.sh`)"
- **ponto de mudança**: `tests/test-evals.sh`, `tests/evals/README.md`, `.gitignore`, `.env.example`, `.env`, `MEMORY.md` (bullet `como-rodar`)
- **teste**: `tests/test-evals.sh` — casos "evals-comportamento/12 …"
- **asserções**:
  - nenhum de `tests/evals.sh`, `tests/evals-lib.sh`, `tests/evals/**` casa o glob `tests/test-*.sh`
  - `grep -l 'evals\.sh' tests/test-*.sh` → só `tests/test-evals.sh`; nele `grep -c 'tests/evals.sh'` → `1` (só dentro de `roda_evals`, que sempre passa `--claude "$STUB"`)
  - `tests/test-evals.sh` roda com `PATH` prefixado por um dir com shims `claude` e `claude.exe` que criam `$SP/chamou-claude`; no fim do arquivo `assert_no_file "$SP/chamou-claude"`
  - README contém `PASSOU`, `REPROVOU`, `ERRO INFRA`, `RECUSADO`, `NÃO RODADO`, `claude setup-token`, `--completo`, `--mutar` e a tabela de exits
  - `.gitignore` tem as linhas `.env` e `tests/evals/results/`; `.env.example` tem `CLAUDE_CODE_OAUTH_TOKEN=__coloque_o_valor__`; `git check-ignore -q .env` → 0
  - `run_hook memory-validate "$ROOT/MEMORY.md"` → 0 após editar a Constituição (o `test-dogfood.sh` cobre)
- **ler**: `tests/run.sh:8-11`, `.gitignore:1-3`, `MEMORY.md:18-42`, `tests/test-dogfood.sh:1-27`
- **done quando**: asserções passam; suíte verde

- [x] **red** — `bash tests/test-evals.sh` falha em `evals-comportamento/12` (README/.gitignore ausentes)
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/test-evals.sh tests/evals/README.md .gitignore .env.example MEMORY.md && git commit -m "docs(evals-comportamento/12): evals fora da suite, README e envs"` (`.env` fica ignorado, não entra)

## Tarefa 15: Rodadas reais — verde com o plugin e calibração ruim

- **depende-de**: [4, 8, 10, 11, 12, 13, 14]
- **requisito**: `evals-comportamento/13` — QUANDO a demanda é entregue O SISTEMA DEVE ter, para cada caso, uma rodada registrada em que ele REPROVA numa condição conhecida como ruim (regra removida ou plugin desligado) — caso que nunca reprova não prova nada
- **decisões relevantes**: custa de verdade (teto US$ 10 por rodada); `claude` em `~/.local/bin/claude.exe` (aprendizado 2026-09-29) → passar `--claude ~/.local/bin/claude.exe` se fora do PATH; reprovação inesperada COM o plugin é achado de produto → skill debug, não ajuste de grader para passar
- **interfaces**: tabela `## Calibração` do `tests/evals/README.md`, 1 linha por caso: `| <caso> | <braço sem plugin --completo | mutação <regra>> | AAAA-MM-DD | REPROVOU x/3 |`
- **ponto de mudança**: `tests/evals/README.md` (linhas da tabela), `tests/test-evals.sh` (guarda)
- **teste**: `tests/test-evals.sh` — caso "evals-comportamento/13 todo caso tem calibração que reprova": para cada caso de `lista_casos "$ROOT"`, a tabela tem linha começando `| <caso> |` contendo `REPROVOU`
- **asserções**: guarda reprova com caso sem linha; passa com as 4 linhas
- **ler**: `tests/evals/README.md`, `docs/audora/aprendizados.md` (grep `claude`)
- **done quando**: as 4 linhas registradas a partir de saída real; rodada rápida real com as 4 linhas `PASSOU` (ou divergência levada à skill debug); `git status` igual antes/depois de cada rodada

- [x] **pré-requisito humano** — `CLAUDE_CODE_OAUTH_TOKEN` no `.env` (sem ele: tdd RECUSADO → parar e pedir)
- [x] **red** — guarda adicionada; `bash tests/test-evals.sh` falha em `evals-comportamento/13`
- [x] **real verde** — `bash tests/evals.sh --teto 10; echo $?` → `0` e 4 linhas `PASSOU` (Tarefa 9 avisou formato divergente → replanejar a etapa do grader) **Resultado 2026-10-10: NÃO deu 4 PASSOU** — escopo-antes 3/3 e memoria 3/3; porta 0/3 e tdd 2/3 levados à skill debug e viraram achados de produto (`porta-anuncio`, `retomada-execute`), após corrigir 3 defeitos do próprio harness/grader.
- [x] **real ruim** — por caso, até reprovar: `bash tests/evals.sh --completo --caso <caso> --teto 10` (braço sem) ou `bash tests/evals.sh --mutar <regra>`; registrar a linha com a taxa real
- [x] **green** — `bash tests/test-evals.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`
- [x] **commit** — `git add tests/evals/README.md tests/test-evals.sh && git commit -m "test(evals-comportamento/13): calibracao real de cada caso"`
