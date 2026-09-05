# Fundamentos v2 dos 5 Princípios — audora-commander

Versão integrada: rascunho v1 + crítica adversarial (agente Fable) + acertos do
Superpowers (local) + pesquisa do gênero (Spec Kit, BMAD, Agent OS, Kiro,
Taskmaster, Anthropic, Aider, OpenSpec).

## Padrão-mãe

**Contexto é o gargalo, não inteligência.** Todo princípio abaixo é, no fundo,
uma forma de pôr a informação certa, na hora certa, no tamanho certo, na janela
de contexto — e de registrar fora dela o que precisa sobreviver.

A crítica nº 1 a TODOS os frameworks do gênero é a mesma: processo pesado demais
para demanda pequena ("mar de markdown"). O antídoto é o Princípio 4: cerimônia
escala com risco; portão de aprovação nunca escala para baixo (HARD-GATE).

---

## P1 — Mapa Dinâmico (GRAFO vivo)

**Fundamento:** LLM não tem memória entre sessões. Código guarda o "como"; o
"o quê / por quê / estado" evapora se não for escrito. GRAFO.md é a memória
externa durável do produto — o NOTES.md estruturado do projeto.

**Lei de Ferro:** `REQUISITO NÃO ESCRITO NO GRAFO É REQUISITO QUE NÃO EXISTE`

Regras:
1. **Schema canônico por nó**: `id`, `estado` (planejada | em-curso | bloqueada |
   entregue | descartada), `depende-de: [ids]`, `criterios-aceite`, `decisoes`,
   `atualizado-em`. Skill grafo valida schema antes de escrever; delta que quebra
   schema é rejeitado.
2. **Seções com modo de carga** (inspirado em Kiro steering): `sempre` (cabeçalho:
   propósito + constituição + índice de nós — enxuto, cabe em qualquer contexto),
   `auto` (nó carregado quando demanda o toca), `manual` (arquivo morto
   GRAFO-ARQUIVO.md). Nunca carregar GRAFO inteiro.
3. **Constituição** (inspirado em Spec Kit): seção curta e estável no topo do
   GRAFO com princípios inegociáveis do projeto (stack, restrições, padrões,
   `como-rodar`). Toda fase valida contra ela: cumpre ou documenta exceção.
4. **Atualização por delta + sync** (inspirado em OpenSpec): durante a demanda,
   mudanças de requisito são registradas como delta no nó (`ADICIONADO` /
   `MODIFICADO` / `REMOVIDO`). Na validação pós-merge, skill validar faz sync:
   delta consolida no nó, nó `entregue` compacta para 1 linha e vai para
   GRAFO-ARQUIVO.md, resumo é promovido ao PRD.md. Direção única GRAFO → PRD.
5. **Anti-alucinação com dois tipos de decisão** (resolve conflito com P5):
   - *Requisito de produto* (afeta comportamento observável ou critério de
     aceite) → perguntar ao humano ANTES; registrar resposta no nó.
   - *Decisão de implementação* (não afeta critérios) → decidir autônomo e
     listar em "Decisões tomadas pela IA" no roteiro de validação.
6. **Conflito GRAFO vs código**: detectado apenas no escopo da demanda (na fase
   plano, ao ler arquivos afetados). Divergência → sinalizar, humano decide.
7. **Brownfield**: GRAFO ausente → bootstrap gera GRAFO mínimo com nós marcados
   `inferido` (não valem como verdade para a Lei de Ferro). Nó `inferido` vira
   `validado` quando demanda o toca e humano confirma. Framework opera com GRAFO
   parcial desde o dia 1 — nunca exige mapeamento completo antes de trabalhar.
8. **Git**: edição do GRAFO em branch restrita aos nós da demanda daquela branch.
   Conflito de merge fora desses nós → parar e sinalizar, nunca auto-resolver.

---

## P2 — Planejamento Just-in-Time

**Fundamento:** plano antecipado apodrece — cada implementação muda o terreno.
LLM planeja melhor com estado real e fresco no contexto do que com especulação.
Contexto just-in-time (Anthropic): referência leve agora, conteúdo na hora.

**Lei de Ferro:** `PLANO SEM LEITURA DO CÓDIGO ATUAL É PLANO INVÁLIDO`

