# Plano — memory-fatiada: skill memory vira roteador + references

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** cortar 45% do custo de carga da skill mais chamada do framework,
movendo as 4 operações grandes/frias para `skills/memory/references/` sem
tocar no contrato das 7 operações.

**Nó do MEMORY:** `memory-fatiada` (MEMORY.md)

**Arquitetura da mudança:** `skills/memory/SKILL.md` fica com cabeçalho, bloco
de schema, regra de leitura seletiva, as 3 operações quentes e pequenas inline
(1 carregar-contexto, 4 registrar-delta, 5 registrar-aprendizado), uma tabela
de roteamento das 7 operações, conflito MEMORY vs código, red flags e PRÓXIMA
SKILL. As 4 grandes/frias viram um arquivo cada em `skills/memory/references/`.
A suíte deixa de fazer `cat SKILL.md` e passa a asserir cada string no arquivo
CERTO (roteador OU reference específica) — contrato mais forte que o de hoje,
não mais fraco, porque hoje um `cat` único não distingue localização.

**Arquivos lidos antes de planejar:**
- `skills/memory/SKILL.md` — as 7 operações e o tamanho de cada seção (medido:
  bootstrap 36l/2226b, registrar-no 18l/1114b, compactar 25l/1464b,
  consultar-codigo 28l/1731b; total a sair 107l/6535b de 226l/13331b).
- `tests/test-skills.sh` — linha 9 (teto 250 só no SKILL.md), linhas 22-32
  (`m="$(cat skills/memory/SKILL.md)"` + 23 asserts de string + 7 de cabeçalho
  de operação): é o bloco que a fatia quebra.
- `tests/test-no-grafo.sh` — linha 10 (`grep -c GRAFO` só no SKILL.md) e linha
  13 (`ls -d skills/*/` = 9, NÃO afetada por subpasta).
- `tests/test-docs.sh` — linha 7 crava `"version": "0.5.0"` nos 2 manifests;
  linha 23 compara md5 dos blocos de código EN/PT dos READMEs.
- `tests/lib.sh` — asserts disponíveis: `assert_eq`, `assert_contains` (grep
  -qF), `assert_not_contains`, `assert_empty`, `assert_file`, `assert_no_file`.
- `.claude-plugin/plugin.json` e `.claude-plugin/marketplace.json` — versão
  0.5.0 nos dois.
- `README.md` / `README.pt-BR.md` — linha 99/100 (tabela de skills) e 124-127
  (layout de arquivos).
- `PRD.md` — seção Arquitetura descreve as operações da skill memory.
- `templates/plano-template.md` — formato deste arquivo.

**Conflitos MEMORY vs código encontrados:** nenhum. Anotado o acoplamento:
`skills/memory/` é governada pelo nó `memory-graphify`, ainda `in-progress` —
esta demanda altera estrutura, não contrato, então não reabre aquele nó.
A Constituição diz "cada SKILL.md ≤ 250 linhas"; a T3 estende o bullet para
cobrir `references/` (extensão, não contradição — decidido no portão de escopo).

## Notas de sessão

<!-- Despejar aqui ANTES de /clear no meio da demanda. -->

---

## Tarefa 1: suíte assere por localização (RED)

