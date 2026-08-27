# Plano — memory-graphify: GRAFO vira MEMORY + Graphify por baixo dos panos

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** Substituir o GRAFO pelo MEMORY (`MEMORY.md` + `docs/audora/memory/<id>.md`, com Aprendizados) em todo o plugin, e compor o Graphify (índice de código, sem API key) com oferta de instalação, git hook, e consulta em plan/debug/execute — versão 0.4.0, breaking.

**Nó do GRAFO:** `memory-graphify` (GRAFO.md → vira MEMORY.md na T7). Escopo aprovado: `docs/audora/specs/memory-graphify-escopo.md` (critérios `memory-graphify/1..19`).

**Arquitetura da mudança:** Corte seco, sem compat: (1) `git mv` de skill/hooks/pasta preservando histórico, textos reescritos para MEMORY; (2) a skill `memory` passa a ser dona do Graphify — duas operações novas (`bootstrap` ganha a etapa Graphify; `consultar-codigo` é o protocolo que plan/debug/execute invocam), evitando triplicar o protocolo e mantendo cada SKILL.md ≤ 250 linhas; (3) detecção determinística por script bash `hooks/graphify-status` (imprime `ausente|sem-grafo|sem-codigo|ativo` lendo `file_type` do `graph.json`), testável sem LLM; (4) suíte de testes bash em `tests/` (fixtures em `mktemp -d`) vira regressão do plugin — exceção nova na Constituição ("sem código executável além de hooks/ e tests/").

**Arquivos lidos antes de planejar:**
- `skills/graph/SKILL.md` — operações 1-5, regra de leitura seletiva, compat v1 e migração PT→EN (as duas últimas somem)
- `skills/audora-commander/SKILL.md`, `skills/scope/SKILL.md`, `skills/plan/SKILL.md`, `skills/execute/SKILL.md`, `skills/e2e/SKILL.md`, `skills/validate/SKILL.md`, `skills/debug/SKILL.md` — linhas com GRAFO/graph (grep -n listado abaixo por tarefa)
- `hooks/grafo-guard`, `hooks/grafo-validate`, `hooks/session-start`, `hooks/run-hook.cmd`, `hooks/hooks.json` — base dos hooks novos (perl JSON::PP, awk DFS, `$0` → templates)
- `templates/GRAFO-template.md`, `templates/no-template.md`, `templates/decisoes-vivas-template.md`, `templates/plano-template.md`, `templates/e2e-infra-template.md` — schemas a renomear/ajustar; `GRAFO-template-v1.md` some
- `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` — versão 0.3.0 → 0.4.0, descrição e keyword `grafo`
- `README.md` (seções l.8, 29, 88-130, 150-186), `README.pt-BR.md` (mesmas seções), `PRD.md` — referências a GRAFO
- `GRAFO.md`, `docs/audora/nos/plugin-v0.1.0.md`, `docs/audora/nos/memory-graphify.md`, `docs/audora/GRAFO-ARQUIVO.md`, `docs/audora/decisoes-vivas.md`, `.gitignore`, `.gitattributes`, `install.sh` — dogfood (T7)
- `docs/audora/planos/arquivo/plano-comandos-ingles.md` (l.205-235, 470-500) — helper `run()` de fixture de hook (escapar backslash; JSON inválido = exit 0 silencioso)
- Graphify 0.9.11 real (scratchpad): `graphify update <dir>` constrói do zero sem LLM (exit 0, cria `graphify-out/{graph.json,GRAPH_REPORT.md,graph.html,manifest.json,cache/}`); `graphify query "<q>" --budget N` → linhas `NODE <label> [src=<arquivo> loc=L<n> community=<c>]` + `EDGE`; `graphify path "A" "B"`; `graphify affected "X"`; `graphify hook install` → `.git/hooks/post-commit` + `post-checkout`; `hook status`; graph.json: `nodes[].file_type ∈ {code, document}` (bash conta como code; headings de .md viram `document`); `query`/`path` sem graph.json → stderr `error: graph file not found` + exit 1.

**Conflitos GRAFO vs código encontrados:** nenhum. Observação: nó `skill-memory` (planned) é absorvido por esta demanda — decisão humana no escopo, aplicada na T7.

**Decisões tomadas pela IA** (revisar em lote na validate):
- Linha 1 do `MEMORY.md`: `memory-schema: 1` (hooks só atuam com ela; arquivo sem a linha = não é nosso → exit 0).
- Aprendizados: seção `## Aprendizados [carga: sempre]` no `MEMORY.md`, 1 linha `- AAAA-MM-DD | <fase> | <aprendizado em 1 frase>`; ao passar de ~40 linhas, compactar move as antigas para `docs/audora/aprendizados-historico.md`.
- Constituição ganha bullet `- **graphify**: ativo | recusado | sem-codigo` (gravado no bootstrap; ausência = nunca perguntado).
- Protocolo Graphify vive na skill `memory` (operação `consultar-codigo`); plan/debug/execute chamam a operação em vez de repetir o protocolo.
- `hooks/graphify-status` (script auxiliar chamado pela skill via Bash, não hook do Claude) fica em `hooks/` para herdar `.gitattributes` LF e o padrão perl/awk.
- Testes: `tests/run.sh` + `tests/test-*.sh` (bash), fixtures em `mktemp -d`; `.gitattributes` ganha `tests/* text eol=lf`.
- Template do nó mantém o nome `templates/no-template.md` (só paths mudam); índice vira `templates/MEMORY-template.md`; `GRAFO-template.md` e `GRAFO-template-v1.md` removidos.
- Legado: `docs/audora/GRAFO-ARQUIVO.md` → `git mv` para `docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md` (conteúdo intocado); linhas legadas do índice apontam para lá.
- Fora do alcance do /1 e intocados: `docs/fundamentos.md`, `docs/specs/*`, `docs/audora/planos/*`, `docs/audora/arquivo/*`, `docs/audora/depuracao/*` (histórico).
- Critério /1 é `grep -ri grafo` (case-insensitive) → a palavra "grafo" fica proibida TAMBÉM no sentido genérico (índice do Graphify) em skills/hooks/templates/manifests/READMEs/PRD: escrever "índice de código"; status do `graphify-status` `sem-grafo` → `sem-indice` (T3/T4/T7/T8 seguem isto). Descoberto na T2 (GREEN acusou o próprio texto do plano).
- A skill `memory` chama scripts pelo caminho "raiz do plugin" = dois níveis acima do diretório base da skill (o Skill tool imprime esse diretório) — `${CLAUDE_PLUGIN_ROOT}` só existe para hooks.

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda: abordagens descartadas
e por quê, estado parcial, próximos passos. Próxima sessão lê isto primeiro. -->

- Fixtures de hook: SEMPRE `SP="$(mktemp -d)"` (path POSIX). `run()` escapa
  backslash antes de montar o JSON — path `C:\...` sem escape faz o hook
  sair 0 em silêncio (falso verde).
- Hooks que rodam DURANTE a sessão são os do cache (0.3.0, `grafo-*`), não os
  do repo — eles ignoram `MEMORY.md`/`docs/audora/memory/` (exit 0). Os hooks
  novos só entram na sessão após `claude plugin uninstall ... && ./install.sh`
  (e2e). Testes chamam `bash hooks/<nome>` direto no repo.

---

## Passo 0 (antes da T1): commit de abertura

- [x] `git add GRAFO.md docs/audora/nos/memory-graphify.md docs/audora/specs/memory-graphify-escopo.md docs/audora/planos/plano-memory-graphify.md && git commit -m "docs(memory-graphify): abrir demanda — no, escopo aprovado e plano"`
- [x] `git status --short` → vazio.

## Tarefa 1: Harness de testes + teste-guarda "zero GRAFO"

- **depende-de**: []
- **requisito**: memory-graphify/1 — QUANDO o plugin for instalado O SISTEMA DEVE listar 8 skills com `memory` no lugar de `graph`, e `grep -ri grafo` sobre `skills/ hooks/ templates/ .claude-plugin/ README*.md PRD.md` DEVE retornar vazio (histórico em `docs/audora/arquivo/` e `docs/specs/` fica).
- **decisões relevantes**: testes em bash sob `tests/`; fixtures em `mktemp -d`; este teste fica RED até a T6 (é o guarda-chuva do lote A) — cada tarefa tem seus próprios testes red→green.
- **interfaces**:
  - produz: `tests/lib.sh` com `assert_eq <esperado> <obtido> <msg>`, `assert_contains <texto> <trecho> <msg>`, `assert_empty <texto> <msg>`, `assert_file <path> <msg>`, `assert_no_file <path> <msg>`, `run_hook <hook> <path>` (define `out` e `code`), `report` (imprime `PASS=n FAIL=m`, exit 1 se FAIL>0); variáveis `ROOT` (raiz do repo) e `SP` (mktemp) — consumidas por T2-T7.
  - produz: `tests/run.sh` — roda todos `tests/test-*.sh`, soma falhas, exit 1 se alguma.
- **arquivos**:
  - Criar: `tests/lib.sh`, `tests/run.sh`, `tests/test-no-grafo.sh`
  - Modificar: `.gitattributes` (linha `tests/* text eol=lf`)
- **done quando**: `bash tests/run.sh` executa `test-no-grafo.sh` e reporta FAIL (grafo ainda existe) com lista de arquivos; `bash tests/lib.sh` sozinho não faz nada (só funções).

`tests/lib.sh`:

```bash
#!/usr/bin/env bash
# Biblioteca dos testes do plugin. Uso: source "$(dirname "$0")/lib.sh"
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SP="$(mktemp -d)"
trap 'rm -rf "$SP"' EXIT
PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); }
ko()   { FAIL=$((FAIL+1)); echo "  FAIL: $1" >&2; }
assert_eq()       { [ "$1" = "$2" ] && ok || ko "$3 — esperado '$1', obtido '$2'"; }
assert_contains() { printf '%s' "$1" | grep -qF -- "$2" && ok || ko "$3 — não contém '$2'"; }
assert_not_contains() { printf '%s' "$1" | grep -qF -- "$2" && ko "$3 — contém '$2'" || ok; }
assert_empty()    { [ -z "$1" ] && ok || ko "$2 — esperado vazio, obtido: $1"; }
assert_file()     { [ -f "$1" ] && ok || ko "$2 — arquivo ausente: $1"; }
assert_no_file()  { [ -e "$1" ] && ko "$2 — ainda existe: $1" || ok; }
# run_hook <nome-do-hook> <file_path>  → define out (stderr) e code
run_hook() {
  local p="${2//\\/\\\\}"
  out="$(printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$p" | bash "$ROOT/hooks/$1" 2>&1 >/dev/null)"; code=$?
}
report() { echo "$(basename "$0"): PASS=$PASS FAIL=$FAIL"; [ "$FAIL" -eq 0 ]; }
```

`tests/run.sh`:

```bash
#!/usr/bin/env bash
# Roda todos os testes do plugin. Exit 1 se qualquer um falhar.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
falhas=0
for t in tests/test-*.sh; do
  bash "$t" || falhas=$((falhas+1))
done
echo "run.sh: $falhas arquivo(s) de teste com falha"
[ "$falhas" -eq 0 ]
```

`tests/test-no-grafo.sh`:

```bash
#!/usr/bin/env bash
# memory-graphify/1 — zero "grafo" na superfície do plugin; skill memory existe, graph não.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
# Exceção única (delta /1 de 2026-08-26): a skill memory cita `GRAFO.md` UMA vez, no aviso do critério /3.
restos="$(LC_ALL=C.UTF-8 grep -rniE 'grafo' skills hooks templates .claude-plugin README.md README.pt-BR.md PRD.md 2>/dev/null | grep -v '^skills/memory/SKILL.md:[0-9]*:.*GRAFO\.md' || true)"
assert_empty "$restos" "memory-graphify/1 resíduo de GRAFO"
[ "$(grep -c 'GRAFO' skills/memory/SKILL.md 2>/dev/null)" -le 1 ] && ok || ko "memory-graphify/1 skill memory cita GRAFO mais de uma vez"
assert_file "skills/memory/SKILL.md" "memory-graphify/1 skill memory"
assert_no_file "skills/graph" "memory-graphify/1 skill graph removida"
assert_eq "8" "$(ls -d skills/*/ | wc -l | tr -d ' ')" "memory-graphify/1 8 skills"
report
```

Passos:

- [x] **1. Escrever** `tests/lib.sh`, `tests/run.sh`, `tests/test-no-grafo.sh` (código acima); `printf 'tests/* text eol=lf\n' >> .gitattributes`.
- [x] **2. RED** — `bash tests/run.sh` → `test-no-grafo.sh: PASS=1 FAIL=4` (PASS=1 = guarda "8 skills", já vale hoje), saída lista `skills/graph/SKILL.md:...` entre os resíduos; `run.sh: 1 arquivo(s) de teste com falha`, exit 1.
- [x] **3. Commit** — `git add tests .gitattributes && git commit -m "test(memory-graphify/1): harness bash + guarda zero-GRAFO (red)"`.

## Tarefa 2: Templates MEMORY

- **depende-de**: [1]
- **requisito**: memory-graphify/4 — QUANDO o bootstrap rodar O SISTEMA DEVE criar `MEMORY.md` pelo template (Propósito, Constituição, Aprendizados, Índice de nós) e `docs/audora/memory/` vazia, perguntando ao humano o que faltar. memory-graphify/5 — QUANDO uma fase registrar nó ou delta O SISTEMA DEVE escrever `docs/audora/memory/<id>.md` E a linha rica do índice na mesma edição, no schema do template de nó (frontmatter grep-ável, critérios EARS numerados `<id>/<n>`).
- **decisões relevantes**: `memory-schema: 1`; bullet `graphify` na Constituição; formato de Aprendizados; sem template v1.
- **interfaces**:
  - produz: `templates/MEMORY-template.md` (seções `## Propósito [carga: sempre]`, `## Constituição [carga: sempre]` com bullets stack/restricoes/padroes/como-rodar/graphify, `## Aprendizados [carga: sempre]`, `## Índice de nós [carga: sempre]`), `templates/no-template.md` (paths `docs/audora/memory/`), `templates/decisoes-vivas-template.md` (regras citam skill memory) — consumidos por T3 (hooks citam os caminhos) e T4 (skill memory).
- **arquivos**:
  - Criar: `templates/MEMORY-template.md` (via `git mv templates/GRAFO-template.md templates/MEMORY-template.md` + reescrita)
  - Modificar: `templates/no-template.md`, `templates/decisoes-vivas-template.md`, `templates/plano-template.md` (l.9 `**Nó do MEMORY:** \`<id>\` (MEMORY.md)`, l.19 `**Conflitos MEMORY vs código encontrados:**`), `templates/e2e-infra-template.md` (l.13 e 77: "Constituição do MEMORY")
  - Remover: `templates/GRAFO-template-v1.md` (`git rm`)
  - Teste: `tests/test-templates.sh`
- **done quando**: `bash tests/test-templates.sh` → FAIL=0; `grep -ri grafo templates` vazio.

`templates/MEMORY-template.md` (conteúdo completo):

