# E2E — gitignore-padrao (2026-10-26, 2 rodadas)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin do repo em
`7938cab` (main), carregado por `--plugin-dir` numa sessão isolada como os
evals (HOME, `CLAUDE_CONFIG_DIR` e TEMP temporários, `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1`,
token do `.env`). Ferramenta: `claude -p` (CLI 2.1.310, Constituição
`ferramenta-e2e`), `--model opus`, `--output-format stream-json --verbose
--permission-mode dontAsk`, `--allowedTools ... "Edit(./**)" "Write(./**)" Bash`,
turnos seguintes por `--resume`. Custo: ~US$ 4,1 (soma dos turnos).

## Receita (regressão)

Scripts no scratchpad da sessão (fora do repo): `fixture.sh <cenário> <dir>`,
`run.sh <cenário> <turno> "<prompt>"` (turno `nX` = sessão nova no mesmo
workspace), `analisa.pl <turno.jsonl>`. Projetos sob `ws/<cenário>/cwd`.

```text
A  projeto novo, git, sem MEMORY        → t1 bootstrap (dados no prompt, gate recusado)       /1 /2 /3
B  existente, git, 3 arquivos versionados em specs/planos/e2e → t1 bootstrap · t2 "sim"     /1 /8
B2 idem B + pre-commit que sai 1         → t1 bootstrap · t2 "sim"                            /9
C  projeto-base dos evals (MEMORY sem versionamento:) → t1 carregar-contexto · t2 "não" · n3 sessão nova  /4 /5
D  idem C + .gitignore `docs/` + .git/info/exclude `CHANGELOG.md` → t1 contexto · t2 "sim" · t3 "sim, comenta"  /4 /6 /7
E  projeto novo SEM git                  → t1 bootstrap                                        /10
F  nó grafico in-progress, bloco aplicado, ferramenta-e2e bash → t1 "e2e de grafico"         /11 /12 /13
G  nó subtrai in-progress, spec/plano/e2e só no disco → t1 "validate de subtrai" · t2 "Aprovado."  /14
H  nó velho delivered com sobras locais + nó vivo in-progress com sobras → t1 cleanup · t2 aprova sem a spec · t3 lote em ./  /15 /16 /17
```

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| `gitignore-padrao/1` — bootstrap escreve o bloco sem perguntar e registra `versionamento: aplicado` | A t1, B t1 | A: `.gitignore` = as 6 linhas do bloco, Constituição `- **versionamento**: aplicado`, nenhuma pergunta sobre o `.gitignore`; B idem, com `.gitignore` novo | passou |
| `gitignore-padrao/2` — bloco presente não duplica nem altera o resto | script no projeto de A depois do bootstrap | `aplicar` → `bloco do audora já presente — .gitignore intocado`, md5 igual | passou |
| `gitignore-padrao/3` — memória versionada e resto de `docs/audora/` seguem versionáveis | `git check-ignore --no-index` no projeto de A | MEMORY, PRD, CHANGELOG, memory/, arquivo/, aprendizados, decisões vivas, validacao/ versionáveis; specs/, planos/, e2e/x/s.png, depuracao/ ignorados | passou |
| `gitignore-padrao/4` — oferta única MOSTRANDO o que passa a ser ignorado | C t1, D t1 | oferta veio 1 vez, mas só "pastas temporárias de `docs/audora/`": sem as 4 pastas, sem rodar o `checar` (nenhum Bash no turno; a reference `versionamento.md` não foi lida) | **reprovou** |
| `gitignore-padrao/5` — recusa registra e não reoferta | C t2, C n3 | t2: `- **versionamento**: recusado` na Constituição; n3 (sessão nova): "o gate e o versionamento já foram recusados, então não há nada a ofertar" | passou |
| `gitignore-padrao/6` — memória ignorada: regra (arquivo e linha), o que quebra, ajuste só com sim | D t2, D t3 | t2: saída do `checar` com `regra .gitignore:1 docs/` e a linha `quebra:`, "Comento?"; t3 (sim): linha 1 vira `# desligado pelo audora-commander: docs/`. Na oferta (t1) o aviso não veio — mesma causa do /4 | passou (depois do sim) |
| `gitignore-padrao/7` — regra de fora do projeto: nomeia e não edita | D t2, D t3 | "`.git/info/exclude:1` (`CHANGELOG.md`) fica fora dos arquivos do projeto, não vou mexer"; exclude intocado depois do t3 | passou |
| `gitignore-padrao/8` — lista versionados nas pastas efêmeras; com sim, commit só com remoções + `.gitignore` | B t1, B t2 | t1 lista os 3 e pergunta; t2: `383fded chore(audora): tira spec, plano, e2e e caçada do git (ficam no disco)` = `A .gitignore` + `D` dos 3; os 3 no disco | passou |
| `gitignore-padrao/9` — commit falha → desfaz e avisa | B2 t2 | "O hook `pre-commit` recusou… O script desfez as remoções"; HEAD = `init`, 3 ainda no `git ls-files`, índice vazio | passou |
| `gitignore-padrao/10` — fora do git: bloco escrito, aviso em 1 linha | E t1 | `.gitignore` com o bloco; "Como a pasta não é um repositório git, a checagem das regras do `.gitignore` não rodou." | passou |
| `gitignore-padrao/11` — `## e2e` do nó com 1 linha por critério + relatório como `local:` | F t1 | `- grafico/1 · passou · …`, `- grafico/2 · passou · …`, `relatório: local: docs/audora/e2e/e2e-grafico.md` | passou |
| `gitignore-padrao/12` — evidência binária em `docs/audora/e2e/` | F t1 | `docs/audora/e2e/grafico/saida.png` + `saida-terminal.txt` (ignorados pelo git) | passou |
| `gitignore-padrao/13` — memória versionada cita pasta efêmera só como `local:` | F t1, G t2 | nó de F sem link para `docs/audora/e2e/`; G: nó arquivado e CHANGELOG sem link para spec/plano/e2e | passou |
| `gitignore-padrao/14` — sync arquiva com spec, plano e e2e fora do git | G t2 | `git mv` do nó para `docs/audora/arquivo/2026-10-26-subtrai.md`, plano em `planos/arquivo/` só no disco, commit do sync sem pasta efêmera, cartão `**Arquivos** — 6 arquivos · +51 −2` | passou |
| `gitignore-padrao/15` — cleanup lista sobras locais em "sem volta (fora do git)" | H t1 | seção `## sem volta (fora do git)` com caçada, e2e, pasta `e2e/velho/` (2 arquivos), plano arquivado e spec de `velho`; aviso "nem `git revert` traz de volta" | passou |
| `gitignore-padrao/16` — aprova → apaga do disco respeitando retirada | H t2, H t3 | t2 travou no harness (lote gravado fora do cwd, `dontAsk` bloqueou); t3: `cleanup: 4 sobra(s) local(is) apagada(s) do disco — sem volta`, `specs/velho-escopo.md` mantida, sem commit | passou |
| `gitignore-padrao/17` — nó vivo nunca listado | H t1, H t3 | spec, plano, e2e e `e2e/vivo/x.png` do nó `vivo` (in-progress) fora do relatório e intactos depois do `aplicar` | passou |

