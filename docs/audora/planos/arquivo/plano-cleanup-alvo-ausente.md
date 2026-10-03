# Plano — cleanup-alvo-ausente: Alvo ausente só se existiu

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** o `hooks/cleanup` só lista planned órfão por "alvo ausente"
quando o caminho citado em arquivos-chave já foi versionado em commit
alcançável do HEAD e sumiu do disco; caminho que nunca existiu (feature
futura) fica fora do relatório, em silêncio.

**Nó do MEMORY:** `cleanup-alvo-ausente` (MEMORY.md)

**Arquitetura da mudança:** o filtro `!-e $_` de `classifica_orfaos`
(`hooks/cleanup:115`) ganha um segundo filtro, `existiu($_)`, que pergunta ao
git só pelos caminhos ausentes do disco:
`git --no-optional-locks --literal-pathspecs log -1 --full-history --format=%H HEAD -- <caminho>`
(saída não vazia = existiu). Uma chamada por caminho ausente (normalmente
poucos), `-1` para cedo; pathspec de diretório casa arquivo sob ele (/5);
`HEAD` limita ao alcançável (/4); `--full-history` acha arquivo criado e
apagado em branch mergeada (sem ele o git simplifica o merge e não acha —
conferido em repo de rascunho). Sem commit nenhum, `existiu` devolve falso
sem chamar o `log` (/9). `contar` usa o mesmo `varre()`, então /8 vem junto.
A frase da skill muda para a IA só usar `--orfao <id>=alvo ausente:` depois
de conferir o histórico (/10).

**Arquivos lidos antes de planejar:**
- `hooks/cleanup:1-125` — wrapper bash→`perl -x`; parse do `--orfao`; `carrega_indice` (cols[5] = arquivos-chave); `item`; `dependentes`; `classifica_orfaos` com o filtro `grep { $_ ne '' && $_ ne '—' && !/[*<]/ && !-e $_ }` em :115-116 e motivo `alvo ausente: <join ', '>` em :117; mantido em :120 só quando há motivo
- `hooks/cleanup:244-328` — `git_z` (:248-252, `open '-|', 'git', '--no-optional-locks', @_`, stderr não redirecionado); `carrega_git`; `filtra_git`; `total`; `relatorio` (avisos primeiro, linhas ordenadas por `cmp`, `## mantido`, `## não tocado`, `total: N item(ns) no lote` | `cleanup: nada a limpar`); `varre()` em :322
- `hooks/cleanup:426-485` — `pre_checa`/`aplicar` não reavaliam alvo ausente (fora desta demanda); `contar` = `varre(); print total()` em :483
- `tests/lib.sh:1-21` — `assert_eq`, `assert_contains`, `assert_not_contains`, `assert_empty`, `$SP`, `report`
- `tests/run.sh:1-10` — roda todo `tests/test-*.sh`, exit 1 se algum falha
- `tests/test-skill-cleanup.sh:1-90` — `mkproj`, `addc`, `runc` (stdout+stderr em `$out`, `$code`), `snap`, `assert_line`, `secao`, `nov`
- `tests/test-skill-cleanup.sh:174-253` — `mkt5` (:178-186) com `q → src/sumiu.ts, README.md` e `r2 → src/nada.ts`, caminhos que NUNCA existiram; asserts skill-cleanup/4,5 em :192, :198, :199, :216 dependem deles; `t6m` (:246) reusa `mkt5`
- `tests/test-skill-cleanup.sh:370-395` — `t9c` reusa `mkt5` com `--orfao p=` (não depende do mecânico)
- `tests/test-skill-cleanup.sh:418-451` — bloco de asserts do texto da skill (`sk`, :428-440); `report` em :451
- `skills/cleanup/SKILL.md:10-50` — tabela (:24 "cita alvo que não existe mais"), passo 2 (:44 "confira no repo (Glob/Grep…)", :46 "Caminho inexistente na coluna arquivos-chave o script já acha sozinho.")
- `skills/cleanup/SKILL.md:84-90` — red flag :87 "alvo ausente conferido no repo"
- `hooks/gate:1-48` — anti-fraude: teste apagado, skip/only, contagem de asserts não pode cair
- `README.md:293`, `README.pt-BR.md:293` — "citing something that no longer exists" / "cita algo que não existe mais": continua verdade, sem mudança
- repo de rascunho (scratchpad) — `log -1 --full-history HEAD -- <p>`: `lib/antigo/` e `lib/antigo` acham o arquivo apagado sob a pasta; `lib/nova/`, caminho só em branch não mergeada e caminho com espaço nunca criado → vazio; arquivo criado+apagado em branch mergeada → só acha COM `--full-history`; sem commit → `fatal: bad revision 'HEAD'` no stderr, `rev-parse -q --verify HEAD` → exit 1 sem saída

