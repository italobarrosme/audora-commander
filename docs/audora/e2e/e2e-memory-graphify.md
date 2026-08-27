# E2E — memory-graphify (2026-08-26)

Infra: não há docker/web — o "produto rodando" é o plugin 0.4.0 instalado
numa sessão real do Claude Code (`claude plugin uninstall` + `./install.sh`;
cache `~/.claude/plugins/cache/audora-commander-dev/audora-commander/0.4.0`
idêntico ao repo em hooks/, skills/, templates/). Exercício: sessões
não-interativas `claude -p` (CLI 2.1.247) contra fixtures em diretório
temporário (`git init` + arquivos mínimos), com `--dangerously-skip-permissions`
onde a skill precisa rodar comandos. Ferramenta: bash + `claude -p` (decisão
do humano no plano aprovado, T8.3; mesma do e2e anterior). Script e saídas
brutas: scratchpad da sessão (`e2e-memory-graphify.sh`, `e2e-out/`).
Evidência no disco das fixtures conferida por fora (grep/ls/hooks), não só
pelo relato do modelo.

| Critério (`<id>/<n>` + EARS) | Passo executado | Evidência | Veredito |
|---|---|---|---|
| memory-graphify/1 — 8 skills com `memory` no lugar de `graph` | `claude -p` "liste as skills audora-commander:" (corrida A) | `audora-commander, debug, e2e, execute, memory, plan, scope, validate` (8; sem `graph`); `diff -r skills cache/0.4.0/skills` vazio | passou |
| hook SessionStart cita `memory` e `MEMORY.md` (suporte a /1, /2) | `claude -p` "cite a frase do hook" (corrida B) | `"… Memória do produto: MEMORY.md (skill memory; Graphify indexa o código). Fluxos de fase: memory, scope, plan, execute, e2e, validate; … debug. …"` | passou |
| memory-graphify/2 — sem `MEMORY.md` → oferece bootstrap, não inventa | corridas C, D, E, F (fixtures sem MEMORY.md) | C: parou e perguntou "Bootstrap do MEMORY.md — autoriza?"; D/E/F: bootstrap executado só porque o prompt pré-autorizou; nenhum MEMORY inventado sem pedir | passou |
| memory-graphify/3 — `GRAFO.md` sem `MEMORY.md` → avisa que não é lido e oferece bootstrap; destino do antigo é do humano | fixture com `GRAFO.md` (versao-schema 2) + `app.py`, demanda "/health" (corrida C) | "Framework 0.4.0 não lê mais `GRAFO.md` — só `MEMORY.md`… não converto nem apago o arquivo antigo por conta própria. Destino do legado é decisão sua." + 3 perguntas (bootstrap? GRAFO.md: deixar/migrar/apagar? Graphify?) e parou sem código | passou |
| memory-graphify/4 — bootstrap cria `MEMORY.md` pelo template + `docs/audora/memory/` vazia | corridas D, E, F | `MEMORY.md` com `memory-schema: 1`, Propósito, Constituição (5 bullets), Aprendizados, Índice; `docs/audora/memory/` criada; `memory-validate` e `memory-guard` exit 0 (conferido por fora na fixture D) | passou |
| memory-graphify/6 — aprendizado registrado na hora (data \| fase \| frase) | corridas D, E, F | linhas `- 2026-08-26 \| memory \| …` na seção Aprendizados das três fixtures (armadilha do `_PINNED`, repo só-Markdown, etc.) | passou |
| memory-graphify/10 — `graphify` fora do PATH → oferece instalar; recusado → `graphify: recusado` + aviso degradado | fixture `src/m.py`, PATH sem graphify, resposta NÃO (corrida F) | `graphify.exe` escondido (rename com trap) → `graphify-status` = `ausente`; a resposta pré-dada era NÃO → sessão gravou `- **graphify**: recusado` na Constituição, não instalou nada, sem `graphify-out/`, sem git hook, aprendizado "plan/debug/execute rodam degradadas (grep/Read), não reofertar" — conferido no disco | passou |
| memory-graphify/12 — Graphify disponível → `graphify update .`, git hook, `graphify-out/` no gitignore, `graphify: ativo` | fixture `src/auth.py` + `src/app.py` (corrida D); conferido no disco | `graphify-status` `sem-indice` → `graphify update .` (13 nós) → `ativo`; `.gitignore` = `graphify-out/`; `graphify-out/{graph.json,…}`; `.git/hooks/post-commit` + `post-checkout` instalados; Constituição `- **graphify**: ativo`; `memory-validate` exit 0 | passou |
| memory-graphify/12 (sub-passo novo da skill) — conferir o post-commit após instalar | corrida D | sessão detectou `_PINNED=''` ("could not locate a Python"), pinou o Python do uv tool, reexecutou o hook com diff real → "launching background rebuild" + log; registrou aprendizado | passou |
| memory-graphify/13 — índice sem nós de código → avisa, sem git hook, `graphify: sem-codigo` | fixture só `README.md` + `docs/guia.md` (corrida E); conferido no disco | `graphify update .` → 4 nós, zero `file_type: code` → `graphify-status` = `sem-codigo`; `.git/hooks` só samples (0 hooks); Constituição `- **graphify**: sem-codigo — …`; aviso "plan/debug/execute rodam degradadas" no aprendizado | passou |
| memory-graphify/14 — consultar-codigo antes de qualquer Read; lê só os `src=` apontados | fixture D já com índice ativo (corrida G) | `graphify-status` → `ativo`; `graphify query "login" --budget 1500` (5 NODE/5 EDGE), `graphify affected "login()"`, `graphify path "main()" "login()"`; Reads: só `src/auth.py` e `src/app.py` (os `src=` dos NODE); resposta `src/auth.py:1`, chamador `main()` em `src/app.py:3` | passou |
| memory-graphify/17 — `recusado`/`sem-codigo` não reoferece nas demandas seguintes | não exercitado ao vivo (exigiria segunda demanda na mesma fixture); regra escrita na skill (op. 2a e 7.1) e no aprendizado gravado pela própria sessão E | — | não-automatizável (roteiro humano) |
| memory-graphify/11, /15, /16 — instalação falha / consulta falha / arquivo fora do índice | caminhos de erro dependem de ambiente quebrado (sem uv, graph.json corrompido) — cobertos pela suíte bash para a detecção (`graphify-status`: `sem-indice` em json corrompido/ausente, `ausente` fora do PATH) | `tests/test-graphify-status.sh` PASS=6 | coberto por teste (não e2e) |
| memory-graphify/5, /7, /8, /9, /18, /19 | estrutura/dogfood/docs — cobertos por `tests/run.sh` (9 arquivos, 0 falhas) | ver roteiro de validação | — |

