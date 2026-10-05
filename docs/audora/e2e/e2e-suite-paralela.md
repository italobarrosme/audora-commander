# E2E — suite-paralela (2026-10-04)

Infra: projeto não-web, sem docker (Constituição). O "produto rodando" é o
runner `tests/run.sh` da `main` em `997c826`, com o `lib.sh` e os arquivos de
teste reais, de três jeitos: (1) CLI numa worktree da `main` com arquivos
plantados (cenários de erro); (2) CLI no repo real (tempo, concorrência,
fluxo); (3) sessão real do Claude Code (`claude.exe -p`, CLI 2.1.284,
Constituição `ferramenta-e2e`) rodando `bash hooks/gate suite-paralela` numa
worktree com um teste vermelho plantado, como a execute faz. O `run.sh` não
entra no cache do plugin: é ferramenta do repo, por isso não houve reinstalação.

Caminhos de fixture só aparecem dentro de bloco de código: este relatório mora
em docs/audora e é varrido pela cleanup.

## Receita (regressão)

1. **Cenários de erro** — worktree `--detach` da `main`; ficam só 3 arquivos
   reais (carga, session-start, templates) e entram os plantados:

```bash
# plantados em tests/ da worktree
test-zz-falha.sh  : source lib.sh; echo saida-normal-antes; ok; ko "plantado pelo e2e"; report
test-zz-crash.sh  : echo antes-do-crash; comando-que-nao-existe-e2e
test-zz-trava.sh  : echo vai-travar; (for k in $(seq 300); do touch "$TICK"; sleep 0.2; done) & sleep 600
test-zz-lento.sh  : sleep 12; echo dormiu-12            # só em C3/C3b
# rodadas
C1   SUITE_TIMEOUT=10 bash tests/run.sh > c1.m 2>&1      # depois: rm tick; sleep 2; tick não volta
C1b  SUITE_TIMEOUT=10 bash tests/run.sh 2>/dev/null
C1c  SUITE_JOBS=1 SUITE_TIMEOUT=10 bash tests/run.sh 2>/dev/null   # diff das linhas PASS= com C1b
C2   SUITE_JOBS=abc SUITE_TIMEOUT=-5 bash tests/run.sh
C2b  SUITE_JOBS= SUITE_TIMEOUT=x bash tests/run.sh
C3   SUITE_TIMEOUT=0 (com test-zz-lento.sh)    C3b  SUITE_TIMEOUT=5 (idem)
C4   sem nenhum test-*.sh
```

2. **Repo real** — L = os 2 mais lentos da T5 rodando sozinhos; A = `bash
   tests/run.sh` sem `SUITE_*`; B = `SUITE_JOBS=4`. Cada linha do stdout
   ganha o horário de chegada (`+Ns`). Um amostrador varre `/proc/*/cmdline`
   a cada ~0,5 s e conta os nomes distintos `bash tests/test-*.sh` que batem
   com a lista real de `tests/` (as suítes falsas do `test-suite-paralela.sh`
   ficam de fora).
3. **Sessão** — worktree da `main` + 1 arquivo plantado não commitado:

```bash
# tests/test-zz-plantado.sh
source "$(dirname "$0")/lib.sh"; ok; ko "plantado pelo e2e da suite-paralela"; report
claude.exe -p "Rode o gate deste repositório para a demanda suite-paralela (comando: bash hooks/gate suite-paralela) e me diga: passou ou reprovou, quantos arquivos de teste falharam, qual arquivo e a linha FAIL dele, e quanto tempo a suíte levou. Não altere nenhum arquivo." --permission-mode acceptEdits --allowedTools "Bash Read Grep Glob" --output-format stream-json --verbose
```

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| suite-paralela/1 — sem a variável, arquivos simultâneos, no máximo N = núcleos | A (repo real, `nproc` 22) | amostrador: pico de 15 dos 17 arquivos rodando juntos, ≤ 22 (amostra a cada ~0,5 s + varredura lenta do `/proc`: arquivo curto pode acabar entre duas amostras); suíte em 73 s contra 62 s do mais lento sozinho | passou |
| suite-paralela/2 — `SUITE_JOBS=N` limita; N = 1 é série | B e C1c | B: máximo **4** juntos; C1c (`SUITE_JOBS=1`) mesmo veredito por arquivo que C1b | passou |
| suite-paralela/3 — limite inválido → aviso com nome e valor, default | C2, C2b | `run.sh: SUITE_JOBS inválido ('abc') — usando 22` e `('') — usando 22`; exit 0 | passou |
| suite-paralela/4 — mesmo veredito em paralelo e com limite 1 | A × B; C1b × C1c | `diff` das linhas `PASS=`: A × B vazio (17 arquivos verdes); C1b × C1c vazio (3 arquivos vermelhos) | passou |
| suite-paralela/5 — blocos na ordem do glob, sem intercalar | A, B, C1, sessão | blocos de carga → … → templates (→ plantados) na ordem do glob em todas as rodadas, cada bloco inteiro (bloco A) | passou |
| suite-paralela/6 — bloco sai assim que ele e os anteriores acabam | A com horário | carga em +3 s, docs/dogfood/gate em +12 s, session-start em +24 s; skill-cleanup e os 3 seguintes em +72 s; resumo em +73 s (bloco A) | passou |
| suite-paralela/7 (delta) — stderr no stderr, no bloco, antes do stdout; `2>/dev/null` só tira ele | C1 e C1b | C1: `FAIL: plantado pelo e2e` antes de `saida-normal-antes`; `command not found` antes de `antes-do-crash`. C1b: só essas linhas somem (bloco B) | passou |
| suite-paralela/8 — última linha `run.sh: <n> arquivo(s) de teste com falha (<s> s)` | todas | `(73 s)`, `(10 s)`, `(1 s)`, `(78 s)` na sessão; segundos batem com o relógio medido por fora (C1 `dur=10`, C3 `dur=12`) | passou |
| suite-paralela/9 — falha, crash, comando não encontrado e timeout contam; todos rodam; exit 1 | C1 | `run.sh: 3 arquivo(s) de teste com falha (10 s)`, exit 1; os 3 reais rodaram e passaram | passou |
| suite-paralela/10 — tudo verde → exit 0 | A, B, C2, C3 | `A_exit=0`, `B_exit=0`, `c2_exit=0`, `c3_exit=0` | passou |
| suite-paralela/11 — sem `test-*.sh` → mensagem no stderr, exit 1 | C4 | stderr `run.sh: nenhum arquivo de teste`; stdout 0 bytes; exit 1 | passou |
| suite-paralela/12 — timeout encerra sem sobrar processo, conta falha, linha com arquivo e limite no bloco | C1 (e 1ª rodada acidental com default) | `run.sh: TIMEOUT …trava.sh (10 s)` dentro do bloco, antes de `vai-travar`; neto parado (`tick` não voltou). 1ª rodada sem `SUITE_TIMEOUT` (erro do script do e2e): `TIMEOUT … (300 s)` aos 301 s, neto parado — o default de 300 s confirmado | passou |
| suite-paralela/13 — `SUITE_TIMEOUT=T` usa T s | C1, C3b | C1 terminou em 10 s com a trava de 600 s; C3b: `TIMEOUT …lento.sh (5 s)`, `(5 s)` | passou |
| suite-paralela/14 — `SUITE_TIMEOUT=0` sem limite | C3 | arquivo de 12 s rodou até o fim (`dormiu-12`), exit 0, sem TIMEOUT | passou |
| suite-paralela/15 — timeout inválido → aviso com nome e valor, 300 s | C2, C2b | `run.sh: SUITE_TIMEOUT inválido ('-5') — usando 300` e `('x') — usando 300`; exit 0 | passou |
| suite-paralela/16 — gate mantém o contrato | sessão `claude -p` | sessão rodou `bash hooks/gate suite-paralela` (Bash com timeout 600000), viu `GATE: reprovado — suite falhou: bash tests/run.sh`, exit 1, e relatou arquivo, linha FAIL e 78 s certos (bloco C). Lado verde: gate da validate na árvore limpa | passou |
| suite-paralela/17 — ≤ 1,5× o mais lento sozinho, mesma sessão | L e A | L = 62 s (skill-cleanup; suite-paralela 53 s); A = 73 s → **1,18×** (limite 93 s). B (`SUITE_JOBS=4`) = 81 s e 84 s | passou |

### Evidência crua

A — repo real, default (horário de chegada):

