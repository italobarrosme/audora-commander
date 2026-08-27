---
name: memory
description: 'Use quando precisar criar, consultar ou atualizar o MEMORY de um projeto — bootstrap em projeto sem MEMORY.md (inclui oferta e ativação do Graphify), carga de contexto no início de uma demanda, registro de nó, delta ou aprendizado, compactação, ou consulta ao índice de código (consultar-codigo) pelas fases plan, debug e execute.'
---

# memory — a memória do produto

```
LEI DE FERRO: REQUISITO NÃO ESCRITO NO MEMORY É REQUISITO QUE NÃO EXISTE
```

**Anuncie ao começar:** "Usando memory para [operação]."

O MEMORY é a memória externa durável do produto: propósito, constituição,
aprendizados, requisitos, estado e decisões. O código guarda o "como"; o
MEMORY guarda o "o quê / por quê / estado / o que aprendemos". O código em
si NÃO vive aqui — é indexado pelo **Graphify** (`graphify-out/`, fora do
git, só código, sem API key) e consultado pela operação 7.

**Schema** (`memory-schema: 1`, linha 1): `MEMORY.md` na raiz é o ÍNDICE
MESTRE (Propósito + Constituição + Aprendizados + 1 linha rica por nó); o
corpo de cada nó vive em `docs/audora/memory/<id>.md`. Schemas canônicos em
`templates/` na raiz do plugin: `MEMORY-template.md` (índice),
`no-template.md` (arquivo de nó), `decisoes-vivas-template.md`. Nunca
invente campos. Os hooks `memory-guard` (tetos de linhas) e
`memory-validate` (índice↔pasta, enum de estado, depende-de, ciclo, seções
obrigatórias) devolvem exit 2 em escrita que quebra o schema — sem hook, a
skill confere o mesmo.

**Raiz do plugin**: scripts auxiliares ficam dois níveis acima do diretório
base desta skill (o Skill tool imprime esse diretório ao carregar). Ex.:
`bash "<raiz do plugin>/hooks/graphify-status" .`.

## Regra de leitura seletiva (vale para TODAS as operações)

Nunca leia a pasta `docs/audora/memory/` inteira, nunca leia corpo de nó não
relacionado. Carregue somente:
1. `MEMORY.md` (índice mestre — é pequeno por construção).
2. Os arquivos dos nós que a demanda toca — escolhidos pela LINHA RICA do
   índice (título, resumo, keywords, arquivos-chave) e por `depende-de`
   (1 salto).

Consulta estrutural NUNCA carrega corpos — grep resolve:
- nós in-progress: `grep -l '^estado: in-progress' docs/audora/memory/*.md`
- quem depende de X: `grep -l 'depende-de:.*X' docs/audora/memory/*.md`
- nó que governa um arquivo: `grep -l 'src/auth' docs/audora/memory/*.md`
- aprendizado por termo: `grep -i '<termo>' MEMORY.md`
- decisão durável de área: `grep -i '<termo>' docs/audora/decisoes-vivas.md`

`docs/audora/arquivo/` (nós entregues) só é lido se o humano pedir histórico.
Código: nunca "varrer o repo para entender" — operação 7.

## Operações

### 1. carregar-contexto (início de demanda)

1. Ler `MEMORY.md`. Ausente → oferecer **bootstrap** (operação 2). Não
   travar, não seguir sem MEMORY, não inventar um.
2. `GRAFO.md` presente e `MEMORY.md` ausente → avisar "GRAFO não é mais lido pelo framework (0.4.0)" e oferecer bootstrap; o destino do arquivo antigo é decisão do humano — nunca converter nem apagar por conta própria.
3. Identificar no índice os nós relacionados (linha rica + depende-de);
   Read SÓ de `docs/audora/memory/<id>.md` desses nós.
4. Devolver: Constituição (inclui o bullet `graphify`) + Aprendizados + nós
   relevantes para a fase que chamou.

### 2. bootstrap (projeto sem MEMORY)

1. Projeto novo: copiar `MEMORY-template.md` → `MEMORY.md`, preencher
   Propósito e Constituição perguntando o que faltar (`como-rodar` incluso);
   Aprendizados vazio; zero nós; criar `docs/audora/memory/` vazia.
2. Projeto existente: engenharia reversa MÍNIMA — ler README/PRD/estrutura
   (não a codebase inteira); Propósito, Constituição verificável, e nós das
   funcionalidades visíveis com `origem: inferido` (linha no índice basta —
   expansão sob demanda).
3. Nó `inferido` NÃO vale como verdade: demanda tocando nó inferido →
   confirmar com o humano antes de usar; confirmado → `origem: humano`.