```markdown
memory-schema: 1

# MEMORY — <nome do projeto>

> Memória do produto: o que ele faz, regras inegociáveis, o que aprendemos e
> o estado de cada demanda. Requisito não escrito aqui é requisito que não
> existe. Este arquivo é o ÍNDICE MESTRE; o corpo de cada nó vive em
> `docs/audora/memory/<id>.md` (1 nó = 1 arquivo, ver
> templates/no-template.md). O CÓDIGO não vive aqui: é indexado pelo
> Graphify em `graphify-out/` (fora do git) e consultado pela skill memory.

## Propósito [carga: sempre]

<3-5 linhas: o que o produto faz, para quem, e o que o torna diferente.
Nada de detalhe técnico aqui — isso é a constituição.>

## Constituição [carga: sempre]

Princípios inegociáveis do projeto. Toda fase valida contra esta seção:
cumpre, ou documenta exceção no nó.

- **stack**: <linguagens, frameworks, banco — só o que é decisão firme>
- **restricoes**: <limites duros: versões mínimas, dependências proibidas,
  requisitos de plataforma>
- **padroes**: <convenções que o código segue: estilo, nomenclatura, camadas>
- **como-rodar**: <comando(s) exatos para subir o projeto localmente — usado
  pela skill e2e. Ex.: `npm run dev` na porta 3000>
- **graphify**: <ativo | recusado | sem-codigo — gravado no bootstrap pela
  skill memory; ausente = ainda não perguntado. `ativo` = grafo em
  `graphify-out/` + git hook post-commit instalado>

## Aprendizados [carga: sempre]

O que o projeto ensinou e vale para toda demanda futura: armadilhas,
preferências do humano, como-rodar descoberto, padrões que não estão no
código. Registrado NA HORA por qualquer fase (skill memory,
registrar-aprendizado). 1 linha, grep-ável:
`- AAAA-MM-DD | <fase> | <aprendizado em 1 frase>`

- 2026-08-24 | e2e | Porta 3000 fica ocupada por servidor órfão de sessão anterior — teardown sempre.

## Índice de nós [carga: sempre]

Uma linha rica por nó — decide relevância SEM abrir o corpo; o corpo vive em
`docs/audora/memory/<id>.md` (resolvido pelo id). Formato:
`- <id> | <estado> | <título curto> | <resumo 1 frase> | <keywords> | <arquivos-chave>`

- exemplo-login | planned | Autenticação e-mail/senha | Usuário entra com e-mail e senha para acessar a área logada | auth, login, sessao | src/auth/

<!-- Regras de manutenção (skill memory):
0. Nó `planned` pode viver SÓ na linha do índice (sem arquivo) até ser
   detalhado. A partir de `in-progress`, arquivo docs/audora/memory/<id>.md
   obrigatório (templates/no-template.md).
1. A linha do índice é editada NA MESMA EDIÇÃO que cria/altera o nó — índice
   e pasta divergentes = memória inconsistente, PARAR (hook memory-validate
   acusa; sem hook, a skill verifica).
2. Consulta estrutural via grep, sem carregar corpos: estado →
   `grep -l '^estado: in-progress' docs/audora/memory/*.md`; deps reversas →
   `grep -l 'depende-de:.*<id>' docs/audora/memory/*.md`; nó por arquivo de
   código → `grep -l '<caminho>' docs/audora/memory/*.md`; aprendizado →
   `grep -i '<termo>' MEMORY.md`.
3. Nó delivered (sync da validate): promover decisões ainda válidas para
   docs/audora/decisoes-vivas.md, consolidar aprendizados da demanda aqui,
   depois `git mv docs/audora/memory/<id>.md
   docs/audora/arquivo/AAAA-MM-DD-<id>.md` e trocar a linha do índice para
   `- <id> | delivered | <título> → docs/audora/arquivo/AAAA-MM-DD-<id>.md`.
   Movimento, nunca reescrita.
4. Tetos: este arquivo ~300 linhas (hook memory-guard); Aprendizados ~40
   linhas → mover os antigos para docs/audora/aprendizados-historico.md;
   por nó ver no-template.
5. Máximo 3 nós in-progress, contados globalmente por este índice.
6. `depende-de` reserva a sintaxe `chave:id` para federação futura — `:` é
   PROIBIDO em id de nó. Caminhos sempre relativos ao arquivo que os contém.
7. O corpo do nó é resolvido pelo id (id = nome do arquivo em
   docs/audora/memory/) — link implícito por construção. -->
```

`templates/no-template.md` — edições exatas: comentário do frontmatter perde o bloco "Migração de estado PT→EN (...)" inteiro (linhas `Migração de estado` até `hotfix-pendente-registro→hotfix-pending-record`); `arquivos:` mantém a nota do sync; comentário final: `Mover o frio para \`<id>-historico.md\`` mantém. Nada mais muda (o arquivo já não cita "nos/").

`templates/decisoes-vivas-template.md` — l.14 `<!-- Regras (skill memory/validate):`.

`tests/test-templates.sh`:

```bash
#!/usr/bin/env bash
# memory-graphify/4,/5 — templates do MEMORY existem com as seções/campos do schema.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
t="$(cat templates/MEMORY-template.md 2>/dev/null)"
assert_eq "memory-schema: 1" "$(head -1 templates/MEMORY-template.md 2>/dev/null | tr -d '\r')" "/4 linha 1"
for sec in '## Propósito [carga: sempre]' '## Constituição [carga: sempre]' '## Aprendizados [carga: sempre]' '## Índice de nós [carga: sempre]'; do
  assert_contains "$t" "$sec" "/4 seção $sec"
done
assert_contains "$t" '**graphify**:' "/4 bullet graphify na Constituição"
assert_contains "$t" 'docs/audora/memory/<id>.md' "/5 caminho do nó"
assert_contains "$t" '| <fase> | <aprendizado' "/6 formato de aprendizado"
n="$(cat templates/no-template.md)"
for campo in '^id:' '^estado:' '^origem:' '^depende-de:' '^arquivos:' '^keywords:' '^resumo:' '^atualizado-em:'; do
  printf '%s\n' "$n" | grep -qE "$campo" && ok || ko "/5 frontmatter $campo"
done
assert_contains "$n" 'exemplo-login/1' "/5 critério numerado"
assert_not_contains "$n" 'PT→EN' "/5 sem migração PT→EN"
assert_no_file templates/GRAFO-template.md "/1 GRAFO-template removido"
assert_no_file templates/GRAFO-template-v1.md "/1 GRAFO-template-v1 removido"
assert_empty "$(grep -rli grafo templates || true)" "/1 zero grafo em templates"
report
```

Passos:

- [x] **1. Escrever teste** `tests/test-templates.sh` (código acima).
- [x] **2. RED** — `bash tests/test-templates.sh` → PASS=9 FAIL=12 (MEMORY-template ausente; GRAFO-template existe).
- [x] **3. Implementar** — `git mv templates/GRAFO-template.md templates/MEMORY-template.md`; reescrever com o conteúdo acima; `git rm templates/GRAFO-template-v1.md`; editar `no-template.md`, `decisoes-vivas-template.md`, `plano-template.md`, `e2e-infra-template.md` conforme listado.
- [x] **4. GREEN** — `bash tests/test-templates.sh` → `PASS=21 FAIL=0`; `grep -ri grafo templates` → vazio.
- [x] **5. Commit** — `git add -A templates tests/test-templates.sh && git commit -m "feat(memory-graphify/4,5): templates MEMORY (índice + nó + decisões), remove GRAFO templates"`.

## Tarefa 3: Hooks memory-guard, memory-validate, session-start, graphify-status

- **depende-de**: [1]
- **requisito**: memory-graphify/8 — QUANDO uma escrita em `MEMORY.md` ou `docs/audora/memory/*.md` quebrar o schema (índice↔pasta divergente, `depende-de` inexistente, ciclo, estado fora do enum, teto de linhas) O SISTEMA DEVE devolver o erro ao modelo via hook (exit 2), como hoje. memory-graphify/10 (detecção: `ausente`), memory-graphify/12 (detecção: `ativo`), memory-graphify/13 — QUANDO `graphify .` produzir grafo sem nós de código (projeto sem linguagem suportada) O SISTEMA DEVE avisar, não instalar git hook, e registrar `graphify: sem-codigo` na Constituição. memory-graphify/15 (detecção: `graph.json` ausente/corrompido → `sem-grafo`).
- **decisões relevantes**: `memory-schema: 1` na linha 1 (sem ela, exit 0); `graphify-status` lê `nodes[].file_type == "code"`; falha de hook nunca quebra o fluxo (exit 0 na dúvida); mensagens citam caminho absoluto do plugin resolvido de `$0`.
- **interfaces**:
  - consome: `tests/lib.sh` (`run_hook`, asserts).
  - produz: `hooks/memory-guard`, `hooks/memory-validate` (contrato: stdin JSON PostToolUse, exit 2 + stderr `memory-validate: memória inconsistente — PARE e corrija antes de seguir:` + bullets; exit 0 fora do MEMORY), `hooks/session-start` (texto cita `memory, scope, plan, execute, e2e, validate` e `debug`), `hooks/graphify-status [dir]` (stdout exatamente uma de `ausente|sem-grafo|sem-codigo|ativo`, exit 0 sempre), `hooks/hooks.json` (PostToolUse → memory-guard, memory-validate) — consumidos por T4 (skill memory cita nomes e saídas).
- **arquivos**:
  - Criar: `hooks/graphify-status`
  - Modificar: `hooks/memory-guard` (via `git mv hooks/grafo-guard hooks/memory-guard`), `hooks/memory-validate` (via `git mv hooks/grafo-validate hooks/memory-validate`), `hooks/session-start`, `hooks/hooks.json`
  - Teste: `tests/test-memory-guard.sh`, `tests/test-memory-validate.sh`, `tests/test-session-start.sh`, `tests/test-graphify-status.sh`
- **done quando**: os 4 testes FAIL=0; `grep -ri grafo hooks` vazio; `perl -MJSON::PP -e 'decode_json(join "", <STDIN>)' < hooks/hooks.json` sem erro.

`hooks/memory-guard` (completo):

```bash
#!/usr/bin/env bash
# Hook PostToolUse (Edit|Write): teto de linhas do MEMORY.
# MEMORY.md (índice mestre) > ~300 linhas ou arquivo de nó > ~100 → exit 2 +
# stderr (mensagem chega ao modelo no mesmo turno). Fora do MEMORY → exit 0.
# Contrato: falha do hook NUNCA quebra o fluxo — na dúvida, exit 0.
set -uo pipefail

input="$(cat)"
file_path="$(printf '%s' "$input" | perl -MJSON::PP -0777 -ne '
  my $d = eval { decode_json($_) } or exit 0;
  print $d->{tool_input}{file_path} // "";' 2>/dev/null)" || exit 0
[ -n "$file_path" ] || exit 0
file_path="${file_path//\\//}"
[ -f "$file_path" ] || exit 0

base="$(basename "$file_path")"
case "$file_path" in
  *MEMORY.md)
    head -1 "$file_path" | tr -d '\r' | grep -q '^memory-schema: 1' || exit 0
    n=$(wc -l < "$file_path" | tr -d ' ')
    if [ "$n" -gt 300 ]; then
      echo "memory-guard: MEMORY.md (índice mestre) com $n linhas — teto ~300. Compactar agora: arquivar nós entregues, mover Aprendizados antigos para docs/audora/aprendizados-historico.md, encurtar resumos (skill memory, operação compactar)." >&2
      exit 2
    fi
    ;;
  *docs/audora/memory/*.md)
    case "$base" in *-historico.md) exit 0 ;; esac
    n=$(wc -l < "$file_path" | tr -d ' ')
    if [ "$n" -gt 100 ]; then
      echo "memory-guard: nó $base com $n linhas — teto ~100. Mover histórico frio (delta consolidado, decisões antigas) para ${base%.md}-historico.md (skill memory, operação compactar)." >&2
      exit 2
    fi
    ;;
esac
exit 0
```

`hooks/memory-validate` (completo — deriva do grafo-validate SEM v1, SEM inline, SEM PT→EN; ganha checagem de seções):

```bash
#!/usr/bin/env bash
# Hook PostToolUse (Edit|Write): integridade do MEMORY (memory-schema: 1).
# Acusa: seção obrigatória ausente no MEMORY.md; linha do índice sem coluna
# de estado; estado fora do enum; nó in-progress/blocked sem arquivo; arquivo
# de nó sem linha no índice; depende-de inexistente; ciclo.
# Erro → exit 2 + stderr. Fora do MEMORY, ou MEMORY.md sem "memory-schema: 1"
# na linha 1 → exit 0.
# Contrato: falha do hook NUNCA quebra o fluxo — na dúvida, exit 0.
set -uo pipefail

# templates/ vive na raiz do PLUGIN — resolver de $0 (run-hook.cmd chama
# "bash <HOOK_DIR>/memory-validate"; no cmd.exe $0 chega com backslash).
here="${0//\\//}"
tpl="$(cd "$(dirname "$here")/../templates" 2>/dev/null && { pwd -W 2>/dev/null || pwd; })"
tpl="${tpl:-<raiz do plugin>/templates}"

input="$(cat)"
file_path="$(printf '%s' "$input" | perl -MJSON::PP -0777 -ne '
  my $d = eval { decode_json($_) } or exit 0;
  print $d->{tool_input}{file_path} // "";' 2>/dev/null)" || exit 0
[ -n "$file_path" ] || exit 0
file_path="${file_path//\\//}"

case "$file_path" in
  *MEMORY.md) root="$(dirname "$file_path")" ;;
  *docs/audora/memory/*.md)
    root="${file_path%docs/audora/memory/*}"; root="${root%/}"
    [ -n "$root" ] || root="." ;;
  *) exit 0 ;;
esac
mem="$root/MEMORY.md"
[ -f "$mem" ] || exit 0
corpo="$(tr -d '\r' < "$mem")"
printf '%s\n' "$corpo" | head -1 | grep -q '^memory-schema: 1' || exit 0
dir="$root/docs/audora/memory"

erros=""
for sec in 'Propósito' 'Constituição' 'Aprendizados' 'Índice de nós'; do
  printf '%s\n' "$corpo" | grep -q "^## $sec" || erros="$erros
- seção obrigatória ausente no MEMORY.md: '## $sec' (formato em $tpl/MEMORY-template.md)"
done

idx="$(printf '%s\n' "$corpo" | sed -n '/^## Índice de nós/,/^## [^Í]/p' | grep '^- ' || true)"
idx_ids="$(printf '%s\n' "$idx" | sed 's/^- *\([^ |]*\).*/\1/')"

