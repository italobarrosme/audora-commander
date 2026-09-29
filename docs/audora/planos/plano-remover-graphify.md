# Plano — remover-graphify: Remover Graphify

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** o plugin deixa de oferecer, instalar, consultar e citar o
Graphify; em projeto com restos, a carga de contexto oferece a limpeza
(inclusive o pacote `graphifyy`); este repo fica limpo; versão `0.10.0`.

**Nó do MEMORY:** `remover-graphify` (spec `docs/audora/specs/remover-graphify-escopo.md`)

**Arquitetura da mudança:** a limpeza vira UM script auxiliar,
`hooks/graphify-limpeza [--remover] [dir]` (detecta → lista; `--remover` →
remove e relata), testado com repo git real e `uv`/`pipx` falsos no PATH — é
o que dá cobertura real a /2–/8 (/13). A skill `memory` só chama o script no
carregar-contexto e conversa com o humano. O resto é remoção: etapa Graphify
do bootstrap, operação `consultar-codigo` (reference + menções em
plan/execute/debug), `hooks/graphify-status` + teste, bullet do template,
superfície (READMEs, fundamentos, manifests, session-start). Localização
feita por grep (Constituição diz `graphify: ativo`, mas `graphify` fora do
PATH do Bash — consultar-codigo degradado, avisado).

**Arquivos lidos antes de planejar:**
- `MEMORY.md` — Constituição (`graphify: ativo`, `graphify-status` em stack e
  restricoes), 3 aprendizados sobre Graphify (2026-08-26 `_PINNED`,
  2026-08-31 post-commit, 2026-09-27 PATH), linha do nó.
- `docs/audora/memory/remover-graphify.md`, `docs/audora/specs/remover-graphify-escopo.md`.
- `docs/audora/decisoes-vivas.md` — nenhuma decisão viva sobre Graphify.
- `skills/memory/SKILL.md` — descrição, intro (op. 7), "Raiz do plugin"
  (exemplo `graphify-status`), tabela, carregar-contexto, registrar-delta
  item 4, Conflito, red flags 140–142.
- `skills/memory/references/bootstrap.md` (etapa 4 Graphify, 5 gate),
  `skills/memory/references/consultar-codigo.md` (inteiro).
- `skills/plan/SKILL.md` (passadas 1/2, red flag do índice),
  `skills/execute/SKILL.md` (bullet Localizar), `skills/debug/SKILL.md`
  (passo 2); `skills/worktree`, `audora-commander`, `scope`, `e2e`,
  `validate` — sem menção.
- `templates/MEMORY-template.md` (cabeçalho + bullet `graphify`),
  `templates/plano-template.md`, `templates/bloco-fechamento-template.md`.
- `hooks/graphify-status`, `hooks/session-start`, `hooks/hooks.json`,
  `hooks/gate` (anti-fraude: arquivo apagado sem válvula; `gate-asserts:`).
- `.git/hooks/post-commit` / `post-checkout` deste repo (marcadores
  `# graphify-hook-start|end`, `# graphify-checkout-hook-start|end`),
  `.gitignore`, `.gitattributes` (`hooks/*`, `tests/*` em LF).
- Fonte do `graphifyy` 0.9.11 (`install.py`, `hooks.py`): CLAUDE.md recebe
  seção `## graphify` (até o próximo `## `); `.claude/settings(.local).json`
  recebem entradas em `hooks.PreToolUse` com `graphify` no comando.
- `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` (0.9.0,
  "MEMORY vivo + Graphify", keyword `graphify`).
- `README.md`, `README.pt-BR.md` — princípio 1, pré-requisitos, tabela,
  seções memory/plan/execute/debug, fluxo passo 4, artefatos.
- `docs/fundamentos.md` — P1 fundamento e regra 3, P2 regra 1, Mapa.
- `PRD.md` — só leitura: NÃO é tocado nesta branch (regra global: PRD segue
  a `main`; a validate promove no sync).
- `tests/lib.sh`, `run.sh`, `test-skills.sh`, `test-templates.sh`,
  `test-docs.sh`, `test-dogfood.sh`, `test-carga.sh` (BASE 54888 / teto
  54900), `test-graphify-status.sh`, `test-session-start.sh`, `test-gate.sh`
  (padrão de fixture git).

**Conflitos MEMORY vs código encontrados:** nenhum novo. Constituição
`graphify: ativo` com `graphify` fora do PATH é conhecido (aprendizado
2026-09-27) e some nesta demanda.

## Notas de sessão

- 2026-09-29 (plan): suíte base verde — 780 asserts, 14 arquivos, exit 0.
- 2026-09-29: plano aprovado no portão HIGH (humano: "continue"); execute via subagente de contexto zerado.
- Até a T3 remover os hooks de git do Graphify deste repo, commitar com
  `GRAPHIFY_SKIP_HOOK=1 git commit ...` (evita reconstrução em background).
- Commits: `git add` com caminhos listados, nunca `-A`. Rodar gate/suíte
  redirecionando para arquivo e ler o exit real (`> log 2>&1; echo $?`).
- 2026-09-29 (execute, subagente): T1–T5 verdes, gate exit 0 em cada uma
  (commits 7cca981, 3556406, a210b87, adedb1f, ef4eb54). PARADO antes da T6:
  sem autorização do humano registrada para apagar
  `tests/test-graphify-status.sh` — nada da T6 foi tocado. Retomar pela T6
  passo 1 depois do "sim" (registrar em `## decisoes` do nó).
- 2026-09-29 (execute, subagente): autorização registrada no nó (f9ec3e3);
  T6 (77b82c1) e T7 (116e694) verdes. Gate final em árvore limpa (HEAD 116e694):
  `GATE: passou`, exit 0; suíte 14 arquivos, 861 asserts (somados da saída),
  0 com falha.
- 2026-09-29 (execute, correção A1–A5, subagente): T8–T14 RED→GREEN, gate
  exit 0 em cada uma (commits fe92372, 27e1fc8, 0856a21, 7cb8f79, 23686c2,
  1456bcf, 10702e0). Ajustes de fixture: A4 precisa de `add -f` em
  `graphify-out/graph.json` (o `.gitignore` do `mkproj` já o ignora) e commit
  com `core.hooksPath` vazio (não disparar os hooks falsos); o teste antigo
  "bullet com qualquer valor" anexava o bullet depois de `## Aprendizados` —
  passou a inseri-lo DENTRO da Constituição (menor aprovado: só lá é resto).
- 2026-09-29 (execute, T15): gate final da rodada em árvore limpa (HEAD 60756eb):
  `GATE: passou`, exit 0; suíte 14 arquivos, 898 asserts (somados da saída),
  0 com falha.
- `$SCRATCH` nos comandos = scratchpad da sessão de execução (sem um,
  `SCRATCH="$(mktemp -d)"`). Suíte/gate passam de 120s → `run_in_background`
  e ler o arquivo de saída.

## Decisões tomadas pela IA

- 2026-09-29 (plan): limpeza em script (`hooks/graphify-limpeza`), não em
  prosa — só assim /2–/8 têm teste de verdade (/13); cabe na Constituição
  (executável só em `hooks/` e `tests/`) e substitui `graphify-status` lá.
- 2026-09-29 (plan): pacote detectado só por `uv tool list` e
  `pipx list --short` (os dois instaladores que o bootstrap usava);
  desinstala pelo mesmo que o tem.
- 2026-09-29 (plan): settings reescrito por `JSON::PP` com chaves em ordem
  alfabética (Perl não guarda ordem) — conteúdo preservado, ordem não; só o
  arquivo que tinha hook do Graphify é reescrito. JSON inválido citando
  graphify → listado e falha com comando à mão.
- 2026-09-29 (plan): hooks de git achados por `git rev-parse --git-path
  hooks` (cobre worktree e `core.hooksPath`; o default é `.git/hooks`).
- 2026-09-29 (plan): CLAUDE.md/settings que ficam vazios permanecem — a spec
  manda apagar inteiro só o hook de git.
- 2026-09-29 (plan): dogfood (T3) roda o script com PATH sem `uv`/`pipx` —
  o pacote `graphifyy` desta máquina fica (não está em /12; os 12 projetos
  estão fora de escopo). O humano desinstala quando quiser.
- 2026-09-29 (plan): ausência (/9, /10) guardada por teste onde a palavra
  não tem motivo para aparecer (8 skills, fundamentos, manifests, templates,
  hooks exceto o script); nos READMEs e na skill memory, que descrevem a
  oferta, por frases proibidas. `test-docs` deixa de exigir Graphify no PRD.
- 2026-09-29 (execute, T2): fixture de `test-graphify-limpeza.sh` fixa
  `core.excludesFile` local num arquivo inexistente — o ignore global desta
  máquina (`~/.config/git/ignore`: `**/.claude/settings.local.json`) deixava
  o arquivo fora do índice e o assert `versionado` falhava por ambiente.
