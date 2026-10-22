# Plano — entrega-clara: Entrega clara no chat

> Plano é descartável após a validação (vai para docs/audora/planos/arquivo/),
> mas obrigatório enquanto a demanda vive. Reler no início de CADA sessão de
> execução e após qualquer compactação de contexto.

**Objetivo:** decidido o portão final, a validate fecha o turno com um cartão
único (`🏁 DONE`, `❌ NÃO ENTREGUE` ou `⚠️ PARCIAL`) que mostra num relance o
estado, o que mudou e como foi — no lugar do bloco de fase + relatório de entrega.

**Nó do MEMORY:** `entrega-clara` (MEMORY.md) — MEDIUM, 15 critérios.

**Arquitetura da mudança:** a seção `## Relatório de entrega` do
`templates/bloco-fechamento-template.md` é TROCADA pela seção
`## Cartão de entrega (só a validate, decidido o portão)`: esqueleto do cartão
+ regras numeradas, incluindo o comando exato que soma os arquivos da demanda
(`git diff --numstat` limitado aos arquivos dos commits de escopo `(<id>…)`).
A validate deixa de imprimir bloco de fase no fechamento e só aponta o cartão;
o sync manda as sobras para o rodapé **Memória** do cartão; o fechamento LIGHT
herda o cartão. Prova = testes de texto por frase inteira dentro da seção
extraída por awk (aprendizado 2026-09-05) + 1 teste de integração que roda o
comando de arquivos num repo fixture com commits de duas demandas.

**Arquivos lidos antes de planejar:**
- `docs/audora/memory/entrega-clara.md:1-95` — objetivo, 15 critérios EARS, fora-de-escopo, 8 decisões (substitui relatorio-entrega/1,/4,/8).
- `MEMORY.md:1-109` — Constituição (≤ 250 linhas por skill/reference, prosa PT, `bash tests/run.sh`, gate), índice; nó `cerimonia-enxuta` (planned) toca o mesmo template — fora daqui.
- `templates/bloco-fechamento-template.md:1-276` — header 1-11 ("TODA skill de fase imprime"); bloco de fase 44-101; parada 103-125; LIGHT 127-153; interrompida 155-186 (parágrafo 183-186 "Vale para portão reprovado…"); relatório 188-276 (seção a trocar, 3921 B).
- `templates/plano-template.md:1-49` — formato deste plano.
- `skills/validate/SKILL.md:1-117` — item 6 sync 78-80; `## Bloco de fechamento` 98-113 (bullets Produzido/Arquivos/Próximo + parágrafo do relatório). 6258 B sem `\r`, teto 6300.
- `skills/validate/references/sync.md:1-73` — passo 3 base da demanda (`cria=…`, 32-46); passo 6 sobras 70-73 ("1 linha ao humano").
- `skills/validate/references/fechamento-light.md:1-35` — bullet do relatório 31-33.
- `tests/test-relatorio-entrega.sh:1-111` — `sec`/`flat` 6-16; asserts do template 18-86; validate 89-99; LIGHT 101-110.
- `tests/test-templates.sh:17-27` — 23-24 asserem `#### Relatório de entrega — <id>` e `| critério | evidência`.
- `tests/test-skills.sh:80-95` — 93 `git diff --numstat` na validate; 94 `**Entrega**` na validate.
- `tests/test-carga.sh:1-23` — BASE inclui template e validate; hoje base=56406 (teto 58000), full=65234 (teto 67100); linha 7 = histórico de medição.
- `tests/test-leitura-por-secao.sh:110-111` e `tests/test-parada-revisao.sh:53-54` — validate ≤ 6300 B.
- `tests/test-skill-cleanup.sh:699-708` — exige em sync.md 'Sobras do processo: N — rode a skill cleanup quando quiser.', 'N = 0 → nada', 'depois do commit do sync'; validate sem `hooks/cleanup`.
- `tests/lib.sh:1-30` — `ok/ko/assert_*`, `$SP` temporário, `report`.
- `tests/run.sh:9` — descobre `tests/test-*.sh` por glob (arquivo novo entra sozinho).
- `skills/validate/README.md` — não existe; `README.md`/`README.pt-BR.md` não citam o relatório (só "1 linha com a contagem de sobras", segue verdadeiro).