**Conflitos MEMORY vs código encontrados:** nenhum. Nota: a linha do índice
lista `hooks/cleanup, tests/test-skill-cleanup.sh`; o /10 também toca
`skills/cleanup/SKILL.md` (previsto no escopo, "frase da skill").

## Notas de sessão

- 2026-10-03 (Tarefa 4): red → `FAIL: cleanup-alvo-ausente/10 skill: conferência com pathspec literal` (PASS=223 FAIL=1); mutante sem `--literal-pathspecs` → 5 FAIL incl. `[slug] literal`; green + `bash hooks/gate cleanup-alvo-ausente` antes do commit → `GATE: passou`, `test-skill-cleanup.sh: PASS=224 FAIL=0`.

## Decisões tomadas pela IA

- 2026-10-02 (execute, Tarefa 2): a fixture `semcommit` NÃO leva a linha
  `- d | delivered | D → docs/audora/arquivo/2026-01-01-d.md` do corpo do
  `mkproj` — sem o arquivo do nó, ela vira link quebrado fora do git e o
  relatório ganha `## não tocado` (comportamento do skill-cleanup/10,11,
  alheio ao /9), o que quebraria o `$out` exato mesmo no green. O índice
  fica só com o planned `x`. O assert de `contar` virou 2 (`code` e `$out`)
  com nomes próprios.

---

## Tarefa 1: `existiu` no filtro do alvo ausente + fixture do skill-cleanup/4,5

- **depende-de**: []
- **requisito**:
  - `cleanup-alvo-ausente/1` — QUANDO um nó planned cita em arquivos-chave um caminho ausente do disco que nunca foi versionado em commit alcançável do HEAD O SISTEMA DEVE deixá-lo fora do relatório inteiro (nem no lote, nem em `## mantido`, nem em outra seção), sem aviso
  - `cleanup-alvo-ausente/2` — QUANDO um nó planned cita em arquivos-chave um caminho que já foi versionado em commit alcançável do HEAD e não existe mais no disco O SISTEMA DEVE listá-lo como planned órfão com o motivo `alvo ausente: <caminho>`
  - `cleanup-alvo-ausente/3` — QUANDO um nó planned cita vários caminhos e só parte deles existiu e sumiu O SISTEMA DEVE listá-lo como planned órfão citando no motivo só os caminhos que existiram e sumiram
  - `cleanup-alvo-ausente/4` — QUANDO o caminho citado só foi versionado em branch não alcançável do HEAD O SISTEMA DEVE tratá-lo como nunca existiu (fora do relatório)
  - `cleanup-alvo-ausente/5` — QUANDO o caminho citado é diretório (termina em `/`) O SISTEMA DEVE considerá-lo versionado se algum arquivo sob ele foi versionado em commit alcançável do HEAD
  - `cleanup-alvo-ausente/6` — QUANDO o caminho citado existe hoje no disco O SISTEMA DEVE deixar o planned fora do relatório, como antes
  - `cleanup-alvo-ausente/7` — QUANDO a skill passa `--orfao <id>=<motivo>` para um planned O SISTEMA DEVE listá-lo com o motivo dado, mesmo que o caminho dele nunca tenha existido, como antes
  - `cleanup-alvo-ausente/8` — QUANDO `contar` roda O SISTEMA DEVE devolver o mesmo total que o `varrer`, sem contar planned cujo caminho nunca existiu
