# Plano — parada-revisao: critério de parada da revisão adversarial

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** a revisão adversarial da validate (HIGH) bloqueia o portão só
com achado provado de 3 classes (alheio, critério, formato real), roda 1
passagem completa + 1 reverificação restrita e manda o resto ao roteiro como
ressalva; ressalva aceita vira candidato a nó nas metas do `PRD.md`.

**Nó do MEMORY:** `parada-revisao` (MEMORY.md) — escopo no próprio nó, 10 critérios.

**Arquitetura da mudança:** o texto da revisão sai do roteador e vai para uma
reference nova, `skills/validate/references/revisao-adversarial.md`, lida só
em HIGH (padrão roteador + references, decisão viva `memory-fatiada`). O
bullet inline de `skills/validate/SKILL.md:63-66` (282 bytes) vira ponteiro
curto + 1 linha na tabela "Onde mora cada parte" — a carga BASE de MEDIUM
encolhe em vez de crescer (/9). A parte do sync de /8 entra em
`references/sync.md` (carga FULL, folga 1718 bytes). Estado entre sessões
(validate → execute → validate) mora em disco: bloqueante vira tarefa nova no
plano e a passagem fica nas Notas de sessão. Docs e versão fecham. O sync do
dogfood (meta 5 sai do `PRD.md`, arquitetura cita a reference nova, linha do
`CHANGELOG.md`) é da validate — **a execute termina na Tarefa 5**.

**Arquivos lidos antes de planejar:**
- `skills/plan/SKILL.md:1-108` — fluxo da fase, formato do mapa.
- `templates/plano-template.md:1-50` — formato do plano.
- `templates/bloco-fechamento-template.md:1-124` — bloco e PARADA.
- `docs/audora/memory/parada-revisao.md:1-60` — critérios /1–/10, decisões, fora-de-escopo.
- `MEMORY.md:1-115` — Constituição (references ≤ 250 linhas), aprendizados: carga na tarefa que muda o arquivo, gate antes do commit, `wc -c` sem `\r`, `assert_contains` sensível a caixa e a `-`, `git add` por caminho, frase inteira por seção.
- `docs/audora/decisoes-vivas.md:1-45` — roteador + references (memory-fatiada); prompt do revisor diz executáveis falsos quando há efeito fora do repo (remover-graphify).
- `skills/validate/SKILL.md:1-114` — tabela de references 24-29; reference ausente 31-32; roteiro item 3 em 49-66, bullet da revisão em 63-66; portão item 5 em 69-75; 6139 bytes sem `\r`.
- `skills/validate/references/sync.md:1-53` — passo 4, bullet Foto em 38-42.
- `skills/validate/references/decisoes-vivas.md:1-12` — cabeçalho de reference (`# validate — …` + `> Reference da skill …`).
- `tests/test-carga.sh:1-22` — BASE 47773 / FULL 55182, tetos 48000 / 56900; linha de medição na 6; BASE_LIST na 12, FULL_EXTRA na 13.
- `tests/test-skills.sh:1-15,182-200` — references ≤ 250 linhas (13); loop de references do roteador (184-187); validate < 7700 bytes (193).
- `tests/test-prd-foto.sh:1-40,100-130` — helper `flat` (7-13); versão 0.13.0 em 111-115.
- `tests/test-docs.sh:1-12` — versão na 7.
- `tests/test-corte-sem-uso.sh:45-55` — versão na 49-52.
- `tests/test-plano-mapa.sh:72-83` — `TETO_BASE=48000` na 76; versão na 78-81.
- `tests/lib.sh:1-21`, `tests/run.sh:1-10` — asserts, `$SP`, `report`.
- `hooks/gate:1-40` — anti-fraude: teste apagado, skip/only, queda de asserts contra HEAD.
- `.claude-plugin/plugin.json:1-8` (versão na 4), `.claude-plugin/marketplace.json:1-15` (versão na 9).
- `README.md:230-245`, `README.pt-BR.md:232-245` — seção `validate`, revisão adversarial em 237-238 / 237-239.
- `docs/fundamentos.md:214-228` — item 5 "Revisão adversarial por subagente" em 220-223.
- `PRD.md:1-145` — arquitetura da validate (roteador e references), meta 5 é esta demanda; metas 4 e 6 dão o formato "Candidato a nó: ressalvas do `<id>` … aceitas no portão".