**Conflitos MEMORY vs código encontrados:** nenhum.

## Notas de sessão

- Commit inicial (fim do plan): nó + linha do índice + este plano, `docs(entrega-clara): escopo e plano` — é o commit que CRIA o nó, base da demanda para o comando de arquivos.
- Carga: só 1594 B de folga na BASE. O cartão tem de caber na troca da seção (≤ ~5500 B) — skeleton enxuto, regras de 1-2 linhas. Estourou 58000 → PARAR e levar ao humano (subir teto só com motivo no nó), nunca subir sozinho.
- Risco conhecido (aprendizado 2026-10-13): formato da saída do modelo não se garante só por texto de skill — a prova de comportamento é o e2e (`claude -p` rodando um portão real em fixture). Recomendar o e2e na validate.
- Arquivos CRLF no checkout? `tr -cd '\r' < f | wc -c` antes de editar; editar com Edit/Write, nunca `sed -i` (aprendizado 2026-10-15).
- Decisões tomadas pela IA:
  - (execute) `sec` do teste novo ignora `## ` dentro de fence de 4 crases: o título `## 🏁 DONE — <id>` do esqueleto fecharia a seção no awk do teste velho.
  - (execute) header do template ganha 1 linha "Exceção: a validate, decidido o portão, imprime o cartão de entrega no lugar do bloco." — frase numa linha só para casar no flat (citação `> ` quebraria).
  - (execute) T1 derruba a contagem de asserts (23 → 16 nos arquivos tocados): válvula `gate-asserts:` em `## decisoes` do nó, troca aprovada no escopo (substitui relatorio-entrega/1, /4, /8).
  - (execute) T4 passou do pino BASE 56406 (`test-parada-revisao.sh:59`, `test-leitura-por-secao.sh:129`; o plano só mapeou o teto 58000): pino sobe para a medição real na tarefa que cresce a BASE, com a nota em `test-carga.sh:7` no mesmo commit (padrão das demandas anteriores). T4: 56406 → 57229.
  - (execute, replanejo da T5) gate reprovou `tests/test-prd-foto.sh:81` (fora do mapa): exigia o bloco Arquivos da validate citar `PRD.md` + `CHANGELOG.md`; o bloco saiu e o comportamento vive no rodapé **Memória** do cartão — assert reapontado para `· PRD atualizado · CHANGELOG +1 ·` no template; item 6 da validate segue guardado pela linha 80.

---

## Interface comum — esqueleto do cartão (produzido na T1, consumido por T2–T6)

Dentro da seção nova, um bloco ` ````markdown ` com, nesta ordem, as linhas-rótulo
(cada uma começando em `**`): `**O que mudou**`, `**Como foi**`, `**Ressalvas**`,
`**Mudanças no caminho**`, `**Por critério**`, `**Evidência**`, `**Decisões da IA**`,
`**Como conferir**`, `**Arquivos**`, `**Memória**`. Linhas fixas do esqueleto:

- `## 🏁 DONE — <id>` (precedido de `---` em linha própria)
- `<categoria> · <entregues>/<total> critérios · na main`
- `4. e2e — rodado: <até 8 palavras>` (na lista numerada de Como foi)
- `**Ressalvas** — nenhuma`
- `` - `<id>/1` ✅ entregue — o sistema agora <comportamento> ``
- `**Evidência** — <c>/<total> critérios · `<suíte ou gate>` nesta sessão → <resultado> · detalhe no roteiro do portão`
- `**Decisões da IA** — <n>, revisadas no portão`
- `**Arquivos** — <n> arquivos · +<a> −<r>`
- `**Memória** — nó arquivado · PRD atualizado · CHANGELOG +1 · decisões vivas +<k> · Sobras do processo: <N> — rode a skill cleanup quando quiser.`
- `> ▶️ **Próximo** — nenhum: demanda entregue.`

