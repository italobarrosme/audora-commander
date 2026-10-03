# Plano — suite-paralela: Suíte em paralelo

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** `bash tests/run.sh` roda os `tests/test-*.sh` em paralelo (até `SUITE_JOBS`, default = núcleos), imprime cada arquivo em bloco na ordem do glob (stderr dele, depois stdout), com tempo no resumo, timeout por arquivo (`SUITE_TIMEOUT`, default 300 s, 0 desliga) e o mesmo código de saída.

**Nó do MEMORY:** `suite-paralela` (MEMORY.md) — 17 critérios (a /7 com delta de 2026-10-03: stderr antes do stdout), categoria MEDIUM (sem portão de plano).

**Arquitetura da mudança:** reescrita só do `tests/run.sh` (bash puro, sem dependência nova; `timeout` e `nproc` vêm do coreutils do Git Bash). Cada arquivo roda em background num subshell: `timeout -k 5 "$tmo" bash "$t" </dev/null >"$W/$i.out" 2>"$W/$i.err"`, e o código de saída vai para `$W/$i.rc` por escrita atômica (`.tmp` + `mv`). Um laço de polling (`sleep 0.1`, portável, sem `wait -n`) dispara arquivos enquanto houver menos de `jobs` rodando e, a cada volta, despeja em ordem todo bloco cujo `.rc` existe e cujos anteriores já saíram: `cat err >&2` (+ linha de TIMEOUT se rc=124 e tmo>0) e depois `cat out`. GNU `timeout` cria grupo de processos próprio e mata a árvore inteira, inclusive exe nativo: sondado na fase plan (netos `sleep` e `PING.EXE` não sobraram). Os testes só leem o repo real (escrita vai para `mktemp -d` via `lib.sh`), então /4 é verificada por medição, sem mexer nos testes.

**Arquivos lidos antes de planejar:**
- `tests/run.sh:1-10` — arquivo inteiro: laço serial, `falhas`, linha `run.sh: $falhas arquivo(s) de teste com falha`, `[ "$falhas" -eq 0 ]` como exit.
- `tests/lib.sh:1-21` — `$ROOT`, `$SP` em `mktemp -d` com trap, `ok`/`ko` (ko escreve `  FAIL:` no stderr), `assert_*`, `report` (única escrita no stdout, no fim).
- `hooks/gate:1-70` — `SUITE_CMD` default `bash tests/run.sh` (10), `cd GATE_ROOT` (8), `etapa` roda `bash -c "$cmd"` e registra `suite falhou: <cmd>` (58-62), saída `GATE: passou`/`GATE: reprovado` (67-70); anti-fraude conta `ASSERT_ERE` em `^tests/test-.*\.sh$`.
- `tests/test-gate.sh:1-45` — padrão de fixture git (`init`, `user.*`, `core.autocrlf false`, commit) e `rungate` com `GATE_ROOT`.
- `tests/test-*.sh` (busca de escrita fora do `$SP`/fixtures e de echo no stdout) — nenhum arquivo escreve no repo real; só `tests/test-carga.sh:19` escreve no stdout antes do `report` (único efeito visível do delta da /7).
- `tests/test-dogfood.sh:1-21`, `tests/test-carga.sh:1-22` — leem `MEMORY.md`/skills do `$ROOT`, sem escrita; `run.sh` fora da lista de carga.
- `README.md:370-374`, `README.pt-BR.md:367-371` — seção Development/Desenvolvimento cita `bash tests/run.sh`: ponto onde as variáveis entram.
- `PRD.md:15-30` — Stack cita `tests/run.sh`; PRD só muda no sync pós-merge.
- `docs/audora/planos/arquivo/plano-cleanup-link-preciso.md:1-40` — formato do último plano (gate antes de cada commit nas notas).
- Ambiente sondado: `nproc`=22, GNU `timeout` 8.32, bash 5.2 msys; sem `setsid`/`flock`; sem `.env` nem `.env.example` no repo.

**Conflitos MEMORY vs código encontrados:** nenhum. Escopo reaberto na fase plan (só a /7), registrado em `## delta` e `## decisoes` do nó.

## Notas de sessão

