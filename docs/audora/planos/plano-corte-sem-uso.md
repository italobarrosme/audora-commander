# Plano — corte-sem-uso: Corte do sem uso

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** limpar os restos do Graphify dos projetos locais e então tirar
do plugin o que não tem uso medido — `hooks/graphify-limpeza`, autopilot,
motor de loop e a skill `worktree` — fechando em 8 skills, versão `0.11.0`.

**Nó do MEMORY:** `corte-sem-uso` (spec `docs/audora/specs/corte-sem-uso-escopo.md`)

**Arquitetura da mudança:** quase tudo é remoção. A limpeza dos projetos
(T1) roda UMA vez por um script de sessão no scratchpad (não versionado —
a Constituição só aceita executável em `hooks/` e `tests/`), que chama o
`hooks/graphify-limpeza` deste repo com PATH sem `uv`/`pipx` e grava o
relatório. Só depois o script sai (T2). A ausência do que sai é guardada por
UM arquivo novo, `tests/test-corte-sem-uso.sh`, que cada tarefa estende com
a sua seção (/5, /6–/8, /9, /10); os testes antigos que exigiam a presença
viram guarda de ausência ou saem junto. Os 4 arquivos de teste apagados
estão autorizados no escopo (decisão 2026-09-30 do nó).

**Arquivos lidos antes de planejar:**
- `PRD.md` (só leitura — atualizado no sync da validate, não nesta branch;
  diz "9 skills" e descreve autopilot/loop/limpeza).
- `MEMORY.md` — Constituição (`stack` e `restricoes` citam
  `graphify-limpeza`; bullet `loop:`), aprendizados 2026-08-31 (exit do
  tail), 2026-09-05 (suíte >120s), 2026-09-27 (gate sem válvula p/ teste
  apagado), 2026-09-29 (uv/pipx falsos; CRLF com perl).
