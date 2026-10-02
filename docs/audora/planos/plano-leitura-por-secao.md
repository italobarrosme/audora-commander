# Plano — leitura-por-secao: Leitura por seção

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** toda fase carrega do `MEMORY.md` só o recorte de que precisa —
Propósito e Constituição inteiras, Aprendizados por busca (fase + termos do
nó, sem invalidados), Índice inteiro só na porta/scope/plan —, sem mudar o
formato; versão `0.15.0`; medição A/B com `claude -p` registrada no nó.

**Nó do MEMORY:** `leitura-por-secao` (MEMORY.md) — 12 critérios aprovados no
próprio nó.

**Arquitetura da mudança:** a regra mora num lugar só, a operação
`carregar-contexto` de `skills/memory/SKILL.md`, com os comandos `grep`
literais de cada recorte; as 7 skills de fase e o template do subagente só
apontam `carregar-contexto (skill memory)`. Aprendizado é reconhecido pelo
formato da linha (`^- AAAA-MM-DD | `), então a busca não casa Constituição nem
Índice e dispensa recorte por awk. A guarda nova, `tests/test-leitura-por-secao.sh`,
é estática (frases dentro da seção) E comportamental: extrai os comandos do
próprio SKILL.md, troca os placeholders e roda numa fixture LF e CRLF. O limite
duro de bytes é o de `parada-revisao/9` (BASE ≤ 47773, validate ≤ 6139), mais
apertado que o teto 48000; o texto foi medido num ensaio a seco e cabe com
cortes de duplicação no memory. Por último, medição A/B (`expandir: sim`).

**Arquivos lidos antes de planejar:**
- `MEMORY.md:1-134` — Constituição (≤ 250 linhas por skill, executável só em
  `hooks/`/`tests/`, `gate: bash hooks/gate <id>`, `ferramenta-e2e: claude -p`);
  seções nas linhas 11/18/44/90; aprendizados usados: 48 (heredoc grande → Write),
  53 (frase quebrada não casa), 55/62 (exit de pipe), 60/84 (somar asserts
  sem `bc`), 64 (suíte > 120 s → background), 65 (asserir FRASE na seção), 67
  (`git add` com caminhos), 73/74 (bytes sem `\r`; `2>/dev/null` antes do
  `<`), 82 (`--plugin-dir` + `enabledPlugins:false`), 83 (polling de
  `claude -p`), 85 (fixture clonada herda branch), 86 (teto na tarefa que
  cresce), 87 (gate antes do commit).
- `docs/audora/memory/leitura-por-secao.md:1-71` — 12 critérios, fora de
  escopo, 13 decisões.
- `skills/memory/SKILL.md:1-142` — intro 14-16; reference ausente 48-52;
  regra de leitura seletiva 54-74 (item 1 na 58; bullets 66-67; "Já carregado"
  70-72); carregar-contexto 78-88; registrar-aprendizado 105-116 (`| <fase> |`
  na 113, guardado); "Conflito MEMORY vs código" 118-123; red flags 125-136.
- `skills/audora-commander/SKILL.md:15-35` (Contexto 23-25),
  `skills/scope/SKILL.md:15-30` (Contexto 20-22), `skills/plan/SKILL.md:1-108`
  (Contexto 21), `skills/execute/SKILL.md:17-37` (Reancorar 19-22),
  `skills/validate/SKILL.md:8-40` (`## Fluxo` 35, passo 1 na 37),
  `skills/e2e/SKILL.md:6-40` (`## Fluxo` 21), `skills/debug/SKILL.md:6-28`
  (linha 17 e `## Modo sintoma` 19).
- `templates/fase-subagente-template.md:1-20` (reancoragem na 9),
  `templates/MEMORY-template.md` (cabeçalhos 11/16/28/38, `[carga: sempre]`),
  `templates/plano-template.md`, `templates/bloco-fechamento-template.md`.
- `tests/test-carga.sh:1-22` (tetos 14-15; medição na 6),
  `tests/test-skills.sh:18-78,185-204` (guardas do roteador memory: `| <fase> |`,
  `Já carregado nesta sessão`, `estado índice↔nó`),
  `tests/test-corte-sem-uso.sh:12-14,49-51` (awk do carregar-contexto por
  `^### 1\. carregar-contexto`; versão), `tests/test-gate.sh:77-78`,
  `tests/test-contexto-por-fase.sh:25-40` (`reancore só pelos artefatos em disco`),
  `tests/test-parada-revisao.sh:1-12,46-60,104-112` (`flat`; **validate ≤ 6139
  e BASE ≤ 47773 na 53-59**; versão 106-110), `tests/test-plano-mapa.sh:7-16,74-80`,
  `tests/test-prd-foto.sh:111-113`, `tests/test-docs.sh:1-21`,
  `tests/test-dogfood.sh:1-22`, `tests/lib.sh:1-21`, `tests/run.sh:1-10`.
