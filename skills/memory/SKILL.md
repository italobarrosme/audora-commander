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

## Onde mora cada operação

Esta skill é um roteador. As operações quentes e curtas estão inline, aqui
embaixo; as grandes ou raras vivem em `references/`, ao lado deste arquivo, e
só devem ser lidas quando a operação é de fato usada. **Leia uma reference por
operação — nunca a pasta inteira.**

| operação | onde |
|---|---|
| carregar-contexto | inline |
| bootstrap | references/bootstrap.md |
| registrar-no | references/registrar-no.md |
| registrar-delta | inline |
| registrar-aprendizado | inline |
| compactar | references/compactar.md |
| consultar-codigo | references/consultar-codigo.md |

Uma **reference ausente** ou ilegível não interrompe nada: avise em 1 linha
qual arquivo faltou e siga a operação pelo que este roteador garante — Lei de
Ferro, schema e regra de leitura seletiva —, **sem travar a fase**. Reference
é atalho para o corpo da operação, não portão. Instalação sem `references/` é instalação quebrada:
avise o humano para reinstalar o plugin.

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

## Operações inline

### 1. carregar-contexto (início de demanda)

1. Ler `MEMORY.md`. Ausente → oferecer **bootstrap** (operação 2). Não
   travar, não seguir sem MEMORY, não inventar um.
2. `GRAFO.md` presente e `MEMORY.md` ausente → avisar "GRAFO não é mais lido pelo framework (0.4.0)" e oferecer bootstrap; o destino do arquivo antigo é decisão do humano — nunca converter nem apagar por conta própria.
3. Identificar no índice os nós relacionados (linha rica + depende-de);
   Read SÓ de `docs/audora/memory/<id>.md` desses nós.
4. Devolver: Constituição (inclui o bullet `graphify`) + Aprendizados + nós
   relevantes para a fase que chamou.
5. Constituição sem bullet `gate:` → ofertar UMA vez gerar o gate (etapa
   gate de `references/bootstrap.md`); `gate: recusado` → não reofertar,
   só se o humano pedir.

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

## Conflito MEMORY vs código

Detecção acontece no escopo da demanda: a skill plan lê os arquivos
afetados (via operação 7, `references/consultar-codigo.md`) e algo contradiz
um nó → sinaliza. Registre a divergência no nó, apresente ao humano, ele
decide. Nunca escolha em silêncio.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Eu lembro do requisito, registro depois" | Depois = nunca. Sessão morre, memória morre. Registre agora. |
| "Carrego a pasta memory/ inteira pra garantir" | Contexto é o gargalo. Índice decide; grep consulta; Read só o tocado. |
| "Leio todas as references de uma vez pra ter contexto" | Contexto é o gargalo — de novo. Uma reference por operação usada. |
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
