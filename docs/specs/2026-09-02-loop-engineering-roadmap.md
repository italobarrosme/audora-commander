# Roadmap — Loop engineering no audora-commander

> Data: 2026-09-02. Insumo da porta de entrada (`audora-commander`) e da fase
> `scope` das demandas listadas abaixo. Origem: estudo da técnica de loop
> engineering (Geoffrey Huntley, jul/2025, "Ralph loop"; nome consolidado em
> 2026) a partir de relato prático em vídeo, mais a discussão desta sessão sobre
> "precisar ficar aceitando comandos". Este documento é PROPOSTA: nenhum nó foi
> registrado no MEMORY — a decomposição e a ordem passam por decisão humana
> antes de virar nó `planned`.

## Sumário executivo

A dor relatada: o framework pede aceite demais ao longo de uma demanda. Dois
tipos de aceite estão misturados: (1) prompts de permissão do harness (Bash,
Edit, Write), que não são do framework e se resolvem por configuração; (2)
portões humanos do framework, que são desenho (P5). Loop engineering não elimina
o humano — move o portão para as bordas (spec de dia, revisão de manhã) e
entrega a aprovação de cada volta a um gate mecânico (teste, build, lint) que o
agente não controla. O audora já tem as bordas no lugar (scope = spec;
validate = revisão de manhã). O que falta, em ordem de dependência: um gate
mecânico único por projeto, um modo autopilot que antecipe os portões do meio
por declaração explícita do humano, e um motor headless que rode o
plano-arquivo volta a volta com contexto zerado, teto de gasto e condição de
parada.

Tese em uma frase: **spec = direção, teste = aprovação, loop = execução,
humano decide nas bordas.**

## O que loop engineering ensina (condensado)

- Motor de três linhas de bash; a engenharia está nos arquivos que o agente
  lê: prompt fixo, lista de tarefas com checkbox, specs curtas, como-rodar.
- Cada volta é sessão nova, contexto zerado de propósito. Memória mora em
  arquivo e no git, nunca no chat.
- Quem aprova a volta é o teste. Sem critério automático, o loop produz lixo a
  noite toda com confiança. "Deixa bonito" não é critério.
- Condição de parada explícita: lista sem item aberto, limite de voltas, teto
  de gasto, `DONE` impresso.
- Segurança sem item opcional: sandbox, sem credencial de produção, branch
  própria + commit por volta verde, teto, gates, hooks determinísticos
  (instrução no prompt é conselho; hook executa sempre), escopo pequeno (diff
  revisável em 15 minutos).
- Desastres com fonte: agente apagou banco de produção com "não mexe" escrito
  no prompt (regra no prompt é pedido; bloqueio real é permissão + sandbox);
  agente hardcodou valor esperado e apagou arquivo de teste para passar (ler o
  diff dos testes; CI fora do alcance do agente); devs experientes 19% mais
  lentos achando que estavam 20% mais rápidos (medir, não sentir).
- A pergunta que decide: um teste automático sabe dizer se ficou pronto? Sim →
  candidato a loop. Não → spec + revisão tarefa a tarefa, humano no comando
  (produção/legado, "pronto" é gosto, arquitetura, dinheiro e dados).

## Diagnóstico: audora hoje × loop

| Peça do loop | No audora hoje | Situação |
|---|---|---|
| `specs/` | nó de scope com critérios EARS numerados `<id>/<n>` | tem |
| `fixplan.md` | `docs/audora/planos/plano-<id>.md`: tarefas, `depende-de`, checkbox | tem |
| `agents.md` | Constituição do MEMORY (`como-rodar`, `stack`, `padroes`) | tem |
| volta verde + commit | execute: TDD red-green, commit por etapa verde citando `<id>/<n>` | tem |
| revisão de manhã | validate: evidência 1:1 + portão humano | tem |
| recuperação | fluxo de reprovação (P5.5): escopo → scope, execução → plan | tem |
| loops paralelos | skill worktree, fan-out com domínios não-sobrepostos | tem (em sessão) |
| gate mecânico único, fora do alcance do agente | execute "roda a suíte"; sem lint/typecheck/anti-fraude de teste padronizados; quem declara verde é o próprio agente | **falta** |
| contexto zerado por volta | fases rodam na mesma sessão; releitura do plano é instrução, não mecanismo | **falta** |
| condição de parada + teto | não existe; a sessão acaba quando o humano para | **falta** |
| classificação "loopável" | validate distingue evidência automatizada de item humano, mas só no fim | **falta na entrada** |
| portões só nas bordas | MEDIUM para em scope, oferta de e2e e validate; HIGH soma plan | parcial |