- 2026-10-03 (plan): base medida no scope: 213 s em série, `test-skill-cleanup.sh` 73 s sozinho.
- Gate antes de CADA commit (aprendizado 2026-09-30): `bash hooks/gate suite-paralela`, saída registrada aqui. `run.sh` passa de 120 s em série → rodar com `run_in_background` e ler o arquivo de saída (aprendizado 2026-09-05); exit real com `> arq 2>&1; echo $?`, nunca `| tail` (aprendizado 2026-08-31).
- Caminhos de fixture (testes falsos) aparecem só em bloco de código: a cleanup varre `docs/audora/` (aprendizado 2026-10-03).
- Decisões tomadas pela IA (a validate apresenta): nomes `SUITE_JOBS`/`SUITE_TIMEOUT`; `timeout -k 5` (KILL 5 s depois do TERM); default de jobs `nproc` → `getconf _NPROCESSORS_ONLN` → 1; sem `timeout` no PATH → aviso `run.sh: timeout ausente — rodando sem limite` e roda sem limite; mensagens exatas de aviso abaixo. Pendente para o humano: a regra global pede env nova no `.env`, mas este repo não tem `.env` e as duas variáveis são botões do runner com default — o plano documenta nos README e NÃO cria `.env` sem o sim dele.

- 2026-10-03 (execute T1): red com 7 FAIL pelo motivo certo (/7 saiu O1 E1 O2 E2; /8 /9 /10 sem `(<s> s)`; /11 rodou o glob literal); green `test-suite-paralela.sh` PASS=18 FAIL=0; `bash hooks/gate suite-paralela` → `GATE: passou`, exit 0, `run.sh: 0 arquivo(s) de teste com falha (172 s)` (ainda jobs=1). Decisão da IA: helpers do teste sem `env` (nesta máquina `~/.local/bin/env` é script do uv) — `unset SUITE_*` + `export` num subshell, para a env do runner externo não vazar na suíte falsa.
- 2026-10-03 (execute T2): red com 8 FAIL pelo motivo certo (/1 /2 /3 maxconc 1, sem aviso de SUITE_JOBS); /2 N=1 e /6 passaram de guarda; green PASS=35 FAIL=0; `bash hooks/gate suite-paralela` → `GATE: passou`, exit 0, `run.sh: 0 arquivo(s) de teste com falha (83 s)` — abaixo dos 213 s da base.
- 2026-10-03 (execute T3): red com 8 FAIL pelo motivo certo (/12 /13 levou 30 s, sem linha TIMEOUT, exit 0, neto vivo; /15 sem aviso); green PASS=56 FAIL=0 (`ps` sem `sleep` sobrando). Casos a mais, cada um visto vermelho antes (ramo tirado e recolocado): arquivo que ignora TERM sai 137 pelo KILL e ganha a mesma linha de TIMEOUT; o "Killed" do bash do subshell não vaza (mutante sem `2>/dev/null` reprova); sem GNU `timeout` (stub que sai 1, como o `timeout.exe` do Windows) → aviso e roda sem limite. `bash hooks/gate suite-paralela` → `GATE: passou`, exit 0, `(230 s)`. Lentidão investigada: `SUITE_TIMEOUT=0` deu 246 s (não é o `timeout`); máquina carregada (processo `FC26` no topo de CPU) — `test-skill-cleanup.sh` sozinho 194 s (73 s no scope). /17 é relativa e medida na T5, na mesma sessão.
- Decisões tomadas pela IA (T3): rc 124 **ou 137** com tmo>0 = TIMEOUT (137 = precisou do KILL do `-k 5`); stderr do subshell de disparo → `/dev/null` (o do teste continua no `.err`); presença do GNU `timeout` por `timeout --version` (o do Windows sai ≠ 0); neto do fake lento em laço limitado (`seq 150`) para o red não deixar processo eterno.
- 2026-10-03 (execute T4): docs com 4 FAIL antes da frase; /16 sem red (contrato preservado) — mordida provada: fake `b` do caso vermelho trocado por `true` → 3 FAIL (exit, `GATE: reprovado`, `suite falhou: bash tests/run.sh`), desfeito. Green PASS=65 FAIL=0; `bash hooks/gate suite-paralela` → `GATE: passou`, exit 0, `(164 s)`; `git diff hooks/gate` vazio. Fixture do gate limpa `GATE_SUITE_CMD` e `SUITE_*` no subshell.

### Contrato fixo do `run.sh` (todas as tarefas)

