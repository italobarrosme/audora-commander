# E2E — porta-anuncio (2026-10-12)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.16.0 da
branch `porta-anuncio` em `36c8508`, reinstalado com `claude plugin uninstall
audora-commander@audora-commander-dev && ./install.sh`; `diff -rq
--strip-trailing-cr` de `skills/`, `hooks/` e `templates/` contra
`<cache>/0.16.0` → iguais (a sessão roda da pasta do repo: marketplace local).
Ferramenta: `claude -p` (CLI 2.1.284, Constituição `ferramenta-e2e`),
`CLAUDE_CODE_DISABLE_CLAUDE_MDS=1`, `--output-format stream-json --verbose
--permission-mode acceptEdits`. Suíte antes do e2e: `SUITE_TIMEOUT=600 bash
tests/run.sh` → exit 0, 22 arquivos, 1900 asserts (`test-porta-anuncio.sh`
PASS=136).

## Receita (regressão)

`run.sh <cenário>` no scratchpad da sessão de validate; fixture = projeto-base
dos evals (`tests/evals/_lib/projeto-base.sh`), git próprio, `core.autocrlf
false`, nó `velho` in-progress fora do índice (exceto s1).

```text
s1   prompt do caso porta (MEDIUM), fluxo real da porta            → /1, /7, /8
s2   TESTE DE HOOK: Write notas.md com o anúncio, depois nó novo   → /7, /10 (input de ferramenta)
s3   TESTE DE HOOK: nó planned, in-progress fora da pasta, Edit e
     Write de nó existente                                         → /9
s4   TESTE DE HOOK: Write do nó novo, MEMORY sem memory-schema: 1                         → /9
s5   turno 1 só texto com o anúncio; turno 2 (--resume) Write nó    → /10 (antes do humano)
s6   TESTE DE HOOK: anúncio em texto, depois Write do nó            → /8
s11  hooks/anuncio-guard do cache por stdin: transcript ausente,
     só lixo, e controle sem anúncio                               → /11
```

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| `porta-anuncio/1` — porta escreve o anúncio antes de registrar o nó | s1, 2 runs reais | run A (fixture com `velho` fora do índice): narração `Classifiquei a demanda como MEDIUM — … Agora vou registrar o nó.` (sem convite) → recusa; 2ª narração `… Me avise se discordar da classificação.` → nó gravado; o `memory-validate` acusou `velho` e o modelo parou antes do scope (fixture). Run B (limpa): o modelo diz ter escrito a frase literal, mas o trace só tem narração — `Classifico a demanda como MEDIUM: … — mas me avise se considerar bin/estat um contrato crítico…` (sem `discordar`) → recusa; `Reenvio a classificação em texto simples … demanda MEDIUM, pois …` (sem `classific… como`) → recusa; o modelo desfaz a linha do índice, escreve o anúncio só no texto final e para pedindo decisão; nó não registrado, scope não começa | **falhou** |
| `porta-anuncio/2` — grader reprova sem anúncio (texto/narração) ou depois do 1º registro | suíte | `test-porta-anuncio.sh` PASS=136, `test-evals-graders.sh` PASS=244 | passou (suíte) |
| `porta-anuncio/3` — anúncio só na skill carregada reprova | suíte | idem | passou (suíte) |
| `porta-anuncio/4` — `--completo --caso porta` 3/3 com e 0/3 sem | `bash tests/evals.sh --completo --caso porta` | `REPROVOU · porta · com 1/3 · sem 0/3 · Δ +33 pp · US$ 0.8409 · tokens 823455 · motivo: categoria: pattern not found in trace`, exit 1 | **falhou** |
| `porta-anuncio/5` — mutação registrada no nó | `bash tests/evals.sh --mutar porta-anuncio --runs 3` | `com a regra 3/3 · sem a regra 0/3 · efeito -100 pp`, `US$ 0.9826 · tokens 1241915`, exit 0 | passou |
| `porta-anuncio/6` — escopo-antes, memoria e tdd seguem PASSOU | `bash tests/evals.sh --caso escopo-antes --caso memoria --caso tdd` | `PASSOU · escopo-antes`, `PASSOU · memoria`, `REPROVOU · tdd · com 0/1 · US$ 0.0336 · tokens 22914 · motivo: faltou teste novo`, exit 1 (run curto, perfil do `retomada-execute`; trace não guardado) | **falhou** |
| `porta-anuncio/7` — nó novo sem anúncio é recusado com a frase-modelo | s2, s5b, s1 | s2: anúncio só no input do Write de `notas.md` → `anuncio-guard: antes de registrar o nó, escreva ao humano, em texto (não no raciocínio), o anúncio da porta: "Demanda classificada como <CATEGORIA> porque … — me corrija se discordar." Depois repita esta escrita.`; `media.md` fora do disco | passou |
| `porta-anuncio/8` — anúncio em texto deixa passar | s6 | bloco `text` `Demanda classificada como MEDIUM porque toca vários arquivos e há lógica nova — me corrija se discordar.` → Write do nó, `SEM RECUSA`, `media.md` no disco | passou |
| `porta-anuncio/9` — Edit, nó existente, outro estado, fora da pasta, sem schema passam | s3, s4 | s3: Write `plan.md` (planned), Write `docs/notas/media.md`, Edit e Write de `velho.md` → todos gravados, 0 `anuncio-guard:`; s4: nó in-progress gravado, `SEM RECUSA` | passou |
| `porta-anuncio/10` — anúncio fora da janela não conta | s2, s5 | s5a texto só com o anúncio; s5b (`--resume`, nova mensagem do humano) → recusa, nó fora do disco | passou |
| `porta-anuncio/11` — transcript ausente/ilegível passa | s11 | `nao-existe.jsonl: exit=0 saida=[]`, `lixo.jsonl: exit=0 saida=[]`; controle sem anúncio `exit=2` | passou |

## Achado

A prosa do modelo entre ferramentas chega ao transcript como narração (resumo
do servidor). O resumo parafraseia livre — perde `porque`, troca `me corrija
se discordar` por outra coisa ou some com `classific… como` —, e o contrato
"por sentido" ainda exige essas palavras. O hook então recusa um anúncio que
o modelo de fato escreveu, a mensagem manda "escrever em texto" (que vira
narração de novo) e o fluxo trava. Reproduz o /4 (1/3) e explica a diferença
para o 3/3 da execute: variância da paráfrase do servidor.