- `.claude-plugin/plugin.json:4`, `.claude-plugin/marketplace.json:9` — `0.14.0`.
- `README.md:105-115,128-140`, `README.pt-BR.md:105-115,128-140` (porta e
  memory: "loads the context" / "Selective reading"), `docs/fundamentos.md:30-45`
  ("Carga seletiva": "o `MEMORY.md` inteiro … entra em toda demanda", 36-38).
- `docs/audora/planos/arquivo/plano-plano-mapa.md:1-140,604-700` e
  `docs/audora/arquivo/2026-10-01-plano-mapa.md` (`## medicao`) — precedente de
  ensaio a seco, orçamento de bytes e A/B com `claude -p`;
  `docs/audora/e2e/e2e-corte-sem-uso.md:1-25` — receita de fixture.
- `PRD.md:1-150` — só leitura (o PRD segue a main; sync na validate).

**Conflitos MEMORY vs código encontrados:** nenhum. Duas observações:
(1) o `resumo` do nó e a linha do índice ainda citavam `PRD.md` e
arquivos-base, descartados pelo humano em 2026-10-02 — corrigidos nesta fase;
(2) `tests/test-parada-revisao.sh:53-59` congela validate ≤ 6139 e BASE ≤ 47773,
abaixo do teto 48000 que o escopo considerou — o plano cabe nos dois, sem
mexer em guarda antiga.

## Notas de sessão

- 2026-10-02 (plan): ensaio a seco numa cópia `git archive HEAD` no
  scratchpad, com os textos exatos de T1 e T2: `test-carga` base=47678
  full=55305 (HEAD: 47723 / 55350); validate 6134 bytes; memory 7261 → 7294.
  `test-skills` 217/0, `test-corte-sem-uso` 38/0, `test-gate` 52/0,
  `test-contexto-por-fase` 34/0, `test-templates` 31/0, `test-plano-mapa` 50/0,
  `test-parada-revisao` verde com os textos finais. Os comandos extraídos do
  texto novo, rodados na fixture da T1 (LF e CRLF), deram exatamente as saídas
  das asserções da T1.
- Descartado no ensaio: frases de contexto por fase (`carregar-contexto da
  fase X`) — +62 B no validate estouravam o 6139; a fase é sabida por quem
  chama. Descartado: manter "Conflito MEMORY vs código" e a red flag de
  references — sem esses cortes BASE fica em 47836.
- 2026-10-02 (execute T1): red 20/28 (frases e comandos ausentes, sem erro
  de bash); green 48/0; memory 7294 B, `test-carga` base=47756 full=55383 (=
  mapa); `test-gate` 52/0; gate antes do commit `GATE: passou`, exit=0.
- 2026-10-02 (execute T2): red 50/11 (só a seção nova); green 61/0; validate
  6134 B, `test-carga` base=47678 full=55305 (= mapa); gate `GATE: passou`, exit=0.
- 2026-10-02 (execute T3): red 61/6 (o mapa diz "7 casos", mas lista 6
  asserções — são 6); green 67/0; `test-docs` 158/0; reembrulho do bullet
  da porta no README PT (troca no meio da linha); gate `GATE: passou`, exit=0.

## Decisões tomadas pela IA

1. Regra única no `carregar-contexto` do memory; fases apontam só
   `carregar-contexto (skill memory)`. Um ponto de verdade, menos bytes.
2. Comandos `grep` literais na skill; a guarda comportamental extrai os
   comandos do próprio SKILL.md e roda numa fixture — prova que o texto
   funciona, não só que existe.
3. Cortes para caber no limite de `parada-revisao/9`: intro do memory (a Lei de
   Ferro e o Schema já dizem), frase "Reference é atalho…" (repete "não
   interrompe nada"), bullets "nó que governa um arquivo" e "aprendizado por
   termo" (este vira o passo 3), seção "Conflito MEMORY vs código" (dona: plan,
   passo 4), red flag de references (repete o roteador) trocada pela do MEMORY
   inteiro. Tetos não sobem.
4. READMEs EN/PT e `docs/fundamentos.md` acompanham — o fundamento diria
   "MEMORY inteiro em toda demanda", falso depois desta entrega.
5. Versão: asserts de `0.14.0` trocados para `0.15.0`, não apagados.
6. Medição: A = `git archive e3c7242` (main, 0.14.0); fixture e scripts no
   scratchpad, sem versionar; a sessão principal roda e faz polling dos
   `claude -p` (aprendizado 83).

## Comandos comuns

