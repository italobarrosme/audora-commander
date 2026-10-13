---
id: porta-anuncio
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [porta, anuncio, categoria, eval]
resumo: Porta de entrada sempre anuncia a categoria com o porquê e o convite à correção, provado pelo eval porta.
atualizado-em: 2026-10-12
---

# porta-anuncio

## objetivo

Fazer a porta de entrada sempre anunciar "Demanda classificada como [X]
porque … — me corrija se discordar" antes de rotear, até o eval `porta`
passar com o plugin e reprovar sem ele. Reaberturas: hook, narração por
sentido, anúncio ≤ 150 chars (chega como texto no meio do turno).

## criterios-aceite

- **porta-anuncio/1** — QUANDO a porta de entrada classifica uma demanda O
  SISTEMA DEVE escrever ao humano, antes de registrar o nó, uma frase própria
  de até 150 caracteres `Demanda classificada como <CATEGORIA> porque <motivo
  curto> — me corrija se discordar`
- **porta-anuncio/2** — QUANDO o caso `porta` roda O SISTEMA DEVE reprovar se
  nenhum bloco do assistente tiver o anúncio MEDIUM — em texto: `classificada
  como MEDIUM`, `porque` e `me corrija`; em narração: `classific…` seguido de
  `como MEDIUM`, depois `me corrija` ou `me avise` e `discordar` —, ou se o
  anúncio vier depois da primeira escrita no `MEMORY.md` ou no arquivo do nó
- **porta-anuncio/3** — QUANDO o trace do caso `porta` tem o modelo do
  anúncio só no texto da skill carregada (`[X]`, `[respostas às perguntas]`)
  e não numa resposta do assistente O SISTEMA DEVE reprovar o caso
- **porta-anuncio/4** — QUANDO `bash tests/evals.sh --completo --runs 6
  --caso porta` roda O SISTEMA DEVE aprovar o caso com 6/6 com o plugin e 0/6
  sem, e a linha do `porta` na calibração do `tests/evals/README.md` DEVE
  registrar essa rodada
- **porta-anuncio/5** — QUANDO `bash tests/evals.sh --mutar porta-anuncio
  --runs 3` roda O SISTEMA DEVE ter o resultado (taxa com e sem a regra)
  registrado no nó, caia a taxa ou não
- **porta-anuncio/6** — QUANDO a rodada rápida roda os casos `escopo-antes`,
  `memoria` e `tdd` depois da mudança O SISTEMA DEVE manter os três `PASSOU`;
  reprovação do `tdd` com o perfil `retomada-execute` (run curto, sem a skill
  execute) roda de novo uma vez, com o trace guardado como prova
- **porta-anuncio/7** — QUANDO o modelo cria (Write) arquivo de nó novo em
  `docs/audora/memory/` com `estado: in-progress` ou `hotfix-pending-record`,
  num projeto com `MEMORY.md` em `memory-schema: 1`, e nenhum bloco do
  assistente desde a última mensagem do humano tem o anúncio — em texto:
  `classificada como <LIGHT|MEDIUM|HIGH|HOTFIX>`, `porque` e `me corrija`; em
  narração: `classific…` seguido de `como <CATEGORIA>`, depois `me corrija`
  ou `me avise` e `discordar` — O SISTEMA DEVE recusar a escrita (exit 2) com
  mensagem ao modelo que manda escrever o anúncio em texto ao humano antes de
  registrar o nó, citando a frase-modelo e o teto de 150 caracteres
- **porta-anuncio/8** — QUANDO esse anúncio, no contrato do tipo do bloco
  (texto ou narração), está num bloco do assistente desde a última mensagem
  do humano O SISTEMA DEVE deixar a criação do nó passar (exit 0, sem saída)
- **porta-anuncio/9** — QUANDO a escrita é Edit, Write de nó já existente, de
  nó com outro estado, fora de `docs/audora/memory/` ou em projeto sem
  `memory-schema: 1` O SISTEMA DEVE deixar passar sem saída
- **porta-anuncio/10** — QUANDO o anúncio está só em raciocínio que não é
  narração (sem a marca do servidor ou com marca ilegível), em input de
  ferramenta, em skill carregada ou antes da última mensagem do humano (que
  não é resultado de ferramenta nem skill) O SISTEMA DEVE recusar como em /7
- **porta-anuncio/11** — QUANDO o transcript está ausente ou ilegível, ou o
  próprio hook falha O SISTEMA DEVE deixar a escrita passar (exit 0)
- **porta-anuncio/12** — QUANDO o anúncio em texto passa de 150 caracteres
  O SISTEMA DEVE deixar a criação do nó passar como em /8 (o hook não mede)
- **porta-anuncio/13** — QUANDO `--runs <n>` acompanha `--completo` O SISTEMA
  DEVE rodar n runs por braço em cada caso; `--runs` sem `--completo` nem
  `--mutar` continua recusado com a mensagem de uso

## fora-de-escopo

Casos de eval para LIGHT e HIGH; pausar e esperar confirmação depois do
anúncio (porta → 1ª fase segue sem parada); mudar as perguntas de risco ou as
regras de categoria; afrouxar qualquer grader (exceto o ramo narração,
3ª reabertura); anúncio em outras fases; retomada por comando
(`retomada-execute`); juiz LLM no grader; hook julgar se a categoria está
certa ou medir o tamanho do anúncio; mutação que desligue o hook (a /5 mede o
passo 4); garantir que o humano veja a narração ou zerá-la (harness; ramo narração cobre).

## decisoes

Decisões do 1º escopo, da carga BASE, das reaberturas 1-4 (4ª: anúncio curto,
teto 150, hook não mede, /4 com 6 runs, /6 com rerun) e a medição /5:
`porta-anuncio-historico.md`.
- 2026-10-12 (medição, porta-anuncio/5, 4ª reabertura):
  `--mutar porta-anuncio --runs 3` → com a regra 3/3 · sem a regra 0/3 · efeito -100 pp;
  manter ou cortar a regra é decisão do humano.

## delta

- MODIFICADO (2026-10-12, 4ª reabertura): /1 frase sem teto → ≤ 150 chars e
  `<motivo curto>`; /4 3/3·0/3 → `--runs 6` 6/6·0/6; /6 + rerun no perfil
  retomada; /7 mensagem cita o teto. ADICIONADO: /12, /13

## e2e
2026-10-12: /1, /4, /6 falharam (`docs/audora/e2e/e2e-porta-anuncio.md`).
Reprovação da validate e a resposta: `porta-anuncio-historico.md`.
