# Plano — memoria-integra: Memória íntegra

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** nenhum critério ou aprendizado some ao entregar ou limpar; regra única "arquivo do nó primeiro, linha do índice logo depois", sem erro transitório; aprendizados num arquivo próprio, `docs/audora/aprendizados.md`, fora do `MEMORY.md`.

**Nó do MEMORY:** `memoria-integra` (MEMORY.md; corpo em `docs/audora/memory/memoria-integra.md`)

**Arquitetura da mudança:** três frentes. (1) Hooks: `memory-validate` adia o
"arquivo sem linha no índice" para a escrita do índice; `cleanup` ganha
`criterios_sem_copia` (artefato com critério sem cópia viva vai para `## mantido`),
protege `aprendizados.md` e o tira da varredura de links. (2) Texto das skills
(scope, memory, sync, compactar, cleanup, debug) e templates: critério de HIGH no
nó, ordem nó→índice, aprendizado em arquivo próprio com template novo
`templates/aprendizados-template.md`. Os comandos do sync e do carregar-contexto
são executados pela suíte nas fixtures (texto que vira comando é testado
rodando). (3) Dogfood: este repo migra os Aprendizados pelo comando do sync na
última tarefa. Testes novos num arquivo próprio, `tests/test-memoria-integra.sh`
(roda em paralelo aos demais); testes antigos só trocam a string asserida,
sem perder linha de assert (anti-fraude do gate).

**Arquivos lidos antes de planejar:**
- `docs/audora/memory/memoria-integra.md:1-100` — critérios /1–/7, /12–/21 (/8–/11 removidos), decisões e delta; /18 reescrito nesta fase (ver Conflitos).
- `MEMORY.md:1-152` — Propósito, Constituição (gate `bash hooks/gate <id>`), índice; Aprendizados por grep; seção Aprendizados `44-101` tem 54 linhas de aprendizado (3 invalidadas) e 1 linha em branco no meio (74).
- `skills/memory/SKILL.md:1-135` — roteador; carregar-contexto passo 3 (`78-81`, comandos `grep -iE … MEMORY.md`); registrar-aprendizado (`105-116`, linha "1 linha na seção `## Aprendizados` do `MEMORY.md`" em 112); red flag "mesma edição" em 125.
- `skills/memory/references/registrar-no.md:1-21` — passo 2 (`15-17`): "NA MESMA EDIÇÃO" + "Transição de estado: nó primeiro, índice depois".
- `skills/memory/references/bootstrap.md:1-28` — passo 1 (`7-9`): "Aprendizados vazio".
- `skills/memory/references/compactar.md:1-29` — gatilho "Aprendizados > ~40" (`11-13`); 2(b) consolidar na seção (`16-17`); passo 4 `aprendizados-historico.md` (`24-27`).
- `skills/validate/references/sync.md:1-60` — passo 1 consolida aprendizados no MEMORY (`9-13`); passo 2 estado e `git mv` (`14-18`); passo 4 é citado como "passo 4" por fechamento-light (não renumerar).
- `skills/validate/references/fechamento-light.md:1-32` — cita "passo 4 do `sync.md`" (21-25).
- `skills/scope/SKILL.md:30-108` — passo 5 HIGH → spec dedicada, "nó aponta para ela" (`47-51`); bloco "Arquivos: o nó (MEDIUM) ou a spec dedicada (HIGH)" (103).
- `skills/cleanup/SKILL.md:1-100` — tabela de tipos (22-30), "Nunca entram" (32-36), red flags (84-93).
- `skills/debug/SKILL.md:45-56` — "registrar-aprendizado no `MEMORY.md`" (53).
- `hooks/memory-validate:1-141` — `escreveu_indice` (25-34); órfão "sem linha no índice mestre" sempre cobrado (91-92); divergência só na escrita do índice (101-105).
- `hooks/memory-guard:1-47` — mensagem do MEMORY > 300 cita `aprendizados-historico.md` (34); só olha `*MEMORY.md`, `*docs/audora/memory/*.md` e PRD (já sai 0 para `docs/audora/aprendizados.md`).
- `hooks/cleanup:1-542` — `carrega_indice` (56-70, `cols[2]` traz "Título → caminho" no delivered); `texto_vivo` (153-157); `ligacao` (160-167); `protegido` (170); `classifica_artefatos` (173-188, item do delivered em 179); `linhas_de_link` (232-243, pula Aprendizados do MEMORY); `relatorio` (331-344, `## mantido` fora do total); `pre_checa` (475-499, mensagem 'arquivo/ e decisões vivas nunca são removidos' em 483).
- `hooks/gate:1-60` — anti-fraude 3 soma linhas `assert_*|ok|ko` de todos os `tests/test-*.sh` vs HEAD.
- `hooks/hooks.json:1-37` — guard e validate em PostToolUse Edit|Write.
- `templates/MEMORY-template.md:1-70` — seção Aprendizados com texto + exemplo (28-36); regras 1 "NA MESMA EDIÇÃO" (50-52), 2 grep no MEMORY (56-57), 3 consolidar aqui (58-59), 4 teto ~40 + histórico (64-66).
- `templates/no-template.md:1-71` — comentário "(mesma edição)" (22).
- `templates/plano-template.md:1-49`, `templates/bloco-fechamento-template.md:1-223` — formato do plano e do bloco.
- `tests/lib.sh:1-21` — `assert_*`, `run_hook`, `$SP`, `report`.
- `tests/test-memory-validate.sh:1-91` — `mk`/`no` (4-8); órfão via MEMORY (17-18).
- `tests/test-memory-guard.sh:1-17` — formato dos casos do guard.
- `tests/test-templates.sh:1-32` — `/6` asserta `'| <fase> | <aprendizado'` no MEMORY-template (11).
- `tests/test-skills.sh:20-100,140-192` — compactar cita `aprendizados-historico.md` (49-50); roteador cita `'| <fase> |'` (60); registrar-no e sync citam 'nó primeiro, índice depois' (189-190); sync cita 'aprendizados' (76).
- `tests/test-leitura-por-secao.sh:1-138` — extrai os comandos do carregar-contexto por `cmds 'grep -iE'` (40-47) e roda em fixture; recorte do repo comparado com a seção do MEMORY (89-93); guarda BASE 53227 (129).
- `tests/test-parada-revisao.sh:50-100` — guarda BASE 53227 (59); sync precisa manter 'nó primeiro, índice depois' (86).
- `tests/test-prd-foto.sh:50-80` — frases do sync que não podem sumir (56-75).
- `tests/test-carga.sh:1-23` — BASE/FULL e tetos 54900/63000; nota de medição (6-7). Medido hoje: base=53227 full=61147.
- `tests/test-corte-sem-uso.sh:10-22` — skills/templates sem 'autopilot|motor|…|antecipad|elegív'; scope sem 'Exceção'.
- `tests/test-dogfood.sh:1-16` — MEMORY do repo válido.
- `tests/test-skill-cleanup.sh:1-120,530-560,580-615,670-710` — `mkproj`/`addc`/`sumiu`/`runc`/`snap`/`secao`/`lote_de` (helpers locais); recusa de protegido com a mensagem antiga (541-542); Aprendizados fora da varredura (583-605); frases da skill (690-697, inclui 'fora da seção Aprendizados').
- `README.md:130-140,164-170,206-210,249-253,280-282,315-319,337-349`, `README.pt-BR.md:130-140,164-170,206-210,249-253,281-283,316-318,337-347`, `docs/fundamentos.md:26-52,125-155` — onde a doc diz "aprendizado no MEMORY" e "HIGH → spec dedicada".

**Conflitos MEMORY vs código encontrados:** 1 — /18 pedia provar as linhas de aprendizado `[invalidado-em:` de uma ferramenta já removida em `docs/audora/aprendizados.md`, mas o commit 75add24 (faxina-restos, delivered) já as apagou e `faxina-restos/2` exige a busca pelo nome dela vazia. Humano decidiu (2026-10-08): tirar tudo sobre isso da memória; /18 ficou "MEMORY sem aprendizado, todos em `docs/audora/aprendizados.md`, e a suíte DEVE provar isso" (decisão + delta MODIFICADO no nó).

## Decisões tomadas pela IA

