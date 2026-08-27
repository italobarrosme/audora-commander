# Plano — skill-worktree: Skill worktree

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** entregar a 9ª skill do framework — `worktree` — que isola uma
demanda em worktree próprio sob pedido explícito, despacha N agentes em N
worktrees e integra de volta em série, sem nunca destruir trabalho não
integrado.

**Nó do MEMORY:** `skill-worktree` (MEMORY.md)

**Arquitetura da mudança:** a skill ORQUESTRA o worktree nativo do harness
(`EnterWorktree`/`ExitWorktree`/`claude --worktree`) em vez de embarcar
plumbing de git — decorre da Constituição (código executável só em `hooks/` e
`tests/`) e da restrição da própria ferramenta nativa, que só reconhece
worktree sob `.claude/worktrees/` do mesmo repositório. Consequência: a skill é
Markdown puro, como as outras 8; o executável novo mora só em `tests/`. A
contagem de skills está cravada em teste, README EN/PT, PRD e no nó
`plugin-v0.1.0` — todos entram na mesma demanda. Versão sobe 0.4.0 → 0.5.0
porque o cache do plugin só é refeito com bump (Aprendizado 2026-08-25).

**Arquivos lidos antes de planejar:**
- `skills/audora-commander/SKILL.md` — formato canônico de skill, tabela de
  roteamento por categoria, seção PRÓXIMA SKILL.
- `skills/memory/SKILL.md` — operações (registrar-aprendizado, registrar-delta),
  regra "em branch de demanda editar só os nós daquela demanda".
- `skills/execute/SKILL.md` — formato de fluxo/red-flags, onde a skill nova
  encaixa no encadeamento.
- `skills/validate/SKILL.md` — portão humano final; worktree não aprova nada.
- `skills/scope/SKILL.md`, `skills/plan/SKILL.md` — formato.
- `tests/lib.sh` — helpers `ok/ko/assert_*`, `run_hook`, `report`.
- `tests/test-skills.sh` — loop das 8 skills + contratos de conteúdo (/6, /14, /18).
- `tests/test-no-grafo.sh` — `assert_eq "8" "$(ls -d skills/*/ | wc -l)"` (L20).
- `tests/test-docs.sh` — versão 0.4.0 cravada nos 2 manifests; blocos EN/PT idênticos.
- `tests/test-session-start.sh` — exige a substring `memory, scope, plan, execute, e2e, validate`.
- `hooks/session-start` — ponteiro curto injetado na sessão.
- `hooks/hooks.json`, `hooks/memory-validate`, `hooks/graphify-status` — contrato dos hooks.
- `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` — versão/keywords.
- `README.md` (L28, L94-105, L142), `README.pt-BR.md`, `PRD.md` (L32, L82, L153) — contagem de skills.
- `templates/no-template.md`, `templates/plano-template.md` — schemas.
- `docs/audora/memory/plugin-v0.1.0.md` — critério /1 "8 skills" (delta 8→9 já registrado).

**Conflitos MEMORY vs código encontrados:** um — `plugin-v0.1.0/1` exigia
"listar as 8 skills"; esta demanda faz 9. Resolvido na auto-revisão do escopo
com delta `MODIFICADO (2026-08-27)` no nó `plugin-v0.1.0`, mesmo padrão do
7→8 anterior. Não precisou de decisão do humano: é contagem, não requisito.

**Evidência de ambiente coletada (não presumida):**
- `git --version` → `2.52.0.windows.1` (suporta `--relative-paths` de 2.48+).
- `claude --version` → `2.1.247`; `claude --help` expõe `-w, --worktree [name]` e `--tmux`.
- Ferramentas nativas confirmadas por schema: `EnterWorktree` (cria/entra; só
  sob `.claude/worktrees/`; base ref por `worktree.baseRef`, default `fresh`) e
  `ExitWorktree` (`action: keep|remove`; **recusa** remover com mudanças a menos
  de `discard_changes: true`).
- `git worktree list --porcelain` → só o main worktree hoje.
- `.git/hooks/` já tem `post-checkout` e `post-commit` (Graphify) — hooks são
  compartilhados via `$GIT_COMMON_DIR/hooks` e `post-checkout` dispara em
  `git worktree add`. Isso é o critério /5 e não é hipotético neste repo.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

