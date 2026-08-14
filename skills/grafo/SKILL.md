---
name: grafo
description: Use quando precisar criar, consultar ou atualizar o GRAFO.md de um projeto — bootstrap em projeto sem GRAFO, registro de nó ou delta de demanda, compactação, ou carga de contexto no início de uma demanda.
---

# grafo — o mapa dinâmico do produto

```
LEI DE FERRO: REQUISITO NÃO ESCRITO NO GRAFO É REQUISITO QUE NÃO EXISTE
```

**Anuncie ao começar:** "Usando grafo para [operação]."

O GRAFO.md é a memória externa durável do produto: requisitos, estado e
decisões. O código guarda o "como"; o GRAFO guarda o "o quê / por quê /
estado". Schema canônico: `${CLAUDE_PLUGIN_ROOT}/templates/GRAFO-template.md`
— única fonte de verdade do formato. Nunca invente campos.

## Regra de leitura seletiva (vale para TODAS as operações)

Nunca leia o GRAFO inteiro. Carregue somente:
1. Seções `[carga: sempre]`: Propósito + Constituição + Índice de nós.
2. Os nós que a demanda atual toca (pelo índice, via `depende-de` e título).

`docs/audora/GRAFO-ARQUIVO.md` (nós entregues) só é lido se o humano pedir
histórico explicitamente.

## Operações

### 1. carregar-contexto (início de demanda)

1. Ler seções `[carga: sempre]` do `GRAFO.md` na raiz do projeto.
2. GRAFO ausente → oferecer **bootstrap** (operação 2). Não travar, não seguir
   sem GRAFO, não inventar um.
3. Identificar no índice os nós relacionados à demanda; carregar só esses.
4. Devolver: constituição + nós relevantes para a fase que chamou.

### 2. bootstrap (projeto sem GRAFO — brownfield ou novo)

1. Projeto novo (vazio): copiar o template, preencher Propósito e Constituição
   perguntando ao humano o que faltar (`como-rodar` incluso). Zero nós.
2. Projeto existente: engenharia reversa MÍNIMA — ler README/PRD/estrutura de
   pastas (não a codebase inteira) e gerar: Propósito, Constituição com o que
   for verificável, e nós das funcionalidades visíveis com `origem: inferido`.
3. Nó `inferido` NÃO vale como verdade para a Lei de Ferro: quando uma demanda
   tocar nó inferido, confirmar com o humano antes de usar; confirmado →
   `origem: humano`.
4. Nunca exigir mapeamento completo antes de trabalhar. GRAFO parcial desde o
   dia 1 é o esperado.

### 3. registrar-no (criar/atualizar nó de demanda)

1. Validar contra o schema do template ANTES de escrever: todos os campos
   obrigatórios (`id`, `estado`, `origem`, `depende-de`, `objetivo`,
   `criterios-aceite`, `fora-de-escopo`, `decisoes`, `atualizado-em`), estado
   dentro do enum. Escrita que quebra schema é rejeitada — corrija e tente de
   novo.
2. Atualizar o Índice de nós na mesma edição (1 linha por nó).
3. Máximo 3 nós `em-curso`. Quarto chegando → parar e mandar a porta de
   entrada resolver com o humano (pausar/continuar/abandonar).
4. Em branch de demanda: editar SOMENTE os nós daquela demanda. Conflito de
   merge fora deles → parar e sinalizar ao humano, nunca auto-resolver.

### 4. registrar-delta (mudança de requisito no meio da demanda)

1. Mudança de requisito NÃO reescreve o nó — entra no bloco `delta` como
   `ADICIONADO` / `MODIFICADO` (antes → depois) / `REMOVIDO` (+ motivo), com
   data.
2. Requisito de produto novo (afeta comportamento observável ou critério de
   aceite) → perguntar ao humano ANTES de registrar. Decisão de implementação
   (não afeta critérios) → decidir autônomo e listar em "Decisões tomadas pela
   IA" (a skill validar apresenta ao humano).
3. Delta é consolidado no nó pela skill validar, no sync pós-merge — nunca
   antes.

### 5. compactar (manutenção)

1. Gatilhos: nó virou `entregue` (no sync da validar) OU GRAFO ativo passou de
   ~300 linhas.
2. Nó `entregue`: reduzir a 1 linha (`- <id> | entregue | <resumo> → ver
   GRAFO-ARQUIVO.md`) e mover o corpo completo para
   `docs/audora/GRAFO-ARQUIVO.md`.
3. A promoção do resumo ao PRD.md é responsabilidade da skill validar
   (direção única GRAFO → PRD; o PRD nunca alimenta o GRAFO).

## Conflito GRAFO vs código

Detecção acontece só no escopo da demanda: quando a skill plano lê os arquivos
afetados e algo contradiz um nó, ela sinaliza. Registre a divergência no nó,
apresente ao humano, e ele decide qual é a verdade. Nunca escolha em silêncio.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Eu lembro do requisito, registro depois" | Depois = nunca. Sessão morre, memória morre. Registre agora. |
| "Carrego o GRAFO inteiro pra garantir" | Contexto é o gargalo. Índice + nós tocados, nada mais. |
| "O nó inferido parece certo, sigo com ele" | Inferido é hipótese. Confirme com o humano antes de construir em cima. |
| "Atualizo o índice depois, só o nó agora" | Índice desatualizado quebra a carga seletiva de todo mundo. Mesma edição. |
| "Auto-resolvo o conflito de merge do GRAFO" | GRAFO é memória do sistema. Conflito fora dos seus nós = humano decide. |

## PRÓXIMA SKILL

Operação chamada por outra fase → devolver o resultado à fase chamadora.
Invocada direto pelo humano → concluir a operação e perguntar se há demanda a
classificar (skill audora-commander).