# 1. estado fora do enum, linha sem estado, nó ativo sem arquivo
while IFS= read -r linha; do
  [ -n "$linha" ] || continue
  id="$(printf '%s' "$linha" | sed 's/^- *\([^ |]*\).*/\1/')"
  estado="$(printf '%s' "$linha" | awk -F'|' 'NF>1 {gsub(/ /,"",$2); print $2}')"
  if [ -z "$estado" ]; then
    erros="$erros
- linha do índice sem coluna de estado: '$linha' — formato é \`- <id> | <estado> | <título> | <resumo> | <keywords> | <arquivos>\` ($tpl/MEMORY-template.md)"
    continue
  fi
  case "$estado" in
    planned|in-progress|blocked|delivered|discarded|hotfix-pending-record) ;;
    *) erros="$erros
- nó '$id' com estado '$estado' fora do enum (planned|in-progress|blocked|delivered|discarded|hotfix-pending-record) — corrija na linha do índice e no arquivo do nó ($tpl/no-template.md)" ;;
  esac
  case "$estado" in
    in-progress|blocked)
      [ -f "$dir/$id.md" ] || erros="$erros
- nó '$id' ($estado) sem arquivo docs/audora/memory/$id.md" ;;
  esac
done <<EOF_IDX
$idx
EOF_IDX

# 2. arquivo sem linha no índice + 3. deps inexistentes (coleta arestas)
edges=""
if [ -d "$dir" ]; then
  for f in "$dir"/*.md; do
    [ -e "$f" ] || continue
    b="$(basename "$f" .md)"
    case "$b" in *-historico) continue ;; esac
    printf '%s\n' "$idx_ids" | grep -qx "$b" || erros="$erros
- arquivo docs/audora/memory/$b.md sem linha no índice mestre"
    for d in $(grep -m1 '^depende-de:' "$f" | tr -d '\r' | sed 's/^depende-de: *\[\(.*\)\].*/\1/' | tr ',' ' '); do
      [ -n "$d" ] || continue
      case "$d" in *:*) continue ;; esac
      printf '%s\n' "$idx_ids" | grep -qx "$d" || erros="$erros
- nó '$b' depende de '$d', que não existe no índice"
      edges="$edges$b $d
"
    done
  done
fi

# 4. ciclo (awk DFS; portável gawk/mawk/busybox)
if [ -n "$edges" ]; then
  ciclo="$(printf '%s' "$edges" | awk '
    { adj[$1] = adj[$1] " " $2; nodes[$1]=1; nodes[$2]=1 }
    function dfs(u,  m,i,arr) {
      if (stk[u]) return 1
      if (vis[u]) return 0
      vis[u]=1; stk[u]=1
      m=split(adj[u], arr, " ")
      for (i=1;i<=m;i++) if (arr[i]!="" && dfs(arr[i])) return 1
      stk[u]=0; return 0
    }
    END { for (n in nodes) { delete vis; delete stk; if (dfs(n)) { print n; exit } } }')"
  [ -n "$ciclo" ] && erros="$erros
- ciclo em depende-de alcançável a partir de '$ciclo' (siga as arestas dele)"
fi

if [ -n "$erros" ]; then
  echo "memory-validate: memória inconsistente — PARE e corrija antes de seguir:$erros" >&2
  exit 2
fi
exit 0
```

`hooks/session-start` — só a string `contexto`:

```bash
contexto="Framework audora-commander ativo. Ao receber demanda de software (criar, alterar, corrigir), invoque a skill \`audora-commander:audora-commander\` ANTES de agir. Memória do produto: MEMORY.md (skill memory; Graphify indexa o código). Fluxos de fase: memory, scope, plan, execute, e2e, validate; bug ou comportamento inesperado: debug. Instrução direta do usuário vale mais que o framework."
```

`hooks/hooks.json` — trocar `grafo-guard` → `memory-guard`, `grafo-validate` → `memory-validate` (2 linhas; resto igual).

`hooks/graphify-status` (completo):

```bash
#!/usr/bin/env bash
# Script auxiliar (chamado pela skill memory via Bash, não é hook do Claude).
# Uso: graphify-status [dir]  → stdout: ausente | sem-grafo | sem-codigo | ativo
#   ausente    = comando graphify fora do PATH
#   sem-grafo  = graphify presente, mas <dir>/graphify-out/graph.json ausente ou corrompido
#   sem-codigo = grafo existe mas nenhum nó tem file_type "code" (só docs)
#   ativo      = grafo com nós de código
# Exit 0 sempre (falha do script nunca quebra o fluxo).
set -uo pipefail
dir="${1:-.}"
command -v graphify >/dev/null 2>&1 || { echo ausente; exit 0; }
g="$dir/graphify-out/graph.json"
[ -f "$g" ] || { echo sem-grafo; exit 0; }
n="$(perl -MJSON::PP -0777 -ne '
  my $d = eval { decode_json($_) };
  if (!$d) { print "-1"; exit 0 }
  my $c = 0;
  for my $x (@{ $d->{nodes} || [] }) { $c++ if (($x->{file_type} // "") eq "code") }
  print $c;' "$g" 2>/dev/null)"
case "${n:-}" in
  -1|"") echo sem-grafo ;;
  0)     echo sem-codigo ;;
  *)     echo ativo ;;
esac
exit 0
```

`tests/test-memory-validate.sh`:

```bash
#!/usr/bin/env bash
# memory-graphify/8 — memory-validate acusa cada classe de inconsistência (exit 2) e cala fora do MEMORY (exit 0).
source "$(dirname "$0")/lib.sh"
mk() { # mk <nome> <linha1> <índice...>
  d="$SP/$1"; mkdir -p "$d/docs/audora/memory"
  printf '%s\n\n## Propósito [carga: sempre]\n\nx\n\n## Constituição [carga: sempre]\n\n- **stack**: x\n\n## Aprendizados [carga: sempre]\n\n## Índice de nós [carga: sempre]\n\n%s\n' "$2" "$3" > "$d/MEMORY.md"
}
no() { printf -- '---\nid: %s\nestado: %s\norigem: humano\ndepende-de: [%s]\narquivos: []\nkeywords: []\nresumo: r\natualizado-em: 2026-08-26\n---\n# %s\n' "$2" "$3" "$4" "$2" > "$SP/$1/docs/audora/memory/$2.md"; }

mk ok 'memory-schema: 1' '- x | in-progress | X | r | k | —'; no ok x in-progress ''
run_hook memory-validate "$SP/ok/MEMORY.md";            assert_eq 0 "$code" "/8 ok → 0"; assert_empty "$out" "/8 ok stderr vazio"
run_hook memory-validate "$SP/ok/docs/audora/memory/x.md"; assert_eq 0 "$code" "/8 ok via nó → 0"

mk sem-arq 'memory-schema: 1' '- x | in-progress | X | r | k | —'
run_hook memory-validate "$SP/sem-arq/MEMORY.md";       assert_eq 2 "$code" "/8 nó sem arquivo → 2"; assert_contains "$out" "sem arquivo docs/audora/memory/x.md" "/8 msg sem arquivo"

mk orfao 'memory-schema: 1' ''; no orfao y planned ''
run_hook memory-validate "$SP/orfao/MEMORY.md";         assert_eq 2 "$code" "/8 arquivo sem índice → 2"; assert_contains "$out" "sem linha no índice" "/8 msg órfão"

mk enum 'memory-schema: 1' '- x | em-curso | X | r | k | —'; no enum x em-curso ''
run_hook memory-validate "$SP/enum/MEMORY.md";          assert_eq 2 "$code" "/8 estado fora do enum → 2"; assert_contains "$out" "fora do enum" "/8 msg enum"; assert_contains "$out" "/templates/no-template.md" "/8 msg cita template absoluto"

mk sempipe 'memory-schema: 1' '- nota sem pipe'
run_hook memory-validate "$SP/sempipe/MEMORY.md";       assert_eq 2 "$code" "/8 linha sem estado → 2"; assert_contains "$out" "sem coluna de estado" "/8 msg sem estado"

mk dep 'memory-schema: 1' '- x | planned | X | r | k | —'; no dep x planned 'nao-existe'
run_hook memory-validate "$SP/dep/MEMORY.md";           assert_eq 2 "$code" "/8 dep inexistente → 2"; assert_contains "$out" "depende de 'nao-existe'" "/8 msg dep"

mk ciclo 'memory-schema: 1' $'- a | planned | A | r | k | —\n- b | planned | B | r | k | —'; no ciclo a planned 'b'; no ciclo b planned 'a'
run_hook memory-validate "$SP/ciclo/MEMORY.md";         assert_eq 2 "$code" "/8 ciclo → 2"; assert_contains "$out" "ciclo em depende-de" "/8 msg ciclo"

d="$SP/secao"; mkdir -p "$d/docs/audora/memory"; printf 'memory-schema: 1\n\n## Índice de nós [carga: sempre]\n\n' > "$d/MEMORY.md"
run_hook memory-validate "$d/MEMORY.md";                assert_eq 2 "$code" "/4 seção ausente → 2"; assert_contains "$out" "'## Aprendizados'" "/4 msg cita Aprendizados"

mk semschema 'versao-schema: 2' '- x | em-curso | X | r | k | —'
run_hook memory-validate "$SP/semschema/MEMORY.md";     assert_eq 0 "$code" "/8 sem memory-schema → 0 (não é nosso)"
mkdir -p "$SP/g/docs/audora/nos"; printf 'versao-schema: 2\n\n## Índice de nós [carga: sempre]\n\n- x | em-curso | X\n' > "$SP/g/GRAFO.md"
run_hook memory-validate "$SP/g/GRAFO.md";              assert_eq 0 "$code" "/8 GRAFO.md ignorado → 0"
run_hook memory-validate "$SP/ok/qualquer.txt";         assert_eq 0 "$code" "/8 fora do MEMORY → 0"
out="$(echo 'nao-json' | bash "$ROOT/hooks/memory-validate" 2>&1)"; assert_eq 0 "$?" "/8 JSON inválido → 0"
report
```