- T4 (execute): o comando de contagem do sync usa `grep -cE '(^|[^[:alnum:]_-])<id>/[0-9]+'` em vez de `'<id>/[0-9]+'` — sem borda à esquerda, `z/[0-9]+` casa `zz/1` e a asserção "nó só com `zz/1` → 0" do próprio plano falharia.
- T5 (execute): a fixture `mkt11` de `tests/test-skill-cleanup.sh` cita `(d/1..2)` no plano arquivado sem critério no nó — com /4 o plano ia para `## mantido` e quebrava `cleanup-lote-encadeado/1,3`. O nó arquivado da fixture ganhou `- **d/1** — …` (nó real tem critério); nenhum assert mudou. O "nada muda lá" do plano estava errado.

## Notas de sessão

- **Antes da T1**: os artefatos do scope e do plano ainda não estão commitados
  (`MEMORY.md` com a linha do nó, das irmãs e 1 aprendizado; o nó; este plano).
  Commit próprio: `git add MEMORY.md docs/audora/memory/memoria-integra.md docs/audora/planos/plano-memoria-integra.md && git commit -m "docs(memoria-integra): escopo e plano"`.
- **Nó no teto**: `docs/audora/memory/memoria-integra.md` tem 100 linhas (teto
  ~100). Qualquer linha nova no nó → antes, compactar (skill memory, operação
  compactar, passo 4: histórico frio para `memoria-integra-historico.md`).
- **Regra de carga BASE** (vale para as tarefas marcadas "carga BASE"): depois
  do green, `bash tests/test-carga.sh` → anotar `base=B`. Seja `G` o número em
  `tests/test-parada-revisao.sh:59` (hoje 53227). Se `B > G`:
  `sed -i "/-le $G \]/s/$G/$B/g" tests/test-parada-revisao.sh tests/test-leitura-por-secao.sh`
  e acrescentar ` memoria-integra/<n>: BASE G → B.` ao fim da linha 7 de
  `tests/test-carga.sh`, no MESMO commit. `B > 54900` → PARAR e levar ao humano.
- **Regra de carga FULL** (tarefas marcadas "carga FULL"): `full` de
  `bash tests/test-carga.sh` > 63000 → PARAR e levar ao humano.
- **Prosa nova** em skills/templates: nunca as palavras do guarda corte-sem-uso/6
  (motor, autopilot, antecipad…, elegív…) nem "Exceção" no scope.
- **Fixture com caminho `docs/audora/…`** neste plano ou no relatório: só dentro
  de bloco de código (aprendizado 2026-10-03), senão a cleanup acusa
  `## nunca existiu`.
- **validate 2026-10-08**: gate passou; e2e 17/17 passou
  (`docs/audora/e2e/e2e-memoria-integra.md`). Os dois bloqueantes abaixo
  viraram as Tarefas 14 e 15, por decisão do humano no portão. Depois delas,
  a próxima validate refaz no e2e os cenários `sync`/`sync0`/`limpa` (/2,
  /3, /4, /16) com o nó no formato antigo e o `aprendizados.md` sem newline
  final.
- **revisão adversarial: passagem 1** (2026-10-08):
  - Bloqueante 1, classe (b) `memoria-integra/2` + (c). A contagem do sync
    (`sync.md:21`) e a `criterios_sem_copia` (`hooks/cleanup:175`) contam a
    simples menção a `<id>/<n>`. Nó HIGH no formato antigo cita o intervalo
    na linha de ponteiro (`limpeza-codigo-morto/1..9`, em 6 dos 7 arquivados
    daqui que apontam para spec). Resultado: contagem 1, a cópia não
    acontece, e a cleanup põe a spec no lote e a apaga. Prova conferida:
    `awk … 2026-09-27-limpeza-codigo-morto.md | grep -cE …` → 1, com 0
    linhas `- **<id>/<n>**`. Estado: aberto, vai para a Tarefa 14.
  - Bloqueante 2, classe (b) `memoria-integra/16` + (c). Com
    `aprendizados.md` sem newline final, o `>>` do `sync.md:17` gruda a
    linha nova na última linha. Prova conferida: `cat -A` →
    `- 2026-01-01 | plan | X1 antigo- 2026-02-01 | plan | M1 novo$`, e
    `grep -c '^- 2026'` → 1. Estado: aberto, vai para a Tarefa 15.
  - Ressalvas (não bloqueiam, vão ao roteiro):
    - critério com ponto (`x/1.1` × `x/1.2`) é comparado só pelo inteiro;
    - plano não arquivado de nó delivered cai em "sem referência" sem passar
      pelo /4;
    - `aplicar` com lote à mão não reconfere o /4;
    - o fallback sem seta pega o arquivado mais antigo do id;
    - o move do /16 não é idempotente se o sync for interrompido;
    - o move do /16 só leva linhas de 1 linha;
    - `skills/memory/SKILL.md:15` ainda lista "Aprendizados" no índice;
    - id de 10 caracteres só de dígito e hífen casaria o grep do /15.

---

## Tarefa 1: memory-validate adia o órfão para a escrita do índice

- **depende-de**: []
- **requisito**: `memoria-integra/5` — QUANDO o arquivo de um nó novo é escrito antes da linha dele no índice O SISTEMA DEVE (`memory-validate`) não acusar erro. · `memoria-integra/6` — QUANDO o `MEMORY.md` é escrito e há arquivo em `docs/audora/memory/` sem linha no índice O SISTEMA DEVE (`memory-validate`) acusar o erro com exit 2, como hoje.
- **decisões relevantes**: "nó primeiro, índice depois" ao criar e transicionar (nó, 2026-10-08). Só o órfão é adiado; enum, estado ausente, depende-de inexistente e ciclo continuam cobrados na escrita do nó.
- **interfaces**: consome `escreveu_indice` (`hooks/memory-validate:27-29`) · produz nada novo.
- **ponto de mudança**: `hooks/memory-validate:91-92` — o `grep -qx "$b" || erros=…sem linha no índice mestre` passa a rodar só com `escreveu_indice -eq 1`; comentários `:3-6` e `:25-26` passam a dizer que órfão e divergência são cobrados só na escrita do índice.
- **teste**: `tests/test-memoria-integra.sh` (NOVO; cabeçalho `# memoria-integra/1..21 — …`, `source lib.sh`, helpers `mk`/`no` copiados de `tests/test-memory-validate.sh:4-8`, `report` no fim) — casos "memoria-integra/5 …" e "memoria-integra/6 …".
- **asserções**:
  - fixture `n5`: índice `- x | in-progress | X | r | k | —` + nó `x` in-progress + nó `novo` planned SEM linha; `run_hook memory-validate <n5>/docs/audora/memory/novo.md` → `code 0`, `out` vazio.
  - mesma fixture com `novo` em `in-progress` (nó novo já ativo) → `code 0`, `out` vazio.
  - nó `novo` sem linha E com `estado: planejado` → escrita do nó → `code 2`, `out` contém `'planejado'` e NÃO contém `sem linha no índice` (só o órfão é adiado).
  - `run_hook memory-validate <n5>/MEMORY.md` → `code 2`, `out` contém `novo.md sem linha no índice mestre`.
- **ler**: `hooks/memory-validate:84-118`, `tests/test-memory-validate.sh:1-20`
- **done quando**: os 4 casos passam e `tests/test-memory-validate.sh` segue verde.

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/5 … → 0" (hoje sai 2 com "sem linha no índice mestre")
- [x] **green** — `bash tests/test-memoria-integra.sh` passa; `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add hooks/memory-validate tests/test-memoria-integra.sh && git commit -m "fix(memoria-integra/5): memory-validate cobra no orfao so na escrita do indice"`

## Tarefa 2: regra única "arquivo do nó primeiro, linha do índice logo depois"

