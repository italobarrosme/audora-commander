# Plano — prd-foto: PRD vira foto, histórico no CHANGELOG

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** o sync da validate passa a manter o `PRD.md` como foto (o que é,
stack, arquitetura, metas futuras) com teto de 200 linhas cobrado por hook, e
o histórico de entregas vai para o `CHANGELOG.md` (1 linha por demanda +
histórico antigo literal).

**Nó do MEMORY:** `prd-foto` (MEMORY.md) — escopo no próprio nó, 10 critérios.

**Arquitetura da mudança:** três camadas. (1) Hook: `memory-guard` ganha um
caso para `PRD.md` irmão de um `MEMORY.md` com `memory-schema: 1` — exit 2
acima de 200 linhas. (2) Texto: `sync.md` passo 4 troca "promover resumo"
por "atualizar a foto + 1 linha no CHANGELOG"; o formato do CHANGELOG mora
num template novo (Constituição: schemas só em `templates/`); LIGHT,
compactar, validate, READMEs e fundamentos acompanham. (3) Dogfood: a
conversão do `PRD.md` do plugin e a medição rodam NA VALIDATE, no sync na
`main` (Tarefas 7 e 8) — PRD só muda pela `main`. **A execute termina na
Tarefa 6.**

**Arquivos lidos antes de planejar:**
- `skills/plan/SKILL.md:1-108` — fluxo da fase, formato do mapa.
- `templates/plano-template.md:1-50` — formato do plano.
- `templates/bloco-fechamento-template.md:1-120` — bloco e PARADA.
- `docs/audora/memory/prd-foto.md:1-63` — critérios /1–/10, decisões.
- `MEMORY.md:1-130` — Constituição, aprendizados (CRLF, `wc -c` sem `\r`, gate antes do commit, `claude.exe`, fixture clonada).
- `docs/audora/decisoes-vivas.md:1-45` — A/B `claude -p` sem meta (plano-mapa).
- `hooks/memory-guard:1-35` — `base=` na 16, `case` na 17; MEMORY usa `wc -l`; contrato "na dúvida, exit 0".
- `hooks/hooks.json:1-36` — PostToolUse `Edit|Write` já chama `memory-guard`; nada a mudar.
- `skills/validate/references/sync.md:1-38` — passo 3 (armadilha do PRD, 26-32) e passo 4 (33-36).
- `skills/validate/references/fechamento-light.md:1-30` — bullets Sync (20-23) e PRD (26-28).
- `skills/validate/SKILL.md:60-113` — item 6 na 76-78 ("PRD, HOTFIX"), bloco Arquivos na 103; 6085 bytes (teste exige < 7700).
- `skills/memory/references/compactar.md:1-29` — item 5 (28-29) fala em "promoção do resumo".
- `skills/memory/references/bootstrap.md:1-28` — só LÊ o PRD; não muda.
- `templates/decisoes-vivas-template.md:1-16` — molde para o template novo.
- `tests/lib.sh:1-21` — `run_hook`, asserts, `$SP`.
- `tests/test-memory-guard.sh:1-17` — fixtures do guard (regressão).
- `tests/test-plano-mapa.sh:1-30,70-83` — helper `flat` (7-13); versão 0.12.0 (78-81).
- `tests/test-carga.sh:1-22` — BASE 47719 / FULL 52959, tetos 48000 / 53400; FULL_EXTRA na 13.
- `tests/test-docs.sh:1-70` — versão na 7; PRD cita `MEMORY.md`, `memory-guard`, `memory-validate`, `tests/` (24-25).
- `tests/test-corte-sem-uso.sh:45-55` — versão 0.12.0 na 51.
- `tests/test-skills.sh:84-125,158-205` — asserts de `sync.md` que precisam continuar: 'MEMORY → PRD', 'o `PRD.md` ainda não foi tocado', 'ordem importa', 'nó primeiro, índice depois'; LIGHT trata 'PRD'.
- `tests/test-dogfood.sh:1-21`, `tests/test-templates.sh:1-33`, `tests/run.sh:1-10`.
- `.claude-plugin/plugin.json:1-8` (versão na 4), `.claude-plugin/marketplace.json:1-15` (versão na 9).
- `PRD.md` (títulos + `561-596`) — 596 linhas; `## Estado atual` 105-560 é histórico; meta 5 cita "PRD como foto".
- `README.md:94-100,130-150,229-250,276-290`, `README.pt-BR.md:94-100,138-142,238-249,283-287` — tabela, memory-guard, validate, passo a passo.
- `docs/fundamentos.md:28-40,50-58,258-266` — P5 (55) e Transversais (263) falam em "resumo ao PRD".

