# Escopo — loop-motor (HIGH)

> Data: 2026-09-05. Nó: `docs/audora/memory/loop-motor.md`. Fase scope.
> D3 do roadmap `docs/specs/2026-09-02-loop-engineering-roadmap.md`.
> Recomendações 2, 3, 4 e 6 do roadmap adotadas como decisão de entrada
> (registradas no nó); tetos default (decisão 5) são PROPOSTA ratificável
> neste portão. Invariantes: HIGH nunca roda no motor; efeito irreversível
> fora do repo = mão do humano; o motor lê o plano, nunca inventa tarefa.

## Objetivo

`hooks/loop` roda o plano-arquivo de uma demanda em autopilot volta a volta.
Cada volta: `claude -p` NOVO (contexto zerado) com prompt fixo gerado de
`templates/loop-prompt-template.md` — nó + plano + UMA tarefa + regras (uma
tarefa por volta, procurar antes de criar, placeholder proibido, não commita,
não marca checkbox, não toca outra tarefa). O MOTOR roda o gate depois da
volta, commita no verde citando `<id>/<n>`, marca o checkbox; no vermelho
guarda o diff como patch e grava o diagnóstico nas Notas de sessão. Para com
condição explícita e registra métricas por rodada.

## Critérios de aceite (EARS, numerados)

### Lote A — pré-condições da rodada

- **loop-motor/1** — QUANDO o motor for invocado sem nó `autopilot: elegivel`,
  sem `gate:` na Constituição, sem branch própria da demanda (fora de
  `main`/`master`) ou sem teto resolvível O SISTEMA DEVE recusar a rodada
  listando TUDO que falta, sem executar volta alguma.
- **loop-motor/2** — QUANDO a Constituição não tiver bullet `sandbox:`
  (`docker | vm | nenhum`) O SISTEMA DEVE recusar a rodada dizendo o que
  falta.
- **loop-motor/3** — QUANDO `sandbox: nenhum` O SISTEMA DEVE exigir
  confirmação explícita por rodada (flag `--confirmo-sem-sandbox`) e imprimir
  o aviso no início e no bloco final; sem a flag → recusar.
- **loop-motor/4** — QUANDO os tetos não vierem por parâmetro O SISTEMA DEVE
  ler o bullet `loop:` da Constituição; sem parâmetro E sem bullet → recusa
  do /1.

### Lote B — a volta

- **loop-motor/5** — QUANDO uma volta iniciar O SISTEMA DEVE gerar o prompt
  de `templates/loop-prompt-template.md` (nó + plano + a PRIMEIRA tarefa
  aberta com `depende-de` satisfeitas + regras) e rodar um `claude -p` NOVO
  com `--max-budget-usd` — contexto zerado, sem sessão reaproveitada.
- **loop-motor/6** — QUANDO uma volta terminar O SISTEMA DEVE rodar o gate
  FORA do processo do agente e só então decidir verde/vermelho.
- **loop-motor/7** — QUANDO o gate der verde O SISTEMA DEVE commitar citando
  `<id>/<n>` da tarefa e marcar o checkbox no plano — o agente da volta nunca
  commita nem marca.
- **loop-motor/8** — QUANDO o gate der vermelho O SISTEMA DEVE não commitar,
  guardar o diff como patch em `docs/audora/planos/loop/<id>/` (nomeado por
  rodada/volta), descartar a árvore e gravar a saída do gate nas Notas de
  sessão do plano.

### Lote C — condições de parada e métricas

- **loop-motor/9** — QUANDO o plano não tiver tarefa aberta O SISTEMA DEVE
  imprimir `DONE` e encerrar apontando a preparação de evidência da validate.
- **loop-motor/10** — QUANDO a mesma tarefa ficar vermelha N vezes seguidas
  (teto voltas-por-tarefa) O SISTEMA DEVE parar, virar o nó para `blocked`
  (arquivo + linha do índice) e imprimir o bloco com o motivo.
- **loop-motor/11** — QUANDO o teto de voltas da rodada ou de custo for
  atingido O SISTEMA DEVE parar deixando o plano retomável, sem trabalho pela
  metade commitado.
- **loop-motor/12** — QUANDO houver `[PRECISA-CLARIFICAR]` no nó ou no plano
  (antes ou durante a rodada) O SISTEMA DEVE parar com o bloco "aguardando
  humano" citando o marcador.
- **loop-motor/13** — QUANDO a rodada terminar (qualquer causa) O SISTEMA
  DEVE registrar as métricas no plano: voltas, verdes/vermelhos, custo
  acumulado, tempo, causa da parada.

### Lote D — suíte e retomada

- **loop-motor/14** — QUANDO a suíte rodar O SISTEMA DEVE exercitar o motor
  com `claude` FALSO no PATH (fixture) e repo git real, SEM chamar o modelo:
  caminho feliz, tarefa nunca-verde → `blocked`, teto estourado, plano sem
  tarefa aberta, sem git, gate ausente, sandbox `nenhum` sem confirmação, e
  segunda execução retomando do plano.
- **loop-motor/15** — QUANDO o motor for reinvocado após parada por teto O
  SISTEMA DEVE retomar da primeira tarefa aberta sem refazer tarefa marcada.

## Tetos default — PROPOSTA (ratificar neste portão)

Bullet novo na Constituição deste repo, lido pelo /4:
`loop: voltas-tarefa=3 voltas-rodada=12 custo-usd=10`.
Parâmetros da invocação sobrepõem qualquer um dos três.

## Fora de escopo

Paralelismo (D4); instalar docker/VM; escolher modelo por tarefa (parâmetro
simples `--model`); rodar demanda HIGH; modificar gate ou autopilot;
substituir a suíte do projeto-alvo; CI remoto.