**Conflitos MEMORY vs código encontrados:** nenhum.

**Decisões da IA neste plano** (para o lote do portão final):
1. Texto da revisão numa reference nova lida só em HIGH; roteador fica com ponteiro de 1 linha e linha na tabela (/9 por construção, não por enxugar outro trecho).
2. Ressalva aceita é registrada em `## decisoes` do nó como `- AAAA-MM-DD (humano): ressalva aceita — <1 linha>` — sem seção nova no `templates/no-template.md` (arquivo da BASE).
3. Bloqueante vira tarefa nova no plano (como na aprovação parcial) e a passagem fica nas Notas de sessão — a execute acha "qual a próxima?" mecanicamente e a validate seguinte sabe que é reverificação.
4. A validate confere a prova do bloqueante antes de aceitá-la (roda o comando, abre o trecho); prova que não se sustenta rebaixa a ressalva — resposta de subagente é pista.
5. O despacho na reference repete a decisão viva `remover-graphify` (efeito fora do repo → executáveis falsos, dito no prompt).
6. Teste próprio `tests/test-parada-revisao.sh` com o helper `flat` copiado de `tests/test-prd-foto.sh:7-13`.
7. (execute) A meta do sync é asserida sem as crases externas — `Candidato a nó: ressalvas do `<id>` aceitas no portão.` — e escrita entre aspas no `sync.md`: crase dentro de crase quebra o inline code; o texto da meta é o das metas 4 e 6 do `PRD.md`.
8. (execute) A reverificação também é registrada nas Notas de sessão do plano: validate que acha passagem 1 + reverificação não revisa de novo (sustenta /5 entre sessões).

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

- 2026-10-01 execute — base antes da demanda: suíte exit 0, 761 asserts.
- Tarefa 1 (`ed08926`): red 20 FAIL (reference ausente, roteador sem ponteiro); green 27/27; carga BASE 47773 → 47723, FULL 55182 → 55132; roteador 6139 → 6089 bytes; suíte exit 0, 789 asserts (+27 do teste novo, +1 do loop de references de `test-skills.sh`); `GATE: passou` antes do commit.
- Tarefa 2: red 13 FAIL (seções `## Parada` e `## No roteiro` ausentes); green 40/40; reference 65 linhas; suíte exit 0, 802 asserts (+13); `GATE: passou` antes do commit.
- Tarefa 3: red 4 FAIL (seção do portão e bullet do sync ausentes); green 48/48; carga BASE 47723 / FULL 55182 → 55350 (registrado em `tests/test-carga.sh:6`); suíte exit 0, 810 asserts (+8); `GATE: passou` antes do commit.
- Tarefa 4: red 8 FAIL (frases ausentes nos 3 docs); green 56/56, `test-docs.sh` 158/158; suíte exit 0, 818 asserts (+8); `GATE: passou` antes do commit.
- Tarefa 5: red 5 FAIL (manifests em 0.13.0; 4 testes com assert positivo de 0.13.0); green 61/61; 4 asserts trocados um por um (rótulo "substitui prd-foto/10"); suíte exit 0, 823 asserts = 761 + 61 do teste novo + 1 do loop de references, sem queda; `GATE: passou` antes do commit.

---

## Tarefa 1: reference da revisão — classes, prova e ressalva; roteador aponta