- **decisões relevantes**: "existiu" = versionado em commit alcançável do HEAD, nunca `--all` (decisão humana 2026-10-02); caminho misto cita só os que existiram e sumiram (idem); nunca-existiu fica silencioso, sem seção informativa (idem); glob/placeholder (`*`, `<`) continua pulado (fora-de-escopo); clone raso = erro conservador aceito. Ordem do motivo = ordem da coluna, `join ', '` (como hoje).
- **interfaces**: produz `existiu($caminho) → 1 | ''` — 1 se `git_z('--literal-pathspecs', 'log', '-1', '--full-history', '--format=%H', 'HEAD', '--', $caminho)` devolve ao menos 1 linha; definida em `hooks/cleanup` logo antes de `classifica_orfaos` (hoje :102). Consome `git_z(@args)` (:248, chamada com parênteses — definida mais abaixo no arquivo, ok em perl). Muda `classifica_orfaos()`: o `grep` de :115 passa a exigir `!-e $_ && existiu($_)`.
- **ponto de mudança**: `hooks/cleanup:115` — filtro de `@aus` em `classifica_orfaos`; `hooks/cleanup:101` — nova `sub existiu` + comentário de 1 linha; `tests/test-skill-cleanup.sh:184-185` — `mkt5` versiona e remove `src/sumiu.ts` e `src/nada.ts` antes do commit `t5` (`addc "$d" src/sumiu.ts x; addc "$d" src/nada.ts x; git -C "$d" rm -q src/sumiu.ts src/nada.ts`), senão skill-cleanup/4,5 (:192, :198, :199, :216) quebram com a regra nova; `tests/test-skill-cleanup.sh:217` — nova seção `# --- cleanup-alvo-ausente/1..8 alvo ausente só se existiu no HEAD ---` com a fixture `mkalvo` e os asserts abaixo; `tests/test-skill-cleanup.sh:2` — cabeçalho cita também `cleanup-alvo-ausente/1..10`.
- **teste**: `tests/test-skill-cleanup.sh`, fixture `mkalvo <dir>` (sobre `mkproj`):
  1. `addc src/velho.ts`, `addc lib/antigo/x.ts`, `git rm -q src/velho.ts lib/antigo/x.ts` + commit;
  2. `checkout -q -b outro`, `addc src/ramo.ts`, `checkout -q -` (ramo.ts só em branch não alcançável);
  3. `checkout -q -b feat`, `addc src/feat.ts`, `git rm -q src/feat.ts` + commit, `checkout -q -`, `merge -q --no-ff feat -m merge` (existiu em branch mergeada);
  4. índice ganha: `- nunca | planned | N | r | k | src/futuro.ts`, `- sumiu | planned | S | r | k | src/velho.ts`, `- misto | planned | M | r | k | src/velho.ts, src/futuro.ts, README.md, lib/antigo/`, `- pasta | planned | P | r | k | lib/antigo/`, `- pastanova | planned | PN | r | k | lib/nova/`, `- ramo | planned | R | r | k | src/ramo.ts`, `- fundido | planned | F | r | k | src/feat.ts`, `- presente | planned | PR | r | k | README.md`, `- v | in-progress | V | r | k | —`; `nov "$d" v in-progress 'nunca'` (dependente vivo do nunca-existiu); commit.