Paradas humanas por categoria hoje (sem contar prompts do harness):

| Categoria | Paradas |
|---|---|
| LIGHT | validate (+ oferta de e2e se toca caminho do usuário) |
| MEDIUM | lotes de perguntas do scope, portão de scope, oferta de e2e, validate |
| HIGH | lotes do scope, portão de scope, portão de plan, oferta de e2e, validate |

## O que NÃO muda (invariantes)

1. O portão final da validate existe em toda categoria (P4: portão nunca
   escala para baixo). Autopilot antecipa portões do meio por declaração do
   humano; nunca remove o último.
2. HIGH nunca roda em autopilot nem em motor. O próprio loop engineering
   exclui arquitetura, dinheiro, dados e produção do ciclo cego.
3. Efeito irreversível fora do repo = mão do humano, sempre (P5.6).
4. `[PRECISA-CLARIFICAR]` nunca vira suposição (P3.2). Em autopilot, marcador
   aberto é condição de parada legítima, não licença para chutar.
5. Sandbox, credenciais e modo de permissão do harness são decisão do humano.
   O framework pergunta uma vez, registra na Constituição e avisa; não instala
   nem configura por conta própria.
6. Constituição do plugin: executável só em `hooks/` e `tests/`; skill ≤ 250
   linhas; schema só em `templates/`; prosa PT, identificadores EN.

## Demandas propostas (decomposição)

Pedido único com vários subsistemas → decompor (regra "demanda gigante" da
porta de entrada). Os critérios abaixo são RASCUNHO para semear a fase scope de
cada demanda — não substituem o portão de escopo.

### D0 — `docs-permissoes` (LIGHT)

Classificação: sem migração, sem API, sem auth, sem efeito irreversível; um
arquivo por idioma, sem lógica nova → LIGHT.

Objetivo: tirar da conta do framework a dor que não é dele. Seção nos READMEs
(EN + PT) "Reduzindo prompts de permissão": `permissions.allow` em
`settings.json`, `--permission-mode acceptEdits`, `bypassPermissions` só em
sandbox ou worktree descartável, e o aviso do loop engineering (regra no prompt
é pedido; bloqueio real é permissão).

Critério rascunho: QUANDO o leitor procurar "permission" nos READMEs O SISTEMA
DEVE apresentar as três opções com o nível de risco de cada uma.

Fora de escopo: qualquer mudança em skill ou hook.

### D1 — `gate-mecanico` (MEDIUM)

Classificação: sem migração/API/auth/irreversível; múltiplos arquivos e lógica
nova → MEDIUM.

Objetivo: um comando único por projeto-alvo que responde passou/não passou — o
"teste que define pronto" do loop. Gerado a partir de
`templates/gate-template.md` (mesmo padrão do `e2e-infra-template.md`), vive no
projeto-alvo, registrado na Constituição como bullet `gate:`. Cobre: suíte de
testes, lint, typecheck quando a stack tem, e **anti-fraude de teste**: reprova
se o diff apagou arquivo de teste, adicionou `skip`/`only`/`xit`, ou derrubou a
contagem de asserts sem justificativa registrada no nó.

O que muda: `templates/gate-template.md` (novo);
`skills/memory/references/bootstrap.md` (oferece o gate, registra `gate:`);
`skills/execute/SKILL.md` (GREEN = gate verde, não só "suíte");
`skills/validate/SKILL.md` (roteiro destaca o diff de arquivos de teste em toda
categoria); `tests/` (asserts de conteúdo + fixture com repo git real
exercitando as três fraudes).

