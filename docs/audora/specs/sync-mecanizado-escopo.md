# Escopo — sync-mecanizado (HIGH)

> Spec dedicada do nó `sync-mecanizado`. HIGH porque a ferramenta ESCREVE em
> memória persistida do produto-alvo, sem passar por leitura humana.

## Objetivo

Dos 8 passos do sync da validate, 3 são julgamento (consolidar delta, escolher
decisões vivas, redigir o resumo do PRD) e 5 são braço. Esta demanda tira **2
grupos** desses 5 da mão do modelo: preencher `arquivos:` do diff real, e
reescrever a linha do índice + arquivar o plano.

## Divisão de trabalho decidida no portão

O humano escolheu **escrever direto** (não propor comandos) e **NÃO** incluir
`estado: delivered` nem o `git mv` do nó. Consequência de ordem, que vira
pré-condição e não suposição:

1. O **modelo** vira `estado: delivered` e faz o `git mv` do nó (e do
   `-historico.md`, se houver).
2. O **script** roda depois: preenche `arquivos:`, reescreve a linha do índice
   e move o plano.

A linha do índice em formato `delivered` aponta para `docs/audora/arquivo/…`.
Se o nó ainda estiver em `docs/audora/memory/`, escrever essa linha deixaria
índice e pasta divergentes — por isso o script ABORTA nesse caso.

**Consequência do "escreve direto", registrada:** os hooks `memory-validate` e
`memory-guard` disparam em `PostToolUse` de `Edit`/`Write`. Um script não
dispara isso. Então o script tem de invocá-los ele mesmo e falhar se algum
acusar — senão a garantia que hoje existe some justamente onde a escrita passou
a ser automática.

## Critérios de aceite

- **sync-mecanizado/1** — QUANDO invocado com o id de um nó O SISTEMA DEVE
  preencher `arquivos:` a partir de `git diff --name-only <base>..HEAD`, com a
  base derivada do primeiro commit que cita o id — nunca de memória
- **sync-mecanizado/2** — QUANDO o `arquivos:` for preenchido O SISTEMA DEVE
  reescrever a linha do índice para
  `- <id> | delivered | <título> → docs/audora/arquivo/AAAA-MM-DD-<id>.md`,
  preservando o título que já estava lá
- **sync-mecanizado/3** — QUANDO existir `docs/audora/planos/plano-<id>.md` O
  SISTEMA DEVE movê-lo por `git mv` para `docs/audora/planos/arquivo/`; não
  existindo (caso LIGHT), seguir sem escrever nada e sem reclamar
- **sync-mecanizado/4** — QUANDO terminar de escrever O SISTEMA DEVE rodar
  `memory-validate` e `memory-guard` sobre o resultado e sair com código ≠ 0 se
  algum acusar, dizendo qual
- **sync-mecanizado/5** — QUANDO qualquer pré-condição não bater O SISTEMA DEVE
  abortar com código ≠ 0, dizer o que achou e NÃO escrever nada. Pré-condições:
  nó já em `docs/audora/arquivo/AAAA-MM-DD-<id>.md`; linha do `<id>` presente
  no índice; nenhuma alteração não commitada nos arquivos que ele vai tocar
- **sync-mecanizado/6** — QUANDO rodar uma segunda vez sobre o mesmo nó O
  SISTEMA DEVE detectar que já está feito e sair 0 sem reescrever nada
  (idempotente)
- **sync-mecanizado/7** — QUANDO não for repositório git, ou `git diff` falhar,
  O SISTEMA DEVE abortar avisando — nunca escrever `arquivos:` com lista vazia
- **sync-mecanizado/8** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  exercitar o script em fixture git real (`mktemp -d`) cobrindo, no mínimo:
  caminho feliz, nó não arquivado, id ausente do índice, árvore suja, ausência
  de plano, e segunda execução
- **sync-mecanizado/9** — QUANDO a skill `validate` descrever o sync O SISTEMA
  DEVE apontar o script nos 2 grupos que ele cobre e deixar explícito que os 3
  passos de julgamento seguem com o modelo

## Fora de escopo

Os 3 passos de julgamento: consolidar o `delta` no corpo, escolher e promover
decisões vivas, redigir o resumo do `PRD.md`. O `estado: delivered` e o
`git mv` do nó e do `-historico.md` — ficam com o modelo por decisão do portão.
Consolidar aprendizados. O caminho HOTFIX (registro retroativo). Rodar
automaticamente por hook do git ou do harness: é invocado pela skill validate,
nunca sozinho. Desfazer um sync. Tocar `PRD.md`. Suportar mais de um nó por
execução.

## Risco aceito, declarado

Escrita automática em memória persistida sem leitura humana prévia foi
escolhida pelo humano sobre a alternativa de "propor comandos". O contrapeso
desta spec: `/4` (o script valida o próprio resultado), `/5` (aborta em vez de
escrever pela metade), `/6` (idempotência) e `/8` (fixture real cobrindo os
caminhos de erro, não só o feliz). Duas revisões adversariais nesta demanda,
uma no plano e uma no diff — decisão tomada depois de a demanda anterior ter
sido reprovada duas vezes por corrupção silenciosa que 380 asserts verdes não
pegaram.