- `SCRATCH` = scratchpad da sessão de execute.
- Teste da demanda: `bash tests/test-leitura-por-secao.sh; echo "exit=$?"`
- Carga: `bash tests/test-carga.sh` → `carga MEDIUM (bytes): base=<n> full=<n>`.
- Guarda antiga de bytes: `bash tests/test-parada-revisao.sh; echo "exit=$?"`.
- Gate (passa de 120 s → `run_in_background`, ler o log inteiro, nunca `| tail`):
  `bash hooks/gate leitura-por-secao > "$SCRATCH/gate.log" 2>&1; echo "exit=$?"` →
  `GATE: passou`, `exit=0`. Rodar ANTES do commit de cada tarefa (aprendizado 87)
  e anotar nas notas de sessão.

---

## Tarefa 1: carregar-contexto lê o MEMORY.md por seção

- **depende-de**: []
- **requisito**:
  - **leitura-por-secao/1** — QUANDO qualquer fase (porta de entrada, scope, plan, execute, e2e, validate, debug) carregar o contexto do `MEMORY.md` O SISTEMA DEVE ler as seções Propósito e Constituição inteiras e, de Aprendizados e Índice de nós, só o recorte dos critérios /2 a /6 — nunca o arquivo inteiro, salvo o fallback de /8.
  - **leitura-por-secao/2** — QUANDO scope, plan, execute, e2e, validate ou debug carregar Aprendizados O SISTEMA DEVE carregar só as linhas cujo campo de fase é a própria fase mais as linhas que casam as keywords ou os arquivos-chave do nó da demanda.
  - **leitura-por-secao/3** — QUANDO a porta de entrada carregar Aprendizados O SISTEMA DEVE carregar só as linhas que casam os termos do pedido do humano.
  - **leitura-por-secao/4** — QUANDO uma linha de Aprendizados estiver marcada `[invalidado-em: …]` O SISTEMA NÃO DEVE carregá-la em nenhuma fase.
  - **leitura-por-secao/5** — QUANDO nenhuma linha de Aprendizados casar o filtro O SISTEMA DEVE seguir a fase sem aprendizados, sem ler a seção inteira.
  - **leitura-por-secao/6** — QUANDO a porta de entrada, scope ou plan carregar o Índice de nós O SISTEMA DEVE ler a seção inteira; QUANDO execute, e2e, validate ou debug carregar O SISTEMA DEVE pegar por busca só a linha do nó da demanda e as dos nós em `depende-de`, sem ler a seção.
  - **leitura-por-secao/7** — QUANDO o recorte já tiver sido carregado nesta sessão (sem `/clear` nem compactação depois) O SISTEMA DEVE reusá-lo do contexto, sem reler.
  - **leitura-por-secao/8** — QUANDO uma seção esperada (`## Propósito`, `## Constituição`, `## Aprendizados`, `## Índice de nós`) não for encontrada no `MEMORY.md` O SISTEMA DEVE avisar em 1 linha qual seção faltou, ler o arquivo inteiro e seguir a fase.
  - **leitura-por-secao/9** — QUANDO um projeto tiver `MEMORY.md` no formato atual (`memory-schema: 1`, marcadores `[carga: sempre]`) O SISTEMA NÃO DEVE exigir nenhuma edição nele: template e marcadores ficam como estão e o `memory-validate` segue aceitando o arquivo.
- **decisões relevantes**: nó — Aprendizados = fase + keywords/arquivos sem
  invalidadas; Índice inteiro só porta/scope/plan; seção faltando → aviso +
  inteiro; marcadores ficam; filtro vazio não cai para a seção; debug sem nó
  usa os termos do sintoma. IA 1, 2, 3.
- **interfaces**: produz, no `carregar-contexto`, 3 comandos literais em
  crase, consumidos pela guarda e pela T2:
  `grep -n '^## ' MEMORY.md` ·
  `grep -iE '^- [0-9-]{10} \| .*(<termo>|<termo>)' MEMORY.md | grep -vF '[invalidado-em:'` (porta) ·
  `grep -iE '^- [0-9-]{10} \| (<fase> \||.*(<termo>|<termo>))' MEMORY.md | grep -vF '[invalidado-em:'` (demais fases) ·
  `grep -E '^- (<id>|<dep>) \|' MEMORY.md` (índice).