Critérios rascunho:

- QUANDO o projeto-alvo não tiver `gate:` na Constituição O SISTEMA DEVE
  oferecer gerar o gate a partir do template e registrar a escolha (aceito,
  recusado).
- QUANDO o diff da volta apagar um arquivo de teste O SISTEMA DEVE reprovar o
  gate nomeando o arquivo.
- QUANDO o diff adicionar marcador de skip/only O SISTEMA DEVE reprovar o gate
  nomeando linha e arquivo.
- QUANDO o gate rodar em projeto sem lint ou typecheck O SISTEMA DEVE pular a
  etapa avisando, nunca falhar por ausência de ferramenta.
- QUANDO a validate montar o roteiro O SISTEMA DEVE listar o diff dos arquivos
  de teste separado do resto.

Fora de escopo: instalar ferramentas no projeto-alvo; CI remoto; hook de git
`pre-commit` (decisão do humano por projeto — a Constituição registra se
existe).

Vale sozinha: mesmo sem autopilot, toda demanda ganha o gate e a anti-fraude.

### D2 — `autopilot` (HIGH)

Classificação: toca o schema persistido do nó (campo novo) e o contrato de
portão humano do P5 — na dúvida, a mais pesada → HIGH.

Objetivo: o humano declara na entrada da demanda ("autopilot" / "roda até o
validate") e o framework antecipa os portões do meio, mantendo o último. Só
LIGHT e MEDIUM; HIGH com autopilot → o framework recusa e explica (catraca).
Elegibilidade pela pergunta que decide: todos os critérios EARS do nó têm
verificação automatizável (teste, e2e, comando)? Não → inelegível, fluxo
normal, com o critério culpado nomeado.

O que muda por skill:

- `audora-commander`: reconhece a declaração; HIGH → recusa; registra no nó
  `autopilot: declarado`.
- `scope`: perguntas continuam (spec de dia); marcador aberto = parada, com
  bloco de fechamento "aguardando humano"; auto-revisão ganha a checagem de
  elegibilidade e grava `autopilot: elegivel | inelegivel (<id>/<n>)`; o
  portão de scope vira **portão antecipado**: o humano já aprovou na entrada;
  o escopo fechado sem marcador segue para plan e é apresentado para
  ratificação na validate.
- `plan`: MEDIUM já segue direto; sem mudança além de ler o campo.
- `e2e` + `validate`: em autopilot, e2e roda sem oferta quando a Constituição
  tem `ferramenta-e2e`; ausente → nó `e2e: pulado-por-autopilot-sem-ferramenta`,
  visível no portão. Roteiro ganha a seção "Premissas e decisões tomadas sem
  portão" e o contador **paradas humanas: N** no bloco de fechamento (a
  métrica da dor).
- `templates/no-template.md`: campo `autopilot:` com comentário dos valores;
  `hooks/memory-validate` aceita o campo (ou ignora campo desconhecido — a
  suíte prova qual dos dois vale hoje).
- `docs/fundamentos.md`: P5 ganha "portão antecipado por declaração" e a
  tabela do P4 ganha a coluna autopilot; decisão viva candidata.

Critérios rascunho:

- QUANDO o humano declarar autopilot em demanda HIGH O SISTEMA DEVE recusar,
  dizer o motivo e seguir o fluxo HIGH normal.
- QUANDO um critério do nó não tiver verificação automatizável O SISTEMA DEVE
  marcar `inelegivel` citando o endereço `<id>/<n>` e seguir o fluxo normal.
- QUANDO o scope fechar sem marcador aberto em demanda elegível O SISTEMA DEVE
  seguir para plan sem esperar aprovação, registrando a antecipação em
  `## decisoes` do nó.
- QUANDO restar `[PRECISA-CLARIFICAR]` O SISTEMA DEVE parar e imprimir o bloco
  de fechamento com a fase desmarcada e o marcador.
