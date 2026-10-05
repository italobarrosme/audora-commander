# PRD — audora-commander

> Última atualização: 2026-10-05

## O que é e para que serve

Plugin de Claude Code (padrão Superpowers) que implementa um framework de
desenvolvimento de software assistido por IA, guiado por 5 Princípios de AI
Coding: memória dinâmica do produto (MEMORY vivo), planejamento
just-in-time, separação "O Quê"/"Como",
processo proporcional ao risco da demanda, e IA executa / humano decide.
Público-alvo: dev solo ou time pequeno construindo web/mobile/api com Claude
Code.

## Stack

- Markdown (skills, templates, docs) + JSON (plugin.json, marketplace.json,
  hooks.json) + bash (hooks: `session-start`, `memory-guard`,
  `memory-validate`; scripts auxiliares `gate` e `cleanup`, este em perl
  via `perl -x`; sem jq — awk/sed/grep/perl do
  Git for Windows).
- Suíte de regressão do plugin em bash: `tests/run.sh` + `tests/test-*.sh`
  (fixtures em `mktemp -d`, `tests/lib.sh` com asserts e `run_hook`). O
  `run.sh` roda os arquivos em paralelo (`SUITE_JOBS`, default = núcleos;
  `1` = série) com timeout por arquivo (`SUITE_TIMEOUT`, default 300 s; `0`
  desliga) e imprime em blocos na ordem do glob, com o tempo no resumo.
- Sem dependência externa de índice de código: o Graphify saiu na 0.10.0;
  a localização de código é a busca do símbolo pelo harness, com leitura
  por trecho.
- Formato de plugin do Claude Code: `.claude-plugin/` + `skills/` + `hooks/`.
  Versão 0.16.0.

## Arquitetura

9 skills: 8 encadeadas por um roteador central e 1 skill-ferramenta
(`cleanup`):

- `audora-commander` — porta de entrada: classifica demanda (LIGHT / MEDIUM /
  HIGH / HOTFIX) por perguntas binárias de risco e roteia pelas fases.
  Projeto sem `MEMORY.md` → oferece bootstrap.
- `memory` — dona do MEMORY (memória externa do produto, `memory-schema: 1`):
  `MEMORY.md` é índice mestre (Propósito, Constituição, Aprendizados, linha
  rica por nó); corpo de cada nó em `docs/audora/memory/<id>.md` com
  frontmatter grep-ável e critérios EARS numerados `<id>/<n>`; decisões
  duráveis em `docs/audora/decisoes-vivas.md`; arquivamento por `git mv` para
  `docs/audora/arquivo/`. Operações: carregar-contexto, bootstrap (MEMORY +
  etapa gate, sem índice de código), registrar-no, registrar-delta, registrar-aprendizado
  (1 linha `data | fase | aprendizado`, na hora, por qualquer fase) e
  compactar. A skill é um **roteador**: `carregar-contexto`,
  `registrar-delta` e `registrar-aprendizado` ficam inline no `SKILL.md`
  (135 linhas); `bootstrap`, `registrar-no` e `compactar` vivem em
  `skills/memory/references/`, lidas UMA por operação — reference ausente
  avisa e degrada, sem travar a fase. O `carregar-contexto` lê o
  `MEMORY.md` por seção, nunca inteiro, e as fases o chamam antes de
  qualquer Read:
  - Propósito e Constituição: inteiras, por `offset`/`limit`.
  - Aprendizados: por `grep` — linhas da fase + keywords e arquivos do nó
    (porta: termos do pedido); `[invalidado-em:` nunca entra; nada casou →
    segue sem aprendizados.
  - Índice de nós: inteiro na porta, scope e plan; execute, e2e, validate e
    debug pegam só a linha do nó e as de `depende-de`.
  - Seção não encontrada → aviso de 1 linha, leitura inteira, a fase segue.
