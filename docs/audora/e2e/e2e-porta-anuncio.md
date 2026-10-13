# E2E — porta-anuncio (2026-10-13, 2ª rodada)

1ª rodada (2026-10-12, antes da 4ª reabertura): /1, /4 e /6 falharam — ver
`git log -- docs/audora/e2e/e2e-porta-anuncio.md`.

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.16.0 da
branch `porta-anuncio` em `acd5266`, reinstalado com `claude plugin uninstall
audora-commander@audora-commander-dev && ./install.sh`; `diff -rq
--strip-trailing-cr` de `skills/`, `hooks/` e `templates/` contra
`<cache>/0.16.0` → iguais. Ferramenta: `claude -p` (CLI 2.1.284, Constituição
`ferramenta-e2e`), `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1`, `--output-format
stream-json --verbose --permission-mode acceptEdits`. Suíte:
`SUITE_TIMEOUT=600 bash tests/run.sh` → exit 0, 284 s
(`test-porta-anuncio.sh` PASS=142). A 1ª tentativa da suíte, com a máquina
carregada (489 s), reprovou só o teto de tempo `porta-anuncio/7 transcript de
20001 linhas em 18s (teto 10)`; sozinho e na 2ª suíte, verde.

## Receita (regressão)

`run.sh <cenário>` no scratchpad da sessão; fixture = projeto-base dos evals
(`tests/evals/_lib/projeto-base.sh`), git próprio, `core.autocrlf false`, nó
`velho` in-progress fora do índice (exceto `s1*`; `s12` também cai no padrão
`s1*` e roda sem `velho`, sem efeito no /12).

```text
s1a-c 3 runs do prompt do caso porta (MEDIUM), fluxo real da porta → /1, /7, /8
s2   TESTE DE HOOK: Write notas.md com o anúncio, depois nó novo   → /7, /10 (input de ferramenta)
s3   TESTE DE HOOK: nó planned, in-progress fora da pasta, Edit e
     Write de nó existente                                         → /9
s4   TESTE DE HOOK: Write do nó novo, MEMORY sem memory-schema: 1  → /9
s5   turno 1 só texto com o anúncio; turno 2 (--resume) Write nó    → /10 (antes do humano)
s6   TESTE DE HOOK: anúncio em texto (104 chars), depois Write do nó → /8
s11  hooks/anuncio-guard do cache por stdin: transcript ausente,
     só lixo, e controle sem anúncio                               → /11
s12  TESTE DE HOOK: anúncio em texto de 185 chars, depois Write nó  → /12
```