- **asserções** (`p="$SP/alvo"; mkalvo "$p"`):
  - `runc "$p" varrer` → `code` = `0` — "cleanup-alvo-ausente/1 varrer → exit 0"
  - `runc "$p" varrer` → `$out` exatamente igual a, linha a linha: `cleanup: relatório — nada foi alterado` / `## planned órfão` / `- fundido | alvo ausente: src/feat.ts` / `- misto | alvo ausente: src/velho.ts, lib/antigo/` / `- pasta | alvo ausente: lib/antigo/` / `- sumiu | alvo ausente: src/velho.ts` / `total: 4 item(ns) no lote` — "cleanup-alvo-ausente/1 relatório só com o que existiu e sumiu" (`assert_eq` com `printf '%s\n'` das 7 linhas)
  - `$out` não contém `nunca` — "cleanup-alvo-ausente/1 nunca-existiu fora do relatório, nem em mantido"
  - `secao "$out" 'planned órfão'` tem a linha `- sumiu | alvo ausente: src/velho.ts` — "cleanup-alvo-ausente/2 existiu e sumiu → órfão"
  - idem `- fundido | alvo ausente: src/feat.ts` — "cleanup-alvo-ausente/2 existiu em branch mergeada (alcançável)"
  - idem `- misto | alvo ausente: src/velho.ts, lib/antigo/` — "cleanup-alvo-ausente/3 motivo só com os que existiram e sumiram"
  - `$out` não contém `- ramo |` — "cleanup-alvo-ausente/4 só em branch não alcançável → fora"
  - `secao` tem `- pasta | alvo ausente: lib/antigo/` — "cleanup-alvo-ausente/5 diretório com arquivo versionado sob ele"
  - `$out` não contém `pastanova` — "cleanup-alvo-ausente/5 diretório nunca versionado → fora"
  - `$out` não contém `presente` — "cleanup-alvo-ausente/6 caminho existente no disco → fora"
  - `runc "$p" varrer --orfao 'pastanova=alvo ausente: lib/nova/'` → `secao` tem `- pastanova | alvo ausente: lib/nova/` — "cleanup-alvo-ausente/7 --orfao lista mesmo caminho que nunca existiu"; última linha = `total: 5 item(ns) no lote` — "cleanup-alvo-ausente/7 total com o --orfao"
  - `runc "$p" contar` → `code` = `0` e `$out` = `4` — "cleanup-alvo-ausente/8 contar = total do varrer"
- **ler**: `hooks/cleanup:102-123`, `hooks/cleanup:248-252`, `tests/test-skill-cleanup.sh:176-216`
- **done quando**: as asserções acima passam, skill-cleanup/3,4,5,11,14 continuam verdes com o `mkt5` novo, e `bash tests/run.sh` termina com `run.sh: 0 arquivo(s) de teste com falha`.

- [x] **red** — escrever `mkalvo` + asserts + ajuste do `mkt5` sem tocar `hooks/cleanup`; `bash tests/test-skill-cleanup.sh` falha com `FAIL: cleanup-alvo-ausente/1 relatório só com o que existiu e sumiu`, `cleanup-alvo-ausente/1 nunca-existiu fora do relatório, nem em mantido`, `cleanup-alvo-ausente/3 motivo só com os que existiram e sumiram`, `cleanup-alvo-ausente/4 só em branch não alcançável → fora`, `cleanup-alvo-ausente/5 diretório nunca versionado → fora`, `cleanup-alvo-ausente/7 total com o --orfao` e `cleanup-alvo-ausente/8 contar = total do varrer` (o `-e` cru lista nunca/pastanova/ramo e o misto cita `src/futuro.ts`); os de /2, /5 pasta, /6 e /7 linha passam (regressão) e nenhum `skill-cleanup/*` falha
- [x] **green** — implementar `existiu` + filtro em `hooks/cleanup:115`; `bash tests/test-skill-cleanup.sh` → `FAIL=0`; `bash tests/run.sh` → `run.sh: 0 arquivo(s) de teste com falha`
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(cleanup-alvo-ausente/1-8): alvo ausente só se o caminho existiu no histórico do HEAD"`

## Tarefa 2: repositório sem commit

- **depende-de**: [1]
- **requisito**: `cleanup-alvo-ausente/9` — QUANDO o repositório ainda não tem nenhum commit O SISTEMA DEVE tratar todo caminho ausente como nunca existiu e terminar a varredura sem erro
- **decisões relevantes**: "sem erro" = exit 0 e nenhuma linha `fatal:` do git no stdout/stderr; a checagem de HEAD roda uma vez por execução, pelo idioma já usado em `hooks/cleanup:36` (crase com `2>/dev/null`).
- **interfaces**: produz `tem_head() → 1 | ''` — 1 se `` `git rev-parse -q --verify HEAD 2>/dev/null` `` sai com `$? == 0`; resultado guardado em `my $TEM_HEAD` (calcula na 1ª chamada). Muda `existiu($caminho)` (Tarefa 1): `return '' unless tem_head();` antes do `git_z`.
- **ponto de mudança**: `hooks/cleanup` — `sub existiu` criada na Tarefa 1 (logo antes de `classifica_orfaos`) e nova `sub tem_head` ao lado dela; `tests/test-skill-cleanup.sh` — fim da seção da Tarefa 1, novo bloco `# --- cleanup-alvo-ausente/9 repositório sem commit ---`.
- **teste**: `tests/test-skill-cleanup.sh` — fixture inline: `p="$SP/semcommit"; rm -rf "$p"; mkdir -p "$p"; git -C "$p" init -q; git -C "$p" config core.excludesFile "$p/.nao-existe"` e `MEMORY.md` com o mesmo corpo do `printf` de `mkproj` (:13) + linha `- x | planned | X | r | k | src/x.ts`, sem `git add` nem commit.
- **asserções**:
  - `runc "$p" varrer` → `code` = `0` — "cleanup-alvo-ausente/9 sem commit varrer → exit 0"
  - `runc "$p" varrer` → `$out` = `cleanup: nada a limpar` (exato, sem `fatal:` nem `## não tocado`) — "cleanup-alvo-ausente/9 sem commit: caminho ausente = nunca existiu, sem erro"
  - `runc "$p" contar` → `code` = `0` e `$out` = `0` — "cleanup-alvo-ausente/9 sem commit contar → 0"