- **depende-de**: []
- **requisito**:
  - **memory-fatiada/1** — QUANDO uma fase invocar a skill memory para uma
    operação que ficou inline (carregar-contexto, registrar-delta,
    registrar-aprendizado) O SISTEMA DEVE executá-la sem abrir nenhum arquivo
    de reference
  - **memory-fatiada/2** — QUANDO uma fase invocar a skill memory para uma
    operação movida (bootstrap, registrar-no, compactar, consultar-codigo) O
    SISTEMA DEVE ler exatamente um arquivo de reference — o daquela operação —
    e nenhum outro
  - **memory-fatiada/3** — QUANDO a skill memory for carregada O SISTEMA DEVE
    apresentar uma tabela que mapeia cada uma das 7 operações ao seu local
    (inline, ou caminho do arquivo de reference)
  - **memory-fatiada/4** — QUANDO um arquivo de reference apontado pela tabela
    não existir ou não puder ser lido O SISTEMA DEVE avisar em 1 linha qual
    faltou e seguir a operação pelo que o roteador ainda garante (Lei de Ferro,
    schema, regra de leitura seletiva), sem travar a fase
  - **memory-fatiada/6** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
    reprovar se `skills/memory/SKILL.md` ou qualquer arquivo em
    `skills/memory/references/` passar de 250 linhas
  - **memory-fatiada/7** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
    reprovar se alguma das 7 operações não for alcançável pela tabela do
    roteador — operação sem entrada na tabela, ou entrada apontando para
    reference inexistente
- **decisões relevantes**: híbrido (3 inline / 4 reference); teto único de 250
  linhas para SKILL.md e references; `assert_contains` é `grep -qF`, então
  string que quebra de linha no Markdown NUNCA casa (aprendizado de 2026-08-27)
  — toda string asserida tem de caber em UMA linha do arquivo.
- **interfaces**:
  - consome: `tests/lib.sh` — `assert_contains "$conteudo" "$string" "$msg"`,
    `assert_not_contains`, `assert_file`, `ok`, `ko`, `report`.
  - produz: nada para outras tarefas (é teste).
- **arquivos**:
  - Modificar: `tests/test-skills.sh` (substituir o bloco das linhas 22-32;
    estender o teto da linha 9)
  - Modificar: `tests/test-no-grafo.sh` (estender a checagem de GRAFO às
    references)
- **done quando**: `bash tests/run.sh` sai 1 e as falhas citam
  `skills/memory/references/*` ausentes — falha por feature ausente, nunca por
  erro de sintaxe do teste.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever teste que falha** — em `tests/test-skills.sh`, trocar a
  linha 9 por um teto que cobre SKILL.md e references, e substituir o bloco
  22-32 pelo abaixo:

```bash
  for g in "$f" "skills/$s/references"/*.md; do
    [ -f "$g" ] || continue
    [ "$(wc -l < "$g")" -le 250 ] && ok || ko "$g > 250 linhas"
  done
```

