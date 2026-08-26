# E2E — comandos-ingles (2026-08-25)

Infra: não há docker/web — o "produto rodando" é o plugin instalado numa
sessão real do Claude Code. Exercício: `claude plugin uninstall` +
`./install.sh` (cache `~/.claude/plugins/cache/audora-commander-dev/audora-commander/0.3.0`)
seguido de sessão não-interativa `claude -p` com o plugin ativo, mais o hook
`grafo-validate` executado via `hooks/run-hook.cmd` no `cmd.exe` contra
fixtures em diretório temporário. Ferramenta: bash + `claude -p` (CLI 2.1.x).

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| comandos-ingles/1.1 — 8 skills EN listadas | `claude -p` "liste as skills audora-commander:" | `audora-commander, debug, e2e, execute, graph, plan, scope, validate` (8, nenhum PT); `ls cache/0.3.0/skills` idem; `diff -r skills cache/skills` vazio | passou |
| comandos-ingles/1.2 — hook cita nomes EN | `claude -p` "cite a frase do hook SessionStart" | `"Framework audora-commander ativo. ... Fluxos de fase: graph, scope, plan, execute, e2e, validate; ... debug. ..."` | passou |
| comandos-ingles/3.4 — hook acusa estado PT no índice v2 | `cmd //c run-hook.cmd grafo-validate < fixture pt` (cwd sem templates/) | exit=2; stderr cita `skill graph` e `tabela em C:/Users/.../templates/no-template.md` (arquivo existe) | passou |
| comandos-ingles/3.5 — v1 / fora do GRAFO / JSON inválido → exit 0 | `run fixture v1`, `run qualquer.txt`, `echo nao-json \| bash hooks/grafo-validate` | exit=0 nos três, stderr vazio | passou |
| comandos-ingles/4.2 — plugin listado como 0.3.0 | `claude plugin update` → "updated from 0.2.0 to 0.3.0"; `installed_plugins.json` | `"version": "0.3.0"`, installPath `.../0.3.0` | passou |
| comandos-ingles/2.1 — anúncio de categoria ao vivo | requer demanda real numa sessão interativa | — | não-automatizável (roteiro humano) |
| demais (1.3, 2.2, 3.1, 3.2, 3.3, 4.1, 4.3) | cobertos por grep/execução na validate (não são e2e) | ver roteiro de validação | — |

Teardown: fixtures em `mktemp -d` (descartáveis); sessão `claude -p` encerra
sozinha; nada levantado permaneceu.