- **ler**: `hooks/cleanup:30-40`, a `sub existiu` da Tarefa 1
- **done quando**: as 3 asserções passam e `bash tests/run.sh` termina com `run.sh: 0 arquivo(s) de teste com falha`.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: cleanup-alvo-ausente/9 sem commit: caminho ausente = nunca existiu, sem erro` (o `$out` traz `fatal: bad revision 'HEAD'` do `git log` antes de `cleanup: nada a limpar`) e `cleanup-alvo-ausente/9 sem commit contar → 0`
- [x] **green** — `tem_head` + guarda em `existiu`; `bash tests/test-skill-cleanup.sh` → `FAIL=0`; `bash tests/run.sh` → `run.sh: 0 arquivo(s) de teste com falha`
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "fix(cleanup-alvo-ausente/9): repositório sem commit não chama o git log"`

## Tarefa 3: frase da skill cleanup

- **depende-de**: []
- **requisito**: `cleanup-alvo-ausente/10` — QUANDO a skill cleanup orienta o julgamento dos planned O SISTEMA DEVE dizer que o script só acha caminho que existiu e sumiu, e que a IA só usa `--orfao <id>=alvo ausente: <alvo>` depois de conferir no histórico que o alvo existiu
- **decisões relevantes**: Constituição — SKILL.md ≤ 250 linhas (hoje 97), prosa PT; frase com o `--orfao` numa linha só (o teste lê por linha); manter a string `--orfao <id>=alvo ausente: <alvo>` já exigida por skill-cleanup/12.
- **interfaces**: nenhuma de código. Texto novo, verbatim:
  - `skills/cleanup/SKILL.md:24` → `| planned órfão | nó planned já entregue/absorvido por um delivered, ou que cita alvo que existiu e não existe mais |`
  - `skills/cleanup/SKILL.md:44` → `   - cita skill, arquivo ou feature que existiu e sumiu → confira no histórico que o alvo existiu (`git log -1 --full-history --oneline HEAD -- <alvo>` não vazio; nunca de memória) e só então use `--orfao <id>=alvo ausente: <alvo>`. Alvo que nunca existiu é feature futura, não órfão.`
  - `skills/cleanup/SKILL.md:46` → `   O script só acha o caminho da coluna arquivos-chave que existiu no histórico e sumiu do disco; caminho que nunca existiu ele não lista.`
  - `skills/cleanup/SKILL.md:87` → `| "Esse planned parece velho, marco órfão" | Velho não é órfão. Só absorvido por delivered ou alvo ausente conferido no histórico. |`
- **ponto de mudança**: `skills/cleanup/SKILL.md:24`, `:44`, `:46`, `:87`; `tests/test-skill-cleanup.sh` — logo após a linha `… ko "skill-cleanup/12 SKILL.md ≤ 250 linhas"` (hoje :438), no bloco que já tem `sk`.
- **teste**: `tests/test-skill-cleanup.sh`, sobre `$sk` (SKILL.md sem `\r`).
- **asserções**:
  - `$sk` contém `O script só acha o caminho da coluna arquivos-chave que existiu no histórico e sumiu do disco` — "cleanup-alvo-ausente/10 skill: script só acha o que existiu e sumiu"
  - a linha de `$sk` que contém `confira no histórico que o alvo existiu` contém também `--orfao <id>=alvo ausente: <alvo>` (`grep -F` da 1ª, `assert_contains` da 2ª) — "cleanup-alvo-ausente/10 skill: --orfao alvo ausente só depois de conferir o histórico"
  - `$sk` não contém `Caminho inexistente na coluna arquivos-chave o script já acha sozinho` — "cleanup-alvo-ausente/10 skill: frase antiga removida"
  - `$sk` não contém `alvo ausente conferido no repo` — "cleanup-alvo-ausente/10 skill: red flag confere no histórico"