- QUANDO a validate rodar em autopilot com `ferramenta-e2e` registrada O
  SISTEMA DEVE executar o e2e sem perguntar.
- QUANDO a validate imprimir o bloco de fechamento O SISTEMA DEVE incluir
  `paradas humanas: N`.
- QUANDO a suíte rodar O SISTEMA DEVE provar por teste negativo que o portão
  final continua declarado na seção de autopilot da validate.

Fora de escopo: o motor headless (D3); mudar o que é HIGH; reduzir perguntas
do scope.

Depende de: D1 (sem gate, autopilot é confiança sem evidência).

### D3 — `loop-motor` (HIGH)

Classificação: executa `claude -p` com permissões amplas por conta própria,
gasta dinheiro, pode ter efeito fora do repo → HIGH.

Objetivo: script em `hooks/loop` (+ wrapper `.cmd`, padrão `run-hook.cmd`)
que roda o plano-arquivo de uma demanda em autopilot volta a volta: cada volta
é um `claude -p` novo (contexto zerado), com prompt fixo gerado de
`templates/loop-prompt-template.md` (nó + plano + UMA tarefa + regras: uma
tarefa por volta, procurar antes de criar, placeholder proibido). O **motor** —
não o agente — roda o gate depois da volta, commita no verde, marca o checkbox,
e no vermelho grava o diagnóstico nas Notas de sessão do plano. Condições de
parada: plano sem tarefa aberta (imprime `DONE` e chama a preparação de
evidência da validate), N vermelhos seguidos na mesma tarefa (nó → `blocked`),
teto de voltas, teto de custo (`--max-budget-usd`, confirmado no Claude Code
2.1.247), marcador aberto. Registra métricas por rodada (voltas,
verde/vermelho, custo, tempo) no plano.

Pré-condições que o motor exige antes da primeira volta: nó
`autopilot: elegivel`; Constituição com `gate:`; Constituição com `sandbox:`
(`docker | vm | nenhum` — `nenhum` só roda com confirmação explícita e aviso
impresso); branch própria da demanda; teto informado.

O que muda: `hooks/loop` + `hooks/loop.cmd` (novos);
`templates/loop-prompt-template.md` (novo); `skills/execute/SKILL.md` (seção
"volta de loop": o que uma volta faz e o que NÃO faz — não commita, não marca
checkbox, não toca outra tarefa); `skills/validate/SKILL.md` (recebe o
relatório de rodada); `tests/test-loop.sh` com `claude` FALSO no PATH
(fixture) e repo git real: caminho feliz, tarefa que nunca fica verde, teto
estourado, plano sem tarefa, sem git, gate ausente, sandbox `nenhum` sem
confirmação, segunda execução (retomada).

Critérios rascunho:

- QUANDO uma volta terminar O SISTEMA DEVE rodar o gate fora do processo do
  agente e só então decidir verde/vermelho.
- QUANDO o gate der verde O SISTEMA DEVE commitar citando `<id>/<n>` e marcar
  a tarefa no plano; QUANDO der vermelho O SISTEMA DEVE não commitar e gravar
  a saída do gate nas Notas de sessão.
- QUANDO a mesma tarefa ficar vermelha N vezes O SISTEMA DEVE parar, virar o
  nó para `blocked` e imprimir o bloco de fechamento com o motivo.
- QUANDO o teto de custo ou de voltas for atingido O SISTEMA DEVE parar
  deixando o plano retomável, sem trabalho pela metade commitado.
- QUANDO a Constituição não tiver `sandbox:` O SISTEMA DEVE recusar a rodada e
  dizer o que falta.
- QUANDO a suíte rodar O SISTEMA DEVE exercitar o motor com `claude` falso,
  nunca chamando o modelo real.

Fora de escopo: paralelismo (D4); instalar docker/VM; escolher modelo por
tarefa (fica como parâmetro simples); rodar HIGH.

Depende de: D1, D2.

### D4 — `loop-paralelo` (classificar na hora; provável HIGH)