- `scope` — fase "O Quê": critérios EARS, marcador [PRECISA-CLARIFICAR].
- `plan` — fase "Como" just-in-time: plano-arquivo em que cada tarefa é um
  MAPA, sem corpo de teste nem de implementação. A tarefa traz o requisito
  `<id>/<n>`, o ponto de mudança `caminho:linha`, o arquivo e o caso de
  teste, os trechos a ler, o done e, quando o critério deixa o valor
  aberto, a asserção exata `entrada → saída esperada`. O header lista cada
  leitura como `caminho:início-fim`. Pergunta ampla vai a um subagente de
  exploração que devolve `caminho:linha`, conferido por leitura própria.
- `execute` — TDD red-green com evidência real; commit por etapa verde. O
  código do teste nasce aqui, do caso e das asserções do mapa. Seção
  `## Localização de código`:
  - lê os trechos do mapa, e arquivo com mais de 200 linhas nunca é lido
    inteiro;
  - fora do mapa, busca o símbolo e segue ligações de import, herança,
    registro e configuração;
  - na 3ª leitura fora do mapa, anota no mapa e segue;
  - modificar arquivo fora do mapa volta ao plan;
  - `caminho:linha` desatualizado é relocalizado pelo símbolo;
  - plano no formato antigo é executado como está.
- `e2e` — levanta o projeto e exercita a demanda de ponta a ponta (opcional,
  fortemente recomendada).
- `validate` — portão humano final: evidência 1:1 com critérios, sync
  MEMORY → PRD no merge (consolida delta, decisões vivas e aprendizados,
  arquiva o nó por movimento, atualiza a foto do `PRD.md` e acrescenta 1
  linha ao `CHANGELOG.md` da raiz, em toda categoria). O `PRD.md` é foto
  (o que é, stack, arquitetura, metas futuras) com até 200 linhas; o
  histórico de entregas mora no `CHANGELOG.md` (formato em
  `templates/changelog-template.md`), e PRD com histórico é convertido
  on-touch, no próximo sync. Roteador: fluxo até o portão inline; sync,
  filtro de decisões vivas, revisão adversarial e Fechamento LIGHT em
  `skills/validate/references/`; reference ausente mantém o portão e não
  roda o sync. A revisão adversarial (só HIGH, `revisao-adversarial.md`)
  bloqueia só achado provado de 3 classes (alheio, critério, formato real);
  o resto vira ressalva de 1 linha. Para em 1 passagem completa mais a
  reverificação dos bloqueantes corrigidos. Ressalva aceita no portão vai
  ao nó e, no sync, às metas futuras como candidato a nó.
- `debug` — debug com causa raiz demonstrada (modo sintoma, que localiza
  código como a `execute`) ou caçada de defeitos por classes com
  verificação de cada achado (modo caçada).
- `cleanup` — skill-ferramenta, invocada pelo humano em projeto com
  `MEMORY.md`: varre as sobras do processo (planned órfão, spec, plano
  arquivado e e2e de nó delivered, depuração sem nó vivo, arquivo de
  `docs/audora/` sem referência viva, link quebrado), apresenta relatório e,
  com aprovação explícita do lote (com retirada de itens), aplica num
  commit só. O mecânico mora em `hooks/cleanup` (`varrer`/`contar` só
  leem; `aplicar` apaga, troca link para arquivo apagado pela nota
  "removido … recuperável no git" e link quebrado pela nota "já não
  existia … (link limpo pela cleanup)", apaga a linha do planned aprovado,
  roda o `memory-validate` e desfaz tudo se algo falhar). Arquivo que sai
  no lote não recebe troca de link, então item que cita outro item do lote
  não trava o `git rm`. Link quebrado é só o que aponta caminho que existiu
  em commit alcançável do HEAD; caminho nunca versionado vira aviso
  `## nunca existiu`, fora do lote e nunca trocado (o `aplicar` recusa lote
  à mão que o traga como link quebrado). A seção Aprendizados do
  `MEMORY.md` não é varrida nem reescrita (segue contando como referência
  viva). Fora do git ou sujo fica fora do lote. Pela
  coluna arquivos-chave, o script só marca "alvo ausente" o caminho que
  existiu em commit alcançável do HEAD e sumiu do disco (`git
  --literal-pathspecs log --full-history HEAD`). Caminho que nunca existiu
  é feature futura e fica fora do relatório; repo sem commit não tem alvo
  ausente. O julgamento semântico de planned órfão é da skill (`--orfao`),
  que confere o histórico antes de marcar alvo ausente. O sync da
  validate só sugere em 1 linha, com a contagem.