Testes extraem a seção com `flat "$T" '## Cartão de entrega (só a validate, decidido o portão)'`
(mesma função de `tests/test-relatorio-entrega.sh:10-16`) e o esqueleto com
`awk '/^````markdown/{f=1;next} /^````/{f=0} f'` sobre a seção.

---

## Tarefa 1: troca da seção — esqueleto, título DONE, linha de estado, fim de turno

- **depende-de**: []
- **requisito**:
  - `entrega-clara/1` — QUANDO o portão final da validate for aprovado, em QUALQUER categoria, O SISTEMA DEVE fechar o turno com um cartão único de título `## 🏁 DONE — <id>`, no lugar do bloco de fase + relatório
  - `entrega-clara/2` — QUANDO o cartão for impresso O SISTEMA DEVE trazer sob o título 1 linha de estado: categoria · `<entregues>/<total>` critérios · `na main` ou `na branch <nome>`
  - `entrega-clara/15` — QUANDO o cartão for impresso O SISTEMA DEVE ser a última parte da resposta do turno, sem chamada de ferramenta depois
- **decisões relevantes**: cartão único substitui bloco de fase + relatório (humano 2026-10-22); substitui relatorio-entrega/1 (ordem de seções); regras do bloco de fase (régua, link, ícone com palavra) seguem valendo.
- **interfaces**: produz a seção `## Cartão de entrega (só a validate, decidido o portão)` com o esqueleto da Interface comum.
- **ponto de mudança**: `templates/bloco-fechamento-template.md:188-276` (troca integral da seção); `templates/bloco-fechamento-template.md:3-4` (header).
- **teste**: `tests/test-entrega-clara.sh` (novo) — casos "entrega-clara/1 …", "/2 …", "/15 …"; `tests/test-templates.sh:23-24` reapontados; `tests/test-relatorio-entrega.sh:18-86` removidos (asserts do template velho).
- **asserções** (flat da seção, salvo indicação):
  - seção não vazia
  - contém `## 🏁 DONE — <id>`; contém `no lugar do bloco de fase`; contém `em TODA categoria (LIGHT, MEDIUM, HIGH, HOTFIX)`
  - rótulos do esqueleto, em ordem → `**O que mudou**|**Como foi**|**Ressalvas**|**Mudanças no caminho**|**Por critério**|**Evidência**|**Decisões da IA**|**Como conferir**|**Arquivos**|**Memória**|` (`grep -oE '^\*\*[^*]+\*\*'` no esqueleto, `tr '\n' '|'`)
  - contém `<categoria> · <entregues>/<total> critérios · na main`; contém ``ou `na branch <nome>` ``
  - contém `última parte da resposta do turno`; contém `nenhuma chamada de ferramenta depois dele`
  - template inteiro contém `a validate, decidido o portão, imprime o cartão de entrega no lugar do bloco` (header)
  - template inteiro NÃO contém `## Relatório de entrega`, `#### Relatório de entrega — <id>`, `| critério | evidência`, `~~caminho/antigo.ts~~`; contém `## Parada entre fases` (vizinha intocada)
  - `tests/test-templates.sh:23-24` → assert contém `## 🏁 DONE — <id>` ("entrega-clara/1 template define o cartão (substitui relatorio-entrega/1)") e NÃO contém `| critério | evidência` ("entrega-clara/8 sem tabela de evidência (substitui relatorio-entrega/4)")
- **ler**: `templates/bloco-fechamento-template.md:1-12,183-276`, `tests/test-relatorio-entrega.sh:1-30`, `tests/test-templates.sh:17-27`
- **done quando**: casos /1 /2 /15 verdes; `bash tests/test-carga.sh` base ≤ 58000; `bash tests/run.sh` exit 0.