4. **Etapa Graphify** (sempre, ao fim do bootstrap):
   a. Constituição já tem bullet `graphify:` → pular esta etapa, não
      perguntar de novo — só se o humano pedir.
   b. Rodar `bash "<raiz do plugin>/hooks/graphify-status" .` → imprime uma
      de `ausente | sem-indice | sem-codigo | ativo`.
   c. `ausente` → perguntar "Instalar Graphify (índice local do código, sem
      API key)?". Aceitou: `uv tool install graphifyy`; falhou ou `uv`
      ausente: `pipx install graphifyy`; confirmar com `graphify --version`
      e seguir para (d). Instalação falhou (sem uv/pipx, sem rede, Python
      < 3.10): mostrar o erro REAL, seguir degradado avisando, NÃO gravar
      `recusado`, nunca afirmar que instalou. Recusou: Constituição
      `graphify: recusado` + aviso "plan/debug/execute rodam degradadas
      (grep/Read)".
   d. `sem-indice` → `graphify update .` (só código, sem API key), rodar o
      status de novo.
   e. `ativo` → `graphify hook install` (post-commit mantém o índice
      atualizado); `graphify-out/` no `.gitignore`; Constituição
      `graphify: ativo`.
   f. `sem-codigo` → avisar "nenhuma linguagem suportada indexada"; NÃO
      instalar git hook; Constituição `graphify: sem-codigo`.
5. MEMORY parcial desde o dia 1 é o esperado.

### 3. registrar-no (criar/atualizar nó)

1. Validar contra `no-template.md` ANTES de escrever: frontmatter completo
   (id, estado, origem, depende-de, arquivos, keywords, resumo,
   atualizado-em), estado no enum (`planned | in-progress | blocked |
   delivered | discarded`, + transitório `hotfix-pending-record`), critérios
   NUMERADOS (`<id>/<n>`, número nunca reutilizado). Escrita que quebra
   schema é rejeitada (`memory-validate`). Exceção declarada: nó recém-aberto
   pela porta de entrada (MEDIUM/HIGH) pode ter `criterios-aceite` vazio ATÉ
   a fase scope; LIGHT/HOTFIX já entram com ≥1 critério numerado.
2. Escrever `docs/audora/memory/<id>.md` E a linha rica do índice NA MESMA
   EDIÇÃO (resumo/keywords espelhados). Índice e pasta divergentes = memória
   inconsistente → PARAR e corrigir.
3. Máximo 3 nós `in-progress` (contagem global pelo índice). Quarto chegando →
   porta de entrada resolve com o humano.
4. Em branch de demanda: editar SOMENTE os arquivos dos nós daquela demanda
   (+ suas linhas de índice). Conflito de merge fora deles → humano decide.

### 4. registrar-delta (mudança no meio da demanda)

1. Mudança NÃO reescreve o nó — append na seção `## delta` do arquivo do nó:
   `ADICIONADO` / `MODIFICADO` (antes → depois) / `REMOVIDO` (+ motivo), com
   data. Zero contato com região compartilhada.
2. Requisito de produto novo (afeta comportamento/critério) → perguntar ao
   humano ANTES. Decisão de implementação → decidir autônomo e listar em
   "Decisões tomadas pela IA" (a validate apresenta).
3. Delta é consolidado no corpo no sync pós-merge (operação compactar,
   item 0, chamada pela validate) — nunca antes.
4. **Constituição** (como-rodar descoberto, padrão novo, ferramenta de e2e
   escolhida, estado do `graphify`): editar o bullet direto no índice
   mestre, mesma validação — é o que e2e/scope chamam de "registrar na
   Constituição".

### 5. registrar-aprendizado (qualquer fase, na hora)

1. O que É aprendizado: armadilha encontrada, preferência do humano,
   como-rodar descoberto, padrão do projeto que não está no código — algo
   que vale para TODA demanda futura. O que NÃO é: decisão de uma demanda
   (vai em `## decisoes` do nó) ou requisito (vira critério do nó).
2. Registrar NA HORA em que foi descoberto, por qualquer fase — não esperar
   o sync final. 1 linha na seção `## Aprendizados` do `MEMORY.md`:
   `- AAAA-MM-DD | <fase> | <aprendizado em 1 frase>` (grep-ável).
3. Antes de escrever: `grep -i '<termo>' MEMORY.md`. Já existe → não
   duplicar. Contradiz um antigo → anexar ao antigo
   `[invalidado-em: data] [substituido-por: <linha nova>]`, nunca apagar.

### 6. compactar (manutenção)

0. **Consolidar delta** (sync da validate): aplicar cada ADICIONADO /
   MODIFICADO / REMOVIDO no corpo (criterios-aceite, decisoes,
   fora-de-escopo), critério novo recebe o próximo `<id>/<n>`, e esvaziar
   `## delta`.
1. Gatilhos: nó virou `delivered` (sync da validate); `MEMORY.md` > ~300
   linhas (`memory-guard` acusa); arquivo de nó > ~100 linhas; seção
   Aprendizados > ~40 linhas.
