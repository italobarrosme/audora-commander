# E2E — limpeza-codigo-morto (2026-09-27)

Infra: plugin não-web, sem docker — o "produto rodando" é o plugin 0.8.0
instalado do cache numa sessão real do Claude Code (`claude plugin uninstall
audora-commander@audora-commander-dev` + `./install.sh`; `claude plugin list`
→ `Version: 0.8.0`; `skills/memory/SKILL.md` do cache com 0 ocorrências de
GRAFO). Ferramenta: `claude -p` (CLI 2.1.247, Constituição `ferramenta-e2e`),
sem flag de permissão, contra 2 fixtures `git init` no scratchpad com um
`app.py` Flask mínimo. Prompt igual nas duas: "Adicione uma rota GET /health
… Siga o framework instalado. Se precisar de autorização ou decisão minha,
PARE e pergunte". Script e saídas brutas no scratchpad da sessão
(`e2e-limpeza.sh`, `e2e-out/fixA.txt`, `e2e-out/fixB.txt`); disco das
fixtures conferido por fora (`ls -A`, `git status --short`).

| Critério (`<id>/<n>` + EARS) | Passo executado | Evidência | Veredito |
|---|---|---|---|
| limpeza-codigo-morto/1 — projeto sem `MEMORY.md` → oferece bootstrap sem mencionar GRAFO, versão anterior ou arquivo legado | fixA: projeto vazio (só `app.py`) | "Lei do `memory`: MEMORY ausente → ofertar bootstrap, nunca seguir sem MEMORY, nunca inventar um… Então paro e pergunto." + 4 perguntas (bootstrap, Graphify, categoria, PRD); `grep -iE 'grafo\|versão anterior\|0.4.0\|legado'` na saída → vazio; disco: só `.git` e `app.py`, `git status` limpo | passou |
| limpeza-codigo-morto/1 (borda) — mesmo cenário com um `GRAFO.md` antigo no repo | fixB: `app.py` + `GRAFO.md` (`versao-schema: 2`, nó `em-curso`) | Nenhum aviso de legado do framework (sem "não é mais lido", sem "0.4.0"). Ofereceu bootstrap e parou ("Nada escrito em disco até tu responder"; conferido: disco intocado). MAS o modelo descobriu o arquivo lendo o repo, citou `GRAFO.md` e ofereceu como opção A "GRAFO.md é a memória deste projeto (schema v2, mais novo que o meu)… leio ele como índice" | passou com ressalva — ver abaixo |
| plugin-v0.1.0/3 — sem `MEMORY.md` → oferece bootstrap em vez de travar ou inventar (evidência renovada no caminho sem legado) | fixA | mesma evidência do /1 | passou |

Ressalva (entra no roteiro do portão): sem o aviso removido, um projeto com
arquivo de memória antigo fica sem orientação do framework, e o modelo pode
tratar o arquivo como memória alternativa (opção A da fixB). Nesta corrida ele
NÃO agiu sozinho: perguntou e não escreveu nada. É a consequência direta do
breaking aceito ("adesão pequena, ninguém impactado") — decisão do humano no
portão final.

Demais critérios (/2–/6, /8, /9) são estruturais/docs, cobertos pela suíte e
pelos greps do roteiro de validação; /7 é o sync do PRD pós-merge.