- **ponto de mudança** (`skills/memory/SKILL.md`, texto medido no ensaio):
  - `:14-17` — sai o parágrafo "O MEMORY é a memória externa durável…" e a linha em branco seguinte.
  - `:50-52` — sai "Reference é atalho para o corpo da operação, não portão."; fica `**sem travar a fase**.` e, em nova linha, `Instalação sem \`references/\` é instalação quebrada: avise o humano para` / `reinstalar o plugin.`
  - `:58` — item 1 vira `1. O recorte do \`MEMORY.md\` da fase (carregar-contexto), nunca o arquivo` / `   inteiro.`
  - `:66-67` — saem os bullets "nó que governa um arquivo" e "aprendizado por termo".
  - `:70-72` — `**Já carregado nesta sessão** (recorte do \`MEMORY.md\` lido, sem \`/clear\`` / `nem compactação depois) → reusar do contexto: não reinvocar a skill nem` / `reler. Depois de \`/clear\` ou compactação, recarregar.`
  - `:78-85` — título e passos 1-3 trocados pelo bloco abaixo; o antigo passo 4 (gate) vira 6, intacto:
    ```
    ### 1. carregar-contexto (toda fase: `MEMORY.md` por seção, nunca inteiro)

    1. `grep -n '^## ' MEMORY.md` → linha de cada seção. Sem `MEMORY.md` →
       **bootstrap** (operação 2), nunca inventar um. Faltou `## Propósito`, `## Constituição`, `## Aprendizados` ou `## Índice de nós` → avisar em 1 linha qual seção faltou, ler o arquivo inteiro e seguir a fase.
    2. Propósito e Constituição: inteiras, Read por `offset`/`limit`.
    3. Aprendizados só por busca; `[invalidado-em:` nunca entra; nada casou →
       seguir sem aprendizados, sem ler a seção:
       - porta de entrada, termos do pedido: `<comando porta>`
       - demais fases, a fase + keywords e arquivos-chave do nó (debug sem nó: termos do sintoma): `<comando demais fases>`
    4. Índice de nós: inteiro na porta de entrada, scope e plan; execute, e2e,
       validate e debug pegam só a linha do nó e as de `depende-de`:
       `grep -E '^- (<id>|<dep>) \|' MEMORY.md`.
    5. Read SÓ de `docs/audora/memory/<id>.md` dos nós relacionados.
    ```
    (`<comando porta>` e `<comando demais fases>` = os de **interfaces**, em crase, cada um inteiro numa linha — aprendizado 53.)
  - `:118-124` — sai a seção `## Conflito MEMORY vs código` e a linha em branco seguinte.
  - `:131` — a linha da red flag "Leio todas as references…" vira `| "Leio o MEMORY.md inteiro" | Recorte da fase; o resto, grep. |`
- **teste**: `tests/test-leitura-por-secao.sh` (NOVO; cabeçalho de 2 linhas
  citando o nó; `source lib.sh`; `cd "$ROOT"`; helper `flat` copiado de
  `tests/test-parada-revisao.sh:8-14`). Seção `# --- /1–/9 — carregar-contexto por seção ---`:
  - casos estáticos "leitura-por-secao/<n> …" sobre `cc` = seção extraída por
    `awk '/^### 1\. carregar-contexto/{f=1;next} /^### /{f=0} f'` e achatada, e
    `m` = arquivo inteiro achatado;
  - casos comportamentais "leitura-por-secao/<n> comando …": comandos extraídos
    de `cc` com `grep -oE` dos trechos em crase que começam por `grep -n '`,
    `grep -iE '` (1º = porta, 2º = demais) e `grep -E '`; placeholders trocados
    por expansão de string (`<fase>`, `<termo>|<termo>`, `<id>|<dep>`);
    executados com `(cd "$FX" && bash -c "$cmd")`; saída reduzida a ids
    (`tr -d '\r' | sed -E 's/^- [0-9-]{10} \| [a-z0-9]+ \| ([A-Z0-9]+) .*/\1/'`
    para aprendizado; 1º campo para índice) e juntada por espaço.
  - Fixture `$SP/fx/MEMORY.md` (via `printf`, não heredoc longo): `memory-schema: 1`;
    `## Propósito [carga: sempre]` + `Loja de teste.`; `## Constituição [carga: sempre]` +
    `- **stack**: bash; cache em disco.`; `## Aprendizados [carga: sempre]` +
    `- 2026-01-01 | plan | P1 plano sem termo`,
    `- 2026-01-02 | execute | E1 teste do cache`,
    `- 2026-01-03 | execute | E2 nada a ver`,
    `- 2026-01-04 | plan | P2 velho [invalidado-em: 2026-02-01] [substituido-por: P1]`,
    `- 2026-01-05 | validate | V1 deploy [invalidado-em: 2026-02-01] [substituido-por: E1]`,
    `- 2026-01-06 | e2e | X1 Cache maiusculo`;
    `## Índice de nós [carga: sempre]` +
    `- checkout | in-progress | Checkout | Fecha pedido com cache | cache, pedido | src/`,
    `- pagamento | planned | Pagamento | Cobra o pedido | deploy, pagamento | src/pay`,
    `- outro | planned | Outro | Nada | outro | —`. Cópia CRLF em `$SP/fxcr/`
    (`perl -pe 's/\n/\r\n/'`); cópia sem o bloco `## Aprendizados` em `$SP/fxsem/`.