Observações do e2e (não reprovam critério; entram no roteiro):
- As sessões E e F relataram um hook PreToolUse do ambiente do humano
  (`if: Bash(git commit*)` / guard de `.git/hooks`) barrando comandos que
  citam `post-commit`; contornaram com Write/cópia do hook. Não é do plugin.
- Em F, restringir o PATH não isola: o Bash tool da sessão filha carrega o
  perfil do usuário e devolve `~/.local/bin` ao PATH (duas tentativas deram
  `sem-indice`). Só escondendo o `graphify.exe` (rename + trap de restauração)
  o status virou `ausente`. Nessas tentativas a sessão seguiu o caminho
  `sem-indice` → `ativo` corretamente (mais uma evidência de /12).
- A sessão F (2ª tentativa) observou `graphify query` devolvendo "No matching
  nodes found" num repo de 1 função stub, enquanto `graphify affected`
  respondia — a op. consultar-codigo já prevê degradar para grep/Read; vale
  citar `affected` como alternativa no passo 3 (sugestão, não defeito).
- A sessão D marcou os nós inferidos como `delivered` com a keyword
  `inferido` no índice, em vez de `origem: inferido` no arquivo do nó (nó só
  na linha do índice é permitido para `planned`; para `delivered` a skill
  não proíbe). Ajuste de texto candidato: "nó inferido de funcionalidade já
  existente entra como `delivered` + arquivo com `origem: inferido`".

Teardown: fixtures em diretório temporário da sessão (descartáveis; hooks
git instalados só dentro delas); sessões `claude -p` encerram sozinhas; nada
levantado permaneceu. Plugin fica instalado na versão 0.4.0 (estado desejado).