`tests/test-memory-guard.sh`:

```bash
#!/usr/bin/env bash
# memory-graphify/8 — tetos de linhas: MEMORY.md > 300 e nó > 100 → exit 2; -historico e sem schema → 0.
source "$(dirname "$0")/lib.sh"
d="$SP/p"; mkdir -p "$d/docs/audora/memory"
{ echo 'memory-schema: 1'; yes '- l' | head -310; } > "$d/MEMORY.md"
run_hook memory-guard "$d/MEMORY.md";                       assert_eq 2 "$code" "/8 índice 311 linhas → 2"; assert_contains "$out" "teto ~300" "/8 msg índice"
{ echo 'memory-schema: 1'; yes '- l' | head -100; } > "$d/MEMORY.md"
run_hook memory-guard "$d/MEMORY.md";                       assert_eq 0 "$code" "/8 índice 101 linhas → 0"
{ echo 'versao-schema: 2'; yes '- l' | head -310; } > "$d/MEMORY.md"
run_hook memory-guard "$d/MEMORY.md";                       assert_eq 0 "$code" "/8 sem memory-schema → 0"
yes 'x' | head -120 > "$d/docs/audora/memory/n.md"
run_hook memory-guard "$d/docs/audora/memory/n.md";         assert_eq 2 "$code" "/8 nó 120 linhas → 2"; assert_contains "$out" "n-historico.md" "/8 msg nó"
yes 'x' | head -120 > "$d/docs/audora/memory/n-historico.md"
run_hook memory-guard "$d/docs/audora/memory/n-historico.md"; assert_eq 0 "$code" "/8 -historico → 0"
mkdir -p "$d/docs/audora/nos"; yes 'x' | head -120 > "$d/docs/audora/nos/n.md"
run_hook memory-guard "$d/docs/audora/nos/n.md";            assert_eq 0 "$code" "/8 pasta nos/ antiga ignorada → 0"
report
```

`tests/test-session-start.sh`:

```bash
#!/usr/bin/env bash
# hook SessionStart cita memory e não graph; JSON válido.
source "$(dirname "$0")/lib.sh"
o="$(bash "$ROOT/hooks/session-start")"
assert_contains "$o" '"hookEventName": "SessionStart"' "session-start JSON"
assert_contains "$o" 'memory, scope, plan, execute, e2e, validate' "session-start fases"
assert_contains "$o" 'MEMORY.md' "session-start cita MEMORY.md"
assert_not_contains "$o" 'graph,' "session-start sem graph"
assert_not_contains "$o" 'GRAFO' "session-start sem GRAFO"
printf '%s' "$o" | perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' 2>/dev/null && ok || ko "session-start JSON inválido"
h="$(cat "$ROOT/hooks/hooks.json")"
assert_contains "$h" 'memory-guard' "hooks.json memory-guard"; assert_contains "$h" 'memory-validate' "hooks.json memory-validate"; assert_not_contains "$h" 'grafo' "hooks.json sem grafo"
report
```

`tests/test-graphify-status.sh`:

```bash
#!/usr/bin/env bash
# memory-graphify/10,/12,/13,/15 — graphify-status classifica o estado do grafo.
source "$(dirname "$0")/lib.sh"
gs="$ROOT/hooks/graphify-status"
d="$SP/proj"; mkdir -p "$d/graphify-out"
assert_eq "ausente"    "$(PATH=/usr/bin:/bin bash "$gs" "$d")" "/10 sem graphify no PATH"
command -v graphify >/dev/null || { echo "graphify não instalado — casos seguintes pulados"; report; exit; }
rm -f "$d/graphify-out/graph.json"
assert_eq "sem-grafo"  "$(bash "$gs" "$d")" "/15 graph.json ausente"
echo '{nao json' > "$d/graphify-out/graph.json"
assert_eq "sem-grafo"  "$(bash "$gs" "$d")" "/15 graph.json corrompido"
echo '{"nodes":[{"label":"README.md","file_type":"document"},{"label":"h","file_type":"document"}],"links":[]}' > "$d/graphify-out/graph.json"
assert_eq "sem-codigo" "$(bash "$gs" "$d")" "/13 só documentos"
echo '{"nodes":[{"label":"README.md","file_type":"document"},{"label":"login()","file_type":"code","source_file":"src/a.py"}],"links":[]}' > "$d/graphify-out/graph.json"
assert_eq "ativo"      "$(bash "$gs" "$d")" "/12 nó de código"
echo '{"nodes":[],"links":[]}' > "$d/graphify-out/graph.json"
assert_eq "sem-codigo" "$(bash "$gs" "$d")" "/13 grafo vazio"
report
```

Passos:

- [x] **1. Escrever os 4 testes** (código acima; `sem-grafo`→`sem-indice`, `yes '- l'`→`yes 'l'`).
- [x] **2. RED** (guard FAIL=8, validate FAIL=22, session-start FAIL=6, graphify-status FAIL=6) — `for t in tests/test-memory-guard.sh tests/test-memory-validate.sh tests/test-session-start.sh tests/test-graphify-status.sh; do bash $t; done` → todos com FAIL>0 (hooks `memory-*` não existem: `bash: hooks/memory-validate: No such file` → code 127 ≠ 0/2; session-start sem "memory"; graphify-status ausente).
- [x] **3. Implementar** — `git mv hooks/grafo-guard hooks/memory-guard && git mv hooks/grafo-validate hooks/memory-validate`; reescrever com o código acima; criar `hooks/graphify-status`; editar `session-start` e `hooks.json`; `chmod +x hooks/graphify-status` (git: `git update-index --chmod=+x hooks/graphify-status`).
- [x] **4. GREEN** (8/22/9/6 PASS) — os 4 testes `FAIL=0`; `grep -ri grafo hooks` vazio; `file hooks/*` sem CRLF (`grep -l $'\r' hooks/* || echo LF-ok`).
- [x] **5. Commit** — `git add -A hooks tests && git commit -m "feat(memory-graphify/8,10,12,13,15): hooks memory-guard/memory-validate/session-start + graphify-status"`.

## Tarefa 4: Skill `memory` (substitui `graph`) — dona do MEMORY e do Graphify

- **depende-de**: [2, 3]
- **expandir**: sim (texto da skill é escrito na vez dela; o teste abaixo é o contrato)
- **requisito**: memory-graphify/2, /3, /4, /5, /6, /7 (operações do MEMORY) e /10, /11, /12, /13, /14, /15, /16, /17 (Graphify) — verbatim na spec `docs/audora/specs/memory-graphify-escopo.md`.
- **decisões relevantes**: sem compat v1 nem migração PT→EN (seções somem — libera ~60 linhas); protocolo Graphify centralizado aqui; scripts pelo caminho "raiz do plugin"; `description` entre aspas simples.
- **interfaces**:
  - consome: `hooks/graphify-status` (saídas `ausente|sem-grafo|sem-codigo|ativo`), `templates/MEMORY-template.md`, `templates/no-template.md`, `templates/decisoes-vivas-template.md`.
  - produz: `skills/memory/SKILL.md` com `name: memory` e operações numeradas com estes títulos exatos (T5 cita por nome): `### 1. carregar-contexto`, `### 2. bootstrap`, `### 3. registrar-no`, `### 4. registrar-delta`, `### 5. registrar-aprendizado`, `### 6. compactar`, `### 7. consultar-codigo`.
- **arquivos**:
  - Modificar: `skills/memory/SKILL.md` (via `git mv skills/graph skills/memory`)
  - Teste: `tests/test-skills.sh` (parte `memory`; T5 estende)
- **done quando**: `bash tests/test-skills.sh` FAIL=0 na parte memory; `wc -l skills/memory/SKILL.md` ≤ 250.