**Conflitos MEMORY vs código encontrados:** nenhum.

**Decisões da IA neste plano** (para o lote do portão final):
1. "PRD.md da raiz" = `PRD.md` cuja pasta tem `MEMORY.md` com `memory-schema: 1` — o hook não depende do `cwd`.
2. Contagem por `awk 'END{print NR}'`: última linha sem `\n` conta (com `wc -l`, 201 linhas sem newline final passariam).
3. Formato do CHANGELOG em `templates/changelog-template.md`: `## Entregas` (linhas novas no fim) antes de `## Histórico até AAAA-MM-DD`.
4. O template novo entra no FULL de `tests/test-carga.sh` (é lido no sync).
5. Tarefas 7 e 8 rodam na validate, depois do portão, no sync na `main`.
6. (execute) A parte de carga da Tarefa 6 subiu para a Tarefa 3: o `sync.md` novo estourou o FULL (53993 > 53400) e verde é a suíte toda. Template no FULL e teto FULL 56900 num passo só (motivo no nó); o assert de `tests/test-plano-mapa.sh` troca para "prd-foto/2 … (substitui plano-mapa/14)".

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

- 2026-10-01 execute — Tarefas 1–6 verdes. Suíte base antes da demanda: exit 0, 681 asserts. `bash hooks/gate prd-foto` rodado ANTES de cada commit, todos `GATE: passou` (exit 0), asserts somados: T1 698 · T2 704 · T3 728 · T4 734 · T5 746 · T6 750 (= 681 + 68 de `tests/test-prd-foto.sh` + 1 de `tests/test-carga.sh`), sem queda. Commits: 9ba9cd4, 27df937, 4f67eca, 5c505f6, bb2e882, 4748680. Asserts substituídos (um por um, rótulo "substitui"): `TETO_FULL` em `tests/test-plano-mapa.sh` (plano-mapa/14 → prd-foto/2); versão 0.12.0 → 0.13.0 em `tests/test-docs.sh`, `tests/test-corte-sem-uso.sh`, `tests/test-plano-mapa.sh` (plano-mapa/15 → prd-foto/10).

---

## Tarefa 1: hook cobra o teto do PRD

- **depende-de**: []
- **requisito**:
  - `prd-foto/5` — QUANDO o `PRD.md` da raiz for escrito (Write/Edit) num projeto cujo `MEMORY.md` começa com `memory-schema: 1` e o arquivo passar de 200 linhas O SISTEMA DEVE devolver erro ao modelo (exit 2) com o nº de linhas, o teto e a instrução de compactar a foto movendo o histórico para o `CHANGELOG.md`.
  - `prd-foto/6` — QUANDO o `PRD.md` escrito tiver até 200 linhas O SISTEMA DEVE aceitar em silêncio (exit 0, stderr vazio) — 200 passa, 201 avisa.
  - `prd-foto/7` — QUANDO o projeto não tiver `MEMORY.md` com `memory-schema: 1`, ou o arquivo escrito for um `PRD.md` fora da raiz, O SISTEMA DEVE ignorar a escrita (exit 0, stderr vazio).