```bash
MS="skills/memory/SKILL.md"; MR="skills/memory/references"
m="$(cat "$MS" 2>/dev/null)"
# /3 — tabela do roteador nomeia as 7 operações
for op in carregar-contexto bootstrap registrar-no registrar-delta \
          registrar-aprendizado compactar consultar-codigo; do
  assert_contains "$m" "$op" "/3 tabela do roteador cita $op"
done
# /1 — as 3 quentes ficam com o CORPO no roteador
assert_contains "$m" '### 1. carregar-contexto' "/1 carregar-contexto inline"
assert_contains "$m" '### 4. registrar-delta' "/1 registrar-delta inline"
assert_contains "$m" '### 5. registrar-aprendizado' "/1 registrar-aprendizado inline"
# /3 — a tabela é tabela: cada linha casa operação com localização
for op in carregar-contexto registrar-delta registrar-aprendizado; do
  assert_contains "$m" "| $op | inline |" "/3 linha de tabela: $op inline"
done
# /7 — as 4 movidas existem e estão na tabela, com a linha completa
for b in bootstrap registrar-no compactar consultar-codigo; do
  assert_file "$MR/$b.md" "/7 reference $b existe"
  assert_contains "$m" "| $b | references/$b.md |" "/7 linha de tabela: $b"
done
# /7 — nenhuma reference órfã (arquivo fora da tabela)
for g in "$MR"/*.md; do
  [ -f "$g" ] || continue
  assert_contains "$m" "references/$(basename "$g")" "/7 sem órfã: $(basename "$g")"
done
# /2 — conteúdo de cada operação movida está na SUA reference
for s in 'hooks/graphify-status' 'uv tool install graphifyy' 'pipx install graphifyy' 'graphify --version' 'graphify update .' 'graphify hook install' 'graphify-out/' '.gitignore' 'graphify: ativo' 'graphify: recusado' 'graphify: sem-codigo'; do
  assert_contains "$(cat "$MR/bootstrap.md" 2>/dev/null)" "$s" "/2 bootstrap cita '$s'"
done
for s in 'graphify query' 'graphify path' 'graphify affected' '--budget' 'src='; do
  assert_contains "$(cat "$MR/consultar-codigo.md" 2>/dev/null)" "$s" "/2 consultar-codigo cita '$s'"
done
for s in 'docs/audora/arquivo/' 'aprendizados-historico.md' 'git mv'; do
  assert_contains "$(cat "$MR/compactar.md" 2>/dev/null)" "$s" "/2 compactar cita '$s'"
done
for s in 'no-template.md' 'hotfix-pending-record' 'planned | in-progress'; do
  assert_contains "$(cat "$MR/registrar-no.md" 2>/dev/null)" "$s" "/2 registrar-no cita '$s'"
done
# /2 — o roteador NÃO carrega o corpo movido (move, não copia)
for s in 'uv tool install graphifyy' 'pipx install graphifyy' 'graphify hook install' '--budget' 'graphify path' 'aprendizados-historico.md'; do
  assert_not_contains "$m" "$s" "/2 roteador sem corpo movido: '$s'"
done
# /1 — o que É do roteador continua nele
for s in 'memory-schema: 1' 'docs/audora/memory/' 'memory-validate' 'memory-guard' 'Aprendizados' '| <fase> |'; do
  assert_contains "$m" "$s" "/1 roteador cita '$s'"
done
assert_contains "$m" 'GRAFO.md' "/3 memory avisa sobre GRAFO.md antigo"
assert_eq "1" "$(grep -c 'GRAFO.md' "$MS" 2>/dev/null)" "/3 GRAFO.md só no aviso"
# /4 — degradação declarada no roteador
assert_contains "$m" 'reference ausente' "/4 roteador declara reference ausente"
assert_contains "$m" 'sem travar a fase' "/4 roteador degrada sem travar"
assert_not_contains "$m" 'PT→EN' "memory sem migração PT→EN"
assert_not_contains "$m" 'versao-schema' "memory sem schema v1/v2"
```

  E em `tests/test-no-grafo.sh`, depois da linha 10:

```bash
r="$(LC_ALL=C.UTF-8 grep -rc 'GRAFO' skills/memory/references 2>/dev/null | grep -v ':0$' || true)"
assert_empty "$r" "memory-graphify/1 reference cita GRAFO"
```

- [ ] **2. Rodar e ver falhar pelo motivo certo** — `bash tests/run.sh`.
  Esperado: exit 1, com `FAIL: /7 reference bootstrap existe — arquivo ausente:
  skills/memory/references/bootstrap.md` e irmãs. Falha por reference ausente,
  não por sintaxe.
- [ ] **3. Implementar o mínimo para passar** — nada nesta tarefa; a
  implementação é a Tarefa 2. Esta tarefa entrega o RED.
- [ ] **4. Rodar e ver passar** — não se aplica aqui; o green vem na Tarefa 2.
- [ ] **5. Commit** — `git add tests/test-skills.sh tests/test-no-grafo.sh && git commit -m "test(memory-fatiada/1,2,3,4,6,7): RED — suite assere por localizacao, references ainda nao existem"`

---

## Tarefa 2: fatiar a skill (GREEN)

- **expandir: sim** — quebrar em subtarefas (uma por reference + o roteador)
  SÓ quando chegar a vez dela. Não detalhar agora.
- **depende-de**: [Tarefa 1]
- **requisito**:
  - **memory-fatiada/1**, **/2**, **/3**, **/4** (verbatim na Tarefa 1)
  - **memory-fatiada/5** — QUANDO qualquer uma das 7 operações for invocada O
    SISTEMA DEVE produzir o mesmo resultado observável de antes da fatia:
    nomes, entradas, saídas e garantias das operações inalterados