Conteúdo obrigatório da skill (o teste cobre cada item):
- Lei de Ferro: `REQUISITO NÃO ESCRITO NO MEMORY É REQUISITO QUE NÃO EXISTE`.
- Regra de leitura seletiva: só `MEMORY.md` + nós tocados; greps de consulta (estado, deps reversas, nó por arquivo, aprendizado por termo); `docs/audora/arquivo/` só se o humano pedir histórico.
- Op. 1 carregar-contexto: `MEMORY.md` ausente → oferecer bootstrap, nunca inventar (/2); **`GRAFO.md` presente sem `MEMORY.md` → avisar "GRAFO não é mais lido pelo framework (0.4.0)" e oferecer bootstrap; o que fazer com o GRAFO antigo é do humano** (/3).
- Op. 2 bootstrap: projeto novo/existente como hoje (+ `docs/audora/memory/` vazia, seção Aprendizados vazia) (/4); **etapa Graphify** (/10-13, /17): se a Constituição já tem `graphify:` → não perguntar; senão rodar `bash "<raiz do plugin>/hooks/graphify-status" .`: `ausente` → perguntar "Instalar Graphify (índice do código, sem API key)?" → aceitou: `uv tool install graphifyy` (falhou/`uv` ausente: `pipx install graphifyy`), confirmar com `graphify --version`; instalação falhou → mostrar o erro real, seguir degradado, NÃO gravar `recusado` (/11); recusou → Constituição `graphify: recusado` + aviso degradado (/10). `sem-grafo` → `graphify update .`, rodar status de novo: `ativo` → `graphify hook install` + `graphify-out/` no `.gitignore` + Constituição `graphify: ativo` (/12); `sem-codigo` → avisar, sem git hook, Constituição `graphify: sem-codigo` (/13).
- Op. 3 registrar-no: nó + linha do índice na mesma edição; enum EN; critérios numerados; máx 3 in-progress (/5).
- Op. 4 registrar-delta: append em `## delta`, sem tocar região compartilhada.
- Op. 5 registrar-aprendizado (/6): 1 linha `- AAAA-MM-DD | <fase> | <aprendizado>` na seção Aprendizados do `MEMORY.md`, na hora, por qualquer fase; o que é aprendizado (armadilha, preferência, como-rodar, padrão) vs decisão (vai no nó).
- Op. 6 compactar (/7): consolidar delta; promover decisões vivas; consolidar aprendizados da demanda (dedupe); `git mv` do nó para `docs/audora/arquivo/AAAA-MM-DD-<id>.md`; teto do índice ~300, nó ~100, Aprendizados ~40 → `docs/audora/aprendizados-historico.md`.
- Op. 7 consultar-codigo (/14-16): pré-condição Constituição `graphify: ativo` (recusado/sem-codigo → devolver "sem grafo de código: grep/Read" sem oferecer instalação); `graphify query "<símbolo, rota ou domínio da tarefa>" --budget 1500`; caminho entre símbolos `graphify path "A" "B"`; impacto `graphify affected "X"`; **ler SÓ os arquivos citados em `src=` das linhas `NODE`** — Read fora só com exceção declarada "grafo não cobre X" (/14); arquivo existe no repo mas não aparece no grafo → `graphify update .` UMA vez e repetir; persistindo → degradar com aviso (/16); comando falha (exit ≠ 0, `graph.json` ausente/corrompido, `graphify-status` ≠ ativo) → avisar e cair para grep/Read na mesma fase, sem travar (/15).
- Red flags atualizadas (carregar pasta inteira; editar nó sem índice; "instalo o Graphify sem perguntar"; "leio o arquivo direto, o grafo deve estar velho").
- PRÓXIMA SKILL igual à de hoje.

`tests/test-skills.sh` (parte memory — T5 acrescenta as demais):

```bash
#!/usr/bin/env bash
# Estrutura das 8 skills + contratos de conteúdo (memory: /2,/3,/6,/10-17; fases: /14,/18).
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
for s in audora-commander memory scope plan execute e2e validate debug; do
  f="skills/$s/SKILL.md"
  assert_file "$f" "skill $s existe"
  [ -f "$f" ] || continue
  [ "$(wc -l < "$f")" -le 250 ] && ok || ko "$s > 250 linhas"
  grep -q "^name: $s\$" "$f" && ok || ko "$s name:"
  grep -q "^description: 'Use quando" "$f" && ok || ko "$s description entre aspas simples"
  grep -q 'LEI DE FERRO' "$f" && ok || ko "$s Lei de Ferro"
  grep -q 'Anuncie ao começar' "$f" && ok || ko "$s Anuncie"
  grep -q '^## PRÓXIMA SKILL' "$f" && ok || ko "$s PRÓXIMA SKILL"
  if [ "$s" = memory ]; then
    [ "$(grep -ci 'grafo' "$f")" -le 1 ] && ok || ko "memory cita grafo além do aviso /3"
  else
    grep -qi 'grafo' "$f" && ko "$s cita grafo" || ok
  fi
  grep -qE 'skill graph|`graph`|graph, scope|skill `graph`' "$f" && ko "$s cita skill graph" || ok
done
m="$(cat skills/memory/SKILL.md)"
for op in '### 1. carregar-contexto' '### 2. bootstrap' '### 3. registrar-no' '### 4. registrar-delta' '### 5. registrar-aprendizado' '### 6. compactar' '### 7. consultar-codigo'; do
  assert_contains "$m" "$op" "memory op $op"
done
assert_contains "$m" 'GRAFO.md' "/3 memory avisa sobre GRAFO.md antigo"   # única menção permitida: o aviso
assert_eq "1" "$(grep -c 'GRAFO.md' skills/memory/SKILL.md)" "/3 GRAFO.md aparece só no aviso"
for s in 'hooks/graphify-status' 'uv tool install graphifyy' 'pipx install graphifyy' 'graphify --version' 'graphify update .' 'graphify hook install' 'graphify-out/' '.gitignore' 'graphify: ativo' 'graphify: recusado' 'graphify: sem-codigo' 'graphify query' 'graphify path' 'graphify affected' '--budget' 'src=' 'Aprendizados' '| <fase> |' 'docs/audora/memory/' 'docs/audora/arquivo/' 'aprendizados-historico.md' 'memory-validate' 'memory-guard'; do
  assert_contains "$m" "$s" "memory cita '$s'"
done
assert_not_contains "$m" 'PT→EN' "memory sem migração PT→EN"
assert_not_contains "$m" 'versao-schema' "memory sem schema v1/v2"
report
```

(Exceção única já embutida nos testes da T1 e desta tarefa: a skill memory cita `GRAFO.md` UMA vez, no aviso do /3. Ao pé da letra /1 e /3 se contradizem — registrado como delta no nó, aprovado junto com este plano.)

Passos:

- [x] **1. Escrever** `tests/test-skills.sh` (parte memory; test-no-grafo já tinha a exceção) + ajustes de exceção em `test-no-grafo.sh`.
- [x] **2. RED** — `bash tests/test-skills.sh` → PASS=51 FAIL=47 (`skills/memory` ausente).
- [x] **3. Implementar** — `git mv skills/graph skills/memory`; reescrever `SKILL.md` conforme "Conteúdo obrigatório" (expandir aqui, na vez).
- [x] **4. GREEN** — `bash tests/test-skills.sh` → PASS=92 FAIL=14, parte memory FAIL=0; 223 linhas (as demais skills ainda falham em "cita grafo" — esperado até T5); `wc -l skills/memory/SKILL.md` ≤ 250.
- [x] **5. Commit** — `git add -A skills/memory skills/graph tests && git commit -m "feat(memory-graphify/2-7,10-17): skill memory substitui graph — MEMORY + Graphify (bootstrap, consultar-codigo, aprendizados)"`.

## Tarefa 5: As outras 7 skills — MEMORY no lugar de GRAFO, Graphify em plan/debug/execute

- **depende-de**: [4]
- **expandir**: sim
- **requisito**: memory-graphify/14 — QUANDO `plan`, `debug` ou `execute` precisarem localizar código com `graphify: ativo` O SISTEMA DEVE consultar `graphify query` / `graphify path` antes de qualquer Read e ler só os arquivos apontados; memory-graphify/18 — QUANDO scope, e2e ou validate rodarem O SISTEMA DEVE NÃO consultar o Graphify; memory-graphify/2 e /3 (porta de entrada: bootstrap/aviso GRAFO); memory-graphify/6 (fases registram aprendizado); memory-graphify/7 (validate: sync com aprendizados + arquivar).
- **decisões relevantes**: as fases chamam `skill memory, operação consultar-codigo` (não repetem o protocolo); nomes de operação exatos da T4.
- **interfaces**:
  - consome: títulos de operação da T4 (`consultar-codigo`, `registrar-aprendizado`, `carregar-contexto`, `registrar-no`, `registrar-delta`, `compactar`).
- **arquivos** (linhas de hoje, `grep -n`):
  - Modificar: `skills/audora-commander/SKILL.md` (l.23-25 contexto → skill `memory`, carregar-contexto; "MEMORY ausente → bootstrap; GRAFO.md antigo → aviso"; l.43 registrar nó no MEMORY; l.64 registro no MEMORY; hook/fluxo de fase cita `memory`)
  - `skills/scope/SKILL.md` (l.20-21 skill memory; l.36 "nó do MEMORY"; item novo: descoberta de preferência do humano → registrar-aprendizado)
  - `skills/plan/SKILL.md` (l.21 skill memory; **l.23-25 Passada 1 — localizar: "Constituição `graphify: ativo` → skill memory, operação consultar-codigo (`graphify query`/`path`), ler só os `src=` apontados; senão grep/glob"**; l.30 "Conflito MEMORY vs código"; l.34 header "nó do MEMORY")
  - `skills/execute/SKILL.md` (l.19-20 reancorar: plano + nó do MEMORY; **item novo no ciclo: antes de tocar código vizinho da tarefa, consultar-codigo quando `graphify: ativo`**; item 5 micro-decisões: aprendizado → registrar-aprendizado)
  - `skills/debug/SKILL.md` (**item 2 Evidência: "código do caminho que falha via consultar-codigo (`graphify path`/`affected`) quando ativo"**; l.43 delta no MEMORY; l.67 "PRD/MEMORY vs estado real"; item 6 registrar aprendizado)
  - `skills/e2e/SKILL.md` (l.28 "Constituição do MEMORY"; "registrar na Constituição (skill memory)"; como-rodar descoberto → registrar-aprendizado)
  - `skills/validate/SKILL.md` (l.3 description "sync de MEMORY e PRD"; item 6 sync: consolidar delta, `arquivos:` via git diff, promover decisões vivas, **consolidar aprendizados da demanda no MEMORY.md**, `git mv docs/audora/memory/<id>.md docs/audora/arquivo/...`, PRD; l.67 "Direção única MEMORY → PRD"; l.84 red flag)
  - Teste: `tests/test-skills.sh` (estender)
