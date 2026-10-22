# E2E — entrega-clara (2026-10-22, 2 rodadas)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin do repo em
`fcfcaef` (main), carregado por `--plugin-dir` numa sessão isolada como os
evals (HOME, `CLAUDE_CONFIG_DIR` e TEMP temporários, `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1`,
token do `.env`) — o plugin instalado no cache não entra. Ferramenta:
`claude -p` (CLI 2.1.308, Constituição `ferramenta-e2e`), `--model opus`,
`--output-format stream-json --verbose --permission-mode dontAsk`, turnos
seguintes por `--resume`. Custo: US$ 3,57 (último turno de cada sessão).

## Receita (regressão)

Scripts no scratchpad da sessão (fora do repo): `fixture.sh <cenário>`
(projeto-base dos evals + nó, plano, PRD, CHANGELOG e commits), `run.sh
<cenário> <turno> "<prompt>"`, `analisa.sh <jsonl>` (blocos do turno e texto
final). Turno 1 de todos: `validate de <id> — o e2e eu dispenso, pode pular.`

```text
A  MEDIUM demo na main, 3 critérios, delta, 1 decisão (IA) no nó + 2 no plano,
   commit docs(outra) no meio            → t2 "Aprovado..."            /1–/11 /15
B  idem em branch feat/demo              → t2 "Aprovado..." · t3 "1"   /12
C  idem A                                → t2 "Reprovado: demo/2 ..."  /13 /10
D  LIGHT ajuste, commits sem escopo      → t2 "1" (aprova)             /1 LIGHT
E  idem D                                → t2 "Reprovado: ajuste/1 ..." /13 LIGHT
F  idem A                                → t2 aprovação parcial         /13 parcial
G  idem A com commits sem escopo (demo)  → t2 "Reprovado: demo/2 ..."  /14
```

Contagem de referência (comando do template rodado à mão na fixture):
A/B/C/F antes do sync `5 arquivos · +87 −0` (sem o commit `docs(outra)`);
A depois do sync `8 arquivos · +112 −2`; G vazio.

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| `entrega-clara/1` — portão aprovado, qualquer categoria, cartão `## 🏁 DONE — <id>` no lugar do bloco de fase + relatório | A t2, B t2, D t2 | A e B: texto final abre com `---` + `## 🏁 DONE — demo`, sem bloco de fase nem relatório. D (LIGHT): cartão completo, mas título `## 🏁 DONE: ajuste` (dois-pontos no lugar do travessão) | passou (desvio de pontuação em D) |
| `entrega-clara/2` — linha de estado | A, B, C, D, F, G | `MEDIUM · 3/3 critérios · na main`; B `· na branch feat/demo`; D `LIGHT · 1/1 critério · na main` | passou |
| `entrega-clara/3` — O que mudou, 1 a 3 bullets de usuário | A, B, D | A 2 bullets ("`subtrai <a> <b>` agora existe..."), B 1, D 1 | passou |
| `entrega-clara/4` — Como foi: trilha em ordem, ≤ 8 palavras, e2e rodado/pulado | A, B, C, D, F, G | A: 5 linhas scope→validate, `e2e: pulado a seu pedido`; D (LIGHT): `execute → e2e → validate`, sem scope/plan | passou |
| `entrega-clara/5` — Ressalvas, 1 linha cada ou "nenhuma" | A, B, D, G | A `**Ressalvas**: o e2e foi pulado a seu pedido.`; G inclui "commits sem o escopo `(demo/N)`" | passou |
| `entrega-clara/6` — Mudanças no caminho do `## delta`; omitida sem delta | A, B, C, D | A/B/C: a linha `MODIFICADO (2026-10-20)` do nó; D (delta vazio): seção ausente | passou |
| `entrega-clara/7` — Por critério: todos, endereço, ícone + palavra | A, C, F | A `demo/1..3` ✅ entregue; C `demo/2` ❌ reprovado com motivo; F ✅/❌ | passou |
| `entrega-clara/8` — Evidência e Decisões da IA em 1 linha | A, B, D | A `3/3 critérios ... 0 testes falhando, exit 0 ... roteiro do portão` e `**Decisões da IA**: 3, revisadas no portão` (2 do plano + 1 `(IA` do nó) | passou |
| `entrega-clara/9` — Como conferir ligado a critério, ` ```text ` | A, B, D | A: 3 itens `demo/1..3` com code block text | passou |
| `entrega-clara/10` — Arquivos em 1 linha do numstat real da demanda | A, B, D, F, C | A `8 arquivos · +112 −2` = referência; B e F `5 arquivos · +87 −0` = referência (sem `notas-outra`). **C** (reprovado): `2 arquivos · +15 −0`, sem rodar o comando — somou os 2 commits `feat` do `git show` e deixou de fora nó, plano e MEMORY. D: comando achou só o commit do sync (commits sem escopo) e o cartão explicou o limite | falhou na 1ª rodada (C) → **passou** na 2ª (C ×3) |
| `entrega-clara/11` — rodapé Memória quando o sync rodou; sem resumo do sync fora | A, D, B t3, F | A/D: `**Memória**:` nó arquivado · PRD · CHANGELOG +1 · decisões vivas · sobras; nenhum texto fora do cartão no turno. F (parcial, sync parcial): parágrafo antes do cartão sobre PRD/CHANGELOG retidos | passou (desvio em F) |
| `entrega-clara/12` — branch: DONE + Próximo pergunta o merge; aceito → merge, sync, 1 linha | B t2, B t3 | t2: `> ⏸️ **Próximo**: fazer o merge na main agora?` + `1. sim` / `2. não: fica na branch feat/demo`; t3 ("1"): merge `3e5e17d` + sync `40e6732`, resposta de 1 parágrafo com a linha Memória, sem segundo cartão | passou |
| `entrega-clara/13` — reprovado/parcial: `❌ NÃO ENTREGUE` / `⚠️ PARCIAL`, motivo por critério, Próximo na fase de retorno, sem DONE | C, G, F, E | C e G: `## ❌ NÃO ENTREGUE — demo`, `demo/2` ❌ com motivo, Próximo `scope de demo`; F: `## ⚠️ PARCIAL — demo`, Próximo PARADA → `scope de demo` (metade da prosa em inglês). **E** (LIGHT): invocou a skill scope no mesmo turno, reabriu o escopo e fechou com o bloco de fase do scope — cartão não saiu | falhou na 1ª rodada (E) → **passou** na 2ª (E ×3) |
| `entrega-clara/14` — dado sem fonte → `[SEM FONTE]`, nunca de memória | G | `**Arquivos**: [SEM FONTE]` + ressalva "commits sem o escopo `(demo/N)`"; não rodou o comando, deduziu do `git log --stat` — não inventou número | passou |
| `entrega-clara/15` — cartão é a última parte do turno | A, B, C, D, F, G | último bloco do assistente = `text` com o cartão, nenhum `tool_use` depois, nos 6 | passou |