- **decisões relevantes**: hook por exit 2 (decisão humana); teto 200; Decisões da IA 1 e 2; contrato do hook "na dúvida, exit 0".
- **interfaces**: consome stdin `{"tool_name":"Edit","tool_input":{"file_path":"<caminho>"}}` · produz exit 0|2 e stderr.
- **ponto de mudança**: `hooks/memory-guard:16` — depois de `base=`, antes do `case` da 17: ramo `[ "$base" = PRD.md ]` que confere `$(dirname)/MEMORY.md`, conta e sai; comentário do topo (2-4) cita o PRD.
- **teste**: `tests/test-prd-foto.sh` (novo; `source lib.sh` + `flat` copiado de `tests/test-plano-mapa.sh:7-13`) — casos "prd-foto/5", "prd-foto/6", "prd-foto/7". Fixture `d=$SP/p` com `MEMORY.md` = `memory-schema: 1`.
- **asserções** (`run_hook memory-guard <arquivo>` → `code` / `out`):
  - `PRD.md` 201 linhas → `2` / exatamente ``memory-guard: PRD.md com 201 linhas — teto 200. Compactar a foto: mover o histórico de entregas, literal, para a seção `## Histórico até AAAA-MM-DD` do CHANGELOG.md (skill validate, sync).``
  - 200 linhas → `0` / vazio
  - 201 linhas sem newline final (`yes l | head -201 | perl -pe 'chomp if eof'`) → `2`
  - 201 linhas CRLF + `MEMORY.md` com `memory-schema: 1\r` → `2`
  - 201 linhas pelo caminho Windows (`cygpath -w "$d/PRD.md"`) → `2`
  - pasta sem `MEMORY.md` (`$SP/q/PRD.md`, 250) → `0` / vazio
  - `MEMORY.md` sem a linha de schema, PRD 250 → `0` / vazio
  - `$d/docs/PRD.md` 250 (raiz com schema) → `0` / vazio
  - `$d/OLDPRD.md` 250 → `0` / vazio
  - `PRD.md` inexistente → `0` / vazio
- **ler**: `hooks/memory-guard:1-35`, `tests/lib.sh:16-21`, `tests/test-memory-guard.sh:1-17`
- **done quando**: `tests/test-prd-foto.sh` verde, `tests/test-memory-guard.sh` intacto e verde.

- [x] **red** — `bash tests/test-prd-foto.sh` falha nos casos de exit 2 (hook atual sai 0 para PRD)
- [x] **green** — `bash tests/test-prd-foto.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`; `bash hooks/gate prd-foto` verde
- [x] **commit** — `git add hooks/memory-guard tests/test-prd-foto.sh && git commit -m "feat(prd-foto/5,6,7): memory-guard cobra o teto de 200 linhas do PRD.md da raiz"`

## Tarefa 2: template do CHANGELOG

- **depende-de**: [1]
- **requisito**:
  - `prd-foto/2` — QUANDO o sync da validate fechar uma demanda entregue, de qualquer categoria, O SISTEMA DEVE acrescentar ao `CHANGELOG.md` da raiz exatamente uma linha `- AAAA-MM-DD | <versão ou —> | <id> | <1 frase> → docs/audora/arquivo/AAAA-MM-DD-<id>.md`, criando o arquivo se não existir.
  - `prd-foto/4` — (só o formato da seção) `## Histórico até AAAA-MM-DD` com o histórico literal.
- **decisões relevantes**: Decisão da IA 3; molde `templates/decisoes-vivas-template.md`.
- **interfaces**: produz `templates/changelog-template.md`, consumido pela Tarefa 3 (`sync.md`) e pela Tarefa 7.
- **ponto de mudança**: `templates/changelog-template.md` (novo).
- **teste**: `tests/test-prd-foto.sh` — caso "prd-foto/2 template".
- **asserções** (sobre `flat templates/changelog-template.md`):
  - contém `# Changelog — <nome do projeto>`
  - contém ``Formato: `- AAAA-MM-DD | <versão ou —> | <id> | <1 frase> → docs/audora/arquivo/AAAA-MM-DD-<id>.md` ``
  - contém `## Entregas` e `## Histórico até AAAA-MM-DD`, nesta ordem (`awk` acha Entregas em linha menor)
  - contém `literal, sem reescrita`
  - exatamente 1 linha de exemplo casando `^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| [^|]+ \| [a-z0-9-]+ \| [^|]+ → docs/audora/arquivo/[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9-]+\.md$` (`grep -cE`)
- **ler**: `templates/decisoes-vivas-template.md:1-16`
- **done quando**: template existe e o caso passa.