Evals (traces no scratchpad, fora do repo): `--completo --runs 6 --caso
porta`, `--mutar porta-anuncio --runs 3`, rápida `escopo-antes memoria tdd`.

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| `porta-anuncio/1` — anúncio ≤ 150 chars antes de registrar o nó | s1a-c + 6 traces do /4 | ordem e conteúdo certos em 9/9 (anúncio antes do 1º Write do nó, scope pela Skill). Tamanho: s1a-c em `text` com 171, 180 e 175 chars (0 recusa); /4: 5 runs só em narração de 211–250 chars ("Classifiquei a demanda como MEDIUM, já que … — me avise se discordar"); 1 run em `text` de 104 chars, escrito depois de recusa do hook. Dentro do teto: 1/9 | **falhou** (teto) |
| `porta-anuncio/2` — grader reprova sem anúncio (texto/narração) ou depois do 1º registro | suíte | `test-porta-anuncio.sh` PASS=142, `test-evals-graders.sh` PASS=244 | passou (suíte) |
| `porta-anuncio/3` — anúncio só na skill carregada reprova | suíte | idem | passou (suíte) |
| `porta-anuncio/4` — `--completo --runs 6 --caso porta` 6/6 com e 0/6 sem | `bash tests/evals.sh --completo --runs 6 --caso porta --traces …` | `REPROVOU · porta · com 5/6 · sem 0/6 · Δ +83 pp · US$ 1.6413 · tokens 1591815 · motivo: categoria: pattern not found in trace`, exit 1. Run `uuKwjh`: narração "… — avise se discordar" (sem "me") → hook recusa o Write → modelo escreve em `text` "Demanda classificada como MEDIUM porque envolve vários arquivos e lógica nova — me corrija se discordar." (104) → nó gravado → scope. O grader conta o Write recusado como 1ª escrita e reprova | **falhou** |
| `porta-anuncio/5` — mutação registrada no nó | `bash tests/evals.sh --mutar porta-anuncio --runs 3` | `com a regra 3/3 · sem a regra 0/3 · efeito -100 pp`, `US$ 0.9885 · tokens 1238016`, exit 0; linha no nó (`## decisoes`) | passou |
| `porta-anuncio/6` — escopo-antes, memoria e tdd seguem PASSOU | `bash tests/evals.sh --caso escopo-antes --caso memoria --caso tdd --traces …` | `PASSOU · escopo-antes · com 1/1`, `PASSOU · memoria · com 1/1`, `PASSOU · tdd · com 1/1`, `US$ 0.4478`, exit 0 (sem rerun) | passou |
| `porta-anuncio/7` — nó novo sem anúncio é recusado com a frase-modelo e o teto | s2, s5b, s11, /4 `uuKwjh` | `anuncio-guard: antes de registrar o nó, escreva ao humano, em texto (não no raciocínio), em até 150 caracteres, o anúncio da porta: "Demanda classificada como <CATEGORIA> porque <motivo curto> — me corrija se discordar." …`; s2 `media.md` fora do disco | passou |
| `porta-anuncio/8` — anúncio em texto deixa passar | s6, s1a-c, /4 `uuKwjh` | s6: `text(104)` → Write do nó, `SEM RECUSA`, `media.md` no disco; s1a-c 0 recusa | passou |
| `porta-anuncio/9` — Edit, nó existente, outro estado, fora da pasta, sem schema passam | s3, s4 | s3: Write `plan.md` (planned), Write `docs/notas/media.md`, Edit e Write de `velho.md` → 4 gravados, 0 recusa, `SEM RECUSA`; s4: nó gravado, `SEM RECUSA` | passou |
| `porta-anuncio/10` — anúncio fora da janela não conta | s2, s5 | s2: anúncio só no input do Write de `notas.md` → recusa; s5a texto só com o anúncio, s5b (`--resume`, nova mensagem do humano) → recusa, nó fora do disco | passou |
| `porta-anuncio/11` — transcript ausente/ilegível passa | s11 | `nao-existe.jsonl: exit=0 saida=[]`, `lixo.jsonl: exit=0 saida=[]`; controle sem anúncio `exit=2` | passou |
| `porta-anuncio/12` — anúncio > 150 em texto passa | s12 | `text(185)` → Write do nó, `SEM RECUSA`, `media.md` no disco | passou |
| `porta-anuncio/13` — `--runs` com `--completo` | /4 real; `bash tests/evals.sh --runs 2 --caso porta` | /4 rodou 6 por braço (`com 5/6 · sem 0/6`); sem `--completo`: `evals: --runs só vale com --mutar ou --completo`, exit 4 | passou |

## Achado

1. O teto de 150 não é cumprido: o modelo põe no `<motivo curto>` a lista
   das respostas de risco ("sem migração, API externa, auth ou efeito
   irreversível"). Em 3/9 o anúncio chegou como `text` (171–180, abaixo dos
   ~200 da narração); em 5/9 virou narração e o ramo narração do grader e do
   hook segurou o fluxo.
2. O grader `categoria` trata Write recusado pelo hook como 1ª escrita. O
   caminho de recuperação que o hook induz (recusa → anúncio em texto →
   Write) reprova sempre no eval, embora o nó só chegue ao disco depois do
   anúncio.