- **depende-de**: [Tarefa 1]
- **requisito**: `memoria-integra/7` — QUANDO a skill memory e suas references descrevem a escrita de nó (criação e transição) O SISTEMA DEVE trazer só a regra "arquivo do nó primeiro, linha do índice logo depois", sem "mesma edição".
- **decisões relevantes**: ordem vale para criar e transicionar (nó, 2026-10-08). Os dois templates que a skill memory aplica (`MEMORY-template.md`, `no-template.md`) entram junto (decisão da IA: senão a regra velha volta pelo bootstrap).
- **interfaces**: frase canônica `arquivo do nó primeiro, linha do índice logo depois`.
- **ponto de mudança**:
  - `skills/memory/references/registrar-no.md:15-17` — passo 2 vira: "Escrever o arquivo do nó primeiro, linha do índice logo depois — na criação e na transição de estado (resumo/keywords espelhados). O `memory-validate` cobra índice↔pasta (nó sem linha, estado divergente) só na escrita do índice: índice e pasta divergentes depois dela = memória inconsistente → PARAR e corrigir."
  - `skills/memory/SKILL.md:125` — red flag vira `| "Atualizo a linha do índice no fim da fase" | Índice atrasado quebra a carga de todo mundo. Arquivo do nó primeiro, linha do índice logo depois. |`
  - `templates/MEMORY-template.md:50-52` — regra 1: "Arquivo do nó primeiro, linha do índice logo depois (criação e transição) — índice e pasta divergentes depois da linha = memória inconsistente, PARAR (hook memory-validate acusa na escrita do índice; sem hook, a skill verifica)."
  - `templates/no-template.md:22` — "(mesma edição)" → "(arquivo do nó primeiro, linha do índice logo depois)".
  - `tests/test-skills.sh:189` — string asserida em registrar-no: `'nó primeiro, índice depois'` → `'arquivo do nó primeiro, linha do índice logo depois'` (mesma linha, mesmo rótulo).
- **teste**: `tests/test-memoria-integra.sh` — caso "memoria-integra/7 …"
- **asserções**:
  - `grep -rilF 'mesma edição' skills/memory templates/MEMORY-template.md templates/no-template.md` → vazio.
  - texto achatado (sem `\r`, quebras de linha → espaço, espaços colapsados) de `skills/memory/references/registrar-no.md` contém `arquivo do nó primeiro, linha do índice logo depois — na criação e na transição de estado`.
  - achatado de `skills/memory/SKILL.md` contém `Arquivo do nó primeiro, linha do índice logo depois.`; de `templates/MEMORY-template.md` contém `Arquivo do nó primeiro, linha do índice logo depois (criação e transição)`.
- **ler**: `skills/memory/references/registrar-no.md:1-21`, `skills/memory/SKILL.md:118-130`, `templates/MEMORY-template.md:46-70`, `templates/no-template.md:14-23`, `tests/test-skills.sh:186-191`
- **done quando**: casos verdes, `tests/test-skills.sh` verde, carga BASE dentro da regra.
- **carga BASE**: sim (memory SKILL, registrar-no, no-template).

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/7 sem 'mesma edição'" (acha registrar-no, SKILL, 2 templates)
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0; regra de carga BASE aplicada
- [x] **commit** — `git add skills/memory/SKILL.md skills/memory/references/registrar-no.md templates/MEMORY-template.md templates/no-template.md tests/test-skills.sh tests/test-memoria-integra.sh tests/test-carga.sh tests/test-parada-revisao.sh tests/test-leitura-por-secao.sh && git commit -m "docs(memoria-integra/7): regra unica arquivo do no primeiro, linha do indice logo depois"`

## Tarefa 3: scope grava critérios de HIGH no nó; spec só contexto

- **depende-de**: [Tarefa 2]
- **requisito**: `memoria-integra/1` — QUANDO a fase scope fecha uma demanda HIGH O SISTEMA DEVE gravar os critérios numerados em `## criterios-aceite` do nó, e a spec dedicada, se criada, DEVE conter só contexto, sem critérios.
- **decisões relevantes**: critérios de HIGH sempre no nó; spec só contexto (nó, 2026-10-08). Docs (READMEs, fundamentos) ficam na Tarefa 12.
- **interfaces**: nenhuma.
- **ponto de mudança**: `skills/scope/SKILL.md:49-51` — os dois bullets viram:
  "- MEDIUM e HIGH: os três campos direto no nó, critérios numerados em `## criterios-aceite`." e
  "- HIGH pode ter spec dedicada `docs/audora/specs/<id>-escopo.md` só com contexto (pesquisa, alternativas, diagramas) — nunca critério."
  `skills/scope/SKILL.md:103` — "**Arquivos**: o nó, a spec de contexto (HIGH, se houver) e a linha do índice."
- **teste**: `tests/test-memoria-integra.sh` — caso "memoria-integra/1 …"
- **asserções** (achatado de `skills/scope/SKILL.md`):
  - contém `MEDIUM e HIGH: os três campos direto no nó, critérios numerados em \`## criterios-aceite\``
  - contém `só com contexto (pesquisa, alternativas, diagramas) — nunca critério`
  - não contém `nó aponta para ela`; não contém `ou a spec dedicada (HIGH)`
- **ler**: `skills/scope/SKILL.md:41-64,95-108`
- **done quando**: casos verdes; `tests/test-corte-sem-uso.sh` e `tests/test-skills.sh` verdes; carga BASE na regra.
- **carga BASE**: sim (scope SKILL).

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/1 critérios no nó"
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0; regra de carga BASE aplicada
- [x] **commit** — `git add skills/scope/SKILL.md tests/test-memoria-integra.sh tests/test-carga.sh tests/test-parada-revisao.sh tests/test-leitura-por-secao.sh && git commit -m "docs(memoria-integra/1): scope grava criterios de HIGH no no, spec so contexto"`

## Tarefa 4: sync copia critérios da spec e para sem critério

- **depende-de**: [Tarefa 1]
- **requisito**: `memoria-integra/2` — QUANDO o sync vai arquivar um nó sem critério numerado e `docs/audora/specs/<id>-escopo.md` tem critérios `<id>/<n>` O SISTEMA DEVE copiá-los literalmente para o nó antes do `git mv`. · `memoria-integra/3` — QUANDO o sync vai arquivar um nó que, depois do /2, segue sem critério numerado O SISTEMA DEVE parar sem arquivar e avisar o humano nomeando o nó.
- **decisões relevantes**: não reparar arquivados (fora-de-escopo). Não renumerar o sync: fechamento-light cita "passo 4" — o texto novo é a abertura do passo 2.
- **interfaces**: produz o comando literal (em crase no `sync.md`) `` `awk '/^## criterios-aceite/{f=1;next} /^## /{f=0} f' docs/audora/memory/<id>.md | grep -cE '<id>/[0-9]+'` `` (conta critérios do nó) e a mensagem `Nó <id> sem critério numerado — sync parado, nada arquivado.`
- **ponto de mudança**: `skills/validate/references/sync.md:14` — passo 2 abre com: "**Antes do `git mv`**: conte os critérios do nó com `<comando acima>`. Zero e a spec `docs/audora/specs/<id>-escopo.md` tem critério `<id>/<n>` → copie literalmente cada um (a linha e suas continuações) para `## criterios-aceite` do nó. Segue zero → PARE sem arquivar e avise o humano: \"Nó <id> sem critério numerado — sync parado, nada arquivado.\"" — o resto do passo 2 fica igual (inclui "nó primeiro, índice depois").
- **teste**: `tests/test-memoria-integra.sh` — casos "memoria-integra/2 …", "memoria-integra/3 …"
- **asserções**:
  - achatado de `sync.md` contém `Antes do \`git mv\``, `copie literalmente cada um (a linha e suas continuações) para \`## criterios-aceite\` do nó` e `Nó <id> sem critério numerado — sync parado, nada arquivado.`; e ainda contém `nó primeiro, índice depois`.
  - comando extraído do `sync.md` (trecho em crase que começa com `awk '/^## criterios-aceite/`), `<id>` → `z`, rodado na fixture: nó `z` com `- **z/1** — …` e `- **z/2** — …` em `## criterios-aceite` → `2`; nó `z` com critérios vazios e `z/3` só em `## delta` → `0`; nó `z` só com `zz/1` nos critérios → `0`.
