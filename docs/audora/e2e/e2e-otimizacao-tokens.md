# E2E — otimizacao-tokens (2026-09-28)

Infra: plugin não-web, sem docker. Plugin 0.9.0 reinstalado
(`claude plugin uninstall` + `./install.sh`; `claude plugin list` →
`Version: 0.9.0`). Ferramenta: `claude -p` (CLI 2.1.247) com
`--output-format stream-json --verbose --dangerously-skip-permissions
--max-budget-usd 4` numa fixture `git init` no scratchpad: CLI bash
`soma.sh` com bug de sinal, `test.sh`, `MEMORY.md` válido (Constituição com
`graphify: recusado`, `gate: recusado`) e `PRD.md`. Prompt: "Bug: `bash
soma.sh -2 -3` imprime 5, deveria imprimir -5. Corrija seguindo o framework
instalado. Pode seguir sem me perguntar nada até o portão final da validate;
no portão final, PARE". Contagem de tool calls por script perl sobre o
stream (`conta.pl`); disco da fixture conferido por fora. Script, stream e
contagem no scratchpad da sessão (`e2e-tokens.sh`, `e2e-tokens-out/`).

Resultado da corrida: 30 turnos, 24 tool calls, US$ 2,39; caminho
audora-commander → debug → execute → validate; parou no portão final com
roteiro (evidência 1:1 dos 3 critérios da fixture, diff de teste separado,
premissas de autopilot); commit `fix(soma-negativos/1,2,3)` na fixture.

| Critério (`<id>/<n>` + EARS) | Passo executado | Evidência | Veredito |
|---|---|---|---|
| otimizacao-tokens/1 — skill memory, `MEMORY.md` e template do bloco já carregados na sessão → não reinvoca nem relê | demanda LIGHT atravessando 4 skills de fase numa sessão só | `Skill: audora-commander:memory x1`; `MEMORY.md` lido 1× (Bash `cat` na entrada); `bloco-fechamento-template.md` lido 1× (Bash `cat` junto do registrar-no); nenhuma releitura nas fases debug/execute/validate | passou |
| otimizacao-tokens/4 — bloco recomenda `/clear` quando a próxima fase se reancora pelos artefatos; em autopilot não aparece | mesma corrida | a sessão tratou "pode seguir sem me perguntar até o portão final" como declaração de autopilot (`autopilot: elegivel` no nó) e o bloco final NÃO recomendou `/clear` — ramo autopilot confirmado. O ramo não-autopilot (recomenda) não foi exercitado ao vivo | parcial — ramo de recomendação só por texto asserido (roteiro humano) |
| otimizacao-tokens/2, /3, /5, /7, /8 | estruturais | suíte (`tests/test-skills.sh`, `test-carga.sh`, `test-autopilot.sh`, `test-gate.sh`) | — |
| otimizacao-tokens/6 | motor com `claude` falso no PATH | `tests/test-loop.sh` (prompt sem `## Tarefa 2`, com cabeçalho e notas; plano sem notas → DONE) | — |

Observação (não reprova critério; vira aprendizado): a sessão leu
`registrar-no.md` e templates pelo caminho do REPO
(`C:/Users/Italo Barros/workspace/audora-commander/...`) — com marketplace
local apontando para a pasta do repo, a "raiz do plugin" que o Skill tool
imprime é o próprio repo, não o cache.