## Observações fora dos critérios

- B, F e G abrem o turno do cartão com 1–2 parágrafos de prosa antes da régua
  (registro da decisão, explicação do sync parcial ou da reprovação).
- F escreveu metade do cartão em inglês sem pedido.
- A pôs o hash do commit do sync no rodapé Memória (fora-de-escopo do nó: não
  pedido, não proibido).

## Teardown

Sem processo de longa duração: cada `claude -p` saiu (rc=0 nos 15 turnos);
workspaces e traces ficam no scratchpad da sessão, fora do repo.

## Rodada 2 — depois do debug (`fc1a001`)

Causa raiz no nó (debug 2026-10-22). Reprodução no HEAD anterior, antes do
fix: E ×2 → 1 emendou o scope (Er2), 1 imprimiu o cartão; C ×2 → os 2 rodaram
o comando (falha de C era intermitente, 1/3). Fix: item 5 da validate
("Reprovado ou parcial, o turno fecha no cartão em toda categoria (LIGHT
também)…") e regra 9 do template ("Rode-o no turno do cartão, em toda decisão
do portão…"). Rodada nova: cenários E e C, 3 runs cada, mesmos prompts.
Custo: US$ 2,51 (+ US$ 1,59 da reprodução).

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| `entrega-clara/13` — reprovado em LIGHT imprime `❌ NÃO ENTREGUE` | E ×3 (Ef1–Ef3) | 3/3 texto final `## ❌ NÃO ENTREGUE — ajuste`, nenhuma Skill scope no turno, último bloco `text` (antes do fix: 1/3) | passou |
| `entrega-clara/10` — comando de arquivos roda no turno do cartão | C ×3 (Cf1–Cf3) | 3/3 rodaram o comando do template; 3/3 `5 arquivos · +87 −0` = referência | passou |
| `entrega-clara/14` — `[SEM FONTE]` do comando vazio | E ×3 | 3/3 rodaram o comando, saída vazia → `**Arquivos** — [SEM FONTE]` + motivo (commits sem escopo `(ajuste)`) | passou |
| `entrega-clara/13` — reprovado MEDIUM | C ×3 | `## ❌ NÃO ENTREGUE — demo` em Cf1 e Cf3; Cf2 `## ❌ NÃO ENTREGUE: demo` (dois-pontos) | passou (desvio de pontuação em 1/3) |

Desvio de pontuação recorrente (fora de critério de comportamento): título com
`:` no lugar de `—` em 2 de 13 cartões (D, Cf2).