- **ler**: `skills/validate/references/sync.md:1-33`, `skills/validate/references/fechamento-light.md:20-25`
- **done quando**: casos verdes; `tests/test-prd-foto.sh`, `tests/test-parada-revisao.sh`, `tests/test-skills.sh` verdes; carga FULL na regra.
- **carga FULL**: sim (sync.md).

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/2 sync: Antes do git mv"
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add skills/validate/references/sync.md tests/test-memoria-integra.sh && git commit -m "docs(memoria-integra/2): sync copia criterios da spec e para no sem criterio"`

## Tarefa 5: cleanup mantém artefato com critério sem cópia no nó arquivado

- **depende-de**: [Tarefa 1]
- **requisito**: `memoria-integra/4` — QUANDO a varredura da cleanup encontra spec, plano arquivado ou relatório e2e de nó delivered que cita critério `<id>/<n>` ausente do nó arquivado O SISTEMA DEVE deixá-lo fora do lote, em `## mantido`, com o motivo.
- **decisões relevantes**: plano arquivado e relatório e2e de entregue seguem saindo, salvo se citam critério ausente (nó, 2026-10-08). Decisões da IA: "nó arquivado" = caminho após `→` na linha do índice; sem seta, o 1º de `docs/audora/arquivo/*-<id>.md` em ordem; o irmão `-historico.md`, se existir, conta como parte do nó. Token de critério: `<id>/<n>` sem letra, dígito, `_` ou `-` antes e sem dígito depois (`d/1` não casa `dd/1` nem `d/10`).
- **interfaces**: produz `criterios_sem_copia($arquivo, $id)` → lista de `"<id>/<n>"` citados no arquivo e ausentes do nó arquivado, sem repetição, em ordem numérica de `<n>`. Consome `@INDICE` (`hooks/cleanup:56-70`) e `ler` (`:49-53`).
- **ponto de mudança**: `hooks/cleanup:179` — no ramo `$tipo && $e eq 'delivered'`: lista não vazia → `push @MANTIDO, "- $f | mantido: cita <lista separada por ', '> sem cópia no nó arquivado"` e `next`; vazia → `item(...)` como hoje. Sub nova logo antes de `classifica_artefatos` (`:172`). `skills/cleanup/SKILL.md:34` — `## mantido` ganha: "e spec, plano arquivado ou relatório e2e que cita critério `<id>/<n>` sem cópia no nó arquivado".
- **teste**: `tests/test-memoria-integra.sh` — casos "memoria-integra/4 …" (fixture git própria: copiar `mkproj`, `addc`, `runc`, `snap`, `secao`, `assert_line` de `tests/test-skill-cleanup.sh:12-37,76-79`).
- **asserções** — fixture (todos os caminhos sob a pasta da fixture):
  ```text
  MEMORY: - d | delivered | D → docs/audora/arquivo/2026-01-01-d.md
  docs/audora/arquivo/2026-01-01-d.md      contém "- **d/1** — QUANDO x O SISTEMA DEVE y"
  docs/audora/specs/d-escopo.md            cita d/1 e d/2
  docs/audora/planos/arquivo/plano-d.md    cita só d/1
  docs/audora/e2e/e2e-d.md                 cita d/10, d/3, d/2, d/3, dd/7
  ```
  - `varrer` → estas linhas exatas, nas seções indicadas (e2e: dedupe, ordem numérica, sem `dd/7`); `contar` → `1`:
    ```text
    ## plano arquivado
    - docs/audora/planos/arquivo/plano-d.md | nó d delivered
    ## mantido
    - docs/audora/e2e/e2e-d.md | mantido: cita d/2, d/3, d/10 sem cópia no nó arquivado
    - docs/audora/specs/d-escopo.md | mantido: cita d/2 sem cópia no nó arquivado
    total: 1 item(ns) no lote
    ```
  - spec sem nenhum `d/<n>` → segue no lote (`- … | nó d delivered`), como hoje
  - linha do índice aponta arquivo que não existe e não há `*-d.md` em `arquivo/` → spec que cita `d/1` vai para `## mantido` com `cita d/1`
  - `d/2` só no irmão `2026-01-01-d-historico.md` → spec que cita `d/2` volta ao lote
  - `varrer` não altera nada (`snap` igual antes/depois)
- **ler**: `hooks/cleanup:44-70,121-188,329-346`, `tests/test-skill-cleanup.sh:12-37,74-117`
- **done quando**: casos verdes; `tests/test-skill-cleanup.sh` inteiro verde (suas fixtures não citam critério, nada muda lá).

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/4 spec com d/2 em mantido"
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add hooks/cleanup skills/cleanup/SKILL.md tests/test-memoria-integra.sh && git commit -m "fix(memoria-integra/4): cleanup mantem artefato com criterio sem copia no no arquivado"`

## Tarefa 6: cleanup nunca remove arquivo que o framework lê; princípio na skill

- **depende-de**: [Tarefa 5]
- **requisito**: `memoria-integra/12` — QUANDO a cleanup monta ou aplica um lote O SISTEMA DEVE deixar fora dele todo arquivo que o framework lê (`MEMORY.md`, nós vivos e arquivados, `decisoes-vivas.md`, `aprendizados.md`), e o `aplicar` DEVE recusar lote à mão que traga algum deles, sem alterar nada. · `memoria-integra/13` — QUANDO a skill cleanup descreve o que apaga O SISTEMA DEVE declarar o princípio "só sai o que não é mais usado: nunca arquivo que o framework lê nem conteúdo que afeta aprendizado ou critério sem outra cópia viva", com red flag correspondente.
- **decisões relevantes**: /12 vale para itens que removem arquivo pelo caminho; planned órfão aprovado segue apagando o próprio nó (nó, 2026-10-08). `MEMORY.md` já cai em `fora de docs/audora/` (mantido).
- **interfaces**: `protegido($caminho)` passa a cobrir também `docs/audora/aprendizados.md`; mensagem nova `arquivo lido pelo framework nunca é removido`.
- **ponto de mudança**: `hooks/cleanup:169-170` (comentário + `protegido`), `hooks/cleanup:483` (mensagem); `tests/test-skill-cleanup.sh:541-542` — a mensagem esperada dos 2 casos troca para `arquivo lido pelo framework nunca é removido` (mesmas linhas). `skills/cleanup/SKILL.md:32-33` — "Nunca entram" vira: "Nunca entram — o framework os lê: `MEMORY.md`, nós (`docs/audora/memory/`, `docs/audora/arquivo/`), `docs/audora/decisoes-vivas.md` e `docs/audora/aprendizados.md`; nem arquivo fora de `docs/audora/`. O `aplicar` recusa lote à mão que traga algum deles, sem alterar nada; planned órfão aprovado segue apagando o próprio nó." Logo abaixo da Lei de Ferro (`:10`): "**Princípio**: só sai o que não é mais usado: nunca arquivo que o framework lê nem conteúdo que afeta aprendizado ou critério sem outra cópia viva." Red flag nova em `:84-93`: `| "Ninguém mais abre isso, pode sair" | Só sai o que não é mais usado. Arquivo que o framework lê, ou critério/aprendizado sem outra cópia viva, fica. |`
- **teste**: `tests/test-memoria-integra.sh` — casos "memoria-integra/12 …", "memoria-integra/13 …" (lote à mão: copiar `lote_de` de `tests/test-skill-cleanup.sh`).
- **asserções** — fixture `mkproj` + aprendizados versionado e um nó vivo `v` versionado:
  - `varrer` → saída não contém `aprendizados.md` (nem em `## sem referência`)
  - lote `## sem referência` com `- docs/audora/aprendizados.md | x` depois de um item válido → `aplicar` exit 1, saída contém `cleanup: falhou em: - docs/audora/aprendizados.md | x — arquivo lido pelo framework nunca é removido`; `snap` igual
  - idem com o arquivo do nó vivo `v` (pasta `memory/` da fixture) sob `## spec de nó entregue` → mesma mensagem, `snap` igual
  - idem com `- MEMORY.md | x` sob `## plano arquivado` → `— fora de docs/audora/`, `snap` igual
  - skill achatada contém `só sai o que não é mais usado: nunca arquivo que o framework lê nem conteúdo que afeta aprendizado ou critério sem outra cópia viva`; linha da tabela de red flags contém `sem outra cópia viva`; contém `planned órfão aprovado segue apagando o próprio nó`
