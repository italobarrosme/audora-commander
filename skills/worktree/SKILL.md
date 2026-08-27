---
name: worktree
description: 'Use quando o humano pedir explicitamente para isolar uma demanda em git worktree, ver a situação dos worktrees, despachar N agentes em paralelo, integrar de volta ou limpar — nunca por iniciativa própria.'
---

# worktree — isolamento sob demanda

```
LEI DE FERRO: WORKTREE COM TRABALHO NÃO INTEGRADO NUNCA É APAGADO
```

**Anuncie ao começar:** "Usando worktree para [operação]."

Worktree é uma segunda árvore de trabalho do MESMO repositório: `.git`
compartilhado, arquivos separados. Isola **arquivo** — e só isso. Porta, banco,
container, cache de build, `.git/hooks` e a pilha de `git stash` continuam
compartilhados. Quem trata worktree como sandbox descobre isso da pior forma.

**Gatilho — leia antes de qualquer operação**: esta skill só age por **pedido
explícito** do humano, ou por instrução escrita na Constituição/nó do MEMORY.
Nenhuma categoria de risco isola sozinha. Sem pedido: dizer em 1 linha "sigo na
árvore atual — peça worktree se quiser isolar" e seguir. Iniciativa própria
aqui cria diretório que ninguém pediu e ninguém limpa.

## Operações

### 1. isolar (uma demanda)

1. **Nó primeiro**: demanda sem nó no MEMORY → porta de entrada (skill
   `audora-commander`) ANTES. Worktree sem nó é trabalho sem endereço: ninguém
   descobre depois o que aquele diretório estava resolvendo.
2. **Nome = id do nó**. `EnterWorktree({name: "<id do nó>"})` cria sob
   `.claude/worktrees/<id>/` e move a sessão para lá. Nome da TAREFA, nunca do
   agente — quem lê a lista seis dias depois precisa saber o QUE está ali.
3. **Base**: `worktree.baseRef` decide de onde a branch parte — `fresh`
   (default) parte da branch default do remote; `head` parte do HEAD local.
   Demanda que continua trabalho local ainda não integrado precisa de `head`.
   Confirmar antes: partir do lugar errado só aparece no merge.
4. **Registrar no nó** (skill `memory`, registrar-delta): caminho e branch.
5. Seguir para a operação 2 ANTES de escrever qualquer código.

### 2. preparar o ambiente

Worktree novo é checkout limpo: **tudo que o git ignora não veio junto**.

1. **Arquivos ignorados necessários** — listar quais o projeto precisa para
   rodar e o estado de cada um no worktree. Fonte da lista, nesta ordem:
   `.worktreeinclude` na raiz (padrões estilo `.gitignore`; copia só o que o
   git já ignora), senão o `como-rodar` da Constituição, senão perguntar.
   Falta um e é necessário → dizer QUAL falta. **Nunca copiar segredo em
   silêncio**, nunca inventar valor, nunca imprimir conteúdo de `.env`.
2. **Dependências** — `node_modules`, `.venv`, cache de build não vêm. Rodar o
   setup do projeto dentro do worktree. Instalação concorrente em N worktrees
   disputa o cache da máquina: uma por vez.
3. **Hooks** — os `hooks são compartilhados` com o checkout principal
   (`.git/hooks` resolve para o repositório comum). Hook instalado por um
   worktree dispara em todos, e `post-checkout` dispara na própria criação do
   worktree. Repo com hooks instalados → avisar o humano.
4. **Índice de código** — artefato fora do git não vem junto; a fase que
   precisar dele reindexa ou degrada, conforme a skill `memory`.

### 3. situar (listar)

`git worktree list --porcelain` é a fonte — formato estável, feito para script.
Para cada worktree, relatar os QUATRO campos:

- caminho e branch;
- nó do MEMORY associado;
- limpo? (`git -C <caminho> status --porcelain` vazio);
- commit não integrado? (`git -C <caminho> log --oneline <base>..HEAD`).

"Está tudo certo" sem os quatro campos é opinião, não situação.

### 4. fan-out (N agentes em N worktrees)

Só por pedido explícito, e só depois dos dois portões abaixo.

1. **Domínios de arquivo `não-sobrepostos`** — antes de despachar, cada agente
   declara os caminhos que vai tocar. Interseção não-vazia → PARE e redesenhe
   a divisão. Worktree isola arquivo, não semântica: dois agentes editando a
   mesma função em worktrees diferentes **mergeiam limpo e quebram o build**.
   Contribuição de agente conflita em taxa muito acima da humana, e a
   mitigação real é desenho de tarefa, não ferramenta.
2. **Um nó por agente.** Fan-out sem nó por frente é memória sem endereço. O
   teto de nós `in-progress` do framework continua valendo.
3. **Criar `em série`** — nunca N criações simultâneas. `git worktree add`
   concorrente disputa lock do repositório comum e falha de forma
   intermitente. Criar, preparar (operação 2), só então o próximo.
4. **Despachar** um agente por worktree, cada um recebendo no prompt o nó, os
   critérios de aceite e o domínio de arquivo dele.