- 2026-09-29 (execute, correção): fixture tira do PATH todo diretório com
  `uv`/`pipx` (helper `path_sem_uv` em `tests/lib.sh`) em vez de só
  antepor os falsos — o real nunca fica alcançável, nem por acidente.
- 2026-09-29 (execute, A1): hook do Graphify = entrada de `hooks[]` cujo
  `command` casa `^\s*graphify\b` (espaço inicial tolerado).
- 2026-09-29 (execute, A4): `versionado` sai de `git diff --name-only
  --relative -- <caminhos mexidos>` — mesmo efeito do `status --porcelain`
  sugerido (só rastreado, inclui apagado), mas com caminho relativo ao dir
  do projeto (porcelain é relativo à raiz do repo).
- 2026-09-29 (execute, menores): filtros de texto passam de awk/grep para
  `perl -ne` — awk e grep do Git Bash descartam o `\r`. Números do JSON
  preservados por marcador string antes do decode (JSON::PP normaliza
  `1.50`→`1.5` e transforma inteiro grande em string).
- 2026-09-29 (execute, menores): dir inexistente → mensagem no stderr e
  exit 2 (distinto de 1 = falha parcial), documentado no cabeçalho.

---

## Tarefa 1: script detecta os restos do Graphify

- **depende-de**: []
- **requisito**: **remover-graphify/2** — QUANDO a carga de contexto
  encontrar no projeto qualquer resto do Graphify — bullet `graphify:` na
  Constituição (qualquer valor), bloco do Graphify em `.git/hooks/post-commit`
  ou `.git/hooks/post-checkout`, pasta `graphify-out/`, linha `graphify-out/`
  no `.gitignore`, hook do Graphify em `.claude/settings.json` ou
  `.claude/settings.local.json`, ou seção do Graphify no `CLAUDE.md` — O
  SISTEMA DEVE oferecer a limpeza listando SÓ os itens encontrados, antes de
  seguir a demanda. **remover-graphify/3** — QUANDO a oferta do /2 for feita
  e o pacote `graphifyy` estiver instalado na máquina O SISTEMA DEVE incluir
  na lista a desinstalação do pacote. **remover-graphify/7** — QUANDO o
  humano recusar a limpeza O SISTEMA DEVE não alterar nada, não gravar a
  recusa e seguir a demanda; a próxima carga de contexto oferece de novo
  enquanto houver resto. **remover-graphify/8** — QUANDO o projeto não tiver
  nenhum resto do Graphify O SISTEMA DEVE não mencionar o Graphify nem fazer
  a oferta — pacote instalado na máquina sozinho não dispara a oferta.
- **decisões relevantes**: script (não prosa); pacote só via uv/pipx e só
  consultado se houver outro resto; hooks por `rev-parse --git-path hooks`.
- **interfaces**:
  - produz: `bash hooks/graphify-limpeza [dir]` → stdout, 1 linha por
    resto `<tipo> <alvo>`, NESTA ordem: `constituicao MEMORY.md`,
    `git-hook <hooks>/post-commit`, `git-hook <hooks>/post-checkout`,
    `pasta graphify-out/`, `gitignore .gitignore`,
    `settings .claude/settings.json`, `settings .claude/settings.local.json`,
    `claude-md CLAUDE.md`, `pacote graphifyy (uv)` | `pacote graphifyy (pipx)`.
    Saída vazia = limpo. Exit 0 sempre. Não escreve nada.
- **arquivos**: Criar `hooks/graphify-limpeza`; Teste
  `tests/test-graphify-limpeza.sh` (novo).
- **done quando**: `bash tests/test-graphify-limpeza.sh` → `FAIL=0`; gate
  verde.

- [ ] **1. Teste red** — criar `tests/test-graphify-limpeza.sh`:
  ```bash
  #!/usr/bin/env bash
  # remover-graphify/2..8 — hooks/graphify-limpeza detecta e remove restos do Graphify.
  # Fixture: repo git real + uv/pipx falsos no PATH (controlados por FAKE_*).
  source "$(dirname "$0")/lib.sh"
  L="$ROOT/hooks/graphify-limpeza"
  B="$SP/bin"; mkdir -p "$B"; export FAKE_LOG="$SP/fake.log"
  printf '%s\n' '#!/usr/bin/env bash' 'echo "uv $*" >> "$FAKE_LOG"' \
    'case "$1 $2" in "tool list") printf "%s\n" "${FAKE_UV_LIST:-}" ;; "tool uninstall") exit "${FAKE_UV_EXIT:-0}" ;; esac' > "$B/uv"
  printf '%s\n' '#!/usr/bin/env bash' 'echo "pipx $*" >> "$FAKE_LOG"' \
    'case "$1" in list) printf "%s\n" "${FAKE_PIPX_LIST:-}" ;; uninstall) exit "${FAKE_PIPX_EXIT:-0}" ;; esac' > "$B/pipx"
  chmod +x "$B/uv" "$B/pipx"
  fake() { export FAKE_UV_LIST="$1" FAKE_PIPX_LIST="$2" FAKE_UV_EXIT="${3:-0}" FAKE_PIPX_EXIT="${4:-0}"; : > "$FAKE_LOG"; }
  P="$SP/proj"
  lim() { out="$(cd "$P" && PATH="$B:$PATH" bash "$L" "$@" 2>&1)"; code=$?; }
  mkvazio() {
    rm -rf "$P"; mkdir -p "$P"
    git -C "$P" init -q; git -C "$P" config user.email t@t; git -C "$P" config user.name t
    git -C "$P" config core.autocrlf false
    printf '%s\n' 'memory-schema: 1' '' '## Constituição [carga: sempre]' '' '- **stack**: bash' \
      '- **gate**: `bash gate`' '' '## Aprendizados [carga: sempre]' '' \
      '- 2026-08-26 | execute | graphify hook install grava _PINNED vazio' > "$P/MEMORY.md"
    printf '%s\n' 'node_modules/' '*.log' > "$P/.gitignore"
    git -C "$P" add -A; git -C "$P" commit -qm base
  }
  mkproj() {
    mkvazio; mkdir -p "$P/.claude" "$P/graphify-out"
    printf '%s\n' 'memory-schema: 1' '' '## Constituição [carga: sempre]' '' '- **stack**: bash' \
      '- **graphify**: ativo — índice em' '  `graphify-out/` + git hook post-commit' \
      '- **gate**: `bash gate`' '' '## Aprendizados [carga: sempre]' > "$P/MEMORY.md"
    printf '%s\n' 'node_modules/' 'graphify-out/' '*.log' > "$P/.gitignore"
    printf '%s\n' '{"permissions":{"allow":["Bash(ls:*)"]},"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"graphify hook-guard search"}]},{"matcher":"Edit","hooks":[{"type":"command","command":"meu-lint"}]}]}}' > "$P/.claude/settings.json"
    printf '%s\n' '{"hooks":{"PreToolUse":[{"matcher":"Read|Glob","hooks":[{"type":"command","command":"graphify hook-guard read"}]}]}}' > "$P/.claude/settings.local.json"
    printf '%s\n' '# Projeto' '' '## Regras' 'use tabs' '' '## graphify' 'Grafo de conhecimento do graphify.' '### detalhe' 'x' '' '## Outra' 'fim' > "$P/CLAUDE.md"
    echo '{}' > "$P/graphify-out/graph.json"
    git -C "$P" add -A; git -C "$P" commit -qm restos
    printf '%s\n' '#!/bin/sh' 'echo meu-hook' '# graphify-hook-start' 'python rebuild' '# graphify-hook-end' > "$P/.git/hooks/post-commit"
    printf '%s\n' '#!/bin/sh' '# graphify-checkout-hook-start' 'python rebuild' '# graphify-checkout-hook-end' > "$P/.git/hooks/post-checkout"
  }
  RESTOS="$(printf '%s\n' 'constituicao MEMORY.md' 'git-hook .git/hooks/post-commit' 'git-hook .git/hooks/post-checkout' 'pasta graphify-out/' 'gitignore .gitignore' 'settings .claude/settings.json' 'settings .claude/settings.local.json' 'claude-md CLAUDE.md')"

  # /2 — cada tipo, na ordem fixa; sem pacote na máquina, sem linha de pacote
  mkproj; fake '' ''; lim .
  assert_eq 0 "$code" "remover-graphify/2 detecção sai 0"
  assert_eq "$RESTOS" "$out" "remover-graphify/2 lista os 8 restos"
  # /2 — SÓ o que existe, um tipo por vez
  mkvazio; printf '%s\n' '- **graphify**: recusado' >> "$P/MEMORY.md"; fake '' ''; lim .
  assert_eq 'constituicao MEMORY.md' "$out" "remover-graphify/2 bullet graphify com qualquer valor"
  mkvazio; printf 'graphify-out/\n' >> "$P/.gitignore"; fake 'graphifyy v0.9.11' ''; lim .
  assert_eq "$(printf '%s\n' 'gitignore .gitignore' 'pacote graphifyy (uv)')" "$out" "remover-graphify/2,3 só o .gitignore + pacote uv"
  mkvazio; mkdir "$P/graphify-out"; fake '' 'graphifyy 0.9.11'; lim .
  assert_eq "$(printf '%s\n' 'pasta graphify-out/' 'pacote graphifyy (pipx)')" "$out" "remover-graphify/3 pacote via pipx"
  mkvazio; printf '%s\n' '#!/bin/sh' '# graphify-checkout-hook-start' 'x' '# graphify-checkout-hook-end' > "$P/.git/hooks/post-checkout"; fake '' ''; lim .
  assert_eq 'git-hook .git/hooks/post-checkout' "$out" "remover-graphify/2 hook post-checkout sozinho"
  mkvazio; mkdir -p "$P/.claude"; printf '%s\n' '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"graphify hook-guard search"}]}]}}' > "$P/.claude/settings.local.json"; fake '' ''; lim .
  assert_eq 'settings .claude/settings.local.json' "$out" "remover-graphify/2 settings.local.json sozinho"
  mkvazio; printf '%s\n' '# P' '## graphify' 'x' > "$P/CLAUDE.md"; fake '' ''; lim .
  assert_eq 'claude-md CLAUDE.md' "$out" "remover-graphify/2 seção do CLAUDE.md sozinha"
  # /2 borda — graphify fora de hooks não é resto; JSON inválido citando graphify é
  mkvazio; mkdir -p "$P/.claude"; printf '%s\n' '{"permissions":{"allow":["Bash(graphify:*)"]}}' > "$P/.claude/settings.json"; fake '' ''; lim .
  assert_empty "$out" "remover-graphify/2 graphify em permissions não é hook"
  printf '{"hooks": graphify quebrado' > "$P/.claude/settings.json"; lim .
  assert_eq 'settings .claude/settings.json' "$out" "remover-graphify/2 JSON inválido citando graphify é listado"
  # /2 borda — fora de repo git: sem git-hook, sem erro
  rm -rf "$P"; mkdir -p "$P"; printf 'graphify-out/\n' > "$P/.gitignore"; fake '' ''; lim .
  assert_eq 0 "$code" "remover-graphify/2 fora de repo git sai 0"
  assert_eq 'gitignore .gitignore' "$out" "remover-graphify/2 fora de repo git lista só o que há"
  # /8 — projeto limpo: silêncio, e o pacote nem é consultado
  mkvazio; fake 'graphifyy v0.9.11' 'graphifyy 0.9.11'; lim .
  assert_eq 0 "$code" "remover-graphify/8 projeto limpo sai 0"
  assert_empty "$out" "remover-graphify/8 projeto limpo não cita Graphify (aprendizado com a palavra não conta)"
  assert_empty "$(cat "$FAKE_LOG")" "remover-graphify/8 pacote sozinho nem é consultado"
  # /7 — detectar não altera nada; a oferta volta na carga seguinte
  mkproj; fake 'graphifyy v0.9.11' ''
  snap() { (cd "$P" && find . -path ./.git/objects -prune -o -type f -print | sort | xargs md5sum); }
  antes="$(snap)"; lim .; lim .
  assert_eq "$antes" "$(snap)" "remover-graphify/7 detecção (2x) não altera arquivo nenhum"
  assert_contains "$out" 'pacote graphifyy (uv)' "remover-graphify/7 a oferta volta na carga seguinte"
  report
  ```