- **ler**: `skills/cleanup/SKILL.md:20-50`, `skills/cleanup/SKILL.md:84-90`, `tests/test-skill-cleanup.sh:428-440`
- **done quando**: as 4 asserções passam, skill-cleanup/12 continua verde (incluindo `--orfao <id>=alvo ausente: <alvo>` e ≤ 250 linhas) e `bash tests/run.sh` termina com `run.sh: 0 arquivo(s) de teste com falha`.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com as 4 mensagens `FAIL: cleanup-alvo-ausente/10 skill: …` acima
- [x] **green** — trocar as 4 linhas da skill pelo texto verbatim; `bash tests/test-skill-cleanup.sh` → `FAIL=0`; `bash tests/run.sh` → `run.sh: 0 arquivo(s) de teste com falha`
- [x] **commit** — `git add skills/cleanup/SKILL.md tests/test-skill-cleanup.sh && git commit -m "docs(cleanup-alvo-ausente/10): skill só marca alvo ausente conferido no histórico"`

## Tarefa 4: pathspec literal (achado do e2e, aprovação parcial no portão)

- **depende-de**: [1, 3]
- **requisito**:
  - `cleanup-alvo-ausente/1` — caminho com `[`…`]` que nunca existiu fica fora mesmo quando, lido como glob, casaria com caminho que existiu
  - `cleanup-alvo-ausente/10` — a conferência que a skill manda a IA rodar não pode casar por glob
- **decisões relevantes**: portão 2026-10-03 (humano): aprovação parcial, opção A — fechar o achado do e2e antes do sync. O script já usa `--literal-pathspecs` (`hooks/cleanup`, `sub existiu`); falta o teste e a frase.
- **interfaces**: nenhuma de código. Texto novo em `skills/cleanup/SKILL.md:44`: `git log -1 --full-history --oneline HEAD -- <alvo>` → `git --literal-pathspecs log -1 --full-history --oneline HEAD -- <alvo>`.
- **ponto de mudança**: `tests/test-skill-cleanup.sh:225-235` (`mkalvo`: `addc app/s/page.tsx` + `git rm` junto de `src/velho.ts`; planned `- slug | planned | SL | r | k | app/[slug]/page.tsx`); `tests/test-skill-cleanup.sh:251` (assert novo); bloco `sk` (assert novo); `skills/cleanup/SKILL.md:44`.
- **asserções**:
  - `$out` do `varrer` em `mkalvo` não contém `- slug |` — "cleanup-alvo-ausente/1 [slug] literal: glob não casa caminho que existiu" (o `$out` exato de /1 segue igual)
  - a linha de `$sk` com `confira no histórico que o alvo existiu` contém `git --literal-pathspecs log -1 --full-history` — "cleanup-alvo-ausente/10 skill: conferência com pathspec literal"
- **ler**: `tests/test-skill-cleanup.sh:220-260`, `skills/cleanup/SKILL.md:44`
- **done quando**: mutante sem `--literal-pathspecs` no `hooks/cleanup` reprova; `bash tests/run.sh` → `run.sh: 0 arquivo(s) de teste com falha`; gate antes do commit registrado nas notas.

- [x] **red** — fixture + 2 asserts; o de /10 falha (frase sem a flag); o de /1 só falha no mutante sem a flag (o script já está certo)
- [x] **green** — frase da skill; `bash tests/test-skill-cleanup.sh` → `FAIL=0`
- [x] **commit** — `git add skills/cleanup/SKILL.md tests/test-skill-cleanup.sh && git commit -m "fix(cleanup-alvo-ausente/1,10): pathspec literal no teste e na conferência da skill"`
