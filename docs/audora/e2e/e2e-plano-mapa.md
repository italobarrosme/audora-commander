# E2E — plano-mapa (2026-10-01)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.12.0 da
branch `plano-mapa` em `6c7499c`, carregado por sessão com
`--plugin-dir <repo>` e o plugin instalado desligado só naquela sessão
(`--settings '{"enabledPlugins":{"audora-commander@audora-commander-dev":false}}'`).
O cache global não foi tocado. Ferramenta: `claude -p` (CLI 2.1.284,
Constituição `ferramenta-e2e`), binário `~/.local/bin/claude.exe`.

## Receita (regressão)

1. **Fixture**: a mesma demanda `slug` da medição A/B (`## medicao` do nó):
   CLI bash `txt.sh` + `lib/texto.sh` (219 linhas antes do slug), registro de
   comandos em `txt.sh` (`COMANDOS` + `case`), nó `slug` MEDIUM com escopo
   aprovado. Clone das fixtures do A/B no commit do plano, com **`main` como
   única branch** (ver armadilha abaixo), `core.excludesFile` inexistente.
   - **E1c**: `fx-a` em `318d0e7`, plano no formato antigo (código completo do
     teste), gerado pelo plugin 0.11.0.
   - **E2**: `fx-b` em `da8934c` (plano-mapa) + commit que insere 40 linhas
     em `lib/texto.sh` depois da linha 37: todo `caminho:linha` do mapa
     abaixo disso fica deslocado.
   - **E3**: `fx-b` em `da8934c` com o plano reescrito sem `txt.sh` no mapa
     (header, pontos de mudança, `ler`, commits) e `slug/4` tirado do nó;
     `slug/1` continua exigindo `txt.sh slug` funcionando.
   - **E4**: `fx-b` em `a51c7a2` (slug pronto) + commit que tira o
     `s/-*$//` do `sed` de `slug`: `slug 'Ola Mundo!'` → `ola-mundo-`.
2. **Sessão**:
   `claude.exe -p "<prompt>" --plugin-dir <repo> --settings '<acima>' --permission-mode acceptEdits --output-format stream-json --verbose > X.jsonl 2> X.err`,
   em background. Prompt `execute de slug` (E1c, E2, E3); E4: "Use a skill
   debug do audora-commander, modo sintoma: `bash txt.sh slug 'Ola Mundo!'`
   imprime `ola-mundo-` … Ache a causa raiz e corrija."
3. **Leitura**: `resumo.pl` extrai do `.jsonl` cada `tool_use` (Read com
   `offset`/`limit`, Edit, Bash, Skill), os textos e o evento `result`;
   depois o disco da fixture (`git log`, `git status`, `bash tests/run.sh`).

Armadilha: `git clone` de fixture cuja HEAD estava numa branch de feature
traz essa branch com o trabalho pronto. A 1ª rodada do E1 achou a execução
anterior em `feat/slug` e só reverificou — descartada e refeita como E1c,
apagando toda branch que não seja `main`.