- **asserções**:
  - /1: `m` contém `### 1. carregar-contexto (toda fase: \`MEMORY.md\` por seção, nunca inteiro)`, `1. O recorte do \`MEMORY.md\` da fase (carregar-contexto), nunca o arquivo inteiro.` e NÃO contém `é pequeno por construção` nem `Ler \`MEMORY.md\`. Ausente`; `cc` contém `Propósito e Constituição: inteiras, Read por \`offset\`/\`limit\``.
  - /2: `cc` contém `demais fases, a fase + keywords e arquivos-chave do nó (debug sem nó: termos do sintoma)`; comando demais fases com `<fase>`=plan, termos `cache|deploy` → `P1 E1 X1`; com `<fase>`=execute → `E1 E2 X1`.
  - /3: `cc` contém `porta de entrada, termos do pedido`; comando porta, termos `cache|deploy` → `E1 X1`.
  - /4: `cc` contém `` `[invalidado-em:` nunca entra ``; nenhuma das 3 saídas acima contém `P2` nem `V1`; no `MEMORY.md` do repo, comando demais fases com `plan` e `leitura|secao` → nenhuma linha com `[invalidado-em:` e menos bytes que a seção Aprendizados inteira.
  - /5: `cc` contém `nada casou → seguir sem aprendizados, sem ler a seção`; comando demais fases com `debug` e `zzz` → saída vazia.
  - /6: `cc` contém `Índice de nós: inteiro na porta de entrada, scope e plan; execute, e2e, validate e debug pegam só a linha do nó e as de \`depende-de\``; comando índice com `checkout|pagamento` → `checkout pagamento`.
  - /7: `m` contém `**Já carregado nesta sessão** (recorte do \`MEMORY.md\` lido, sem \`/clear\` nem compactação depois)`.
  - /8: `cc` contém `avisar em 1 linha qual seção faltou, ler o arquivo inteiro e seguir a fase`; comando seções em `fx` → `Propósito Constituição Aprendizados Índice` (1ª palavra após `## `); em `fxsem` → `Propósito Constituição Índice`.
  - /9: para cada `n` em Propósito, Constituição, Aprendizados, `Índice de nós`: `grep -qxF "## $n [carga: sempre]" templates/MEMORY-template.md` (0) e `cc` contém `` `## $n` ``; `run_hook memory-validate "$ROOT/MEMORY.md"` → code 0.
  - CRLF: os 6 casos comportamentais em `fxcr` → as mesmas saídas de `fx`.
- **ler**: `skills/memory/SKILL.md:1-142`, `tests/test-parada-revisao.sh:1-14`,
  `tests/test-corte-sem-uso.sh:10-14`, `tests/lib.sh:1-21`.
- **done quando**: teste da demanda `exit=0`; `test-carga` base = 47756
  (≤ 47773) — se diferir, conferir o texto contra este mapa antes de seguir;
  `test-skills`, `test-corte-sem-uso`, `test-gate`, `test-parada-revisao` e
  `test-dogfood` verdes; gate `exit=0`.

- [x] **red** — `bash tests/test-leitura-por-secao.sh; echo "exit=$?"` → `exit=1`, FAILs de "não contém" nas frases novas e saídas vazias nos casos comportamentais (comandos ausentes no HEAD); nenhum erro de sintaxe do bash no stderr.
- [x] **green** — mesmo comando `exit=0`; carga e guardas do done verdes; gate antes do commit.
- [x] **commit** — `git add skills/memory/SKILL.md tests/test-leitura-por-secao.sh && git commit -m "feat(leitura-por-secao/1-9): carregar-contexto lê o MEMORY.md por seção — seções fixas, aprendizados por busca, índice por fase"`

## Tarefa 2: as fases carregam pelo carregar-contexto

- **depende-de**: [1]
- **requisito**:
  - **leitura-por-secao/1** — QUANDO qualquer fase (porta de entrada, scope, plan, execute, e2e, validate, debug) carregar o contexto do `MEMORY.md` O SISTEMA DEVE ler as seções Propósito e Constituição inteiras e, de Aprendizados e Índice de nós, só o recorte dos critérios /2 a /6 — nunca o arquivo inteiro, salvo o fallback de /8.
  - **leitura-por-secao/6** — QUANDO a porta de entrada, scope ou plan carregar o Índice de nós O SISTEMA DEVE ler a seção inteira; QUANDO execute, e2e, validate ou debug carregar O SISTEMA DEVE pegar por busca só a linha do nó da demanda e as dos nós em `depende-de`, sem ler a seção.
