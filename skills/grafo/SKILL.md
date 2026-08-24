---
name: grafo
description: Use quando precisar criar, consultar ou atualizar o GRAFO de um projeto — bootstrap em projeto sem GRAFO, registro de nó ou delta de demanda, compactação, ou carga de contexto no início de uma demanda. Schema v2 (índice mestre + 1 nó = 1 arquivo) com suporte v1.
---

# grafo — o mapa dinâmico do produto

```
LEI DE FERRO: REQUISITO NÃO ESCRITO NO GRAFO É REQUISITO QUE NÃO EXISTE
```

**Anuncie ao começar:** "Usando grafo para [operação]."

O GRAFO é a memória externa durável do produto: requisitos, estado e
decisões. O código guarda o "como"; o GRAFO guarda o "o quê / por quê /
estado". **Schema v2**: `GRAFO.md` na raiz é o ÍNDICE MESTRE (Propósito +
Constituição + 1 linha rica por nó); o corpo de cada nó vive em
`docs/audora/nos/<id>.md`. Schemas canônicos em `templates/` na raiz do
plugin: `GRAFO-template.md` (índice v2), `no-template.md` (arquivo de nó),
`decisoes-vivas-template.md`, `GRAFO-template-v1.md` (compat). Nunca invente
campos.

**Detecção de versão**: linha 1 do GRAFO.md. `versao-schema: 1` → modo
compat (ver seção no fim). `versao-schema: 2` → fluxo abaixo.

## Regra de leitura seletiva (vale para TODAS as operações)

Nunca leia a pasta `nos/` inteira, nunca leia corpo de nó não relacionado.
Carregue somente:
1. `GRAFO.md` (índice mestre — é pequeno por construção).
2. Os arquivos dos nós que a demanda toca — escolhidos pela LINHA RICA do
   índice (título, resumo, keywords, arquivos-chave) e por `depende-de`
   (1 salto).

Consulta estrutural NUNCA carrega corpos — grep no frontmatter resolve:
- nós em-curso: `grep -l '^estado: em-curso' docs/audora/nos/*.md`
- quem depende de X: `grep -l 'depende-de:.*X' docs/audora/nos/*.md`
- nó que governa um arquivo: `grep -l 'src/auth' docs/audora/nos/*.md`
- decisão durável de área: `grep -i '<termo>' docs/audora/decisoes-vivas.md`

`docs/audora/arquivo/` (nós entregues) só é lido se o humano pedir histórico.

## Operações

### 1. carregar-contexto (início de demanda)

1. Ler `GRAFO.md`. Ausente → oferecer **bootstrap** (operação 2). Não
   travar, não seguir sem GRAFO, não inventar um.
2. Identificar no índice os nós relacionados (linha rica + depende-de);
   Read SÓ de `docs/audora/nos/<id>.md` desses nós.
3. Devolver: constituição + nós relevantes para a fase que chamou.

### 2. bootstrap (projeto sem GRAFO)

1. Projeto novo: copiar `GRAFO-template.md` → `GRAFO.md`, preencher
   Propósito e Constituição perguntando o que faltar (`como-rodar` incluso).
   Zero nós; criar `docs/audora/nos/` vazia.
2. Projeto existente: engenharia reversa MÍNIMA — ler README/PRD/estrutura
   (não a codebase inteira); Propósito, Constituição verificável, e nós das
   funcionalidades visíveis com `origem: inferido` (linha no índice basta —
   expansão sob demanda).
3. Nó `inferido` NÃO vale como verdade: demanda tocando nó inferido →
   confirmar com o humano antes de usar; confirmado → `origem: humano`.
4. GRAFO parcial desde o dia 1 é o esperado.

### 3. registrar-no (criar/atualizar nó)

1. Validar contra `no-template.md` ANTES de escrever: frontmatter completo
   (id, estado, origem, depende-de, arquivos, keywords, resumo,
   atualizado-em), estado no enum, critérios NUMERADOS (`<id>/<n>`, número
   nunca reutilizado). Escrita que quebra schema é rejeitada.
2. Escrever `docs/audora/nos/<id>.md` E a linha rica do índice NA MESMA
   EDIÇÃO (resumo/keywords espelhados). Índice e pasta divergentes = memória
   inconsistente → PARAR e corrigir (hook grafo-validate acusa; sem hook, a
   skill confere).