- **depende-de**: []
- **requisito**:
  - `parada-revisao/1` — QUANDO a validate despachar a revisão adversarial de uma demanda HIGH O SISTEMA DEVE instruir o revisor a marcar como bloqueante só o achado de uma de 3 classes: (a) apaga ou altera coisa fora da demanda, (b) viola um critério de aceite, (c) falha com entrada ou formato real.
  - `parada-revisao/2` — QUANDO o revisor apontar um achado bloqueante O SISTEMA DEVE exigir a prova da classe: (a) o arquivo ou trecho alheio no diff, (b) o endereço `<id>/<n>` do critério e como ele é violado, (c) o comando ou a entrada que reproduz a falha; achado sem prova é rebaixado a ressalva.
  - `parada-revisao/3` — QUANDO um achado não for bloqueante O SISTEMA DEVE listá-lo no roteiro como ressalva de 1 linha, sem voltar à execute e sem disparar nova passagem de revisão.
  - `parada-revisao/9` — QUANDO uma demanda MEDIUM passar pela validate O SISTEMA NÃO DEVE carregar texto desta demanda: a carga BASE de `tests/test-carga.sh` fica ≤ 48000 bytes.
- **decisões relevantes**: Decisões da IA 1, 4, 5 e 6; bloqueia só as 3 classes (humano); sem prova rebaixa (humano); cabeçalho de reference no padrão de `references/decisoes-vivas.md:1-4`; reference ≤ 250 linhas.
- **interfaces**: produz `skills/validate/references/revisao-adversarial.md` com as seções `## Despacho`, `## Bloqueante: só 3 classes, com prova`, `## Ressalva` (Tarefas 2 e 3 acrescentam seções no mesmo arquivo).
- **ponto de mudança**: arquivo novo `skills/validate/references/revisao-adversarial.md`; `skills/validate/SKILL.md:28` (linha nova na tabela, antes de `| demanda LIGHT |`) e `:63-66` (bullet vira ponteiro). A linha de medição de `tests/test-carga.sh` fica para a Tarefa 3 (FULL só muda lá); tetos não mudam.
- **teste**: `tests/test-parada-revisao.sh` (novo) — casos "parada-revisao/1", "/2", "/3", "/9".
- **asserções** (`flat` do arquivo; R = a reference, V = `skills/validate/SKILL.md`):
  - R existe; `tr -d '\r' < R | wc -l` ≤ 250
  - R contém `# validate — revisão adversarial (HIGH)` · `lida só em demanda HIGH` · `subagente de contexto limpo` · `Autor não revisa a si mesmo` · `executáveis falsos no PATH`
  - /1: R contém `bloqueante só o achado de uma de 3 classes` · `(a) apaga ou altera coisa fora da demanda` · `(b) viola um critério de aceite` · `(c) falha com entrada ou formato real`
  - /2: R contém `(a) o arquivo ou trecho alheio no diff` · `(b) o endereço `<id>/<n>` do critério e como ele é violado` · `(c) o comando ou a entrada que reproduz a falha` · `achado sem prova é rebaixado a ressalva` · `confira a prova você mesmo` · `prova que não se sustenta também é rebaixada`
  - /3: R contém `ressalva de 1 linha` · `sem voltar à execute e sem disparar nova passagem`
  - /9: V contém `references/revisao-adversarial.md` (na tabela E no item 3: `grep -c` da string ≥ 2); V NÃO contém `rebaixado a ressalva`, `3 classes` nem `ATACAR`; `tr -d '\r' < V | wc -c` ≤ 6139 (o roteador não cresce); `tests/test-carga.sh` NÃO contém `revisao-adversarial` (fora de BASE e FULL); `bash tests/test-carga.sh` sai 0 e imprime `base=` ≤ 47773
- **ler**: `skills/validate/SKILL.md:18-33,49-66`, `skills/validate/references/decisoes-vivas.md:1-4`, `tests/test-prd-foto.sh:1-13`, `tests/test-carga.sh:1-22`
- **done quando**: casos verdes; `tests/test-skills.sh` e `tests/test-carga.sh` verdes sem mexer nos asserts deles.