- [ ] **2. Rodar** `bash tests/test-graphify-limpeza.sh; echo "exit=$?"` →
  `FAIL:` nos asserts de saída/código, com `No such file` (script ausente),
  `exit=1` (os de "nada mudou" passam por vacuidade — esperado).
- [ ] **3. Implementar** `hooks/graphify-limpeza` (bash, LF, `set -uo
  pipefail`; cabeçalho de comentário com uso, tipos, ordem e exit — o
  contrato da seção interfaces). Não-óbvio:
  - flag: `[ "${1:-}" = "--remover" ] && { remover=1; shift; }`; `cd "${1:-.}"`.
  - constituicao: `grep -qE '^- \*\*graphify\*\*:' MEMORY.md`.
  - git-hook: `hk="$(git rev-parse --git-path hooks 2>/dev/null)"` (vazio
    fora de repo → pula); resto se `grep -qE '^# graphify-(checkout-)?hook-start' "$hk/post-commit"` (idem post-checkout).
  - gitignore: `grep -qE '^/?graphify-out/?[[:space:]]*$' .gitignore`
    (`[[:space:]]` engole `\r`); pasta: `[ -d graphify-out ]`.
  - claude-md: `grep -qE '^## [Gg]raphify[[:space:]]*$' CLAUDE.md`.
  - settings: função única usada também na T2 (exit 0 = tem hook do
    Graphify, 1 = não tem, 2 = JSON inválido); resto se exit 0, ou exit 2 E
    `grep -qi graphify` no arquivo:
    ```bash
    json_graphify() {  # <arquivo> <detectar|remover>; remover imprime o JSON novo
      MODO="$2" perl -MJSON::PP -0777 -e '
        my $j = eval { JSON::PP->new->utf8->decode(scalar <STDIN>) };
        exit 2 unless ref $j eq "HASH";
        my $H = $j->{hooks}; exit 1 unless ref $H eq "HASH";
        my $enc = JSON::PP->new->utf8->canonical; my $n = 0;
        for my $ev (keys %$H) {
          next unless ref $H->{$ev} eq "ARRAY";
          my @fica = grep { $enc->encode($_) !~ /graphify/i } @{ $H->{$ev} };
          my $tirou = @{ $H->{$ev} } - @fica; $n += $tirou;
          if ($tirou && !@fica) { delete $H->{$ev} } else { $H->{$ev} = \@fica }
        }
        exit 1 unless $n;
        delete $j->{hooks} unless %$H;
        print JSON::PP->new->utf8->canonical->pretty->space_before(0)->indent_length(2)->encode($j) if $ENV{MODO} eq "remover";
        exit 0' < "$1"
    }
    ```
  - pacote (só se a lista do projeto não estiver vazia):
    `command -v uv >/dev/null 2>&1 && uv tool list 2>/dev/null | grep -q '^graphifyy '` → `uv`;
    senão `command -v pipx >/dev/null 2>&1 && pipx list --short 2>/dev/null | grep -q '^graphifyy '` → `pipx`.
- [ ] **4. Rodar** `bash tests/test-graphify-limpeza.sh; echo "exit=$?"` →
  `test-graphify-limpeza.sh: PASS=17 FAIL=0`, `exit=0`; depois
  `bash hooks/gate remover-graphify > "$SCRATCH/gate.log" 2>&1; echo $?` →
  `0`, log termina em `GATE: passou`.
- [ ] **5. Commit** — `git add hooks/graphify-limpeza tests/test-graphify-limpeza.sh && git update-index --chmod=+x hooks/graphify-limpeza && GRAPHIFY_SKIP_HOOK=1 git commit -m "feat(remover-graphify/2,3,7,8): graphify-limpeza detecta restos do Graphify"`.

## Tarefa 2: script remove os restos (`--remover`)

- **depende-de**: [Tarefa 1]
- **requisito**: **remover-graphify/4** — QUANDO o humano aprovar a limpeza
  O SISTEMA DEVE remover cada item listado e relatar, item a item, o que saiu
  e os arquivos versionados que mudaram, sem commitar por conta própria.
  **remover-graphify/5** — QUANDO um hook de git, o `.gitignore`, o
  `settings.json` ou o `CLAUDE.md` tiver conteúdo além do Graphify O SISTEMA
  DEVE remover só a parte do Graphify e preservar o resto (JSON continua
  válido); arquivo de hook que só continha o Graphify sai inteiro.
  **remover-graphify/6** — QUANDO a remoção de um item falhar (arquivo
  bloqueado, desinstalação com erro, sem permissão) O SISTEMA DEVE seguir
  com os demais, relatar o que falhou com o comando para fazer à mão, e não
  travar a demanda.
- **decisões relevantes**: nunca commita; aprovação é da lista inteira;
  JSON reescrito ordenado; CLAUDE.md/settings vazios ficam.
- **interfaces**:
  - consome: detecção e `json_graphify` da T1.
  - produz: `bash hooks/graphify-limpeza --remover [dir]` → por item, na
    ordem da detecção, `removido <tipo> <alvo>` ou
    `falhou <tipo> <alvo> — à mão: <comando>`; depois `versionado <arquivo>`
    para cada arquivo que o script ALTEROU e que é rastreado
    (`git ls-files --error-unmatch`). Exit 0 = tudo removido; 1 = algum
    falhou (os demais seguem). Sem resto → silêncio, exit 0.
