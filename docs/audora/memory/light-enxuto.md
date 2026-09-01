---
id: light-enxuto
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [light, cerimonia, validate, roteamento, fechamento]
resumo: Demanda LIGHT deixa de pagar o fechamento desenhado para MEDIUM — o sync de 8 operações tem passo vácuo e passos quase sempre vazios.
atualizado-em: 2026-09-01
---

# light-enxuto

## objetivo

Uma demanda LIGHT (ajuste localizado em comportamento existente) percorre
`execute → validate`, mas paga no fechamento o sync de 8 operações desenhado
para MEDIUM/HIGH: uma delas é **vácuo** (arquivar o plano — LIGHT não tem
plano), duas quase sempre vêm vazias (consolidar delta, promover decisões
vivas) e uma é discutível (promover ao PRD um ajuste que não move o estado do
produto). O fechamento deve ser proporcional ao risco, como o resto do
framework.

## criterios-aceite

- **light-enxuto/1** — QUANDO uma demanda LIGHT chegar ao sync O SISTEMA DEVE
  executar apenas os passos com conteúdo real: `arquivos:` do diff,
  aprendizados, e nó → `delivered` com arquivamento. Consolidar delta e
  promover decisões vivas rodam SÓ quando houver delta ou decisão
- **light-enxuto/2** — QUANDO uma demanda LIGHT fechar O SISTEMA DEVE promover
  ao `PRD.md` apenas se o ajuste alterar comportamento que o PRD já descreve;
  não alterando, registrar no nó e dizer em 1 linha que o PRD não mudou e por
  quê — silêncio sobre o PRD é proibido
- **light-enxuto/3** — QUANDO uma demanda LIGHT não tiver plano-arquivo O
  SISTEMA DEVE pular a etapa de arquivar plano sem listá-la como pendência
- **light-enxuto/4** — QUANDO a validate fechar uma demanda LIGHT O SISTEMA
  DEVE oferecer o e2e apenas se a demanda tocar caminho percorrido pelo
  usuário (tela, rota, fluxo, saída de CLI); LIGHT interno (refactor, doc,
  config, teste) não recebe a oferta
- **light-enxuto/5** — QUANDO a validate montar o roteiro de uma demanda LIGHT
  O SISTEMA DEVE entregar a versão curta: evidência 1:1 por critério + o diff
  + 1 linha de como conferir, sem sumário por arquivo e sem seção de decisões
  vivas quando não houver nenhuma
- **light-enxuto/6** — QUANDO uma demanda LIGHT for fechada O SISTEMA DEVE
  manter o portão humano com aprovação explícita E a evidência 1:1 por
  critério — o enxugamento corta material de revisão, nunca o portão nem a
  evidência
- **light-enxuto/7** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se `skills/validate/SKILL.md` não declarar o caminho de fechamento
  LIGHT
- **light-enxuto/8** — QUANDO a suíte de regressão rodar O SISTEMA DEVE
  reprovar se o caminho LIGHT declarado dispensar o portão humano ou a
  evidência 1:1 — guarda contra erosão futura do que /6 protege

## fora-de-escopo

Mudar o que LIGHT percorre: segue `execute → validate`, sem scope e sem plan.
Mudar as 4 perguntas de risco da classificação, ou o que faz uma demanda ser
LIGHT. Enxugar MEDIUM ou HIGH — o fechamento deles fica intacto. Dispensar o
≥1 critério EARS numerado que a porta de entrada já exige do LIGHT: é o
endereço que a evidência cita, fica. HOTFIX — tem caminho próprio, com
registro retroativo, e não entra aqui. Tornar o e2e indisponível: /4 muda a
OFERTA automática; pedido explícito do humano sempre roda. Mexer no bloco de
fechamento (nó `resumo-de-fase`, entregue) — o LIGHT já omite as fases que
não percorre.

## decisoes

- 2026-09-01 (humano): PRD só quando o ajuste altera comportamento já
  descrito nele. "Sempre" descartado por inflar o PRD com ruído; "nunca"
  descartado porque LIGHT que muda comportamento visível sumiria do retrato.
- 2026-09-01 (humano): oferta de e2e só quando toca caminho de usuário.
  "Sempre" descartado por gerar recusa repetida; "nunca em LIGHT" descartado
  por fechar a porta ao LIGHT que merecia.
- 2026-09-01 (humano): portão fica, roteiro encolhe. "Sem portão" descartado
  explicitamente — quebraria "IA executa / humano decide", que é o princípio
  central do framework.

## delta

## e2e

pendente

## feedback-reprovacao