- **decisões relevantes**: IA 1 (frase única); nota de sessão (frase por fase descartada: validate ≤ 6139).
- **interfaces**: consome a operação `carregar-contexto` da T1; produz a frase `carregar-contexto (skill memory)` em cada fase.
- **ponto de mudança** (trocas exatas, cada uma casando 1 vez):
  - `skills/audora-commander/SKILL.md:23-24` — `1. **Contexto**: skill \`memory\`, operação carregar-contexto (Constituição +` / `   Aprendizados + índice de nós). MEMORY ausente` → `1. **Contexto**: carregar-contexto (skill memory). MEMORY ausente`
  - `skills/scope/SKILL.md:20-21` — `1. **Contexto**: carregar constituição + nós relacionados (skill memory,` / `   operação carregar-contexto). Nó da demanda` → `1. **Contexto**: carregar-contexto (skill memory). Nó da demanda`
  - `skills/plan/SKILL.md:21` — `carregar nó da demanda + constituição (skill memory). Ler o` → `carregar-contexto (skill memory). Ler o`
  - `skills/execute/SKILL.md:19-20` — `e o nó do` / `   MEMORY. MEDIUM/HIGH` → `e o nó;` / `   carregar-contexto (skill memory). MEDIUM/HIGH`
  - `skills/validate/SKILL.md:35-37`, `skills/e2e/SKILL.md:21-23` — entre `## Fluxo` e o passo 1, parágrafo novo `Contexto: carregar-contexto (skill memory).` cercado de linha em branco.
  - `skills/debug/SKILL.md:17-19` — o mesmo parágrafo entre a linha 17 e `## Modo sintoma`.
  - `templates/fase-subagente-template.md:9` — `artefatos em disco: MEMORY.md, docs/` → `artefatos em disco: o recorte do MEMORY.md (carregar-contexto), docs/`
- **teste**: `tests/test-leitura-por-secao.sh`, seção `# --- /1 /6 — as 7 fases carregam pelo carregar-contexto ---`, casos "leitura-por-secao/1 <fase> carrega pelo carregar-contexto".
- **asserções**:
  - para `s` em audora-commander scope plan execute e2e validate debug: `flat skills/$s/SKILL.md` contém `carregar-contexto (skill memory)`.
  - `flat skills/audora-commander/SKILL.md` NÃO contém `operação carregar-contexto (Constituição + Aprendizados + índice de nós)`; scope NÃO contém `carregar constituição + nós relacionados`; plan NÃO contém `carregar nó da demanda + constituição`.
  - `flat templates/fase-subagente-template.md` contém `o recorte do MEMORY.md (carregar-contexto)` e segue contendo `reancore só pelos artefatos em disco`.
  - `tr -d '\r' < skills/validate/SKILL.md | wc -c` ≤ 6139 (esperado 6134).
- **ler**: `skills/audora-commander/SKILL.md:20-27`, `skills/scope/SKILL.md:18-24`,
  `skills/plan/SKILL.md:19-24`, `skills/execute/SKILL.md:17-23`,
  `skills/validate/SKILL.md:33-40`, `skills/e2e/SKILL.md:19-25`,
  `skills/debug/SKILL.md:15-21`, `templates/fase-subagente-template.md:7-11`.
- **done quando**: teste da demanda `exit=0`; `test-carga` base = 47678
  (≤ 47773); `test-parada-revisao`, `test-contexto-por-fase`, `test-skills`
  verdes; gate `exit=0`.

- [x] **red** — teste da demanda `exit=1` só nos casos da seção nova (7 fases sem a frase, 3 frases antigas presentes, template sem o recorte); seção da T1 verde.
- [x] **green** — `exit=0`; carga 47678; guardas verdes; gate antes do commit.
- [x] **commit** — `git add skills/audora-commander/SKILL.md skills/scope/SKILL.md skills/plan/SKILL.md skills/execute/SKILL.md skills/validate/SKILL.md skills/e2e/SKILL.md skills/debug/SKILL.md templates/fase-subagente-template.md tests/test-leitura-por-secao.sh && git commit -m "feat(leitura-por-secao/1,6): as 7 fases e o subagente carregam o MEMORY pelo carregar-contexto"`

## Tarefa 3: READMEs e fundamentos descrevem a leitura por seção

- **depende-de**: [2]
- **requisito**: **leitura-por-secao/1** — QUANDO qualquer fase (porta de entrada, scope, plan, execute, e2e, validate, debug) carregar o contexto do `MEMORY.md` O SISTEMA DEVE ler as seções Propósito e Constituição inteiras e, de Aprendizados e Índice de nós, só o recorte dos critérios /2 a /6 — nunca o arquivo inteiro, salvo o fallback de /8.
- **decisões relevantes**: IA 4; README principal em inglês com PT espelhado (Constituição).
- **interfaces**: nenhuma.
- **ponto de mudança**:
  - `README.md:110-111` — `loads the context (skill \`memory\`: Constitution,` / `Learnings and node index;` → `loads the context (skill \`memory\`: Constitution,` / `the Learnings that match the request and the node index;`
  - `README.md:135-136` — `Selective reading` / `(index + only the nodes the demand touches; grep for structural queries)` → `Selective reading (\`MEMORY.md\` by section: Purpose and Constitution whole, Learnings by grep on the phase and the node's terms, invalidated ones never, the node index whole only at the entry, scope and plan; only the nodes the demand touches; grep for structural queries)`
  - `README.pt-BR.md:110-111` — `Constituição,` / `Aprendizados e índice de nós;` → `Constituição,` / `os Aprendizados que casam o pedido e o índice de nós;`
  - `README.pt-BR.md:135-136` — `Leitura seletiva` / `(índice + só os nós que a demanda toca; grep para consulta estrutural)` → `Leitura seletiva (\`MEMORY.md\` por seção: Propósito e Constituição inteiras, Aprendizados por grep na fase e nos termos do nó, nunca os invalidados, índice de nós inteiro só na porta, no scope e no plan; só os nós que a demanda toca; grep para consulta estrutural)`
  - `docs/fundamentos.md:36-38` — `o \`MEMORY.md\` inteiro` / `(\`[carga: sempre]\` — enxuto, cabe em qualquer contexto) entra em toda` / `demanda;` → `o \`MEMORY.md\` entra` / `por seção em toda fase — Propósito e Constituição inteiras, Aprendizados` / `por busca (fase e termos do nó, sem invalidados), Índice inteiro só na` / `porta, no scope e no plan e só a linha do nó nas outras;`
  - Quebrar as linhas novas em ≤ 80 colunas, como o entorno.