Objetivo: N motores em N worktrees (skill worktree, fan-out), domínios de
arquivo não-sobrepostos, integração em série pela operação 5 da worktree. Um
nó por motor; o teto de `in-progress` continua valendo. Só depois de D3 rodar
no próprio repo por algumas demandas reais.

Depende de: D3.

## Ordem e por quê

1. **D0** — alívio imediato, sem risco, sem dependência.
2. **D1** — sem gate, tudo o que vem depois é confiança sem evidência; vale
   sozinha.
3. **D2** — reduz as paradas de MEDIUM de 3-4 para 1 (mais os lotes do scope,
   que são a spec de dia).
4. **D3** — a noite: contexto zerado, teto, parada.
5. **D4** — só com D3 provado.

Cada uma vale por si e cabe num PR pequeno — a própria regra do loop.

## Decisões do humano antes de abrir a primeira demanda

1. **Concorrência**: há 3 nós `in-progress` (`plugin-v0.1.0`,
   `memory-graphify`, `sync-mecanizado`); o teto é 3. Os dois primeiros são
   guarda-chuva de agosto; decidir: arquivar como `delivered`, `discarded`, ou
   manter. `sync-mecanizado` está em plano e toca `skills/validate/SKILL.md` e
   `hooks/` — D1 e D2 tocam o mesmo arquivo. Recomendação: fechar
   `sync-mecanizado` antes de D1.
2. **Motor**: bash + `claude -p` (contexto zerado por volta, como o loop
   original) ou `/loop` nativo do harness (mesma sessão, contexto acumula).
   Recomendação: bash + `claude -p`; o harness é orquestrado, não
   reimplementado.
3. **Quem commita**: agente ou motor. Recomendação: motor, depois do gate — é o
   que tira o veredito do alcance do agente.
4. **Volta vermelha**: descartar o diff (`git checkout -- .` na branch da
   demanda) ou guardar como patch para a próxima volta. Recomendação: guardar
   patch em `docs/audora/planos/loop/<id>/` e descartar no fim da rodada.
5. **Tetos default**: voltas por tarefa, voltas por rodada, custo em USD. Sem
   default sensato aqui — é preferência do humano e vira Constituição.
6. **Sandbox `nenhum`**: recusar, ou avisar e seguir com confirmação.
   Recomendação: confirmação explícita por rodada, impressa no bloco.
7. **Autopilot em LIGHT**: LIGHT já tem só o portão final; autopilot ali só
   muda a oferta de e2e. Incluir, ou deixar só MEDIUM.

## Fora do roadmap (não entra em nenhuma demanda)

- Remover o portão final da validate, ou rodar HIGH sem humano.
- O framework instalar docker, VM, Playwright, ou configurar permissões do
  harness.
- CI remoto, ou substituir a suíte do projeto-alvo.
- Loop sem plano-arquivo: o motor lê o plano, nunca inventa tarefa.

## Métricas de sucesso (medir, não sentir)

| Métrica | Hoje | Alvo |
|---|---|---|
| paradas humanas por demanda MEDIUM | 3-4 (+ lotes do scope) | 1 (+ lotes do scope) |
| veredito verde dado pelo próprio agente | sempre | nunca (gate fora do agente) |
| fraude de teste detectada antes do portão | não detecta | reprova no gate, nomeando |
| demanda MEDIUM rodando sem humano presente | 0 | plano inteiro, com teto |

Os contadores saem do bloco de fechamento da validate (D2) e das métricas de
rodada do motor (D3).

## Apêndice — prompts de permissão do harness (não é do framework)

- `permissions.allow` em `.claude/settings.json` do projeto (ou global):
  allowlist de comandos e ferramentas; a skill `/fewer-permission-prompts`
  monta a lista a partir do histórico.
- `claude --permission-mode acceptEdits`: edições sem prompt; Bash ainda
  pergunta.
- `claude --dangerously-skip-permissions` (ou
  `--permission-mode bypassPermissions`): só em sandbox ou worktree
  descartável, nunca com credencial de produção no ambiente. É o modo do loop.