- **arquivos**: Modificar `hooks/graphify-limpeza`,
  `tests/test-graphify-limpeza.sh`.
- **done quando**: teste `FAIL=0`; gate verde.

- [ ] **1. Teste red** — em `tests/test-graphify-limpeza.sh`, ANTES do
  `report` final:
  ```bash
  # /4 — aprovado: remove tudo, relata item a item, lista versionados, não commita
  mkproj; fake 'graphifyy v0.9.11' ''; lim --remover .
  assert_eq 0 "$code" "remover-graphify/4 remoção completa sai 0"
  while IFS= read -r l; do assert_contains "$out" "removido $l" "remover-graphify/4 relata $l"; done <<< "$RESTOS"
  assert_contains "$out" 'removido pacote graphifyy (uv)' "remover-graphify/3,4 relata o pacote"
  assert_contains "$(cat "$FAKE_LOG")" 'uv tool uninstall graphifyy' "remover-graphify/3,4 desinstala pelo instalador que o tem"
  for v in MEMORY.md .gitignore .claude/settings.json .claude/settings.local.json CLAUDE.md; do
    assert_contains "$out" "versionado $v" "remover-graphify/4 relata versionado $v"
  done
  assert_eq 2 "$(git -C "$P" rev-list --count HEAD)" "remover-graphify/4 não commita"
  fake '' ''; lim .
  assert_empty "$out" "remover-graphify/4 depois da remoção não sobra resto"
  # /5 — só a parte do Graphify sai; o resto fica
  pc="$(cat "$P/.git/hooks/post-commit" 2>/dev/null)"
  assert_contains "$pc" 'echo meu-hook' "remover-graphify/5 hook preserva o conteúdo alheio"
  assert_not_contains "$pc" 'graphify' "remover-graphify/5 bloco do Graphify saiu do hook"
  assert_no_file "$P/.git/hooks/post-checkout" "remover-graphify/5 hook só do Graphify sai inteiro"
  assert_no_file "$P/graphify-out" "remover-graphify/4 pasta graphify-out/ removida"
  assert_eq "$(printf '%s\n' 'node_modules/' '*.log')" "$(cat "$P/.gitignore")" "remover-graphify/5 .gitignore preserva as outras linhas"
  for s in .claude/settings.json .claude/settings.local.json; do
    perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' < "$P/$s" 2>/dev/null && ok || ko "remover-graphify/5 $s JSON inválido"
    assert_not_contains "$(cat "$P/$s")" 'graphify' "remover-graphify/5 $s sem hook do Graphify"
  done
  sj="$(cat "$P/.claude/settings.json")"
  assert_contains "$sj" 'meu-lint' "remover-graphify/5 settings preserva hook alheio"
  assert_contains "$sj" 'Bash(ls:*)' "remover-graphify/5 settings preserva permissions"
  cm="$(cat "$P/CLAUDE.md")"
  for s in '# Projeto' '## Regras' 'use tabs' '## Outra' 'fim'; do assert_contains "$cm" "$s" "remover-graphify/5 CLAUDE.md preserva '$s'"; done
  assert_not_contains "$cm" 'graphify' "remover-graphify/5 seção do Graphify saiu do CLAUDE.md"
  assert_not_contains "$cm" '### detalhe' "remover-graphify/5 subseção do Graphify saiu junto"
  mm="$(cat "$P/MEMORY.md")"
  assert_not_contains "$mm" 'graphify' "remover-graphify/5 bullet e continuação saíram da Constituição"
  assert_contains "$mm" '- **stack**: bash' "remover-graphify/5 Constituição preserva stack"
  assert_contains "$mm" '- **gate**: `bash gate`' "remover-graphify/5 Constituição preserva gate"
  # /6 — falha num item não trava os demais; relata o comando à mão
  mkproj; printf '{"hooks": graphify quebrado' > "$P/.claude/settings.json"; fake 'graphifyy v0.9.11' '' 1; lim --remover .
  assert_eq 1 "$code" "remover-graphify/6 falha parcial sai 1"
  assert_contains "$out" 'falhou settings .claude/settings.json — à mão:' "remover-graphify/6 JSON inválido vira comando à mão"
  assert_eq '{"hooks": graphify quebrado' "$(cat "$P/.claude/settings.json")" "remover-graphify/6 arquivo que falhou fica intocado"
  assert_contains "$out" 'falhou pacote graphifyy (uv) — à mão: uv tool uninstall graphifyy' "remover-graphify/6 desinstalação com erro vira comando à mão"
  assert_contains "$out" 'removido settings .claude/settings.local.json' "remover-graphify/6 segue no item seguinte"
  assert_contains "$out" 'removido claude-md CLAUDE.md' "remover-graphify/6 segue até o fim"
  assert_not_contains "$out" 'versionado .claude/settings.json' "remover-graphify/6 arquivo que falhou não é relatado como alterado"
  # /3,/4 — pacote via pipx é desinstalado pelo pipx
  mkvazio; mkdir "$P/graphify-out"; fake '' 'graphifyy 0.9.11'; lim --remover .
  assert_contains "$(cat "$FAKE_LOG")" 'pipx uninstall graphifyy' "remover-graphify/3,4 desinstala via pipx"
  assert_contains "$out" 'removido pacote graphifyy (pipx)' "remover-graphify/4 relata o pacote pipx"
  # /8 — --remover sem resto: silêncio; /4 — fora de repo git: sem versionado
  mkvazio; fake 'graphifyy v0.9.11' ''; lim --remover .
  assert_eq 0 "$code" "remover-graphify/8 --remover em projeto limpo sai 0"
  assert_empty "$out" "remover-graphify/8 --remover em projeto limpo é silencioso"
  rm -rf "$P"; mkdir -p "$P/graphify-out"; fake '' ''; lim --remover .
  assert_eq 'removido pasta graphify-out/' "$out" "remover-graphify/4 fora de repo git remove sem versionado"
  ```
- [ ] **2. Rodar** `bash tests/test-graphify-limpeza.sh; echo "exit=$?"` →
  FAIL nos casos novos (o `--remover` hoje só lista/ignora), `exit=1`.
- [ ] **3. Implementar** em `hooks/graphify-limpeza` o laço `--remover`
  sobre a lista detectada; cada remoção grava num `mktemp` e copia com
  `cat "$tmp" > "$f"` (preserva modo); falha de escrita/`rm` → `falhou`.
  Arquivos alterados com sucesso vão para `mudou[]`. Não-óbvio:
  - constituicao (bullet + continuação indentada):
    `awk '/^- \*\*graphify\*\*:/{s=1;next} s&&/^[[:space:]]+[^[:space:]]/{next} {s=0;print}'`
  - git-hook: `awk '/^# graphify-(checkout-)?hook-start/{s=1;next} s&&/^# graphify-(checkout-)?hook-end/{s=0;next} !s'`;
    sobrou só shebang/branco (`! grep -qvE '^(#!.*)?[[:space:]]*$' "$tmp"`) → `rm -f` do hook.
  - gitignore: `grep -vE '^/?graphify-out/?[[:space:]]*$' .gitignore > "$tmp" || true`.
  - pasta: `rm -rf graphify-out`; ainda existe → falhou.
  - settings: `json_graphify "$f" remover > "$tmp"`; exit ≠ 0 → falhou.
  - claude-md: `awk '/^## [Gg]raphify[[:space:]]*$/{s=1;next} s&&/^## /{s=0} !s'`.
  - pacote: `uv tool uninstall graphifyy >/dev/null 2>&1` ou
    `pipx uninstall graphifyy >/dev/null 2>&1`.
  - comandos à mão, literais: constituicao `apague o bullet "- **graphify**:" da Constituição em MEMORY.md`;
    git-hook `apague de <alvo> o bloco entre graphify-*hook-start e graphify-*hook-end`;
    pasta `rm -rf graphify-out`; gitignore `apague a linha graphify-out/ de .gitignore`;
    settings `apague de <alvo> as entradas de hooks que citam graphify`;
    claude-md `apague a seção "## graphify" de CLAUDE.md`;
    pacote `uv tool uninstall graphifyy` | `pipx uninstall graphifyy`.
  - fim: `for f in "${mudou[@]}"; do git ls-files --error-unmatch -- "$f" >/dev/null 2>&1 && echo "versionado $f"; done`.
- [ ] **4. Rodar** `bash tests/test-graphify-limpeza.sh; echo "exit=$?"` →
  `PASS=68 FAIL=0`, `exit=0`; gate → `0`, `GATE: passou`.
- [ ] **5. Commit** — `git add hooks/graphify-limpeza tests/test-graphify-limpeza.sh && GRAPHIFY_SKIP_HOOK=1 git commit -m "feat(remover-graphify/4,5,6): graphify-limpeza --remover preserva o alheio e segue na falha"`.

## Tarefa 3: dogfood — este repositório sem resto do Graphify

