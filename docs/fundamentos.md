# Fundamentos dos 5 Princípios — audora-commander

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

## P1 — Memória Dinâmica (MEMORY vivo)

**Fundamento:** LLM não tem memória entre sessões. Código guarda o "como"; o
"o quê / por quê / estado" evapora se não for escrito. O MEMORY é a memória
externa durável do produto — o NOTES.md estruturado do projeto.

**Lei de Ferro:** `REQUISITO NÃO ESCRITO NO MEMORY É REQUISITO QUE NÃO EXISTE`

Regras:
1. **Índice mestre + 1 nó = 1 arquivo**: `MEMORY.md` (linha 1
   `memory-schema: 1`) guarda Propósito, Constituição, um ponteiro para os
   Aprendizados e uma linha rica por nó; o corpo de cada nó vive em `docs/audora/memory/<id>.md`
   com frontmatter grep-ável (`id`, `estado` — `planned | in-progress |
   blocked | delivered | discarded`, + `hotfix-pending-record` —, `origem`,
   `depende-de`, `arquivos`, `keywords`, `resumo`, `atualizado-em`). A skill
   memory valida o schema antes de escrever; os hooks `memory-guard` e
   `memory-validate` rejeitam escrita que o quebra.
2. **Carga seletiva** (inspirado em Kiro steering): o `MEMORY.md` entra
   por seção em toda fase — Propósito e Constituição inteiras, Aprendizados
   por busca (fase e termos do nó, sem invalidados), Índice inteiro só na
   porta, no scope e no plan e só a linha do nó nas outras; corpo de nó e
   decisões vivas (`[carga: auto]`) entram só quando a demanda toca a área,
   escolhidos pela linha do índice ou por grep; nós em `docs/audora/arquivo/`
   só se o humano pedir histórico.
   Nunca carregar a pasta de nós inteira; consulta estrutural é grep.
3. **Constituição** (inspirado em Spec Kit): seção curta e estável no topo do
   `MEMORY.md` com princípios inegociáveis do projeto (stack, restrições,
   padrões, `como-rodar`, gate). Toda fase valida contra
   ela: cumpre ou documenta exceção.
4. **Aprendizados na hora**: armadilha, preferência do humano ou padrão que
   vale para toda demanda futura vira 1 linha `data | fase | aprendizado` em
   `docs/audora/aprendizados.md` (consultado por grep, fora do `MEMORY.md`),
   registrada pela fase que descobriu — nunca guardada para o fim.
5. **Atualização por delta + sync** (inspirado em OpenSpec): durante a demanda,
   mudanças de requisito são registradas como delta no nó (`ADICIONADO` /
   `MODIFICADO` / `REMOVIDO`). No sync pós-merge, a skill validate consolida o
   delta no corpo, promove decisões duráveis a `docs/audora/decisoes-vivas.md`,
   marca o nó `delivered`, arquiva por `git mv` em `docs/audora/arquivo/`,
   atualiza a foto do PRD.md e acrescenta 1 linha ao CHANGELOG.md. O PRD.md
   é foto do estado atual (o que é, stack, arquitetura, metas futuras), com
   teto de 200 linhas cobrado pelo hook `memory-guard`; o histórico de
   entregas mora no CHANGELOG.md. Direção única MEMORY → PRD.
6. **Anti-alucinação com dois tipos de decisão** (resolve conflito com P5):
   - *Requisito de produto* (afeta comportamento observável ou critério de
     aceite) → perguntar ao humano ANTES; registrar resposta no nó.
   - *Decisão de implementação* (não afeta critérios) → decidir autônomo e
     listar em "Decisões tomadas pela IA" no roteiro de validação.
7. **Conflito MEMORY vs código**: detectado apenas no escopo da demanda (na
   fase plan, ao ler arquivos afetados). Divergência → sinalizar, humano decide.
8. **Brownfield**: MEMORY ausente → bootstrap gera MEMORY mínimo com nós
   `origem: inferido` (não valem como verdade para a Lei de Ferro). Nó
   inferido vira `origem: humano` quando a demanda o toca e o humano confirma.
   Framework opera com MEMORY parcial desde o dia 1 — nunca exige mapeamento
   completo antes de trabalhar.
9. **Git**: edição do MEMORY em branch restrita aos nós da demanda daquela
   branch. Conflito de merge fora desses nós → parar e sinalizar, nunca
   auto-resolver.

---

