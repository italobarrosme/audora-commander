# Plano — comandos-ingles: comandos, categorias e estados em inglês

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** Renomear as skills (`graph, scope, plan, execute, e2e, validate,
debug`), as categorias (LIGHT/MEDIUM/HIGH/HOTFIX) e o enum de estado dos nós
(`planned|in-progress|blocked|delivered|discarded|hotfix-pending-record`) em
todo artefato vivo do plugin, com migração total de estados no primeiro toque
de escrita em projetos-alvo, hook acusando estado fora do enum, READMEs com
tabela PT→EN e plugin 0.3.0.

**Nó do GRAFO:** `comandos-ingles` (GRAFO.md) — spec:
`docs/audora/specs/comandos-ingles-escopo.md` (critérios comandos-ingles/1.1–4.3)

**Arquitetura da mudança:** Mudança é de identificadores, não de estrutura:
(1) diretórios das skills renomeados por `git mv` + `name:` do frontmatter;
(2) varredura das 8 skills trocando SÓ identificadores (nome de skill,
categoria, estado) — prosa, caminhos e nomes de arquivo intactos; (3) os
templates viram a fonte do enum EN com a tabela de mapeamento e a skill
`graph` ganha a regra de migração PT→EN (3.2/3.3); (4) hooks: `session-start`
cita nomes EN, `grafo-validate` acusa estado fora do enum; (5) dogfood: GRAFO
deste repo migrado por completo; (6) READMEs + versão 0.3.0; (7) reinstalação
real do plugin e verificação 1:1. Nomes de arquivo dos hooks (`grafo-guard`,
`grafo-validate`) e caminhos (`docs/audora/planos/plano-<id>.md`, `GRAFO.md`)
NÃO mudam (fora de escopo).

**Arquivos lidos antes de planejar:**
- `skills/audora-commander/SKILL.md` (86 l.) — 20 ocorrências de categoria
  (tabela de roteamento l.52-55 — a linha HOTFIX l.55 só tem nomes de skill,
  perguntas, red flags), 5 de nomes de skill + "pela validar" l.57, 3 de
  estado (`em-curso`, `hotfix-pendente-registro`). Linha 3: `description:`
  SEM aspas contendo `: ` → `claude plugin validate .claude-plugin/plugin.json`
  FALHA hoje (YAML) — bug pré-existente, corrigido na T2.
- `skills/grafo/SKILL.md` (167 l.) — menção "estado no enum" (l.76) SEM
  lista literal do enum; greps `'^estado: em-curso'` (l.36); "sync da
  validar" (l.107, 111), "(a validar apresenta)" l.98, "chamada pela validar"
  l.100, "e2e/escopo chamam" l.103; red flag l.158 "Migração em lote é
  big-bang" (schema v1→v2 — precisa qualificador); l.141 "nunca precisam
  migrar" (GRAFO-ARQUIVO.md); formato coluna `- <id> | entregue |` l.117.
- `skills/escopo/SKILL.md` (81; "a executar decide" l.58),
  `skills/plano/SKILL.md` (91; "volte à skill\n  escopo" l.67-68 — quebra de
  linha entre "skill" e o nome), `skills/executar/SKILL.md` (84),
  `skills/e2e/SKILL.md` (102; "fix via executar" l.68, "testes da executar"
  l.79), `skills/validar/SKILL.md` (91; "Volte à executar" l.30),
  `skills/depurar/SKILL.md` (99) — pontos: frontmatter `name`/`description`,
  título `# <nome> —`, "Anuncie ao começar", "skill <nome>", "PRÓXIMA
  SKILL", referências nominais (pela/da/via/à <nome>), categorias, estados.
- `hooks/session-start` — string `contexto` cita os 7 nomes PT.
- `hooks/grafo-validate` — bloco 1 = linhas 34-48 (comentário `# 1.` + while)
  com `case em-curso|bloqueada)`; sem checagem de enum; awk `NF>1` deixa
  `estado` vazio em linha sem `|`. Linha 26 só roda em `versao-schema: 2`;
  JSON inválido no stdin → exit 0 silencioso (l.10-11).
- `hooks/grafo-guard` — mensagens citam "skill grafo" (linhas 22 e 30).
- `hooks/run-hook.cmd`, `install.cmd` — sem mudança; matches de "LEVE" são
  `%ERRORLEVEL%` (falso positivo → classe ASCII nos greps deste plano).
- `hooks/hooks.json`, `install.sh`, `.gitattributes` — sem mudança.
- `templates/GRAFO-template.md` (65; 10 matches — l.33 exemplo, regras 0/2/3/5,
  "skill grafo" l.35 e l.62 "migração on-touch ... nunca em lote forçado"),
  `templates/GRAFO-template-v1.md` (72; 9 matches), `templates/no-template.md`
  (72; 4 matches — l.3, enum comentado l.15-16, "sync da\n validar" l.20-21,
  "skill validar" l.53), `templates/decisoes-vivas-template.md` (17; 1 match
  l.11 "skill grafo/validar" + "sync da validar" l.3),
  `templates/plano-template.md` (0 matches — só prosa "plano"/"GRAFO"),
  `templates/e2e-infra-template.md` (0 matches).
- `README.md` / `README.pt-BR.md` (153 cada; 8 seções `## ` cada, títulos
  traduzidos) — princípio 4, tabela das 8 skills, fluxo de uso, artefatos,
  checklist 5, link para `docs/fundamentos.md`. Blocos de código diferem HOJE
  só no placeholder `<folder-where-you-cloned-the-repo>` /
  `<pasta-onde-clonou-o-repo>` (decisão viva docs-bilingues).
- `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` — `version`.
- `GRAFO.md` (índice l.34-45 = 12 estados: 2 em-curso, 6 planejada,
  4 entregue; comentário l.47 "(skill grafo)"),
  `docs/audora/nos/plugin-v0.1.0.md` (l.3; critério 5 cita LEVE/MÉDIA l.30;
  decisão l.41-42 "nomes em português"), `docs/audora/nos/comandos-ingles.md`
  (l.3), `docs/audora/arquivo/2026-08-25-grafo-v2.md` (l.3 `estado:
  entregue`), `docs/audora/GRAFO-ARQUIVO.md` (headings l.6, 29, 56 "(entregue
  DATA)"), `docs/audora/decisoes-vivas.md` (decisões l.9-16 intactas;
  comentário de regras l.18 "skill grafo/validar" é cópia do template).