- **depende-de**: [Tarefa 2]
- **requisito**: **remover-graphify/12** — QUANDO a demanda fechar O SISTEMA
  DEVE ter este repositório sem resto do Graphify: Constituição sem bullet
  `graphify:`, sem hooks de git do Graphify, sem `graphify-out/` e sem a
  linha no `.gitignore`; aprendizados sobre o Graphify marcados
  `[invalidado-em:]` com motivo, nunca apagados.
- **decisões relevantes**: roda o script real com PATH sem uv/pipx (pacote
  da máquina fica); `gate-asserts:` entra no nó já aqui e vale para a
  demanda (queda aprovada em /13).
- **interfaces**: consome `hooks/graphify-limpeza [--remover] .`.
- **arquivos**: Modificar `tests/test-dogfood.sh`, `MEMORY.md`,
  `.gitignore` (pelo script), `docs/audora/memory/remover-graphify.md`;
  não versionados: `.git/hooks/post-commit`, `.git/hooks/post-checkout`,
  `graphify-out/`.
- **done quando**: `bash hooks/graphify-limpeza .` vazio neste repo;
  test-dogfood `FAIL=0`; gate verde.

- [ ] **1. Teste red** — `tests/test-dogfood.sh`: comentário da linha 2 →
  `# memory-graphify/9; remover-graphify/12 — este repositório usa MEMORY, sem resto do Graphify.`;
  trocar a linha `assert_contains "$m" '**graphify**: ativo' ...` por
  `assert_not_contains "$m" '**graphify**:' "remover-graphify/12 Constituição sem bullet graphify"`;
  trocar `grep -q '^graphify-out/$' .gitignore && ok || ko "/12 gitignore"` e
  o bloco `if command -v graphify ... fi` inteiro por:
  ```bash
  grep -q 'graphify-out' .gitignore && ko "remover-graphify/12 .gitignore ainda cita graphify-out" || ok
  assert_empty "$(bash hooks/graphify-limpeza .)" "remover-graphify/12 repo sem resto do Graphify"
  for t in '_PINNED' 'O post-commit do Graphify' 'e `graphify` não estão no PATH'; do
    assert_contains "$(grep -F -- "$t" MEMORY.md)" '[invalidado-em: 2026-09-29]' "remover-graphify/12 aprendizado '$t' invalidado, não apagado"
  done
  ```
- [ ] **2. Rodar** `bash tests/test-dogfood.sh; echo "exit=$?"` → FAIL em
  bullet, `.gitignore`, detecção não vazia e 3 aprendizados; `exit=1`.
- [ ] **3. Nó**: em `docs/audora/memory/remover-graphify.md`, após o último
  bullet de `## decisoes`, linha solta:
  `gate-asserts: queda aprovada no escopo (/13) — asserts de graphify-status, consultar-codigo, etapa Graphify do bootstrap e dogfood antigo saem com o comportamento; limpeza (/2–/8) coberta por tests/test-graphify-limpeza.sh.`
- [ ] **4. Limpar o repo com o script real** —
  `PATH="/mingw64/bin:/usr/bin" bash hooks/graphify-limpeza .` → exatamente
  `constituicao MEMORY.md`, `git-hook .git/hooks/post-commit`,
  `git-hook .git/hooks/post-checkout`, `pasta graphify-out/`,
  `gitignore .gitignore` (sem `pacote`). Depois
  `PATH="/mingw64/bin:/usr/bin" bash hooks/graphify-limpeza --remover .; echo $?`
  → 5 `removido ...`, `versionado MEMORY.md`, `versionado .gitignore`, `0`.
  `falhou pasta` (Python de reconstrução segurando arquivo) → esperar e
  `rm -rf graphify-out`.
- [ ] **5. MEMORY.md à mão** (Edit): cabeçalho — `> templates/no-template.md). O CÓDIGO não vive aqui: é indexado pelo` +
  `> Graphify em \`graphify-out/\` (fora do git) e consultado pela skill memory.` →
  `> templates/no-template.md).`; Propósito — `MEMORY vivo (com o código indexado por baixo pelo` + `Graphify), planejamento` →
  `MEMORY vivo, planejamento`; stack e restricoes — `graphify-status` →
  `graphify-limpeza`; linha do índice do nó — `hooks/graphify-status` →
  `hooks/graphify-limpeza`; aprendizados 2026-08-26 (`_PINNED`) e 2026-08-31
  (post-commit) recebem ao fim
  `[invalidado-em: 2026-09-29] [substituido-por: remover-graphify — Graphify removido do plugin]`;
  o de 2026-09-27 (`claude` e `graphify` fora do PATH) recebe
  `[invalidado-em: 2026-09-29] [substituido-por: linha 2026-09-29 do claude.exe]`
  e entra logo abaixo:
  `- 2026-09-29 | plan | Nesta máquina \`claude\` não está no PATH do Bash tool — usar \`~/.local/bin/claude.exe\` (ou \`PATH="$HOME/.local/bin:$PATH"\` antes do \`./install.sh\`).`
- [ ] **6. Rodar** `bash tests/test-dogfood.sh` → `FAIL=0`; gate → `0`.
- [ ] **7. Commit** — `git add tests/test-dogfood.sh MEMORY.md .gitignore docs/audora/memory/remover-graphify.md && git commit -m "chore(remover-graphify/12): dogfood — repo sem resto do Graphify; aprendizados invalidados"`
  (hooks do Graphify já saíram: sem `GRAPHIFY_SKIP_HOOK`).

## Tarefa 4: fases sem `consultar-codigo`

- **depende-de**: [Tarefa 3]
- **requisito**: **remover-graphify/9** — QUANDO as fases plan, execute e
  debug precisarem localizar código O SISTEMA DEVE usar a busca normal do
  harness, sem operação `consultar-codigo`, sem índice e sem regra
  substituta; a skill `memory` fica com as operações de memória, sem a de
  código.
- **decisões relevantes**: sem regra substituta (humano) — o texto só perde
  o ramo do índice, não ganha "use Grep". Vem antes da T5 porque tira
  ~1,9 KB da carga BASE (teto 54900, hoje 54888) e abre espaço para a oferta.
- **arquivos**: Apagar `skills/memory/references/consultar-codigo.md`;
  Modificar `skills/memory/SKILL.md`, `skills/plan/SKILL.md`,
  `skills/execute/SKILL.md`, `skills/debug/SKILL.md`,
  `tests/test-skills.sh`, `tests/test-carga.sh`.
- **done quando**: `grep -rniE 'consultar-codigo|operação 7' skills` vazio;
  suíte e gate verdes.

- [ ] **1. Teste red** — `tests/test-skills.sh`: comentário `# /3 — a tabela do roteador nomeia as 7 operações` → `6 operações` e tirar
  `consultar-codigo` do laço (fica `registrar-aprendizado compactar; do`);
  laço `/7`: `for b in bootstrap registrar-no compactar; do`; apagar o laço
  `for s in 'graphify query' ... consultar-codigo.md ...`; trocar os dois
  laços `/14` (plan execute debug) e `/18` (scope e2e validate
  audora-commander) por:
  ```bash
  # remover-graphify/9,/10 — fases e worktree sem Graphify e sem consulta ao índice de código
  for s in audora-commander scope plan execute e2e validate debug worktree; do
    grep -qiE 'graphify|consultar-codigo' "skills/$s/SKILL.md" && ko "remover-graphify/9 $s cita graphify/consultar-codigo" || ok
  done
  assert_no_file "$MR/consultar-codigo.md" "remover-graphify/9 reference consultar-codigo removida"
  for s in 'consultar-codigo' 'operação 7' 'graphify query' 'graphify update'; do
    assert_not_contains "$m" "$s" "remover-graphify/9 memory sem '$s'"
  done
  ```
  `tests/test-carga.sh`: tirar ` $R/consultar-codigo.md` de `BASE_LIST`.
- [ ] **2. Rodar** `bash tests/test-skills.sh; echo "exit=$?"` → FAIL em
  plan/execute/debug, reference existente e memory com `consultar-codigo`.