### 5. integrar de volta

A ordem é a decisão, não um detalhe.

1. **Um por vez, `em série`.** Escolher o primeiro (menor diff, ou o que
   desbloqueia os outros), reancorar na base atualizada, rodar a suíte,
   integrar.
2. **Depois de cada integração**, os worktrees restantes reancoram na base
   nova ANTES do próximo. Pular isso acumula dívida de merge: o terceiro
   branch paga o conflito do primeiro e do segundo somados.
3. Suíte vermelha depois de reancorar → skill `debug`. Nunca `--force`.
4. Quem aprova a demanda é a skill `validate`. Worktree integra; não aprova.

### 6. encerrar e limpar

1. **Checar antes de tocar**: `status --porcelain` e `log <base>..HEAD`.
   Qualquer um não-vazio significa que há trabalho ali.
2. **Limpo e integrado** → `ExitWorktree({action: "remove"})`.
3. **Com trabalho** → `ExitWorktree({action: "keep"})`. A ferramenta nativa
   RECUSA remover neste caso a menos que receba `discard_changes: true`. Esse
   parâmetro é do humano, não seu: mostrar o que se perderia (arquivos sujos e
   commits não integrados, nomeados) e ESPERAR decisão explícita. Autorizou →
   remover e confirmar o que foi descartado.
4. **Órfãos** (diretório sumiu, metadado ficou): `git worktree prune -n` lista
   sem apagar; `git worktree list` marca os `prunable`. Apresentar a lista e
   oferecer a limpeza — nunca executar a remoção por conta própria.
5. Atualizar o nó do MEMORY ao encerrar (skill `memory`).

## Quando NÃO isolar

| Situação | Por quê |
|---|---|
| Demanda sequencial, uma de cada vez | Branch normal resolve. Worktree só soma diretório e limpeza. |
| Ajuste de uma linha | O preparo do ambiente custa mais que a demanda inteira. |
| Stack com muito estado (banco, fila, cache) | Worktree não isola runtime. Sem plano para porta e banco, dois worktrees se corrompem. |
| Desenvolvimento containerizado | Metadado de worktree usa caminho absoluto; quebra dentro do container. |
| Sem rotina de limpeza | Worktree que ninguém remove vira dezenas de diretórios e dezenas de GB. |
| Precisa da mesma branch em dois lugares | O git recusa. Use `--detach` ou outra branch. |

## Armadilhas

- **`git stash` é compartilhado** entre todos os worktrees — `stash pop` num
  worktree pega o stash de outro. Em fluxo paralelo, proibir stash: commit de
  trabalho parcial na branch própria.
- **`.git/hooks` é compartilhado** (ver operação 2, item 3).
- **Nunca `rm -rf`** para remover worktree — deixa metadado órfão. Diretório
  movido à mão → `git worktree repair`.
- **Windows**: o caminho de um worktree é mais longo que o do checkout normal,
  então repo que clona bem pode falhar ao criar worktree ("Filename too
  long") — mitigar com `core.longpaths` e raiz curta. Caminho com espaço:
  sempre entre aspas, em todo comando e todo hook.
- Armadilha nova encontrada aqui → skill `memory`, `registrar-aprendizado`,
  na hora.

## Degradação

Ambiente sem suporte — não é repositório git, harness sem worktree nativo, git
antigo demais, criação recusada — a skill `degrada`: avisa em 1 linha, segue a
demanda na árvore atual e NÃO trava. Worktree é conforto, não portão.

## MEMORY dentro do worktree

Editar somente os arquivos dos nós daquela demanda e as linhas de índice
correspondentes. Conflito de merge no MEMORY fora desses arquivos → o humano
decide; nunca auto-resolver.

## Red flags — pare e corrija

| Racionalização | Realidade |
|---|---|
| "Isolo por segurança, mesmo sem pedirem" | Gatilho é pedido explícito. Diretório que ninguém pediu, ninguém limpa. |
| "Worktree isola tudo, dá pra paralelizar à vontade" | Isola arquivo. Porta, banco, hooks e stash continuam compartilhados. |
| "Está sujo mas é lixo, removo com force" | Você não sabe o que é lixo. Mostre o que se perde e espere o humano. |
| "Crio os 5 worktrees de uma vez, é mais rápido" | Criação concorrente disputa lock e falha no meio. Em série. |
| "Divido os domínios depois, começo já" | Domínio sobreposto mergeia limpo e quebra o build. Divida ANTES. |
| "Integro os 3 branches juntos pra economizar" | O terceiro paga o conflito dos outros dois. Um por vez, reancorando. |
| "`rm -rf` no diretório resolve" | Deixa metadado órfão. `ExitWorktree` ou `git worktree remove`. |

## PRÓXIMA SKILL

Worktree criado e preparado → a fase que a demanda pedia (**execute**, ou
**scope**/**plan** se o escopo ainda não fechou). Trabalho integrado →
**validate** (portão humano). Fan-out despachado → acompanhar os agentes e
voltar aqui para a operação 5.