## Rodada 2 (depois do debug, `041892f`)

Causa raiz (debug, modo sintoma): o item 7 da carregar-contexto bastava para
"ofertar" e citava `references/versionamento.md` só entre parênteses — 0 de 2
sessões leram a reference, então o `checar` nunca rodou e o contrato da oferta
(4 pastas + saída do `checar`) não chegou ao humano. Refutadas: modelo leu e
ignorou (zero leituras no trace); Bash bloqueado (rodou em D t2). Fix: o item 7
manda ler a reference e rodar o `checar` ANTES de ofertar.

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| `gitignore-padrao/4` | C t1, D t1 (fixtures novas) | as duas leram `versionamento.md` e rodaram `versionamento checar`; C listou `docs/audora/specs/`, `planos/`, `e2e/`, `depuracao/` + `bloco: ausente` / `0 regra(s)…` e perguntou 1 vez | passou |
| `gitignore-padrao/6` | D t1 | a oferta já avisou "Regra `docs/` na linha 1 do `.gitignore`: esconde `docs/audora/memory/`… Isso quebra o arquivamento…" e perguntou se comenta | passou (na oferta) |
| `gitignore-padrao/7` | D t1 | "`CHANGELOG.md` está ignorado por `.git/info/exclude:1`, que fica fora do projeto. Não vou editar" | passou |

Resultado final: 17/17.

Observações fora dos critérios:
- F respondeu o 1º parágrafo em inglês ("Ran grafico end to end…").
- G commitou o sync com trailer `Co-Authored-By` (fixture sem regra do usuário; não é do plugin).
- H t2: limite do harness, não do plugin — a sessão `dontAsk` só escreve em `./**`.
