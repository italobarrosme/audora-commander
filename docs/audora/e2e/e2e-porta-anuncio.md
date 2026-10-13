# E2E — porta-anuncio (2026-10-13, 3ª rodada)

Rodadas anteriores (1ª 2026-10-12: /1, /4, /6 falharam; 2ª 2026-10-13: /1
e /4 falharam) — ver `git log -- docs/audora/e2e/e2e-porta-anuncio.md`.

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.16.0 da
branch `porta-anuncio` em `dde987f`, reinstalado com `claude plugin uninstall
audora-commander@audora-commander-dev && ./install.sh`; `diff -rq
--strip-trailing-cr` de `skills/`, `hooks/` e `templates/` contra
`<cache>/0.16.0` → iguais. Ferramenta: `claude -p` (CLI 2.1.284, Constituição
`ferramenta-e2e`), `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1`, `--output-format
stream-json --verbose --permission-mode acceptEdits`. Suíte:
`SUITE_TIMEOUT=600 bash tests/run.sh` → exit 0, 243 s
(`test-porta-anuncio.sh` PASS=166, `test-evals-graders.sh` PASS=244).

## Receita (regressão)

`run.sh <cenário>` no scratchpad da sessão; fixture = projeto-base dos evals
(`tests/evals/_lib/projeto-base.sh`), git próprio, `core.autocrlf false`, nó
`velho` in-progress fora do índice (exceto `s1*`, que inclui `s12a`/`s12b`,
sem efeito no /12).

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
s12a TESTE DE HOOK: anúncio em texto de 206 chars, depois Write nó  → /12 (> 200)
s12b TESTE DE HOOK: anúncio de 185 chars que enumera os riscos      → /12 (enumera)
```

Evals (traces no scratchpad, fora do repo): `--completo --runs 6 --caso
porta`, `--mutar porta-anuncio --runs 3`, rápida `escopo-antes memoria tdd`.
Anúncio medido por run com perl sobre o trace (tipo do bloco, tamanho de
`classifi…discordar`, presença de `sem …` = enumera respostas de risco).

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| `porta-anuncio/1` — anúncio próprio ≤ 200 chars, motivo único, antes de registrar o nó | s1a-c + 6 traces do /4 | ordem certa em 9/9 (anúncio antes do 1º Write do nó, scope pela Skill, 0 recusa do hook). Motivo único: **1/9** — só `s1c` (`text`, 134: "Demanda classificada como **MEDIUM** porque traz lógica nova em vários arquivos (lib.sh, bin/estat, testes) — me corrija se discordar."). Os outros 8 enumeram as respostas de risco ("sem tocar dado persistido, contrato público, auth ou efeito irreversível"): `s1a` `text` 175; `s1b` narração 187; /4 6/6 em narração, 183–217 (3 acima de 200). Em texto: 2/9 | **falhou** (motivo único) |
| `porta-anuncio/2` — grader reprova sem anúncio (texto/narração) ou depois do 1º registro | suíte | `test-porta-anuncio.sh` PASS=166, `test-evals-graders.sh` PASS=244 | passou (suíte) |
| `porta-anuncio/3` — anúncio só na skill carregada reprova | suíte | idem | passou (suíte) |
| `porta-anuncio/4` — `--completo --runs 6 --caso porta` 6/6 com e 0/6 sem; calibração registrada | `bash tests/evals.sh --completo --runs 6 --caso porta --traces …` | `PASSOU · porta · com 6/6 · sem 0/6 · Δ +100 pp · US$ 1.7032 · tokens 1599091`, exit 0, sem `ISOLAMENTO VIOLADO`; `tests/evals/README.md:94` `REPROVOU 0/6 (com o plugin 6/6, Δ +100 pp)` | passou |
| `porta-anuncio/5` — mutação registrada no nó | `bash tests/evals.sh --mutar porta-anuncio --runs 3` | `com a regra 3/3 · sem a regra 1/3 · efeito -67 pp`, `US$ 0.9519 · tokens 1193889`, exit 0 (T24 da execute: 3/3 · 3/3); linha no nó | passou |
| `porta-anuncio/6` — escopo-antes, memoria e tdd seguem PASSOU | `bash tests/evals.sh --caso escopo-antes --caso memoria --caso tdd --traces …` | `PASSOU · escopo-antes · com 1/1`, `PASSOU · memoria · com 1/1`, `PASSOU · tdd · com 1/1`, `US$ 0.4367`, exit 0 (sem rerun) | passou |
| `porta-anuncio/7` — nó novo sem anúncio recusado com frase-modelo, motivo único e 200 | s2, s5b, s11 | `anuncio-guard: antes de registrar o nó, escreva ao humano, em texto (não no raciocínio), em até 200 caracteres e com um motivo só (o que decidiu a categoria), o anúncio da porta: "Demanda classificada como <CATEGORIA> porque <motivo> — me c…`; s2 e s5b: `media.md` fora do disco | passou |
| `porta-anuncio/8` — anúncio em texto deixa passar | s6, s1a/s1c | s6: `text(104)` → Write do nó, `SEM RECUSA`, `media.md` no disco; s1a-c 0 recusa | passou |
| `porta-anuncio/9` — Edit, nó existente, outro estado, fora da pasta, sem schema passam | s3, s4 | s3: `plan.md`, `docs/notas/media.md`, Edit e Write de `velho.md` ("# velho reescrito") gravados, `SEM RECUSA`; s4: nó gravado, `SEM RECUSA` | passou |
| `porta-anuncio/10` — anúncio fora da janela não conta | s2, s5 | s2: anúncio só no input do Write de `notas.md` (gravado) → recusa do nó; s5a texto só com o anúncio, s5b (`--resume`) → recusa, nó fora do disco | passou |
| `porta-anuncio/11` — transcript ausente/ilegível passa | s11 | `nao-existe.jsonl: exit=0 saida=[]`, `lixo.jsonl: exit=0 saida=[]`; controle sem anúncio `exit=2` | passou |
| `porta-anuncio/12` — anúncio > 200 ou que enumera passa | s12a, s12b | s12a `text(206)` → Write do nó, `SEM RECUSA`; s12b `text(185)` enumerando → `SEM RECUSA`; `media.md` no disco nos dois | passou |
| `porta-anuncio/13` — `--runs` com `--completo` | /4 real; `bash tests/evals.sh --runs 2 --caso porta` | /4 rodou 6 por braço; sem `--completo`: `evals: --runs só vale com --mutar ou --completo`, exit 4 | passou |
| `porta-anuncio/14` — Write recusado por hook não conta como 1ª escrita | suíte | `test-porta-anuncio.sh` PASS=166 (asserções `porta-anuncio/14 categoria: …`); nesta rodada 0 recusa nos 6 runs do /4 — o caminho real não apareceu | passou (suíte) |

## Achado

1. Motivo único não segura: 3ª rodada seguida em que o modelo põe no motivo
   a lista das respostas de risco negativas. O placeholder `<motivo>` + "Um
   motivo só, o que decidiu a categoria, sem enumerar as respostas de risco"
   da 5ª reabertura não mudou a taxa (T23: 0/6; aqui: 1/9).
2. Em 7/9 o anúncio sai como narração (a prosa entre ferramentas vira resumo
   do servidor); o ramo narração do grader e do hook segura o fluxo, e o
   tamanho da narração não é controlável pelo texto da skill.
3. Mutação: o hook recupera o anúncio sem o passo 4 em 1/3 (T24: 3/3) — o
   efeito da regra oscila entre 0 e −67 pp entre rodadas de 3.