- [x] **red** — `bash tests/test-parada-revisao.sh` falha em "parada-revisao/1", "/2", "/3" (reference ausente) e "/9" (roteador sem ponteiro)
- [x] **green** — `bash tests/test-parada-revisao.sh; bash tests/test-skills.sh; bash tests/test-carga.sh` passam; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`; `bash hooks/gate parada-revisao` → `GATE: passou` ANTES do commit (asserts somados nas Notas de sessão)
- [x] **commit** — `git add skills/validate/references/revisao-adversarial.md skills/validate/SKILL.md tests/test-parada-revisao.sh && git commit -m "feat(parada-revisao/1,2,3,9): revisão adversarial em reference HIGH — 3 classes com prova, resto é ressalva"`

## Tarefa 2: parada — reverificação restrita, sem 3ª passagem, roteiro e revisor indisponível

- **depende-de**: [1]
- **requisito**:
  - `parada-revisao/4` — QUANDO houver bloqueante e a execute o corrigir O SISTEMA DEVE fazer uma reverificação restrita: o revisor confere só aqueles achados contra o diff da correção, sem caçar achado novo.
  - `parada-revisao/5` — QUANDO a passagem completa e a reverificação terminarem O SISTEMA DEVE encerrar a revisão — nunca uma 3ª passagem; achado novo visto na reverificação entra como ressalva e o que restar vai ao portão humano.
  - `parada-revisao/6` — QUANDO a revisão terminar O SISTEMA DEVE pôr no roteiro o nº de passagens, cada bloqueante com classe, prova e estado (corrigido ou aberto) e as ressalvas.
  - `parada-revisao/7` — QUANDO o subagente revisor não puder ser despachado ou falhar O SISTEMA DEVE avisar em 1 linha no roteiro que a revisão adversarial não rodou, e o portão segue com o humano revisando o diff.
- **decisões relevantes**: Decisão da IA 3; 1 passagem completa + reverificação restrita (humano); achado novo na reverificação vira ressalva (IA, no nó); revisor indisponível não trava o portão (IA, no nó).
- **interfaces**: consome a reference da Tarefa 1; acrescenta as seções `## Parada` e `## No roteiro`.
- **ponto de mudança**: `skills/validate/references/revisao-adversarial.md` (depois de `## Ressalva`).
- **teste**: `tests/test-parada-revisao.sh` — casos "parada-revisao/4", "/5", "/6", "/7".
- **asserções** (`flat` de R; frases dentro da seção extraída por `flat R '## Parada'` ou `flat R '## No roteiro'`):
  - /4 (`## Parada`): contém `cada bloqueante vira uma tarefa nova no plano` · `registre nas Notas de sessão do plano` · `passagem 1` · `` `execute de <id>` `` · `reverificação restrita: o revisor confere só aqueles achados contra o diff da correção, sem caçar achado novo`
  - /5 (`## Parada`): contém `nunca uma 3ª passagem` · `achado novo visto na reverificação entra como ressalva` · `o que restar vai ao portão humano`
  - /6 (`## No roteiro`): contém `nº de passagens` · `cada bloqueante com classe, prova e estado (corrigido ou aberto)` · `as ressalvas`
  - /7 (`## No roteiro`): contém `revisão adversarial não rodou` · `o portão segue com o humano revisando o diff`
  - R continua ≤ 250 linhas
- **ler**: `skills/validate/references/revisao-adversarial.md` (inteiro, < 60 linhas), `skills/validate/SKILL.md:69-75`
- **done quando**: casos verdes; asserts da Tarefa 1 seguem verdes.

