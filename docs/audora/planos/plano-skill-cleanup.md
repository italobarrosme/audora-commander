# Plano — skill-cleanup: Skill de limpeza

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** skill-ferramenta nova `cleanup` + script `hooks/cleanup`
(`varrer` / `contar` / `aplicar`). A dupla acha as sobras do processo,
apresenta o relatório, aplica o lote aprovado num commit só e desfaz tudo se
algo falhar. A validate ganha a sugestão de 1 linha no sync. Versão `0.16.0`.

**Nó do MEMORY:** `skill-cleanup` (MEMORY.md) — 16 critérios aprovados no
próprio nó.

**Arquitetura da mudança:** o mecânico mora num script auxiliar
`hooks/cleanup` (bash + perl, precedente `hooks/gate`), chamado pela skill por
`bash "<raiz do plugin>/hooks/cleanup" <sub>`, na raiz do projeto (cwd):
- `varrer` só lê. Classifica as sobras, confere o estado git e imprime o
  relatório.
- `contar` imprime só o total do lote.
- `aplicar <lote>` relê o relatório aprovado. Apaga arquivos, troca links
  pela nota e apaga linhas do índice. Roda `hooks/memory-validate`, faz 1
  commit só com os caminhos do lote e, em qualquer falha, restaura os caminhos
  tocados com `git checkout HEAD`.

O julgamento fica na skill (`skills/cleanup/SKILL.md`): o LLM lê as linhas
planned e delivered do índice, decide os órfãos /3 e /4 semânticos e os passa
por `--orfao <id>=<motivo>`. O /4 por caminho (coluna arquivos-chave
inexistente) é mecânico, no script. Decisão do humano no plan (nó,
`## decisoes`): o script aplica o lote, com exceção registrada à decisão viva
grafo-v2. Testes em `tests/test-skill-cleanup.sh`, com fixtures git reais em
`$SP` e falhas reais: hook pre-commit, item que mudou depois da varredura e
MEMORY quebrado.

**Arquivos lidos antes de planejar:**
- `MEMORY.md:11-43` — Constituição: executável só em `hooks/`/`tests/`; skill ≤ 250
  linhas; skill-ferramenta sem `## Bloco de fechamento`; `gate: bash hooks/gate <id>`;
  `ferramenta-e2e: claude -p`. `MEMORY.md:92-131` — índice (formato das linhas
  delivered `→ caminho`, planned com coluna arquivos-chave, `—`). Aprendizados
  usados: skill nova toca 8 pontos (2026-09-27), `assert_contains` é `grep -F`
  sensível a caixa (2026-08-31), suíte > 120 s → background (2026-09-05),
  `git add` com caminhos explícitos (2026-09-02), fixture com
  `core.excludesFile` inexistente (2026-09-29), perl preserva CRLF (2026-09-29),
  `2>/dev/null` antes do `<` (2026-09-28), gate antes do commit (2026-09-30),
  teto de carga na tarefa que cresce o arquivo (2026-10-01).
- `docs/audora/memory/skill-cleanup.md:1-125` — 16 critérios, fora de escopo, decisões.
- `docs/audora/decisoes-vivas.md:15` — "Índice mestre é editado pelo LLM e
  VALIDADO por hook, nunca gerado por script" (conflito, ver abaixo).
- `skills/memory/SKILL.md:1-135` — modelo de skill-ferramenta (roteador, Lei de
  Ferro, "Anuncie", red flags, PRÓXIMA SKILL, "Raiz do plugin" 22-25).
- `skills/plan/SKILL.md:1-109`, `templates/plano-template.md:1-49`.
- `skills/scope/SKILL.md:50` (`docs/audora/specs/<id>-escopo.md`),
  `skills/e2e/SKILL.md:66` (`docs/audora/e2e/e2e-<id>.md`),
  `skills/debug/SKILL.md:82` (`docs/audora/depuracao/cacada-<AAAA-MM-DD>.md`),
  `skills/plan/SKILL.md:16` (`docs/audora/planos/plano-<id>.md`),
  `skills/validate/references/sync.md:1-56` (passo 2 move o plano para
  `planos/arquivo/`; item 5 é o último — o item 6 novo entra depois da linha 56).
- `templates/no-template.md:1-30` — frontmatter (`depende-de: [..]`, `arquivos:`
  é registro histórico do diff, não link).
- `docs/audora/arquivo/2026-10-01-plano-mapa.md:1-12,84-88` — `arquivos:` no
  frontmatter cita caminho já inexistente (`planos/plano-plano-mapa.md`); link
  relativo `[relatório](../e2e/e2e-plano-mapa.md)` no corpo.
- `hooks/gate:1-70` — padrão de script auxiliar (`set -uo pipefail`, saída
  `GATE:`); `hooks/memory-validate:1-141` — entrada JSON no stdin, exit 2 +
  stderr, `$0` com backslash normalizado (14-16), `depende-de` só no
  frontmatter dos arquivos de `docs/audora/memory/` (110).
- `hooks/session-start:8` — linha `contexto=` com a lista de fluxos;
  `hooks/hooks.json:1-36` — o script novo NÃO é hook do harness.
- `tests/lib.sh:1-21` (asserts, `run_hook`, `$SP`), `tests/run.sh:1-10`,
  `tests/test-gate.sh:1-45` (fixture git: `mkfix`, `core.autocrlf false`),
  `tests/test-memory-validate.sh:1-30` (fixture de MEMORY válido: `mk`, `no`),
  `tests/test-dogfood.sh:1-20` (prende planned do índice deste repo).
- `tests/test-skills.sh:1-20` (loop de estrutura na 7), `:80-107` (contagem 8
  na 84; skills-ferramenta sem bloco na 98), `:158-166`.