- `docs/fundamentos.md` (271 l.) — enum PT l.28-29, tabela de roteamento
  l.148-151 idêntica à da skill, `hotfix-pendente-registro` l.162, "skill
  grafo/validar" l.29/41; linkado por README.md:37, README.pt-BR.md:36 e
  PRD.md:50. FICA EM PT (decisão abaixo; humano confirma no portão).
- `PRD.md` — 12 linhas com identificadores PT (l.20 versão, 26-27
  categorias, 28/34/35/36/39/41 nomes em crase, 55/60/69/109 histórico).
  Atualizado no sync da validar (direção GRAFO → PRD; lista do sync abaixo).
- `git status`: `GRAFO.md` modificado; nó, spec e este plano `??` (untracked)
  → commit de abertura antes da T1.
- Ambiente: Git Bash MINGW64, GNU grep 3.0, `LC_ALL` vazio; `claude` CLI
  2.1.123 com `claude plugin validate <path>` e `claude plugin update <plugin>`.

**Conflitos GRAFO vs código encontrados:** nenhum (8 skills, estados e
categorias do código batem com GRAFO/PRD).

**Fato operacional:** os hooks que rodam DURANTE a execução são os do cache
instalado (0.2.0, enum PT) — `grafo-validate` antigo ignora `in-progress`
(case não casa → sem erro). Reinstalação na Tarefa 8 troca o cache. Se o
cache for atualizado antes da T6, editar o ÍNDICE primeiro (o hook valida o
GRAFO.md inteiro em qualquer escrita de nó).

## Padrão global de verificação (definir no início de CADA sessão de execução)

```bash
export LC_ALL=C.UTF-8          # \b e classes só são confiáveis em UTF-8 (→, —, à)
B='(^|[^A-Za-z0-9_])'; E='([^A-Za-z0-9_]|$)'   # fronteira ASCII explícita, não \b
S='(grafo|escopo|plano|executar|validar|depurar)'
ST='(planejada|em-curso|bloqueada|entregue|descartada|hotfix-pendente-registro)'
P="\`$S\`|skill $S$E|\*\*$S\*\*|audora-commander:$S|^# $S |Usando $S |$S → ($S|\[e2e\])|(pela|da|via|à) $S$E|${B}a (executar|validar|depurar) (decide|apresenta|cobra|chama)|fase (escopo|plano)$E|pula escopo e plano|e2e/escopo|${B}(LEVE|MÉDIA|ALTA)$E|\`$ST\`|estado: $ST|\| $ST \|"
# cadeia de roteamento `X → Y` (não `escopo → isso`, substantivo em plano l.67)
# multilinha "skill<quebra>nome" (grep -P não roda no locale msys):
ML() { for f in "$@"; do perl -0ne 'while(/skill[ \t]*\n[ \t]*(grafo|escopo|plano|executar|validar|depurar)\b/g){$n=()=substr($_,0,pos)=~/\n/g; print "$ARGV:".($n+1)."\n"}' "$f"; done; }
# exclusões PERMITIDAS (únicas): tabela PT→EN do no-template e seção de renomeação dos READMEs
X_TPL='→(planned|in-progress|blocked|delivered|discarded|hotfix-pending-record)|Migração de estado'
NOSEC() { sed '/^## .*0\.3\.0/,/^## /d' "$1"; }   # remove a seção "Renamed in 0.3.0" (EN ou PT) antes do grep
```

Greps em modo linha (nunca `-o`: a classe consome o delimitador e colapsa
vizinhos como "LEVE/MÉDIA"). Medido hoje (2026-08-25): skills 93,
templates 25 (com `${B}$ST$E`), READMEs 36, hooks 2, PRD 12, `.cmd` 0;
`ML skills/*/SKILL.md` → `skills/plano/SKILL.md:68`.

## Notas de sessão

Rodada adversarial do PLANO (2026-08-25, 3 lentes, 25 achados confirmados
por verificadores independentes, 2 refutados) — todos integrados nesta
versão: exceção de grep para a tabela dos READMEs (por seção, não por
heading traduzido), 4ª linha da tabela do no-template escapando ao `grep -v`,
`\b` cego a `→`/`—` no grep 3.0 (classe ASCII + LC_ALL), referências
nominais às skills ("pela validar", "fix via executar") e linha HOTFIX da
tabela fora do padrão, PRD sem evidência, commits sem `git add` e artefatos
untracked, 13→12 estados, bloco 34-48 do hook, depende-de vs consome,
fronteira T2.2/T3 no enum, red flag "lote" contradizendo 3.2, comentários
`skill grafo` no GRAFO.md/decisoes-vivas.md, fundamentos.md em PT sem
decisão, diff de READMEs falhando hoje por placeholder traduzido, fixtures
com path Windows quebrando o JSON (hook sai 0 em silêncio), plano-template
sem matches, checagem de CRLF falso-negativa, linha de índice sem `|`
virando "migração pendente", e `claude plugin validate` falhando hoje por
YAML da description.

## Decisões tomadas pela IA (revisar na validação)

- Verificação por comandos bash inline (grep/execução real, saída lida), sem
  pasta `tests/` — Constituição: "sem código executável além dos hooks";
  precedente do plano grafo-v2.
- Fronteira de palavra por classe ASCII explícita `(^|[^A-Za-z0-9_])` em vez
  de `\b`, com `LC_ALL=C.UTF-8`: o grep 3.0 do Git for Windows não reconhece
  boundary antes de `→`/`—`/`à`; `%ERRORLEVEL%` continua fora (R é
  alfanumérico). Mesmas linhas que `\b` devolve hoje (diff igual).
- Padrão `$P` definido UMA vez e reusado (T2, T4, T6, T7, T8); únicas
  exceções permitidas de PT como identificador: a tabela de migração do
  `no-template.md` (excluída por `$X_TPL`) e a seção "Renamed in 0.3.0" dos
  READMEs (excluída por `NOSEC`, faixa `## .*0.3.0` agnóstica de idioma
  porque os headings do PT são traduzidos).
- `description:` de TODAS as skills passa a ser YAML entre aspas simples
  (`'...'`) — hoje `audora-commander` quebra `claude plugin validate` por
  `: ` sem aspas; prosa intacta.
