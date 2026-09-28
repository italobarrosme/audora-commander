---
id: otimizacao-tokens
estado: in-progress
origem: humano
depende-de: [limpeza-codigo-morto]
arquivos: []
keywords: [tokens, custo, contexto, plano, loop]
resumo: Corta custo de token do framework: plano sem código duplicado, prompt de volta enxuto no loop, limpeza de contexto.
atualizado-em: 2026-09-27
---

# otimizacao-tokens

## objetivo

Reduzir o custo em tokens que o framework impõe a cada demanda, sem tirar
nenhum portão nem evidência.

## criterios-aceite

- **otimizacao-tokens/1** — QUANDO uma fase precisar da skill memory, do
  `MEMORY.md` ou do template do bloco de fechamento e eles já tiverem sido
  carregados nesta sessão (sem `/clear` nem compactação depois) O SISTEMA
  DEVE reusar o que está no contexto, sem reinvocar a skill nem reler o
  arquivo; após `/clear` ou compactação, recarrega normalmente.
- **otimizacao-tokens/2** — QUANDO a skill validate for carregada O SISTEMA
  DEVE trazer inline só o fluxo até o portão; sync pós-merge, filtro de
  decisões vivas e Fechamento LIGHT vivem em `skills/validate/references/`,
  lidos UMA por uso, e a prosa histórica sai.
- **otimizacao-tokens/3** — QUANDO uma reference da validate estiver ausente
  O SISTEMA DEVE avisar nomeando o arquivo, manter o portão humano e NÃO
  executar o sync de memória — pede reinstalação do plugin.
- **otimizacao-tokens/4** — QUANDO uma fase fechar e a próxima se reancorar
  só pelos artefatos O SISTEMA DEVE recomendar `/clear` no bloco de
  fechamento, deixando a decisão com o humano (em autopilot, sem pausa, a
  recomendação não aparece).
- **otimizacao-tokens/5** — QUANDO a fase plan escrever uma tarefa O SISTEMA
  DEVE trazer o código completo do teste, assinaturas exatas e comandos, e
  código de implementação SÓ quando não-óbvio (algoritmo, regex, SQL,
  formato exato); placeholder segue proibido.
- **otimizacao-tokens/6** — QUANDO o motor de loop montar o prompt de uma
  volta O SISTEMA DEVE incluir o cabeçalho do plano (até a primeira
  `## Tarefa`), a seção da tarefa escolhida e `## Notas de sessão` (onde
  estiver), e NÃO o texto das outras tarefas; plano sem notas monta o prompt
  sem erro.
- **otimizacao-tokens/7** — QUANDO a suíte rodar O SISTEMA DEVE reprovar se a
  carga base do caminho MEDIUM (SKILL.md das fases + references e templates
  que o caminho lê uma vez) passar do teto em bytes registrado; o nó
  registra antes → depois medido pela mesma conta.
- **otimizacao-tokens/8** — QUANDO as mudanças entrarem O SISTEMA DEVE
  manter todo invariante de portão e evidência (portão final nunca
  antecipado, evidência 1:1, Fechamento LIGHT preserva o portão) asserido na
  suíte, agora no arquivo onde mora — movimento, nunca perda.

## fora-de-escopo

Teto e modelo na revisão adversarial; podar o que carrega em toda sessão
(descriptions, hook, Aprendizados); fatiar outras skills (worktree só carrega
sob pedido); forçar `/clear` ou subagente por fase; medição com `claude -p`
real (custo de API).

## decisoes

- 2026-09-26 (humano, lote de entrada): entram "Loop: prompt enxuto", "Plano
  sem código duplicado" e "Limpeza de contexto" (descartado: teto na revisão
  adversarial).
- 2026-09-26 (humano): "limpeza de contexto" = pergunta "qual o padrão dos
  projetos desse tipo?" — IA respondeu: carga progressiva + estado no disco +
  contexto novo por fase/tarefa, recomendando as três; confirmar no scope.
- 2026-09-27 (humano, lote do escopo): contexto = não reler + fatiar
  validate + `/clear` recomendado entre fases (as três); plano = teste +
  assinaturas (descartado: só assinaturas — volta do loop perde
  autossuficiência); loop = cabeçalho + tarefa + notas (descartado: sem
  notas — volta repete erro de vermelho anterior); medição = bytes + teto na
  suíte (descartados: `claude -p` real — custo e ruído; sem teto — volta a
  inchar).
- 2026-09-27 (IA): bump 0.9.0 nesta demanda (comportamento das fases muda;
  cache do plugin só refaz com bump) — a confirmar no portão de escopo.
- 2026-09-27 (IA): economia do /1 é comportamental (o modelo deixa de
  reler) — medida por bytes só como estimativa; o /7 mede a carga estática.
- 2026-09-27 (humano): portão de escopo aprovado ("continue"), incluindo bump
  0.9.0.

## medicao

Bytes (`tests/test-carga.sh`; tokens ~ bytes/3,3). Carga estática MEDIUM:
BASE 56237 → 53609 (−4,7%); FULL 58036 → 58818 (+1,3% — regras novas e
cabeçalhos das references); `validate` base 11603 → 7596 (−35%; LIGHT deixa
de carregar sync e filtro). Loop (/6), plano real `plano-limpeza-codigo-morto`:
recorte do plano no prompt 13695 → 6632 por volta (−52%). Estimado: /1 evita reler memory (8,3KB)
e bloco (4,1KB) por fase, ~35KB (~10k tok) por MEDIUM; /5 paga a saída 1x.

## delta

## e2e

relatorio: ../e2e/e2e-otimizacao-tokens.md (2026-09-28; 1 corrida `claude -p` 0.9.0, LIGHT ponta a ponta; /1 passou; /4 parcial — só ramo autopilot ao vivo)

## feedback-reprovacao