- **decisões relevantes**: contrato das 7 operações preservado (fora-de-escopo
  do nó proíbe mudar nome, entrada, saída ou garantia); reference ausente avisa
  e degrada; conteúdo em português; `references/` é Markdown, então não fere a
  restrição de "código executável só em hooks/ e tests/".
- **interfaces**:
  - consome: as strings exatas que a Tarefa 1 assere em cada arquivo.
  - produz: `skills/memory/references/{bootstrap,registrar-no,compactar,consultar-codigo}.md`
    e `skills/memory/SKILL.md` reescrito como roteador.
- **arquivos**:
  - Criar: `skills/memory/references/bootstrap.md`
  - Criar: `skills/memory/references/registrar-no.md`
  - Criar: `skills/memory/references/compactar.md`
  - Criar: `skills/memory/references/consultar-codigo.md`
  - Modificar: `skills/memory/SKILL.md`
- **done quando**: `bash tests/run.sh` verde (todos os arquivos de teste
  PASS, FAIL=0) e `wc -c skills/memory/SKILL.md` ≤ 7600 bytes.

---

## Tarefa 3: Constituição, versão e docs

- **depende-de**: [Tarefa 2]
- **requisito**:
  - **memory-fatiada/6** (verbatim na Tarefa 1) — a Constituição precisa
    autorizar o teto que a suíte cobra.
  - **memory-fatiada/8** — QUANDO o plugin for instalado a partir do
    marketplace O SISTEMA DEVE entregar os arquivos de `references/` junto com
    a skill; instalação sem eles é instalação quebrada, não degradação
    aceitável
- **decisões relevantes**: `claude plugin update` só refaz o cache com bump de
  versão (aprendizado de 2026-08-25) — sem bump, a instalação de teste do /8
  roda contra o cache velho e dá falso verde. Bump é pré-condição do e2e, não
  enfeite. Contrato preservado ⇒ minor, não major: 0.5.0 → 0.6.0.
- **interfaces**:
  - consome: os caminhos `skills/memory/references/*.md` criados na Tarefa 2.
  - produz: nada para tarefas seguintes.