- `tests/test-docs.sh:1-40` (versão na 7), `tests/test-corte-sem-uso.sh:37-53`
  (contagem 8 na 38; guarda "sem '9 skills'" na 45; títulos 47-48; versão 51),
  `tests/test-session-start.sh:1-14`.
- `tests/test-carga.sh:1-22` — `sync.md` está no FULL (55368 de teto 56900);
  validate SKILL.md e BASE não são tocados (guardas 6139 / 47773 em
  `tests/test-parada-revisao.sh:53-59`). `tests/test-parada-revisao.sh:82-88`,
  `tests/test-prd-foto.sh:53-60` — frases do `sync.md` que não podem sumir.
- `.claude-plugin/plugin.json:4`, `.claude-plugin/marketplace.json:9` — `0.15.0`.
- `README.md:26-32,89-103,265-286,315-346`, `README.pt-BR.md:26-31,89-103,327-336`
  — "8 chained skills"/"8 skills encadeadas" (28/27), título da tabela (89),
  linha `debug` (100), seção `### debug` (265-285 EN), checklist "8 skills" (334).
- `PRD.md:1-150` — só leitura (o PRD segue a main; sync na validate).

**Conflitos MEMORY vs código encontrados:** decisão viva grafo-v2
(`docs/audora/decisoes-vivas.md:15`) proíbe script de gerar o índice; aplicar o
lote por script apaga linha do índice. Humano decidiu em 2026-10-02: script
aplica, com exceção registrada no nó (só APAGA linha aprovada e roda
`memory-validate` antes do commit). No sync, a validate deve anotar a exceção
junto da decisão viva.

## Contrato do script (fonte única das asserções)

Uso: `bash <raiz do plugin>/hooks/cleanup varrer [--orfao <id>=<motivo>]... | contar | aplicar <lote>`,
sempre na raiz do projeto (cwd). Sem subcomando ou subcomando desconhecido →
stdout `uso: cleanup varrer [--orfao <id>=<motivo>]... | contar | aplicar <lote>`, exit 1.

Relatório do `varrer` (seção sem item é omitida; itens ordenados com `LC_ALL=C sort`):

```
cleanup: relatório — nada foi alterado
## planned órfão
- <id> | <motivo>
## spec de nó entregue
- <caminho> | nó <id> delivered
## plano arquivado
- <caminho> | nó <id> delivered
## relatório e2e
- <caminho> | nó <id> delivered
## depuração velha
- <caminho> | sem nó vivo ligado
## sem referência
- <caminho> | nenhum documento vivo o cita
## link quebrado
- <arquivo>:<linha> | aponta <alvo> inexistente
## mantido
- <id> | mantido: <dependente> depende dele
## não tocado
- <alvo> | não tocado: fora do git
- <alvo> | não tocado: mudança não commitada[ em <arquivo>]
total: <N> item(ns) no lote
```

Lote com N = 0: imprime só `## mantido`/`## não tocado` (se houver) e a última
linha vira `cleanup: nada a limpar` (sem cabeçalho nem `total:`).

Definições (usadas por várias tarefas):
- **Estado de nó**: 2ª coluna da linha `^- <id> | ` do índice do `MEMORY.md`. Vivo =
  planned, in-progress, blocked, hotfix-pending-record.
- **Ligação por nome**: `specs/<id>-escopo.md`, `planos/arquivo/plano-<id>.md`,
  `planos/plano-<id>.md`, `e2e/e2e-<id>.md` (sob `docs/audora/`).
- **Documento vivo** (/8): `MEMORY.md`, `docs/audora/memory/*.md`,
  `docs/audora/decisoes-vivas.md`, `PRD.md`, `README*.md` da raiz,
  `skills/**/*.md`, `.claude/skills/**/*.md`. Referência = o basename aparece
  (`grep -F`).