```
+2s carga MEDIUM (bytes): base=47741 full=55661 — tetos 48000 / 56900
+3s test-carga.sh: PASS=16 FAIL=0
+4s test-contexto-por-fase.sh: PASS=34 FAIL=0
+4s test-corte-sem-uso.sh: PASS=38 FAIL=0
+12s test-docs.sh: PASS=170 FAIL=0
+12s test-dogfood.sh: PASS=27 FAIL=0
+12s test-gate.sh: PASS=52 FAIL=0
+17s test-leitura-por-secao.sh: PASS=81 FAIL=0
+17s test-memory-guard.sh: PASS=8 FAIL=0
+24s test-memory-validate.sh: PASS=43 FAIL=0
+24s test-parada-revisao.sh: PASS=61 FAIL=0
+24s test-plano-mapa.sh: PASS=50 FAIL=0
+24s test-prd-foto.sh: PASS=79 FAIL=0
+24s test-session-start.sh: PASS=9 FAIL=0
+72s test-skill-cleanup.sh: PASS=298 FAIL=0
+72s test-skills.sh: PASS=225 FAIL=0
+73s test-suite-paralela.sh: PASS=65 FAIL=0
+73s test-templates.sh: PASS=31 FAIL=0
+73s run.sh: 0 arquivo(s) de teste com falha (73 s)
A_exit=0  A_max_concorrente=15  A_stderr_bytes=0
B_exit=0  B_max_concorrente=4   B_stderr_bytes=0   diff_AB=0
```

B — C1 (stdout + stderr juntos) e C1b (só stdout):

```
== C1                                              == C1b (2>/dev/null)
carga MEDIUM (bytes): ...                          carga MEDIUM (bytes): ...
test-carga.sh: PASS=16 FAIL=0                      test-carga.sh: PASS=16 FAIL=0
test-session-start.sh: PASS=9 FAIL=0               test-session-start.sh: PASS=9 FAIL=0
test-templates.sh: PASS=31 FAIL=0                  test-templates.sh: PASS=31 FAIL=0
tests/test-zz-crash.sh: line 3: comando-que-nao-existe-e2e: command not found
antes-do-crash                                     antes-do-crash
  FAIL: plantado pelo e2e
saida-normal-antes                                 saida-normal-antes
test-zz-falha.sh: PASS=1 FAIL=1                    test-zz-falha.sh: PASS=1 FAIL=1
run.sh: TIMEOUT tests/test-zz-trava.sh (10 s)
vai-travar                                         vai-travar
run.sh: 3 arquivo(s) de teste com falha (10 s)     run.sh: 3 arquivo(s) de teste com falha (10 s)
c1_exit=1 dur=10   c1_neto=morto                   c1b_exit=1   (C1c série: diff_par_serie=0)
```

C — saída do gate vista pela sessão (fim):

```
test-templates.sh: PASS=31 FAIL=0
  FAIL: plantado pelo e2e da suite-paralela
test-zz-plantado.sh: PASS=1 FAIL=1
run.sh: 1 arquivo(s) de teste com falha (78 s)
GATE: reprovado — 1 motivo(s):
  - suite falhou: bash tests/run.sh
EXIT=1
```

Resposta da sessão: "Gate **reprovou** (exit 1) … 1 de 18 … Linha FAIL: `FAIL:
plantado pelo e2e da suite-paralela` … 78 s … Motivo do gate: `suite falhou:
bash tests/run.sh` … Nenhum arquivo alterado." `git status` da worktree depois:
só o arquivo plantado (`??`).

## Observações (fora dos critérios)

- Máquina sem carga hoje: skill-cleanup sozinho levou 62 s (194 s na T5, com
  a máquina carregada; 73 s no scope). A razão /17 ficou parecida nos dois
  dias (1,18–1,22×): o caminho crítico é o skill-cleanup.
- Erro do script do e2e: a 1ª rodada do C1 saiu sem `SUITE_TIMEOUT=10` (estava
  só no texto do echo). Serviu de evidência do default de 300 s; a rodada
  certa veio depois. Ao matar o script no meio, `run.sh` e o arquivo travado
  ficaram vivos — Ctrl-C/interrupção matando os filhos está fora de escopo
  (anotado no nó); limpei à mão.
- 1ª versão do amostrador contou também as suítes falsas que o
  `test-suite-paralela.sh` sobe (deu 6 com `SUITE_JOBS=4`); filtrando pelos
  nomes reais de `tests/` deu 4.
- Custo da sessão: US$ 0,23, 2 turnos, 89 s. A sessão chamou o Bash com
  `timeout: 600000` direto e esperou a suíte em primeiro plano.