```
SUITE_JOBS     ausente → $(nproc || getconf _NPROCESSORS_ONLN || echo 1)
               ^[1-9][0-9]*$ → esse valor
               qualquer outro (inclui vazio) → stderr: run.sh: SUITE_JOBS inválido ('<valor>') — usando <default>
SUITE_TIMEOUT  ausente → 300 | ^(0|[1-9][0-9]*)$ → esse valor (0 = sem limite)
               qualquer outro (inclui vazio) → stderr: run.sh: SUITE_TIMEOUT inválido ('<valor>') — usando 300
bloco do arquivo i:  stderr dele (>&2) [+ run.sh: TIMEOUT tests/<arq> (<tmo> s) >&2 se rc=124 e tmo>0]  →  stdout dele
última linha stdout: run.sh: <n> arquivo(s) de teste com falha (<s> s)     # s = SECONDS desde o início
sem test-*.sh:       stderr "run.sh: nenhum arquivo de teste", stdout vazio, exit 1
exit:                0 se n=0, senão 1
```

### Helpers do teste novo (`tests/test-suite-paralela.sh`, criados na T1, usados por todas)

```
mksuite <dir>              # rm -rf; mkdir -p <dir>/tests <dir>/bin; cp "$ROOT/tests/run.sh" <dir>/tests/
fake <dir> <nome> <corpo>  # grava <dir>/tests/test-<nome>.sh com '#!/usr/bin/env bash' + corpo
stubnproc <dir> <n>        # grava <dir>/bin/nproc que imprime <n> (PATH="<dir>/bin:$PATH")
runs <dir> [VAR=valor...]  # (cd <dir> && env PATH="<dir>/bin:$PATH" "$@" bash tests/run.sh >"$SP/o" 2>"$SP/e"); code=$?; o=$(cat $SP/o); e=$(cat $SP/e)
mescla <dir> [VAR=valor...]# igual a runs, mas 2>&1 num arquivo só → m=$(cat $SP/m)
maxconc <dir>              # maior número gravado em <dir>/mark/n.* (sort -n | tail -1)
```

Corpo do fake de concorrência (`CONC`), usado em /1 /2 /3:

```
mkdir -p "$MARK"; touch "$MARK/r.$$"; sleep 2
ls "$MARK" | grep -c '^r\.' > "$MARK/n.$$"; rm -f "$MARK/r.$$"
```

(`MARK=<dir>/mark` exportado pelo `runs`.)

---

## Tarefa 1: blocos em ordem, resumo com tempo, código de saída e suíte vazia

- **depende-de**: []
- **requisito**:
  - `suite-paralela/5` — QUANDO a suíte termina O SISTEMA DEVE ter impresso o bloco de cada arquivo na ordem do glob `tests/test-*.sh` (a de hoje), sem linha de um arquivo intercalada no bloco de outro.
  - `suite-paralela/7` (delta) — QUANDO um arquivo escreve no stderr (ex.: linhas `FAIL:`) O SISTEMA DEVE emitir essas linhas no stderr do `run.sh`, dentro do bloco do arquivo, ANTES das linhas de stdout dele, cada canal na ordem em que o arquivo o escreveu; com `2>/dev/null`, só elas somem.
  - `suite-paralela/8` — QUANDO a suíte termina O SISTEMA DEVE imprimir como última linha do stdout `run.sh: <n> arquivo(s) de teste com falha (<s> s)`, com `<n>` = nº de arquivos com falha e `<s>` = segundos inteiros de relógio desde o início do `run.sh`.
  - `suite-paralela/9` — QUANDO algum arquivo sai com código ≠ 0 (falha, crash, comando não encontrado, timeout) O SISTEMA DEVE contá-lo em `<n>`, rodar todos os demais até o fim e sair 1.
  - `suite-paralela/10` — QUANDO todos os arquivos saem 0 O SISTEMA DEVE sair 0.
  - `suite-paralela/11` — QUANDO `tests/` não tem nenhum `test-*.sh` O SISTEMA DEVE imprimir no stderr `nenhum arquivo de teste` e sair 1.