- **Link**: fora do frontmatter (linha 1 `---` até o próximo `---`) e fora de
  bloco ```` ``` ````. Vale `[texto](alvo)` local (sem `esquema:`, sem `#` no
  início, sem `<`/`*`/`{`; âncora `#…` descartada), resolvido a partir da
  pasta do arquivo. Vale também o token `docs/audora/[A-Za-z0-9._/-]+\.md`
  fora de `](…)`, com ou sem crases, resolvido a partir da raiz. Token seguido
  de `` ` removido em `` é nota da cleanup e não é link.
- **Nota**: `` `<caminho>` removido em AAAA-MM-DD pela cleanup — recuperável no git``
  (`<caminho>` relativo à raiz; data = `date +%F`). Substitui o link inteiro
  (`[texto](alvo)`, ou o token com as crases).
- **Caminhos tocados por item**: o arquivo apagado, mais todo `.md` rastreado
  com link para ele. Planned órfão: `MEMORY.md`, mais `docs/audora/memory/<id>.md`
  se existir, mais quem linka esse arquivo. Link quebrado: o arquivo do link.

## Notas de sessão

- Rodar a cleanup NESTE repo é passo pós-entrega, fora do nó. `tests/test-dogfood.sh:10`
  prende os planned do índice — uma limpeza real aqui exige mexer nessa guarda.
- `tests/test-skill-cleanup.sh` cria muitos repos git: no Windows passa de
  120 s junto da suíte → `bash tests/run.sh` via `run_in_background` e ler o
  output-file. O arquivo sozinho roda em foreground.

## Decisões tomadas pela IA

- 2026-10-02 (execute, T1): `hooks/cleanup` é um shim bash (normaliza `$0`,
  exporta `CLEANUP_DIR`) que faz `exec perl -x` no próprio arquivo; toda a
  lógica fica em perl (parse de índice, links, git via `open '-|'` em lista,
  sem shell). Evita aspas de perl dentro de bash e preserva CRLF por padrão.
- 2026-10-02 (execute, T3): candidato a "sem referência" exclui também
  `docs/audora/memory/` (além de `arquivo/` e `decisoes-vivas.md`); depuração
  ligada a nó vivo sai do /8 (já é citada por documento vivo).
- 2026-10-02 (execute, T5): `--orfao` sem `<id>=<motivo>` → uso, exit 1;
  mantido com vários dependentes lista todos (`mantido: a, b depende dele`);
  o arquivo `docs/audora/memory/<id>.md` de um planned órfão conta como
  candidato (link quebrado dentro dele não é listado à parte).

---

## Tarefa 1: esqueleto do script, sem MEMORY e nada a limpar

- **depende-de**: []
- **requisito**: `skill-cleanup/2` — QUANDO o projeto não tem `MEMORY.md` O SISTEMA DEVE recusar a varredura, apontar o bootstrap da skill memory e não alterar nada · `skill-cleanup/15` — QUANDO a varredura não acha nada O SISTEMA DEVE dizer "nada a limpar" e não commitar
- **decisões relevantes**: Constituição (executável só em `hooks/`); script auxiliar, não hook do harness (fora de `hooks.json`).
- **interfaces**: produz `hooks/cleanup` com os 3 subcomandos do contrato (só `varrer`/`contar` funcionais nesta tarefa; `aplicar` responde ao uso). No teste, produz `mkproj <dir>`, que cria um repo git com `core.autocrlf false`, `core.excludesFile` inexistente, user/email, um `MEMORY.md` válido (4 seções, linha `- d | delivered | D → docs/audora/arquivo/2026-01-01-d.md`), `docs/audora/arquivo/2026-01-01-d.md`, `docs/audora/decisoes-vivas.md`, `README.md` e o commit `base`. Produz também `addc <dir> <caminho> <conteúdo>`, que escreve, faz `git add` e commita, e `runc <dir> <args…>`, que define `out` (stdout+stderr) e `code`.
- **ponto de mudança**: `hooks/cleanup:1` (arquivo novo).
- **teste**: `tests/test-skill-cleanup.sh` (novo) — casos "skill-cleanup/2 sem MEMORY recusa", "skill-cleanup/15 nada a limpar", "uso".
- **asserções**:
  - dir git sem `MEMORY.md`, `varrer` → exit 1; out contém `cleanup: sem MEMORY.md — rode o bootstrap da skill memory; nada foi alterado`; `git status --porcelain` igual ao de antes.
  - idem `contar` → exit 1, mesma mensagem.
  - dir sem `.git` com `MEMORY.md` → exit 1; out contém `cleanup: não é repositório git — nada foi alterado`.
  - `mkproj` limpo, `varrer` → exit 0; out = `cleanup: nada a limpar` (linha única); `git rev-list --count HEAD` = 1.
  - `mkproj` limpo, `contar` → out = `0`, exit 0.
  - sem argumento → exit 1; out contém `uso: cleanup varrer`.
- **ler**: `hooks/gate:1-20`, `tests/test-gate.sh:22-35`, `tests/test-memory-validate.sh:4-8`.
- **done quando**: as 6 asserções passam e `bash tests/run.sh` fica verde.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/2` (script ausente)
- [x] **green** — `bash tests/test-skill-cleanup.sh` passa; `bash tests/run.sh` (background) verde; `bash hooks/gate skill-cleanup` → `GATE: passou`
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(skill-cleanup/2,15): hooks/cleanup recusa sem MEMORY e diz nada a limpar"`

## Tarefa 2: artefatos de nó entregue, depuração velha e relatório só-leitura

- **depende-de**: [1]
- **requisito**: `skill-cleanup/7` — QUANDO existe spec de escopo, plano arquivado ou relatório e2e de nó delivered, ou relatório de depuração sem nó vivo ligado O SISTEMA DEVE listá-lo no tipo correspondente · `skill-cleanup/1` — QUANDO o humano invoca a cleanup num projeto com `MEMORY.md` O SISTEMA DEVE apresentar um relatório agrupado por tipo (planned órfão, spec de nó entregue, plano arquivado, relatório e2e, depuração velha, sem referência, link quebrado), cada item com caminho e motivo em 1 linha, sem alterar nenhum arquivo antes da aprovação
- **decisões relevantes**: "arquivo morto = planos arquivados + relatórios e2e de delivered + depuração sem nó vivo" (nó). Depuração "ligada" = basename citado no índice ou num arquivo de `docs/audora/memory/`.
- **interfaces**: produz o formato de relatório do contrato (cabeçalho, ordem das seções, `total:`); `contar` = N.
- **ponto de mudança**: `hooks/cleanup` — função de classificação dos arquivos de `docs/audora/specs`, `planos/arquivo`, `e2e`, `depuracao`.
- **teste**: `tests/test-skill-cleanup.sh` — casos "skill-cleanup/7 …", "skill-cleanup/1 só-leitura e formato".
- **asserções** (fixture: `mkproj` + nó vivo `v` in-progress com `docs/audora/memory/v.md`. Arquivos commitados: `specs/d-escopo.md`, `specs/v-escopo.md`, `planos/arquivo/plano-d.md`, `planos/plano-v.md`, `e2e/e2e-d.md`, `e2e/e2e-v.md`, `depuracao/cacada-2026-01-01.md` e `depuracao/cacada-2026-02-02.md`. Este último é citado em `v.md`):
  - out contém, nesta ordem, `## spec de nó entregue`, `## plano arquivado`, `## relatório e2e`, `## depuração velha`.
  - linhas exatas: `- docs/audora/specs/d-escopo.md | nó d delivered`, `- docs/audora/planos/arquivo/plano-d.md | nó d delivered`, `- docs/audora/e2e/e2e-d.md | nó d delivered`, `- docs/audora/depuracao/cacada-2026-01-01.md | sem nó vivo ligado`.
  - out NÃO contém `specs/v-escopo.md`, `plano-v.md`, `e2e-v.md` nem `cacada-2026-02-02.md`.
  - 1ª linha = `cleanup: relatório — nada foi alterado`; última = `total: 4 item(ns) no lote`; `contar` → `4`.
  - md5 de todos os arquivos (`find . -path ./.git -prune -o -type f`) e `git status --porcelain` idênticos antes/depois do `varrer`.