- **teste**: `tests/test-leitura-por-secao.sh`, seção `# --- /1 docs ---`, casos "leitura-por-secao/1 docs …".
- **asserções**: `flat README.md` contém `` `MEMORY.md` by section `` e `the Learnings that match the request`; `flat README.pt-BR.md` contém `` `MEMORY.md` por seção `` e `os Aprendizados que casam o pedido`; `flat docs/fundamentos.md` contém `` o `MEMORY.md` entra por seção em toda fase `` e NÃO contém `` o `MEMORY.md` inteiro ``.
- **ler**: `README.md:105-140`, `README.pt-BR.md:105-140`, `docs/fundamentos.md:30-45`.
- **done quando**: teste da demanda `exit=0`; `test-docs` verde; gate `exit=0`.

- [x] **red** — teste da demanda `exit=1` só nos 7 casos de docs.
- [x] **green** — `exit=0`; `test-docs` verde; gate antes do commit.
- [x] **commit** — `git add README.md README.pt-BR.md docs/fundamentos.md tests/test-leitura-por-secao.sh && git commit -m "docs(leitura-por-secao/1): READMEs EN/PT e fundamentos descrevem a leitura do MEMORY por seção"`

## Tarefa 4: versão 0.15.0 e carga dentro dos tetos

- **depende-de**: [3]
- **requisito**:
  - **leitura-por-secao/11** — QUANDO as skills mudarem O SISTEMA DEVE manter a carga BASE e FULL de `tests/test-carga.sh` dentro dos tetos vigentes (48000 / 56900); subir teto só com o motivo registrado no nó.
  - **leitura-por-secao/12** — QUANDO o plugin for reinstalado O SISTEMA DEVE declarar a versão `0.15.0` em `plugin.json` e `marketplace.json`.
- **decisões relevantes**: bump `0.15.0` (IA, nó); tetos mantidos (IA, nó); IA 5.
- **interfaces**: nenhuma.
- **ponto de mudança**:
  - `.claude-plugin/plugin.json:4`, `.claude-plugin/marketplace.json:9` — `"0.14.0"` → `"0.15.0"`.
  - Asserts de versão trocados, rótulo `leitura-por-secao/12 $j declara 0.15.0 (substitui parada-revisao/10)`, comentários junto: `tests/test-docs.sh:7`, `tests/test-corte-sem-uso.sh:49-51`, `tests/test-plano-mapa.sh:74,79`, `tests/test-prd-foto.sh:111-113`, `tests/test-parada-revisao.sh:106-109` (os `assert_not_contains` de versões antigas ficam).
  - `tests/test-carga.sh:6` — acrescentar `; leitura-por-secao: BASE 47723 → 47678 / FULL 55350 → 55305` (números do ensaio; se o `test-carga` desta tarefa der outro, usar o real e anotar por quê). `TETO_BASE`/`TETO_FULL` intactos.
- **teste**: `tests/test-leitura-por-secao.sh`, seção `# --- /11 /12 — carga e versão ---`.
- **asserções**:
  - /11: `tests/test-carga.sh` contém `TETO_BASE=48000` e `TETO_FULL=56900`; `bash tests/test-carga.sh` sai 0; `base` ≤ 47773 (guarda de `parada-revisao/9`).
  - /12: cada manifest contém `"version": "0.15.0"` e NÃO contém `"version": "0.14.0"`; `grep -rlF '"version": "0.14.0"' tests/ | grep -v test-leitura-por-secao` → vazio.
- **ler**: `.claude-plugin/plugin.json:1-8`, `.claude-plugin/marketplace.json:1-14`, `tests/test-docs.sh:5-8`, `tests/test-corte-sem-uso.sh:47-55`, `tests/test-plano-mapa.sh:72-83`, `tests/test-prd-foto.sh:109-115`, `tests/test-parada-revisao.sh:104-115`, `tests/test-carga.sh:1-22`.
- **done quando**: teste da demanda `exit=0`; `bash tests/run.sh > "$SCRATCH/run.log" 2>&1; echo "exit=$?"` → `exit=0` (background; total de asserts somado do log, aprendizado 84); gate `exit=0`.