- [ ] **3. Implementar**:
  - `git rm skills/memory/references/consultar-codigo.md`.
  - memory: descrição — `, compactação, ou consulta ao índice de código (consultar-codigo) pelas fases plan, debug e execute.'` → `, ou compactação.'`;
    intro — apagar `O código em si NÃO vive aqui — é indexado pelo **Graphify** (\`graphify-out/\`, fora do git, só código, sem API key) e consultado pela operação 7.`;
    tabela — apagar `| consultar-codigo | references/consultar-codigo.md |`;
    apagar a linha `Código: nunca "varrer o repo para entender" — operação 7.`;
    Conflito — `afetados (via operação 7, \`references/consultar-codigo.md\`) e algo contradiz` → `afetados e algo contradiz`;
    red flags — apagar as linhas "Leio o arquivo direto, o índice deve estar velho" e "Graphify falhou, paro a demanda até arrumar".
  - plan: passo 2 inteiro vira
    `2. **Passada 1 — localizar**: a partir do escopo, achar onde a mudança mora` +
    `   (símbolos, rotas, nomes de domínio). Não ler nada ainda — só listar.`;
    passo 3 — apagar `Read fora do apontado só com exceção declarada ("índice não cobre X porque …").`;
    red flags — apagar a linha "Grep no repo inteiro é mais seguro que o índice".
  - execute: apagar o bullet `- **Localizar** (...)` inteiro (5 linhas, até `entender".`).
  - debug, passo 2: apagar de `Constituição \`graphify: ativo\` → skill memory` até `senão grep.` (fica `lembra que fazia. Diff recente`).
- [ ] **4. Rodar** `bash tests/run.sh > "$SCRATCH/suite.log" 2>&1; echo $?`
  → `0` (test-carga imprime base menor que 54888); gate → `0`, com a linha
  `GATE: asserts N → M com justificativa no nó: gate-asserts: ...`.
- [ ] **5. Commit** — `git add skills/memory/SKILL.md skills/memory/references/consultar-codigo.md skills/plan/SKILL.md skills/execute/SKILL.md skills/debug/SKILL.md tests/test-skills.sh tests/test-carga.sh && git commit -m "refactor(remover-graphify/9): fases localizam código sem consultar-codigo"`.

## Tarefa 5: bootstrap sem Graphify; carga de contexto oferece a limpeza

- **depende-de**: [Tarefa 4]
- **requisito**: **remover-graphify/1** — QUANDO o bootstrap rodar num
  projeto sem `MEMORY.md` O SISTEMA DEVE criar o MEMORY sem oferecer nem
  instalar o Graphify: nenhum bullet `graphify:` na Constituição, nenhum hook
  de git do Graphify, nenhuma linha `graphify-out/` no `.gitignore`.
  **remover-graphify/2**, **/3**, **/4**, **/6**, **/7**, **/8** (texto na
  Tarefa 1 e 2) — lado da skill: quando chamar, o que perguntar, o que não
  fazer.
- **decisões relevantes**: aprovação da lista inteira ("Remover tudo?");
  limpeza não commita; recusa não gravada; oferta inline no carregar-contexto
  (operação quente), sem reference nova.
- **interfaces**: consome `bash "<raiz do plugin>/hooks/graphify-limpeza" .`
  e `... --remover .` (T1/T2).
- **arquivos**: Modificar `skills/memory/SKILL.md`,
  `skills/memory/references/bootstrap.md`, `templates/MEMORY-template.md`,
  `tests/test-skills.sh`, `tests/test-templates.sh`.
- **done quando**: `grep -ci graphify skills/memory/references/bootstrap.md templates/*.md`
  tudo 0; suíte e gate verdes.

- [ ] **1. Teste red** — `tests/test-skills.sh`: trocar o laço
  `for s in 'hooks/graphify-status' ... bootstrap.md ...` por:
  ```bash
  # remover-graphify/1 — bootstrap não oferece nem instala o Graphify; o gate fecha o bootstrap
  grep -qi 'graphify' "$MR/bootstrap.md" && ko "remover-graphify/1 bootstrap cita graphify" || ok
  assert_contains "$(cat "$MR/bootstrap.md")" '**Etapa gate** (sempre, ao fim do bootstrap)' "remover-graphify/1 gate fecha o bootstrap"
  # remover-graphify/2..8 — carregar-contexto oferece a limpeza (asserido DENTRO da seção)
  cc="$(awk '/^### 1\. carregar-contexto/{f=1;next} /^### /{f=0} f' "$MS")"
  for s in 'hooks/graphify-limpeza" .' 'Saída vazia → seguir sem citar o assunto' 'listar SÓ o que saiu' 'Remover tudo?' 'graphify-limpeza" --remover .' 'item a item' 'não trava a demanda' 'NÃO commitar' 'não gravar nada' 'a próxima carga oferece de novo'; do
    assert_contains "$cc" "$s" "remover-graphify/2-8 carregar-contexto: '$s'"
  done
  for s in 'hooks/graphify-status' 'Instalo o Graphify' 'inclui oferta e ativação do Graphify'; do
    assert_not_contains "$m" "$s" "remover-graphify/1,10 memory sem '$s'"
  done
  ```
  `tests/test-templates.sh`: trocar a linha do `'**graphify**:'` por
  `assert_empty "$(grep -li graphify templates/*.md)" "remover-graphify/1,10 templates sem Graphify"`.
- [ ] **2. Rodar** `bash tests/test-skills.sh; bash tests/test-templates.sh`
  → FAIL nos asserts novos (bootstrap cita graphify; carregar-contexto sem
  a oferta; template com bullet).
- [ ] **3. Implementar**:
  - bootstrap.md: apagar o item 4 inteiro (**Etapa Graphify**, a–f); item 5
    vira `4. **Etapa gate** (sempre, ao fim do bootstrap):`; item 6 vira 5.
  - MEMORY-template: cabeçalho — `> templates/no-template.md). O CÓDIGO não vive aqui: é indexado pelo` +
    `> Graphify em \`graphify-out/\` (fora do git) e consultado pela skill memory.` →
    `> templates/no-template.md).`; apagar o bullet `- **graphify**: ...` (3 linhas).
  - memory: descrição — `bootstrap em projeto sem MEMORY.md (inclui oferta e ativação do Graphify), carga de contexto no início de uma demanda,` →
    `bootstrap em projeto sem MEMORY.md, carga de contexto no início de uma demanda (inclui a oferta de limpar restos do Graphify),`;
    "Raiz do plugin" — `hooks/graphify-status" .` → `hooks/graphify-limpeza" .`;
    carregar-contexto passo 3 — `Constituição (inclui o bullet \`graphify\`) +` → `Constituição +`;
    registrar-delta item 4 — `escolhida, estado do \`graphify\`): editar` → `escolhida): editar`;
    red flags — apagar a linha "Instalo o Graphify sem perguntar";
    carregar-contexto ganha o passo 5, EXATAMENTE nestas quebras (cada
    frase asserida cabe numa linha):
    ```markdown
    5. **Restos do Graphify** (o framework não usa mais): rodar
       `bash "<raiz do plugin>/hooks/graphify-limpeza" .` (1 linha por resto).
       Saída vazia → seguir sem citar o assunto. Com linhas → ANTES da demanda,
       listar SÓ o que saiu e perguntar uma vez: "Remover tudo?". Aprovou →
       `bash "<raiz do plugin>/hooks/graphify-limpeza" --remover .` e relatar
       item a item (`removido`, `falhou` + comando à mão, `versionado`); falha
       não trava a demanda; NÃO commitar. Recusou → não mexer, não gravar nada;
       a próxima carga oferece de novo.
    ```
- [ ] **4. Rodar** suíte (`> "$SCRATCH/suite.log" 2>&1; echo $?` → `0`;
  test-carga abaixo do teto 54900) e gate → `0`.
- [ ] **5. Commit** — `git add skills/memory/SKILL.md skills/memory/references/bootstrap.md templates/MEMORY-template.md tests/test-skills.sh tests/test-templates.sh && git commit -m "feat(remover-graphify/1,2,7,8): bootstrap sem Graphify; carga de contexto oferece a limpeza"`.

## Tarefa 6: `graphify-status` sai

- **depende-de**: [Tarefa 3, Tarefa 4, Tarefa 5]
- **requisito**: **remover-graphify/13** — QUANDO o gate rodar ao fim da
  demanda O SISTEMA DEVE sair 0: o comportamento da limpeza (/2–/8) tem
  cobertura na suíte, e a queda de asserts de `graphify-status` passa só com
  `gate-asserts:` justificado no nó e a remoção do arquivo de teste
  autorizada no commit. **remover-graphify/10** (parte `hooks`).
- **decisões relevantes**: aprendizado 2026-09-27 — o gate não tem válvula
  para arquivo de teste apagado: a remoção exige autorização explícita do
  humano ANTES do commit (parada pontual, não é portão de fase).
- **arquivos**: Apagar `hooks/graphify-status`, `tests/test-graphify-status.sh`;
  Modificar `tests/test-graphify-limpeza.sh`, `docs/audora/memory/remover-graphify.md`.
- **done quando**: `grep -rn 'graphify-status' skills templates hooks tests MEMORY.md README.md README.pt-BR.md docs/fundamentos.md .claude-plugin`
  só acha asserts de ausência (`tests/test-skills.sh`,
  `tests/test-graphify-limpeza.sh`) e a lista do PRD em `tests/test-docs.sh`
  (sai na T7); commit autorizado.

- [ ] **1. Teste red** — em `tests/test-graphify-limpeza.sh`, antes do `report`:
  `assert_no_file "$ROOT/hooks/graphify-status" "remover-graphify/10 classificador do índice removido"`.