- **decisões relevantes**: saída em blocos na ordem do glob; tempo como sufixo `(<s> s)`; suíte vazia = exit 1; stderr antes do stdout (delta /7).
- **interfaces**: produz `tests/run.sh` com a estrutura completa (workdir `W=$(mktemp -d)` com trap, arrays `arqs`, laço de polling, função `despeja <i>` que imprime o bloco i e soma falha se rc≠0). Nesta tarefa o limite fica FIXO em `jobs=1` (o laço novo, em série; `nucleos`/`SUITE_JOBS` entram na T2) e o disparo vai sem `timeout` (a T3 liga). Produz os helpers `mksuite`, `fake`, `runs`, `mescla` do teste novo.
- **ponto de mudança**: `tests/run.sh:1-10` — reescrita; teste novo `tests/test-suite-paralela.sh`.
- **teste**: `tests/test-suite-paralela.sh` — casos "suite-paralela/5 ordem do glob", "/7 stderr antes do stdout", "/8 resumo com tempo", "/9 falhas contadas e todos rodam", "/10 tudo verde sai 0", "/11 suíte vazia".
- **asserções**:

```
/5   fakes: a = 'sleep 2; echo a1; echo a2'  b = 'echo b1; echo b2'  c = 'sleep 1; echo c1'
     runs → as 5 primeiras linhas de $o == a1 a2 b1 b2 c1 (nessa ordem); code 0
/7   fake a = 'echo O1; echo E1 >&2; echo O2; echo E2 >&2'
     runs  → $e == "E1\nE2"; $o sem a última linha == "O1\nO2"
     mescla → 4 primeiras linhas de $m == E1 E2 O1 O2
/8   (no /5) última linha de $o casa ^run\.sh: 0 arquivo\(s\) de teste com falha \(([0-9]+) s\)$ e o número ≥ 2
/9   fakes: ok = 'touch "$MARK/ok"'  um = 'touch "$MARK/um"; exit 1'
            tres = 'touch "$MARK/tres"; exit 3'  nada = 'touch "$MARK/nada"; comando-inexistente-xyz'
     runs → code 1; última linha de $o começa com 'run.sh: 3 arquivo(s) de teste com falha ('
            os 4 marcadores existem
/10  fakes: x = 'true'  y = 'echo y'  → code 0; última linha começa com 'run.sh: 0 arquivo(s) de teste com falha ('
/11  mksuite sem fake → code 1; $e == 'run.sh: nenhum arquivo de teste'; $o vazio
```

- **ler**: `tests/run.sh:1-10`, `tests/lib.sh:1-21`
- **done quando**: os 6 casos verdes; `bash tests/run.sh` (a suíte real, já pelo runner novo) sai 0.

- [x] **red** — `bash tests/test-suite-paralela.sh` falha em /7 (hoje o stderr sai na hora: `$m` = O1 E1 O2 E2), /8 (sem `(<s> s)`) e /11 (hoje roda o glob literal e não imprime a mensagem); /5 /9 /10 já passam no serial (guarda de regressão).
- [x] **green** — `bash tests/test-suite-paralela.sh` → `FAIL=0`; `bash tests/run.sh > "$SP/r.log" 2>&1; echo $?` → `0` (rodar em background); `bash hooks/gate suite-paralela` → `GATE: passou` (registrar nas notas)
- [x] **commit** — `git add tests/run.sh tests/test-suite-paralela.sh && git commit -m "feat(suite-paralela/5,7-11): run.sh em blocos ordenados, tempo no resumo e suíte vazia"`

## Tarefa 2: limite de paralelismo e saída em fluxo

- **depende-de**: [1]
- **requisito**:
  - `suite-paralela/1` — QUANDO `bash tests/run.sh` roda sem a variável de limite definida O SISTEMA DEVE executar os `tests/test-*.sh` em processos simultâneos, com no máximo N rodando ao mesmo tempo, onde N = nº de núcleos lógicos da máquina.
  - `suite-paralela/2` — QUANDO a variável de limite vale um inteiro N ≥ 1 O SISTEMA DEVE manter no máximo N arquivos rodando ao mesmo tempo; com N = 1, cada arquivo só começa depois que o anterior termina (como hoje).
  - `suite-paralela/3` — QUANDO a variável de limite tem valor inválido (vazio, 0, negativo ou não numérico) O SISTEMA DEVE imprimir no stderr um aviso com o nome da variável e o valor rejeitado e rodar com o limite default (/1).
  - `suite-paralela/6` — QUANDO um arquivo termina e todos os anteriores na ordem já foram impressos O SISTEMA DEVE imprimir o bloco dele na hora, sem esperar os arquivos seguintes.
