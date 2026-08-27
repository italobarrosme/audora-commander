---
id: skill-worktree
estado: in-progress
origem: humano
depende-de: [plugin-v0.1.0]
arquivos: [skills/worktree/, tests/, README.md, README.pt-BR.md, PRD.md]
keywords: [worktree, isolamento, git, paralelismo, branch]
resumo: Skill de isolamento por git worktree — ciclo de vida de uma demanda mais fan-out de N agentes, com integração em série e portão humano na remoção.
atualizado-em: 2026-08-27
---

# skill-worktree

## objetivo

Nona skill do framework: isolar o trabalho de uma demanda em um worktree
próprio e, quando pedido, despachar N agentes em N worktrees com integração
ordenada de volta — sempre por pedido explícito do humano, sem nunca destruir
trabalho não integrado.

## criterios-aceite

- **skill-worktree/1** — QUANDO a skill for invocada sem pedido explícito de
  isolamento (nem na demanda do humano, nem na Constituição, nem no nó) O
  SISTEMA DEVE recusar isolar, seguir na árvore atual e dizer em 1 linha por quê
- **skill-worktree/2** — QUANDO o humano pedir isolamento para uma demanda com
  nó registrado O SISTEMA DEVE derivar o nome do worktree e da branch do id do
  nó e gravar caminho e branch no nó
- **skill-worktree/3** — QUANDO o humano pedir isolamento sem nó registrado O
  SISTEMA DEVE exigir a passagem pela porta de entrada antes de criar worktree
- **skill-worktree/4** — QUANDO um worktree novo for criado O SISTEMA DEVE
  listar quais arquivos ignorados pelo git o projeto precisa para rodar
  (`.env` e afins) e o estado deles no worktree, sem copiar segredo em silêncio
- **skill-worktree/5** — QUANDO um worktree novo for criado num repo com git
  hooks instalados O SISTEMA DEVE avisar que os hooks são compartilhados com o
  checkout principal e disparam também no worktree
- **skill-worktree/6** — QUANDO o humano pedir a situação dos worktrees O
  SISTEMA DEVE listar cada um com branch, nó associado, se está limpo e se tem
  commit não integrado
- **skill-worktree/7** — QUANDO o humano pedir fan-out de N agentes O SISTEMA
  DEVE recusar despachar enquanto os domínios de arquivo de cada agente não
  forem declarados e não-sobrepostos
- **skill-worktree/8** — QUANDO N worktrees forem criados para fan-out O
  SISTEMA DEVE criá-los em série, nunca simultaneamente
- **skill-worktree/9** — QUANDO houver mais de um worktree para integrar O
  SISTEMA DEVE integrar um por vez e reancorar os restantes na base atualizada
  antes do próximo
- **skill-worktree/10** — QUANDO for pedida a remoção de um worktree com
  alteração não commitada ou commit não integrado O SISTEMA DEVE recusar,
  mostrar o que se perderia e esperar decisão explícita do humano
- **skill-worktree/11** — QUANDO o humano autorizar explicitamente o descarte
  O SISTEMA DEVE remover e confirmar o que foi descartado
- **skill-worktree/12** — QUANDO existirem worktrees órfãos (diretório sumiu,
  metadado ficou) O SISTEMA DEVE apontá-los e oferecer limpeza, nunca apagar
  por conta própria
- **skill-worktree/13** — QUANDO o ambiente não suportar worktree (não é repo
  git, harness sem suporte, git antigo demais) O SISTEMA DEVE avisar em 1 linha
  e seguir a demanda na árvore atual, sem travar
- **skill-worktree/14** — QUANDO a demanda for trabalhada dentro de um worktree
  O SISTEMA DEVE editar no MEMORY somente os arquivos dos nós daquela demanda
  e as linhas de índice correspondentes

## fora-de-escopo

Reimplementar mecânica de git em script próprio (a Constituição restringe
código executável a `hooks/` e `tests/`; a skill orquestra o worktree nativo do
harness). Isolamento de runtime — portas, banco, container, cache de build por
worktree (nó próprio; worktree isola arquivo, não runtime). Predição de
conflito semântico entre worktrees. Substituir o portão da skill validate:
worktree não aprova nada, quem aprova é o humano na validate. Suporte a
submódulos (a doc oficial do git desaconselha múltiplos checkouts de
superprojeto). Porte do fluxo para harness sem worktree nativo (nó
porte-multi-harness).

## decisoes

Ver `skill-worktree-historico.md` (mesma pasta).

## delta

<!-- Tudo abaixo: verificação empírica, Git 2.52.0.windows.1. -->
- ADICIONADO: **skill-worktree/15** — QUANDO o worktree contiver junction ou
  symlink de diretório apontando para fora dele O SISTEMA DEVE desconectar o
  link ANTES de qualquer remoção. Motivo: `git worktree remove` apaga o
  conteúdo do ALVO através da junction (3 reproduções) — perda de dados fora
  do worktree.
- ADICIONADO: **skill-worktree/16** — QUANDO a checagem de "limpo" for feita
  antes de remover O SISTEMA DEVE considerar também os arquivos IGNORADOS
  presentes no worktree. Motivo: ignorado não bloqueia a remoção (exit 0,
  apaga em silêncio) e `status --porcelain` não os lista — o `.env` do preparo
  seria destruído.
- MODIFICADO: /6 e /10 — commit não integrado detectado por `rev-list --count
  HEAD --not --remotes`, não `<base>..HEAD`. Motivo: `@{u}..HEAD` sai 128 em
  branch nova sem upstream — o caso exato de um worktree de tarefa.

## e2e

pendente

## feedback-reprovacao