- **done quando**: `bash tests/test-skills.sh` FAIL=0; `bash tests/test-no-grafo.sh` → só `README*`/`PRD`/`.claude-plugin` como resíduos restantes; cada skill ≤ 250 linhas.

Extensão de `tests/test-skills.sh` (acrescentar antes de `report`):

```bash
for s in plan execute debug; do
  f="$(cat skills/$s/SKILL.md)"
  assert_contains "$f" 'consultar-codigo' "/14 $s consulta o grafo"
  assert_contains "$f" 'graphify: ativo' "/14 $s condiciona ao estado ativo"
done
for s in scope e2e validate audora-commander; do
  grep -qi 'graphify' "skills/$s/SKILL.md" && ko "/18 $s não deve citar graphify" || ok
done
for s in scope execute debug e2e; do
  assert_contains "$(cat skills/$s/SKILL.md)" 'registrar-aprendizado' "/6 $s registra aprendizado"
done
a="$(cat skills/audora-commander/SKILL.md)"
assert_contains "$a" 'skill `memory`' "/2 porta de entrada usa skill memory"
assert_contains "$a" 'MEMORY ausente' "/2 porta de entrada oferece bootstrap"
v="$(cat skills/validate/SKILL.md)"
assert_contains "$v" 'docs/audora/memory/<id>.md docs/audora/arquivo/' "/7 validate arquiva por git mv"
assert_contains "$v" 'aprendizados' "/7 validate consolida aprendizados"
assert_contains "$v" 'MEMORY → PRD' "/7 direção única"
```

Nota /18 vs porta de entrada: `audora-commander` não cita graphify (o bootstrap é operação da skill memory, chamada por nome). Se ao escrever a skill for necessário citar, trocar a linha do teste por `audora-commander` fora da lista e registrar a decisão.

Passos:

- [ ] **1. Estender o teste** (código acima).
- [ ] **2. RED** — `bash tests/test-skills.sh` → FAIL ≥ 15 (skills citam grafo; plan/execute/debug sem consultar-codigo).
- [ ] **3. Implementar** — editar as 7 skills nas linhas listadas (expandir aqui).
- [ ] **4. GREEN** — `bash tests/test-skills.sh` FAIL=0; `for f in skills/*/SKILL.md; do wc -l $f; done` todos ≤ 250; `grep -rli grafo skills` vazio ou só `skills/memory/SKILL.md` (aviso /3).
- [ ] **5. Commit** — `git add skills tests && git commit -m "feat(memory-graphify/2,3,6,7,14,18): 7 skills falam MEMORY; plan/debug/execute consultam Graphify via memory"`.

## Tarefa 6: Manifests 0.4.0, READMEs, PRD (arquitetura)

- **depende-de**: [5]
- **requisito**: memory-graphify/19 — QUANDO a demanda for entregue O SISTEMA DEVE ter `README.md`, `README.pt-BR.md` e `PRD.md` descrevendo MEMORY + Graphify, versão 0.4.0 no manifest, e seção "Renamed in 0.4.0" (GRAFO → MEMORY, `graph` → `memory`, paths novos). memory-graphify/1 (zero grafo nesses arquivos).
- **decisões relevantes**: README EN + PT com blocos de código idênticos (decisão viva docs-bilingues); seção 0.3.0 sai (tabelas com `grafo`), substituída pela 0.4.0 que resume também o que 0.3.0 renomeou sem repetir nomes PT/`grafo`; PRD "Estado atual" ganha entrada só no sync da validate — aqui só Stack/Arquitetura/metas.
- **interfaces**: nenhuma.
- **arquivos**:
  - Modificar: `.claude-plugin/plugin.json` (`version: 0.4.0`; description "…: 5 princípios, MEMORY vivo + Graphify, processo proporcional ao risco, TDD e portões humanos"; keywords `grafo` → `memory`, `graphify`), `.claude-plugin/marketplace.json` (idem versão/descrição)
  - `README.md`: l.8 princípio 1 "MEMORY.md is the product's living memory (requirements, decisions, learnings); Graphify indexes the code underneath"; l.29; Prerequisites: bullet "Optional but recommended: [Graphify](https://github.com/safishamsi/graphify) (`uv tool install graphifyy`, Python 3.10+) — the `memory` skill offers to install it on the first demand and degrades to grep/Read if you decline"; tabela das 8 skills (`memory` | Creates and maintains MEMORY.md — bootstrap, nodes, deltas, learnings, compaction — and drives Graphify: install offer, code graph, `consultar-codigo` for plan/debug/execute); fluxo de uso passo 4 "plan queries the code graph (Graphify) and reads only the files it points to" e passo 7 "the MEMORY syncs"; Artifacts: `MEMORY.md`, `docs/audora/memory/`, `graphify-out/` (gitignored, regenerable), remover parágrafo v1; checklist l.142-147 (MEMORY.md, node in the MEMORY); seção `## Renamed in 0.4.0 (breaking)` com tabela `graph` → `memory`, `GRAFO.md` → `MEMORY.md`, `docs/audora/nos/` → `docs/audora/memory/`, `GRAFO-ARQUIVO.md` → dropped (history in `docs/audora/arquivo/`), hooks `grafo-guard`/`grafo-validate` → `memory-guard`/`memory-validate`, "No migration: a project with the old file gets a warning and a fresh bootstrap"; nota "0.3.0 already moved commands, risk categories and node states to English — see git history"; Development l.184 `MEMORY.md`.
  - `README.pt-BR.md`: mesmas seções em português (l.8, 29, 38-44, 89-131, 143-147, 150-180, 183).
  - `PRD.md`: Stack (hooks `memory-guard`, `memory-validate`, `session-start`; script `graphify-status`; testes bash em `tests/`; Graphify como dependência externa opcional; versão 0.4.0); Arquitetura (skill `memory` no lugar de `graph`, descrição do MEMORY, Aprendizados, Graphify e consultar-codigo; hooks); metas (remover item 4 sobre grafo-validate → reescrever como "validar `estado:` também nos arquivos de `docs/audora/memory/`").
  - Teste: `tests/test-docs.sh`
- **done quando**: `bash tests/test-docs.sh` FAIL=0; `bash tests/test-no-grafo.sh` FAIL=0 (guarda-chuva verde).

`tests/test-docs.sh`:

```bash
#!/usr/bin/env bash
# memory-graphify/19 — versão 0.4.0, READMEs e PRD falam MEMORY + Graphify; blocos de código idênticos EN/PT.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  perl -MJSON::PP -0777 -e 'decode_json(join "", <STDIN>)' < "$j" 2>/dev/null && ok || ko "$j JSON inválido"
  assert_contains "$(cat "$j")" '"version": "0.4.0"' "/19 $j versão 0.4.0"
done
assert_contains "$(cat .claude-plugin/plugin.json)" '"graphify"' "/19 keyword graphify"
en="$(cat README.md)"; pt="$(cat README.pt-BR.md)"
assert_contains "$en" '## Renamed in 0.4.0' "/19 seção 0.4.0 EN"
assert_contains "$pt" '## Renomeado em 0.4.0' "/19 seção 0.4.0 PT"
for s in 'MEMORY.md' '`memory`' 'docs/audora/memory/' 'graphify-out/' 'uv tool install graphifyy' 'memory-validate'; do
  assert_contains "$en" "$s" "/19 README EN cita $s"; assert_contains "$pt" "$s" "/19 README PT cita $s"
done
assert_not_contains "$en" 'Renamed in 0.3.0' "/1 seção 0.3.0 removida (tabela grafo)"
blocos() { awk '/^```/{f=!f; next} f' "$1"; }
assert_eq "$(blocos README.md | md5sum)" "$(blocos README.pt-BR.md | md5sum)" "/19 blocos de código idênticos EN/PT"
p="$(cat PRD.md)"
for s in 'MEMORY.md' 'memory-guard' 'memory-validate' 'graphify-status' 'Graphify' 'tests/' '0.4.0'; do assert_contains "$p" "$s" "/19 PRD cita $s"; done
report
```

Passos:

- [ ] **1. Escrever** `tests/test-docs.sh`.
- [ ] **2. RED** — `bash tests/test-docs.sh` → FAIL ≥ 12.
- [ ] **3. Implementar** — edições listadas (EN primeiro, PT espelhando; blocos de código copiados sem tradução).
- [ ] **4. GREEN** — `bash tests/test-docs.sh` FAIL=0; `bash tests/test-no-grafo.sh` FAIL=0; `diff <(grep -c '^## ' README.md) <(grep -c '^## ' README.pt-BR.md)` vazio (paridade de seções).
- [ ] **5. Commit** — `git add .claude-plugin README.md README.pt-BR.md PRD.md tests/test-docs.sh && git commit -m "docs(memory-graphify/19): 0.4.0 — READMEs, PRD e manifests descrevem MEMORY + Graphify; Renamed in 0.4.0"`.

## Tarefa 7: Dogfood — este repositório migra para MEMORY e ativa o Graphify

- **depende-de**: [3, 6]
- **requisito**: memory-graphify/9 — QUANDO a demanda for entregue O SISTEMA DEVE ter este repositório migrado (dogfood): `MEMORY.md` + `docs/audora/memory/` com os nós ativos e planejados de hoje; `GRAFO.md`, `docs/audora/nos/` e `GRAFO-ARQUIVO.md` removidos; histórico de nós entregues preservado em `docs/audora/arquivo/` (conteúdo intocado). memory-graphify/12 (bootstrap Graphify neste repo: `ativo`, git hook, gitignore, Constituição).
- **decisões relevantes**: `skill-memory` → `discarded` com `substituido-por: memory-graphify`; legado → `docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md`; Aprendizados iniciais = 2 armadilhas reais já conhecidas (cache do plugin; fixtures de hook); Constituição: exceção "código executável: hooks/ e tests/"; `graphify-out/` no `.gitignore`.
- **interfaces**:
  - consome: `hooks/memory-validate`, `hooks/memory-guard`, `hooks/graphify-status` (T3); `templates/MEMORY-template.md` (T2).
- **arquivos**:
  - Criar: `MEMORY.md` (via `git mv GRAFO.md MEMORY.md` + edição), `docs/audora/memory/` (via `git mv docs/audora/nos docs/audora/memory`), `docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md` (via `git mv docs/audora/GRAFO-ARQUIVO.md …`)
  - Modificar: `.gitignore` (`graphify-out/`), `docs/audora/memory/memory-graphify.md` (delta: `ADICIONADO (2026-08-26): /1 tolera a menção única de GRAFO.md no aviso /3 da skill memory`), `docs/audora/decisoes-vivas.md` (l.14 comentário "skill memory/validate")
  - Teste: `tests/test-dogfood.sh`
- **done quando**: `bash tests/test-dogfood.sh` FAIL=0; `run_hook memory-validate MEMORY.md` → 0; `bash hooks/graphify-status .` → `ativo`; `graphify hook status` → instalados.

`MEMORY.md` deste repo — edições sobre o `GRAFO.md` atual:
- l.1 `memory-schema: 1`; título `# MEMORY — audora-commander`; blockquote do template.
- Constituição: `restricoes` → "código executável só em `hooks/` (hooks + `graphify-status`) e `tests/` (suíte bash)"; `padroes` mantém; `como-rodar` → "`bash tests/run.sh` (suíte do plugin); validação de instalação = `claude plugin uninstall audora-commander@audora-commander-dev && ./install.sh` + checklist do README"; novo bullet `- **graphify**: ativo`.
- Nova seção `## Aprendizados [carga: sempre]` com:
  - `- 2026-08-25 | validate | claude plugin update só refaz o cache com bump de versão — sem bump: uninstall + ./install.sh; hooks que rodam na sessão são os do cache, não do repo.`
  - `- 2026-08-25 | execute | Fixtures de hook em mktemp -d (path POSIX) e JSON com backslash escapado — path C:\... sem escape faz o hook sair 0 em silêncio (falso verde).`
- Índice: `plugin-v0.1.0` e `memory-graphify` iguais; `skill-memory | discarded | Skill MEMORY | absorvido por memory-graphify (2026-08-26) | memoria, aprendizado | —`; `comandos-ingles`/`grafo-v2` iguais; `docs-bilingues`, `e2e-playwright-docker`, `skill-depurar` → `→ docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md`; comentário final aponta o template novo.

`tests/test-dogfood.sh`:

```bash
#!/usr/bin/env bash
# memory-graphify/9,/12 — este repositório usa MEMORY + Graphify.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
assert_file MEMORY.md "/9 MEMORY.md"; assert_no_file GRAFO.md "/9 GRAFO.md removido"
assert_no_file docs/audora/nos "/9 nos/ removida"; assert_no_file docs/audora/GRAFO-ARQUIVO.md "/9 GRAFO-ARQUIVO removido"
assert_file docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md "/9 legado preservado"
sha="$(git log -1 --format=%H --diff-filter=AM -- docs/audora/GRAFO-ARQUIVO.md)"   # último commit que escreveu o legado (vale antes e depois do git mv)
assert_eq "$(git show "$sha:docs/audora/GRAFO-ARQUIVO.md" | md5sum)" "$(md5sum < docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md)" "/9 legado intocado (== última versão commitada)"
assert_eq "memory-schema: 1" "$(head -1 MEMORY.md | tr -d '\r')" "/9 schema"
m="$(cat MEMORY.md)"
assert_contains "$m" '## Aprendizados [carga: sempre]' "/9 Aprendizados"
assert_contains "$m" '**graphify**: ativo' "/12 Constituição graphify ativo"
for id in plugin-v0.1.0 memory-graphify skill-memory comandos-ingles grafo-v2 docs-bilingues e2e-playwright-docker skill-depurar grafo-inicio-fim skill-poc porte-multi-harness marketplace-publico agentes-dedicados; do
  grep -q "^- $id |" MEMORY.md && ok || ko "/9 índice perdeu $id"
done
grep -q '^- skill-memory | discarded |' MEMORY.md && ok || ko "/9 skill-memory discarded"
assert_file docs/audora/memory/memory-graphify.md "/9 nó em memory/"
run_hook memory-validate "$ROOT/MEMORY.md"; assert_eq 0 "$code" "/9 memory-validate verde"; assert_empty "$out" "/9 stderr vazio"
run_hook memory-guard "$ROOT/MEMORY.md";    assert_eq 0 "$code" "/9 memory-guard verde"
grep -q '^graphify-out/$' .gitignore && ok || ko "/12 gitignore"
if command -v graphify >/dev/null; then
  assert_eq "ativo" "$(bash hooks/graphify-status .)" "/12 status ativo"
  assert_contains "$(graphify hook status 2>&1)" 'post-commit: installed' "/12 git hook instalado"
fi
report
```

Passos:

- [ ] **1. Escrever** `tests/test-dogfood.sh`.
- [ ] **2. RED** — `bash tests/test-dogfood.sh` → FAIL>0 (MEMORY.md ausente…).
- [ ] **3. Migrar** — `git mv GRAFO.md MEMORY.md && git mv docs/audora/nos docs/audora/memory && git mv docs/audora/GRAFO-ARQUIVO.md docs/audora/arquivo/2026-08-24-legado-GRAFO-ARQUIVO.md`; editar `MEMORY.md` conforme acima; delta no nó; `decisoes-vivas.md` l.14; `printf 'graphify-out/\n' >> .gitignore`.
- [ ] **4. Graphify** — `bash hooks/graphify-status .` → `sem-grafo`; `graphify update .` → `Rebuilt: N nodes` (N>0, hooks bash são código); `bash hooks/graphify-status .` → `ativo`; `graphify hook install` → `post-commit: installed`; `graphify hook status` confirma.
- [ ] **5. GREEN** — `bash tests/test-dogfood.sh` FAIL=0; `bash tests/run.sh` → `0 arquivo(s) de teste com falha`.
- [ ] **6. Commit** — `git add -A && git commit -m "chore(memory-graphify/9,12): dogfood — GRAFO.md vira MEMORY.md, nos/ vira memory/, legado arquivado, Graphify ativo"` (o post-commit do Graphify roda em background — confirmar `git status` limpo; `graphify-out/` ignorado).

## Tarefa 8: Verificação final + preparação do e2e

- **depende-de**: [7]
- **requisito**: todos — `tests/run.sh` verde é a evidência automatizada dos critérios /1, /4, /5, /8, /9, /10 (detecção), /12, /13, /15 (detecção), /19; os critérios de comportamento de skill (/2, /3, /6, /7, /11, /14, /16, /17, /18) têm evidência estrutural aqui e evidência ao vivo no e2e (`claude -p` com o plugin reinstalado).
- **interfaces**: nenhuma.
- **arquivos**: nenhum novo.
- **done quando**: `bash tests/run.sh` → `0 arquivo(s) de teste com falha`; `git status --short` vazio; plugin reinstalado (`claude plugin uninstall audora-commander@audora-commander-dev && ./install.sh`) com cache `0.4.0` e `diff -r hooks "$HOME/.claude/plugins/cache/audora-commander-dev/audora-commander/0.4.0/hooks"` vazio.

Passos:

- [ ] **1.** `bash tests/run.sh` → verde; `for f in skills/*/SKILL.md; do echo "$(wc -l < $f) $f"; done` todos ≤ 250.
- [ ] **2.** `claude plugin uninstall audora-commander@audora-commander-dev && ./install.sh` → "Instalação concluída"; `diff -r hooks "$HOME/.claude/plugins/cache/audora-commander-dev/audora-commander/0.4.0/hooks"` vazio; `diff -r skills ".../0.4.0/skills"` vazio.
- [ ] **3.** Seguir para **e2e** (skill): sessão `claude -p` lista 8 skills com `memory`; hook cita `memory, scope, plan…`; projeto fixture em `mktemp -d` sem MEMORY.md e com `GRAFO.md` → porta de entrada avisa e oferece bootstrap (/3); fixture com `src/*.py` → bootstrap roda `graphify update`, gitignore, Constituição `ativo` (/12); fixture só-docs → `sem-codigo` (/13); `PATH` sem graphify → oferta de instalação (/10).