- **decisões relevantes**: limite default = núcleos; `SUITE_JOBS` muda, 1 = série; inválido → aviso + default (contrato fixo acima).
- **interfaces**: consome o laço de polling e `despeja` da T1 · produz no `run.sh` a função `int_env <nome> <default> <ere>` (imprime o valor válido ou o default; avisa no stderr com o texto do contrato) e `jobs=$(int_env SUITE_JOBS "$(nucleos)" '^[1-9][0-9]*$')`, com `nucleos` = `nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1`. Teste ganha `stubnproc` e `maxconc`.
- **ponto de mudança**: `tests/run.sh` — início (cálculo de `jobs`) e condição de disparo do laço.
- **teste**: `tests/test-suite-paralela.sh` — casos "suite-paralela/1 default = núcleos", "/2 SUITE_JOBS=N", "/3 SUITE_JOBS inválido", "/6 fluxo".
- **asserções**:

```
/1   4 fakes CONC; stubnproc 2 → runs → maxconc == 2; code 0
     4 fakes CONC; stubnproc 8 → runs → maxconc == 4
/2   4 fakes CONC; stubnproc 8; SUITE_JOBS=2 → maxconc == 2
     2 fakes CONC; stubnproc 8; SUITE_JOBS=1 → maxconc == 1
/3   4 fakes CONC; stubnproc 2; SUITE_JOBS=abc → $e contém "run.sh: SUITE_JOBS inválido ('abc') — usando 2"; maxconc == 2; code 0
     fake 'true'; stubnproc 2; para cada v em '0' '-1' '' →
          $e contém "run.sh: SUITE_JOBS inválido ('<v>') — usando 2"; code 0
/6   stubnproc 8; fakes a = 'echo a'  b = 'sleep 6; echo b'
     run.sh em background (>"$SP/f.o"); polling até 4 s por 'a' em f.o →
          f.o contém 'a' e NÃO contém 'run.sh:' nesse instante; depois wait → code 0
```

- **ler**: `tests/run.sh` (versão da T1)
- **done quando**: os 4 casos verdes; suíte real sai 0 e a linha `(<s> s)` dela já fica abaixo dos 213 s da base (registrar).

- [x] **red** — `bash tests/test-suite-paralela.sh` falha em /1 (T1 tem `jobs=1`: maxconc 1, esperado 2 e 4), /2 com SUITE_JOBS=2 (maxconc 1) e /3 (sem aviso); /2 com N=1 e /6 já passam (guarda)
- [x] **green** — `bash tests/test-suite-paralela.sh` → `FAIL=0`; `bash tests/run.sh > "$SP/r.log" 2>&1; echo $?` → `0`; `bash hooks/gate suite-paralela` → `GATE: passou` (registrar)
- [x] **commit** — `git add tests/run.sh tests/test-suite-paralela.sh && git commit -m "feat(suite-paralela/1-3,6): limite SUITE_JOBS (default núcleos) e saída em fluxo"`

## Tarefa 3: timeout por arquivo

- **depende-de**: [2]
- **requisito**:
  - `suite-paralela/12` — QUANDO um arquivo passa do timeout (default 300 s) O SISTEMA DEVE encerrá-lo sem deixar nenhum processo dele rodando, contá-lo como falha e emitir no stderr, dentro do bloco dele, uma linha com o nome do arquivo e o limite estourado.
  - `suite-paralela/13` — QUANDO a variável de timeout vale um inteiro T > 0 O SISTEMA DEVE usar T segundos como timeout de cada arquivo.
  - `suite-paralela/14` — QUANDO a variável de timeout vale 0 O SISTEMA DEVE rodar sem timeout (comportamento de hoje).
  - `suite-paralela/15` — QUANDO a variável de timeout tem valor inválido (vazio, negativo ou não numérico) O SISTEMA DEVE imprimir no stderr um aviso com o nome da variável e o valor rejeitado e usar 300 s.