## Critérios × evidência

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| plano-mapa/1: tarefa é mapa, sem corpo de teste nem de implementação | leitura do plano B do A/B + suíte | `plano-slug.md` de `fx-b` (`da8934c`): cada tarefa tem requisito, ponto de mudança `caminho:linha`, teste, asserções, `ler`, done; nenhum bloco de código. Na execute (E2) o teste nasceu do caso e das asserções do mapa | passou |
| plano-mapa/2: asserção exata quando o critério deixa o valor aberto | leitura do plano B | `slug/2` → `exit 2; stderr erro: slug exige um texto; stdout vazio`; `slug/3` → mensagem fixada `erro: slug exige ao menos uma letra ou número` | passou |
| plano-mapa/3: header lista cada leitura como `caminho:início-fim` | leitura do plano B + `plan-b.jsonl` | Header lista `txt.sh:1-35`, `lib/texto.sh:1-37`, `:78-122`, `:169-219`, `tests/run.sh:1-35` com o relevante de cada uma. **Ressalva**: a sessão de plan leu `lib/texto.sh` INTEIRO (Read sem offset) e registrou trechos — o critério pede o registro, não a leitura parcial no plan | passou (com ressalva) |
| plano-mapa/4: pergunta ampla → subagente de exploração conferido | `plan-b.jsonl` | Nenhum `Agent` na sessão: a fixture é pequena e não houve pergunta ampla. Só a guarda de texto (`test-plano-mapa`) | não-automatizável (validação humana) |
| plano-mapa/5: execute lê os trechos do mapa; > 200 linhas nunca inteiro | E2, E1c, `exec-b` do A/B | E2 (`lib/texto.sh` 259 l.): `limit=37`, `offset=150 limit=15`, `offset=209 limit=10`. E1c (219 l.): `limit=30`, `offset=76 limit=50`. Nenhum Read inteiro | passou |
| plano-mapa/6: fora do mapa, busca do símbolo e leitura do trecho | E2, E1c | E2: `grep -n '^[a-z_]*()'` antes de ler; E1c: `Grep ^truncar\(\)\|^[a-z_]+\(\)` e depois `offset=76` | passou |
| plano-mapa/7: ligação de import/registro/config é seguida | E3 | O mapa não tinha `txt.sh`; a execute leu `txt.sh` (registro `COMANDOS` + `case`) e apontou que `slug/1` depende da linha do `case` | passou |
| plano-mapa/8: na 3ª leitura fora do mapa, anota no mapa e segue | — | Nenhum cenário passou de 2 leituras fora do mapa numa tarefa. Só a guarda de texto | não-automatizável (validação humana) |
| plano-mapa/9: modificar fora do mapa → parar e voltar ao plan para a etapa | E3 | Antes de qualquer código, chamou `Skill audora-commander:plan` com "replanejar só a Tarefa 1 … mapa não inclui txt.sh"; reescreveu só a Tarefa 1 e parou com a decisão humana pendente. `git status`: só plano e nó alterados, `txt.sh` e `lib/texto.sh` intocados | passou |
| plano-mapa/10: `caminho:linha` desatualizado → relocalizar por símbolo e corrigir o mapa | E2 | "Último commit (pós-plano) adicionou 40 linhas … Relocalizo por símbolo"; achou `truncar` 154 e `_so_alnum` 214; commit `3122d26 docs(slug): mapa do plano realinhado após refactor da seção Medida (+40 linhas)`; arquivo nunca lido inteiro | passou |
| plano-mapa/11: plano no formato antigo é executado sem pedir conversão | E1c | Execute de `plano-slug.md` do 0.11.0: red `19/10` → green, red `31/4` → green, commits `7d4906f` e `822b903`; suíte da fixture `PASS=35 FAIL=0`, exit 0; 0 menções a conversão | passou |
| plano-mapa/12: debug sintoma localiza como a execute; caçada intocada | E4 + suíte | `lib/texto.sh` (235 l.) lido só por `sed -n 120,145p`; `tests/run.sh` com `offset=20 limit=15`; causa raiz pelo diff `a3f28e4`; red 35/2 → green 37/0. Caçada: `test-plano-mapa` (asserts da seção) | passou |
| plano-mapa/13: medição A/B registrada no nó | leitura | `## medicao` do nó com linhas/bytes dos 2 planos, tokens das 2 execute e o verde da `fx-b` (36/36) | passou |
| plano-mapa/14: carga BASE/FULL dentro dos tetos | gate nesta sessão | `carga MEDIUM (bytes): base=47719 full=52959 — tetos 48000 / 53400` | passou |
| plano-mapa/15: versão 0.12.0 nos 2 manifests | leitura + suíte | `"version": "0.12.0"` em `plugin.json` e `marketplace.json`; reinstalar pelo cache ficou fora (branch não mergeada) | passou (sem reinstalar) |

## Custo

| sessão | turnos | US$ |
|---|---|---|
| E1 (descartada) | 29 | 0,92 |
| E1c | 29 | 0,75 |
| E2 | 42 | 1,08 |
| E3 | 31 | 1,00 |
| E4 | 15 | 0,53 |

As 5 sessões terminaram com exit 0.