2. Nó `delivered`: (a) promover as decisões AINDA VÁLIDAS aprovadas no portão
   para `docs/audora/decisoes-vivas.md` (1 linha: data | nó | decisão);
   (b) consolidar os aprendizados da demanda na seção Aprendizados (dedupe
   pelo grep da operação 5); (c) `git mv docs/audora/memory/<id>.md
   docs/audora/arquivo/AAAA-MM-DD-<id>.md`; (d) linha do índice vira
   `- <id> | delivered | <título> → docs/audora/arquivo/AAAA-MM-DD-<id>.md`.
   Movimento, nunca reescrita.
3. Requisito/decisão/aprendizado superado: NUNCA apagar — anexar
   `[invalidado-em: data] [substituido-por: <ref>]`.
4. Nó ativo > ~100 linhas: mover histórico frio (delta consolidado, decisões
   antigas) para `docs/audora/memory/<id>-historico.md` + ponteiro de 1
   linha. Aprendizados > ~40 linhas: mover os mais antigos para
   `docs/audora/aprendizados-historico.md` + ponteiro de 1 linha.
5. A promoção do resumo ao PRD.md é responsabilidade da skill validate
   (direção única MEMORY → PRD; o PRD nunca alimenta o MEMORY).

### 7. consultar-codigo (plan, debug, execute — antes de qualquer Read)

Protocolo único de consulta ao índice de código. Chamado por plan, debug e
execute ANTES de abrir qualquer arquivo de código. scope, e2e e validate
NÃO chamam (não exploram código cru).

1. Pré-condição: Constituição com `graphify: ativo`. `graphify: recusado`
   ou `graphify: sem-codigo` → devolver "sem índice de código: grep/Read" e
   seguir — sem oferecer instalação/indexação de novo (só se o humano
   pedir). Bullet ausente → a etapa Graphify do bootstrap nunca rodou:
   executar a operação 2, passo 4, e voltar aqui.
2. Sanidade: `bash "<raiz do plugin>/hooks/graphify-status" .` ≠ `ativo`
   (`graph.json` sumiu ou corrompeu) → passo 6.
3. Consultar: `graphify query "<símbolo, rota ou domínio da tarefa>"
   --budget 1500` → linhas `NODE <label> [src=<arquivo> loc=L<n>
   community=<c>]` e `EDGE`. Caminho entre dois símbolos: `graphify path
   "A" "B"`. Impacto de mudar X: `graphify affected "X"`.
4. Ler SÓ os arquivos citados em `src=` das linhas `NODE` (Read com offset
   em `loc=` quando o arquivo for grande). Read fora do apontado → só com
   exceção declarada na fase, em 1 linha: "índice não cobre X porque …".
5. Arquivo existe no repo mas não aparece na consulta → `graphify update .`
   UMA única vez e repetir o passo 3; persistindo → passo 6.
6. Degradar: comando falha (exit ≠ 0, `error: graph file not found`,
   `graph.json` corrompido, `graphify` sumiu do PATH) → avisar em 1 linha
   e cair para grep/Read na MESMA fase. Nunca travar a demanda, nunca
   "consertar" o Graphify no meio da fase — registrar aprendizado
   (operação 5) se a causa for do projeto.

## Conflito MEMORY vs código

Detecção acontece no escopo da demanda: a skill plan lê os arquivos
afetados (via operação 7) e algo contradiz um nó → sinaliza. Registre a
divergência no nó, apresente ao humano, ele decide. Nunca escolha em
silêncio.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Eu lembro do requisito, registro depois" | Depois = nunca. Sessão morre, memória morre. Registre agora. |
| "Carrego a pasta memory/ inteira pra garantir" | Contexto é o gargalo. Índice decide; grep consulta; Read só o tocado. |
| "Edito o nó agora, índice depois" | Índice desatualizado quebra a carga de todo mundo. Mesma edição. |
| "Aprendizado eu guardo no sync final" | Sync final é depois do /clear. Aprendizado é NA HORA, 1 linha. |
| "Apago a decisão velha, tá superada" | Apagar mata rastreabilidade. invalidado-em + substituido-por. |
| "O nó inferido parece certo, sigo com ele" | Inferido é hipótese. Confirme com o humano antes de construir em cima. |
| "Instalo o Graphify sem perguntar, é só uma ferramenta" | Instalar no ambiente do humano é decisão dele. Pergunte; recusado fica recusado. |
| "Leio o arquivo direto, o índice deve estar velho" | Consulta primeiro; velho → `graphify update .` UMA vez; depois degrada AVISANDO. |
| "Graphify falhou, paro a demanda até arrumar" | Índice é atalho, não portão. Avise e caia para grep/Read na mesma fase. |
| "Auto-resolvo o conflito de merge do MEMORY" | MEMORY é memória do sistema. Conflito fora dos seus nós = humano decide. |

## PRÓXIMA SKILL

Operação chamada por outra fase → devolver o resultado à fase chamadora.
Invocada direto pelo humano → concluir a operação e perguntar se há demanda a
classificar (skill audora-commander).