- **ler**: `hooks/memory-validate:47-55` (parse do índice), `skills/e2e/SKILL.md:66`, `skills/debug/SKILL.md:82`.
- **done quando**: asserções passam; suíte verde.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/7`
- [x] **green** — arquivo e suíte verdes; `bash hooks/gate skill-cleanup` passou
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(skill-cleanup/1,7): varrer lista artefatos de nó entregue e depuração velha, sem alterar nada"`

## Tarefa 3: sem referência

- **depende-de**: [2]
- **requisito**: `skill-cleanup/8` — QUANDO um arquivo de `docs/audora/` não é referenciado por nenhum documento vivo (índice, nós de `docs/audora/memory/`, decisões vivas, skills, PRD, READMEs; nós arquivados não contam) O SISTEMA DEVE listá-lo como sem referência
- **decisões relevantes**: fora de escopo — `docs/audora/arquivo/` nunca é removido; arquivo fora de `docs/audora/` nunca entra. Candidatos = arquivos de `docs/audora/` fora de `memory/`, `arquivo/` e `decisoes-vivas.md`, que nem são tipados na T2 nem estão ligados a nó vivo por nome. Referência por basename (conservador).
- **interfaces**: consome a classificação da T2; produz a seção `## sem referência`.
- **ponto de mudança**: `hooks/cleanup` — função de referência viva.
- **teste**: `tests/test-skill-cleanup.sh` — caso "skill-cleanup/8 …".
- **asserções** (fixture da T2 + `docs/audora/notas/{solta,citada,viva,so-arquivo}.md`. `citada.md` é citada no `README.md`, `viva.md` em `decisoes-vivas.md` e `so-arquivo.md` só em `arquivo/2026-01-01-d.md`. Tem ainda `docs/specs/fora.md`, sem citação):
  - linhas exatas `- docs/audora/notas/solta.md | nenhum documento vivo o cita` e `- docs/audora/notas/so-arquivo.md | nenhum documento vivo o cita`.
  - out NÃO contém `citada.md`, `viva.md`, `docs/specs/fora.md`, `2026-01-01-d.md |`, `decisoes-vivas.md |`.
  - `docs/audora/planos/plano-v.md` (nó v vivo, sem citação) → NÃO listado.
- **ler**: `docs/audora/memory/skill-cleanup.md` (/8 e fora-de-escopo).
- **done quando**: asserções passam; suíte verde.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/8`
- [x] **green** — arquivo e suíte verdes; gate passou
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(skill-cleanup/8): varrer lista arquivo de docs/audora sem referência viva"`

## Tarefa 4: detecção de link quebrado

