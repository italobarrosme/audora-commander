---
id: cleanup-alvo-ausente
estado: delivered
origem: humano
depende-de: [skill-cleanup]
arquivos: [CHANGELOG.md, MEMORY.md, PRD.md, docs/audora/e2e/e2e-cleanup-alvo-ausente.md, docs/audora/planos/arquivo/plano-cleanup-alvo-ausente.md, hooks/cleanup, skills/cleanup/SKILL.md, tests/test-skill-cleanup.sh]
keywords: [cleanup, orfao, planned, alvo-ausente]
resumo: O /4 mecânico da cleanup só marca planned órfão por caminho que já existiu no repo, não por arquivo ainda não criado
atualizado-em: 2026-10-03
---

# cleanup-alvo-ausente

## objetivo

O `hooks/cleanup` deixa de listar como planned órfão ("alvo ausente") o nó
planned cujo arquivo-chave ainda não foi criado; só o caminho que existiu e
sumiu conta como alvo ausente.

## criterios-aceite

- **cleanup-alvo-ausente/1** — QUANDO um nó planned cita em arquivos-chave um caminho ausente do disco que nunca foi versionado em commit alcançável do HEAD O SISTEMA DEVE deixá-lo fora do relatório inteiro (nem no lote, nem em `## mantido`, nem em outra seção), sem aviso
- **cleanup-alvo-ausente/2** — QUANDO um nó planned cita em arquivos-chave um caminho que já foi versionado em commit alcançável do HEAD e não existe mais no disco O SISTEMA DEVE listá-lo como planned órfão com o motivo `alvo ausente: <caminho>`
- **cleanup-alvo-ausente/3** — QUANDO um nó planned cita vários caminhos e só parte deles existiu e sumiu O SISTEMA DEVE listá-lo como planned órfão citando no motivo só os caminhos que existiram e sumiram
- **cleanup-alvo-ausente/4** — QUANDO o caminho citado só foi versionado em branch não alcançável do HEAD O SISTEMA DEVE tratá-lo como nunca existiu (fora do relatório)
- **cleanup-alvo-ausente/5** — QUANDO o caminho citado é diretório (termina em `/`) O SISTEMA DEVE considerá-lo versionado se algum arquivo sob ele foi versionado em commit alcançável do HEAD
- **cleanup-alvo-ausente/6** — QUANDO o caminho citado existe hoje no disco O SISTEMA DEVE deixar o planned fora do relatório, como antes
- **cleanup-alvo-ausente/7** — QUANDO a skill passa `--orfao <id>=<motivo>` para um planned O SISTEMA DEVE listá-lo com o motivo dado, mesmo que o caminho dele nunca tenha existido, como antes
- **cleanup-alvo-ausente/8** — QUANDO `contar` roda O SISTEMA DEVE devolver o mesmo total que o `varrer`, sem contar planned cujo caminho nunca existiu
- **cleanup-alvo-ausente/9** — QUANDO o repositório ainda não tem nenhum commit O SISTEMA DEVE tratar todo caminho ausente como nunca existiu e terminar a varredura sem erro
- **cleanup-alvo-ausente/10** — QUANDO a skill cleanup orienta o julgamento dos planned O SISTEMA DEVE dizer que o script só acha caminho que existiu e sumiu, e que a IA só usa `--orfao <id>=alvo ausente: <alvo>` depois de conferir no histórico que o alvo existiu

## fora-de-escopo

- A nota "recuperável no git" em link que já nasceu quebrado (ressalva do
  `skill-cleanup`, segue como meta futura no `PRD.md`).
- Clone raso: caminho removido antes do corte do histórico conta como
  nunca existiu e fica fora (erro conservador, aceito).
- Caminho com `*` ou `<` (glob/placeholder) continua pulado, como hoje.
- Detectar planned parado por tempo ou feature futura que mudou de nome.
- Rodar a cleanup neste repo (guarda de `tests/test-dogfood.sh:10`).

## decisoes

- 2026-10-02 (porta de entrada): classificada MEDIUM — nenhuma pergunta de
  risco deu sim; múltiplos arquivos (`hooks/cleanup`, teste, frase da skill)
  e lógica nova (consulta ao histórico do git). Origem: ressalva do
  `skill-cleanup` aceita no portão (meta futura 6 do `PRD.md`).
- 2026-10-02 (humano): planned com caminhos mistos é listado citando só os
  que existiram e sumiram. Descartado: listar só se todos sumiram.
- 2026-10-02 (humano): planned de caminho que nunca existiu fica silencioso.
  Descartado: seção informativa fora do lote — feature futura é o normal,
  não sobra.
- 2026-10-02 (humano): "existiu" = versionado em commit alcançável do HEAD.
  Descartado: qualquer branch (`--all`) — arquivo de branch não integrada
  não é sumido.
- 2026-10-02 (humano): a nota do /10 do `skill-cleanup` fica fora. Descartado:
  incluir nesta demanda.
- 2026-10-02 (humano): portão de escopo APROVADO ("aprovado") — 10 critérios.
- 2026-10-03 (humano): portão final — aprovação parcial (opção A): o achado do
  e2e (frase da skill sem `--literal-pathspecs`; `[slug]` casava por glob, e
  a flag do script sem teste) fechado na Tarefa 4 do plano antes do sync;
  depois, aprovado. Sem decisão viva nova (as 3 decisões humanas têm teste
  que as impõe: /1, /3, /4).

## delta

## e2e

2026-10-02: `docs/audora/e2e/e2e-cleanup-alvo-ausente.md` removido em 2026-10-03 pela cleanup — recuperável no git — 10 passou;
achado: a frase da skill (`git log … -- <alvo>`) sem `--literal-pathspecs`
casa `[slug]` por glob (a IA conferiu literal por conta própria) — fechado
na Tarefa 4 (2026-10-03).

## feedback-reprovacao