## P2 — Planejamento Just-in-Time

**Fundamento:** plano antecipado apodrece — cada implementação muda o terreno.
LLM planeja melhor com estado real e fresco no contexto do que com especulação.
Contexto just-in-time (Anthropic): referência leve agora, conteúdo na hora.

**Lei de Ferro:** `PLANO SEM LEITURA DO CÓDIGO ATUAL É PLANO INVÁLIDO`

Regras:
1. **Duas passadas**: (1) localizar candidatos a partir do escopo; (2) ler por trecho o que o
   plano vai tocar, listando cada leitura como `caminho:início-fim`. Plano lista explicitamente os arquivos lidos; etapa que
   toca arquivo não listado invalida o plano naquele ponto.
2. **Plano é ARQUIVO** (`docs/audora/planos/plano-<id>.md`), estilo
   Superpowers: header (objetivo, arquitetura, nó do MEMORY, arquivos lidos),
   tarefas com checkbox, passos de 2-5 minutos, caminhos exatos, proibição de
   placeholders ("TBD", "tratar erros adequadamente", "similar à tarefa N").
   Relido no início de cada sessão de execução. Arquivado (não deletado) em
   `docs/audora/planos/arquivo/` após validação; nunca reutilizado como spec.
3. **Tarefa autossuficiente** (inspirado em BMAD story file): cada tarefa embute
   requisito (critérios `<id>/<n>` do nó, verbatim), decisões relevantes,
   critério de done e interfaces consumidas/produzidas. Sessão limpa (ou
   subagente) executa sem redescobrir contexto. A tarefa é mapa (critério →
   caso de teste → `caminho:linha`, com a asserção exata quando o critério
   deixa o valor aberto); o código nasce na execute.
4. **Dependências explícitas + expansão sob demanda** (inspirado em Taskmaster):
   tarefas declaram `depende-de`; "qual a próxima?" é resposta mecânica, nunca
   tarefa bloqueada. Tarefa complexa (`expandir: sim`) é quebrada em
   subtarefas só quando chega a vez dela.
5. **Etapa calibrada**: passos de 2-5 minutos, 1 teste mínimo, critério de done.
   Após qualquer compactação de contexto: reler plano + nó do MEMORY antes de
   continuar (reancoragem obrigatória).
6. **Gatilhos de replanejamento enumerados**: (a) símbolo/arquivo referenciado
   não existe ou mudou incompativelmente; (b) teste da etapa impossível como
   especificado; (c) descoberta altera escopo → não é replanejar, é voltar à
   fase scope (P3). Teste falhando por bug da implementação é debug, não
   replanejamento.

---

## P3 — Separar "O Quê" do "Como"

**Fundamento:** janela de contexto é recurso escasso; discussão de escopo polui
o contexto da implementação e dilui a atenção do modelo. Cada documento em uma
altitude só (Spec Kit): escopo fala de comportamento, plano fala de arquivos.

**Lei de Ferro:** `NENHUM CÓDIGO ANTES DO ESCOPO FECHADO EM ARTEFATO ESCRITO`

Regras:
1. **Artefato de fronteira**: escopo fecha em artefato escrito (critérios no
   nó do MEMORY; em HIGH, spec de contexto opcional em `docs/audora/specs/`,
   nunca com critério) antes de qualquer código. `/clear` é
   seguro porque nada importante vive só na conversa.
2. **Incerteza marcada, nunca preenchida** (inspirado em Spec Kit): lacuna de
   requisito recebe marcador `[PRECISA-CLARIFICAR]` no artefato. Escopo não
   fecha com marcador aberto. Proibido substituir marcador por suposição
   plausível.
3. **Critérios de aceite em formato testável** (inspirado em Kiro/EARS):
   "QUANDO [condição] O SISTEMA DEVE [comportamento observável]", numerados
   com endereço estável `<id>/<n>` citado em teste, commit, e2e e roteiro.
   Formato não aceita ambiguidade e vira teste direto — conecta o "O Quê" ao
   TDD da execução.
4. **Checklist de auto-revisão do escopo** (inspirado em Spec Kit): antes do
   portão, agente confere: sem `[PRECISA-CLARIFICAR]`? critérios testáveis?
   fora-de-escopo explícito? sem contradição com constituição/nós vizinhos?
5. **Perguntas em lote**: perguntas independentes vão juntas (até 4 por lote);
   pergunta cuja resposta muda outra vai em série.