- **ler**: `hooks/cleanup:169-170,474-499`, `skills/cleanup/SKILL.md:1-40,84-93`, `tests/test-skill-cleanup.sh:500-560`
- **done quando**: casos verdes; `tests/test-skill-cleanup.sh` verde com as 2 strings trocadas; SKILL.md ≤ 250 linhas.

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/12 aplicar recusa aprendizados.md"
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add hooks/cleanup skills/cleanup/SKILL.md tests/test-skill-cleanup.sh tests/test-memoria-integra.sh && git commit -m "fix(memoria-integra/12): cleanup nunca remove arquivo que o framework le"`

## Tarefa 7: cleanup ignora `docs/audora/aprendizados.md` na varredura de links

- **depende-de**: [Tarefa 6]
- **requisito**: `memoria-integra/19` — QUANDO a cleanup varre links O SISTEMA DEVE ignorar `docs/audora/aprendizados.md` como hoje ignora a seção Aprendizados do `MEMORY.md`.
- **decisões relevantes**: decisão da IA: `docs/audora/aprendizados.md` entra em `texto_vivo` (hoje a seção Aprendizados conta como documento vivo dentro do `MEMORY.md`; sem isso, arquivo citado só por aprendizado viraria "sem referência" depois da migração).
- **interfaces**: `linhas_de_link(\@linhas, $arquivo)` devolve `()` para `docs/audora/aprendizados.md` — vale para `links`, `%REF` e `troca_links`.
- **ponto de mudança**: `hooks/cleanup:230-233` (comentário + retorno vazio no topo de `linhas_de_link`); `hooks/cleanup:152-155` (`texto_vivo` inclui o arquivo); `skills/cleanup/SKILL.md:30` — "(fora da seção Aprendizados)" → "(fora da seção Aprendizados e de `docs/audora/aprendizados.md`)".
- **teste**: `tests/test-memoria-integra.sh` — casos "memoria-integra/19 …"
- **asserções** — fixture `mkproj`, `sumiu` de um spec velho, aprendizados versionado com link para ele, para um caminho nunca versionado e citando uma nota:
  ```text
  docs/audora/aprendizados.md: "- 2026-01-01 | execute | ver [v](specs/velha.md), `docs/audora/x/nunca.md` e notas/n.md"
  docs/audora/notas/n.md: citado só por aprendizados.md
  ```
  - `varrer` → exatamente `cleanup: nada a limpar` (sem `## link quebrado`, sem `## nunca existiu`, `notas/n.md` fora de `## sem referência`)
  - com spec `d-escopo.md` de nó delivered também citada por aprendizados.md: lote do `varrer` → `aplicar` exit 0; aprendizados.md byte-igual ao `HEAD~1`; `git show --name-only HEAD` sem `aprendizados.md`
  - skill contém `fora da seção Aprendizados e de \`docs/audora/aprendizados.md\``
- **ler**: `hooks/cleanup:150-157,228-267,383-392`, `tests/test-skill-cleanup.sh:580-605`
- **done quando**: casos verdes; `tests/test-skill-cleanup.sh` verde.

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/19 varrer → nada a limpar"
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add hooks/cleanup skills/cleanup/SKILL.md tests/test-memoria-integra.sh && git commit -m "fix(memoria-integra/19): cleanup ignora aprendizados.md na varredura de links"`

## Tarefa 8: aprendizado vive em `docs/audora/aprendizados.md`; bootstrap só com ponteiro

- **depende-de**: [Tarefa 2]
- **requisito**: `memoria-integra/14` — QUANDO uma fase registra um aprendizado O SISTEMA DEVE gravar a linha em `docs/audora/aprendizados.md`, criando o arquivo se não existir, e nunca no `MEMORY.md`. · `memoria-integra/17` — QUANDO o bootstrap cria o `MEMORY.md` O SISTEMA DEVE deixar a seção Aprendizados só com a linha de ponteiro, sem criar `docs/audora/aprendizados.md`.
- **decisões relevantes**: arquivo nasce no 1º aprendizado; consulta por grep (nó, 2026-10-08). Decisão da IA: schema do arquivo em template novo (Constituição: schemas só em `templates/`); o formato `- AAAA-MM-DD | <fase> | …` sai do MEMORY-template e vai para ele.
- **interfaces**: produz `templates/aprendizados-template.md` = linha 1 `# Aprendizados`, depois 1 bloco de citação (`> `) dizendo o que é aprendizado, "NA HORA por qualquer fase (skill memory, registrar-aprendizado)", o formato `` `- AAAA-MM-DD | <fase> | <aprendizado em 1 frase>` ``, "1 linha no fim do arquivo; consulta só por grep" e a regra `[invalidado-em: AAAA-MM-DD] [substituido-por: <linha nova>]`; nenhuma linha de aprendizado de exemplo. Produz a linha de ponteiro **P** = ``Aprendizados vivem em `docs/audora/aprendizados.md` (1 linha cada, só por grep — skill memory, registrar-aprendizado).``
- **ponto de mudança**:
  - `templates/MEMORY-template.md:28-36` — seção vira cabeçalho + linha em branco + P + linha em branco.
  - `skills/memory/SKILL.md:111-116` — passo 2: "… 1 linha no fim de `docs/audora/aprendizados.md` (sem o arquivo, crie-o por `templates/aprendizados-template.md`), nunca no `MEMORY.md`: `- AAAA-MM-DD | <fase> | <aprendizado em 1 frase>` (grep-ável)."; passo 3: `grep -si '<termo>' docs/audora/aprendizados.md MEMORY.md`.
  - `skills/memory/references/bootstrap.md:9` — "Aprendizados vazio" → "seção Aprendizados só com a linha de ponteiro do template, sem criar `docs/audora/aprendizados.md` (nasce no 1º aprendizado)".
  - `tests/test-templates.sh:11` — mesmo assert, alvo trocado: `assert_contains "$(cat templates/aprendizados-template.md 2>/dev/null)" '| <fase> | <aprendizado' "/6 formato de aprendizado"`.
- **teste**: `tests/test-memoria-integra.sh` — casos "memoria-integra/14 …", "memoria-integra/17 …"
- **asserções**:
  - achatado da operação 5 de `skills/memory/SKILL.md` (awk de `### 5.` até o próximo `## `) contém `1 linha no fim de \`docs/audora/aprendizados.md\` (sem o arquivo, crie-o por \`templates/aprendizados-template.md\`), nunca no \`MEMORY.md\``; não contém `1 linha na seção \`## Aprendizados\` do \`MEMORY.md\``
  - linhas não vazias da seção Aprendizados de `templates/MEMORY-template.md` (awk entre `## Aprendizados` e o próximo `## `) → exatamente 1, igual a P
  - `templates/aprendizados-template.md` existe; linha 1 = `# Aprendizados`; contém `` `- AAAA-MM-DD | <fase> | <aprendizado em 1 frase>` ``; `grep -cE '^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| '` → `0`
  - achatado de `bootstrap.md` contém `seção Aprendizados só com a linha de ponteiro do template, sem criar \`docs/audora/aprendizados.md\``
  - bootstrap simulado: copiar o template para uma pasta vazia como `MEMORY.md` → `run_hook memory-validate` → `0`; nenhum arquivo `docs/audora/aprendizados.md` criado
- **ler**: `skills/memory/SKILL.md:105-117`, `templates/MEMORY-template.md:26-40`, `skills/memory/references/bootstrap.md:1-12`, `tests/test-templates.sh:1-12`, `tests/test-leitura-por-secao.sh:32-35`
- **done quando**: casos verdes; `tests/test-templates.sh`, `tests/test-skills.sh` (`'| <fase> |'` no roteador) e `tests/test-leitura-por-secao.sh` (cabeçalho `## Aprendizados [carga: sempre]` no template) verdes; carga BASE na regra.
- **carga BASE**: sim (memory SKILL).

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/14 registrar-aprendizado grava em aprendizados.md"
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0; regra de carga BASE aplicada
- [x] **commit** — `git add templates/aprendizados-template.md templates/MEMORY-template.md skills/memory/SKILL.md skills/memory/references/bootstrap.md tests/test-templates.sh tests/test-memoria-integra.sh tests/test-carga.sh tests/test-parada-revisao.sh tests/test-leitura-por-secao.sh && git commit -m "feat(memoria-integra/14): aprendizado em docs/audora/aprendizados.md, bootstrap so com ponteiro"`

## Tarefa 9: carregar-contexto busca nos dois arquivos, sem erro

