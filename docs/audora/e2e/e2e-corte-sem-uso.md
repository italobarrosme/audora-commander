# E2E — corte-sem-uso (2026-09-30)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.11.0 da
branch `corte-sem-uso` em `e9eaaea`, carregado por sessão com
`--plugin-dir <repo>` e o 0.9.0 instalado desligado só naquela sessão
(`--settings '{"enabledPlugins":{"audora-commander@audora-commander-dev":false}}'`).
O cache global não foi tocado. Escolha do humano: não reinstalar uma branch
que ainda não foi mergeada. Ferramenta: `claude -p` (CLI 2.1.284,
Constituição `ferramenta-e2e`), binário `~/.local/bin/claude.exe`.

## Receita (regressão)

1. **Fixture** (`fixture.sh <dir> [com-graphify]`, no scratchpad):
   - `git init -b main` com `core.excludesFile` inexistente e 1 commit `init`.
   - `calc.sh` (`soma`/`sub`; uso inválido sai 2), `tests/run.sh` verde
     (`PASS=3 FAIL=0`) e `PRD.md` curto.
   - `MEMORY.md` `memory-schema: 1` com `gate: recusado`, e o nó
     `historico` (`in-progress`, MEDIUM, escopo aprovado, 4 critérios EARS).
   - Com `com-graphify`, a fixture ganha restos do Graphify: o bullet
     `- **graphify**:` na Constituição, `graphify-out/graph.json` e
     `graphify-out/` no `.gitignore`.
2. **Sessão**:
   `claude.exe -p "<prompt>" --plugin-dir <repo> --settings '<acima>' --permission-mode acceptEdits --output-format stream-json --verbose > X.jsonl 2> X.err`,
   rodada em background. Para retomar a mesma sessão, usar
   `--resume <session_id>`.
   - (A) fixture sem Graphify, prompt: "Liste os nomes exatos das skills do
     plugin audora-commander disponíveis nesta sessão…".
   - (B1) fixture com Graphify, prompt: `plan de historico`.
   - (B2) mesma sessão de B1 retomada, prompt: "aprovado, com as decisões
     1-4 como propostas. segue".
3. **Leitura**: o `.jsonl` inteiro, com textos, `tool_use` e prompt do
   `Agent`. Depois, o disco da fixture (`git log`, `git status`, branch) e
   `ls ~/.calc_historico`.
4. **(C) Projetos locais, só leitura**: `git show 71f0409:hooks/graphify-limpeza`
   em cópia no scratchpad, rodado SEM `--remover`, com PATH sem `uv`/`pipx`
   (o script aborta se alcançar os reais). Roda em cada raiz de repo sob
   `workspace/` cujo `MEMORY.md` comece com `memory-schema: 1`. Depois,
   `git status --porcelain --untracked-files=all` de cada projeto contra a
   linha "git status alterado" de `limpeza-graphify-projetos.md`.

## Critérios × evidência

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| corte-sem-uso/1: restos removidos, detecção seguinte vazia | (C) detecção só leitura nos 15 projetos | `projetos=15 com-resto=0`, `limpo … (exit 0)` em todos | passou |
| corte-sem-uso/2: sem commit; o `git status` muda só nos restos | (C) status atual contra o relatório, mais a data do último commit | Arquivos fora da lista do relatório: nenhum é resto do Graphify. São os já sujos antes, citados nas notas do plano (SellInfoTurbo `.env.example`, legal-verify `.claude/worktrees/`, vturbo-bipa, esfera-bench `.bench/`), ou trabalho posterior do humano: vibra, catch-promotion e pepity têm commits de 12:14–12:37, depois da limpeza, e catch-promotion nem tinha resto. O antes/depois exato é da T1 (relatório, HEAD igual em todos) | passou (evidência fresca parcial) |
| corte-sem-uso/3: SellInfoTurbo sem seção no `.claude/CLAUDE.md` e sem `.claude/skills/graphify/` | (C) | `.claude/skills/graphify: ausente`; `.claude/CLAUDE.md` com 0 bytes (tinha só a seção); 0 linhas com graphify no `CLAUDE.md` raiz | passou |
| corte-sem-uso/4: relatório por projeto | leitura | `docs/audora/e2e/limpeza-graphify-projetos.md`: 15 seções, com itens removidos, versionados, falhas e detecção depois | passou |
| corte-sem-uso/5: carga de contexto sem oferta de limpeza do Graphify | (B1) na fixture com os 3 restos | O modelo leu a Constituição com o bullet e listou `graphify-out/`. Não ofereceu limpeza, não chamou script e não consultou índice (nenhum `tool_use` de graphify). Seguiu direto para o plano | passou |
| corte-sem-uso/6: sem autopilot; portão do meio sempre humano | (B1)+(B2) | `grep -ci autopilot` dá 0 nos dois `.jsonl`. B1 subiu para HIGH (grava em `~`) e fechou em "portão humano: aprovar plano… Aprovou → PARADA". Nenhuma pergunta de elegibilidade e nenhum campo `autopilot:` no nó | passou |
| corte-sem-uso/7: sem `hooks/loop` nem loop-prompt | (B2) + listagem | Nenhum `tool_use` citou `hooks/loop` ou motor (`grep` = 0). Os arquivos não existem no repo (suíte `test-corte-sem-uso`) | passou |
| corte-sem-uso/8: "segue" na PARADA roda a fase seguinte em subagente pelo template | (B2) | Registrou a aprovação no nó, leu `templates/fase-subagente-template.md` e despachou UM `Agent` com o texto do template (`{{FASE}}`=execute, `{{ID}}`=historico). O subagente fez só execute: 2 commits TDD em `feat/historico`, red 6/3 → green 9/0 e red 11/4 → green 15/0. A sessão principal conferiu (suíte `PASS=15 FAIL=0`) e fechou em `PARADA: rode /clear … validate de historico`, sem emendar | passou |
| corte-sem-uso/9: 8 skills, nenhuma `worktree` | (A) | `system/init`: o único `audora-commander` é o `@inline` do repo, com as skills `audora-commander`, `debug`, `e2e`, `execute`, `memory`, `plan`, `scope` e `validate`. O modelo respondeu "Total: **8**". O SessionStart injetou o ponteiro sem worktree | passou |
| corte-sem-uso/10: versão 0.11.0 | leitura + suíte | Os 2 manifests têm `"version": "0.11.0"` (`test-docs`). Reinstalar pelo cache ficou fora, por escolha do humano | passou (sem reinstalar) |
| corte-sem-uso/11: gate sai 0 | suíte + gate nesta sessão | `bash tests/run.sh` com exit 0, 11 arquivos e 631 asserts; `bash hooks/gate corte-sem-uso` com exit 0 e `GATE: passou` | passou |
| corte-sem-uso/12: carga medida antes → depois no nó | leitura + revisão adversarial | O `## medicao` do nó bate com o recálculo sobre blobs LF feito pelo revisor | passou |

Os 3 `claude -p` terminaram com exit 0: A em 7 s, B1 em 191 s e B2 em 118 s.
`~/.calc_historico` não existe antes nem depois.

## Observações (não reprovam critério)

- B1 reclassificou `historico` de MEDIUM para HIGH por conta própria, porque
  a feature grava dado persistido fora do repo. Isso trouxe o portão do plano
  HIGH, que também é portão do meio humano, e deu mais cobertura ao /6.
- O subagente de B2 levantou um risco de `core.autocrlf=true` com `.sh`, que
  pede `.gitattributes`. É da fixture, não do plugin.