6. **Fim de fase é PARADA; `/clear` é do humano**: ao fechar scope, plan ou
   execute de MEDIUM/HIGH, a skill PARA e não emenda a fase seguinte — imprime
   "PARADA: rode /clear e, na sessão nova: `<fase> de <id>`". "Agente" sem
   /clear roda a fase seguinte em subagente de contexto zerado.
   Antes de `/clear` no meio de demanda: despejar notas de sessão no arquivo do
   plano (abordagens descartadas + porquê, estado parcial, próximos passos).
7. **Estrutura sempre, extensão proporcional**: P4 governa o tamanho, P3 a
   estrutura. Categoria LIGHT entra com critérios curtos direto no nó; HIGH
   também grava os critérios no nó e pode ter spec só de contexto. Os três campos (objetivo, critérios, fora-de-escopo)
   nunca são opcionais; o tamanho deles sim.
8. **Teste discriminante pergunta vs reabertura**: a resposta muda critérios de
   aceite ou fora-de-escopo? Sim → volta formal à fase scope, registra delta no
   nó. Não → esclarecimento; registra no nó e segue.

---

## P4 — Ferramenta na medida da demanda

**Fundamento:** processo tem custo (tokens, tempo, atenção humana). Rigor certo
é proporcional a risco e reversibilidade, não a tamanho do diff. A falha nº 1 do
gênero é ignorar isto — quem calibra, ganha.

**Lei de Ferro:** `NA DÚVIDA ENTRE DUAS CATEGORIAS, A MAIS PESADA`

Regras:
1. **Quatro categorias com roteamento explícito**:

   | Categoria | Fases | Portões humanos |
   |---|---|---|
   | LIGHT | execute → validate | resultado |
   | MEDIUM | scope → plan → execute → [e2e] → validate | escopo, resultado |
   | HIGH | scope → plan → execute → [e2e] → validate | escopo, plano, resultado |
   | HOTFIX | execute → validate (registro retroativo) | diff + evidência (único) |

   `[e2e]` = opcional, fortemente recomendado (ver P5.x).

2. **Classificação por perguntas binárias, em ordem**: toca migração/dado
   persistido? toca API pública/contrato? toca auth/segurança/pagamento? tem
   efeito irreversível fora do repo? — qualquer SIM → HIGH. Múltiplos arquivos
   ou lógica nova → MEDIUM. Resto → LIGHT.
3. **HOTFIX é entrada declarada pelo humano** — nunca auto-selecionada pela IA.
   Pula scope/plan; exige teste que reproduz o defeito antes do fix + portão
   único (diff + evidência). Registro retroativo no MEMORY obrigatório: nó
   `hotfix-pending-record` até a sessão seguinte regularizar.
4. **Reversível definido**: desfazível com `git revert` sem efeito residual fora
   do repo. Migração executada, e-mail enviado, cobrança feita, dado apagado,
   deploy público = irreversível, independentemente do tamanho do diff.
5. **Catraca com válvula**: subir categoria no meio é automático com aviso;
   descer só com aprovação explícita do humano.
6. **Red flags anti-racionalização** (tabela estilo Superpowers): "é só uma
   linha", "eu já entendi o suficiente", "processo aqui é exagero", "classifico
   como LIGHT pra ir mais rápido".

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
3. **Gate mecânico**: um comando por projeto (`gate:` na Constituição) responde
   passou/não passou — suíte, lint, typecheck e anti-fraude de teste (teste
   apagado, skip/only adicionado, queda de asserts sem justificativa).
4. **Roteiro de validação guiada**: comportamento sempre (comandos, telas,
   rotas, casos de erro) e diff dos arquivos de teste separado; em categoria
   HIGH, somar sumário de mudanças por arquivo + trechos sensíveis destacados.
   Comportamento E código, não ou.
5. **Revisão adversarial por subagente** (inspirado em Superpowers/Anthropic):
   em categoria HIGH, antes do portão final, subagente de contexto limpo ataca o
   diff contra os critérios de aceite e devolve resumo condensado. Revisor sem
   viés de autor pega o que o autor não vê. Critério de parada: bloqueia só
   achado provado de 3 classes (alheio, critério, formato real); o resto vira
   ressalva de 1 linha no roteiro. Uma passagem completa e, havendo
   bloqueante corrigido, uma reverificação restrita a ele — nunca uma 3ª
   passagem. Caçar borda teórica a cada rodada não converge.