- [ ] **red** — criar `tests/test-entrega-clara.sh` com os casos /1 /2 /15 e trocar `tests/test-templates.sh:23-24`; `bash tests/test-entrega-clara.sh` falha com `FAIL: entrega-clara/1 template sem a seção` (seção ainda não existe)
- [ ] **green** — trocar a seção + header, tirar `tests/test-relatorio-entrega.sh:18-86`; `bash tests/test-entrega-clara.sh && bash tests/test-templates.sh && bash tests/test-carga.sh && bash tests/run.sh` exit 0
- [ ] **commit** — `git add templates/bloco-fechamento-template.md tests/test-entrega-clara.sh tests/test-templates.sh tests/test-relatorio-entrega.sh && git commit -m "feat(entrega-clara/1): cartao de entrega substitui o relatorio no template - esqueleto, estado e fim de turno"`

## Tarefa 2: corpo do cartão — o que mudou, como foi, ressalvas, delta, por critério, evidência, decisões, como conferir

- **depende-de**: [1]
- **requisito**:
  - `entrega-clara/3` — QUANDO o cartão for impresso O SISTEMA DEVE trazer "O que mudou": 1 a 3 bullets em linguagem de usuário ("o sistema agora …")
  - `entrega-clara/4` — QUANDO o cartão for impresso O SISTEMA DEVE trazer "Como foi": trilha das fases percorridas, em ordem, resumo de até 8 palavras cada, e2e marcado como rodado ou pulado
  - `entrega-clara/5` — QUANDO houver ressalva (e2e pulado, prova parcial, ressalva aceita no portão) O SISTEMA DEVE listar 1 linha por ressalva; QUANDO não houver O SISTEMA DEVE escrever "Ressalvas — nenhuma"
  - `entrega-clara/6` — QUANDO o nó tiver `## delta` com entradas O SISTEMA DEVE listar Mudanças no caminho, 1 linha por entrada; sem delta, omitir
  - `entrega-clara/7` — QUANDO o cartão for impresso O SISTEMA DEVE listar "Por critério" com TODOS os critérios do nó, endereço `<id>/<n>`, ícone e palavra (✅ entregue, ⏳ pendente, ❌ reprovado) e comportamento de usuário
  - `entrega-clara/8` — QUANDO o cartão for impresso O SISTEMA DEVE resumir a evidência em 1 linha (com evidência / total + suíte ou gate desta sessão + "detalhe no roteiro do portão") e as Decisões da IA em 1 linha (quantidade + "revisadas no portão"; nenhuma → omitir), sem repetir tabela de evidência nem lista de decisões do roteiro
  - `entrega-clara/9` — QUANDO o cartão for impresso O SISTEMA DEVE trazer Como conferir com ≥ 1 item ligado a critério: comando em ` ```text ` ou tela/rota a abrir
- **decisões relevantes**: evidência e decisões em 1 linha cada (humano); "Como foi" = trilha + ressalvas + mudanças no caminho, sem commit (humano); Ressalvas sempre impressa (IA, escopo); fases que a categoria não percorre ficam fora da trilha (regra LIGHT do template, 127-134).
- **interfaces**: consome o esqueleto da T1; produz regras numeradas da seção (uma por bloco do cartão).
- **ponto de mudança**: `templates/bloco-fechamento-template.md` — lista `Regras:` da seção criada na T1.
- **teste**: `tests/test-entrega-clara.sh` — casos "entrega-clara/3" … "entrega-clara/9".
- **asserções** (flat da seção; cada linha = um `assert_contains`, frase inteira):
  - /3: `1 a 3 bullets`; `o sistema agora`
  - /4: `em ordem cronológica`; `até 8 palavras`; ``e2e marcado `rodado` ou `pulado` ``; `fases que a categoria não percorre ficam fora`; ``cada resumo vem de fonte lida nesta sessão (nó, plano, `git log`, campo `## e2e` do nó)``
  - /5: `**Ressalvas** — nenhuma`; `1 linha por ressalva`; `e2e pulado, prova parcial, ressalva aceita no portão`
  - /6: ``1 linha por entrada de `## delta` do nó``; `Sem delta, a seção não é impressa`
  - /7: `TODOS os critérios do nó`; `✅ entregue`; `⏳ pendente`; `❌ reprovado`; `` `<id>/<n>` ``
  - /8: `detalhe no roteiro do portão`; `**Decisões da IA** — <n>, revisadas no portão`; `Sem decisão da IA, a linha não é impressa`; `nunca repete a tabela de evidência nem a lista de decisões do roteiro`
  - /9: `≥ 1 item, cada um ligado ao critério que confere`; ``code block ` ```text ` ``; `tela/rota a abrir`
- **ler**: seção nova do template (inteira), `docs/audora/memory/entrega-clara.md:16-60`
- **done quando**: casos /3–/9 verdes; base ≤ 58000; `bash tests/run.sh` exit 0.

- [ ] **red** — acrescentar os casos /3–/9; `bash tests/test-entrega-clara.sh` falha com `FAIL: entrega-clara/4 … não contém 'em ordem cronológica'` (e demais frases)
- [ ] **green** — escrever as regras; `bash tests/test-entrega-clara.sh && bash tests/test-carga.sh && bash tests/run.sh` exit 0
- [ ] **commit** — `git add templates/bloco-fechamento-template.md tests/test-entrega-clara.sh && git commit -m "feat(entrega-clara/3): corpo do cartao - o que mudou, como foi, ressalvas, por criterio, evidencia e decisoes em 1 linha"`

## Tarefa 3: arquivos da demanda em 1 linha, do diff real

- **depende-de**: [1]
- **requisito**: `entrega-clara/10` — QUANDO o cartão for impresso O SISTEMA DEVE trazer os arquivos só como 1 linha `<n> arquivos · +<a> −<r>`, somada do `git diff --numstat` real da demanda, sem arquivo de outra demanda
- **decisões relevantes**: arquivos só como contagem (humano); substitui relatorio-entrega/8; base da demanda = pai do commit que CRIOU o nó (`sync.md:32-38`), nunca `--grep` para achar a base; commits da demanda reconhecidos pelo escopo convencional `<tipo>(<id>)` ou `<tipo>(<id>/<n>)`. Limite aceito: arquivo tocado pela demanda E por outra no mesmo range soma as linhas das duas.
- **interfaces**: produz no template um bloco ` ```bash ` (dentro da seção do cartão, regra de Arquivos) com exatamente este comando, sem barra invertida (aprendizado 2026-10-12):
  ```bash
  cria=$(git log --diff-filter=A --format=%H -- "docs/audora/memory/<id>.md" "docs/audora/arquivo/"*"-<id>.md" | tail -1)
  [ -n "$cria" ] && git log --format= --name-only -E --grep='^[a-z]+[(]<id>[/)]' "$cria^..HEAD" | sort -u | xargs -r -d '\n' git diff --numstat "$cria^" HEAD -- | awk '{a+=$1; r+=$2; n++} END {if (n) print n " arquivos · +" a " −" r}'
  ```
  e a frase `Saída vazia → `[SEM FONTE]``.
