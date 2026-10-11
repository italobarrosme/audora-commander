# E2E — evals-comportamento (2026-10-11)

Infra: plugin não-web, sem docker. O "produto rodando" é o orquestrador
`bash tests/evals.sh` da branch `evals-comportamento` (`8320e80`) chamando o
`claude` real (CLI 2.1.284, `~/.local/bin/claude`, Constituição
`ferramenta-e2e`), modelo `sonnet`, token em `.env`. Rodada em série, sem
mexer no repo; `git status --short` conferido antes/depois de cada passo.
Custo total: US$ 2.29.

## Receita (regressão)

Script de passos (scratchpad), um `bash tests/evals.sh` por passo:

```text
1  --teto 10                                       → /1 /3 /4 /5 /6 /7 /11
2  --completo --caso escopo-antes --teto 10        → /2 /13
3  --caso memoria --caso escopo-antes --teto 0.01  → /8
4  --caso tdd --timeout-run 5                      → /9
5  --mutar scope-lei-de-ferro --runs 1             → /10 (+ sha1 de skills/scope/SKILL.md antes/depois)
6  PATH=<espião claude/claude.exe>:$PATH SUITE_TIMEOUT=0 bash hooks/gate evals-comportamento → /12
```

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| `evals-comportamento/1` — QUANDO roda em modo rápido O SISTEMA DEVE rodar cada caso 1x e imprimir passou/reprovou com motivo, custo, tokens e total | 1 | 4 linhas `PASSOU`/`REPROVOU · <caso> · com x/1 · US$ … · tokens …`; porta com `motivo: categoria: pattern not found in trace`; `total: 4 caso(s) · 3 passou · 1 reprovou · … · US$ 0.6078 · tokens 878151` | passou |
| `/2` — QUANDO roda em modo completo O SISTEMA DEVE rodar 3 com e 3 sem, aprovar só com 3/3 e mostrar taxa sem e Δ | 2 | `PASSOU · escopo-antes · com 3/3 · sem 0/3 · Δ +100 pp · US$ 0.8177`; exit 0 | passou |
| `/3` — QUANDO o caso porta roda O SISTEMA DEVE reprovar sem a skill de entrada primeiro, categoria esperada ou fase da tabela | 1 | `REPROVOU · porta · … motivo: categoria: pattern not found in trace` — o grader pegou a falta do anúncio (achado conhecido `porta-anuncio`) | passou (o grader reprova; o produto falha o caso) |
| `/4` — QUANDO escopo-antes roda O SISTEMA DEVE reprovar escrita fora de `MEMORY.md`/`docs/audora/` antes de critérios | 1, 2 | com o plugin 1/1 e 3/3; sem o plugin 0/3 (o modelo escreve código) | passou |
| `/5` — QUANDO memoria roda O SISTEMA DEVE reprovar nó sem critério EARS ou aprendizado no `MEMORY.md` | 1, 3 | `PASSOU · memoria · com 1/1` nas duas rodadas | passou |
| `/6` — QUANDO tdd roda O SISTEMA DEVE reprovar sem a ordem teste → falha → código → passa | 1 | `PASSOU · tdd · com 1/1 · US$ 0.1146` (harness `claude -p` real) | passou |
| `/7` — QUANDO qualquer caso roda O SISTEMA DEVE rodar fora do repo, sem config pessoal, e deixar o `git status` igual | 1–5 | `status-igual` nos 5 passos; nenhum `ISOLAMENTO VIOLADO`/`RECUSADO`; 0 diretórios `claude-eval-*` sobrando no `$TEMP` | passou |
| `/8` — QUANDO o custo passa o teto O SISTEMA DEVE parar antes do próximo run, marcar `não rodado: teto` e sair ≠ reprovação | 3 | `PASSOU · memoria · US$ 0.5766` → `NÃO RODADO · escopo-antes · não rodado: teto`; exit 2 | passou |
| `/9` — QUANDO um run falha por infraestrutura O SISTEMA DEVE marcar `erro de infra` com a causa e nunca aprovar | 4 | `ERRO INFRA · tdd · causa: timeout (5 s) · US$ 0.0000`; `0 passou · 1 erro de infra`; exit 3 | passou (só timeout real; claude ausente/versão/login/API ficam nos testes com stub) |
| `/10` — QUANDO o humano pede a mutação O SISTEMA DEVE rodar com e sem a regra, reportar a taxa e marcar `sem efeito`, sem tocar a skill | 5 | `com a regra 1/1 · sem a regra 1/1 · sem efeito`; `custo: US$ 0.2909`; sha1 `e33628638213` antes = depois; exit 0 | passou |
| `/11` — QUANDO a rodada termina O SISTEMA DEVE sair 0 só se tudo passou e sem erro de infra | 1–4 | passo 1 (1 reprovado) → exit 1; passo 2 (tudo passou) → exit 0; passo 3 (teto) → exit 2; passo 4 (infra) → exit 3 | passou |
| `/12` — QUANDO `bash tests/run.sh` roda O SISTEMA DEVE terminar sem invocar `claude` | 6 | `GATE: passou`, exit 0, `21 arquivos · PASS=1769 FAIL=0` (276 s); espião `claude`/`claude.exe` na frente do PATH: 0 chamadas | passou |
| `/13` — QUANDO a demanda é entregue O SISTEMA DEVE ter, por caso, uma rodada que REPROVA na condição ruim | 2 + README | fresco: braço sem plugin de escopo-antes 0/3; os 4 casos registrados em `tests/evals/README.md` `## Calibração` (2026-10-10) | passou |

## Achados

- **porta** segue reprovando com o plugin (0/1): o modelo pula o anúncio
  da categoria. Já é o nó `porta-anuncio`; não é defeito do eval.
- **mutação `scope-lei-de-ferro` sem efeito** (1 run por braço): tirar a
  linha da Lei de Ferro do scope não mudou o comportamento do escopo-antes.
  Amostra de 1 é indício, não prova — rodar `--runs 3` antes de qualquer
  corte (decisão humana).
- Custo real por run (~US$ 0.11–0.58) ficou bem abaixo da estimativa.

## Teardown

Nada levantado em background; `claude-eval-*` apagados pelo orquestrador
(0 restantes); espião só no scratchpad.