- Arquivos `hooks/grafo-guard` e `hooks/grafo-validate` mantêm nome (nome de
  arquivo é fora de escopo); só mensagens citam `skill graph`.
- `GRAFO-ARQUIVO.md` (v1 legado): heading "(entregue DATA)" é o campo de
  estado do formato v1 → vira "(delivered DATA)"; chave `entregue-em` fica.
- Decisão de 2026-08-14 em `plugin-v0.1.0` ("nomes em português") recebe
  `[invalidado-em: 2026-08-25] [substituido-por: comandos-ingles]`.
- Tabela de mapeamento PT→EN de estados vive em `templates/no-template.md`
  (comentário); a skill `graph` e a mensagem do hook só referenciam.
- Linhas legadas do índice (`→ ver docs/audora/GRAFO-ARQUIVO.md`) têm a
  coluna de estado traduzida como as demais.
- `docs/fundamentos.md` FICA em PT (doc de fundamentos; fora da lista 1.3/2.2
  da spec, como `docs/specs/*`). A seção de renomeação dos READMEs avisa, nos
  dois idiomas, que fundamentos.md usa os nomes anteriores à 0.3.0. **Humano
  confirma ou puxa o arquivo para a T7 no portão do plano.**
- `decisoes-vivas.md`: decisões (l.9-16) intactas — histórico; só o
  comentário de regras (l.18, cópia do template) acompanha a T4.