- [x] **red** — `bash tests/test-prd-foto.sh` falha em "prd-foto/2 template" (arquivo ausente)
- [x] **green** — `bash tests/test-prd-foto.sh` passa; suíte `0`; gate verde
- [x] **commit** — `git add templates/changelog-template.md tests/test-prd-foto.sh && git commit -m "feat(prd-foto/2,4): template do CHANGELOG — 1 linha por entrega e histórico literal"`

## Tarefa 3: sync escreve foto + CHANGELOG

- **depende-de**: [2]
- **requisito**:
  - `prd-foto/1` — QUANDO o sync da validate promover uma demanda entregue ao `PRD.md` O SISTEMA DEVE atualizar só as seções da foto que a entrega mudou (o que é, stack, arquitetura, metas futuras) e a data de última atualização, sem acrescentar parágrafo de histórico de entrega.
  - `prd-foto/2` — (verbatim na Tarefa 2) linha no `CHANGELOG.md`, de qualquer categoria.
  - `prd-foto/3` — QUANDO uma meta futura do `PRD.md` for entregue pela demanda O SISTEMA DEVE tirá-la das metas futuras; a entrega fica registrada só na linha do `CHANGELOG.md`.
  - `prd-foto/4` — QUANDO o sync encontrar `PRD.md` com histórico de entregas ou com mais de 200 linhas O SISTEMA DEVE mover o histórico, literal e sem reescrita, para a seção `## Histórico até AAAA-MM-DD` do `CHANGELOG.md` e deixar o `PRD.md` como foto com até 200 linhas.
- **decisões relevantes**: direção única MEMORY → PRD; ordem do sync (o CHANGELOG cita o caminho arquivado → depois do `git mv`); conversão on-touch.
- **interfaces**: consome `templates/changelog-template.md` (Tarefa 2).
- **ponto de mudança**: `skills/validate/references/sync.md:29-30` (armadilha: CHANGELOG entra sempre) e `:33-36` (passo 4 reescrito); `skills/memory/references/compactar.md:28-29`; `skills/validate/SKILL.md:78` e `:103`.
- **teste**: `tests/test-prd-foto.sh` — casos "prd-foto/1", "/2 sync", "/3", "/4".
- **asserções** (`flat` de cada arquivo):
  - `sync.md` contém `atualize só as seções da foto (o que é, stack, arquitetura, metas futuras) que a entrega mudou` · `e a data de última atualização` · `nunca acrescente parágrafo de histórico de entrega`
  - `sync.md` NÃO contém `resumo do que foi entregue`
  - `sync.md` contém `exatamente uma linha no `CHANGELOG.md` da raiz, em toda categoria` · `templates/changelog-template.md` · `sem o arquivo, crie-o pelo template` · `acrescente o `CHANGELOG.md` sempre`
  - `sync.md` contém `Meta futura entregue sai das metas futuras` · `a entrega fica só na linha do `CHANGELOG.md``
  - `sync.md` contém `` `PRD.md` com histórico de entregas ou com mais de 200 linhas`` · ``mova o histórico, literal e sem reescrita, para `## Histórico até AAAA-MM-DD` do `CHANGELOG.md` `` · `foto com até 200 linhas` · `escreva a foto num Write só`
  - `sync.md` continua com `MEMORY → PRD`, `o `PRD.md` ainda não foi tocado`, `ordem importa`, `nó primeiro, índice depois` (guardas de `tests/test-skills.sh`)
  - `compactar.md` NÃO contém `promoção do resumo`; contém `foto do `PRD.md` e a linha do `CHANGELOG.md` são da skill validate`
  - `skills/validate/SKILL.md` contém `` `arquivos:` do diff real, PRD + CHANGELOG, HOTFIX`` · `` `PRD.md` atualizado e `CHANGELOG.md` com a linha da entrega``; tamanho sem `\r` < 7700
- **ler**: `skills/validate/references/sync.md:1-38`, `skills/memory/references/compactar.md:24-29`, `skills/validate/SKILL.md:72-80,96-105`
- **done quando**: casos verdes e `tests/test-skills.sh` verde sem mexer nos asserts dele.