6. **Fluxo de reprovação definido**: nó permanece `in-progress` +
   `feedback-reprovacao`; motivo de escopo → fase scope; motivo de execução →
   fase plan da etapa afetada. Aprovação parcial: o aceito segue o sync, o
   resto vira etapas novas.
7. **Efeito irreversível fora do repo = portão humano SEMPRE**, em qualquer
   categoria. IA prepara comando + rollback; humano executa ou autoriza aquele
   comando específico.
8. **Decisões do humano registradas no MEMORY** — decisão vira memória durável.

---

## P5.x — Validação E2E da demanda (skill `e2e`, opcional e fortemente recomendada)

**Fundamento:** teste de unidade verde prova a peça; não prova o produto. Exercitar
a demanda de ponta a ponta, com o projeto rodando de verdade, é a evidência mais
próxima do que o humano vai conferir no portão final.

**Lei de Ferro:** `EVIDÊNCIA E2E VEM DO PRODUTO RODANDO, NUNCA DE SAÍDA DE TESTE DE UNIDADE`

Regras:
1. **Posição no fluxo**: após execute (testes verdes), antes do portão final da
   validate. A skill validate SEMPRE oferece o e2e com recomendação forte
   (LIGHT: só quando toca caminho do usuário); humano pode pular — recusa é
   registrada no nó (`e2e: pulado-pelo-humano`).
2. **Infra e ferramenta**: docker compose é a infra default
   (`docker-compose.e2e.yml`); Playwright é o default para web; projeto
   não-web → o humano escolhe a ferramenta, registrada na Constituição. Sem
   Docker → `como-rodar` da Constituição; ausente → perguntar uma vez e
   registrar lá (memória durável).
3. **Cenário derivado dos critérios EARS**: cada "QUANDO X O SISTEMA DEVE Y" vira
   passo executável — browser para web, chamada HTTP para API, invocação para CLI.
4. **Evidência 1:1**: cada critério → passo executado + evidência (screenshot,
   resposta, saída) no relatório `docs/audora/e2e/e2e-<id>.md`, anexado ao
   roteiro de validação.
5. **Cenário vira regressão**: compose e specs de e2e são versionados no
   projeto; demanda futura estende em vez de recriar.
6. **Teardown sempre**: processo levantado é derrubado ao fim, sucesso ou falha.

## Transversais

- **Git**: 1 demanda = 1 branch. Commit ao fim de cada etapa com teste verde
  (checkpoint de rollback barato). A skill validate roda no merge: estado do
  nó, sync de delta, foto do PRD + linha do CHANGELOG, arquivamento do nó e
  do plano.
- **Falha irrecuperável de etapa**: parar; nó → `blocked` + diagnóstico
  registrado; humano escolhe: reverter branch, replanejar do último checkpoint,
  ou abandonar (nó → `discarded` com motivo).
- **Subagentes**: recebem no prompt o nó do MEMORY + etapa do plano + critério
  de done. Editam só os arquivos dos nós da própria demanda; conflito fora
  deles sobe para o humano.
- **Demandas concorrentes**: máximo 3 nós `in-progress`. Demanda nova com
  outras abertas → porta de entrada lista e pergunta: pausar, continuar ou
  abandonar.
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
| Delta + sync pós-merge (OpenSpec) | memory + validate |
| Carga seletiva sempre/auto (Kiro steering) | memory |
| Constituição enxuta (Spec Kit) | memory |
| Bootstrap brownfield com nós `inferido` (crítica adversarial) | memory |
| `[PRECISA-CLARIFICAR]` (Spec Kit) | scope |
| Critérios EARS testáveis (Kiro) | scope → execute |
| Checklist de auto-revisão de spec (Spec Kit) | scope |
| Tarefa autossuficiente (BMAD story file) | plan |
| Dependências explícitas + expansão sob demanda (Taskmaster) | plan |
| Plano-arquivo com passos 2-5 min sem placeholder (Superpowers) | plan |
| Red-green com evidência real (Superpowers + regra do usuário) | execute |
| E2E da demanda com produto rodando (pedido do usuário) | e2e |
| Debug em fases com causa raiz antes de fix (Superpowers systematic-debugging) | debug |
| Gate de evidência 1:1 com critérios (crítica adversarial) | validate |
| Revisão adversarial por subagente (Superpowers/Anthropic) | validate |
| Leis de Ferro + tabelas de racionalização (Superpowers) | todas |