- Hook novo: linha de índice sem coluna de estado vira erro próprio ("sem
  coluna de estado"), não "migração PT→EN pendente" — mensagem certa para o
  modelo.
- PRD.md muda no sync da validar (direção GRAFO → PRD), com esta lista
  concreta: l.20 "Versão 0.2.0" → "0.3.0"; l.26-27 categorias → LIGHT /
  MEDIUM / HIGH / HOTFIX; l.28/34/35/36/39/41 nomes em crase → `graph`,
  `scope`, `plan`, `execute`, `validate`, `debug`; l.55/60/69/109 histórico:
  trocar crase PT por EN ("a skill `debug` (então `depurar`)" NÃO — texto
  sem crase: "a skill de debug, renomeada para `debug` em 0.3.0"); + resumo
  da entrega e data. Evidência 1.3-PRD/4.2-PRD = `grep -nE "$P" PRD.md` → 0
  APÓS o sync (≠ 0 antes).
- Commit por tarefa verde, direto na `main` (padrão deste repo), sempre
  `git add <lista exata> && git commit`; commit de abertura com nó + spec +
  plano antes da T1 (precedente 2ec5669/cf1bae8).
- Fixtures de hook em `SP="$(mktemp -d)"` (path POSIX); `run()` escapa
  backslash antes de montar o JSON — path `C:\...` sem escape faz o hook
  sair 0 em silêncio (falso verde).

---

## Passo 0 (antes da T1): commit de abertura

- [ ] `git add GRAFO.md docs/audora/nos/comandos-ingles.md docs/audora/specs/comandos-ingles-escopo.md docs/audora/planos/plano-comandos-ingles.md && git commit -m "docs(comandos-ingles): abrir demanda — no, escopo aprovado e plano"`
- [ ] `git status --short` → vazio.

## Tarefa 1: Renomear diretórios das skills + `name:`

- **depende-de**: []
- **requisito**: comandos-ingles/1.1 — QUANDO o plugin for instalado
  O SISTEMA DEVE listar exatamente 8 skills com prefixo `audora-commander:`:
  `audora-commander`, `graph`, `scope`, `plan`, `execute`, `e2e`,
  `validate`, `debug` — e nenhuma com nome antigo (corte seco, sem alias).
- **decisões relevantes**: corte seco; `git mv` preserva histórico.
- **interfaces**:
  - produz: diretórios `skills/graph`, `skills/scope`, `skills/plan`,
    `skills/execute`, `skills/validate`, `skills/debug` — nomes que T2–T7
    citam.
- **arquivos**:
  - Renomear: `skills/grafo`→`skills/graph`, `skills/escopo`→`skills/scope`,
    `skills/plano`→`skills/plan`, `skills/executar`→`skills/execute`,
    `skills/validar`→`skills/validate`, `skills/depurar`→`skills/debug`.
  - Modificar: linha 2 (`name:`) de cada SKILL.md renomeado.
- **done quando**: `ls skills` = 8 nomes EN; `name:` == nome do diretório em
  todos os 8; zero diretório PT.

Passos:

- [ ] **1. RED** —
  `for d in skills/*/; do n=$(basename $d); grep -q "^name: $n$" $d/SKILL.md && echo "ok $n" || echo "FAIL $n"; done`
  → hoje "ok" para todos (nomes PT). Depois do `git mv` (passo 2), rodar de
  novo → 6× `FAIL` (dir EN, name PT) = red pelo motivo certo.
- [ ] **2. git mv** —
  `git mv skills/grafo skills/graph && git mv skills/escopo skills/scope && git mv skills/plano skills/plan && git mv skills/executar skills/execute && git mv skills/validar skills/validate && git mv skills/depurar skills/debug`
- [ ] **3. GREEN** — editar `name:` nos 6 SKILL.md (`name: graph` etc.);
  rerodar o loop do passo 1 → 8× `ok`; `ls skills` → `audora-commander debug e2e execute graph plan scope validate`.
- [ ] **4. Commit** — `git add -A skills && git commit -m "feat(comandos-ingles/1.1): renomear skills para ingles (git mv + name)"`.

## Tarefa 2: Varredura das 8 skills — identificadores EN — `expandir: sim`

- **depende-de**: [1]
- **requisito**:
  - comandos-ingles/1.3 — QUANDO uma skill referenciar outra (roteamento,
    "PRÓXIMA SKILL", chamada de operação) O SISTEMA DEVE usar só o nome em
    inglês — zero ocorrências dos nomes antigos como identificador de comando
    em `skills/`, `hooks/`, `templates/`, `README*.md`, `PRD.md`, `install.*`.
  - comandos-ingles/2.1 — QUANDO a porta de entrada classificar uma demanda
    O SISTEMA DEVE anunciar e registrar a categoria como LIGHT, MEDIUM, HIGH
    ou HOTFIX; a tabela de roteamento e as regras de catraca usam esses nomes.
  - comandos-ingles/2.2 — QUANDO skills, templates, hook e READMEs
    mencionarem categoria de risco O SISTEMA DEVE usar só os nomes em inglês.
  - comandos-ingles/3.1 (parte skills) — QUANDO um nó for criado ou atualizado
    O SISTEMA DEVE gravar `estado:` com valor do enum em inglês.
- **decisões relevantes**: prosa fica PT; caminhos/nomes de arquivo ficam
  (`plano-<id>.md`, `docs/audora/planos/`, "plano-arquivo" como termo de
  artefato, `GRAFO`); SKILL.md ≤ 250 linhas; padrão de skill intacto;
  `description` entre aspas simples.
- **interfaces**: consome nomes de diretório de T1; produz os identificadores
  que T4–T7 citam.
- **arquivos** (Modificar): os 8 `skills/*/SKILL.md`.
- **Mapa de substituição** (aplicar em cada arquivo; só onde o termo é
  identificador de comando/categoria/estado):

  | Onde | Antes | Depois |
  |---|---|---|
  | título `# <nome> —`, "Usando <nome> para", "skill <nome>", "**<nome>**" em PRÓXIMA SKILL, "skill `<nome>`", `audora-commander:<nome>`, setas de roteamento `<nome> → <nome>` (inclusive a linha HOTFIX da tabela) | grafo / escopo / plano / executar / validar / depurar | graph / scope / plan / execute / validate / debug |
  | referência nominal à skill: "pela/da/à/via <nome>", "a executar decide", "Volte à executar", "e2e/escopo chamam", "fase escopo/plano", "pula escopo e plano" | idem | idem — e JUNTAR na mesma linha "skill\n  escopo" (plano l.67-68) |
  | categorias (`LEVE`, `MÉDIA`, `ALTA` como categoria) | LEVE / MÉDIA / ALTA | LIGHT / MEDIUM / HIGH |
  | estados (crase, `estado:` ou coluna `\| x \|`) | planejada / em-curso / bloqueada / entregue / descartada / hotfix-pendente-registro | planned / in-progress / blocked / delivered / discarded / hotfix-pending-record |
  | frontmatter linha 3 | `description: texto` | `description: 'texto'` (aspas simples; prosa intacta) |
  | NÃO trocar | `docs/audora/planos/plano-<id>.md`, "plano-arquivo", "o plano", "escopo" como substantivo ("reabertura de escopo", "fora-de-escopo"), "validação", "executar" como verbo comum, `GRAFO`, hooks `grafo-guard`/`grafo-validate`, linhas terminando em "skill" (plano l.67, validar l.90) | — |

  **Fronteira com a T3**: a 2.2 (graph) NÃO insere enum literal nem
  `hotfix-pending-record` — isso é T3(a). Em `skills/graph/SKILL.md` a T2
  toca só: título l.6, Anuncie l.12, grep de estado l.36, MÉDIA/ALTA l.78,
  LEVE l.79, `em-curso` l.86, l.98/100/103/107/111 (referências nominais a
  validar/escopo), `entregue` l.111/113 e formato coluna l.117, "skill
  validar" l.123, "skill plano" l.147.

- **done quando**: `grep -rnE "$P" skills/` → 0 linhas; `ML skills/*/SKILL.md`
  → vazio; todos os 8 SKILL.md ≤ 250 linhas; frontmatter/Lei de Ferro/
  Anuncie/PRÓXIMA SKILL presentes em cada um;
  `claude plugin validate .claude-plugin/plugin.json` → "✔ Validation passed"
  (valida plugin.json + frontmatter dos 8 SKILL.md; FALHA hoje).

Verificação (RED hoje: 93 linhas + `ML` → `skills/plano/SKILL.md:68` +
`claude plugin validate .claude-plugin/plugin.json` → exit 1 "YAML frontmatter
failed to parse"; GREEN: 0 / vazio / "✔ Validation passed"):

```bash
grep -rnE "$P" skills/ ; ML skills/*/SKILL.md ; wc -l skills/*/SKILL.md ; claude plugin validate .claude-plugin/plugin.json
```

Subtarefas (expandir na execução, uma skill por vez; cada uma = editar →
`grep -nE "$P" skills/<x>/SKILL.md` → 0 → commit
`git add skills/<x>/SKILL.md && git commit -m "feat(comandos-ingles/1.3,2.1,2.2): skill <x> em identificadores EN"`):
2.1 audora-commander (description entre aspas — GREEN da 2.1 inclui o
`claude plugin validate`; tabela de roteamento incl. linha HOTFIX; 4
perguntas; regras de categoria; red flags; "pela validar" l.57; PRÓXIMA
SKILL); 2.2 graph (lista da fronteira acima); 2.3 scope; 2.4 plan (juntar
l.67-68); 2.5 execute; 2.6 e2e (l.68, 79); 2.7 validate (l.30); 2.8 debug.

## Tarefa 3: Regra de migração PT→EN na skill `graph`

- **depende-de**: [2, 4]
- **requisito**:
  - comandos-ingles/3.2 — QUANDO a primeira escrita no GRAFO de um projeto
    (registrar-no, registrar-delta, compactar) encontrar qualquer estado em
    português O SISTEMA DEVE converter TODOS os estados PT→EN na mesma
    demanda — índice mestre, `docs/audora/nos/*.md`,
    `docs/audora/arquivo/*.md`, `GRAFO-ARQUIVO.md` legado e nós inline
    legados — antes de concluir a operação pedida. Em projeto v1 (monólito)
    a conversão cobre todos os estados do monólito na mesma edição, sem
    exigir migração v1→v2 além da on-touch já existente.
  - comandos-ingles/3.3 — QUANDO uma operação só de leitura
    (carregar-contexto, consulta estrutural por grep) encontrar estados em
    português O SISTEMA DEVE ler normalmente e avisar que a migração ocorrerá
    na primeira escrita — leitura nunca migra.
  - comandos-ingles/3.5 (parte skill) — skill é a fonte normativa da
    migração (sem bash / v1).
- **decisões relevantes**: tabela de mapeamento no template (T4), skill só
  referencia; teto 250 linhas (graph hoje 167); "migração" de SCHEMA é
  on-touch, de ESTADO é total — a skill precisa dizer isso com o substantivo.
- **interfaces**:
  - consome: `templates/no-template.md` com a tabela PT→EN (T4 — verificar
    `grep -c 'hotfix-pendente-registro→hotfix-pending-record' templates/no-template.md` → 1).
  - produz: subseção "Migração de estado PT→EN" citada pelo hook (T5,
    mensagem) e pelo README (T7).
- **arquivos**: Modificar `skills/graph/SKILL.md`.
- **done quando**: a skill contém (a) enum EN literal em registrar-no
  (`planned | in-progress | blocked | delivered | discarded` + transitório
  `hotfix-pending-record`); (b) na "Regra de leitura seletiva": detecção de
  estado PT (`grep -lE "^estado: $ST" docs/audora/nos/*.md` + coluna 2 do
  índice) com aviso "migração na primeira escrita — leitura nunca migra";
  (c) em registrar-no/registrar-delta/compactar: passo 0 "estado PT
  detectado → converter TODOS (índice, nos/, arquivo/, GRAFO-ARQUIVO.md,
  inline) pela tabela de `templates/no-template.md` antes da operação";
  (d) em "Modo compat v1": conversão de todos os estados do monólito na
  mesma edição; (e) red flag nova "Converto só o ESTADO do nó que toquei, o
  resto depois" | "Estado PT→EN é total na primeira escrita (3.2); schema é
  que é on-touch"; (f) red flag l.158 reescrita: "Migro o SCHEMA v1 inteiro
  de uma vez, fica limpo" | "Schema é on-touch (só nós tocados). Estado
  PT→EN é o contrário: converte TODOS na primeira escrita"; (g) l.141:
  "nunca precisam migrar de schema ... — mas o campo de estado deles
  converte PT→EN junto com o resto"; (h) ≤ 250 linhas.

Passos:

- [ ] **1. RED** — `grep -c 'PT→EN\|hotfix-pending-record' skills/graph/SKILL.md` → 0 (garantido pela fronteira da T2.2); `grep -c 'Migração em lote é big-bang' skills/graph/SKILL.md` → 1.
- [ ] **2. Escrever** as inserções (a)–(g).
- [ ] **3. GREEN** — `grep -c 'PT→EN' skills/graph/SKILL.md` ≥ 3 (leitura, escrita, compat); `grep -c 'Migração em lote é big-bang'` → 0; `grep -c 'Schema é on-touch'` → 1; `grep -c 'hotfix-pending-record'` ≥ 1; `wc -l` ≤ 250; `grep -nE "$P" skills/graph/SKILL.md` → 0.
- [ ] **4. Commit** — `git add skills/graph/SKILL.md && git commit -m "feat(comandos-ingles/3.2,3.3): migracao de estado PT->EN na skill graph"`.

## Tarefa 4: Templates — enum EN + tabela de mapeamento

- **depende-de**: [1]
- **requisito**: comandos-ingles/3.1 — QUANDO um nó for criado ou atualizado
  O SISTEMA DEVE gravar `estado:` com valor do enum em inglês
  (`planned | in-progress | blocked | delivered | discarded`, mais o
  transitório `hotfix-pending-record`), no arquivo do nó E na linha do índice.
  Também 1.3 e 2.2 nos templates.
- **decisões relevantes**: chaves de frontmatter, seções e caminhos ficam;
  tabela PT→EN vive no comentário do no-template; GRAFO-template l.62 ganha o
  qualificador "de SCHEMA".
- **interfaces**: produz a tabela que T3 (skill graph) e T5 (mensagem do
  hook) referenciam por caminho `templates/no-template.md`.
- **arquivos** (Modificar — 4 templates): `templates/no-template.md` (l.3
  `estado: planejada`, enum comentado l.15-16, "sync da\n validar" l.20-21
  → juntar na linha, "skill validar" l.53); `templates/GRAFO-template.md`
  (exemplo l.33, regras 0/2/3/5 — `planejada`, `em-curso`, `entregue`,
  "skill grafo" l.35; l.62 → "migração de SCHEMA on-touch pela skill graph,
  nunca em lote forçado; estados PT→EN convertem todos de uma vez na
  primeira escrita"); `templates/GRAFO-template-v1.md` (l.29, 36-38, 64-71,
  "skill grafo" l.63); `templates/decisoes-vivas-template.md` (l.3 "sync da
  validar", l.11 "skill grafo/validar"). `templates/plano-template.md` e
  `templates/e2e-infra-template.md`: 0 matches — não tocar.
- **done quando**: grep abaixo = 0 linhas; no-template contém a tabela (cada
  linha PT contém `→`):

  ```
  <!-- Migração de estado PT→EN (skill graph, primeira escrita no projeto):
       planejada→planned | em-curso→in-progress | bloqueada→blocked |
       entregue→delivered | descartada→discarded |
       hotfix-pendente-registro→hotfix-pending-record -->
  ```

Passos:

- [ ] **1. RED** — `grep -rnE "$P|${B}$ST$E" templates/` → 25 linhas hoje (GRAFO-template, v1, no-template, decisoes-vivas; plano/e2e-infra 0).
- [ ] **2. Editar** os 4 templates pelo mapa da T2 + inserir a tabela.
- [ ] **3. GREEN** — `grep -rnE "$P|${B}$ST$E" templates/ | grep -vE "$X_TPL"` → 0; positivo: `grep -oE '(planejada→planned|em-curso→in-progress|bloqueada→blocked|entregue→delivered|descartada→discarded|hotfix-pendente-registro→hotfix-pending-record)' templates/no-template.md | sort -u | wc -l` → 6; `ML templates/*.md` → vazio.
- [ ] **4. Commit** — `git add templates/ && git commit -m "feat(comandos-ingles/3.1): enum de estado EN nos templates + tabela PT->EN"`.

## Tarefa 5: Hooks — ponteiro EN e enum no validate

- **depende-de**: [1, 4]
- **requisito**:
  - comandos-ingles/1.2 — QUANDO uma sessão iniciar com o plugin ativo
    O SISTEMA DEVE injetar o ponteiro do hook citando os comandos pelos nomes
    em inglês.
  - comandos-ingles/3.4 — QUANDO o hook `grafo-validate` rodar sobre um
    GRAFO v2 cujo índice contenha estado fora do enum em inglês O SISTEMA
    DEVE acusar (exit 2) com mensagem apontando a migração PT→EN pela skill
    `graph`.
  - comandos-ingles/3.5 — QUANDO o hook rodar sem bash ou sobre GRAFO v1
    O SISTEMA DEVE manter o comportamento atual (exit 0 / degradação).
- **decisões relevantes**: nomes de arquivo dos hooks ficam; falha de hook
  nunca quebra o fluxo (na dúvida exit 0); LF obrigatório (.gitattributes já
  cobre `hooks/*`); linha sem coluna de estado = erro de formato, não
  "migração pendente".
- **interfaces**:
  - consome: enum EN e tabela (T4 — `grep -c 'hotfix-pendente-registro→hotfix-pending-record' templates/no-template.md` → 1); nome `graph` (T1).
  - produz: mensagem `grafo-validate: ... estado '<x>' fora do enum ...` que
    o README (T7) descreve.
- **arquivos** (Modificar): `hooks/session-start` (string `contexto`),
  `hooks/grafo-validate` (bloco linhas 34-48, comentário `# 1.` incluído),
  `hooks/grafo-guard` (mensagens linhas 22/30: "skill grafo" → "skill graph").
- **done quando**: bateria abaixo passa com saídas lidas.

Código — `hooks/session-start`, nova string:

```bash
contexto="Framework audora-commander ativo. Ao receber demanda de software (criar, alterar, corrigir), invoque a skill \`audora-commander:audora-commander\` ANTES de agir. Fluxos de fase: graph, scope, plan, execute, e2e, validate; bug ou comportamento inesperado: debug. Instrução direta do usuário vale mais que o framework."
```

Código — `hooks/grafo-validate`, substituir o bloco das linhas 34-48
(comentário `# 1.` + while inteiro até `EOF_IDX`) por:

```bash
# 1. estado fora do enum EN (migração PT→EN pendente), linha sem estado,
#    e nó ativo sem corpo (arquivo ou inline legado)
while IFS= read -r linha; do
  [ -n "$linha" ] || continue
  id="$(printf '%s' "$linha" | sed 's/^- *\([^ |]*\).*/\1/')"
  estado="$(printf '%s' "$linha" | awk -F'|' 'NF>1 {gsub(/ /,"",$2); print $2}')"
  if [ -z "$estado" ]; then
    erros="$erros
- linha do índice sem coluna de estado: '$linha' — formato é \`- <id> | <estado> | <título> | <resumo> | <keywords> | <arquivos>\` (templates/GRAFO-template.md)"
    continue
  fi
  case "$estado" in
    planned|in-progress|blocked|delivered|discarded|hotfix-pending-record) ;;
    *) erros="$erros
- nó '$id' com estado '$estado' fora do enum (planned|in-progress|blocked|delivered|discarded|hotfix-pending-record) — migração PT→EN pendente: skill graph converte TODOS os estados na primeira escrita (tabela em templates/no-template.md)" ;;
  esac
  case "$estado" in
    in-progress|blocked)
      if [ ! -f "$nos_dir/$id.md" ] && ! printf '%s\n' "$inline_ids" | grep -qx "$id"; then
        erros="$erros
- nó '$id' ($estado) sem arquivo docs/audora/nos/$id.md e sem corpo inline"
      fi ;;
  esac
done <<EOF_IDX
$idx
EOF_IDX
```

Fixtures — `SP="$(mktemp -d)"` (path POSIX; nunca o scratchpad `C:\...` sem
`cygpath -u`); helper (escapa backslash — JSON inválido faz o hook sair 0 em
silêncio):

```bash
run() { p="${1//\\/\\\\}"; printf '{"tool_input":{"file_path":"%s"}}' "$p" | bash hooks/grafo-validate; echo "exit=$?"; }
mk() { d="$SP/$1"; mkdir -p "$d/docs/audora/nos"; printf 'versao-schema: %s\n\n## Índice de nós [carga: sempre]\n\n%s\n\n## Fim\n' "$2" "$3" > "$d/GRAFO.md"; }
mk pt        2 '- x | em-curso | X | r | k | —';            printf -- '---\nid: x\nestado: em-curso\n---\n' > "$SP/pt/docs/audora/nos/x.md"
mk pt-sem    2 '- x | em-curso | X | r | k | —'             # sem x.md (controle: hook ATUAL deve acusar "sem arquivo")
mk en        2 '- x | in-progress | X | r | k | —';         printf -- '---\nid: x\nestado: in-progress\n---\n' > "$SP/en/docs/audora/nos/x.md"
mk en-sem    2 '- x | in-progress | X | r | k | —'          # sem x.md
mk v1        1 '- x | em-curso | X'
mk legado    2 '- x | delivered | X → ver docs/audora/GRAFO-ARQUIVO.md'
mk sempipe   2 $'- nota sem pipe\n- y | planned | Y | r | k | —'; printf -- '---\nid: y\nestado: planned\n---\n' > "$SP/sempipe/docs/audora/nos/y.md"
mk vazio     2 ''
```

Passos:

- [ ] **1. RED** (hook ATUAL) — `run $SP/pt-sem/GRAFO.md` → stderr "sem arquivo" + `exit=2` (prova que o JSON chega ao hook); `run $SP/pt/GRAFO.md` → `exit=0` (deveria ser 2 — red pelo motivo certo); `bash hooks/session-start | grep -c 'graph, scope, plan'` → 0.
- [ ] **2. Editar** os 3 hooks (código acima).
- [ ] **3. GREEN** —
  - `run $SP/pt/GRAFO.md` → stderr contém "fora do enum" e "skill graph", `exit=2`;
  - `run $SP/en/GRAFO.md` → `exit=0`, stderr vazio;
  - `run $SP/en-sem/GRAFO.md` → "sem arquivo" + `exit=2`;
  - `run $SP/v1/GRAFO.md` → `exit=0` (3.5);
  - `run $SP/legado/GRAFO.md` → `exit=0`;
  - `run $SP/sempipe/GRAFO.md` → stderr contém "sem coluna de estado", NÃO contém "migração PT→EN", `exit=2`;
  - `run $SP/vazio/GRAFO.md` → `exit=0`;
  - `run $SP/qualquer.txt` → `exit=0`;
  - `bash hooks/session-start | grep -c 'graph, scope, plan, execute, e2e, validate'` → 1; `| grep -c 'debug'` → 1; JSON válido: `bash hooks/session-start | perl -MJSON::PP -e 'decode_json(join"",<STDIN>)'` sem erro;
  - `bash -n hooks/grafo-validate` ok; `grep -c '^# 1\.' hooks/grafo-validate` → 1;
  - LF: `git ls-files --eol hooks | grep -vc 'w/lf'` → 0 (após `git add`) e `for f in hooks/grafo-validate hooks/session-start hooks/grafo-guard; do printf '%s %s\n' "$f" "$(tr -cd '\r' < "$f" | wc -c)"; done` → todos 0 (NUNCA `grep -c $'\r'` — falso-negativo no grep msys);
  - `grep -nE "$P" hooks/` → 0.
- [ ] **4. Commit** — `git add hooks/session-start hooks/grafo-validate hooks/grafo-guard && git commit -m "feat(comandos-ingles/1.2,3.4,3.5): hook cita nomes EN; validate acusa estado fora do enum"`.

## Tarefa 6: Dogfood — GRAFO deste repo em EN

- **depende-de**: [4, 5]
- **requisito**: comandos-ingles/4.3 — QUANDO o GRAFO deste repositório for
  lido após a entrega O SISTEMA DEVE estar integralmente no enum EN (índice,
  nós ativos, arquivo, GRAFO-ARQUIVO.md) e os critérios ativos que citam
  categoria (`plugin-v0.1.0/5`) atualizados via delta MODIFICADO. Exercita
  3.2 de verdade (este repo é o primeiro projeto migrado).
- **decisões relevantes**: índice e nós na mesma edição — ÍNDICE PRIMEIRO
  (se o cache já tiver o hook novo, editar nó antes do índice dispara 12
  erros); decisão superada recebe `invalidado-em`; prosa histórica intacta;
  decisões de `decisoes-vivas.md` intactas (só o comentário de regras muda).
- **interfaces**: consome enum EN (T4) e o hook novo (T5) rodado LOCAL
  (`run GRAFO.md` do repo, não o cache).
- **arquivos** (Modificar): `GRAFO.md` (12 estados nas linhas 34-45 + l.47
  "(skill grafo)" → "(skill graph)"), `docs/audora/nos/plugin-v0.1.0.md`
  (l.3 `estado:`; delta MODIFICADO do critério 5 "LEVE e uma MÉDIA" → "LIGHT
  e uma MEDIUM"; decisão l.41-42 + `[invalidado-em: 2026-08-25]
  [substituido-por: comandos-ingles]`), `docs/audora/nos/comandos-ingles.md`
  (l.3), `docs/audora/arquivo/2026-08-25-grafo-v2.md` (l.3),
  `docs/audora/GRAFO-ARQUIVO.md` (headings l.6, 29, 56 "(entregue" →
  "(delivered"), `docs/audora/decisoes-vivas.md` (l.18 "skill grafo/validar"
  → "skill graph/validate"; l.9-16 intactas).
- **done quando**: `run GRAFO.md` (hook local da T5) → `exit=0`; greps abaixo.

Passos:

- [ ] **1. RED** — `run GRAFO.md` (hook novo, local) → `exit=2` com 12 linhas "fora do enum" (2 em-curso + 6 planejada + 4 entregue); `grep -rnE "^estado: $ST|\| $ST \||\(entregue 20" GRAFO.md docs/audora/nos docs/audora/arquivo docs/audora/GRAFO-ARQUIVO.md` → 18 linhas (12 + 2 + 1 + 3); `grep -nE 'skill (grafo|validar)' GRAFO.md docs/audora/decisoes-vivas.md` → 2 linhas.
- [ ] **2. Editar** — GRAFO.md primeiro, depois nós + arquivo + GRAFO-ARQUIVO + decisoes-vivas l.18; delta e invalidado-em em plugin-v0.1.0.
- [ ] **3. GREEN** — `run GRAFO.md` → `exit=0`; grep de estados do passo 1 → 0; `grep -nE 'skill (grafo|validar)' GRAFO.md docs/audora/decisoes-vivas.md` → 0; `grep -c 'in-progress' GRAFO.md` → 2; `grep -c 'planned' GRAFO.md` → 6; `grep -c '| delivered |' GRAFO.md` → 4; `grep -c 'invalidado-em: 2026-08-25' docs/audora/nos/plugin-v0.1.0.md` → 1; `grep -c 'LIGHT e uma MEDIUM' docs/audora/nos/plugin-v0.1.0.md` → 1 (no delta).
- [ ] **4. Commit** — `git add GRAFO.md docs/audora/nos/plugin-v0.1.0.md docs/audora/nos/comandos-ingles.md docs/audora/arquivo/2026-08-25-grafo-v2.md docs/audora/GRAFO-ARQUIVO.md docs/audora/decisoes-vivas.md && git commit -m "feat(comandos-ingles/4.3,3.2): GRAFO deste repo migrado para enum EN (dogfood)"`.

## Tarefa 7: READMEs (tabela PT→EN, breaking 0.3.0) + versão

- **depende-de**: [2, 4, 5]
- **requisito**:
  - comandos-ingles/4.1 — QUANDO o usuário abrir `README.md` ou
    `README.pt-BR.md` O SISTEMA DEVE apresentar a tabela de renomeação PT→EN
    (comandos, categorias, estados) e a nota de breaking change 0.3.0.
  - comandos-ingles/4.2 — QUANDO o plugin for listado O SISTEMA DEVE exibir
    versão `0.3.0` (plugin.json, marketplace.json e PRD coerentes — PRD no
    sync da validar).
  - comandos-ingles/1.3 e 2.2 nos READMEs.
- **decisões relevantes**: paridade EN/PT (nó docs-bilingues: seções 1:1,
  blocos de código idênticos com placeholders `<...>` normalizados, tokens
  literais nunca traduzidos); a seção de renomeação é a ÚNICA exceção de PT
  como identificador nos READMEs (excluída do grep por `NOSEC`);
  fundamentos.md fica em PT com aviso (decisão acima).
- **interfaces**: consome nomes (T1), categorias (T2), enum (spec/T4),
  mensagem do hook (T5).
- **arquivos** (Modificar): `README.md`, `README.pt-BR.md`,
  `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`.
- **Conteúdo** (README.md; PT espelha com títulos traduzidos):
  - Princípio 4: "LIGHT, MEDIUM, HIGH and HOTFIX demands…".
  - Tabela "The 8 skills": `graph`, `scope`, `plan`, `execute`, `validate`,
    `debug` (papéis inalterados); artefatos: "(debug skill)"; "specs for HIGH
    demands".
  - Fluxo de uso: "example: a MEDIUM demand"; passo 2 "MEDIUM"; passos 3-6
    com `scope`, `plan`, `execute`, `validate`.
  - Checklist 5: "WHEN a LIGHT and a MEDIUM demand…"; "plan file for the
    MEDIUM".
  - Seção nova antes de "Development": `## Renamed in 0.3.0 (breaking)` /
    `## Renomeado em 0.3.0 (breaking)` — 3 tabelas (commands / risk
    categories / node states) com o dicionário da spec (PT em texto puro na
    coluna "Before"), e os parágrafos: old command names no longer exist (no
    aliases); existing GRAFOs are migrated in full by the `graph` skill on
    the first write — until then `grafo-validate` reports "estado fora do
    enum"; `docs/fundamentos.md` still uses the pre-0.3.0 names.
  - `plugin.json` e `marketplace.json`: `"version": "0.3.0"`.
- **done quando**: greps abaixo; paridade de seções (`grep -c '^## '` → 9 em
  cada); blocos de código idênticos com placeholders normalizados; JSON e
  manifesto válidos.

Passos:

- [ ] **1. RED** — `for f in README.md README.pt-BR.md; do NOSEC $f | grep -nE "$P|depurar skill|skill depurar"; done` → 36 linhas hoje; `grep -c '0.3.0' .claude-plugin/*.json` → 0; `grep -c '^## .*0\.3\.0' README.md README.pt-BR.md` → 0 cada.
- [ ] **2. Editar** os 4 arquivos.
- [ ] **3. GREEN** —
  - `for f in README.md README.pt-BR.md; do NOSEC $f | grep -nE "$P|depurar skill|skill depurar"; done` → 0;
  - `grep -c '^## .*0\.3\.0' README.md README.pt-BR.md` → 1 cada; positivo da tabela: `grep -c 'LEVE / MÉDIA / ALTA / HOTFIX' README.md README.pt-BR.md` → 1 cada; `grep -cE 'grafo.*graph|planejada.*planned|hotfix-pendente-registro.*hotfix-pending-record' README.md README.pt-BR.md` ≥ 1 cada; `grep -c 'fundamentos.md' README.md README.pt-BR.md` ≥ 2 cada;
  - paridade: `grep -c '^## ' README.md README.pt-BR.md` → 9 e 9;
  - blocos: `diff <(sed -n '/^```/,/^```/p' README.md | sed 's/<[^>]*>/<PH>/g') <(sed -n '/^```/,/^```/p' README.pt-BR.md | sed 's/<[^>]*>/<PH>/g')` vazio;
  - `grep -c '"version": "0.3.0"' .claude-plugin/plugin.json .claude-plugin/marketplace.json` → 1 cada; `perl -MJSON::PP -e 'decode_json(join"",<STDIN>)' < .claude-plugin/plugin.json` ok (idem marketplace.json); `claude plugin validate .` → "✔ Validation passed" e `claude plugin validate . 2>&1 | grep -ci warning` → 0; `claude plugin validate .claude-plugin/plugin.json` → "✔ Validation passed".
- [ ] **4. Commit** — `git add README.md README.pt-BR.md .claude-plugin/plugin.json .claude-plugin/marketplace.json && git commit -m "docs(comandos-ingles/4.1,4.2): tabela PT->EN nos READMEs, breaking 0.3.0"`.

## Tarefa 8: Reinstalação real + verificação 1:1 + revisão adversarial

- **depende-de**: [3, 6, 7]
- **requisito**: comandos-ingles/1.1 exercitado no plugin instalado; mapa
  1:1 dos 13 critérios → evidência (para o roteiro da validar).
- **decisões relevantes**: ALTA exige revisão adversarial (validar item 3);
  instalação é a única "execução" do plugin; PRD só muda no sync.
- **arquivos**: nenhum novo (evidência vai para o roteiro da validar); ajustes
  da rodada adversarial nos arquivos já listados nas tarefas.
- **done quando**: cache do plugin em `~/.claude/plugins/cache/audora-commander-dev/audora-commander/0.3.0/skills/` lista exatamente `audora-commander debug e2e execute graph plan scope validate`; hooks e skills do cache = repo; grep global final = 0; tabela critério→evidência completa; achados da revisão adversarial corrigidos e re-testados.

Passos:

- [ ] **1. Reinstalar** — `./install.sh` (idempotente) e `claude plugin update audora-commander@audora-commander-dev`; ler `~/.claude/plugins/installed_plugins.json` → `"version": "0.3.0"`. Sessão nova/`/clear` depois (hook SessionStart).
- [ ] **2. Verificar** — `C=~/.claude/plugins/cache/audora-commander-dev/audora-commander/0.3.0`; `ls $C/skills` → 8 nomes EN; `diff -r skills $C/skills` e `diff -r hooks $C/hooks` vazios; grep global final: `grep -rnE "$P" skills hooks install.sh install.cmd .claude-plugin GRAFO.md docs/audora/decisoes-vivas.md` → 0; `grep -rnE "$P|${B}$ST$E" templates/ | grep -vE "$X_TPL"` → 0; `for f in README.md README.pt-BR.md; do NOSEC $f | grep -nE "$P"; done` → 0; `ML skills/*/SKILL.md templates/*.md` → vazio; PRD em linha separada: `grep -cE "$P" PRD.md` → ≠ 0 AGORA (esperado 0 só após o sync da validar — registrar como pendente).
- [ ] **3. Revisão adversarial** — subagentes de contexto limpo com diff + spec, 3 lentes (cobertura dos 13 critérios; consistência de nomes entre skills/hook/README/templates; hooks/bash/Windows: CRLF, exit codes, fixtures). Corrigir achados verificados, re-rodar baterias T5/T6/T7.
- [ ] **4. Montar tabela critério → evidência** (13 linhas) para o roteiro; itens do roteiro humano: 1.1 (listagem interativa), 2.1 (anúncio ao vivo), 1.3-PRD e 4.2-PRD (pendente sync).
- [ ] **5. Commit** de fechamento, se houver ajuste — `git add <arquivos ajustados> && git commit -m "chore(comandos-ingles): rodada adversarial e verificacao final"`.