- [x] **red** — `bash tests/test-prd-foto.sh` falha nos casos /1–/4 do sync
- [x] **green** — `bash tests/test-prd-foto.sh` e `bash tests/test-skills.sh` passam; suíte `0`; gate verde
- [x] **commit** — `git add skills/validate/references/sync.md skills/memory/references/compactar.md skills/validate/SKILL.md tests/test-prd-foto.sh && git commit -m "feat(prd-foto/1,2,3,4): sync atualiza a foto do PRD e acrescenta 1 linha ao CHANGELOG"`

## Tarefa 4: LIGHT também ganha a linha

- **depende-de**: [3]
- **requisito**: `prd-foto/2` (verbatim na Tarefa 2) — "de qualquer categoria" inclui LIGHT; `prd-foto/1` no bullet PRD do LIGHT.
- **decisões relevantes**: decisão da IA no nó — LIGHT ganha linha; PRD em LIGHT segue "promove só se mudar o que a foto descreve".
- **interfaces**: nenhuma nova.
- **ponto de mudança**: `skills/validate/references/fechamento-light.md:20-23` (Sync) e `:26-28` (PRD).
- **teste**: `tests/test-prd-foto.sh` — caso "prd-foto/2 LIGHT".
- **asserções** (`flat fechamento-light.md`):
  - contém `A linha do `CHANGELOG.md` entra sempre, também em LIGHT`
  - contém `atualize a foto só se o ajuste mudar o que ela descreve`
  - continua com `silêncio sobre o PRD é proibido`, `não tem plano`, `caminho percorrido pelo usuário`, `arquivos de teste separados`
- **ler**: `skills/validate/references/fechamento-light.md:1-30`
- **done quando**: caso verde; `tests/test-skills.sh` e `tests/test-gate.sh` verdes.

- [x] **red** — `bash tests/test-prd-foto.sh` falha em "prd-foto/2 LIGHT"
- [x] **green** — `bash tests/test-prd-foto.sh` passa; suíte `0`; gate verde
- [x] **commit** — `git add skills/validate/references/fechamento-light.md tests/test-prd-foto.sh && git commit -m "feat(prd-foto/2): LIGHT também acrescenta a linha do CHANGELOG"`

## Tarefa 5: READMEs e fundamentos

- **depende-de**: [4]
- **requisito**: documentação de /1, /2 e /5 (sem critério próprio; padrão das demandas anteriores).
- **decisões relevantes**: READMEs EN/PT com blocos de código idênticos (`tests/test-docs.sh:22-23`) — não criar bloco de código.
- **interfaces**: nenhuma.
- **ponto de mudança**: `README.md:99,140,241-247,282-284`; `README.pt-BR.md:99,140,242-248,285-287`; `docs/fundamentos.md:55,263`.
- **teste**: `tests/test-prd-foto.sh` — caso "prd-foto docs".
- **asserções** (`flat`):
  - `README.md` contém `the `PRD.md` snapshot updated` · `one line appended to `CHANGELOG.md`` · `` `PRD.md` over 200 lines``; NÃO contém `summary promoted to `PRD.md`` nem `receives the summary`
  - `README.pt-BR.md` contém `foto do `PRD.md` atualizada` · `uma linha acrescentada ao `CHANGELOG.md`` · `` `PRD.md` acima de 200 linhas``; NÃO contém `resumo promovido ao `PRD.md`` nem `PRD.md recebe o resumo`
  - `docs/fundamentos.md` contém `atualiza a foto do PRD.md e acrescenta 1 linha ao CHANGELOG.md`; NÃO contém `promove o resumo ao PRD.md`
- **ler**: `README.md:94-100,130-150,229-250,276-290`, `README.pt-BR.md:94-100,138-142,238-249,283-287`, `docs/fundamentos.md:50-58,258-266`
- **done quando**: caso verde; `tests/test-docs.sh` verde.

- [x] **red** — `bash tests/test-prd-foto.sh` falha em "prd-foto docs"
- [x] **green** — `bash tests/test-prd-foto.sh` e `bash tests/test-docs.sh` passam; suíte `0`; gate verde
- [x] **commit** — `git add README.md README.pt-BR.md docs/fundamentos.md tests/test-prd-foto.sh && git commit -m "docs(prd-foto/1,2,5): READMEs e fundamentos descrevem a foto do PRD e o CHANGELOG"`

