---
id: gate-mecanico
estado: delivered
origem: humano
depende-de: []
arquivos: [templates/gate-template.md, hooks/gate, tests/test-gate.sh, skills/execute/SKILL.md, skills/validate/SKILL.md, skills/memory/SKILL.md, skills/memory/references/bootstrap.md, MEMORY.md, PRD.md, docs/audora/e2e/e2e-gate-mecanico.md, docs/audora/planos/arquivo/plano-gate-mecanico.md]
keywords: [gate, loop-engineering, anti-fraude, testes, lint, typecheck, template]
resumo: Comando único por projeto-alvo que responde passou/não passou (suíte, lint, typecheck, anti-fraude de teste); GREEN do execute vira gate verde.
atualizado-em: 2026-09-04
---

# gate-mecanico

## objetivo

Um comando único por projeto-alvo que responde passou/não passou — o "teste
que define pronto" do loop engineering. Gerado de `templates/gate-template.md`,
vive no projeto-alvo, registrado na Constituição como bullet `gate:`. Cobre
suíte, lint e typecheck quando a stack tem, e anti-fraude de teste (arquivo de
teste apagado, skip/only adicionado, contagem de asserts derrubada sem
justificativa). D1 do roadmap
`docs/specs/2026-09-02-loop-engineering-roadmap.md`.

## criterios-aceite

- **gate-mecanico/1** — QUANDO o bootstrap rodar em projeto sem `gate:` na
  Constituição O SISTEMA DEVE oferecer gerar o gate a partir de
  `templates/gate-template.md` e registrar a escolha na Constituição
  (`gate: <comando>` ou `gate: recusado`)
- **gate-mecanico/2** — QUANDO uma demanda iniciar (carregar-contexto) em
  projeto já bootstrapado sem bullet `gate:` O SISTEMA DEVE fazer a mesma
  oferta UMA vez; recusado fica recusado
- **gate-mecanico/3** — QUANDO o gate rodar O SISTEMA DEVE executar suíte,
  lint e typecheck da stack e sair 0 (passou) ou 1 (não passou) com o motivo
  impresso
- **gate-mecanico/4** — QUANDO o gate rodar em projeto sem lint ou typecheck
  O SISTEMA DEVE pular a etapa ausente avisando, nunca falhar por ausência de
  ferramenta
- **gate-mecanico/5** — QUANDO o diff não commitado (working tree + staged vs
  HEAD) apagar arquivo de teste O SISTEMA DEVE reprovar nomeando o arquivo
- **gate-mecanico/6** — QUANDO o diff não commitado adicionar marcador de
  skip/only da stack (skip, only, xit e equivalentes) O SISTEMA DEVE reprovar
  nomeando arquivo e linha
- **gate-mecanico/7** — QUANDO o diff não commitado derrubar a contagem de
  asserts sem justificativa registrada no nó da demanda O SISTEMA DEVE
  reprovar informando contagem antes → depois
- **gate-mecanico/8** — QUANDO a queda de asserts tiver justificativa
  registrada no nó da demanda (marcador definido no gate-template) O SISTEMA
  DEVE passar imprimindo a justificativa
- **gate-mecanico/9** — QUANDO a Constituição tiver `gate:` O SISTEMA DEVE
  (skill execute) tratar GREEN como gate verde — etapa só é verde com gate
  saindo 0
- **gate-mecanico/10** — QUANDO a validate montar o roteiro O SISTEMA DEVE
  listar o diff dos arquivos de teste separado do resto, em toda categoria
- **gate-mecanico/11** — QUANDO esta demanda for entregue O SISTEMA DEVE ter
  o gate deste próprio repo gerado do template, vivendo em `hooks/`
  (Constituição: executável só em `hooks/` e `tests/`) e registrado como
  `gate:` na Constituição

## fora-de-escopo

Instalar ferramentas no projeto-alvo; CI remoto; hook de git `pre-commit`
(decisão do humano por projeto); autopilot (D2) e motor headless (D3);
detecção de fraude além das três classes (arquivo apagado, skip/only,
contagem de asserts); rodar o gate automaticamente por conta própria (quem
dispara é a execute ou o humano — motor é D3).

## decisoes

- 2026-09-04 (humano): aberta como segunda demanda do roadmap, após D0
  entregue; `sync-mecanizado` já fechado antes (recomendação nº 1 do roadmap).
- 2026-09-04 (humano, scope): contagem de asserts ENTRA no D1, com válvula de
  justificativa no nó. Descartados: adiar (infiel ao objetivo do roadmap) e
  sem válvula (falso positivo em refactor legítimo).
- 2026-09-04 (humano, scope): dogfood SIM — este repo gera o próprio gate e
  registra `gate:` na Constituição. Descartado: só template+skills (template
  chegaria cru em D2/D3, sem uso real).
- 2026-09-04 (humano, scope): anti-fraude examina o diff NÃO COMMITADO
  (working tree + staged vs HEAD) — a volta atual. Descartados: branch vs
  base (exige parâmetro, reprova volta inocente por pecado antigo) e os dois
  (mais lógica sem necessidade no v1).
- 2026-09-04 (humano, scope): oferta no bootstrap E no início de demanda em
  projeto sem `gate:`, uma vez; recusado fica recusado (padrão Graphify).
  Descartados: só bootstrap e só a pedido (adoção lenta).
- 2026-09-04 (IA, scope): formato exato do marcador de justificativa de
  asserts é schema — vive no `gate-template.md` (Constituição: schema só em
  `templates/`), definido na fase plan/execute.

## delta

## e2e

relatorio: ../e2e/e2e-gate-mecanico.md

## feedback-reprovacao
