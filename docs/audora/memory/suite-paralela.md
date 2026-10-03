---
id: suite-paralela
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [testes, suite, paralelo, run.sh, gate, velocidade, timeout]
resumo: A suíte tests/run.sh roda os arquivos de teste em paralelo, sem subagente, mantendo a saída na ordem de sempre e o mesmo código de saída
atualizado-em: 2026-10-03
---

# suite-paralela

## objetivo

`bash tests/run.sh` roda os `tests/test-*.sh` em processos simultâneos
(limitados ao nº de núcleos) e imprime as saídas na ordem de sempre, com o
mesmo código de saída, o tempo total no resumo e um timeout por arquivo. O
gate, que chama o `run.sh`, fica mais rápido sem mudar de contrato. Medido em
2026-10-03: 213 s em série, arquivo mais lento 73 s
(`test-skill-cleanup.sh`), 22 núcleos.

## criterios-aceite

Paralelismo
- suite-paralela/1 — QUANDO `bash tests/run.sh` roda sem a variável de limite definida O SISTEMA DEVE executar os `tests/test-*.sh` em processos simultâneos, com no máximo N rodando ao mesmo tempo, onde N = nº de núcleos lógicos da máquina.
- suite-paralela/2 — QUANDO a variável de limite vale um inteiro N ≥ 1 O SISTEMA DEVE manter no máximo N arquivos rodando ao mesmo tempo; com N = 1, cada arquivo só começa depois que o anterior termina (como hoje).
- suite-paralela/3 — QUANDO a variável de limite tem valor inválido (vazio, 0, negativo ou não numérico) O SISTEMA DEVE imprimir no stderr um aviso com o nome da variável e o valor rejeitado e rodar com o limite default (/1).
- suite-paralela/4 — QUANDO os arquivos rodam em paralelo O SISTEMA DEVE dar a cada arquivo o mesmo veredito (código de saída e linha `PASS=… FAIL=…`) que ele tem com limite 1 na mesma árvore, sem interferência entre arquivos.

Saída
- suite-paralela/5 — QUANDO a suíte termina O SISTEMA DEVE ter impresso o bloco de cada arquivo na ordem do glob `tests/test-*.sh` (a de hoje), sem linha de um arquivo intercalada no bloco de outro.
- suite-paralela/6 — QUANDO um arquivo termina e todos os anteriores na ordem já foram impressos O SISTEMA DEVE imprimir o bloco dele na hora, sem esperar os arquivos seguintes.
- suite-paralela/7 — QUANDO um arquivo escreve no stderr (ex.: linhas `FAIL:`) O SISTEMA DEVE emitir essas linhas no stderr do `run.sh`, dentro do bloco do arquivo, na mesma ordem relativa às linhas de stdout em que o arquivo as escreveu; com `2>/dev/null`, só elas somem.
- suite-paralela/8 — QUANDO a suíte termina O SISTEMA DEVE imprimir como última linha do stdout `run.sh: <n> arquivo(s) de teste com falha (<s> s)`, com `<n>` = nº de arquivos com falha e `<s>` = segundos inteiros de relógio desde o início do `run.sh`.

Código de saída
- suite-paralela/9 — QUANDO algum arquivo sai com código ≠ 0 (falha, crash, comando não encontrado, timeout) O SISTEMA DEVE contá-lo em `<n>`, rodar todos os demais até o fim e sair 1.
- suite-paralela/10 — QUANDO todos os arquivos saem 0 O SISTEMA DEVE sair 0.
- suite-paralela/11 — QUANDO `tests/` não tem nenhum `test-*.sh` O SISTEMA DEVE imprimir no stderr `nenhum arquivo de teste` e sair 1.

Timeout
- suite-paralela/12 — QUANDO um arquivo passa do timeout (default 300 s) O SISTEMA DEVE encerrá-lo sem deixar nenhum processo dele rodando, contá-lo como falha e emitir no stderr, dentro do bloco dele, uma linha com o nome do arquivo e o limite estourado.
- suite-paralela/13 — QUANDO a variável de timeout vale um inteiro T > 0 O SISTEMA DEVE usar T segundos como timeout de cada arquivo.
- suite-paralela/14 — QUANDO a variável de timeout vale 0 O SISTEMA DEVE rodar sem timeout (comportamento de hoje).
- suite-paralela/15 — QUANDO a variável de timeout tem valor inválido (vazio, negativo ou não numérico) O SISTEMA DEVE imprimir no stderr um aviso com o nome da variável e o valor rejeitado e usar 300 s.