- [x] **red** — `bash tests/test-parada-revisao.sh` falha em "parada-revisao/4", "/5", "/6", "/7"
- [x] **green** — `bash tests/test-parada-revisao.sh` passa; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`; `bash hooks/gate parada-revisao` → `GATE: passou` antes do commit
- [x] **commit** — `git add skills/validate/references/revisao-adversarial.md tests/test-parada-revisao.sh && git commit -m "feat(parada-revisao/4,5,6,7): 1 passagem + reverificação restrita, nunca 3ª; roteiro com passagens e revisor indisponível"`

## Tarefa 3: ressalva aceita vai ao nó e às metas do PRD

- **depende-de**: [2]
- **requisito**: `parada-revisao/8` — QUANDO o humano aceitar ressalvas no portão O SISTEMA DEVE registrá-las no nó e, no sync, levá-las às metas futuras do `PRD.md` como candidato a nó.
- **decisões relevantes**: Decisão da IA 2; não bloqueante vira ressalva, aceita vira candidato a nó (humano); reclassificar ressalvas antigas das metas 4 e 6 é fora de escopo; direção única MEMORY → PRD.
- **interfaces**: consome a linha de nó `- AAAA-MM-DD (humano): ressalva aceita — <1 linha>` (produzida pela reference, lida pelo sync).
- **ponto de mudança**: `skills/validate/references/revisao-adversarial.md` (seção nova `## Ressalva aceita no portão`); `skills/validate/references/sync.md:38-42` (bullet Foto ganha a frase das ressalvas); `tests/test-carga.sh:6` (acrescenta `; parada-revisao: BASE 47773 → <base medido> / FULL 55182 → <full medido>` com os valores impressos por `bash tests/test-carga.sh`).
- **teste**: `tests/test-parada-revisao.sh` — casos "parada-revisao/8 portão" e "/8 sync".
- **asserções** (`flat`):
  - R contém `` registre cada uma em `## decisoes` do nó `` · `(humano): ressalva aceita —`
  - `sync.md` contém `Ressalva aceita no portão` · `` `Candidato a nó: ressalvas do `<id>` aceitas no portão.` ``
  - `sync.md` continua com `MEMORY → PRD`, `o `PRD.md` ainda não foi tocado`, `ordem importa`, `nó primeiro, índice depois` (guardas de `tests/test-skills.sh`)
  - `bash tests/test-carga.sh` sai 0: full ≤ 56900 (sync.md está no FULL)
- **ler**: `skills/validate/references/sync.md:34-51`, `PRD.md:122-140`
- **done quando**: casos verdes; `tests/test-skills.sh`, `tests/test-carga.sh` e `tests/test-prd-foto.sh` verdes sem mexer nos asserts deles.