## Tarefa 6: versão 0.13.0 e carga

- **depende-de**: [5]
- **requisito**: `prd-foto/10` — QUANDO o plugin for reinstalado O SISTEMA DEVE declarar a versão `0.13.0` em `plugin.json` e `marketplace.json`.
- **decisões relevantes**: Decisão da IA 4; "subir teto só com motivo no nó" (`tests/test-carga.sh:8`); troca de assert um por um, sem perder nenhum.
- **interfaces**: nenhuma.
- **ponto de mudança**: `.claude-plugin/plugin.json:4`, `.claude-plugin/marketplace.json:9`; asserts de versão em `tests/test-docs.sh:7`, `tests/test-corte-sem-uso.sh:49-52`, `tests/test-plano-mapa.sh:74-81` (0.12.0 → 0.13.0, rótulo "prd-foto/10 … (substitui plano-mapa/15)"); `tests/test-carga.sh:13` (+ `$T/changelog-template.md` no FULL_EXTRA) e `:7` (linha de medição "prd-foto: BASE x → y / FULL x → y").
- **teste**: `tests/test-prd-foto.sh` — caso "prd-foto/10"; `tests/test-carga.sh`.
- **asserções**:
  - cada manifest contém `"version": "0.13.0"` e NÃO contém `"version": "0.12.0"`
  - `bash tests/test-carga.sh` imprime base ≤ 48000 e full ≤ 53400. Se passar de um teto: novo teto = medido + 3%, arredondado para cima em centenas; motivo registrado em `## decisoes` do nó; asserts `TETO_BASE=`/`TETO_FULL=` de `tests/test-plano-mapa.sh:76-77` trocados pelo valor novo com "(substitui plano-mapa/14)"; listar no portão.
- **ler**: `.claude-plugin/plugin.json:1-8`, `.claude-plugin/marketplace.json:1-15`, `tests/test-carga.sh:1-22`, `tests/test-corte-sem-uso.sh:45-55`, `tests/test-plano-mapa.sh:74-83`, `tests/test-docs.sh:1-10`
- **done quando**: suíte `0`, total de asserts (soma de `PASS=` da saída) = antes + asserts novos, sem queda.

- [x] **red** — `bash tests/test-prd-foto.sh` falha em "prd-foto/10" (0.12.0)
- [x] **green** — `log=$(mktemp); bash tests/run.sh > "$log" 2>&1; echo $?` → `0`; `grep -o 'PASS=[0-9]*' "$log" | cut -d= -f2 | awk '{s+=$1} END{print s}'`; gate verde
- [x] **commit** — `git add .claude-plugin/plugin.json .claude-plugin/marketplace.json tests/test-docs.sh tests/test-corte-sem-uso.sh tests/test-plano-mapa.sh tests/test-carga.sh tests/test-prd-foto.sh && git commit -m "chore(prd-foto/10): versão 0.13.0; carga BASE/FULL medida"`

**Fim da execute.** Tarefas 7 e 8 são da validate.

## Tarefa 7: conversão do PRD do plugin (validate, sync na main)

