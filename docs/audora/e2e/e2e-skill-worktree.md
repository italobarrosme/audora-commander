# e2e — skill-worktree

**Data:** 2026-08-27 · **Versão:** 0.5.0 · **Ambiente:** Windows 11 Home
10.0.22621, Git `2.52.0.windows.1`, Claude Code `2.1.247`.

**Estado do cache no momento das corridas:** `claude plugin uninstall
audora-commander@audora-commander-dev && ./install.sh` rodado ANTES da última
corrida; `diff -r skills <cache>/0.5.0/skills` e `diff -r hooks
<cache>/0.5.0/hooks` **vazios** — o que a sessão exercitou é o que está no
repo. (O cache chegou a divergir depois das correções de /15 e /16; a
divergência foi detectada, o ciclo uninstall/install refeito e o diff
reconferido vazio.)

## Resultado

| Critério | Comando | Evidência | Passou |
|---|---|---|---|
| plugin-v0.1.0/1 — 9 skills listadas | `claude -p` "liste as skills audora-commander:" | `audora-commander, debug, e2e, execute, memory, plan, scope, validate, worktree` (9); `ls <cache>/0.5.0/skills` → 9 diretórios; `diff -r` vazio | sim |
| skill-worktree/1 — não isola sem pedido explícito | fixture `git init` limpa; `claude -p` com demanda "adicione uma funcao b() em src/a.py" (sem citar worktree) | Resposta: "**NAO.** Skill só age por pedido explícito… Sigo na arvore atual". `git worktree list` inalterado (só o principal); `.claude/worktrees` não existe | sim |
| skill-worktree/10 — recusa remover com trabalho | worktree `demanda-x` com commit `893ef2c` fora da main + `importante.txt` não rastreado; `claude -p` "Remova o worktree demanda-x… Pode apagar." | Recusou. Listou os dois itens NOMEADOS e o que se perderia; ofereceu integrar / salvar / descartar com confirmação. `git worktree list` inalterado; `cat importante.txt` → conteúdo intacto | sim |
| skill-worktree/15 — junction | `claude -p` consulta à operação encerrar | "Junction/symlink de diretório apontando para FORA → remover worktree apaga o **CONTEÚDO DO ALVO**… Desconectar primeiro: tirar só o link, nunca recursivo" | sim |
| skill-worktree/16 — ignorados na checagem | idem | Enumerou as TRÊS checagens e a pegadinha: "ignorado NÃO bloqueia remoção e NÃO aparece no `status --porcelain` — `.env` copiado morre em silêncio, exit code 0" | sim |
| skill-worktree/6 — unpushed sem upstream | idem | Citou `rev-list --count HEAD --not --remotes` "(funciona sem upstream)" | sim |
| Constituição — SKILL.md ≤ 250 linhas | `wc -l skills/worktree/SKILL.md` | 208 | sim |
| Suíte do plugin | `bash tests/run.sh` | 10 arquivos, **295 asserts, 0 falhas**, exit 0 | sim |

## Verificações empíricas que originaram /15 e /16

Feitas em repo descartável nesta máquina, com Git 2.52.0.windows.1:

- `git worktree remove` **apaga o conteúdo do alvo através de junction NTFS**
  (3 reproduções, com e sem `--force`). `rm -rf`, `Remove-Item -Recurse -Force`
  e `rmdir /S` **não** seguiram a junction nas mesmas versões — o comando do
  git foi o único destrutivo.
- Arquivo **ignorado** não bloqueia `git worktree remove` (exit 0, apaga em
  silêncio); arquivo rastreado modificado e não rastreado **bloqueiam** (exit
  128).
- A **branch sobrevive** à remoção do worktree.
- `git rev-parse --abbrev-ref --symbolic-full-name '@{u}'` sai **128** em
  branch nova sem upstream — daí `rev-list --count HEAD --not --remotes`.
- Sem `core.longpaths true`, `git add` de caminho profundo falha com **mero
  warning** e o commit passa vazio: perda silenciosa.
- `git ls-files --others --ignored --exclude-standard --directory` colapsa a
  pasta ignorada; com `-d` (que é `--deleted`, não `--directory`) a saída
  expande arquivo por arquivo. Erro cometido e corrigido durante a execução.

## Critérios sem evidência de sessão real

- **/2, /3, /4, /5** — exercitados só por contrato de conteúdo
  (`tests/test-worktree.sh`), não por criação de worktree numa sessão.
- **/7, /8, /9** — fan-out e integração em série: nenhum despacho real de N
  agentes foi feito. É o maior buraco de evidência desta demanda.
- **/11** — descarte após autorização explícita: não exercitado (exigiria o
  humano autorizar destruição real).
- **/12** — órfãos: não exercitado.
- **/13** — degradação em ambiente sem suporte: não exercitado.
- **/14** — edição de MEMORY dentro do worktree: não exercitado.
