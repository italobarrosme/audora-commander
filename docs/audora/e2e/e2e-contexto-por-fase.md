# E2E — contexto-por-fase (2026-09-29)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.9.0
reinstalado da `main` em `a8f36f8` (`git branch --show-current` → `main`;
`claude plugin uninstall audora-commander@audora-commander-dev` +
`PATH="$HOME/.local/bin:$PATH" ./install.sh`; `claude plugin list` →
`Version: 0.9.0`, enabled; o cache `0.9.0` contém a linha `PARADA: rode
/clear` em `skills/plan/SKILL.md` e na seção `## Parada entre fases` do
template). Ferramenta: `claude -p` (CLI 2.1.284, Constituição
`ferramenta-e2e`), binário `~/.local/bin/claude.exe`. Escopo decidido pelo
humano: e2e enxuto, 3 cenários, cada um numa fixture própria.

## Receita (regressão)

1. **Fixture** (uma por cenário, `F=$(mktemp -d)`, `git init -b main`, 1
   commit `init`): `calc.sh` em bash (`soma`/`sub`, uso inválido sai 2),
   `tests/run.sh` verde (`PASS=3 FAIL=0`), `PRD.md` curto e `MEMORY.md`
   `memory-schema: 1`. A Constituição tem `stack`, `restricoes`, `padroes`,
   `como-rodar: bash tests/run.sh`, `ferramenta-e2e`, `gate: recusado` e
   `graphify: recusado`. O índice tem 1 linha:
   `- historico | in-progress | Histórico de operações | …`. O nó
   `docs/audora/memory/historico.md` fica `estado: in-progress`, com 4
   critérios EARS (`historico/1..4`) e decisões `(IA): MEDIUM …` e
   `(humano): escopo aprovado no portão do scope`. Não há
   `docs/audora/planos/`.
2. **Cache**: `claude plugin uninstall audora-commander@audora-commander-dev`
   e depois `PATH="$HOME/.local/bin:$PATH" ./install.sh` (conferir antes que
   `git branch --show-current` dá `main`).
3. **Sessão**: dentro da fixture, rodar
   `~/.local/bin/claude.exe -p "<prompt>" --permission-mode acceptEdits --output-format stream-json --verbose > out.jsonl 2> err.txt`,
   em background. O prompt é só o comando de retomada, como o humano
   digitaria. Nada diz ao modelo o que esperar.
   - (a) `claude.exe -p "plan de historico" …`
   - (b) `claude.exe -p "execute de historico" …`
   - (c) `claude.exe -p "plan de exportar-csv" …`
4. **Leitura**: ler o `.jsonl` INTEIRO (texto, tool_use e tool_result). Depois
   conferir o disco da fixture: `git log --oneline`,
   `git status --short --untracked-files=all`, `git diff --stat`,
   `grep '^estado' docs/audora/memory/historico.md`.

## Critérios × evidência

| Critério (`<id>/<n>` + EARS) | Passo executado | Evidência | Veredito |
|---|---|---|---|
| contexto-por-fase/1: fim de plan MEDIUM fecha com PARADA (`/clear` + `execute de <id>`) e NÃO inicia a fase seguinte | (a) `plan de historico` na fixture A: 12 turnos, ~125 s | Fim da resposta: `### historico · plan → execute` … `**Próximo** — PARADA: rode /clear e, na sessão nova, \`execute de historico\``. Os únicos Write/Edit da sessão foram para o plano. Disco: `git log` só tem `95abb7b init`. `git status` mostra só `?? docs/audora/planos/plano-historico.md` (170 linhas). `git diff --stat` sai vazio, `calc.sh` e `tests/` ficam intocados, e o nó continua `estado: in-progress` | passou |
| contexto-por-fase/9: `execute de <id>` MEDIUM sem plano-arquivo → recusa nomeando o artefato e aponta a fase certa | (b) `execute de historico` na fixture B: 7 turnos, ~26 s | "Não comecei a execução do historico: falta o plano. O nó é MEDIUM e não existe `docs/audora/planos/plano-historico.md` … Próximo passo é rodar `plan de historico`". Disco: `git status` limpo, `git log` só com `init`, nenhum arquivo criado | passou |
| contexto-por-fase/9: `plan de <id-inexistente>` → recusa nomeando o que falta e aponta a fase certa | (c) `plan de exportar-csv` na fixture C: 8 turnos, ~28 s | "Não fiz o plano. Não existe nó `exportar-csv` … o índice em `MEMORY.md` só tem `historico` … Próximo passo é o **scope** de `exportar-csv`". Disco: `git status` limpo, `git log` só com `init`, nenhum arquivo criado | passou |

Todos os cenários chamaram a skill certa pelo Skill tool
(`audora-commander:plan` / `audora-commander:execute`). O system/init
listava o plugin `audora-commander`, e o SessionStart do framework injetou o
ponteiro. Nenhum cenário escreveu em `~/.calc_historico` (conferido com `ls`).

Os critérios /2–/8 e /10–/13 são de outras transições (entrada, LIGHT, e2e ↔
validate, "segue"/subagente, autopilot, fase reprovada) ou de guarda de
suíte. Ficaram fora do corte enxuto decidido pelo humano. A cobertura deles
está nos asserts de `tests/test-contexto-por-fase.sh` e eles vão para o
roteiro de validação.

## Observações (não reprovam critério)

- **Pontuação divergente entre skill e template.** Em (a) o Próximo saiu no
  formato do template, `na sessão nova, \`execute de historico\`` (com
  vírgula, como na linha 49 de `templates/bloco-fechamento-template.md`). A
  skill plan (item 9) e a skill execute usam `na sessão nova: \`…\``, com
  dois-pontos. O conteúdo exigido pelo /1 está presente (instrução de
  `/clear` + comando exato), mas as duas fontes do texto discordam na
  pontuação.
- **Recusa sem bloco de fechamento.** (b) e (c) recusaram em prosa e não
  imprimiram o bloco de fechamento. O template pede o bloco também em fase
  bloqueada ("nunca omitido"). O /9 não exige o bloco.
- **Frase imprecisa em (b).** Em (b) o modelo escreveu "Depois de você aprovar
  o plano, rode `execute de historico`". Em MEDIUM o plano não tem portão (a
  skill plan manda "MEDIUM: plano salvo, seguir direto").
- **Pergunta extra em (c).** Em (c), antes de abrir o scope, o modelo
  perguntou se `exportar-csv` vira critério do `historico` ou nó próprio. A
  fase apontada continua certa (scope).

## Teardown

As sessões `claude -p` terminam sozinhas (exit 0 nos 3 cenários). As fixtures
ficam em diretório temporário e não sobra processo. O plugin instalado da
`main` é o estado normal da máquina.