- **arquivos**:
  - Modificar: `MEMORY.md` (bullet `restricoes` da Constituição: "cada SKILL.md
    ≤ 250 linhas" → "cada SKILL.md e cada arquivo de `skills/*/references/`
    ≤ 250 linhas")
  - Modificar: `.claude-plugin/plugin.json` (`"version": "0.6.0"`)
  - Modificar: `.claude-plugin/marketplace.json` (`"version": "0.6.0"`)
  - Modificar: `tests/test-docs.sh` (linha 7: `'"version": "0.6.0"'`)
  - Modificar: `README.md` e `README.pt-BR.md` (seção de layout: acrescentar
    `skills/memory/references/` — a MESMA linha nos dois, fora de bloco de
    código, para não quebrar o md5 dos blocos EN/PT da linha 23 do test-docs)
  - Modificar: `PRD.md` (Arquitetura: memory descrita como roteador +
    references; versão 0.6.0)
- **done quando**: `bash tests/run.sh` verde e
  `grep -c '"version": "0.6.0"' .claude-plugin/*.json` devolve 1 em cada.
  O /8 fica **provado só no e2e** (instalação real) — esta tarefa entrega a
  pré-condição, não a prova.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever teste que falha** — em `tests/test-docs.sh` linha 7, trocar
  `'"version": "0.5.0"'` por `'"version": "0.6.0"'`; e acrescentar ao fim:

```bash
assert_contains "$(cat MEMORY.md)" 'skills/*/references/' "/6 Constituição cobre references"
for r in README.md README.pt-BR.md; do
  assert_contains "$(cat "$r")" 'skills/memory/references/' "/8 $r cita references/"
done
```

- [ ] **2. Rodar e ver falhar pelo motivo certo** — `bash tests/run.sh`.
  Esperado: exit 1 com `FAIL: /19 .claude-plugin/plugin.json versão 0.6.0` e
  `FAIL: /6 Constituição cobre references`.
- [ ] **3. Implementar o mínimo para passar** — editar os 6 arquivos listados
  em **arquivos**, com o bullet da Constituição em uma linha só:
  `- **restricoes**: cada SKILL.md e cada arquivo de \`skills/*/references/\` ≤ 250 linhas; ...` (preservar o resto do bullet verbatim).
- [ ] **4. Rodar e ver passar (suíte toda verde)** — `bash tests/run.sh`;
  esperado `run.sh: 0 arquivo(s) de teste com falha`.
- [ ] **5. Commit** — `git add -A && git commit -m "feat(memory-fatiada/6,8): 0.6.0 — Constituicao cobre references, manifests e docs"`

---

## Tarefa 4: medição antes/depois

- **depende-de**: [Tarefa 3]
- **requisito**:
  - **memory-fatiada/9** — QUANDO a demanda fechar O SISTEMA DEVE registrar no
    nó a medição antes/depois, em bytes, do custo de carga da skill nas 5
    sessões de fase de uma demanda MEDIUM — medida por comando executado com
    saída lida, nunca estimada
- **decisões relevantes**: decisão viva de 2026-08-25 (grafo-v2) — corte de
  token estimado não vale; medir quando a travessia doer. Doeu.
- **interfaces**:
  - consome: `skills/memory/SKILL.md` e as 4 references da Tarefa 2.
  - produz: bloco de medição na seção `## decisoes` do nó
    `docs/audora/memory/memory-fatiada.md`.
- **arquivos**:
  - Modificar: `docs/audora/memory/memory-fatiada.md`
- **done quando**: o nó contém os dois números (antes e depois, em bytes) com
  o comando que os produziu ao lado, e a saída real foi lida nesta sessão.

Passos (2-5 minutos cada; código real, zero placeholder):

- [ ] **1. Escrever teste que falha** — não há teste automatizado: /9 é
  evidência registrada, cobrada pelo gate 1:1 da skill validate. O "red" desta
  tarefa é o nó sem o bloco de medição.
- [ ] **2. Rodar o comando de medição** — mapeamento fixo de operações por
  sessão de fase de uma demanda MEDIUM (S1 commander+scope: carregar-contexto,
  registrar-no, registrar-aprendizado; S2 plan: carregar-contexto,
  consultar-codigo; S3 execute: consultar-codigo, registrar-delta,
  registrar-aprendizado; S4 e2e: carregar-contexto, registrar-aprendizado;
  S5 validate: compactar, registrar-delta):

```bash
base=7e86d9d
antes_1=$(git show $base:skills/memory/SKILL.md | wc -c)
antes=$((antes_1 * 5))
sk=$(wc -c < skills/memory/SKILL.md)
rn=$(wc -c < skills/memory/references/registrar-no.md)
cc=$(wc -c < skills/memory/references/consultar-codigo.md)
cm=$(wc -c < skills/memory/references/compactar.md)
depois=$(( (sk+rn) + (sk+cc) + (sk+cc) + sk + (sk+cm) ))
echo "antes=$antes depois=$depois corte=$(( (antes-depois)*100/antes ))%"
```

- [ ] **3. Registrar no nó** — colar `antes`, `depois`, corte % e o comando
  acima na seção `## decisoes` de `docs/audora/memory/memory-fatiada.md`.
- [ ] **4. Verificar** — `bash tests/run.sh` verde e
  `run_hook memory-guard` no nó com exit 0 (nó ≤ 100 linhas; estourou, mover
  frio para `memory-fatiada-historico.md`).
- [ ] **5. Commit** — `git add -A && git commit -m "docs(memory-fatiada/9): medicao antes/depois do custo de carga por sessao de fase"`
