# E2E — validate-estado-no (2026-09-28)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.9.0
reinstalado de `main` (`claude plugin uninstall
audora-commander@audora-commander-dev` + `./install.sh`; `claude plugin list`
→ `Version: 0.9.0`, enabled), numa sessão real do Claude Code. Ferramenta:
`claude -p` (CLI 2.1.247, Constituição `ferramenta-e2e`) com
`--permission-mode acceptEdits --output-format stream-json --verbose`. Cada
cenário roda contra uma fixture própria (`git init` no scratchpad) com
`MEMORY.md` `memory-schema: 1` e um nó `x`. O prompt manda usar só o Edit e
copiar literalmente qualquer mensagem de hook. Script e saídas brutas ficam
no scratchpad da sessão (`e2e-estado.sh`, `e2e-estado/out/*.jsonl`). O disco
das fixtures foi conferido por fora (`grep '^estado'`, `grep '^- x'`).

O hook que disparou foi `hooks/run-hook.cmd memory-validate`, resolvido na
raiz do repo. Com o marketplace local, a raiz do plugin é o próprio repo
(aprendizado de 2026-09-28).

| Critério (`<id>/<n>` + EARS) | Passo executado | Evidência | Veredito |
|---|---|---|---|
| validate-estado-no/1 — estado do nó fora do enum → rejeita nomeando arquivo, valor e enum | Fixture A (índice e nó `planned`); Edit no nó para `estado: planejado` | `PostToolUse:Edit hook blocking error … - arquivo docs/audora/memory/x.md com estado 'planejado' fora do enum (planned\|in-progress\|blocked\|delivered\|discarded\|hotfix-pending-record) (…/templates/no-template.md)` | passou |
| validate-estado-no/2 — nó sem `estado:` → rejeita nomeando o arquivo | Fixture B; Edit apagando a linha `estado:` | `… - arquivo docs/audora/memory/x.md sem campo 'estado:' no frontmatter (…/no-template.md)` | passou |
| validate-estado-no/9 — escrita do nó com estado válido ≠ índice (1ª metade da transição) → aceita | Fixture C (ambos `in-progress`); passo 1: Edit no nó para `delivered` | `grep memory-validate C.jsonl` → vazio, nenhuma mensagem de hook no passo 1; disco: `estado: delivered` com o índice ainda `in-progress` naquele momento | passou |
| validate-estado-no/5 — tudo válido e igual ao índice → aceita | Fixture C, passo 2: Edit no índice para `- x \| delivered \|` | Modelo: "Passo 2 — SEM MENSAGEM DE HOOK"; disco: nó e índice `delivered` | passou (caminho LF; CRLF e espaços na suíte) |
| validate-estado-no/3 — escrita do `MEMORY.md` com nó divergente → rejeita nomeando nó e os dois valores | Fixture D (índice `in-progress`, nó `delivered`); Edit no `MEMORY.md` em linha alheia (Propósito) | `… - nó 'x' com estado divergente: índice 'in-progress', arquivo 'delivered' — transição é nó primeiro, índice depois; alinhe os dois` | passou |
| validate-estado-no/4 — qualquer escrita confere todos os nós | Fixture D: a escrita foi no `MEMORY.md`, o erro acusou o nó | Mesma evidência do /3. O caso "escrita no nó x acusa nó y" está na suíte | passou (parcial ao vivo, completo na suíte) |

Os critérios /6 (histórico ignorado), /7 (órfão sem divergência duplicada),
/8 (READMEs) e /10 (ordem nó → índice em registrar-no e sync) são de borda
estrutural ou de docs. Estão cobertos pela suíte (`tests/test-memory-validate.sh`,
`tests/test-docs.sh`, `tests/test-skills.sh`) e ficam no roteiro de validação.

Observação: nos cenários A, B e D o modelo recebeu o erro e **não corrigiu**,
porque o prompt proibia. Numa demanda normal, o erro volta ao modelo com exit
2 e ele corrige o arquivo. Esse caminho não foi exercitado aqui de propósito,
para manter o disco como evidência.
