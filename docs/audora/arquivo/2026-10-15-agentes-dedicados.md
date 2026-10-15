---
id: agentes-dedicados
estado: delivered
origem: humano
depende-de: []
arquivos: [CHANGELOG.md, MEMORY.md, PRD.md, README.md, README.pt-BR.md, agents/revisor.md, docs/audora/aprendizados.md, docs/audora/decisoes-vivas.md, docs/audora/planos/arquivo/plano-agentes-dedicados.md, skills/debug/SKILL.md, skills/validate/references/revisao-adversarial.md, tests/test-agentes-dedicados.sh]
keywords: [agentes, subagent, revisor, read-only, revisao-adversarial, validate, debug, cacada, plataforma]
resumo: Um agente revisor sem escrita no plugin, despachado pela revisão adversarial da validate e pela caçada do debug.
atualizado-em: 2026-10-15
---

# agentes-dedicados

## objetivo

Entregar um único agente `revisor` no plugin, sem ferramenta de escrita, que
a revisão adversarial da validate e a refutação de achados do modo caçada do
debug despacham pelo nome, no lugar de um subagente genérico que herda todas
as ferramentas.

Origem: estudo `docs/study/2026-10-14-estudo-melhorias.md` §5 (local) — 33
subagentes "revisores" editaram código por herdar todas as ferramentas. Base
do nó `review-avulsa`. Categoria: MEDIUM (nenhum risco SIM; vários arquivos).

## criterios-aceite

- **agentes-dedicados/1** — QUANDO o plugin está instalado O SISTEMA DEVE
  listar um agente `revisor` entre os agentes do plugin, com descrição que
  diga que ele revisa e refuta sem alterar nada
- **agentes-dedicados/2** — QUANDO o revisor é despachado O SISTEMA DEVE
  dar a ele só leitura de arquivo, busca e shell — nunca editar, escrever
  arquivo nem despachar outro agente
- **agentes-dedicados/3** — QUANDO o revisor é despachado O SISTEMA DEVE
  carregar, na definição do próprio agente e sem depender do prompt de quem
  despacha, a trava do shell: proibido escrever no repo ou causar efeito
  fora dele, e script de efeito externo só roda com executáveis falsos no
  PATH
- **agentes-dedicados/4** — QUANDO o revisor é despachado O SISTEMA DEVE
  rodá-lo no mesmo modelo da sessão principal
- **agentes-dedicados/5** — QUANDO a validate roda a revisão adversarial de
  uma demanda HIGH O SISTEMA DEVE despachar o `revisor` pelo nome, mantendo
  as regras atuais da revisão (3 classes de bloqueante com prova, ressalva,
  1 passagem + reverificação)
- **agentes-dedicados/6** — QUANDO o modo caçada do debug termina a varredura
  com ≥1 achado O SISTEMA DEVE despachar o `revisor` uma única vez com a
  lista de achados para tentar refutar cada um, antes de escrever o
  relatório
- **agentes-dedicados/7** — QUANDO o revisor devolve a refutação de um achado
  da caçada O SISTEMA DEVE dar o veredito só depois de a sessão conferir a
  prova contra o artefato real, e registrar no relatório o que o revisor
  disse de cada achado
- **agentes-dedicados/8** — QUANDO o modo caçada termina com zero achados O
  SISTEMA DEVE não despachar o revisor
- **agentes-dedicados/9** — QUANDO o despacho do `revisor` pelo nome falha
  (agente ausente ou não carregado) O SISTEMA DEVE despachar subagente
  genérico com a mesma trava no prompt e escrever 1 linha avisando que o
  read-only não está garantido — no roteiro da validate ou no relatório da
  caçada
- **agentes-dedicados/10** — QUANDO nem o `revisor` nem o genérico podem ser
  despachados O SISTEMA DEVE manter o comportamento de hoje: a validate
  escreve "revisão adversarial não rodou — <motivo>" e segue para o portão;
  a caçada verifica pela própria sessão e escreve 1 linha no relatório
- **agentes-dedicados/11** — QUANDO a suíte do plugin roda O SISTEMA DEVE
  reprovar se o `revisor` ganhar ferramenta de escrita, de edição ou de
  despacho de agente, ou perder a trava do shell

## fora-de-escopo

Skill de review avulsa (nó `review-avulsa`); revisor despachado por scope,
plan, execute, e2e ou debug modo sintoma; modelo fixo; `explorador` (o
`Explore` nativo cobre), `refutador`, construtor, `context: fork`,
memory-guard em PreToolUse (vai para P05/P09 do estudo), implementadores
paralelos, worktrees, debate entre agentes, agent teams; mudar as regras da
revisão adversarial (classes, parada, ressalva).
Régua de corte: 5 demandas reais sem uso ou sem achado aceito → corta.

## decisoes

- 2026-10-15 (humano): escopo encolhe de 3 agentes + PreToolUse para 1
  revisor, conforme o veredito "refinar" do estudo de 2026-10-14.
- 2026-10-15 (humano): revisor tem shell com trava (proíbe escrita e efeito
  externo, exige executáveis falsos) — descartado "sem shell" (perde a prova
  por mutação) e "shell só leitura" (perde rodar teste).
- 2026-10-15 (humano): despacham a validate (HIGH) e a caçada, onde o
  revisor refuta os achados da sessão — descartados "só validate", "toda
  revisão" e "revisor caça" (autor e verificador no mesmo agente).
- 2026-10-15 (humano): revisor indisponível → genérico com a mesma trava e
  aviso — descartado "pula com ressalva" e "bloqueia o portão".
- 2026-10-15 (humano): modelo herdado da sessão — descartado fixo forte
  (custo) e fixo barato (perde achado sutil).
- 2026-10-15 (humano): portão aprovado; 2 decisões vivas promovidas.

## delta

## e2e

2026-10-15: pulado-pelo-humano — portão aprovado só com a suíte (gate passou, 0 falhas; `test-agentes-dedicados` 44 asserts); /1 sem listagem em sessão real, /5–/10 sem prova de comportamento do modelo.

## feedback-reprovacao