- `docs/audora/memory/corte-sem-uso.md`, `docs/audora/specs/corte-sem-uso-escopo.md`.
- `docs/audora/decisoes-vivas.md` — 3 entradas `skill-worktree` (22–24).
- `skills/audora-commander/SKILL.md` (57–58, seção Autopilot 73–88),
  `skills/scope/SKILL.md` (item 6 58–61, item 7 65–69, red flag 103),
  `skills/plan/SKILL.md` (62), `skills/execute/SKILL.md` (seções "Volta de
  loop" 61–67 e "Autopilot MEDIUM (motor)" 69–71), `skills/e2e/SKILL.md`
  (19–21), `skills/validate/SKILL.md` (item 1 40–45, item 3 62–67, seção
  "Autopilot no portão" 96–102, Produzido 122–127),
  `skills/validate/references/fechamento-light.md` (16–19),
  `skills/memory/SKILL.md` (description, "Raiz do plugin" 28–30,
  carregar-contexto item 5 89–96), `skills/memory/references/bootstrap.md`
  (usa `templates/gate-template.md`), `skills/worktree/SKILL.md` (sai inteira).
- `templates/bloco-fechamento-template.md` (5, 51), `templates/fase-subagente-template.md`
  (inteiro), `templates/no-template.md` (20–23, 67), `templates/MEMORY-template.md`
  (sem `loop:` nem graphify), `templates/plano-template.md`, `templates/loop-prompt-template.md` (sai).
- `hooks/session-start` (cita worktree), `hooks/gate` (anti-fraude 1 sem
  válvula; `gate-asserts:` só p/ queda de asserts; compara com HEAD),
  `hooks/graphify-limpeza` (uso, saída `removido|falhou|versionado`,
  pacote só com `uv`/`pipx` no PATH), `hooks/loop` (sai), `hooks/hooks.json`,
  `hooks/run-hook.cmd`, `.gitattributes`, `install.sh`, `install.cmd` (nenhum cita o que sai).
- `.claude-plugin/plugin.json` (0.10.0, keyword `worktree`), `.claude-plugin/marketplace.json` (0.10.0).
- `README.md` (28, 89, 94, 101, 119, 141–145, 151, 166–167, 171–172,
  205–207, 237–238, 251, 275–292, 342), `README.pt-BR.md` (27, 89, 94, 101,
  119, 142–145, 151, 166–167, 172, 204–206, 237, 250, 275–292, 343),
  `docs/fundamentos.md` (P3 regra 3 94–95, tabela P4 164–169, P5 regras
  9–10 227–235, bullet Worktree 277–278).
- `tests/lib.sh` (`path_sem_uv`/`guarda_sem_uv`), `tests/run.sh`,
  `tests/test-skills.sh` (2, 7, 50–54, 76, 89, 103), `tests/test-docs.sh`
  (7, 14–16, 24–28), `tests/test-dogfood.sh` (5–6, 20),
  `tests/test-session-start.sh` (12), `tests/test-templates.sh` (32),
  `tests/test-contexto-por-fase.sh` (2, 16, 34, 46–57), `tests/test-carga.sh`
  (tetos 54900/60300), cabeçalhos de `tests/test-autopilot.sh`,
  `tests/test-loop.sh` (200–214 asserem execute/validate/Constituição),
  `tests/test-worktree.sh`, `tests/test-graphify-limpeza.sh` (saem).
- Projetos locais: varredura de `C:\Users\Italo Barros\workspace` (MEMORY
  com `memory-schema: 1`, raiz de repo git) + detecção read-only
  (PATH sem `uv`/`pipx`) — ver Notas de sessão.
- `.claude/CLAUDE.md` e `.claude/skills/graphify/` de `VTURBO/SellInfoTurbo`
  (CLAUDE.md = só a seção `# graphify`, 3 linhas, LF; a skill é rastreada).

**Conflitos MEMORY vs código encontrados:** nenhum. (O `PRD.md` diz 9 skills
e descreve o que sai — é o esperado: segue a `main` e muda no sync.)

## Notas de sessão

- 2026-09-30 (plan): suíte base verde — 14 arquivos, 935 asserts (somados
  da saída), exit 0. Carga ANTES (blobs LF de `ab68deb`): skills 74760 B,
  templates 26128 B; `test-carga` BASE 51800 / FULL 57040.
- 2026-09-30 (plan): detecção read-only — 15 projetos (raiz de repo) com
  `memory-schema: 1`; 13 com resto: capibaracash, kn8, trip-trip-trip,
  vibra-reseller-panel, SellInfoTurbo (+ settings.json + CLAUDE.md),
  legal-verify, promolinked, vturbo-bipa, boardboard, pepity (os 5 itens:
  constituicao, 2 git-hook, pasta, gitignore), esfera-3d (sem git-hook),
  esfera-bench C-r1 e D-r1 (só constituicao + gitignore). Limpos:
  audora-commander, catch-promotion. Com `git status` já sujo antes:
  vibra (1), SellInfoTurbo (1), legal-verify (1), vturbo-bipa (5), C-r1 (1),
  D-r1 (3). `graphify-out/` somam ~330 MB.
- `$SCRATCH` = scratchpad da sessão de execução (sem um, `SCRATCH="$(mktemp -d)"`).
- Suíte e gate passam de 120s → `run_in_background` e ler o arquivo de
  saída; exit real por `> log 2>&1; echo $?`, nunca via `| tail`. Total de
  asserts SOMADO da saída (`grep -oE 'PASS=[0-9]+' log | awk -F= '{s+=$2} END{print s}'`).
- Commits: `git add`/`git rm` com caminhos listados, nunca `-A`.
- Gate nas tarefas que apagam teste: reprova SÓ por "arquivo de teste
  apagado" dos 4 autorizados (+ linha `GATE: asserts N → M com justificativa`).
  Qualquer outro motivo → corrigir antes do commit. Depois do commit, a
  árvore limpa faz o gate passar.
- 2026-09-30 (execute T1): limpeza autorizada e rodada — 13 projetos
  limpos, detecção seguinte vazia nos 15, HEAD de todos igual, `fora dos
  restos: nenhum`. 1º gate reprovou por falha intermitente de
  `docs-permissoes/1` (não reproduziu; aprendizado registrado); 2º gate
  exit 0, 935 asserts.

## Decisões tomadas pela IA

- 2026-09-30 (plan): "projeto" em /1 = diretório que é RAIZ de repo git
  (`git rev-parse --show-toplevel` = o diretório) com `MEMORY.md` iniciado
  por `memory-schema: 1`. Exclui `VTURBO/vturbo-bipa/.next/standalone`
  (cópia de build que aponta os hooks do repo pai por `../../.git`). Apresentado
  no portão do plano.
- 2026-09-30 (plan): limpeza com PATH sem `uv`/`pipx` — o pacote
  `graphifyy` nem é detectado (spec: desinstalar da máquina fora de escopo;
  aprendizado 2026-09-29). O script aborta se `uv`/`pipx` ficar alcançável.
- 2026-09-30 (plan): antes de remover, backup em `$SCRATCH/backup/<projeto>/`
  dos hooks de git e dos arquivos que o script pode alterar (rollback de
  hook não versionado e de arquivo já sujo); `graphify-out/` sem backup —
  é saída derivada de uma ferramenta que sai (~330 MB).
- 2026-09-30 (plan): execução da limpeza tem PARADA pontual (P5 regra 7,
  efeito irreversível fora do repo): comando exato + rollback apresentados,
  humano autoriza aquele comando. Não é portão de fase.
- 2026-09-30 (plan): `.claude/CLAUDE.md` do SellInfoTurbo tem SÓ a seção do
  Graphify → o arquivo fica vazio, não é apagado (mesma regra do script:
  arquivo que fica vazio permanece). `.claude/skills/` vazia após o `rm` sai.
- 2026-09-30 (plan): READMEs e `docs/fundamentos.md` também perdem autopilot,
  motor e worktree (a spec cita skills/templates em /6 e /9, mas doc que
  descreve o que não existe é doc errada); a menção genérica "disposable
  worktree" do `bypassPermissions` fica (é git, não a skill; docs-permissoes/3).
- 2026-09-30 (plan): `{{TAREFA}}` sai do template de subagente — só o
  fallback do motor o usava.
- 2026-09-30 (plan): `path_sem_uv`/`guarda_sem_uv` saem de `tests/lib.sh`
  com o último teste que os usa (T2); a decisão viva 2026-09-29 (executável
  falso em teste de script com efeito fora do repo) continua valendo.
- 2026-09-30 (plan): guarda de "9 skills" nos READMEs NÃO inclui `PRD.md`
  (muda no sync); as 3 decisões vivas `skill-worktree` ficam para o filtro
  de decisões vivas do sync (proposta no roteiro da validate).
- 2026-09-30 (plan): /12 grava `## medicao` no nó (precedente:
  `otimizacao-tokens`) e os tetos do `test-carga` baixam para depois + 3%,
  pela regra do próprio arquivo.
- 2026-09-30 (execute): a linha de cabeçalho "Graphify em `graphify-out/` …
  consultado pela skill memory" (12 projetos) e aprendizados antigos que
  citam o Graphify ficam — o detector não os cobre e a spec exclui "qualquer
  outro conteúdo dos projetos"; anotado no relatório, levar ao portão.
- 2026-09-30 (execute): o plano-arquivo (não versionado ao fim do plan) entra
  no commit da T1, junto com as notas de sessão.

---

## Tarefa 1: limpar os projetos locais

- **depende-de**: []
- **requisito**:
  - **corte-sem-uso/1** — QUANDO a limpeza rodar O SISTEMA DEVE percorrer
    todo projeto sob `C:\Users\Italo Barros\workspace` com `MEMORY.md`
    iniciado por `memory-schema: 1` e, em cada um com resto do Graphify,
    remover os restos pelo `hooks/graphify-limpeza --remover`, deixando a
    detecção seguinte vazia — salvo item que falhou, relatado com o comando à mão.
  - **corte-sem-uso/2** — QUANDO um projeto for limpo O SISTEMA DEVE deixar
    as mudanças versionadas SEM commit e alterar apenas arquivos de resto do
    Graphify: o `git status` depois difere do de antes só nesses arquivos.
  - **corte-sem-uso/3** — QUANDO o projeto `VTURBO/SellInfoTurbo` for limpo
    O SISTEMA DEVE também tirar a seção do Graphify de `.claude/CLAUDE.md`
    (preservando o resto) e apagar `.claude/skills/graphify/`.
  - **corte-sem-uso/4** — QUANDO a limpeza terminar O SISTEMA DEVE registrar
    um relatório por projeto (itens removidos, arquivos versionados
    alterados, falhas) em `docs/audora/e2e/limpeza-graphify-projetos.md`.
- **decisões relevantes**: spec — mudanças nos projetos SEM commit; nada
  além dos restos; nada desinstalado da máquina; limpeza ANTES de apagar o
  script. Plano — definição de "projeto", PATH sem `uv`/`pipx`, backup,
  PARADA pontual (Decisões acima).
- **interfaces**:
  - consome: `hooks/graphify-limpeza [--remover] [dir]` (HEAD atual).
  - produz: `docs/audora/e2e/limpeza-graphify-projetos.md` (T5 e a validate citam).
- **arquivos**:
  - Criar (scratchpad, NÃO versionado): `$SCRATCH/limpeza-projetos.sh`
  - Criar: `docs/audora/e2e/limpeza-graphify-projetos.md`
  - Modificar: `docs/audora/memory/corte-sem-uso.md` (`## decisoes`: autorização)
- **done quando**: `bash "$SCRATCH/limpeza-projetos.sh" "$SCRATCH"` (modo
  detecção) sai 0 com todo projeto `(limpo)`; relatório sem linha
  `fora dos restos:` diferente de `nenhum`; commit feito.

- [ ] **1. Escrever o verificador/executor** — gravar via Write (heredoc
  grande quebra no Bash tool) `$SCRATCH/limpeza-projetos.sh`:

  ```bash
  #!/usr/bin/env bash
  # corte-sem-uso/1..4 — restos do Graphify nos projetos locais. Roda do repo do plugin, UMA vez.
  # Uso: limpeza-projetos.sh <scratch>             → só detecta; exit 1 se algum projeto tem resto
  #      limpeza-projetos.sh <scratch> --remover   → backup + remove + <scratch>/relatorio.md
  set -uo pipefail
  PLUGIN="C:/Users/Italo Barros/workspace/audora-commander"
  WS="C:/Users/Italo Barros/workspace"
  SCR="$1"; MODO="${2:-}"
  L="$PLUGIN/hooks/graphify-limpeza"
  SELL="$WS/VTURBO/SellInfoTurbo"
  RESTO_ERE='^(MEMORY\.md|\.gitignore|CLAUDE\.md|\.claude/settings(\.local)?\.json|graphify-out/.*|\.claude/CLAUDE\.md|\.claude/skills/graphify/.*)$'
  sem_uv() { local d x r="" IFS=:; for d in $PATH; do [ -n "$d" ] || continue; for x in uv uv.exe pipx pipx.exe; do [ -e "$d/$x" ] && continue 2; done; r="${r:+$r:}$d"; done; printf '%s' "$r"; }
  P="$(sem_uv)"
  [ -z "$(PATH="$P" command -v uv)$(PATH="$P" command -v pipx)" ] || { echo "ABORTADO: uv/pipx alcançável" >&2; exit 3; }
  projetos() {
    find "$WS" -maxdepth 7 \( -name node_modules -o -name .git -o -name .next -o -name worktrees -o -name .venv \) -prune -o -name MEMORY.md -print 2>/dev/null |
    while IFS= read -r f; do
      d="$(dirname "$f")"
      [ "$(head -1 "$f" | tr -d '\r')" = "memory-schema: 1" ] || continue
      [ "$(git -C "$d" rev-parse --show-toplevel 2>/dev/null)" = "$d" ] || continue
      printf '%s\n' "$d"
    done | sort
  }
  extra_sell() {   # /3 — o que o script não alcança
    grep -qi graphify "$SELL/.claude/CLAUDE.md" 2>/dev/null && echo "claude-md .claude/CLAUDE.md"
    [ -e "$SELL/.claude/skills/graphify" ] && echo "skill .claude/skills/graphify/"
    return 0
  }
  pend=0; mkdir -p "$SCR/backup"; [ "$MODO" = "--remover" ] && : > "$SCR/relatorio.md"
  while IFS= read -r d; do
    n="${d#"$WS"/}"; k="$(printf '%s' "$n" | tr '/ ' '__')"
    det="$(PATH="$P" bash "$L" "$d")"
    [ "$d" = "$SELL" ] && det="$(printf '%s\n%s\n' "$det" "$(extra_sell)" | sed '/^$/d')"
    if [ "$MODO" != "--remover" ]; then
      printf '## %s\n%s\n\n' "$n" "${det:-(limpo)}"; [ -n "$det" ] && pend=$((pend+1)); continue
    fi
    git -C "$d" status --porcelain=v1 -uall > "$SCR/$k.antes"
    h="$(git -C "$d" rev-parse --git-path hooks)"
    for f in "$h/post-commit" "$h/post-checkout" MEMORY.md .gitignore CLAUDE.md .claude/settings.json .claude/settings.local.json .claude/CLAUDE.md .claude/skills/graphify; do
      [ -e "$d/$f" ] && { mkdir -p "$SCR/backup/$k/$(dirname "$f")"; cp -rp "$d/$f" "$SCR/backup/$k/$f"; }
    done
    saida="$(PATH="$P" bash "$L" --remover "$d")"
    if [ "$d" = "$SELL" ]; then
      if grep -qi graphify "$d/.claude/CLAUDE.md" 2>/dev/null; then
        perl -i -ne 'if (/^#{1,2} graphify\s*$/i) { $s = 1; next } $s = 0 if $s && /^#{1,2} /; print unless $s' "$d/.claude/CLAUDE.md" \
          && saida="$saida"$'\n'"removido claude-md .claude/CLAUDE.md" || saida="$saida"$'\n'"falhou claude-md .claude/CLAUDE.md — à mão: apague a seção graphify de .claude/CLAUDE.md"
      fi
      if [ -e "$d/.claude/skills/graphify" ]; then
        rm -rf "$d/.claude/skills/graphify" && saida="$saida"$'\n'"removido skill .claude/skills/graphify/" || saida="$saida"$'\n'"falhou skill .claude/skills/graphify/ — à mão: rm -rf .claude/skills/graphify"
        rmdir "$d/.claude/skills" 2>/dev/null
      fi
    fi
    git -C "$d" status --porcelain=v1 -uall > "$SCR/$k.depois"
    mudou="$(diff "$SCR/$k.antes" "$SCR/$k.depois" | sed -n 's/^[<>] ...//p' | sort -u)"
    fora="$(printf '%s\n' "$mudou" | sed '/^$/d' | grep -vE "$RESTO_ERE")"
    depois="$(PATH="$P" bash "$L" "$d")"; [ "$d" = "$SELL" ] && depois="$depois$(extra_sell)"
    {
      printf '## %s\n\n' "$n"
      printf -- '- detectado: %s\n' "$(printf '%s' "${det:-nada}" | tr '\n' ';')"
      printf '%s\n' "$saida" | sed '/^$/d; s/^/- /'
      printf -- '- git status alterado: %s\n' "$(printf '%s' "${mudou:-nenhum}" | tr '\n' ' ')"
      printf -- '- fora dos restos: %s\n' "${fora:-nenhum}"
      printf -- '- detecção depois: %s\n\n' "${depois:-vazia}"
    } >> "$SCR/relatorio.md"
    [ -n "$fora$depois" ] && pend=$((pend+1))
  done < <(projetos)
  echo "projetos com pendência: $pend"
  [ "$pend" -eq 0 ]
  ```
- [ ] **2. Red** — `bash "$SCRATCH/limpeza-projetos.sh" "$SCRATCH" > "$SCRATCH/det-antes.txt" 2>&1; echo $?`
  → `1`; ler o arquivo inteiro: 15 blocos `## …`, `projetos com pendência: 13`,
  SellInfoTurbo listando também `claude-md .claude/CLAUDE.md` e
  `skill .claude/skills/graphify/`; nenhum `.next/standalone`. Divergiu das
  Notas de sessão → parar e reportar antes de seguir.
- [ ] **3. PARADA pontual (P5 regra 7)** — apresentar ao humano: a lista do
  passo 2, o comando exato `bash "$SCRATCH/limpeza-projetos.sh" "$SCRATCH" --remover`,
  e o rollback (`cp -rp "$SCRATCH/backup/<projeto>/." "<projeto>/"` restaura
  hooks e arquivos; `graphify-out/` sem backup). Só com o "sim": registrar em
  `## decisoes` do nó `- 2026-MM-DD (humano): autorizada a limpeza dos 13 projetos pelo comando <comando>`.
- [ ] **4. Executar** — `bash "$SCRATCH/limpeza-projetos.sh" "$SCRATCH" --remover > "$SCRATCH/remover.log" 2>&1; echo $?`
  → esperado `0` e `projetos com pendência: 0`. Exit 1: ler
  `$SCRATCH/relatorio.md`; item `falhou` fica relatado com o comando à mão
  (/1 aceita); `fora dos restos:` ≠ `nenhum` → PARAR e mostrar ao humano
  (violação de /2; rollback do backup se ele pedir).
- [ ] **5. Green** — `bash "$SCRATCH/limpeza-projetos.sh" "$SCRATCH" > "$SCRATCH/det-depois.txt" 2>&1; echo $?`
  → `0`, todo bloco `(limpo)` (salvo item `falhou` relatado). Conferir /3:
  `grep -ci graphify "C:/Users/Italo Barros/workspace/VTURBO/SellInfoTurbo/.claude/CLAUDE.md"`
  → `0`; `ls "C:/Users/Italo Barros/workspace/VTURBO/SellInfoTurbo/.claude/skills"` → não existe.
  Conferir /2 sem commit: `git -C <projeto> log -1 --format=%H` igual ao de antes (sem commit novo).
- [ ] **6. Relatório** — criar `docs/audora/e2e/limpeza-graphify-projetos.md`:
  cabeçalho `# Limpeza do Graphify nos projetos locais — corte-sem-uso/1–4`,
  1 parágrafo (data, HEAD do plugin usado, PATH sem `uv`/`pipx`, SEM commit
  nos projetos, backup em `$SCRATCH/backup`, `graphify-out/` sem backup) e,
  abaixo, o conteúdo de `$SCRATCH/relatorio.md` inteiro.
- [ ] **7. Commit** — gate antes (`bash hooks/gate corte-sem-uso > "$SCRATCH/gate.log" 2>&1; echo $?` → `0`; só docs mudaram), então
  `git add docs/audora/e2e/limpeza-graphify-projetos.md docs/audora/memory/corte-sem-uso.md && git commit -m "docs(corte-sem-uso/1-4): restos do Graphify limpos nos projetos locais (sem commit neles); relatório"`.

## Tarefa 2: `graphify-limpeza` sai

- **depende-de**: [Tarefa 1]
- **requisito**: **corte-sem-uso/5** — QUANDO o leitor abrir skills,
  templates, hooks, manifests, `README.md`, `README.pt-BR.md` e
  `docs/fundamentos.md` O SISTEMA DEVE não citar Graphify;
  `hooks/graphify-limpeza`, seu teste e a oferta de limpeza da carga de
  contexto não existem mais. **corte-sem-uso/11** (parte
  `tests/test-graphify-limpeza.sh`) — QUANDO o gate rodar ao fim da demanda
  O SISTEMA DEVE sair 0; a queda de asserts passa só com `gate-asserts:`
  justificado no nó, e a remoção de `tests/test-graphify-limpeza.sh`,
  `tests/test-loop.sh`, `tests/test-autopilot.sh` e `tests/test-worktree.sh`
  está autorizada no nó e citada no commit.
- **decisões relevantes**: decisão 2026-09-30 do nó (aprovar o escopo
  autoriza apagar os 4 testes); `path_sem_uv`/`guarda_sem_uv` saem (Decisões).
- **interfaces**:
  - produz: `tests/test-corte-sem-uso.sh` com a função
    `lista_com <ERE> <caminho>...` (arquivos que casam, case-insensitive);
    T3–T5 acrescentam seções ANTES do `report`.
- **arquivos**:
  - Criar: `tests/test-corte-sem-uso.sh`
  - Apagar: `hooks/graphify-limpeza`, `tests/test-graphify-limpeza.sh`
  - Modificar: `skills/memory/SKILL.md`, `README.md`, `README.pt-BR.md`,
    `MEMORY.md` (Constituição), `docs/audora/memory/corte-sem-uso.md`,
    `tests/lib.sh`, `tests/test-skills.sh`, `tests/test-dogfood.sh`,
    `tests/test-docs.sh`, `tests/test-session-start.sh`
- **done quando**: suíte verde; gate reprova só por `arquivo de teste
  apagado: tests/test-graphify-limpeza.sh`; commit feito.

- [ ] **1. Válvula** — em `docs/audora/memory/corte-sem-uso.md`, no fim de
  `## decisoes`, a linha (vale para a demanda inteira):
  `gate-asserts: queda aprovada no escopo (/11) — asserts de test-graphify-limpeza, test-loop, test-autopilot e test-worktree saem com o comportamento removido; ausência guardada por tests/test-corte-sem-uso.sh.`
- [ ] **2. Teste red** — criar `tests/test-corte-sem-uso.sh`:

  ```bash
  #!/usr/bin/env bash
  # corte-sem-uso/5..10 — o plugin não carrega mais Graphify, autopilot, motor de loop nem a skill worktree.
  source "$(dirname "$0")/lib.sh"
  cd "$ROOT" || exit 1
  # lista_com <ERE> <caminho>... → arquivos que casam (case-insensitive)
  lista_com() { local e="$1"; shift; grep -rliE -- "$e" "$@" 2>/dev/null; }

  # --- /5 Graphify fora da superfície; limpeza e seu teste não existem ---
  assert_empty "$(lista_com 'graphify' skills templates hooks .claude-plugin README.md README.pt-BR.md docs/fundamentos.md)" "corte-sem-uso/5 superfície sem Graphify"
  assert_no_file hooks/graphify-limpeza "corte-sem-uso/5 script de limpeza removido"
  assert_no_file tests/test-graphify-limpeza.sh "corte-sem-uso/11 teste da limpeza removido"
  cc="$(tr -d '\r' < skills/memory/SKILL.md | awk '/^### 1\. carregar-contexto/{f=1;next} /^### /{f=0} f')"
  assert_not_contains "$cc" 'Restos do' "corte-sem-uso/5 carregar-contexto sem oferta de limpeza"
  assert_contains "$cc" 'ofertar UMA vez gerar o gate' "corte-sem-uso/5 carregar-contexto mantém a oferta do gate"
  grep -qsi graphify .git/hooks/post-commit .git/hooks/post-checkout && ko "corte-sem-uso/5 hook de git do repo cita graphify" || ok
  assert_no_file graphify-out "corte-sem-uso/5 repo sem graphify-out"

  report
  ```
- [ ] **3. Rodar red** — `bash tests/test-corte-sem-uso.sh; echo $?` → `1`,
  com `FAIL: corte-sem-uso/5 superfície sem Graphify`, `... script de
  limpeza removido`, `... teste da limpeza removido`, `... sem oferta de limpeza`.
- [ ] **4. Implementar**:
  - `git rm hooks/graphify-limpeza tests/test-graphify-limpeza.sh`.
  - `skills/memory/SKILL.md`: description sem `(inclui a oferta de limpar
    restos do Graphify)`; exemplo de "Raiz do plugin" vira
    `` `<raiz do plugin>/templates/gate-template.md`. ``; apagar o item 5 de
    carregar-contexto inteiro (linhas 89–96).
  - `README.md`: tabela (94) sem `and offers to clean up Graphify leftovers
    found in the project`; seção `memory` sem a frase `When loading context
    finds Graphify leftovers … comes back next time.`; Human gates vira
    `generating the gate is your call; MEMORY merge conflicts …`.
    `README.pt-BR.md`: o mesmo (94, 142–145, 151 → `gerar o gate é decisão sua; …`).
  - `MEMORY.md` Constituição: `stack` → `bash (hooks, suíte \`tests/\`)`;
    `restricoes` → `código executável só em \`hooks/\` e \`tests/\` (suíte bash)`.
  - `tests/lib.sh`: apagar `path_sem_uv` e `guarda_sem_uv` (linhas 22–46).
  - `tests/test-dogfood.sh`: apagar linhas 5–6 (`DPATH`, `guarda_sem_uv`)
    e 20 (roda o script); cabeçalho: `# memory-graphify/9; remover-graphify/12 — este repositório usa MEMORY; restos do Graphify guardados em test-corte-sem-uso.sh.`
  - `tests/test-skills.sh`: apagar 50–54 (limpeza na carga de contexto).
  - `tests/test-docs.sh`: apagar 14–16 (READMEs descrevem a limpeza).
  - `tests/test-session-start.sh` linha 12 → `assert_empty "$(cd "$ROOT" && grep -li graphify hooks/*)" "corte-sem-uso/5 hooks sem Graphify"`.
- [ ] **5. Green** — `grep -rn 'path_sem_uv\|guarda_sem_uv\|graphify-limpeza' tests skills templates hooks` → só
  `tests/test-corte-sem-uso.sh`. Suíte em background
  (`bash tests/run.sh > "$SCRATCH/suite.log" 2>&1; echo $?`) → `0`, 14
  arquivos. Gate: `bash hooks/gate corte-sem-uso > "$SCRATCH/gate.log" 2>&1; echo $?`
  → `1` com `GATE: asserts N → M com justificativa no nó` e UM motivo:
  `arquivo de teste apagado: tests/test-graphify-limpeza.sh`.
- [ ] **6. Commit** — `git add tests/test-corte-sem-uso.sh skills/memory/SKILL.md README.md README.pt-BR.md MEMORY.md docs/audora/memory/corte-sem-uso.md tests/lib.sh tests/test-skills.sh tests/test-dogfood.sh tests/test-docs.sh tests/test-session-start.sh && git commit -m "refactor(corte-sem-uso/5,11): graphify-limpeza e seu teste removidos (remoção autorizada no escopo, decisão 2026-09-30 do nó)"`
  (as remoções já estão no índice pelo `git rm`).

## Tarefa 3: autopilot e motor de loop saem

- **depende-de**: [Tarefa 2]
- **requisito**:
  - **corte-sem-uso/6** — QUANDO o leitor abrir skills e templates O
    SISTEMA DEVE não citar autopilot, elegibilidade de autopilot, motor de
    loop nem `hooks/loop`; o template de nó não tem o campo `autopilot:` e
    todo portão do meio volta a ser sempre humano.
  - **corte-sem-uso/7** — QUANDO o repositório for listado O SISTEMA DEVE
    não ter `hooks/loop`, `templates/loop-prompt-template.md` e seus testes;
    a Constituição (template e este repo) não tem bullet `loop:`.
  - **corte-sem-uso/8** — QUANDO o humano disser "segue" numa PARADA O
    SISTEMA DEVE continuar rodando a fase seguinte em subagente de contexto
    zerado pelo `templates/fase-subagente-template.md`, que deixa de citar o motor.
  - **corte-sem-uso/11** (partes `tests/test-autopilot.sh` e `tests/test-loop.sh`).
- **decisões relevantes**: spec — autopilot e motor saem inteiros;
  `paradas humanas: N` sai junto. Plano — `{{TAREFA}}` sai; READMEs e
  fundamentos também (Decisões).
- **interfaces**: consome `lista_com` (T2).
- **arquivos**:
  - Apagar: `hooks/loop`, `templates/loop-prompt-template.md`,
    `tests/test-loop.sh`, `tests/test-autopilot.sh`
  - Modificar: `skills/audora-commander/SKILL.md`, `skills/scope/SKILL.md`,
    `skills/plan/SKILL.md`, `skills/execute/SKILL.md`, `skills/e2e/SKILL.md`,
    `skills/validate/SKILL.md`, `skills/validate/references/fechamento-light.md`,
    `templates/no-template.md`, `templates/bloco-fechamento-template.md`,
    `templates/fase-subagente-template.md`, `MEMORY.md` (Constituição),
    `README.md`, `README.pt-BR.md`, `docs/fundamentos.md`,
    `tests/test-corte-sem-uso.sh`, `tests/test-contexto-por-fase.sh`,
    `tests/test-templates.sh`
- **done quando**: suíte verde; gate reprova só pelos 2 testes apagados; commit feito.

- [ ] **1. Teste red** — em `tests/test-corte-sem-uso.sh`, antes do `report`:

  ```bash
  # --- /6 autopilot e motor fora de skills, templates e docs; portões do meio sempre humanos ---
  assert_empty "$(lista_com 'autopilot|motor|hooks/loop|loop-prompt|elegiv|elegív|antecipad|paradas humanas' skills templates)" "corte-sem-uso/6 skills e templates sem autopilot/motor"
  assert_empty "$(lista_com 'autopilot|motor de loop|hooks/loop|loop round|rodada do loop' README.md README.pt-BR.md docs/fundamentos.md)" "corte-sem-uso/6 READMEs e fundamentos sem autopilot/motor"
  sc="$(tr -d '\r' < skills/scope/SKILL.md)"
  assert_contains "$sc" 'ESPERAR aprovação explícita' "corte-sem-uso/6 portão de escopo sempre humano"
  assert_not_contains "$sc" 'Exceção' "corte-sem-uso/6 scope sem exceção ao portão"
  assert_not_contains "$(tr -d '\r' < templates/no-template.md)" 'autopilot:' "corte-sem-uso/6 template de nó sem campo autopilot:"
  # --- /7 motor de loop e seus testes não existem; Constituição sem loop: ---
  for f in hooks/loop templates/loop-prompt-template.md tests/test-loop.sh tests/test-autopilot.sh; do
    assert_no_file "$f" "corte-sem-uso/7,11 $f removido"
  done
  assert_not_contains "$(cat MEMORY.md templates/MEMORY-template.md)" '**loop**:' "corte-sem-uso/7 Constituição sem bullet loop:"
  # --- /8 "segue" continua em subagente; template sem motor ---
  fs="$(tr -d '\r' < templates/fase-subagente-template.md)"
  assert_contains "$fs" 'o humano diz "segue" na PARADA' "corte-sem-uso/8 template cobre o segue"
  assert_contains "$fs" 'contexto zerado rodando {{FASE}} de {{ID}}' "corte-sem-uso/8 subagente de contexto zerado"
  assert_not_contains "$fs" 'motor' "corte-sem-uso/8 template sem motor"
  assert_not_contains "$fs" '{{TAREFA}}' "corte-sem-uso/8 placeholder do fallback do motor fora"
  pa="$(tr -d '\r' < templates/bloco-fechamento-template.md | awk '/^## Parada entre fases/{f=1;next} /^## /{f=0} f')"
  assert_contains "$pa" 'templates/fase-subagente-template.md' "corte-sem-uso/8 segue aponta o subagente"
  ```
- [ ] **2. Rodar red** — `bash tests/test-corte-sem-uso.sh; echo $?` → `1`,
  FAIL em: skills e templates sem autopilot/motor; READMEs e fundamentos;
  scope sem exceção; template de nó; os 4 `removido`; bullet `loop:`;
  template sem motor; placeholder `{{TAREFA}}`. (Os asserts de "segue" já passam — guardam o que fica.)
- [ ] **3. Skills** —
  - `audora-commander`: parágrafo `[e2e]` (57–58) vira
    `` `[e2e]` = opcional, oferecido SEMPRE pela validate com recomendação forte. ``;
    apagar a seção `## Autopilot (declaração do humano)` (73–89, até a linha em branco antes de `## Red flags`).
  - `scope`: apagar o último bullet do item 6 (58–61) e a "Exceção —
    portão antecipado" do item 7 (65–69); red flag (103) vira
    `| "Apresento o escopo e já começo o plano" | Portão é portão. Apresente e ESPERE o sim. |`.
  - `plan`: apagar a linha 62 (`> Em autopilot, sem parada: …`).
  - `execute`: apagar as seções `## Volta de loop (motor \`hooks/loop\`)` e
    `## Autopilot MEDIUM (motor)` (61–72).
  - `e2e`: apagar a frase `Autopilot declarado vale … sem-ferramenta\`).` (19–21).
  - `validate`: apagar do item 1 o bloco `Nó em autopilot … visível no portão.`
    (40–45); do item 3 os bullets **Premissas e decisões tomadas sem portão**
    e **Relatório de rodada** (62–67); a seção `## Autopilot no portão`
    (96–103); o **Produzido** do bloco vira
    `- **Produzido**: o veredito do portão e o que o sync consolidou.` (sai o contador `paradas humanas` e as 4 linhas que o explicam).
  - `validate/references/fechamento-light.md`: o bullet da oferta termina em
    `Pedido explícito do humano roda sempre, em qualquer caso.` (sai `Em autopilot, … o pulo no nó.`).
- [ ] **4. Templates e Constituição** —
  - `no-template.md`: apagar o comentário do campo `autopilot:` (20–23) e
    `| pulado-por-autopilot-sem-ferramenta` do enum de `## e2e` (a linha 66 passa a fechar o comentário: `<!-- pendente | relatorio: ../e2e/e2e-<id>.md | pulado-pelo-humano -->`).
  - `bloco-fechamento-template.md` linha 51 →
    `Sem parada: porta de entrada → 1ª fase; LIGHT, HOTFIX; e2e ↔ validate.`
  - `fase-subagente-template.md`: header vira
    `> Usado quando o humano diz "segue" na PARADA (seção Parada entre fases de`
    `> \`templates/bloco-fechamento-template.md\`). A sessão principal preenche`
    `> \`{{FASE}}\` e \`{{ID}}\` e despacha UM subagente (ferramenta Agent) com o texto abaixo.`;
    passo 2 do prompt vira `2. Faça só {{FASE}}. Não emende outra fase.`;
    apagar a regra `` `{{TAREFA}}` vazio … `` (18).
  - `MEMORY.md`: apagar o bullet `- **loop**: …` da Constituição (2 linhas).
  - `git rm hooks/loop templates/loop-prompt-template.md tests/test-loop.sh tests/test-autopilot.sh`.
- [ ] **5. Docs** —
  - `README.md`: apagar `Accepts "autopilot" / "roda até o validate" for
    LIGHT and MEDIUM (HIGH refuses).` (119); `Under autopilot it records
    whether every criterion is automatable.` (166–167); ` (skipped only under
    eligible autopilot, ratified at the final gate)` (171–172); a frase `As a
    lap of the loop engine (\`hooks/loop\`) it does ONE task … as patches.`
    (205–207); `autopilot premises, loop round report, ` (237–238);
    ` — never anticipated,` (251 → `the final gate, in every category`).
  - `README.pt-BR.md`: os mesmos pontos (119; 166–167; 172; 204–206;
    237 `premissas do autopilot, relatório da rodada do loop, `; 250 → `o portão final, em toda categoria`).
  - `docs/fundamentos.md`: P3 regra 3 → `Sessão limpa (ou subagente) executa
    sem redescobrir contexto.`; tabela do P4 sem a coluna `Autopilot`
    (4 colunas: Categoria | Fases | Portões humanos); apagar P5 regras 9 e 10 (227–235).
  - `tests/test-contexto-por-fase.sh`: cabeçalho → `# contexto-por-fase — parada entre fases, retomada, "segue" em subagente.`;
    linha 16 → `assert_not_contains "$pa" 'autopilot' "corte-sem-uso/6 parada sem exceção de autopilot"`;
    apagar a 34 (`uma tarefa por subagente`), 51–54 (`ap=` e seus 3 asserts),
    56–57 (contrato com `hooks/loop`); comentário 46 → `# --- /1 /3 /9 — execute: parada, LIGHT emenda ---`.
  - `tests/test-templates.sh` linha 32 → `assert_not_contains "$b2" 'autopilot' "corte-sem-uso/6 parada sem autopilot"`.
- [ ] **6. Green** — `bash tests/test-corte-sem-uso.sh; echo $?` → `0`.
  `grep -rniE 'autopilot|hooks/loop|motor' skills templates` → vazio.
  `grep -n 'pulado-por-autopilot' skills templates -r` → vazio. Suíte
  (background) → `0`, 12 arquivos; `test-carga` abaixo dos tetos. Gate →
  `1` com a linha de justificativa e SÓ 2 motivos: `arquivo de teste
  apagado: tests/test-autopilot.sh` e `… tests/test-loop.sh`.
- [ ] **7. Commit** — `git add skills/audora-commander/SKILL.md skills/scope/SKILL.md skills/plan/SKILL.md skills/execute/SKILL.md skills/e2e/SKILL.md skills/validate/SKILL.md skills/validate/references/fechamento-light.md templates/no-template.md templates/bloco-fechamento-template.md templates/fase-subagente-template.md MEMORY.md README.md README.pt-BR.md docs/fundamentos.md tests/test-corte-sem-uso.sh tests/test-contexto-por-fase.sh tests/test-templates.sh && git commit -m "refactor(corte-sem-uso/6,7,8,11): autopilot e motor de loop removidos; portões do meio sempre humanos (remoção de test-autopilot e test-loop autorizada no escopo, decisão 2026-09-30 do nó)"`.

## Tarefa 4: skill `worktree` sai

- **depende-de**: [Tarefa 3]
- **requisito**: **corte-sem-uso/9** — QUANDO o plugin for instalado O
  SISTEMA DEVE ter 8 skills (sem `worktree`), com contagem coerente em
  testes, READMEs, manifests e `hooks/session-start`; nenhuma skill cita a
  skill `worktree`. **corte-sem-uso/11** (parte `tests/test-worktree.sh`).
- **decisões relevantes**: spec — sai inteira. Plano — "disposable
  worktree" do `bypassPermissions` fica; PRD e decisões vivas no sync.
- **interfaces**: consome `lista_com` (T2).
- **arquivos**:
  - Apagar: `skills/worktree/SKILL.md`, `tests/test-worktree.sh`
  - Modificar: `hooks/session-start`, `templates/bloco-fechamento-template.md`,
    `.claude-plugin/plugin.json`, `README.md`, `README.pt-BR.md`,
    `docs/fundamentos.md`, `tests/test-corte-sem-uso.sh`, `tests/test-skills.sh`,
    `tests/test-docs.sh`, `tests/test-session-start.sh`
- **done quando**: `ls -d skills/*/ | wc -l` = 8; suíte verde; gate reprova
  só por `tests/test-worktree.sh`; commit feito.

- [ ] **1. Teste red** — em `tests/test-corte-sem-uso.sh`, antes do `report`:

  ```bash
  # --- /9 8 skills, nenhuma superfície cita a skill worktree ---
  assert_eq "8" "$(ls -d skills/*/ | wc -l | tr -d ' ')" "corte-sem-uso/9 8 skills"
  assert_no_file skills/worktree/SKILL.md "corte-sem-uso/9 skill worktree removida"
  assert_no_file tests/test-worktree.sh "corte-sem-uso/11 teste da worktree removido"
  assert_empty "$(lista_com 'worktree' skills templates hooks .claude-plugin docs/fundamentos.md)" "corte-sem-uso/9 skills, templates, hooks, manifests e fundamentos sem worktree"
  for r in README.md README.pt-BR.md; do
    assert_not_contains "$(tr -d '\r' < "$r")" '| `worktree` |' "corte-sem-uso/9 $r sem a skill worktree na tabela"
    assert_not_contains "$(tr -d '\r' < "$r")" '### `worktree`' "corte-sem-uso/9 $r sem seção worktree"
    assert_empty "$(grep -nE '(^|[^0-9])9 (chained )?skills' "$r")" "corte-sem-uso/9 $r sem '9 skills'"
  done
  assert_contains "$(tr -d '\r' < README.md)" '## The 8 skills' "corte-sem-uso/9 README EN diz 8 skills"
  assert_contains "$(tr -d '\r' < README.pt-BR.md)" '## As 8 skills' "corte-sem-uso/9 README PT diz 8 skills"
  ```
- [ ] **2. Rodar red** — `bash tests/test-corte-sem-uso.sh; echo $?` → `1`,
  FAIL em: 8 skills (obtido 9); skill removida; teste removido; sem
  worktree (skills/worktree, bloco-fechamento, session-start, plugin.json,
  fundamentos); tabela, seção e `9 skills` nos 2 READMEs; `The 8`/`As 8`.
- [ ] **3. Implementar** —
  - `git rm -r skills/worktree tests/test-worktree.sh`.
  - `hooks/session-start`: tirar `; isolamento em git worktree, só a pedido explícito: worktree` (a frase fica `…; bug ou comportamento inesperado: debug. Instrução direta …`).
  - `bloco-fechamento-template.md` linha 5: `` Skill-ferramenta (`memory`) NÃO imprime bloco próprio: ``.
  - `plugin.json` keywords: `["workflow", "tdd", "planning", "best-practices", "memory"]`.
  - `README.md`: `adds 8 chained skills` (28); `## The 8 skills` (89);
    apagar a linha `| \`worktree\` | …` (101) e a seção `### \`worktree\``
    inteira (275–293, até antes de `## Usage flow`); checklist `list the 8 skills` (342).
    `README.pt-BR.md`: o mesmo (27 `adiciona 8 skills`, 89, 101, 275–293, 343 `listar as 8 skills`).
  - `docs/fundamentos.md`: apagar o bullet **Worktree sob pedido** (277–278).
  - `tests/test-skills.sh`: cabeçalho `# Estrutura das 8 skills + …`;
    linhas 7 e 76 sem `worktree` no `for`; linha 89 →
    `assert_eq "8" "$(ls -d skills/*/ | wc -l | tr -d ' ')" "corte-sem-uso/9 8 skills"`;
    linha 103 → `for s in memory; do`.
  - `tests/test-docs.sh`: apagar 24–28 (worktree listada, 9 skills, "zero 8 skills").
  - `tests/test-session-start.sh`: antes do `report`,
    `assert_not_contains "$o" 'worktree' "corte-sem-uso/9 session-start sem worktree"`.
- [ ] **4. Green** — `bash tests/test-corte-sem-uso.sh; echo $?` → `0`;
  `bash hooks/session-start | perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)'; echo $?` → `0`;
  suíte (background) → `0`, 11 arquivos (`test-docs` confere as subseções
  das 8 skills nos READMEs). Gate → `1` com a linha de justificativa e SÓ
  `arquivo de teste apagado: tests/test-worktree.sh`.
- [ ] **5. Commit** — `git add hooks/session-start templates/bloco-fechamento-template.md .claude-plugin/plugin.json README.md README.pt-BR.md docs/fundamentos.md tests/test-corte-sem-uso.sh tests/test-skills.sh tests/test-docs.sh tests/test-session-start.sh && git commit -m "refactor(corte-sem-uso/9,11): skill worktree removida, 8 skills (remoção de test-worktree autorizada no escopo, decisão 2026-09-30 do nó)"`.

## Tarefa 5: versão 0.11.0, carga medida e gate final

- **depende-de**: [Tarefa 4]
- **requisito**:
  - **corte-sem-uso/10** — QUANDO o plugin for reinstalado O SISTEMA DEVE
    declarar a versão `0.11.0` em `plugin.json` e `marketplace.json`.
  - **corte-sem-uso/11** — QUANDO o gate rodar ao fim da demanda O SISTEMA
    DEVE sair 0; a queda de asserts passa só com `gate-asserts:` justificado
    no nó, e a remoção de `tests/test-graphify-limpeza.sh`,
    `tests/test-loop.sh`, `tests/test-autopilot.sh` e `tests/test-worktree.sh`
    está autorizada no nó e citada no commit.
  - **corte-sem-uso/12** — QUANDO a demanda fechar O SISTEMA DEVE registrar
    no nó a carga estática medida antes e depois (bytes das skills e
    templates e a BASE do `test-carga`), como dado para a demanda seguinte.
- **decisões relevantes**: spec — bump `0.11.0` (breaking, minor pré-1.0).
  Plano — `## medicao` no nó; tetos do `test-carga` = depois + 3%
  arredondado para cima em centenas.
- **interfaces**: consome as notas de sessão (carga ANTES).
- **arquivos**:
  - Modificar: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`,
    `tests/test-docs.sh`, `tests/test-corte-sem-uso.sh`, `tests/test-carga.sh`,
    `docs/audora/memory/corte-sem-uso.md`
- **done quando**: gate em árvore limpa sai `0`; `## medicao` no nó com
  antes → depois; commit feito.

- [ ] **1. Teste red** — `tests/test-docs.sh` linha 7 →
  `assert_contains "$(cat "$j")" '"version": "0.11.0"' "corte-sem-uso/10 $j versão 0.11.0"`;
  em `tests/test-corte-sem-uso.sh`, antes do `report`:

  ```bash
  # --- /10 versão 0.11.0 nos dois manifests ---
  for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
    assert_contains "$(tr -d '\r' < "$j")" '"version": "0.11.0"' "corte-sem-uso/10 $j declara 0.11.0"
    assert_not_contains "$(tr -d '\r' < "$j")" '"version": "0.10.0"' "corte-sem-uso/10 $j sem 0.10.0"
  done
  ```
- [ ] **2. Rodar red** — `bash tests/test-docs.sh; echo $?` → `1`
  (`corte-sem-uso/10 … versão 0.11.0`); `bash tests/test-corte-sem-uso.sh; echo $?` → `1` (4 FAIL do /10).
- [ ] **3. Implementar** — `"version": "0.11.0"` nos 2 manifests.
- [ ] **4. Medir (/12)** — depois de tudo commitado exceto esta tarefa, sobre blobs LF:
  ```bash
  med() { local t=0 f; for f in $(git ls-tree -r --name-only "$1" -- "$2"); do t=$((t + $(git show "$1:$f" | tr -d '\r' | wc -c))); done; echo "$t"; }
  echo "skills antes=$(med ab68deb skills) depois=$(med HEAD skills)"
  echo "templates antes=$(med ab68deb templates) depois=$(med HEAD templates)"
  bash tests/test-carga.sh | grep 'carga MEDIUM'
  ```
  → antes 74760 / 26128 (Notas de sessão); BASE antes 51800. Registrar no
  nó, nova seção `## medicao` entre `## decisoes` e `## delta`:
  `Bytes (blobs LF). skills: 74760 → <S>; templates: 26128 → <T>; test-carga BASE 51800 → <B>, FULL 57040 → <F>. Saíram skills/worktree (1 skill), hooks/loop, hooks/graphify-limpeza, templates/loop-prompt-template.md.`
  Em `tests/test-carga.sh`: linha 6 ganha `; corte-sem-uso: BASE 51800 → <B> / FULL 57040 → <F>.`
  e `TETO_BASE`/`TETO_FULL` = `<B>`/`<F>` × 1,03 arredondados para cima em centenas.
- [ ] **5. Green** — `bash tests/test-corte-sem-uso.sh; echo $?` → `0`;
  suíte (background) → `0`, 11 arquivos, total de asserts somado da saída
  (anotar nas Notas de sessão). Gate → `0` (`GATE: passou`, com a linha de
  justificativa se a contagem cair; nenhum arquivo de teste apagado nesta tarefa).
- [ ] **6. Commit** — `git add .claude-plugin/plugin.json .claude-plugin/marketplace.json tests/test-docs.sh tests/test-corte-sem-uso.sh tests/test-carga.sh docs/audora/memory/corte-sem-uso.md && git commit -m "chore(corte-sem-uso/10,12): versão 0.11.0; carga estática medida antes → depois"`.
- [ ] **7. Gate final (/11)** — árvore limpa (`git status --short` vazio):
  `bash hooks/gate corte-sem-uso > "$SCRATCH/gate-final.log" 2>&1; echo $?`
  → `0`, `GATE: passou`. Conferir /11 no histórico:
  `git log --format=%s ab68deb..HEAD | grep -c 'autorizada no escopo'` → `3`
  (T2, T3, T4 citam a autorização); `git log --diff-filter=D --name-only --format= ab68deb..HEAD -- tests/`
  → exatamente os 4 arquivos autorizados. Anotar HEAD, exit e total de
  asserts nas Notas de sessão.
