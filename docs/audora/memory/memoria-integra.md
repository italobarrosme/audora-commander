---
id: memoria-integra
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [memory, sync, cleanup, spec, criterios, indice, aprendizados]
resumo: Critérios de HIGH sobrevivem ao arquivamento e à cleanup; ordem nó/índice sem contradição nem erro transitório; Aprendizados em arquivo próprio fora do MEMORY
atualizado-em: 2026-10-08
---

# memoria-integra

<!-- HIGH. Revisão de 2026-10-08, pontos 1, 6, 11. Irmãs: caminhos-sem-saida, contratos-de-texto. -->

## objetivo

Nenhum critério ou aprendizado some da memória ao entregar ou limpar, e as regras de escrita do MEMORY são únicas, sem contradição nem erro transitório.

## criterios-aceite

<!-- "Linha de aprendizado" = bullet `- AAAA-MM-DD | <fase> | ...`; "critério numerado" = linha `- **<id>/<n>** — …` (menção em ponteiro não conta). -->

- **memoria-integra/1** — QUANDO a fase scope fecha uma demanda HIGH O
  SISTEMA DEVE gravar os critérios numerados em `## criterios-aceite` do nó,
  e a spec dedicada, se criada, DEVE conter só contexto, sem critérios.
- **memoria-integra/2** — QUANDO o sync vai arquivar um nó sem critério
  numerado e `docs/audora/specs/<id>-escopo.md` tem critérios `<id>/<n>` O
  SISTEMA DEVE copiá-los literalmente para o nó antes do `git mv`.
- **memoria-integra/3** — QUANDO o sync vai arquivar um nó que, depois do
  /2, segue sem critério numerado O SISTEMA DEVE parar sem arquivar e
  avisar o humano nomeando o nó.
- **memoria-integra/4** — QUANDO a varredura da cleanup encontra spec, plano
  arquivado ou relatório e2e de nó delivered que cita critério `<id>/<n>`
  ausente do nó arquivado O SISTEMA DEVE deixá-lo fora do lote, em
  `## mantido`, com o motivo.
- **memoria-integra/5** — QUANDO o arquivo de um nó novo é escrito antes da
  linha dele no índice O SISTEMA DEVE (`memory-validate`) não acusar erro.
- **memoria-integra/6** — QUANDO o `MEMORY.md` é escrito e há arquivo em
  `docs/audora/memory/` sem linha no índice O SISTEMA DEVE
  (`memory-validate`) acusar o erro com exit 2, como hoje.
- **memoria-integra/7** — QUANDO a skill memory e suas references descrevem
  a escrita de nó (criação e transição) O SISTEMA DEVE trazer só a regra
  "arquivo do nó primeiro, linha do índice logo depois", sem "mesma edição".
- **memoria-integra/8** a **/11** — REMOVIDOS em 2026-10-08 (aviso > 40, compactação e histórico; ver delta).
- **memoria-integra/12** — QUANDO a cleanup monta ou aplica um lote O
  SISTEMA DEVE deixar fora dele todo arquivo que o framework lê
  (`MEMORY.md`, nós vivos e arquivados, `decisoes-vivas.md`,
  `aprendizados.md`), e o `aplicar` DEVE recusar lote à mão que
  traga algum deles, sem alterar nada.
- **memoria-integra/13** — QUANDO a skill cleanup descreve o que apaga O
  SISTEMA DEVE declarar o princípio "só sai o que não é mais usado: nunca
  arquivo que o framework lê nem conteúdo que afeta aprendizado ou critério
  sem outra cópia viva", com red flag correspondente.