- **depende-de**: [2]
- **requisito**: `skill-cleanup/10` — QUANDO a varredura acha em `MEMORY.md` ou `docs/audora/` um link para arquivo inexistente O SISTEMA DEVE listá-lo como link quebrado e, aprovado, trocá-lo pela mesma nota (aqui: só a detecção; a troca é da T8)
- **decisões relevantes**: "Link" do contrato (frontmatter e fences fora; nota não é link). Link dentro de arquivo que já é candidato à remoção no mesmo relatório não é listado.
- **interfaces**: produz `## link quebrado` com `- <arquivo>:<linha> | aponta <alvo> inexistente` (`<alvo>` como escrito no arquivo).
- **ponto de mudança**: `hooks/cleanup` — função de extração de links (perl).
- **teste**: `tests/test-skill-cleanup.sh` — caso "skill-cleanup/10 detecta …".
- **asserções** (corpo de `docs/audora/arquivo/2026-01-01-d.md`; `L*` obtidos por `grep -n`):
  - `[r](../e2e/nao-existe.md)` em L1 → `- docs/audora/arquivo/2026-01-01-d.md:L1 | aponta ../e2e/nao-existe.md inexistente`.
  - `` `docs/audora/specs/sumiu.md` `` em L2 → `…:L2 | aponta docs/audora/specs/sumiu.md inexistente`.
  - frontmatter `arquivos: [docs/audora/planos/plano-d.md]` → NÃO listado.
  - `docs/audora/x/sumiu-fence.md` dentro de ```` ``` ```` → NÃO listado.
  - `[ok](../decisoes-vivas.md)` e `[w](https://x.y/z.md)` → NÃO listados.
  - nota `` `docs/audora/e2e/velho.md` removido em 2026-01-01 pela cleanup — recuperável no git`` → NÃO listada.
  - `MEMORY.md` com linha `- z | delivered | Z → docs/audora/arquivo/sumiu.md` → `- MEMORY.md:<n> | aponta docs/audora/arquivo/sumiu.md inexistente`.
  - link quebrado dentro de `specs/d-escopo.md` (candidato da T2) → NÃO listado.
- **ler**: `docs/audora/arquivo/2026-10-01-plano-mapa.md:1-12,84-88` (formas reais de link).
- **done quando**: asserções passam; suíte verde.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/10`
- [x] **green** — arquivo e suíte verdes; gate passou
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(skill-cleanup/10): varrer detecta link quebrado fora de frontmatter, fence e nota"`

## Tarefa 5: planned órfão e mantido

- **depende-de**: [2]
- **requisito**: `skill-cleanup/3` — QUANDO um nó planned tem objetivo já entregue ou absorvido por um nó delivered O SISTEMA DEVE listá-lo como planned órfão, citando o nó que o absorveu · `skill-cleanup/4` — QUANDO um nó planned cita skill, arquivo ou feature que não existe mais no repo O SISTEMA DEVE listá-lo como planned órfão, citando o alvo ausente · `skill-cleanup/5` — QUANDO um planned órfão está no `depende-de` de outro nó não arquivado O SISTEMA DEVE deixá-lo fora do lote e reportar "mantido: <dependente> depende dele"
- **decisões relevantes**: o /3 e o /4 semântico vêm da skill por `--orfao <id>=<motivo>`, e o motivo do `--orfao` prevalece; o /4 mecânico olha a coluna arquivos-chave (6ª) da linha planned, separada por `,`. Pula `—`, vazio e token com `*` ou `<`; os demais são checados com `[ -e ]`. Um id aparece uma vez só. Nó "não arquivado" = arquivo em `docs/audora/memory/`.
- **interfaces**: `varrer --orfao <id>=<motivo>` (repetível) → `- <id> | <motivo>`; `--orfao` com id que não é planned → linha `aviso: --orfao <id> ignorado — não é planned no índice` antes do relatório.
- **ponto de mudança**: `hooks/cleanup` — parse de argumentos e função de planned órfão.
- **teste**: `tests/test-skill-cleanup.sh` — casos "skill-cleanup/3", "/4", "/5".
- **asserções** (índice: `- p | planned | P | r | k | —`; `- q | planned | Q | r | k | src/sumiu.ts, README.md`; `- r | planned | R | r | k | —`; `- r2 | planned | R2 | r | k | src/nada.ts`; `- s | planned | S | r | k | —`. `docs/audora/memory/v.md` (in-progress) tem `depende-de: [r2]` e `arquivo/2026-01-01-d.md` tem `depende-de: [s]`):
  - `varrer --orfao 'p=absorvido por d'` → `- p | absorvido por d` sob `## planned órfão`.
  - sem `--orfao` → `- q | alvo ausente: src/sumiu.ts` (README.md existe e não aparece no motivo).
  - `varrer --orfao 'r2=absorvido por d'` → `- r2 | mantido: v depende dele` sob `## mantido`; `r2` fora de `## planned órfão`.
  - `varrer --orfao 's=absorvido por d'` → `- s | absorvido por d` (dependente arquivado não conta).
  - `varrer --orfao 'd=x'` → out contém `aviso: --orfao d ignorado — não é planned no índice`; `d` fora de `## planned órfão`.
  - `- r | …` sem `--orfao` → NÃO listado.
  - `contar` → conta só o mecânico (`q`): `1` nesta fixture, sem os artefatos da T2.
- **ler**: `hooks/memory-validate:110-116` (parse do `depende-de`), `MEMORY.md:118-123` (linhas planned reais).
- **done quando**: asserções passam; suíte verde.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/3`
- [x] **green** — arquivo e suíte verdes; gate passou
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(skill-cleanup/3,4,5): planned órfão por --orfao e por alvo ausente; mantido com dependente vivo"`

## Tarefa 6: não tocado — fora do git e mudança não commitada

- **depende-de**: [3, 4, 5]
- **requisito**: `skill-cleanup/11` — QUANDO um candidato está fora do git (untracked ou ignorado) ou tem mudança não commitada O SISTEMA DEVE deixá-lo fora do lote e reportá-lo como "não tocado: fora do git" ou "não tocado: mudança não commitada"
- **decisões relevantes**: "fora do git ou sujo → pula e avisa" (nó). Candidato com algum "caminho tocado" sujo (referente ou `MEMORY.md`) → não tocado, com sufixo ` em <arquivo>`. Links em `.md` não rastreado não são editados nem bloqueiam.
- **interfaces**: consome as listas da T2–T5 e a função "caminhos tocados por item" (do contrato), que a T7 reusa; produz `## não tocado`.
- **ponto de mudança**: `hooks/cleanup` — filtro git final antes da impressão.
- **teste**: `tests/test-skill-cleanup.sh` — caso "skill-cleanup/11 …".
- **asserções**:
  - `docs/audora/e2e/e2e-d.md` criado sem `git add` → `- docs/audora/e2e/e2e-d.md | não tocado: fora do git`; fora de `## relatório e2e`.
  - `.gitignore` com `docs/audora/tmp/` + `docs/audora/tmp/x.md` → `- docs/audora/tmp/x.md | não tocado: fora do git`.
  - `specs/d-escopo.md` commitado e depois editado → `- docs/audora/specs/d-escopo.md | não tocado: mudança não commitada`.
  - `planos/arquivo/plano-d.md` limpo, linkado por `arquivo/2026-01-01-d.md` e esse arquivo sujo → `- docs/audora/planos/arquivo/plano-d.md | não tocado: mudança não commitada em docs/audora/arquivo/2026-01-01-d.md`.
  - `MEMORY.md` sujo + `--orfao 'p=absorvido por d'` → `- p | não tocado: mudança não commitada em MEMORY.md`.
  - `total:` não conta os não tocados; `contar` idem.
- **ler**: `docs/audora/memory/skill-cleanup.md` (/11, decisões "fora do git").
- **done quando**: asserções passam; suíte verde.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/11`
- [x] **green** — arquivo e suíte verdes; gate passou
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(skill-cleanup/11): candidato fora do git ou sujo fica fora do lote como não tocado"`

## Tarefa 7: aplicar — apagar arquivo, nota nos links, 1 commit, lote vazio

- **depende-de**: [6]
- **requisito**: `skill-cleanup/9` — QUANDO o humano aprova a remoção de um arquivo O SISTEMA DEVE apagá-lo e trocar todo link que apontava para ele pela nota "`<caminho>` removido em AAAA-MM-DD pela cleanup — recuperável no git" · `skill-cleanup/13` — QUANDO o lote aprovado é aplicado O SISTEMA DEVE fazer 1 commit só com os caminhos do lote, com mensagem listando o que saiu por tipo, e deixar o MEMORY válido no schema (índice↔pasta, `depende-de`) · `skill-cleanup/12` (parte do script) — … se ele reprovar ou tirar todos, não alterar nada nem commitar
- **decisões relevantes**: "1 commit próprio da limpeza" (nó). O lote é o próprio relatório, já aparado pelo humano; o parse lê só as 7 seções acionáveis e ignora `cleanup:`, `total:`, `aviso:`, `## mantido` e `## não tocado`. A remoção usa `git rm -q` e a edição usa `perl -i` (preserva CRLF). O commit é `git commit -q -m <msg> -- <caminhos>`, e o que já estava staged fica fora dele.
- **interfaces**: `aplicar <lote>` → sucesso: `cleanup: commit <hash7> — <N> item(ns) removido(s)`, exit 0. Mensagem do commit: título `chore(cleanup): remove <N> sobra(s) do processo`, linha em branco e 1 linha por tipo com itens, `<tipo>: <alvo>, <alvo>` (alvo = 1ª coluna do item). Lote sem item acionável → `cleanup: lote vazio — nada aplicado`, exit 0. Lote inexistente → `cleanup: lote <arq> não encontrado`, exit 1.
- **ponto de mudança**: `hooks/cleanup` — subcomando `aplicar` (remoção de arquivo + troca de link + commit).
- **teste**: `tests/test-skill-cleanup.sh` — casos "skill-cleanup/9", "/13", "/12 lote vazio".
- **asserções** (fixture da T2 + `[rel](../e2e/e2e-d.md)` no corpo e `docs/audora/e2e/e2e-d.md` no frontmatter `arquivos:` de `arquivo/2026-01-01-d.md`. Mais `outro.txt` novo e staged antes do `aplicar`; o lote é a saída do `varrer`):
  - exit 0; out contém `cleanup: commit `; `git rev-list --count HEAD` +1.
  - os 4 arquivos do lote não existem; `git show --name-only --format= HEAD | LC_ALL=C sort` = os 4 + `docs/audora/arquivo/2026-01-01-d.md`.
  - `git show -s --format=%s HEAD` = `chore(cleanup): remove 4 sobra(s) do processo`; corpo contém `spec de nó entregue: docs/audora/specs/d-escopo.md` e `depuração velha: docs/audora/depuracao/cacada-2026-01-01.md`.
  - linha do link em `arquivo/2026-01-01-d.md` = `` `docs/audora/e2e/e2e-d.md` removido em $(date +%F) pela cleanup — recuperável no git``; frontmatter `arquivos:` inalterado.
  - `outro.txt` segue staged (`git diff --cached --name-only` = `outro.txt`) e fora do commit.
  - `run_hook memory-validate "<fixture>/MEMORY.md"` → code 0.
  - lote só com cabeçalhos (`## spec de nó entregue` sem itens) → out = `cleanup: lote vazio — nada aplicado`; HEAD e `git status --porcelain` inalterados.
  - lote inexistente → exit 1, `cleanup: lote /nao/existe não encontrado`.
  - lote = relatório completo com `## mantido`/`## não tocado` → esses itens intocados.
- **ler**: `tests/lib.sh:16-20` (`run_hook`), `hooks/memory-validate:12-23`.
- **done quando**: asserções passam; suíte verde.

- [x] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/9`
- [x] **green** — arquivo e suíte verdes; gate passou
- [x] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(skill-cleanup/9,12,13): aplicar apaga, troca link pela nota e faz 1 commit só com o lote"`

## Tarefa 8: aplicar — planned órfão, link quebrado e MEMORY validado

- **depende-de**: [7]
- **requisito**: `skill-cleanup/6` — QUANDO o humano aprova a remoção de um planned órfão O SISTEMA DEVE apagar a linha dele do índice e, se existir, o arquivo do nó em `docs/audora/memory/` · `skill-cleanup/10` (troca) — … e, aprovado, trocá-lo pela mesma nota · `skill-cleanup/13` (MEMORY válido)
- **decisões relevantes**: exceção à decisão viva grafo-v2 (nó, plan): o script só APAGA a linha `^- <id> | planned |` e roda `hooks/memory-validate` depois de aplicar, quando o lote tocou `MEMORY.md` ou `docs/audora/memory/`. O validate é achado por `$(dirname "${0//\\//}")/memory-validate`, com JSON `{"tool_name":"Edit","tool_input":{"file_path":"<cwd>/MEMORY.md"}}` no stdin. Link quebrado: troca o link em `<arquivo>:<linha>` cujo alvo bate com o motivo; a nota usa o caminho resolvido a partir da raiz.
- **interfaces**: consome o `aplicar` da T7; o exit 2 do validate é tratado como falha na T9.
- **ponto de mudança**: `hooks/cleanup` — `aplicar` para `## planned órfão` e `## link quebrado` + chamada do validate.
- **teste**: `tests/test-skill-cleanup.sh` — casos "skill-cleanup/6", "/10 troca", "idempotência".
- **asserções**:
  - planned `p` sem arquivo, aprovado → `grep -c '^- p |' MEMORY.md` = 0; demais linhas do índice intactas (diff só remove 1 linha).
  - planned `s` com `docs/audora/memory/s.md`, linkado por `[s](s.md)` em `docs/audora/memory/v.md` → `s.md` não existe; linha `^- s |` sumiu; `v.md` contém `` `docs/audora/memory/s.md` removido em $(date +%F) pela cleanup — recuperável no git``.
  - link quebrado de L1 (T4) aprovado → L1 do arquivo = a nota com `docs/audora/e2e/nao-existe.md`; L2 trocada → nota com `docs/audora/specs/sumiu.md`.
  - `MEMORY.md` com CRLF na fixture → depois do `aplicar`, `grep -c $'\r$' MEMORY.md` = nº de linhas (CRLF preservado).
  - `run_hook memory-validate` → code 0; corpo do commit contém `planned órfão: p, s` e `link quebrado: docs/audora/arquivo/2026-01-01-d.md:` (com a linha).
  - idempotência: `varrer` logo após → `cleanup: nada a limpar`.
- **ler**: `hooks/memory-validate:12-23,47-48`, `docs/audora/memory/skill-cleanup.md` (`## decisoes`, linha do plan).
- **done quando**: asserções passam; suíte verde.

- [ ] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/6`
- [ ] **green** — arquivo e suíte verdes; gate passou
- [ ] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(skill-cleanup/6,10,13): aplicar apaga planned órfão do índice, troca link quebrado e valida o MEMORY"`

## Tarefa 9: falha no meio desfaz o lote

- **depende-de**: [8]
- **requisito**: `skill-cleanup/14` — QUANDO uma alteração do lote falha no meio O SISTEMA DEVE parar antes do commit, desfazer o que já aplicou (árvore volta ao estado de antes do lote) e reportar o item que falhou
- **decisões relevantes**: há uma pré-checagem antes de tocar qualquer arquivo. Ela recusa o item quando algum caminho tocado está sujo ou fora do git, quando o alvo está fora de `docs/audora/` (o planned órfão e o link em `MEMORY.md` são exceções) e quando o alvo cai em `docs/audora/arquivo/` ou `decisoes-vivas.md`. Os itens são aplicados na ordem do lote. Na falha, o script roda `git reset -q -- <tocados>` e depois `git checkout -q HEAD -- <tocados que existem em HEAD>`.
- **interfaces**: falha → `cleanup: falhou em: <linha do item> — <motivo>` + `cleanup: lote desfeito, nada commitado`, exit 1. Motivos: `mudança não commitada em <arq>`, `fora de docs/audora/`, `arquivo/ e decisões vivas nunca são removidos`, `alvo não existe mais`, `link não encontrado na linha`, `commit recusado`, `MEMORY inválido: <1ª linha do stderr do validate>`.
- **ponto de mudança**: `hooks/cleanup` — pré-checagem e trap de rollback do `aplicar`.
- **teste**: `tests/test-skill-cleanup.sh` — caso "skill-cleanup/14 …". Em todo cenário vale o "estado igual": HEAD, `git status --porcelain` e md5 da árvore idênticos ao de antes do `aplicar`.
- **asserções**:
  - lote = spec `d` (válida) + link quebrado L1, e L1 foi reescrita e commitada depois do `varrer` → exit 1; out contém `cleanup: falhou em: - docs/audora/arquivo/2026-01-01-d.md:` e `link não encontrado na linha`; `specs/d-escopo.md` existe de novo; estado igual.
  - `.git/hooks/pre-commit` com `exit 1` → exit 1; `falhou em: commit — commit recusado`; estado igual.
  - `docs/audora/memory/z.md` sem linha no índice, commitado, + lote com planned `p` → exit 1; out contém `MEMORY inválido:`; `^- p |` de volta; estado igual.
  - item `- src/app.ts | x` sob `## sem referência` → exit 1, `fora de docs/audora/`; nada aplicado.
  - item `- docs/audora/arquivo/2026-01-01-d.md | x` sob `## sem referência` → exit 1, `arquivo/ e decisões vivas nunca são removidos`.
  - item cujo arquivo foi apagado e commitado depois do `varrer` → exit 1, `alvo não existe mais`; estado igual.
- **ler**: `hooks/gate:56-70` (acumular falhas/saída).
- **done quando**: asserções passam; suíte verde.

- [ ] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/14`
- [ ] **green** — arquivo e suíte verdes; gate passou
- [ ] **commit** — `git add hooks/cleanup tests/test-skill-cleanup.sh && git commit -m "feat(skill-cleanup/14): falha no meio do lote desfaz tudo e nomeia o item"`

## Tarefa 10: skill `cleanup` e registro da skill nova

- **depende-de**: [9]
- **requisito**: `skill-cleanup/1` (invocação pelo humano) · `skill-cleanup/3` e `/4` (julgamento semântico → `--orfao`) · `skill-cleanup/12` — QUANDO o relatório é apresentado O SISTEMA DEVE esperar aprovação explícita do lote, aceitar que o humano tire itens e, se ele reprovar ou tirar todos, não alterar nada nem commitar · `skill-cleanup/2` (a skill também recusa sem `MEMORY.md`)
- **decisões relevantes**: Constituição `padroes` (frontmatter com `description: 'Use quando…'` entre aspas simples, Lei de Ferro em bloco, "Anuncie ao começar", fluxo numerado, red flags, `## PRÓXIMA SKILL`; skill-ferramenta SEM `## Bloco de fechamento`); ≤ 250 linhas. Aprendizado 2026-09-27: a skill nova toca `tests/test-skills.sh`, `tests/test-docs.sh`, READMEs EN+PT, os 2 manifests e `hooks/session-start` (o PRD é da validate). As frases asseridas ficam em UMA linha do Markdown.
- **interfaces**: a skill chama literalmente `bash "<raiz do plugin>/hooks/cleanup" varrer --orfao <id>=<motivo>` e `bash "<raiz do plugin>/hooks/cleanup" aplicar <lote>`. O lote fica no scratchpad.
- **ponto de mudança**: `skills/cleanup/SKILL.md:1` (novo). Também:
  - `tests/test-skills.sh:2,7,84,98` — loop com `cleanup`, contagem 9 e `cleanup` no loop de skills-ferramenta;
  - `tests/test-corte-sem-uso.sh:37-38,45,47-48,51` — contagem 9; a guarda "sem '9 skills'" vira `assert_contains` de `## The 9 skills`/`## As 9 skills`; versão;
  - `tests/test-docs.sh:7` (versão), `.claude-plugin/plugin.json:4`, `.claude-plugin/marketplace.json:9` (`0.16.0`);
  - `hooks/session-start:8` (acrescentar `; sobras do processo (nós órfãos, arquivo morto): cleanup`);
  - `README.md:28,89,100,285,334` e `README.pt-BR.md:27,89,100,286,334` — 9 skills, linha da tabela, seção `### cleanup` depois de `### debug` e checklist.
- **teste**: `tests/test-skill-cleanup.sh` — caso "skill-cleanup/12 skill"; `tests/test-skills.sh`, `tests/test-corte-sem-uso.sh`, `tests/test-docs.sh`, `tests/test-session-start.sh`.
- **asserções** (no SKILL.md, `grep -F`, cada frase numa linha):
  - contém `hooks/cleanup" varrer`, `hooks/cleanup" aplicar`, `--orfao <id>=absorvido por <id-delivered>`, `--orfao <id>=alvo ausente: <alvo>`, `aprovação explícita`, `tirar itens`, `reprovou ou tirou todos → não rode` + `aplicar`, `nada a limpar`, `git revert <hash>`, `bootstrap da skill memory`, `grep -E '^- [^|]+ \| (planned|delivered) \|' MEMORY.md`.
  - NÃO contém `## Bloco de fechamento`; `wc -l` ≤ 250.
  - `ls -d skills/*/ | wc -l` = 9; `.claude-plugin/*.json` declaram `"version": "0.16.0"`.
  - README EN contém `## The 9 skills` e `| \`cleanup\` |`; PT contém `## As 9 skills` e `| \`cleanup\` |`; blocos de código EN/PT idênticos (guarda existente).
  - `bash hooks/session-start` contém `cleanup` e segue contendo `memory, scope, plan, execute, e2e, validate`.
- **ler**: `skills/memory/SKILL.md:1-60,118-135` (molde), `README.md:89-103,265-286,329-346`, `README.pt-BR.md:89-103,266-287,329-346`, `tests/test-corte-sem-uso.sh:37-53`.
- **done quando**: asserções passam; suíte verde; `bash tests/test-carga.sh` sem mudança na carga (a skill nova não entra no BASE/FULL).

- [ ] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/12 skill`; `bash tests/test-skills.sh` falha em `corte-sem-uso/9 8 skills` depois de trocar a asserção para 9
- [ ] **green** — os 5 arquivos de teste verdes; `bash tests/run.sh` (background) verde; gate passou
- [ ] **commit** — `git add skills/cleanup/SKILL.md tests/test-skill-cleanup.sh tests/test-skills.sh tests/test-corte-sem-uso.sh tests/test-docs.sh .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/session-start README.md README.pt-BR.md && git commit -m "feat(skill-cleanup/1,3,4,12): skill cleanup (relatório, aprovação em lote, aplicar) e registro — 9 skills, 0.16.0"`

## Tarefa 11: sugestão no sync da validate

- **depende-de**: [2]
- **requisito**: `skill-cleanup/16` — QUANDO o sync da validate termina e há ≥1 sobra que a cleanup listaria O SISTEMA DEVE sugerir em 1 linha rodar a cleanup, com a contagem, sem executá-la
- **decisões relevantes**: "gatilho manual + sugestão de 1 linha no sync da validate" (nó). A contagem é a do `contar`, só a parte mecânica: os órfãos semânticos ficam para a skill. Roda depois do commit do sync, porque item sujo não conta. `validate/SKILL.md` NÃO muda (guarda 6139 B); o `sync.md` está no FULL (teto 56900, hoje 55368).
- **interfaces**: consome `bash "<raiz do plugin>/hooks/cleanup" contar` (T1/T2).
- **ponto de mudança**: `skills/validate/references/sync.md:56` — item 6 novo depois do item 5 (HOTFIX).
- **teste**: `tests/test-skill-cleanup.sh` — caso "skill-cleanup/16 sync".
- **asserções** (`flat` do `sync.md`, sem `\r`):
  - contém `hooks/cleanup" contar`, `Sobras do processo: N — rode a skill cleanup quando quiser.`, `N = 0 → nada` e `Nunca rode` + `aplicar`.
  - frases já guardadas do `sync.md` seguem presentes (`tests/test-parada-revisao.sh:84-87`, `tests/test-prd-foto.sh:55-59` verdes).
  - `bash tests/test-carga.sh` verde, FULL ≤ 56900 (medir antes e depois e anotar no comentário da linha 6).
- **ler**: `skills/validate/references/sync.md:50-56`, `tests/test-carga.sh:1-22`.
- **done quando**: asserções passam; suíte verde.

- [ ] **red** — `bash tests/test-skill-cleanup.sh` falha com `FAIL: skill-cleanup/16`
- [ ] **green** — arquivo, `test-carga.sh` e suíte verdes; gate passou
- [ ] **commit** — `git add skills/validate/references/sync.md tests/test-skill-cleanup.sh tests/test-carga.sh && git commit -m "feat(skill-cleanup/16): sync da validate sugere a cleanup com a contagem, sem rodar"`