- **decisões relevantes**: 300 s default, `SUITE_TIMEOUT` muda, 0 desliga; inválido → aviso + 300; linha de TIMEOUT é a última do stderr do bloco (antes do stdout, pelo delta /7).
- **interfaces**: consome `int_env` da T2 · produz `tmo=$(int_env SUITE_TIMEOUT 300 '^(0|[1-9][0-9]*)$')` e o disparo `timeout -k 5 "$tmo" bash "$t"` (GNU: duração 0 = sem limite); em `despeja`, rc=124 e tmo>0 → `echo "run.sh: TIMEOUT $t ($tmo s)" >&2` depois do `cat err`. Sem `timeout` no PATH → aviso único `run.sh: timeout ausente — rodando sem limite` e disparo sem ele.
- **ponto de mudança**: `tests/run.sh` — cálculo de `tmo`, linha do disparo e `despeja`.
- **teste**: `tests/test-suite-paralela.sh` — casos "suite-paralela/12 timeout mata a árvore", "/13 SUITE_TIMEOUT=T", "/14 SUITE_TIMEOUT=0", "/15 SUITE_TIMEOUT inválido".
- **asserções**:

```
/12+/13  fakes: ok = 'true'
                lento = 'echo antes; (while :; do touch "$MARK/tick"; sleep 0.2; done) & sleep 30'
         SUITE_TIMEOUT=2; mescla, medindo SECONDS →
           duração < 15 s; code 1
           $m tem, nesta ordem e seguidas: 'run.sh: TIMEOUT tests/test-lento.sh (2 s)' e 'antes'
           última linha começa com 'run.sh: 1 arquivo(s) de teste com falha ('
         depois: rm -f "$MARK/tick"; sleep 1 → assert_no_file "$MARK/tick" (nenhum processo do arquivo sobrou)
/14      fake 'sleep 3'; SUITE_TIMEOUT=0 → code 0; $e não contém 'inválido' nem 'TIMEOUT'
/15      fake 'true'; para cada v em 'x' '-5' '' →
           $e contém "run.sh: SUITE_TIMEOUT inválido ('<v>') — usando 300"; code 0
```

- **ler**: `tests/run.sh` (versão da T2)
- **done quando**: os 4 casos verdes; nenhum `sleep`/`bash` do fake lento vivo depois do caso (conferir também com `ps` na primeira rodada, registrar nas notas); suíte real sai 0.

- [x] **red** — `bash tests/test-suite-paralela.sh` falha em /12 (sem timeout o caso leva 30 s, sem linha TIMEOUT e com code 0) e /15 (sem aviso)
- [x] **green** — `bash tests/test-suite-paralela.sh` → `FAIL=0`; `bash tests/run.sh > "$SP/r.log" 2>&1; echo $?` → `0`; `bash hooks/gate suite-paralela` → `GATE: passou` (registrar)
- [x] **commit** — `git add tests/run.sh tests/test-suite-paralela.sh && git commit -m "feat(suite-paralela/12-15): timeout por arquivo (SUITE_TIMEOUT, default 300 s, 0 desliga)"`

## Tarefa 4: contrato do gate e documentação das variáveis

- **depende-de**: [3]
- **requisito**:
  - `suite-paralela/16` — QUANDO `bash hooks/gate` roda O SISTEMA DEVE manter o contrato de hoje: suíte com exit 0 → gate passa; algum arquivo vermelho → gate reprova pelo motivo da suíte.
- **decisões relevantes**: gate não muda (fora de escopo); a doc cita os nomes das variáveis (decisão do scope).
- **interfaces**: consome o `run.sh` final e `hooks/gate` sem alteração · fixture git `gproj` no padrão de `tests/test-gate.sh:24-32` (`init`, `user.*`, `core.autocrlf false`, `core.excludesFile` inexistente — aprendizado 2026-09-29), com `tests/run.sh` copiado e fakes commitados; gate chamado como `(cd "$gproj" && GATE_ROOT="$gproj" bash "$ROOT/hooks/gate" 2>&1)` SEM `GATE_SUITE_CMD`, para exercitar o default `bash tests/run.sh`.
- **ponto de mudança**: `tests/test-suite-paralela.sh` (casos novos); `README.md:372-374` e `README.pt-BR.md:369-371` — frase após "Regression suite"/"Suíte de regressão" citando `SUITE_JOBS` (default = núcleos, 1 = série) e `SUITE_TIMEOUT` (default 300 s, 0 = sem limite); bullet `como-rodar` da Constituição no `MEMORY.md` ganha "`SUITE_JOBS=1` = em série" (skill memory, registrar-delta item 4).
- **teste**: `tests/test-suite-paralela.sh` — casos "suite-paralela/16 gate verde", "/16 gate vermelho", "docs citam SUITE_JOBS e SUITE_TIMEOUT".
- **asserções**:

```
/16 verde     fakes commitados: a = 'true'  b = 'echo b'      → code 0; saída contém 'GATE: passou'
/16 vermelho  fakes commitados: a = 'true'  b = 'exit 1'      → code 1; saída contém 'GATE: reprovado'
                                                                e 'suite falhou: bash tests/run.sh'
docs          README.md e README.pt-BR.md contêm 'SUITE_JOBS' e 'SUITE_TIMEOUT' (4 asserts)
```

- **ler**: `hooks/gate:1-70`, `tests/test-gate.sh:24-45`, `README.md:370-374`, `README.pt-BR.md:367-371`, `MEMORY.md` só o bullet `como-rodar` (grep)
- **done quando**: casos verdes; `git diff hooks/gate` vazio.

- [x] **red** — /16 não tem red (contrato preservado): prova de mordida = trocar o fake `b` do caso vermelho por `true` e ver os asserts de 'GATE: reprovado' falharem (desfazer). Docs: `bash tests/test-suite-paralela.sh` falha nos 4 asserts de README antes da frase.
- [x] **green** — `bash tests/test-suite-paralela.sh` → `FAIL=0`; `bash tests/run.sh > "$SP/r.log" 2>&1; echo $?` → `0`; `bash hooks/gate suite-paralela` → `GATE: passou` (registrar)
- [x] **commit** — `git add tests/test-suite-paralela.sh README.md README.pt-BR.md MEMORY.md && git commit -m "test(suite-paralela/16): gate segue o contrato com o run.sh paralelo; docs de SUITE_JOBS e SUITE_TIMEOUT"`

## Tarefa 5: medição — mesmo veredito e meta de tempo

- **depende-de**: [4]
- **requisito**:
  - `suite-paralela/4` — QUANDO os arquivos rodam em paralelo O SISTEMA DEVE dar a cada arquivo o mesmo veredito (código de saída e linha `PASS=… FAIL=…`) que ele tem com limite 1 na mesma árvore, sem interferência entre arquivos.
  - `suite-paralela/17` — QUANDO a suíte roda nesta máquina (22 núcleos) com limite e timeout default O SISTEMA DEVE terminar em ≤ 1,5× o tempo do arquivo mais lento rodando sozinho, os dois medidos na mesma sessão.
- **decisões relevantes**: meta relativa 1,5×; /4 e /17 medidas por comando (dentro da suíte rodariam a suíte de novo, recursivo).
- **interfaces**: nenhuma de código. Se /4 divergir → debug (interferência entre arquivos), não replanejamento; se /17 estourar → medir por arquivo sob carga antes de mexer.
- **ponto de mudança**: nenhum arquivo de produto; evidência em `## Notas de sessão` deste plano.
- **teste**: comandos abaixo (todos com `run_in_background`, lendo o arquivo inteiro).
- **asserções**:

```
mais lento sozinho:
  for t in tests/test-*.sh; do s=$SECONDS; bash "$t" >/dev/null 2>&1; echo "$((SECONDS-s)) $t"; done | sort -n | tail -1
  → L segundos
paralelo (2 rodadas):   bash tests/run.sh > "$SP/p1.out" 2> "$SP/p1.err"; echo $?   (idem p2)
série:                  SUITE_JOBS=1 bash tests/run.sh > "$SP/s.out" 2> "$SP/s.err"; echo $?
/4   exits de p1, p2 e s iguais (0)
     diff <(grep 'PASS=' "$SP/s.out" | sort) <(grep 'PASS=' "$SP/p1.out" | sort) → vazio (idem p2)
/17  P = número de '(<P> s)' da última linha de p1 e de p2 → P ≤ 1,5 × L nas duas
```

- **ler**: nenhum trecho novo
- **done quando**: /4 e /17 com os números registrados nas notas de sessão (L, P1, P2, tempo da série).

- [ ] **red** — n/a (medição); o "antes" é o baseline do scope: 213 s em série, mais lento 73 s
- [ ] **green** — os comandos acima com o resultado esperado, registrados nas notas
- [ ] **commit** — `git add docs/audora/planos/plano-suite-paralela.md && git commit -m "docs(suite-paralela/4,17): medição — mesmo veredito em paralelo e tempo ≤ 1,5× o mais lento"`