- [ ] **2. Rodar** o arquivo → `FAIL: ... ainda existe: .../hooks/graphify-status`.
- [ ] **3. Implementar** — `git rm hooks/graphify-status tests/test-graphify-status.sh`.
- [ ] **4. Rodar** suíte → `0` (`PASS=69 FAIL=0` no arquivo novo); gate →
  esperado `GATE: reprovado — 1 motivo(s)`: `arquivo de teste apagado: tests/test-graphify-status.sh`.
  Qualquer outro motivo → corrigir antes. **PARAR e pedir ao humano
  autorização para commitar a remoção**; registrar a resposta em `## decisoes`
  do nó (`- <data do dia> (humano): commit da T6 autorizado com o gate reprovando só por arquivo de teste apagado`).
- [ ] **5. Commit** (só com o "sim") — `git add tests/test-graphify-limpeza.sh docs/audora/memory/remover-graphify.md && git commit -m "refactor(remover-graphify/10,13): graphify-status e seu teste removidos (remoção autorizada pelo humano)"`
  (as remoções já estão no índice pelo `git rm`).

## Tarefa 7: superfície, versão 0.10.0 e gate final

- **depende-de**: [Tarefa 6]
- **requisito**: **remover-graphify/10** — QUANDO o leitor abrir skills,
  templates, hooks, manifests, `README.md`, `README.pt-BR.md` e
  `docs/fundamentos.md` O SISTEMA DEVE não apresentar o Graphify como
  recurso do framework; a palavra só aparece no que descreve a oferta de
  limpeza (/2–/8). O princípio da memória dinâmica deixa de citar índice de
  código. **remover-graphify/11** — QUANDO o plugin for reinstalado O
  SISTEMA DEVE declarar a versão `0.10.0` em `plugin.json` e
  `marketplace.json`. **remover-graphify/13** (gate final).
- **decisões relevantes**: bump 0.10.0 (IA, scope); sem seção de renomeação
  nem "versão anterior" (decisão viva 2026-09-27); PRD fora (sync da validate).
- **arquivos**: Modificar `hooks/session-start`, `.claude-plugin/plugin.json`,
  `.claude-plugin/marketplace.json`, `README.md`, `README.pt-BR.md`,
  `docs/fundamentos.md`, `tests/test-docs.sh`, `tests/test-session-start.sh`.
- **done quando**: `grep -rniE 'graphify|consultar-codigo' skills templates hooks .claude-plugin README.md README.pt-BR.md docs/fundamentos.md`
  só acha: descrição e passo 5 do carregar-contexto e "Raiz do plugin" em
  `skills/memory/SKILL.md`, `hooks/graphify-limpeza`, e as frases da
  limpeza nos READMEs; gate final `0`.

- [ ] **1. Teste red** — `tests/test-docs.sh`: `'"version": "0.9.0"'` →
  `'"version": "0.10.0"'` (rótulo `remover-graphify/11 $j versão 0.10.0`);
  linha do keyword → `assert_not_contains "$(tr 'A-Z' 'a-z' < .claude-plugin/plugin.json; tr 'A-Z' 'a-z' < .claude-plugin/marketplace.json)" 'graphify' "remover-graphify/10 manifests sem Graphify"`;
  tirar `'graphify-out/' 'uv tool install graphifyy'` do laço dos READMEs;
  tirar `'graphify-status' 'Graphify'` do laço do PRD; acrescentar após o
  laço dos READMEs:
  ```bash
  # remover-graphify/10 — READMEs: Graphify só na oferta de limpeza; princípio 1 sem índice de código
  assert_contains "$en" 'Graphify leftovers' "remover-graphify/10 README EN descreve a limpeza"
  assert_contains "$pt" 'restos do Graphify' "remover-graphify/10 README PT descreve a limpeza"
  for s in 'uv tool install graphifyy' 'consultar-codigo' 'graphify query' 'graphify update' 'indexes the code' 'code index' 'code graph'; do
    assert_not_contains "$en" "$s" "remover-graphify/10 README EN sem '$s'"
  done
  for s in 'uv tool install graphifyy' 'consultar-codigo' 'graphify query' 'graphify update' 'indexa o código' 'índice de código' 'índice do código'; do
    assert_not_contains "$pt" "$s" "remover-graphify/10 README PT sem '$s'"
  done
  assert_not_contains "$(tr 'A-Z' 'a-z' < docs/fundamentos.md)" 'graphify' "remover-graphify/10 fundamentos sem Graphify"
  ```
  `tests/test-session-start.sh`, antes do `report`:
  ```bash
  assert_not_contains "$o" 'Graphify' "remover-graphify/10 session-start sem Graphify"
  assert_empty "$(cd "$ROOT" && grep -li graphify hooks/* | grep -v '^hooks/graphify-limpeza$')" "remover-graphify/10 hooks sem Graphify fora da limpeza"
  ```
- [ ] **2. Rodar** `bash tests/test-docs.sh; bash tests/test-session-start.sh`
  → FAIL em versão, manifests, READMEs, fundamentos, session-start.
- [ ] **3. Implementar**:
  - session-start: `MEMORY.md (skill memory; Graphify indexa o código).` → `MEMORY.md (skill memory).`
  - manifests: `"version": "0.10.0"`; descrição `MEMORY vivo + Graphify,` → `MEMORY vivo,`; keywords sem `"graphify"`.
  - fundamentos: P1 — apagar `O código em si não vive nele: é indexado pelo Graphify (índice local, só código) e consultado sob demanda.`;
    regra 3 — `\`como-rodar\`, estado do Graphify, gate` → `\`como-rodar\`, gate`;
    P2 regra 1 — `(1) localizar candidatos a partir do escopo — consulta ao índice do Graphify quando ativo, senão grep/glob; (2)` → `(1) localizar candidatos a partir do escopo; (2)`;
    Mapa — apagar a linha `| Índice de código consultado antes de ler arquivo (Graphify) | ... |`.
  - README EN / PT (mesmas mudanças nos dois; blocos de código intocados):
    princípio 1 — EN `(requirements, decisions, learnings); Graphify indexes the code underneath. A requirement` → `(requirements, decisions, learnings). A requirement`;
    PT `aprendizados); o Graphify indexa o código por baixo. Requisito` → `aprendizados). Requisito`;
    pré-requisitos — apagar o bullet "Optional but recommended: [Graphify]…" / "Opcional, mas recomendado: [Graphify]…" (4 linhas);
    tabela, linha `memory` — `and drives Graphify: install offer, code graph, \`consultar-codigo\` for plan/debug/execute.` → `and offers to clean up Graphify leftovers found in the project.`;
    PT `e comanda o Graphify: oferta de instalação, índice do código, \`consultar-codigo\` para plan/debug/execute.` → `e oferece limpar restos do Graphify encontrados no projeto.`;
    seção `memory` — "When it fires": tirar `, look up code` / `, consultar código`;
    "What it does": `Seven operations` / `Sete operações` → `Six` / `Seis`, lista sem `` `consultar-codigo` ``; trocar do "The bootstrap offers to install Graphify…" até "…degrades to grep with a warning." (PT: do "O bootstrap oferece instalar o Graphify…" até "…degrada para grep com aviso.") por
    EN `The bootstrap offers to generate the mechanical gate — once; a refusal sticks. When loading context finds Graphify leftovers in the project, it lists only what it found (including the \`graphifyy\` package, if installed) and asks once to remove everything; it never commits, and a refusal is not recorded — the offer comes back next time.`
    PT `O bootstrap oferece gerar o gate mecânico — uma vez; recusa fica registrada. Quando a carga de contexto acha restos do Graphify no projeto, lista só o que achou (inclusive o pacote \`graphifyy\`, se instalado) e pergunta uma vez se remove tudo; nunca commita, e a recusa não é gravada — a oferta volta na próxima vez.`;
    "What it leaves on disk" — tirar `` `graphify-out/` (gitignored) `` / `` `graphify-out/` (no gitignore) `` (ajustar a vírgula/"and");
    "Human gates" — `installing Graphify and generating the gate are your call` → `generating the gate and removing Graphify leftovers are your call`; PT `instalar o Graphify e gerar o gate são decisão sua` → `gerar o gate e remover restos do Graphify são decisão sua`;
    `plan` — `locate (Graphify query when active, otherwise grep) and then read` → `locate and then read`; PT `localizar (consulta ao Graphify quando ativo, senão grep) e depois ler` → `localizar e depois ler`;
    `execute` — `Per task: locate neighbors through the code index; RED` → `Per task: RED`; PT `Por tarefa: localiza vizinhos pelo índice de código; RED` → `Por tarefa: RED`;
    `debug` — `failing path through the code index, recent diff` → `the failing path, recent diff`; PT `caminho que falha pelo índice de código, diff recente` → `caminho que falha, diff recente`;
    fluxo, passo 4 — EN `` `plan` reads the current code the demand touches and generates `docs/audora/planos/plano-<id>.md`. ``; PT `` `plan` lê o código atual que a demanda toca e gera `docs/audora/planos/plano-<id>.md`. ``;
    artefatos — apagar o bullet `graphify-out/` (2 linhas).