- **depende-de**: [6, portão final aprovado]
- **requisito**: `prd-foto/8` — QUANDO o sync desta demanda rodar no próprio plugin (merge na `main`) O SISTEMA DEVE deixar o `PRD.md` do plugin como foto com até 200 linhas e criar o `CHANGELOG.md` com o histórico atual movido e a linha desta entrega.
- **decisões relevantes**: Decisão da IA 5; regras novas do `sync.md` (Tarefa 3); `/3` → meta 5 do PRD perde "PRD como foto" e fica só o critério de parada da revisão adversarial; foto escrita num Write só (o hook novo avisa a cada Edit acima de 200).
- **interfaces**: consome `templates/changelog-template.md`.
- **ponto de mudança**: `PRD.md:105-560` (`## Estado atual` sai literal para o CHANGELOG), `PRD.md:15-104` (Stack: 0.13.0; Arquitetura: teto do PRD no `memory-guard`, sync com CHANGELOG), `PRD.md:561-596` (meta 5), `CHANGELOG.md` (novo).
- **teste**: `tests/test-prd-foto.sh` — caso "prd-foto/8 dogfood" (escrito ANTES da conversão).
- **asserções**:
  - `awk 'END{print NR}' PRD.md` ≤ 200; `PRD.md` NÃO contém `## Estado atual` nem `PRD como foto`
  - `CHANGELOG.md` contém `## Histórico até 2026-` e as frases literais `Plano-mapa entregue em 2026-10-01 (nó `plano-mapa`, MEDIUM, versão 0.12.0).` e `Corte do sem uso entregue em 2026-09-30`
  - `grep -cE '^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| 0\.13\.0 \| prd-foto \| .+ → docs/audora/arquivo/[0-9]{4}-[0-9]{2}-[0-9]{2}-prd-foto\.md$' CHANGELOG.md` → `1`, e o arquivo apontado existe
  - `run_hook memory-guard "$ROOT/PRD.md"` → `0` / vazio
  - evidência de literalidade (antes do commit do sync): `diff <(git show HEAD:PRD.md | tr -d '\r' | awk '/^## Estado atual/{f=1;next} /^## Metas futuras/{f=0} f') <(tr -d '\r' < CHANGELOG.md | awk '/^## Histórico até/{f=1;next} f')` → vazio, exit 0
- **ler**: `PRD.md` por seção (1-104, 561-596; 105-560 só pelo `awk` acima), `templates/changelog-template.md`
- **done quando**: caso verde, `tests/test-docs.sh` verde (PRD ainda cita `MEMORY.md`, `memory-guard`, `memory-validate`, `tests/`), suíte `0`.

- [ ] **red** — `bash tests/test-prd-foto.sh` falha em "prd-foto/8 dogfood" (PRD com 596 linhas)
- [ ] **green** — conversão feita; `bash tests/test-prd-foto.sh` passa; `diff` de literalidade vazio; suíte `0`
- [ ] **commit** — junto do commit do sync: `git add PRD.md CHANGELOG.md tests/test-prd-foto.sh <arquivos do sync>`

## Tarefa 8: medição antes × depois (validate)

- **depende-de**: [7]
- **requisito**: `prd-foto/9` — QUANDO a demanda fechar O SISTEMA DEVE registrar no nó as linhas e bytes (sem `\r`) do `PRD.md` do plugin antes e depois, e o custo da leitura do PRD numa sessão `claude -p` com o PRD antigo × a foto. Sem meta numérica.
- **decisões relevantes**: decisão viva 2026-10-01 (A/B `claude -p`, sem meta); aprendizados: `~/.local/bin/claude.exe`; `--output-format stream-json --verbose` para o arquivo, lido inteiro; fixture clonada sem branches além da `main`; espera com polling ativo.
- **interfaces**: nenhuma.
- **ponto de mudança**: nó arquivado `docs/audora/arquivo/AAAA-MM-DD-prd-foto.md` — seção `## medicao` nova.
- **teste**: nenhum (medição). Evidência = números no nó.
- **asserções**:
  - antes: `git show <commit pré-sync>:PRD.md | tr -d '\r' | wc -l` e `| wc -c`; depois: o mesmo sobre `HEAD:PRD.md`
  - A/B: clone em `$(mktemp -d)/ab`, rodada A com o `PRD.md` pré-sync, rodada B com a foto; mesmo prompt nas duas: `Leia o PRD.md inteiro e responda em 1 linha: qual a versão do plugin?`; registrar `total_cost_usd` e `usage` do evento `result` de cada `.jsonl`; n=1
- **ler**: `docs/audora/decisoes-vivas.md` (linha 2026-10-01)
- **done quando**: `## medicao` no nó arquivado com linhas, bytes e custo A × B.

- [ ] **medir** — os dois `wc` e as duas rodadas, saída em arquivo
- [ ] **registrar** — seção `## medicao` no nó arquivado
- [ ] **commit** — `git add docs/audora/arquivo/*-prd-foto.md && git commit -m "docs(prd-foto/9): medição — PRD antes × foto, linhas, bytes e custo de leitura (n=1)"`