Contrato e meta
- suite-paralela/16 — QUANDO `bash hooks/gate` roda O SISTEMA DEVE manter o contrato de hoje: suíte com exit 0 → gate passa; algum arquivo vermelho → gate reprova pelo motivo da suíte.
- suite-paralela/17 — QUANDO a suíte roda nesta máquina (22 núcleos) com limite e timeout default O SISTEMA DEVE terminar em ≤ 1,5× o tempo do arquivo mais lento rodando sozinho, os dois medidos na mesma sessão.

## fora-de-escopo

- Ctrl-C/interrupção da suíte matando os processos de teste em andamento: não entra.
- Rodar só alguns arquivos (nomes como argumento do `run.sh`): não entra.
- Linha de progresso ou saída em ordem de término: a saída continua em blocos na ordem do glob.
- Execute paralela com subagentes: fica para o nó `agentes-dedicados`.
- Mudar o conteúdo dos `tests/test-*.sh` além do necessário para tirar interferência entre arquivos (/4); nenhum teste é removido nem tem assert apagado.
- Mudança de comportamento no `hooks/gate` (só herda a velocidade).

## decisoes

- 2026-10-03 (humano): paralelizar a suíte sem subagente (frente 1); execute paralela com subagentes fica para o nó `agentes-dedicados`.
- 2026-10-03 (humano, scope): saída em ordem fixa e em fluxo (bloco N sai quando N e os anteriores acabam). Descartados: tudo no fim (silêncio longo) e progresso + bloco final (a saída deixaria de ser igual à em série).
- 2026-10-03 (humano, scope): limite default = nº de núcleos, mudável por variável de ambiente (1 = série). Descartados: todos juntos com env (pesa demais em máquina com poucos núcleos) e todos juntos sem válvula (sem volta para série na hora de depurar).
- 2026-10-03 (humano, scope): meta de tempo relativa, ≤ 1,5× o arquivo mais lento sozinho. Descartados: absoluta ≤ 100 s (presa a esta máquina) e sem número (critério que não reprova nada).
- 2026-10-03 (humano, scope): entram tempo no resumo e timeout por arquivo. Ficam fora: Ctrl-C matando todos e rodar só alguns arquivos.
- 2026-10-03 (humano, scope): timeout default 300 s, mudável por env; 0 desliga. Descartados: 180 s (falha falsa com a máquina carregada) e 600 s fixo (sem válvula).
- 2026-10-03 (humano, scope): tempo como sufixo na linha de hoje, `(<s> s)`, para planos e docs que citam `run.sh: 0 arquivo(s) de teste com falha` continuarem batendo. Descartado: linha separada.
- 2026-10-03 (humano, scope): stderr dos arquivos continua no stderr, no bloco do arquivo, na ordem relativa de hoje. Descartados: stderr no fim do bloco (muda a ordem) e tudo no stdout (quebra quem redireciona um canal só).
- 2026-10-03 (humano, scope): variável de limite ou de timeout inválida → aviso no stderr e default. Descartado: abortar antes de rodar.
- 2026-10-03 (humano, scope): suíte sem nenhum `test-*.sh` → mensagem e exit 1. Descartado: exit 0 (suíte vazia seria falso verde no gate).
- Nomes das variáveis de ambiente: decisão de implementação (execute decide e lista para revisão; a doc cita os nomes).
- 2026-10-03 (humano, plan → reabertura de scope): /7 passa a pôr o stderr ANTES do stdout no bloco do arquivo. Motivo: stdout e stderr do arquivo chegam por canos separados e nenhum guarda a ordem entre eles; a ordem relativa exata exigiria cooperação dos testes (fora de escopo). Descartados: stderr depois do stdout (já recusado no scope), ordem aproximada (critério sem teste determinístico) e tudo no stdout (quebra quem redireciona um canal só).

## delta

- MODIFICADO (2026-10-03): suite-paralela/7 — "…na mesma ordem relativa às linhas de stdout em que o arquivo as escreveu…" → "QUANDO um arquivo escreve no stderr (ex.: linhas `FAIL:`) O SISTEMA DEVE emitir essas linhas no stderr do `run.sh`, dentro do bloco do arquivo, ANTES das linhas de stdout dele, cada canal na ordem em que o arquivo o escreveu; com `2>/dev/null`, só elas somem." Aprovado pelo humano na fase plan. Efeito visível: só no `test-carga.sh`, o FAIL passa a sair antes da linha `carga MEDIUM`.

## e2e

pendente

## feedback-reprovacao
