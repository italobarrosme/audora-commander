---
name: memory
description: 'Use quando precisar criar, consultar ou atualizar o MEMORY de um projeto — bootstrap em projeto sem MEMORY.md, carga de contexto no início de uma demanda, registro de nó, delta ou aprendizado, ou compactação.'
---

# memory — a memória do produto

```
LEI DE FERRO: REQUISITO NÃO ESCRITO NO MEMORY É REQUISITO QUE NÃO EXISTE
```

**Anuncie ao começar:** "Usando memory para [operação]."

**Schema** (`memory-schema: 1`, linha 1): `MEMORY.md` na raiz é o ÍNDICE
MESTRE (Propósito + Constituição + Aprendizados + 1 linha rica por nó); o
corpo de cada nó vive em `docs/audora/memory/<id>.md`. Schemas canônicos em
`templates/` na raiz do plugin: `MEMORY-template.md` (índice),
`no-template.md` (arquivo de nó), `decisoes-vivas-template.md`. Nunca
invente campos. Os hooks `memory-guard` (tetos de linhas) e
`memory-validate` (índice↔pasta, enum de estado, estado índice↔nó,
depende-de, ciclo, seções obrigatórias) devolvem exit 2 em escrita que quebra o schema — sem hook, a
skill confere o mesmo.

**Raiz do plugin**: scripts auxiliares ficam dois níveis acima do diretório
base desta skill (o Skill tool imprime esse diretório ao carregar). Ex.:
`<raiz do plugin>/templates/gate-template.md`.

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

Uma **reference ausente** ou ilegível não interrompe nada: avise em 1 linha
qual arquivo faltou e siga a operação pelo que este roteador garante — Lei de
Ferro, schema e regra de leitura seletiva —, **sem travar a fase**.
Instalação sem `references/` é instalação quebrada: avise o humano para
reinstalar o plugin.

## Regra de leitura seletiva (vale para TODAS as operações)

Nunca leia a pasta `docs/audora/memory/` inteira, nunca leia corpo de nó não
relacionado. Carregue somente:
1. O recorte do `MEMORY.md` da fase (carregar-contexto), nunca o arquivo
   inteiro.
2. Os arquivos dos nós que a demanda toca — escolhidos pela LINHA RICA do
   índice (título, resumo, keywords, arquivos-chave) e por `depende-de`
   (1 salto).

Consulta estrutural NUNCA carrega corpos — grep resolve:
- nós in-progress: `grep -l '^estado: in-progress' docs/audora/memory/*.md`
- quem depende de X: `grep -l 'depende-de:.*X' docs/audora/memory/*.md`
- decisão durável de área: `grep -i '<termo>' docs/audora/decisoes-vivas.md`

**Já carregado nesta sessão** (recorte do `MEMORY.md` lido, sem `/clear`
nem compactação depois) → reusar do contexto: não reinvocar a skill nem
reler. Depois de `/clear` ou compactação, recarregar.

`docs/audora/arquivo/` (nós entregues) só é lido se o humano pedir histórico.

## Operações inline

### 1. carregar-contexto (toda fase: `MEMORY.md` por seção, nunca inteiro)

1. `grep -n '^## ' MEMORY.md` → linha de cada seção. Sem `MEMORY.md` →
   **bootstrap** (operação 2), nunca inventar um. Faltou `## Propósito`, `## Constituição`, `## Aprendizados` ou `## Índice de nós` → avisar em 1 linha qual seção faltou, ler o arquivo inteiro e seguir a fase.
2. Propósito e Constituição: inteiras, Read por `offset`/`limit`.
3. Aprendizados só por busca em `docs/audora/aprendizados.md` e no
   `MEMORY.md` (enquanto ele tiver linha de aprendizado); `[invalidado-em:`
   nunca entra; nada casou → seguir sem aprendizados, sem ler a seção;
   arquivo ausente não é erro (`-s`):
   - porta de entrada, termos do pedido: `grep -shiE '^- [0-9-]{10} \| .*(<termo>|<termo>)' docs/audora/aprendizados.md MEMORY.md | grep -vF '[invalidado-em:'`
   - demais fases, a fase + keywords e arquivos-chave do nó (debug sem nó: termos do sintoma): `grep -shiE '^- [0-9-]{10} \| (<fase> \||.*(<termo>|<termo>))' docs/audora/aprendizados.md MEMORY.md | grep -vF '[invalidado-em:'`
4. Índice de nós: inteiro na porta de entrada, scope e plan; execute, e2e,
   validate e debug pegam só a linha do nó e as de `depende-de`:
   `grep -E '^- (<id>|<dep>) \|' MEMORY.md`.
5. Read SÓ de `docs/audora/memory/<id>.md` dos nós relacionados.
6. Constituição sem bullet `gate:` → ofertar UMA vez gerar o gate (etapa
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
   escolhida): editar o bullet direto no índice
   mestre, mesma validação — é o que e2e/scope chamam de "registrar na
   Constituição".

### 5. registrar-aprendizado (qualquer fase, na hora)

1. O que É aprendizado: armadilha encontrada, preferência do humano,
   como-rodar descoberto, padrão do projeto que não está no código — algo
   que vale para TODA demanda futura. O que NÃO é: decisão de uma demanda
   (vai em `## decisoes` do nó) ou requisito (vira critério do nó).
2. Registrar NA HORA em que foi descoberto, por qualquer fase — não esperar
   o sync final. 1 linha no fim de `docs/audora/aprendizados.md` (sem o
   arquivo, crie-o por `templates/aprendizados-template.md`), nunca no
   `MEMORY.md`: `- AAAA-MM-DD | <fase> | <aprendizado em 1 frase>` (grep-ável).
3. Antes de escrever: `grep -si '<termo>' docs/audora/aprendizados.md MEMORY.md`. Já existe → não
   duplicar. Contradiz um antigo → anexar ao antigo
   `[invalidado-em: data] [substituido-por: <linha nova>]`, nunca apagar.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Eu lembro do requisito, registro depois" | Depois = nunca. Sessão morre, memória morre. Registre agora. |
| "Carrego a pasta memory/ inteira pra garantir" | Contexto é o gargalo. Índice decide; grep consulta; Read só o tocado. |
| "Leio o MEMORY.md inteiro" | Recorte da fase; o resto, grep. |
| "Atualizo a linha do índice no fim da fase" | Índice atrasado quebra a carga de todo mundo. Arquivo do nó primeiro, linha do índice logo depois. |
| "Aprendizado eu guardo no sync final" | Sync final é depois do /clear. Aprendizado é NA HORA, 1 linha. |
| "Apago a decisão velha, tá superada" | Apagar mata rastreabilidade. invalidado-em + substituido-por. |
| "O nó inferido parece certo, sigo com ele" | Inferido é hipótese. Confirme com o humano antes de construir em cima. |
| "Auto-resolvo o conflito de merge do MEMORY" | MEMORY é memória do sistema. Conflito fora dos seus nós = humano decide. |

## PRÓXIMA SKILL

Operação chamada por outra fase → devolver o resultado à fase chamadora.
Invocada direto pelo humano → concluir a operação e perguntar se há demanda a
classificar (skill audora-commander).