- [ ] **4. Rodar** suíte `> "$SCRATCH/suite.log" 2>&1; echo $?` → `0`;
  total de asserts SOMADO da saída (`grep PASS= "$SCRATCH/suite.log"`), não
  de cabeça; o grep do done.
- [ ] **5. Commit** — `git add hooks/session-start .claude-plugin/plugin.json .claude-plugin/marketplace.json README.md README.pt-BR.md docs/fundamentos.md tests/test-docs.sh tests/test-session-start.sh && git commit -m "docs(remover-graphify/10,11): superfície sem Graphify; versão 0.10.0"`.
- [ ] **6. Gate final (/13)** — árvore limpa:
  `bash hooks/gate remover-graphify > "$SCRATCH/gate-final.log" 2>&1; echo $?`
  → `0`, `GATE: passou`. Registrar no plano (Notas) o total de asserts e o
  exit.

---

## Rodada de correção pós-reprovação (A1–A5 + menores)

> Portão final reprovou /4, /5 e /10 (achados em `## feedback-reprovacao` do
> nó). Correção aprovada pelo humano com as correções sugeridas — dispensa
> novo portão de plano. Cada tarefa começa pelo teste que reproduz o furo.
> SEGURANÇA: `hooks/graphify-limpeza` só roda com `uv`/`pipx` FALSOS e com o
> PATH sem o diretório do uv/pipx reais (incidente 2026-09-29); `--remover`
> só em fixture `mktemp -d`. A T8 blinda isso ANTES de qualquer outra rodada.

## Tarefa 8: fixture sem uv/pipx reais no PATH

- **depende-de**: []
- **requisito**: **remover-graphify/13** (suíte cobre /2–/8 sem efeito fora
  do repo) — aprendizado 2026-09-29: o `lim` usa `PATH="$B:$PATH"`, que
  mantém alcançável o uv real (`AppData/Local/hermes/bin`,
  `Python314/Scripts`); `test-dogfood.sh` roda o script com o PATH real.
- **arquivos**: `tests/lib.sh` (helper `path_sem_uv`),
  `tests/test-graphify-limpeza.sh`, `tests/test-dogfood.sh`.
- **teste que reproduz**: guarda no topo das duas fixtures — nenhum diretório
  do PATH da fixture (fora `$B`) tem `uv`/`uv.exe`/`pipx`/`pipx.exe`, e
  `command -v uv` dentro da fixture é `$B/uv`; guarda falha → `ko` e `exit 1`
  ANTES de rodar o script. RED: com o PATH atual a guarda falha.
- **GREEN**: `path_sem_uv` (PATH sem dir que tenha uv/pipx) na `lib.sh`;
  `FIXPATH="$B:$(path_sem_uv)"` no `lim`; dogfood roda com `PATH="$(path_sem_uv)"`.
- [x] RED  - [x] GREEN (arquivo + gate)  - [x] commit `test(remover-graphify/13): ...`

## Tarefa 9: A1 — settings filtra por `hooks[].command` `^graphify\b`

- **depende-de**: [Tarefa 8]
- **requisito**: **remover-graphify/5** (preservar o resto; JSON válido) e
  **/2** (listar só o que é do Graphify).
- **teste que reproduz**: settings.json com grupo `Bash` contendo
  `graphify hook-guard search` + `meu-guard`; settings.local.json só com
  `rm -rf old-graphify-backup`; `.gitignore` com `graphify-out/`. Detecção =
  exatamente `gitignore .gitignore` + `settings .claude/settings.json`;
  `--remover` → `meu-guard` e matcher `Bash` ficam, `graphify` sai;
  settings.local.json byte a byte igual (não reescrito).
- **GREEN**: `json_graphify` filtra dentro de cada grupo as entradas de
  `hooks[]` com `command =~ /^\s*graphify\b/`; grupo só sai se ficou vazio;
  evento só sai se ficou vazio.
- [x] RED  - [x] GREEN  - [x] commit `fix(remover-graphify/5): ...`

## Tarefa 10: A2 — seção do CLAUDE.md termina no próximo H1 ou H2

- **depende-de**: [Tarefa 9]
- **requisito**: **remover-graphify/5**.
- **teste que reproduz**: CLAUDE.md `# Projeto`, `## graphify`, `x`,
  `# Anexo`, `y` → depois do `--remover`, exatamente `# Projeto`, `# Anexo`, `y`.
- **GREEN**: fim da seção em `^#{1,2} ` (`/^##? /`).
- [x] RED  - [x] GREEN  - [x] commit `fix(remover-graphify/5): ...`

## Tarefa 11: A3 — hook com start sem end falha e fica intocado

- **depende-de**: [Tarefa 10]
- **requisito**: **remover-graphify/5** e **/6** (falha → comando à mão).
- **teste que reproduz**: post-commit `#!/bin/sh`, `# graphify-hook-start`,
  `python rebuild`, `echo meu-hook-depois` → `--remover` sai 1,
  `falhou git-hook .git/hooks/post-commit — à mão:`, arquivo idêntico.
- **GREEN**: o filtro do hook sai ≠ 0 quando termina dentro do bloco → `ok=0`.
- [x] RED  - [x] GREEN  - [x] commit `fix(remover-graphify/5,6): ...`

## Tarefa 12: A4 — arquivo versionado removido sai como `versionado`

- **depende-de**: [Tarefa 11]
- **requisito**: **remover-graphify/4**.
- **teste que reproduz**: `mkproj` (graphify-out/graph.json commitado) +
  `core.hooksPath .githooks` com `post-checkout` só do Graphify e
  `post-commit` misto, ambos commitados → `--remover` relata
  `versionado graphify-out/graph.json`, `versionado .githooks/post-checkout`
  e `versionado .githooks/post-commit`.
- **GREEN**: caminhos que o script mexeu com sucesso (arquivo reescrito,
  hook apagado, pasta apagada) → `git diff --name-only --relative -- <caminhos>`
  → `versionado <arquivo>`.
- [x] RED  - [x] GREEN  - [x] commit `fix(remover-graphify/4): ...`

## Tarefa 13: A5 — worktree sem "Índice de código"

- **depende-de**: [Tarefa 12]
- **requisito**: **remover-graphify/10**.
- **teste que reproduz**: no laço do /9 em `tests/test-skills.sh`,
  `grep -qiE '(í|Í|i)ndice de c(ó|o)digo'` em cada uma das 8 skills → `ko`
  (forma com alternação: `[íi]` em bracket não casa `Í` por byte). RED:
  `worktree` item 4.
- **GREEN**: apagar o item 4 (2 linhas) de `skills/worktree/SKILL.md`.
- [x] RED  - [x] GREEN  - [x] commit `docs(remover-graphify/10): ...`

## Tarefa 14: menores baratos

- **depende-de**: [Tarefa 13]
- **requisito**: **remover-graphify/5** (preservar o resto), **/2** (só a
  Constituição), contrato do cabeçalho do script.
- **testes que reproduzem**:
  - CRLF sem newline final em MEMORY.md, `.gitignore`, CLAUDE.md, hook e
    settings.json → depois do `--remover`, conteúdo exato com `\r\n` e sem
    newline final (awk/grep do Git Bash comem o `\r`).
  - settings com `1.50`, `10000000000000000000000`, `1e3` → ficam literais
    (JSON::PP escreve `1.5`, `"1000…"` string, `1000`).
  - `- **graphify**:` em `## Notas` (fora da Constituição) → não é resto; no
    `--remover` com os dois, o de `## Notas` fica.
  - dir inexistente → exit 2 e `diretório inexistente` no stderr (hoje: `cd`
    falha com exit 1, contra "Exit 0 sempre" do cabeçalho); cabeçalho documenta.
- **GREEN**: filtros de texto em `perl -ne` (preserva `\r`); `grava` tira o
  `\r?\n` final quando o original não terminava em newline; números do JSON
  viram marcador `"\u0001N<literal>"` antes do decode e voltam depois do
  encode; saída do JSON em CRLF se o original era CRLF; bullet casado só entre
  `^## Constitui` e o próximo `^## `.
- [x] RED  - [x] GREEN  - [x] commit `fix(remover-graphify/2,5): ...`

## Tarefa 15: gate final da rodada

- **depende-de**: [Tarefa 14]
- [x] Árvore limpa; `bash hooks/gate remover-graphify > "$SCRATCH/gate-final.log" 2>&1; echo $?`
  → `0`, `GATE: passou`; total de asserts SOMADO da saída; registrar nas Notas.
