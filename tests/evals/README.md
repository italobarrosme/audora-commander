# Evals de comportamento

A suíte `tests/` prova o **texto** das skills; estes evals provam o
**comportamento**: rodam o modelo de verdade numa fixture e conferem o que ele
fez (skill invocada, arquivo escrito, ordem do TDD). Também medem qual regra é
peso morto (mutação). **Manual e pago** — fica fora do `bash tests/run.sh`.

## Como rodar

```bash
bash tests/evals.sh                       # modo rápido: cada caso 1x com o plugin
bash tests/evals.sh --completo            # 3x com o plugin e 3x sem; passa só com 3/3
bash tests/evals.sh --caso porta          # só um caso (repetível)
bash tests/evals.sh --mutar execute-apague [--runs 3]   # mutação de uma regra
```

| flag | padrão | o que faz |
|---|---|---|
| `--completo` | rápido | 3 runs com e 3 sem o plugin; mostra a taxa sem e a diferença (Δ) |
| `--caso <nome>` | todos | roda só esse caso (repetível) |
| `--teto <usd>` | `10` | para antes do próximo run quando o gasto da rodada chega ao teto |
| `--modelo <m>` | `sonnet` | modelo do agente sob teste |
| `--mutar <regra>` | — | roda o caso da regra com a skill original e com uma cópia sem a regra |
| `--runs <n>` | `3` | runs por braço na mutação (só com `--mutar`) |
| `--timeout-run <s>` | `900` | limite por run do caso harness (`tdd`) |
| `--claude <bin>` / `--raiz <dir>` | PATH / repo | ganchos de teste (o `tests/test-evals.sh` usa um claude falso) |

Pré-requisitos: Claude Code ≥ 2.1.269 (`claude` no PATH ou em
`~/.local/bin/claude.exe`) e, para o caso `tdd`, um token: rode
`claude setup-token` e ponha o valor em `.env` (`CLAUDE_CODE_OAUTH_TOKEN=`;
`.env` é ignorado pelo git). Sem token o caso `tdd` sai **RECUSADO** — o
harness isola `HOME`/config num diretório temporário, e copiar as credenciais
do humano arriscaria rotacionar o refresh token. O harness também liga
`CLAUDE_CODE_DISABLE_CLAUDE_MDS=1` (no Windows o `claude` acha o seu
`~/.claude/CLAUDE.md` pela API do SO, mesmo com `HOME` trocado) e libera Bash
**sem sandbox** dentro do workspace temporário — rode só em máquina sua.

## Casos

| caso | prova | como |
|---|---|---|
| `porta` | evals-comportamento/3 | `claude plugin eval`: 1ª skill é a porta, anúncio MEDIUM, próxima fase scope |
| `escopo-antes` | evals-comportamento/4 | `claude plugin eval`: nenhum Write/Edit fora de `MEMORY.md` e `docs/audora/` |
| `memoria` | evals-comportamento/5 | `claude plugin eval`: nó com critério EARS; aprendizado em `aprendizados.md`, nunca no MEMORY |
| `tdd` | evals-comportamento/6 | harness próprio `claude -p` (o `plugin eval` recusa Bash no Windows nativo): teste novo → falhando → código → passando |

Cada caso é uma pasta com `prompt.md` (ou `harness.md`), `fixture.sh` (cria o
projeto com MEMORY no workspace vazio; base em `_lib/projeto-base.sh`) e
`graders/`. Regras mutáveis em `mutacoes.tsv`.

## Saída

```
evals: modo rápido · modelo sonnet · teto US$ 10.00
PASSOU · porta · com 1/1 · US$ 0.4123 · tokens 16481
REPROVOU · memoria · com 0/1 · US$ 0.3011 · tokens 9800 · motivo: no-com-ears: no match
ERRO INFRA · tdd · causa: sem autenticação · US$ 0.0000 · tokens 0
NÃO RODADO · escopo-antes · não rodado: teto
total: 4 caso(s) · 1 passou · 1 reprovou · 1 erro de infra · 1 não rodado · US$ 0.7134 · tokens 26281
```

- **PASSOU** / **REPROVOU**: veredito dos graders (motivo = grader que reprovou).
- **ERRO INFRA**: claude ausente ou velho, sem autenticação, timeout, erro de
  API — nunca conta como aprovado.
- **RECUSADO**: o isolamento não pôde ser garantido (plugin extra na sessão,
  sem token no harness, raiz fora de git). Conta como erro de infra.
- **NÃO RODADO**: o teto de custo parou a rodada.
- `ISOLAMENTO VIOLADO · git status mudou: …`: o repo do plugin saiu diferente.

Mutação: `com a regra 3/3 · sem a regra 1/3 · efeito -67 pp`, ou `sem efeito`
quando a taxa sem a regra não cai — relatório; o corte é decisão do humano.

| exit | quando |
|---|---|
| `0` | tudo que rodou passou, nenhum erro de infra (mutação: relatório completo) |
| `1` | algum caso reprovou |
| `2` | teto de custo atingido |
| `3` | erro de infra, RECUSADO ou isolamento violado |
| `4` | uso inválido (flag, caso, regra ou âncora de mutação) |

Precedência: `3 > 2 > 1 > 0`. Custo típico: ~US$ 0,30–0,60 por run em
`sonnet`; o modo completo de 4 casos fica perto do teto padrão.

## Calibração

Um caso que nunca reprova não prova nada (evals-comportamento/13): cada caso
tem uma rodada registrada em que REPROVA numa condição sabidamente ruim.

| caso | condição ruim | data | resultado |
|---|---|---|---|
| escopo-antes | braço sem plugin (`--completo`) | 2026-10-10 | REPROVOU 0/3 (com o plugin 3/3, Δ +100 pp) |
| memoria | braço sem plugin (`--completo`) | 2026-10-10 | REPROVOU 0/3 (com o plugin 3/3, Δ +100 pp) |
| porta | braço sem plugin (`--completo`) | 2026-10-10 | REPROVOU 0/3 (com o plugin também 0/3: achado `porta-anuncio`) |
| tdd | braço sem plugin (`--completo`) | 2026-10-10 | REPROVOU 0/3 (com o plugin 2/3: achado `retomada-execute`) |

Achados da 1ª rodada real (2026-10-10, `sonnet`, ~US$ 6 com a depuração):
- **porta** — com o plugin o modelo classifica MEDIUM e vai para scope, mas
  pula o anúncio "Demanda classificada como … — me corrija se discordar"
  (5/5 runs). Nó `porta-anuncio`.
- **tdd** — em ~1 de 3 runs o modelo não reconhece `execute de dobro` (o
  comando de retomada que o bloco de fechamento manda colar), não invoca skill
  e pergunta o que fazer. Nó `retomada-execute`.