- [x] **red** — `bash tests/test-parada-revisao.sh` falha em "parada-revisao/8 portão" e "/8 sync"
- [x] **green** — `bash tests/test-parada-revisao.sh; bash tests/test-carga.sh` passam; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`; `bash hooks/gate parada-revisao` → `GATE: passou` antes do commit
- [x] **commit** — `git add skills/validate/references/revisao-adversarial.md skills/validate/references/sync.md tests/test-carga.sh tests/test-parada-revisao.sh && git commit -m "feat(parada-revisao/8): ressalva aceita no portão vai ao nó e, no sync, às metas do PRD"`

## Tarefa 4: READMEs e fundamentos

- **depende-de**: [3]
- **requisito**: documentação de /1, /3, /4 e /5 (sem critério próprio; padrão das demandas anteriores).
- **decisões relevantes**: READMEs EN/PT com blocos de código idênticos (`tests/test-docs.sh`) — não criar bloco de código; README EN em inglês (Constituição).
- **interfaces**: nenhuma.
- **ponto de mudança**: `README.md:237-238`; `README.pt-BR.md:237-239`; `docs/fundamentos.md:220-223`.
- **teste**: `tests/test-parada-revisao.sh` — caso "parada-revisao docs".
- **asserções** (`flat`):
  - `README.md` contém `blocks only on proven findings of three classes` · `the rest becomes a one-line caveat` · `one full pass plus a re-check of the fixed blockers`
  - `README.pt-BR.md` contém `bloqueia só achado provado de 3 classes` · `o resto vira ressalva de 1 linha` · `1 passagem completa mais a reverificação dos bloqueantes corrigidos`
  - `docs/fundamentos.md` contém `bloqueia só achado provado de 3 classes (alheio, critério, formato real)` · `nunca uma 3ª passagem`
- **ler**: `README.md:230-245`, `README.pt-BR.md:232-245`, `docs/fundamentos.md:214-228`
- **done quando**: caso verde; `tests/test-docs.sh` verde.

- [x] **red** — `bash tests/test-parada-revisao.sh` falha em "parada-revisao docs"
- [x] **green** — `bash tests/test-parada-revisao.sh; bash tests/test-docs.sh` passam; `bash tests/run.sh > /dev/null 2>&1; echo $?` → `0`; `bash hooks/gate parada-revisao` → `GATE: passou` antes do commit
- [x] **commit** — `git add README.md README.pt-BR.md docs/fundamentos.md tests/test-parada-revisao.sh && git commit -m "docs(parada-revisao/1,3,4,5): READMEs e fundamentos descrevem a parada da revisão adversarial"`

## Tarefa 5: versão 0.14.0

- **depende-de**: [4]
- **requisito**: `parada-revisao/10` — QUANDO o plugin for reinstalado O SISTEMA DEVE declarar a versão `0.14.0` em `plugin.json` e `marketplace.json`.
- **decisões relevantes**: bump `0.14.0` (IA, no nó); troca de assert um por um, sem perder nenhum, rótulo "(substitui prd-foto/10)".
- **interfaces**: nenhuma.
- **ponto de mudança**: `.claude-plugin/plugin.json:4`, `.claude-plugin/marketplace.json:9`; asserts 0.13.0 → 0.14.0 em `tests/test-docs.sh:7`, `tests/test-corte-sem-uso.sh:49-51`, `tests/test-plano-mapa.sh:74,79`, `tests/test-prd-foto.sh:111-113` (rótulo `parada-revisao/10 … (substitui prd-foto/10)`; os `assert_not_contains` de versões antigas ficam).
- **teste**: `tests/test-parada-revisao.sh` — caso "parada-revisao/10".
- **asserções**: cada manifest contém `"version": "0.14.0"` e NÃO contém `"version": "0.13.0"`; `grep -rln '"version": "0.13.0"' tests/ | grep -v test-parada-revisao` vazio (nenhum assert positivo de 0.13.0 sobra).
- **ler**: `.claude-plugin/plugin.json:1-8`, `.claude-plugin/marketplace.json:1-15`, `tests/test-docs.sh:1-10`, `tests/test-corte-sem-uso.sh:45-55`, `tests/test-plano-mapa.sh:72-83`, `tests/test-prd-foto.sh:108-116`
- **done quando**: suíte `0`; total de asserts (soma de `PASS=`) = total antes da demanda + asserts novos de `tests/test-parada-revisao.sh`, sem queda.

- [x] **red** — `bash tests/test-parada-revisao.sh` falha em "parada-revisao/10" (0.13.0)
- [x] **green** — `log=$(mktemp); bash tests/run.sh > "$log" 2>&1; echo $?` → `0`; `grep -o 'PASS=[0-9]*' "$log" | cut -d= -f2 | awk '{s+=$1} END{print s}'`; `bash hooks/gate parada-revisao` → `GATE: passou` antes do commit
- [x] **commit** — `git add .claude-plugin/plugin.json .claude-plugin/marketplace.json tests/test-docs.sh tests/test-corte-sem-uso.sh tests/test-plano-mapa.sh tests/test-prd-foto.sh tests/test-parada-revisao.sh && git commit -m "chore(parada-revisao/10): versão 0.14.0"`

**Fim da execute.** No sync da validate (na `main`): meta 5 sai do `PRD.md`;
a arquitetura da validate cita `revisao-adversarial.md` entre as references;
versão 0.14.0 na Stack; 1 linha no `CHANGELOG.md`.