Regras:
1. **Duas passadas**: (1) localizar candidatos por busca (grep/glob) a partir do
   escopo; (2) ler os arquivos que o plano vai tocar. Plano lista explicitamente
   os arquivos lidos; etapa que toca arquivo não listado invalida o plano naquele
   ponto.
2. **Plano é ARQUIVO** (`plano-<id-demanda>.md`), estilo Superpowers: header
   (objetivo, arquitetura, link para o nó do GRAFO), tarefas com checkbox, passos
   de 2-5 minutos, caminhos exatos, proibição de placeholders ("TBD", "tratar
   erros adequadamente", "similar à tarefa N"). Relido no início de cada sessão
   de execução. Arquivado (não deletado) após validação; nunca reutilizado como
   spec.
3. **Tarefa autossuficiente** (inspirado em BMAD story file): cada tarefa embute
   requisito (TR do nó), decisões de arquitetura relevantes, critério de aceite
   e interfaces consumidas/produzidas. Sessão limpa (ou subagente) executa sem
   redescobrir contexto.
4. **Dependências explícitas + expansão sob demanda** (inspirado em Taskmaster):
   tarefas declaram `depende-de`; "qual a próxima?" é resposta mecânica, nunca
   tarefa bloqueada. Tarefa complexa é quebrada em subtarefas só quando chega a
   vez dela.
5. **Etapa calibrada**: no máximo ~3 arquivos, 1 teste-alvo, critério de done.
   Após qualquer compactação de contexto: reler plano + nó do GRAFO antes de
   continuar (reancoragem obrigatória).
6. **Gatilhos de replanejamento enumerados**: (a) símbolo/arquivo referenciado
   não existe ou mudou incompativelmente; (b) teste da etapa impossível como
   especificado; (c) descoberta altera escopo → não é replanejar, é voltar à
   fase escopo (P3). Teste falhando por bug da implementação é debug, não
   replanejamento.

---

## P3 — Separar "O Quê" do "Como"

**Fundamento:** janela de contexto é recurso escasso; discussão de escopo polui
o contexto da implementação e dilui a atenção do modelo. Cada documento em uma
altitude só (Spec Kit): escopo fala de comportamento, plano fala de arquivos.

**Lei de Ferro:** `NENHUM CÓDIGO ANTES DO ESCOPO FECHADO EM ARTEFATO ESCRITO`

Regras:
1. **Artefato de fronteira**: escopo fecha em artefato escrito (nó do GRAFO ou
   spec dedicada) antes de qualquer código. `/clear` é seguro porque nada
   importante vive só na conversa.
2. **Incerteza marcada, nunca preenchida** (inspirado em Spec Kit): lacuna de
   requisito recebe marcador `[PRECISA-CLARIFICAR]` no artefato. Escopo não
   fecha com marcador aberto. Proibido substituir marcador por suposição
   plausível.
3. **Critérios de aceite em formato testável** (inspirado em Kiro/EARS):
   "QUANDO [condição] O SISTEMA DEVE [comportamento observável]". Formato não
   aceita ambiguidade e vira teste direto — conecta o "O Quê" ao TDD da
   execução.
4. **Checklist de auto-revisão do escopo** (inspirado em Spec Kit): antes do
   portão, agente confere: sem `[PRECISA-CLARIFICAR]`? critérios testáveis?
   fora-de-escopo explícito? sem contradição com constituição/nós vizinhos?
5. **`/clear` é do humano; fim de fase é o gatilho**: ao fechar fase, skill
   instrui: "Fase fechada. Artefatos salvos: [lista]. Seguro dar /clear agora."
   Antes de `/clear` no meio de demanda: despejar notas de sessão no arquivo do
   plano (abordagens descartadas + porquê, estado parcial, próximos passos).
6. **Estrutura sempre, extensão proporcional**: P4 governa o tamanho, P3 a
   estrutura. Categoria LEVE fecha escopo em 3 linhas dentro do nó; ALTA exige
   spec dedicada. Os três campos (objetivo, critérios, fora-de-escopo) nunca são
   opcionais; o tamanho deles sim.
7. **Teste discriminante pergunta vs reabertura**: a resposta muda critérios de
   aceite ou fora-de-escopo? Sim → volta formal à fase escopo, registra delta no
   GRAFO. Não → esclarecimento; registra no nó e segue.

---

## P4 — Ferramenta na medida da demanda

**Fundamento:** processo tem custo (tokens, tempo, atenção humana). Rigor certo
é proporcional a risco e reversibilidade, não a tamanho do diff. A falha nº 1 do
gênero é ignorar isto — quem calibra, ganha.

**Lei de Ferro:** `NA DÚVIDA ENTRE DUAS CATEGORIAS, A MAIS PESADA`

Regras:
1. **Quatro categorias com roteamento explícito**:

   | Categoria | Fases | Portões humanos | Autopilot |
   |---|---|---|---|
   | LEVE | executar → validar | resultado | resultado (e2e sem oferta) |
   | MÉDIA | escopo → plano → executar → [e2e] → validar | escopo, resultado | resultado (+ lotes do escopo) |
   | ALTA | escopo → plano → executar → [e2e] → validar | escopo, plano, resultado | recusado |
   | HOTFIX | executar → validar (registro retroativo) | diff + evidência (único) | — |

   `[e2e]` = opcional, fortemente recomendado (ver P5.x).

2. **Classificação por perguntas binárias, em ordem**: toca migração/dado
   persistido? toca API pública/contrato? toca auth/segurança/pagamento? tem
   efeito irreversível fora do repo? — qualquer SIM → ALTA. Múltiplos arquivos
   ou lógica nova → MÉDIA. Resto → LEVE.
3. **HOTFIX é entrada declarada pelo humano** — nunca auto-selecionada pela IA.
   Pula escopo/plano; exige teste que reproduz o defeito antes do fix + portão
   único (diff + evidência). Registro retroativo no GRAFO obrigatório: nó
   `hotfix-pendente-registro` até a sessão seguinte regularizar.
4. **Reversível definido**: desfazível com `git revert` sem efeito residual fora
   do repo. Migração executada, e-mail enviado, cobrança feita, dado apagado,
   deploy público = irreversível, independentemente do tamanho do diff.
5. **Catraca com válvula**: subir categoria no meio é automático com aviso;
   descer só com aprovação explícita do humano.
6. **Red flags anti-racionalização** (tabela estilo Superpowers): "é só uma
   linha", "eu já entendi o suficiente", "processo aqui é exagero", "classifico
   como LEVE pra ir mais rápido".

---

## P5 — IA executa, humano decide

**Fundamento:** LLM otimiza plausibilidade, não verdade; o humano é dono do
produto e do risco. Erro corrigido em requisito custa ordens de grandeza menos
que em código — portões cedo pagam por si.

**Lei de Ferro:** `NENHUMA AFIRMAÇÃO DE SUCESSO SEM EVIDÊNCIA FRESCA DE EXECUÇÃO`

Regras:
1. **Portões por categoria** (tabela do P4). Entre portões, IA trabalha
   autônoma — pedir aprovação a cada linha é teatro de segurança que o próprio
   framework proíbe.
2. **Evidência mapeada 1:1 aos critérios**: cada critério de aceite → comando
   executado + saída correspondente. Critério sem verificação automatizável →
   item explícito no roteiro de validação humana. Critério sem nenhum dos dois →
   demanda não pode ser declarada pronta.
3. **Roteiro de validação guiada**: comportamento sempre (comandos, telas,
   rotas, casos de erro); em categoria ALTA, somar sumário de mudanças por
   arquivo + trechos sensíveis destacados. Comportamento E código, não ou.
4. **Revisão adversarial por subagente** (inspirado em Superpowers/Anthropic):
   em categoria ALTA, antes do portão final, subagente de contexto limpo ataca o
   diff contra os critérios de aceite e devolve resumo condensado. Revisor sem
   viés de autor pega o que o autor não vê.
5. **Fluxo de reprovação definido**: nó permanece `em-curso` +
   `feedback-reprovacao`; motivo de escopo → fase escopo; motivo de execução →
   fase plano da etapa afetada. Aprovação parcial: o aceito vira `entregue`, o
   resto vira etapas novas.
6. **Efeito irreversível fora do repo = portão humano SEMPRE**, em qualquer
   categoria. IA prepara comando + rollback; humano executa ou autoriza aquele
   comando específico.
7. **Decisões do humano registradas no GRAFO** — decisão vira memória durável.
8. **Portão antecipado por declaração** (autopilot): o humano pode declarar
   ("autopilot" / "roda até o validate") em demanda LEVE/MÉDIA — os portões
   do meio ficam aprovados na entrada e as decisões tomadas sem portão são
   ratificadas no final; o portão final NUNCA é antecipado; ALTA recusa
   (catraca do P4). Elegibilidade: todo critério com verificação
   automatizável, senão o fluxo normal segue com o critério culpado nomeado.

---

## P5.x — Validação E2E da demanda (skill `e2e`, opcional e fortemente recomendada)

**Fundamento:** teste de unidade verde prova a peça; não prova o produto. Exercitar
a demanda de ponta a ponta, com o projeto rodando de verdade, é a evidência mais
próxima do que o humano vai validar no portão final.

**Lei de Ferro:** `EVIDÊNCIA E2E VEM DO PRODUTO RODANDO, NUNCA DE SAÍDA DE TESTE DE UNIDADE`

Regras:
1. **Posição no fluxo**: após executar (testes verdes), antes do portão final de
   validar. Skill validar SEMPRE oferece o e2e com recomendação forte; humano pode
   pular — recusa é registrada no nó (`e2e: pulado-pelo-humano`).
2. **Como rodar o projeto**: descoberto na seção `como-rodar` da constituição do
   GRAFO; ausente → perguntar ao humano uma vez e registrar lá (memória durável).
3. **Cenário derivado dos critérios EARS**: cada "QUANDO X O SISTEMA DEVE Y" vira
   passo executável — browser para web, chamada HTTP para API, invocação para CLI.
4. **Evidência 1:1**: cada critério → passo executado + evidência (screenshot,
   resposta, saída) no relatório `e2e-<id-demanda>.md`, anexado ao roteiro de
   validação.
5. **Cenário vira regressão quando possível**: projeto com infra de e2e → cenário
   é persistido como teste permanente; sem infra → oferecer bootstrap mínimo ou
   arquivar script junto ao plano.
6. **Teardown sempre**: processo levantado é derrubado ao fim, sucesso ou falha.

## Transversais

- **Git**: 1 demanda = 1 branch. Commit ao fim de cada etapa com teste verde
  (checkpoint de rollback barato). Skill validar roda no merge: estado do nó,
  sync de delta, promoção ao PRD, arquivamento do plano.
- **Falha irrecuperável de etapa**: parar; nó → `bloqueada` + diagnóstico
  registrado; humano escolhe: reverter branch, replanejar do último checkpoint,
  ou abandonar (nó → `descartada` com motivo).
- **Subagentes**: recebem no prompt o nó do GRAFO + etapa do plano + critério de
  done. Não editam GRAFO — devolvem delta proposto; orquestrador aplica.
- **Demandas concorrentes**: máximo 3 nós `em-curso`. Demanda nova com outras
  abertas → porta de entrada lista e pergunta: pausar, continuar ou abandonar.
- **Anunciar skill em uso** (Superpowers): "Usando [skill] para [propósito]" —
  visibilidade do processo para o humano.
- **TDD (regra global do usuário)**: red com motivo certo → green visto na saída
  real → refactor. Ênfase em integrações e casos de erro, não caminho feliz.
  Cobertura significativa, não numérica.

## Mapa acerto → skill

| Acerto (fonte) | Skill destino |
|---|---|
| Processo proporcional (BMAD; crítica ao gênero) | audora-commander |
| Classificação binária + tabela de roteamento (crítica adversarial) | audora-commander |
| Delta + sync pós-merge (OpenSpec) | grafo + validar |
| Modos de carga sempre/auto/manual (Kiro steering) | grafo |
| Constituição enxuta (Spec Kit) | grafo |
| Bootstrap brownfield com nós `inferido` (crítica adversarial) | grafo |
| `[PRECISA-CLARIFICAR]` (Spec Kit) | escopo |
| Critérios EARS testáveis (Kiro) | escopo → executar |
| Checklist de auto-revisão de spec (Spec Kit) | escopo |
| Tarefa autossuficiente (BMAD story file) | plano |
| Dependências explícitas + expansão sob demanda (Taskmaster) | plano |
| Plano-arquivo com passos 2-5 min sem placeholder (Superpowers) | plano |
| Red-green com evidência real (Superpowers + regra do usuário) | executar |
| E2E da demanda com produto rodando (pedido do usuário) | e2e |
| Debug em fases com causa raiz antes de fix (Superpowers systematic-debugging) | depurar |
| Gate de evidência 1:1 com critérios (crítica adversarial) | validar |
| Revisão adversarial por subagente (Superpowers/Anthropic) | validar |
| Leis de Ferro + tabelas de racionalização (Superpowers) | todas |