- **memoria-integra/14** — QUANDO uma fase registra um aprendizado O SISTEMA DEVE gravar a linha em `docs/audora/aprendizados.md`, criando o arquivo se não existir, e nunca no `MEMORY.md`.
- **memoria-integra/15** — QUANDO uma fase carrega contexto O SISTEMA DEVE buscar aprendizados por grep em `docs/audora/aprendizados.md` e também no `MEMORY.md` enquanto ele tiver linha de aprendizado, sem `[invalidado-em:`; sem nenhum dos dois, seguir sem aprendizados e sem erro.
- **memoria-integra/16** — QUANDO o sync roda e a seção Aprendizados do `MEMORY.md` tem linha de aprendizado O SISTEMA DEVE movê-las literalmente, na mesma ordem, para o fim de `docs/audora/aprendizados.md` (criado se não existir, sem alterar as linhas que já estão lá) e deixar na seção só 1 linha de ponteiro para o arquivo.
- **memoria-integra/17** — QUANDO o bootstrap cria o `MEMORY.md` O SISTEMA DEVE deixar a seção Aprendizados só com a linha de ponteiro, sem criar `docs/audora/aprendizados.md`.
- **memoria-integra/18** — QUANDO esta demanda for entregue O SISTEMA DEVE ter o `MEMORY.md` deste repo sem linha de aprendizado, todas em `docs/audora/aprendizados.md`, e a suíte DEVE provar isso.
- **memoria-integra/19** — QUANDO a cleanup varre links O SISTEMA DEVE ignorar `docs/audora/aprendizados.md` como hoje ignora a seção Aprendizados do `MEMORY.md`.
- **memoria-integra/20** — QUANDO `docs/audora/aprendizados.md` é escrito, com qualquer número de linhas, O SISTEMA (`memory-guard`) DEVE sair 0 sem aviso.
- **memoria-integra/21** — QUANDO skills, templates e mensagens de hook dizem onde vive aprendizado O SISTEMA DEVE citar só `docs/audora/aprendizados.md`, sem teto de ~40 linhas nem `aprendizados-historico.md`.

## fora-de-escopo

- Restaurar critérios de nós já arquivados (aqui ou em projetos-alvo).
- Pontos 2-5, 7-10 e 12 da revisão (caminhos-sem-saida, contratos-de-texto).
- Teto, aviso ou compactação do `docs/audora/aprendizados.md`.
- Mudar o formato da linha de aprendizado ou a regra de invalidação.
- Mudar os tetos de ~300 linhas do índice e ~100 por nó.
- Migrar spec HIGH de demanda em andamento em projeto-alvo, além do /2.

## decisoes

- 4 decisões do scope (3 demandas; critério de HIGH no nó; sem reparo de arquivados; cleanup só apaga o sem uso) → [histórico](memoria-integra-historico.md).
- 2026-10-08 (humano, plan): não compactar; aprendizados saem do MEMORY para `docs/audora/aprendizados.md`, consultado por grep. Descartado: aviso > 40 + compactação no sync (decisão anterior, invalidada); histórico manual.
- 2026-10-08 (humano, plan): MEMORY antigo migra no próximo sync; arquivo nasce no 1º aprendizado. Descartado: migrar no 1º registro; nunca migrar; criar no bootstrap.
- 2026-10-08 (humano, plan): /12 vale para itens que removem arquivo pelo caminho; planned órfão aprovado segue apagando o próprio nó. Descartado: órfão com arquivo vai para `## mantido`.
- 2026-10-08 (humano, plan): divergência MEMORY × código no /18 (a prova citava linhas que o faxina-restos já apagou) → /18 sem essa prova; ferramenta removida não volta à memória. Descartado: restaurar as linhas; trocar por prova das invalidadas atuais.
- 2026-10-08 (humano, validate): critério numerado = linha `- **<id>/<n>** — …`; menção em ponteiro não conta. Descartado: só o sync; rebaixar a ressalva.

## delta

- REMOVIDO (2026-10-08): /8–/11 (aviso > 40, compactação, histórico, ≤ 40 no repo) — humano não quer compactação.
- MODIFICADO (2026-10-08): /12 `aprendizados-historico.md` → `aprendizados.md`; fora-de-escopo sem a busca no histórico.
- ADICIONADO (2026-10-08): /14–/21. Já aplicado no corpo pela reabertura do scope, antes do plano.
- MODIFICADO (2026-10-08, plan): /18 perde a prova de linhas de ferramenta já removida — só "MEMORY sem aprendizado, todos em `docs/audora/aprendizados.md`".
- MODIFICADO (2026-10-08, validate): "critério numerado" = `<id>/<n>` → linha `- **<id>/<n>** — …`.

## e2e

passou (17/17, 2026-10-08) — [relatório](../e2e/e2e-memoria-integra.md)

## feedback-reprovacao