Graphify: o plugin não oferece, instala, consulta, limpa nem cita o índice de
código.

Fronteira de fase: fim de scope, plan ou execute de MEDIUM/HIGH é PARADA —
a fase não emenda a seguinte e imprime `/clear` + o comando de retomada
`<fase> de <id>`; a fase nova se reancora só pelos artefatos em disco.
"Segue" sem `/clear` roda a fase seguinte num subagente de contexto zerado
(`templates/fase-subagente-template.md`), que nunca aprova portão e devolve
pergunta humana à sessão principal. Sem parada: entrada → 1ª fase, LIGHT,
HOTFIX e e2e ↔ validate. Todo portão do meio é humano — não há modo que o
antecipe. Regra única na seção `## Parada entre
fases` de `templates/bloco-fechamento-template.md`.

Hook SessionStart injeta ponteiro curto para a porta de entrada. Hooks
PostToolUse (Edit|Write) validam escritas no MEMORY: `memory-guard` (tetos
de ~300 linhas no índice e ~100 por nó, e 200 linhas no `PRD.md` irmão de
um `MEMORY.md` com schema) e `memory-validate` (seções
obrigatórias do índice, índice↔pasta, depende-de existente, ciclo, estado
dentro do enum EN no índice E no frontmatter de cada nó, nó sem `estado:`, e
— só na escrita do índice — estado índice ≠ nó; transição é nó primeiro,
índice depois) — erro volta ao modelo via exit 2; arquivo sem
`memory-schema: 1` na linha 1 é ignorado; sem bash, as skills seguem sendo a
fonte normativa.

Documentos de referência: `docs/fundamentos.md` (fundamentos v2 dos princípios)
e `docs/specs/2026-08-14-audora-commander-design.md` (spec de design).

## Metas futuras de implementação

1. Futuro: porte para outros harnesses, marketplace público,
   agentes dedicados.
2. Candidato a nó: eliminar o erro transitório na CRIAÇÃO de nó ("arquivo
   sem linha no índice" ao escrever o nó antes do índice), fora do escopo de
   `validate-estado-no`.
3. Candidato a nó: acabamento da PARADA (`contexto-por-fase`, observações do
   e2e aceitas no portão) — unificar a pontuação (template com vírgula,
   skills com dois-pontos), recusa de retomada imprimindo o bloco de fase
   bloqueada, e folga na carga BASE (12 bytes do teto).
4. Candidato a nó: ressalvas da revisão adversarial do `corte-sem-uso`
   (aceitas no portão).
   - As guardas de ausência de `tests/test-corte-sem-uso.sh` deixam passar
     variações de texto: "loop engine", "nove skills", `|  \`worktree\`  |`
     com espaço extra e o bullet `**loop:**`.
   - A guarda do Graphify no próprio repo não cobre `.claude/skills/graphify`,
     `CLAUDE.md` nem settings.
   - `hooks/gate` compara contra HEAD. Por isso, depois do commit, não prova
     o `gate-asserts:` nem teste apagado.

   A antiga meta das bordas da limpeza do Graphify caiu com o script.
5. Candidato a nó: ressalvas do `plano-mapa` aceitas no portão.
   - /4 (subagente de exploração conferido) e /8 (3ª leitura fora do mapa)
     só têm guarda de texto. Nenhuma sessão real chegou a esses gatilhos.
   - O plan ainda pode ler um arquivo grande inteiro. O critério exige só o
     header por trecho.
   - Na execute, o custo subiu +3,7% (n=1, demanda pequena). Vale medir de
     novo numa demanda maior.
   - A seção Aprendizados do `MEMORY.md` está com 51 linhas, acima do
     gatilho de ~40. Compactar exige mexer na guarda de
     `tests/test-dogfood.sh:18`, que prende os aprendizados invalidados do
     Graphify no índice.