- [ ] **red** — teste da demanda `exit=1` só nos casos de /12 (manifests em 0.14.0; 5 asserts positivos de 0.14.0 em `tests/`).
- [ ] **green** — `exit=0`; suíte toda `exit=0`; gate antes do commit.
- [ ] **commit** — `git add .claude-plugin/plugin.json .claude-plugin/marketplace.json tests/test-docs.sh tests/test-corte-sem-uso.sh tests/test-plano-mapa.sh tests/test-prd-foto.sh tests/test-parada-revisao.sh tests/test-carga.sh tests/test-leitura-por-secao.sh && git commit -m "chore(leitura-por-secao/11,12): versão 0.15.0; carga BASE/FULL dentro dos tetos"`

## Tarefa 5: medição A/B com claude -p

- **depende-de**: [4]
- **expandir: sim** — quebrar em subtarefas quando chegar a vez (fixture, plugin A, sessões A/B por fase, extração, registro).
- **requisito**: **leitura-por-secao/10** — QUANDO a demanda for medida O SISTEMA DEVE registrar em `## medicao` do nó, para a mesma demanda MEDIUM numa fixture rodada com `claude -p` antes × depois (n=1), os bytes lidos do `MEMORY.md` por fase e o custo de cada sessão; o depois lê menos bytes do `MEMORY.md` que o antes em toda fase.
- **decisões relevantes**: prova = A/B real com `claude -p` + guarda estática (humano); IA 6; aprendizados 57, 58, 75, 82, 83, 85.
- **o que já está decidido para a expansão**:
  - Plugin A: `mkdir -p "$SCRATCH/plugin-0.14.0" && git archive e3c7242 | tar -x -C "$SCRATCH/plugin-0.14.0"` (conferir `"version": "0.14.0"`). Plugin B: este repo no HEAD da branch depois da T4.
  - Fixture: script `$SCRATCH/fixture-leitura.sh <dir>` (Write, não heredoc): `git init -b main`, `core.excludesFile` inexistente, CLI bash pequeno com `tests/run.sh` verde, `PRD.md` curto, `MEMORY.md` `memory-schema: 1` com `gate: recusado` e tamanho próximo ao deste repo (≥ 15 KB): ≥ 35 Aprendizados de todas as fases (≥ 5 invalidados, ≥ 3 citando termos da demanda) e ≥ 25 nós no índice (entregues apontando arquivos que existem em `docs/audora/arquivo/`). Duas cópias, `fx-a` e `fx-b`; só a branch `main` (aprendizado 85).
  - Sessões (`~/.local/bin/claude.exe -p`, background, `> X.jsonl 2> X.err`, lidas inteiras): `--plugin-dir <A|B> --settings '{"enabledPlugins":{"audora-commander@audora-commander-dev":false}}' --permission-mode acceptEdits --output-format stream-json --verbose`. Mesmo pedido e mesmas respostas nos dois lados: (1) pedido à porta → scope (respostas do scope por `--resume <session_id>`, texto fixo em `$SCRATCH/respostas.txt`); (2) `plan de <id>`; (3) `execute de <id>`; (4) `e2e de <id>`; (5) `validate de <id>` até o portão, sem aprovar. Rodadas pela sessão principal com polling ativo (aprendizado 83).
  - Extração: `$SCRATCH/bytes-memory.pl <jsonl>` (perl `JSON::PP`): soma os bytes do `tool_result` de cada `tool_use` que lê o `MEMORY.md` da raiz — Read com `file_path` terminando em `/MEMORY.md` fora de `docs/audora/memory/`, Grep com `path` nesse arquivo, Bash cujo `command` cita `MEMORY.md` fora de `docs/audora/memory/`; a fase é a da última Skill de fase invocada antes da chamada (porta e scope se separam na mesma sessão). Custo: `total_cost_usd` de cada evento `result`, somado por turno.
- **arquivos**: Modificar `docs/audora/memory/leitura-por-secao.md` (`## medicao` nova, entre `## decisoes` e `## delta`: tabela fase × bytes A / B / B÷A × custo A / B, e a receita em 3-5 linhas). Nenhum arquivo do plugin muda.
- **done quando**: `## medicao` tem as 6 fases (porta, scope, plan, execute, e2e, validate) com bytes e custo dos dois lados e B < A em todas; gate `exit=0`; commit `docs(leitura-por-secao/10): medição A/B …`. Fase com B ≥ A NÃO é registrada como aceita: é defeito da skill → debug (por que leu inteiro), corrigir o texto, re-rodar o lado B daquela fase e anotar.