- **depende-de**: [Tarefa 8]
- **requisito**: `memoria-integra/15` — QUANDO uma fase carrega contexto O SISTEMA DEVE buscar aprendizados por grep em `docs/audora/aprendizados.md` e também no `MEMORY.md` enquanto ele tiver linha de aprendizado, sem `[invalidado-em:`; sem nenhum dos dois, seguir sem aprendizados e sem erro.
- **decisões relevantes**: MEMORY antigo migra no próximo sync (nó, 2026-10-08) — até lá a busca lê os dois.
- **interfaces**: os 2 comandos literais do passo 3 passam a ser
  `grep -shiE '^- [0-9-]{10} \| .*(<termo>|<termo>)' docs/audora/aprendizados.md MEMORY.md | grep -vF '[invalidado-em:'` (porta) e
  `grep -shiE '^- [0-9-]{10} \| (<fase> \||.*(<termo>|<termo>))' docs/audora/aprendizados.md MEMORY.md | grep -vF '[invalidado-em:'` (demais fases). `-s` cala arquivo ausente; `-h` tira o prefixo de nome.
- **ponto de mudança**: `skills/memory/SKILL.md:78-81` — passo 3: "Aprendizados só por busca em `docs/audora/aprendizados.md` e no `MEMORY.md` (enquanto ele tiver linha de aprendizado); `[invalidado-em:` nunca entra; nada casou → seguir sem aprendizados, sem ler a seção; arquivo ausente não é erro (`-s`):" + os 2 comandos. `tests/test-leitura-por-secao.sh:42-43` — `cmds 'grep -iE'` → `cmds 'grep -shiE'` (mesmas linhas); `:90` — `sec_apr` passa a ser as linhas de aprendizado de `docs/audora/aprendizados.md` e `MEMORY.md` juntas (`cat … 2>/dev/null | tr -d '\r' | grep -E '^- [0-9-]{10} \|'`), para o recorte seguir menor que o total depois da migração da Tarefa 13.
- **teste**: `tests/test-memoria-integra.sh` — casos "memoria-integra/15 …" (extrair os comandos do passo 3 como `tests/test-leitura-por-secao.sh:39-48`)
- **asserções** — fixtures (ids no 3º campo, como em leitura-por-secao):
  ```text
  fa: MEMORY só com a linha de ponteiro; aprendizados.md com
      - 2026-01-01 | plan | A1 cache
      - 2026-01-02 | plan | A2 nada
      - 2026-01-03 | plan | A3 cache [invalidado-em: 2026-02-01] [substituido-por: A1]
  fb: aprendizados.md com A1; seção Aprendizados do MEMORY com
      - 2026-01-04 | execute | M1 cache
  fc: MEMORY só com a linha de ponteiro; sem aprendizados.md
  ```
  - `fa`, fase `plan`, termos `cache|deploy` → ids `A1 A2` (A2 casa só pela fase); porta `cache|deploy` → `A1`; nenhuma saída contém `A3`
  - `fb`, fase `execute`, termos `cache` → `A1 M1` (aprendizados.md primeiro, depois MEMORY)
  - `fc`, os dois comandos com stdout+stderr juntos (`2>&1`) → `''`
  - `fa` em CRLF (perl `s/\n/\r\n/`) → mesmos ids
  - texto do passo 3 contém `nada casou → seguir sem aprendizados, sem ler a seção` (leitura-por-secao/5 intacto) e `arquivo ausente não é erro`
- **ler**: `skills/memory/SKILL.md:73-89`, `tests/test-leitura-por-secao.sh:39-93`
- **done quando**: casos verdes; `tests/test-leitura-por-secao.sh` verde (fixtures dele só têm MEMORY → `-s` cobre); carga BASE na regra.
- **carga BASE**: sim (memory SKILL).

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/15 fa plan → A1 A2" (comando atual não lê aprendizados.md)
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0; regra de carga BASE aplicada
- [x] **commit** — `git add skills/memory/SKILL.md tests/test-leitura-por-secao.sh tests/test-memoria-integra.sh tests/test-carga.sh tests/test-parada-revisao.sh && git commit -m "feat(memoria-integra/15): carregar-contexto busca aprendizados nos dois arquivos, sem erro"`

## Tarefa 10: sync migra os Aprendizados do MEMORY para o arquivo próprio

- **depende-de**: [Tarefa 4, Tarefa 8]
- **requisito**: `memoria-integra/16` — QUANDO o sync roda e a seção Aprendizados do `MEMORY.md` tem linha de aprendizado O SISTEMA DEVE movê-las literalmente, na mesma ordem, para o fim de `docs/audora/aprendizados.md` (criado se não existir, sem alterar as linhas que já estão lá) e deixar na seção só 1 linha de ponteiro para o arquivo.
- **decisões relevantes**: migra no próximo sync (nó, 2026-10-08). Decisão da IA: o movimento é comando (perl preserva bytes e CRLF — aprendizado 2026-09-29: awk/grep do Git Bash perdem `\r`); a reescrita da seção para P é Edit da IA.
- **interfaces**: produz, num bloco ```` ```bash ```` do passo 1 do `sync.md`, exatamente 2 linhas:
  ```bash
  [ -f docs/audora/aprendizados.md ] || cp "<raiz do plugin>/templates/aprendizados-template.md" docs/audora/aprendizados.md
  perl -ne 'if (/^## /) { $s = /^## Aprendizados/ } print if $s && /^- \d{4}-\d{2}-\d{2} \| /' MEMORY.md >> docs/audora/aprendizados.md
  ```
  Consome P e `templates/aprendizados-template.md` (Tarefa 8).
- **ponto de mudança**: `skills/validate/references/sync.md:12-13` — "e consolidar os aprendizados na seção Aprendizados do `MEMORY.md` (skill memory, compactar — dedupe por grep)" vira: "e, se a seção Aprendizados do `MEMORY.md` tem linha de aprendizado, movê-las — literal, na mesma ordem, para o fim de `docs/audora/aprendizados.md`, sem tocar as que já estão lá:" + o bloco + "e deixar na seção só a linha de ponteiro de `templates/MEMORY-template.md`."
- **teste**: `tests/test-memoria-integra.sh` — casos "memoria-integra/16 …" (extrair as 2 linhas do bloco: a que começa com `[ -f docs/audora/aprendizados.md ]` e a que começa com `perl -ne 'if (/^## /)`; trocar `<raiz do plugin>` por `$ROOT`; rodar com `bash -c` na raiz da fixture)
- **asserções** — MEMORY da fixture: Constituição com `- **stack**: x`, Aprendizados com `L1`, linha em branco, `L2 … [invalidado-em: …]`, `L3`; índice com `- z | planned | Z | r | k | —`:
  - sem aprendizados.md → arquivo criado; linha 1 `# Aprendizados`; linhas de aprendizado = `L1 L2 L3`, nessa ordem; o resto = cópia byte a byte do template
  - com aprendizados.md prévio (`X1`, `X2`) → os bytes anteriores ficam como prefixo intacto (`head -c <tamanho antigo>` igual ao antigo) e depois vêm `L1 L2 L3`
  - MEMORY em CRLF → as 3 linhas acrescentadas terminam em `\r\n` (byte a byte iguais às do MEMORY)
  - nenhuma linha do índice nem da Constituição vai para o arquivo
  - achatado de `sync.md` contém `literal, na mesma ordem, para o fim de \`docs/audora/aprendizados.md\`, sem tocar as que já estão lá` e `deixar na seção só a linha de ponteiro`; não contém `consolidar os aprendizados na seção`; segue contendo `aprendizados` (test-skills /7) e `nó primeiro, índice depois`