3. Máximo 3 nós `em-curso` (contagem global pelo índice). Quarto chegando →
   porta de entrada resolve com o humano.
4. Em branch de demanda: editar SOMENTE os arquivos dos nós daquela demanda
   (+ suas linhas de índice). Conflito de merge fora deles → humano decide.

### 4. registrar-delta (mudança no meio da demanda)

1. Mudança NÃO reescreve o nó — append na seção `## delta` do arquivo do nó:
   `ADICIONADO` / `MODIFICADO` (antes → depois) / `REMOVIDO` (+ motivo), com
   data. Zero contato com região compartilhada.
2. Requisito de produto novo (afeta comportamento/critério) → perguntar ao
   humano ANTES. Decisão de implementação → decidir autônomo e listar em
   "Decisões tomadas pela IA" (a validar apresenta).
3. Delta é consolidado no corpo pela skill validar, no sync pós-merge.

### 5. compactar (manutenção)

1. Gatilhos: nó virou `entregue` (sync da validar); índice mestre > ~300
   linhas; arquivo de nó > ~100 linhas.
2. Nó `entregue`: (a) propor promoção das decisões AINDA VÁLIDAS para
   `docs/audora/decisoes-vivas.md` (1 linha: data | nó | decisão; humano
   aprova no portão); (b) `git mv docs/audora/nos/<id>.md
   docs/audora/arquivo/AAAA-MM-DD-<id>.md`; (c) linha do índice vira
   `- <id> | entregue | <título> → arquivo/AAAA-MM-DD-<id>.md`. Movimento,
   nunca reescrita.
3. Requisito/decisão superado: NUNCA apagar — anexar
   `[invalidado-em: data] [substituido-por: <ref>]`.
4. Nó ativo > ~100 linhas: mover histórico frio (delta consolidado, decisões
   antigas) para `docs/audora/nos/<id>-historico.md` + ponteiro de 1 linha.
5. A promoção do resumo ao PRD.md é responsabilidade da skill validar
   (direção única GRAFO → PRD; o PRD nunca alimenta o GRAFO).

## Modo compat v1 (`versao-schema: 1`)

1. **Só leitura/contexto** (carregar-contexto em demanda que ainda não
   registra nada): operar o monolito como sempre
   (`GRAFO-template-v1.md`) — NÃO migrar, não exigir migração.
2. **Primeiro toque de escrita** (registrar-no/delta em nó, demanda nova):
   migração on-touch — bump da linha 1 para `versao-schema: 2`, criar
   `docs/audora/nos/`, mover SÓ os nós tocados para arquivos (frontmatter a
   partir dos campos v1), enriquecer as linhas deles no índice. Nós não
   tocados permanecem inline como legado válido.
3. **Fallback de leitura no v2**: arquivo ausente em `nos/` mas `### <id>`
   presente no GRAFO.md → ler o corpo inline (estado transicional legítimo).
   Nós entregues no GRAFO-ARQUIVO.md antigo nunca precisam migrar.
4. Projeto pequeno pode ficar no v1 para sempre — caso degenerado válido,
   sem prazo.

## Conflito GRAFO vs código

Detecção acontece no escopo da demanda: a skill plano lê os arquivos
afetados e algo contradiz um nó → sinaliza. Registre a divergência no nó,
apresente ao humano, ele decide. Nunca escolha em silêncio.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Eu lembro do requisito, registro depois" | Depois = nunca. Sessão morre, memória morre. Registre agora. |
| "Carrego a pasta nos/ inteira pra garantir" | Contexto é o gargalo. Índice decide; grep consulta; Read só o tocado. |
| "Edito o nó agora, índice depois" | Índice desatualizado quebra a carga de todo mundo. Mesma edição. |
| "Migro o projeto v1 inteiro de uma vez, fica limpo" | On-touch. Migração em lote é big-bang que ninguém pediu. |
| "Apago a decisão velha, tá superada" | Apagar mata rastreabilidade. invalidado-em + substituido-por. |
| "O nó inferido parece certo, sigo com ele" | Inferido é hipótese. Confirme com o humano antes de construir em cima. |
| "Auto-resolvo o conflito de merge do GRAFO" | GRAFO é memória do sistema. Conflito fora dos seus nós = humano decide. |

## PRÓXIMA SKILL

Operação chamada por outra fase → devolver o resultado à fase chamadora.
Invocada direto pelo humano → concluir a operação e perguntar se há demanda a
classificar (skill audora-commander).