Pesquisa que fundamenta o desenho (3 dossiês de subagente, com URL por
afirmação) resumida nas decisões do nó. Pontos que mais pesaram:
- Consenso de 3+ fontes: worktree isola ARQUIVO, não runtime (porta, banco,
  cache) — por isso runtime está em fora-de-escopo.
- `27,67%` de conflito em PRs de agente vs `10-20%` humano (arXiv 2604.03551) —
  fundamenta integração em série (/9) e domínios não-sobrepostos (/7).
- `.git/index.lock` / `.git/config.lock` disputados com 3+ criações simultâneas
  (claude-code#55724, #34645) — fundamenta criação em série (/8).
- `refs/stash` é compartilhado entre worktrees (regra REFS da doc oficial) —
  vira armadilha explícita na skill.
- Acúmulo relatado de 256 worktrees / 28 GB sem rotina de limpeza — fundamenta
  /12 (órfãos apontados, nunca apagados sozinhos).

---

## Tarefa 1: RED — testes da 9ª skill e dos contratos de conteúdo

- **depende-de**: []
- **requisito**: cobre a existência estrutural exigida por todos os critérios;
  em especial **skill-worktree/1** — QUANDO a skill for invocada sem pedido
  explícito de isolamento (nem na demanda do humano, nem na Constituição, nem
  no nó) O SISTEMA DEVE recusar isolar, seguir na árvore atual e dizer em 1
  linha por quê.
- **decisões relevantes**: Constituição — cada `SKILL.md` ≤ 250 linhas,
  frontmatter `name`+`description` ("Use quando..."), Lei de Ferro em bloco de
  código, "Anuncie ao começar", tabela de red flags, seção "PRÓXIMA SKILL";
  código executável só em `hooks/` e `tests/`.
- **interfaces**:
  - consome: `tests/lib.sh` → `ok()`, `ko(msg)`, `assert_eq(esperado, obtido, msg)`,
    `assert_contains(haystack, needle, msg)`, `assert_not_contains(...)`,
    `assert_file(path, msg)`, `report()`, `$ROOT`.
  - produz: `tests/test-worktree.sh` (executável, roda pelo `tests/run.sh`).
- **arquivos**:
  - Criar: `tests/test-worktree.sh`
  - Modificar: `tests/test-no-grafo.sh` (L20: `"8"` → `"9"`)
  - Modificar: `tests/test-skills.sh` (L5: acrescentar `worktree` ao loop)
- **done quando**: `bash tests/run.sh` sai 1, com `test-no-grafo.sh` e
  `test-worktree.sh` acusando falha por ausência de `skills/worktree/SKILL.md`
  — e nenhum outro arquivo de teste falhando.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever `tests/test-worktree.sh`** — conteúdo completo:

```bash
#!/usr/bin/env bash
# skill-worktree/1..14 — contratos de conteúdo da skill worktree.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
f="skills/worktree/SKILL.md"
assert_file "$f" "skill worktree existe"
[ -f "$f" ] || { report; exit; }
w="$(cat "$f")"
[ "$(wc -l < "$f")" -le 250 ] && ok || ko "worktree > 250 linhas"
grep -q "^name: worktree\$" "$f" && ok || ko "worktree name:"
grep -q "^description: 'Use quando" "$f" && ok || ko "worktree description entre aspas simples"
assert_contains "$w" 'LEI DE FERRO' "worktree Lei de Ferro"
assert_contains "$w" 'Anuncie ao começar' "worktree Anuncie"
assert_contains "$w" '## PRÓXIMA SKILL' "worktree PRÓXIMA SKILL"
assert_not_contains "$w" 'grafo' "worktree sem grafo"
# /1 gatilho é pedido explícito — nunca iniciativa própria
assert_contains "$w" 'pedido explícito' "/1 worktree exige pedido explícito"
# /2 e /3 nomeação pelo id do nó e exigência de nó
assert_contains "$w" 'id do nó' "/2 nome derivado do id do nó"
# /4 arquivos ignorados pelo git
assert_contains "$w" '.worktreeinclude' "/4 cita .worktreeinclude"
# /5 hooks compartilhados
assert_contains "$w" 'hooks são compartilhados' "/5 avisa hooks compartilhados"
# /7 e /8 fan-out
assert_contains "$w" 'não-sobrepostos' "/7 domínios de arquivo não-sobrepostos"
assert_contains "$w" 'em série' "/8 e /9 criação e integração em série"
# /10 e /11 remoção
assert_contains "$w" 'discard_changes' "/10 cita a trava da ferramenta nativa"
# /12 órfãos
assert_contains "$w" 'git worktree prune' "/12 limpeza de órfãos"
# /13 degradação
assert_contains "$w" 'degrada' "/13 degrada sem travar"
# ferramentas nativas orquestradas, não plumbing próprio
for s in 'EnterWorktree' 'ExitWorktree' 'git worktree list --porcelain'; do
  assert_contains "$w" "$s" "worktree cita '$s'"
done
# registra aprendizado como as demais fases
assert_contains "$w" 'registrar-aprendizado' "worktree registra aprendizado"
report
```

- [ ] **2. Tornar executável e ajustar os dois testes existentes** —
  `chmod +x tests/test-worktree.sh`; em `tests/test-no-grafo.sh` trocar
  `assert_eq "8"` por `assert_eq "9"` e a mensagem `"...8 skills"` por
  `"...9 skills"`; em `tests/test-skills.sh` o loop passa a
  `for s in audora-commander memory scope plan execute e2e validate debug worktree; do`.
- [ ] **3. Rodar e ver falhar pelo motivo certo** — `bash tests/run.sh`.
  Esperado: `test-worktree.sh: PASS=0 FAIL=1` (arquivo ausente),
  `test-no-grafo.sh` acusando `9 skills` com 8 obtidas, `test-skills.sh`
  acusando `skill worktree existe`; `run.sh` exit 1. Falha por feature
  ausente, não por typo — conferir na saída real.
- [ ] **4. Commit do vermelho** — `git add tests/ && git commit -m "test(skill-worktree/1-14): RED — contratos da 9a skill worktree"`.

---

## Tarefa 2: GREEN — `skills/worktree/SKILL.md` — `expandir: sim`

- **depende-de**: [1]
- **requisito**: todos os 14 critérios do nó `skill-worktree`. Verbatim dos que
  governam o corpo da skill:
  - **skill-worktree/4** — QUANDO um worktree novo for criado O SISTEMA DEVE
    listar quais arquivos ignorados pelo git o projeto precisa para rodar
    (`.env` e afins) e o estado deles no worktree, sem copiar segredo em silêncio
  - **skill-worktree/9** — QUANDO houver mais de um worktree para integrar O
    SISTEMA DEVE integrar um por vez e reancorar os restantes na base
    atualizada antes do próximo
  - **skill-worktree/10** — QUANDO for pedida a remoção de um worktree com
    alteração não commitada ou commit não integrado O SISTEMA DEVE recusar,
    mostrar o que se perderia e esperar decisão explícita do humano
- **decisões relevantes**: orquestrar o nativo, não reimplementar git; gatilho
  só por pedido explícito; fan-out incluído (ressalva do teto de 250 linhas
  registrada no nó — se estourar, cortar prosa, nunca cortar critério).
- **interfaces**:
  - consome: `EnterWorktree({name})` / `EnterWorktree({path})`;
    `ExitWorktree({action: "keep"|"remove", discard_changes?: boolean})`;
    `git worktree list --porcelain`; `git worktree prune -n`;
    `git -C <wt> status --porcelain`.
  - produz: `skills/worktree/SKILL.md` — consumido por `tests/test-worktree.sh`,
    pelo roteamento da skill `audora-commander` e pelo ponteiro do `session-start`.
- **arquivos**:
  - Criar: `skills/worktree/SKILL.md`
  - Teste: `tests/test-worktree.sh` (da Tarefa 1)
- **done quando**: `bash tests/run.sh` verde (todos os arquivos), `wc -l
  skills/worktree/SKILL.md` ≤ 250, e cada um dos 14 critérios rastreável a uma
  seção nomeada da skill.

`expandir: sim` — quebrar em subtarefas quando chegar a vez (esboço de seções:
gatilho; 6 operações; o que worktree NÃO isola; armadilhas; red flags; PRÓXIMA
SKILL). Não detalhar agora.

---

## Tarefa 3: Superfície do plugin — contagem, versão e ponteiro

- **depende-de**: [2]
- **requisito**: **plugin-v0.1.0/1** (com o delta de 2026-08-27) — QUANDO o
  marketplace local for adicionado e o plugin instalado O SISTEMA DEVE listar
  as 9 skills com prefixo `audora-commander:`.
- **decisões relevantes**: Aprendizado 2026-08-25 — `claude plugin update` só
  refaz o cache com bump de versão; sem bump o humano continua com 8 skills.
  Constituição: README principal em inglês com PT linkado; blocos de código
  idênticos entre EN e PT (cravado em `test-docs.sh`).
- **interfaces**:
  - consome: `skills/worktree/SKILL.md` (Tarefa 2).
  - produz: versão `0.5.0` nos 2 manifests; linha `| `worktree` | ... |` nas
    tabelas de skills EN e PT; ponteiro do `session-start` citando worktree.
- **arquivos**:
  - Modificar: `.claude-plugin/plugin.json` (version 0.5.0; keyword `worktree`)
  - Modificar: `.claude-plugin/marketplace.json` (version 0.5.0)
  - Modificar: `README.md` (L28 "8 chained skills" → 9; `## The 8 skills` →
    `## The 9 skills` + linha da tabela; L142 checklist "8 skills" → 9)
  - Modificar: `README.pt-BR.md` (equivalentes)
  - Modificar: `PRD.md` (L32 "8 skills encadeadas" → 9; estado atual; metas)
  - Modificar: `hooks/session-start` (acrescentar worktree ao ponteiro
    PRESERVANDO a substring `memory, scope, plan, execute, e2e, validate`
    exigida por `tests/test-session-start.sh`)
  - Modificar: `tests/test-docs.sh` (asserts de `"version": "0.4.0"` → `"0.5.0"`;
    seção `Renamed in 0.4.0` continua valendo — não renomear)
- **done quando**: `bash tests/run.sh` verde e `grep -rn "8 skills" README.md
  README.pt-BR.md PRD.md` vazio.

Passos:

- [ ] **1. RED** — atualizar `tests/test-docs.sh` para `0.5.0` e acrescentar
  `assert_contains "$en" '| `worktree` |' "/19 README EN lista worktree"` e o
  par em PT; rodar `bash tests/run.sh` e ver `test-docs.sh` falhar.
- [ ] **2. GREEN** — aplicar as edições de versão, tabelas e ponteiro.
- [ ] **3. Verificar** — `bash tests/run.sh` verde; `grep -rn "8 skills"` vazio.
- [ ] **4. Commit** — `git add -A && git commit -m "feat(skill-worktree/1-14): 9a skill worktree + superficie do plugin em 0.5.0"`.

---

## Tarefa 4: Instalação real e evidência

- **depende-de**: [3]
- **requisito**: **plugin-v0.1.0/1** e **plugin-v0.1.0/4** — QUANDO cada skill
  for invocada isoladamente O SISTEMA DEVE carregar seu conteúdo sem erro e sem
  placeholders.
- **decisões relevantes**: Aprendizado 2026-08-25 — validar instalação é
  `claude plugin uninstall audora-commander@audora-commander-dev && ./install.sh`;
  os hooks que rodam na sessão são os do cache, não os do repo.
- **interfaces**:
  - consome: repo em 0.5.0 (Tarefa 3).
  - produz: cache do plugin em `0.5.0` contendo `skills/worktree/`.
- **arquivos**:
  - Modificar: nenhum (verificação).
- **done quando**: `diff -r skills "<cache>/0.5.0/skills"` vazio e
  `ls "<cache>/0.5.0/skills"` lista 9 diretórios incluindo `worktree`.

Passos:

- [ ] **1.** `claude plugin uninstall audora-commander@audora-commander-dev && ./install.sh`.
- [ ] **2.** Localizar o cache e conferir: `ls ~/.claude/plugins/cache/*/0.5.0/skills` → 9 diretórios.
- [ ] **3.** `diff -r skills ~/.claude/plugins/cache/*/0.5.0/skills` → vazio.
   Divergência aqui é o achado 1 da revisão adversarial do nó `memory-graphify`
   se repetindo — parar e refazer o ciclo uninstall/install, não seguir.
- [ ] **4.** Seguir para **e2e** (skill) para exercitar a skill numa sessão real.