- **ler**: `skills/validate/references/sync.md:1-20`
- **done quando**: casos verdes; `tests/test-skills.sh`, `tests/test-prd-foto.sh`, `tests/test-parada-revisao.sh` verdes; carga FULL na regra.
- **carga FULL**: sim.

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/16 comando do sync existe"
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add skills/validate/references/sync.md tests/test-memoria-integra.sh && git commit -m "feat(memoria-integra/16): sync move os Aprendizados do MEMORY para aprendizados.md"`

## Tarefa 11: skills, templates e hooks citam só o arquivo próprio; guard calado nele

- **depende-de**: [Tarefa 8, Tarefa 10]
- **requisito**: `memoria-integra/20` — QUANDO `docs/audora/aprendizados.md` é escrito, com qualquer número de linhas, O SISTEMA (`memory-guard`) DEVE sair 0 sem aviso. · `memoria-integra/21` — QUANDO skills, templates e mensagens de hook dizem onde vive aprendizado O SISTEMA DEVE citar só `docs/audora/aprendizados.md`, sem teto de ~40 linhas nem `aprendizados-historico.md`.
- **decisões relevantes**: sem teto nem compactação do arquivo (fora-de-escopo). `memory-guard` já sai 0 para o arquivo (não casa `*MEMORY.md` nem `*docs/audora/memory/*.md`): /20 é teste de guarda, sem mudança de código.
- **interfaces**: nenhuma.
- **ponto de mudança**:
  - `hooks/memory-guard:34` — mensagem: "… Compactar agora: arquivar nós entregues, mover as linhas de Aprendizados para docs/audora/aprendizados.md (sync da validate), encurtar resumos (skill memory, operação compactar)."
  - `skills/memory/references/compactar.md:11-13` — gatilhos sem "seção Aprendizados > ~40 linhas"; `:16-17` — 2(b) vira "aprendizados não se consolidam aqui: vivem em `docs/audora/aprendizados.md` (registrar-aprendizado; o sync migra o MEMORY antigo)"; `:26-27` — sai a frase "Aprendizados > ~40 linhas: mover … + ponteiro de 1 linha".
  - `templates/MEMORY-template.md:56-57` — "aprendizado → `grep -i '<termo>' docs/audora/aprendizados.md`"; `:59` — sai "consolidar aprendizados da demanda aqui,"; `:64-66` — regra 4 sem "Aprendizados ~40 linhas → … aprendizados-historico.md".
  - `skills/debug/SKILL.md:53` — "registrar-aprendizado no `MEMORY.md`" → "registrar-aprendizado (`docs/audora/aprendizados.md`)".
  - `tests/test-skills.sh:49` — no laço "/2 compactar cita", `'aprendizados-historico.md'` → `'docs/audora/aprendizados.md'` (mesma linha).
- **teste**: `tests/test-memoria-integra.sh` — casos "memoria-integra/20 …", "memoria-integra/21 …"
- **asserções**:
  - /20: fixture com `MEMORY.md` (`memory-schema: 1`) e `docs/audora/aprendizados.md` de 500 linhas → `run_hook memory-guard <fixture>/docs/audora/aprendizados.md` → `code 0`, `out` vazio; `run_hook memory-validate` no mesmo caminho → `code 0`, `out` vazio
  - /21: `grep -rlF 'aprendizados-historico' skills templates hooks` → vazio; `grep -rnE '~ ?40' skills templates hooks` → vazio; `grep -rnF 'registrar-aprendizado no \`MEMORY.md\`' skills` → vazio; `MEMORY.md` de 311 linhas → `memory-guard` exit 2 e `out` contém `docs/audora/aprendizados.md`; achatado do MEMORY-template contém `aprendizado → \`grep -i '<termo>' docs/audora/aprendizados.md\``; achatado de `compactar.md` contém `vivem em \`docs/audora/aprendizados.md\``
- **ler**: `hooks/memory-guard:29-37`, `skills/memory/references/compactar.md:1-29`, `templates/MEMORY-template.md:46-70`, `skills/debug/SKILL.md:50-54`, `tests/test-skills.sh:46-58`, `tests/test-memory-guard.sh:1-17`
- **done quando**: casos verdes; `tests/test-memory-guard.sh` ('teto ~300') e `tests/test-skills.sh` verdes; carga FULL na regra (compactar).
- **carga FULL**: sim.

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/21 sem aprendizados-historico" (acha compactar, template, memory-guard)
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add hooks/memory-guard skills/memory/references/compactar.md templates/MEMORY-template.md skills/debug/SKILL.md tests/test-skills.sh tests/test-memoria-integra.sh && git commit -m "docs(memoria-integra/21): aprendizado citado so em aprendizados.md, sem teto nem historico"`

## Tarefa 12: READMEs e fundamentos acompanham

- **depende-de**: [Tarefa 3, Tarefa 8]
- **requisito**: apoio a `memoria-integra/1` e `memoria-integra/14` — a doc não pode contradizer as skills (critério de HIGH no nó; aprendizado no arquivo próprio).
- **decisões relevantes**: frases já asseridas ficam: `the Learnings that match the request`, `os Aprendizados que casam o pedido`, `` `MEMORY.md` by section ``, `` `MEMORY.md` por seção ``, `o \`MEMORY.md\` entra por seção em toda fase`.
- **interfaces**: nenhuma.
- **ponto de mudança**:
  - `README.pt-BR.md:168-170` — "HIGH → os três campos no nó também, e, se precisar, spec de contexto `docs/audora/specs/<id>-escopo.md` (nunca critério)"; `README.md:167-169` — "HIGH → the three fields in the node too and, if needed, a context-only spec `docs/audora/specs/<id>-escopo.md` (never criteria)".
  - `README.pt-BR.md:133-134,139` e `README.md:133-134,139` — índice mestre com "ponteiro para os Aprendizados"; Aprendizados por grep em `docs/audora/aprendizados.md`.
  - `README.pt-BR.md:209` "aprendizados para o MEMORY na hora" → "aprendizados para `docs/audora/aprendizados.md` na hora"; `README.md:208-209` idem ("learnings to `docs/audora/aprendizados.md` on the spot").
  - `README.pt-BR.md:282-283` / `README.md:281-282` — "deltas no nó e aprendizados em `docs/audora/aprendizados.md`" / "deltas in the node and learnings in `docs/audora/aprendizados.md`".
  - `README.pt-BR.md:251` / `README.md:251` — sync "migra os Aprendizados antigos do MEMORY para `docs/audora/aprendizados.md`" / "moves old MEMORY learnings to `docs/audora/aprendizados.md`".
  - listas de artefatos `README.pt-BR.md:337-347` / `README.md:339-349` — "aprendizados" sai da linha do `MEMORY.md`; linha nova `docs/audora/aprendizados.md` — "aprendizados, 1 por linha, consultados por grep" / "learnings, one per line, queried by grep"; linha de `specs/` → "contexto de escopo de demandas HIGH (critérios ficam no nó)" / "scope context for HIGH demands (criteria live in the node)".
  - `docs/fundamentos.md:28-29` (índice com ponteiro), `:48-51` (linha em `docs/audora/aprendizados.md`), `:127-128` e `:151-152` (HIGH: critérios no nó, spec só contexto).
- **teste**: `tests/test-memoria-integra.sh` — caso "memoria-integra/14 docs …"
- **asserções**: achatados de `README.md`, `README.pt-BR.md`, `docs/fundamentos.md` contêm cada um `docs/audora/aprendizados.md`; PT não contém `aprendizados para o MEMORY na hora` nem `HIGH → spec dedicada`; EN não contém `learnings to the MEMORY on the spot` nem `HIGH → a dedicated spec`; fundamentos não contém `HIGH exige spec dedicada`.
- **ler**: `README.md:125-142,160-170,204-212,246-256,278-284,312-320,335-350`, `README.pt-BR.md:125-142,160-172,204-212,246-256,278-285,312-320,334-348`, `docs/fundamentos.md:24-55,124-156`
- **done quando**: caso verde; `tests/test-docs.sh`, `tests/test-leitura-por-secao.sh`, `tests/test-parada-revisao.sh`, `tests/test-corte-sem-uso.sh` verdes.

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "memoria-integra/14 docs README PT cita aprendizados.md"
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add README.md README.pt-BR.md docs/fundamentos.md tests/test-memoria-integra.sh && git commit -m "docs(memoria-integra/14): READMEs e fundamentos com aprendizados.md e criterio de HIGH no no"`

## Tarefa 13: este repo migra os Aprendizados (dogfood)

- **depende-de**: [Tarefa 7, Tarefa 9, Tarefa 10, Tarefa 11]
- **requisito**: `memoria-integra/18` — QUANDO esta demanda for entregue O SISTEMA DEVE ter o `MEMORY.md` deste repo sem linha de aprendizado, todas em `docs/audora/aprendizados.md`, e a suíte DEVE provar isso.
- **decisões relevantes**: decisão da IA: migra aqui, na execute, pelo próprio comando do sync (Tarefa 10) — o teste da suíte já fica verde antes do portão; o sync desta demanda acha a seção só com P e não tem o que mover. Prova contra o `MEMORY.md` do commit `684abc9` (main no início da demanda) — linha de aprendizado criada depois disso já nasce no arquivo próprio.
- **interfaces**: consome as 2 linhas do bloco do `sync.md` (Tarefa 10), P (Tarefa 8).
- **ponto de mudança**: `MEMORY.md:44-101` (seção vira cabeçalho + P); `docs/audora/aprendizados.md` (NOVO, criado pelo comando); `tests/test-dogfood.sh` (casos novos, antes do `report`).
- **teste**: `tests/test-dogfood.sh` — casos "memoria-integra/18 …"
- **asserções**:
  - `grep -cE '^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| ' MEMORY.md` → `0`
  - linhas não vazias da seção Aprendizados do `MEMORY.md` → exatamente P
  - `git show 684abc9:MEMORY.md | grep -E '^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| '` (53 linhas) = `grep -xFf <(as mesmas) docs/audora/aprendizados.md` — mesmas linhas, mesma ordem, nenhuma faltando
  - a linha de 2026-10-08 do scope ("Princípio da cleanup (humano)…") está em `docs/audora/aprendizados.md`
  - `run_hook memory-validate "$ROOT/MEMORY.md"` → `0` (já existe em `/9`)
- **ler**: `MEMORY.md:40-102`, `tests/test-dogfood.sh:1-16`
- **done quando**: casos verdes; `tests/test-leitura-por-secao.sh` verde (recorte do repo vem de aprendizados.md, ajuste da Tarefa 9); `bash hooks/cleanup varrer` neste repo sem `aprendizados.md` em nenhuma seção.

- [x] **red** — `bash tests/test-dogfood.sh` falha em "memoria-integra/18 MEMORY sem linha de aprendizado" (hoje 54)
- [x] **green** — rodar as 2 linhas do bloco do `sync.md` na raiz (com `<raiz do plugin>` = raiz deste repo), Edit da seção para P; `bash tests/test-dogfood.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add MEMORY.md docs/audora/aprendizados.md tests/test-dogfood.sh && git commit -m "chore(memoria-integra/18): aprendizados deste repo migram para docs/audora/aprendizados.md"`

## Tarefa 14: "critério numerado" = linha `- **<id>/<n>**`, no sync e na cleanup

- **depende-de**: [Tarefa 4, Tarefa 5]
- **origem**: revisão adversarial, passagem 1, bloqueante 1. Decisão do humano no portão (2026-10-08): contar só a linha de critério.
- **requisito**: `memoria-integra/2` (texto sem mudança). A definição do comentário de `## criterios-aceite` do nó muda: "critério numerado" passa de `<id>/<n>` para "linha `- **<id>/<n>** — …`".
- **decisões relevantes**: vale para a contagem do sync E para a `criterios_sem_copia` da cleanup. Do lado do artefato (spec, plano, e2e), a citação continua sendo qualquer menção `<id>/<n>`. Só a "cópia no nó arquivado" exige a linha.
- **ponto de mudança**:
  - **Antes de tudo, o nó**: `docs/audora/memory/memoria-integra.md` está no teto (~100 linhas). Primeiro compactar (skill memory, operação compactar, passo 4: histórico frio para `memoria-integra-historico.md`). Depois, nó primeiro:
    - em `## decisoes`, a linha `- 2026-10-08 (humano, validate): critério numerado = linha `- **<id>/<n>** — …`; menção em ponteiro não conta. Descartado: só o sync; rebaixar a ressalva.`;
    - em `## delta`, `MODIFICADO (2026-10-08, validate): "critério numerado" = `<id>/<n>` → linha `- **<id>/<n>** — …``;
    - o comentário da linha 22 com a definição nova.
  - `skills/validate/references/sync.md:21`: o comando de contagem passa a ser `awk '/^## criterios-aceite/{f=1;next} /^## /{f=0} f' docs/audora/memory/<id>.md | grep -cE '^- \*\*<id>/[0-9]+'`. A frase "a spec … tem critério `<id>/<n>`" vira "tem linha de critério `- **<id>/<n>** — …`".
  - `hooks/cleanup:175-189` (`criterios_sem_copia`): `%tem` passa a ser montado só a partir das linhas `^- \*\*\Q$id\E/(\d+)(?!\d)` (com `/m`) do nó arquivado e do `-historico`; `%cita` não muda. Atualizar o comentário da sub.
  - `skills/cleanup/SKILL.md`: onde explica o `## mantido` por critério, dizer que a cópia no nó é a linha `- **<id>/<n>**`.
- **teste**: `tests/test-memoria-integra.sh`, blocos /2 e /4.
- **asserções**:
  - comando do sync, na fixture `f23`: nó `z` com só `9 critérios \`z/1..9\` na spec dedicada` em `## criterios-aceite` → `0`. Os 3 casos atuais seguem `2`/`0`/`0`.
  - cleanup: `mk4` com o nó arquivado só com a linha de ponteiro `Spec: 2 critérios (d/1..2) na spec dedicada` (sem `- **d/1**`) → `## mantido` com `- <spec de d> | mantido: cita d/1, d/2 sem cópia no nó arquivado`. Os casos atuais de `c4`/`c4b`/`c4c`/`c4d` seguem iguais.
  - dogfood: `hooks/cleanup varrer` neste repo sem mudança no relatório, salvo item que passe a `## mantido` (anotar nas Notas). Resultado: `cleanup: nada a limpar` com o hook do HEAD e o novo — sem specs aqui, nada muda.
- **done quando**: casos verdes; `tests/test-skill-cleanup.sh` verde, sem perder assert; carga FULL na regra.
- **carga FULL**: sim (sync.md, cleanup SKILL.md).

- [x] **red** — `bash tests/test-memoria-integra.sh` falha em "ponteiro com intervalo não conta" e no `## mantido` do nó só com ponteiro
- [x] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [x] **commit** — `git add docs/audora/memory/ skills/validate/references/sync.md hooks/cleanup skills/cleanup/SKILL.md tests/test-memoria-integra.sh && git commit -m "fix(memoria-integra/2,4): criterio numerado e a linha do criterio, nao a mencao"`

## Tarefa 15: sync põe a quebra de linha que falta antes de mover os aprendizados

- **depende-de**: [Tarefa 10]
- **origem**: revisão adversarial, passagem 1, bloqueante 2. Decisão do humano no portão (2026-10-08): corrigir.
- **requisito**: `memoria-integra/16` — "… sem alterar as linhas que já estão lá".
- **ponto de mudança**: `skills/validate/references/sync.md:15-18`. Nova linha no bloco bash, entre o `cp` e o `perl`: `[ -z "$(tail -c1 docs/audora/aprendizados.md)" ] || echo >> docs/audora/aprendizados.md`.
- **teste**: `tests/test-memoria-integra.sh`, bloco /16. Extrair a linha nova como `m_nl` (grep `^ *\[ -z "\$\(tail -c1`) e incluí-la em `move16`, entre `m_cria` e `m_move`.
- **asserções**:
  - `m_nl` extraído contém `tail -c1 docs/audora/aprendizados.md`.
  - fixture `m16d`: `aprendizados.md` = `printf '# Aprendizados\n\n- 2026-01-00 | plan | X1 a'` (sem newline final) → depois do move, `grep -cE '^- [0-9]{4}'` = 4, e a linha `- 2026-01-00 | plan | X1 a` fica intacta (`grep -xF`).
  - os casos `m16a`/`m16b`/`m16c` seguem byte a byte iguais (a linha não mexe em arquivo que já termina em `\n` ou `\r\n`).
- **done quando**: casos verdes; carga FULL na regra.
- **carga FULL**: sim (sync.md).

- [ ] **red** — `bash tests/test-memoria-integra.sh` falha em "m16d sem newline final"
- [ ] **green** — `bash tests/test-memoria-integra.sh`, `bash tests/run.sh` e `bash hooks/gate memoria-integra` saem 0
- [ ] **commit** — `git add skills/validate/references/sync.md tests/test-memoria-integra.sh && git commit -m "fix(memoria-integra/16): sync completa a quebra de linha antes de mover aprendizados"`