- **ponto de mudança**: `templates/bloco-fechamento-template.md` — regra de **Arquivos** da seção do cartão.
- **teste**: `tests/test-entrega-clara.sh` — caso "entrega-clara/10 comando do template no repo fixture" (integração: extrai o bloco ` ```bash ` da seção com `awk '/^```bash/{f=1;next} /^```/{f=0} f'`, troca `<id>` por `demo` com `sed 's/<id>/demo/g'`, roda com `bash` dentro do fixture) + asserts de texto.
- **asserções**:
  - fixture em `$SP/repo` (`git init -q`, `git config core.autocrlf false`, user.name/email locais), commits nesta ordem:
    C0 `chore: init` (README, 1 linha) · C1 `docs(demo): escopo e plano` cria `docs/audora/memory/demo.md` (3 linhas) · C2 `feat(demo/1): a` cria `a.txt` (2 linhas) · C3 `feat(outra/1): b` cria `b.txt` (5 linhas) · C4 `fix(demo/2): a` troca 1 linha de `a.txt` · C5 `docs(outra): cita demo/1` cria `c.txt` (1 linha) · C6 `feat(demo-x/1): d` cria `d.txt` (1 linha) · C7 `docs(demo): sync` faz `git mv docs/audora/memory/demo.md docs/audora/arquivo/2026-10-22-demo.md`
  - comando no fixture → stdout exato `2 arquivos · +5 −0`
  - mesmo comando com `<id>` → `nada` (sem nó) → stdout E stderr vazios (`2>&1` capturado = `''`)
  - conferido no plan (2026-10-22, script em scratchpad): com a guarda, `demo` → `2 arquivos · +5 −0`; sem a guarda, `nada` vaza `fatal: bad revision '^..HEAD'` no stderr
  - flat da seção contém `**Arquivos** — <n> arquivos · +<a> −<r>`; ``Saída vazia → `[SEM FONTE]` ``; `sem tabela de arquivos`
- **ler**: `skills/validate/references/sync.md:32-46`, seção nova do template
- **done quando**: caso /10 verde (incluindo o fixture); base ≤ 58000; `bash tests/run.sh` exit 0.

- [ ] **red** — acrescentar o caso /10; `bash tests/test-entrega-clara.sh` falha com `FAIL: entrega-clara/10 … esperado '2 arquivos · +5 −0', obtido ''` (bloco bash ainda não existe)
- [ ] **green** — escrever a regra + bloco; `bash tests/test-entrega-clara.sh && bash tests/test-carga.sh && bash tests/run.sh` exit 0
- [ ] **commit** — `git add templates/bloco-fechamento-template.md tests/test-entrega-clara.sh && git commit -m "feat(entrega-clara/10): arquivos do cartao em 1 linha, somados do diff real so dos commits da demanda"`

## Tarefa 4: rodapé da memória, merge em branch, não entregue/parcial, sem fonte

- **depende-de**: [2, 3]
- **requisito**:
  - `entrega-clara/11` — QUANDO o sync tiver rodado O SISTEMA DEVE fechar o cartão com 1 linha de rodapé da memória (nó arquivado, PRD, CHANGELOG, decisões vivas; sobras de limpeza se N > 0), sem resumo do sync fora dele
  - `entrega-clara/12` — QUANDO o portão for aprovado com o trabalho numa branch fora da main O SISTEMA DEVE imprimir o cartão DONE com o Próximo perguntando, em opções numeradas, se faz o merge na main agora; aceito → merge, sync e confirmação em 1 linha, sem segundo cartão
  - `entrega-clara/13` — QUANDO o portão for reprovado ou parcial O SISTEMA DEVE imprimir o mesmo cartão com título `## ❌ NÃO ENTREGUE — <id>` ou `## ⚠️ PARCIAL — <id>`, veredito e motivo por critério e Próximo na decisão humana ou fase de retorno — sem a palavra DONE
  - `entrega-clara/14` — QUANDO um dado do cartão não tiver fonte lida nesta sessão (nó, saída de comando, diff) O SISTEMA DEVE marcar `[SEM FONTE]` e o critério ligado como ⏳, nunca preencher de memória
- **decisões relevantes**: aprovado em branch já é DONE e o cartão pergunta o merge (humano); após merge, 1 linha sem segundo cartão (IA, escopo); reprovado/parcial usam o mesmo cartão (humano). `tests/test-skill-cleanup.sh:702-703` exige manter em sync.md as frases `Sobras do processo: N — rode a skill cleanup quando quiser.`, `N = 0 → nada`, `depois do commit do sync`.
- **interfaces**: consome a linha `**Memória** — …` do esqueleto (T1); produz em `sync.md` passo 6 o destino das sobras.
- **ponto de mudança**: `templates/bloco-fechamento-template.md` — regras da seção do cartão; `templates/bloco-fechamento-template.md:183-186` (tirar "portão reprovado" do parágrafo do bloco interrompido); `skills/validate/references/sync.md:70-73` ("1 linha ao humano" → rodapé **Memória** do cartão).
- **teste**: `tests/test-entrega-clara.sh` — casos "/11" … "/14".
- **asserções**:
  - /11 (flat da seção): `**Memória** —`; `só quando o sync rodou`; `nenhum resumo do sync fora do cartão`; (flat de sync.md) contém `no rodapé **Memória** do cartão de entrega` e segue contendo `Sobras do processo: N — rode a skill cleanup quando quiser.`; NÃO contém `1 linha ao humano`
  - /12 (flat da seção): `> ⏸️ **Próximo** — fazer o merge na main agora?`; `> 1. sim — merge, sync e confirmação em 1 linha`; `> 2. não — fica na branch <nome>`; `sem segundo cartão`
  - /13: seção contém `## ❌ NÃO ENTREGUE — <id>`; `## ⚠️ PARCIAL — <id>`; `veredito e motivo por critério`; `fase de retorno (scope ou plan)`; `sem a palavra DONE`; template inteiro NÃO contém `Vale para portão reprovado`
  - /14: `[SEM FONTE]`; `o critério ligado fica ⏳`; `nunca preencher de memória`
- **ler**: seção nova do template, `templates/bloco-fechamento-template.md:155-186`, `skills/validate/references/sync.md:68-73`, `tests/test-skill-cleanup.sh:699-708`
- **done quando**: casos /11–/14 verdes; `bash tests/test-skill-cleanup.sh` verde; base ≤ 58000, full ≤ 67100; `bash tests/run.sh` exit 0.

- [ ] **red** — acrescentar os casos /11–/14; `bash tests/test-entrega-clara.sh` falha com `FAIL: entrega-clara/12 … não contém 'sem segundo cartão'` (e demais)
- [ ] **green** — regras no template, parágrafo 183-186, passo 6 do sync; `bash tests/test-entrega-clara.sh && bash tests/test-skill-cleanup.sh && bash tests/test-carga.sh && bash tests/run.sh` exit 0
- [ ] **commit** — `git add templates/bloco-fechamento-template.md skills/validate/references/sync.md tests/test-entrega-clara.sh && git commit -m "feat(entrega-clara/12): cartao pergunta o merge em branch, nao entregue e parcial, rodape da memoria e sem fonte"`

## Tarefa 5: validate fecha com o cartão

- **depende-de**: [4]
- **requisito**: `entrega-clara/1`, `entrega-clara/12`, `entrega-clara/15` (verbatim na T1 e T4) — lado da skill validate.
- **decisões relevantes**: validate ≤ 6300 B sem `\r` (guardas `test-leitura-por-secao.sh:110-111`, `test-parada-revisao.sh:53-54`); validate sem `hooks/cleanup` (`test-skill-cleanup.sh:708`); toda skill de fase mantém `## Bloco de fechamento` apontando `bloco-fechamento-template.md` (Constituição, `test-skills.sh:80-83`).
- **interfaces**: consome a seção `## Cartão de entrega (só a validate, decidido o portão)` e os títulos `🏁 DONE`, `❌ NÃO ENTREGUE`, `⚠️ PARCIAL`.
- **ponto de mudança**: `skills/validate/SKILL.md:98-113` (corpo do `## Bloco de fechamento`: bullets Produzido/Arquivos/Próximo e parágrafo do relatório → o cartão no lugar do bloco de fase); `skills/validate/SKILL.md:78-80` (item 6: frase do merge em branch).
- **teste**: `tests/test-entrega-clara.sh` — casos "entrega-clara/1 validate", "/12 validate", "/15 validate"; `tests/test-skills.sh:93-94` reapontados; `tests/test-relatorio-entrega.sh:89-99` removidos.
- **asserções** (flat de `skills/validate/SKILL.md`, seção `## Bloco de fechamento` salvo indicação):
  - contém `fecha o turno com o **cartão de entrega**`; contém ``— `🏁 DONE`, `❌ NÃO ENTREGUE` ou `⚠️ PARCIAL` —``; contém `no lugar do bloco de fase`; contém `nenhuma ferramenta depois dele`; contém `bloco-fechamento-template.md`
  - NÃO contém `seguido do relatório de **Entrega**`; NÃO contém `**Produzido**: o veredito do portão`
  - arquivo inteiro contém `branch fora da main → o cartão pergunta o merge`
  - bytes sem `\r` ≤ 6300
  - `tests/test-skills.sh:93-94` → um assert: validate contém `**cartão de entrega**` ("entrega-clara/1 validate fecha com o cartão (substitui relatorio-entrega/8 e /4 do bloco de entrega)")
- **ler**: `skills/validate/SKILL.md:70-117`, `tests/test-skills.sh:85-95`, `tests/test-relatorio-entrega.sh:89-111`
- **done quando**: casos verdes; validate ≤ 6300 B; `bash tests/run.sh` exit 0.

- [ ] **red** — casos da validate + `test-skills.sh:93-94`; `bash tests/test-entrega-clara.sh` falha com `FAIL: entrega-clara/1 validate … não contém 'fecha o turno com o **cartão de entrega**'`
- [ ] **green** — reescrever 98-113 e o item 6; tirar `tests/test-relatorio-entrega.sh:89-99`; `bash tests/test-entrega-clara.sh && bash tests/test-skills.sh && bash tests/test-leitura-por-secao.sh && bash tests/test-parada-revisao.sh && bash tests/run.sh` exit 0
- [ ] **commit** — `git add skills/validate/SKILL.md tests/test-entrega-clara.sh tests/test-skills.sh tests/test-relatorio-entrega.sh && git commit -m "feat(entrega-clara/1): validate fecha o turno com o cartao de entrega e pergunta o merge em branch"`

## Tarefa 6: LIGHT herda o cartão; teste velho sai; medição de carga

- **depende-de**: [5]
- **requisito**: `entrega-clara/1` (verbatim na T1) — "em QUALQUER categoria": caminho LIGHT.
- **decisões relevantes**: LIGHT sem plano → Decisões da IA contam só as linhas `(IA` do `## decisoes` do nó (regra herdada de relatorio-entrega/6); trilha LIGHT `execute → validate`; regressões que o teste velho guardava no LIGHT (`HOTFIX não usa este caminho`, `silêncio sobre o PRD é proibido`) passam para o teste novo.
- **interfaces**: consome a seção do cartão.
- **ponto de mudança**: `skills/validate/references/fechamento-light.md:31-33`; `tests/test-relatorio-entrega.sh` (`git rm` — sobra só o bloco LIGHT 101-110, portado); `tests/test-carga.sh:7` (acrescentar a medição `entrega-clara: BASE 56406 → <medido> / FULL 65234 → <medido>`, números da saída real de `bash tests/test-carga.sh`; tetos 15-16 inalterados).
- **teste**: `tests/test-entrega-clara.sh` — caso "entrega-clara/1 LIGHT".
- **asserções** (flat de `fechamento-light.md`):
  - contém `**Cartão de entrega**`; contém `sai igual em LIGHT, no lugar do bloco de fase`; contém ``as Decisões da IA contam só as linhas `(IA` do `## decisoes` do nó``
  - NÃO contém `Relatório de entrega`
  - contém `HOTFIX não usa este caminho`; contém `silêncio sobre o PRD é proibido`
  - `tests/test-relatorio-entrega.sh` não existe (`assert_no_file`)
- **ler**: `skills/validate/references/fechamento-light.md:1-35`, `tests/test-relatorio-entrega.sh:101-111`, `tests/test-carga.sh:1-23`
- **done quando**: caso verde; `grep -rn 'Relatório de entrega' skills templates tests` vazio fora de comentário histórico em `tests/test-carga.sh`; `bash tests/run.sh` exit 0; `bash hooks/gate entrega-clara` exit 0.

- [ ] **red** — caso LIGHT; `bash tests/test-entrega-clara.sh` falha com `FAIL: entrega-clara/1 LIGHT … não contém '**Cartão de entrega**'`
- [ ] **green** — reescrever 31-33, `git rm tests/test-relatorio-entrega.sh`, medição na linha 7 do test-carga; `bash tests/test-entrega-clara.sh && bash tests/run.sh && bash hooks/gate entrega-clara` exit 0
- [ ] **commit** — `git add skills/validate/references/fechamento-light.md tests/test-entrega-clara.sh tests/test-carga.sh && git commit -m "feat(entrega-clara/1): fechamento LIGHT imprime o cartao; teste do relatorio velho sai"`
