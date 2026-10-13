# porta-anuncio — histórico

Decisões antigas movidas de `porta-anuncio.md` (teto ~100 linhas) na 2ª
reabertura, 2026-10-12. Continuam valendo.

## decisoes

2026-10-12, todas do humano (alternativa descartada entre parênteses):
- anúncio como frase própria antes do 1º registro (só no bloco de
  fechamento: tarde demais para corrigir barato; nos dois: redundante);
- eval exige categoria + porquê + convite (só a categoria: aceita anúncio
  sem justificativa);
- cobertura só MEDIUM, caso existente (MEDIUM+LIGHT+HIGH: ~3x o custo);
- prova = completo 3/3 com e 0/3 sem (rápido 1/1: não distingue sorte de regra).

2026-10-12 (IA, execute): carga BASE 53752 → 53879 (+127 bytes do passo 4,
já enxuto); guardas `parada-revisao/9` e `leitura-por-secao/11` sobem junto.

2026-10-12, reabertura, do humano: hook que recusa o registro (aceitar a
narração no thinking / parar em /3); alvo só nó novo in-progress ou
hotfix-pending-record (qualquer nó novo: falso bloqueio); janela desde a
última mensagem do humano (sessão inteira); falha deixa passar (recusar);
anúncio = frase completa, como o grader (só a categoria).

2026-10-12, 2ª reabertura (debug T9), do humano: a narração conta como
anúncio no hook e no grader (anunciar e pausar: uma ida e volta a mais por
demanda; parar e reverter o hook; descartar a demanda).

2026-10-12, 3ª reabertura (plan), do humano: na narração o anúncio vale por
sentido — `classific…` + `como <CAT>` + convite (`me corrija`/`me avise`) +
`discordar`, sem exigir `porque` (anunciar e pausar; parar e reverter o
hook; só a categoria). Motivo: a narração é resumo do servidor e parafraseia
(0/6 `classificada como`, 0/6 `porque`, 1/6 `me corrija`; plano, Notas).
IA, plan: `classific…` = radical `classifi(c|qu)` ("Classifiquei" em 6/12).

## delta

- ADICIONADO (2026-10-12): /7–/11, hook (debug: texto não basta, sonnet e opus)
- MODIFICADO (2026-10-12): /2, /7, /8 e /10 — "bloco de texto do assistente"
  → "bloco de texto ou de narração do assistente" (debug T9: o servidor troca
  a prosa entre ferramentas por narração; o modelo escreve o anúncio)
- MODIFICADO (2026-10-12): /2, /7, /8 — narração com contrato próprio, por
  sentido (plan: a narração parafraseia)
- ADICIONADO (2026-10-12, humano, debug T4): passo 6 entra na 1ª fase pela ferramenta
  Skill, nunca lendo o SKILL.md (Read em ~1/12 runs derrubou a /4; anterior: histórico)

## decisoes (movidas na 4ª reabertura)

- 2026-10-12 (medição, porta-anuncio/5, execute): `--mutar porta-anuncio --runs 3` → com a regra 3/3 · sem a regra 0/3 · efeito -100 pp
  (US$ 1.0441, hook ativo nos dois braços); manter ou cortar a regra é decisão do humano.
  Revalidada na validate 2026-10-12: 3/3 · 0/3 · -100 pp, US$ 0.9826.

## decisoes (4ª reabertura)

2026-10-12, 4ª reabertura, do humano (descartada entre parênteses), causa no
debug (aprendizado da narração: prosa ≥ 200 chars no meio do turno vira
narração em ~98%):
- anúncio curto (antes da 1ª ferramenta: sem contexto do MEMORY; no fim do
  turno: parada nova; afrouxar: anúncio sem convite);
- teto 150 chars (120: motivo telegráfico; sem número: não testável);
- hook não recusa anúncio longo em texto, só a mensagem pede o teto (recusar:
  recusa a mais sem ganho — texto chegou ao humano);
- /4 com 6 runs por braço (3: passou por sorte na execute, 1/3 na validate);
- /6 mantém o `tdd` com 1 rerun no perfil `retomada-execute` (estrito: falha
  alheia à demanda; tirar o tdd: perde a guarda).

## feedback-reprovacao (movido na execute da 4ª reabertura)

2026-10-12 (validate): /1 (narração parafraseada, hook recusa 2×), /4 (1/3),
/6 (`tdd` 0/1) → debug (prosa longa no meio do turno) → 4ª reabertura.

## delta (4ª reabertura; movido na validate de 2026-10-13)

- MODIFICADO (2026-10-12, 4ª reabertura): /1 frase sem teto → ≤ 150 chars e
  `<motivo curto>`; /4 3/3·0/3 → `--runs 6` 6/6·0/6; /6 + rerun no perfil
  retomada; /7 mensagem cita o teto. ADICIONADO: /12, /13

## e2e (1ª rodada)

2026-10-12: /1, /4, /6 falharam (relatório no `git log` de
`docs/audora/e2e/e2e-porta-anuncio.md`); resposta: 4ª reabertura.

## movido no scope da 5ª reabertura (2026-10-13)

- 2026-10-12 (medição, porta-anuncio/5, 4ª reabertura): `--mutar porta-anuncio --runs 3` → com a regra 3/3 · sem a regra 0/3 · efeito -100 pp
  (de novo na validate de 10-13: 3/3 · 0/3, US$ 0.9885); manter ou cortar a regra é decisão do humano.
- feedback-reprovacao 2026-10-13 (validate, por escopo): /1 teto 150 cumprido
  em 1/9 — o motivo lista as respostas de risco; >~200 vira narração. /4 5/6:
  o grader conta o Write recusado pelo hook como 1ª escrita (recusa → texto →
  nó reprova). Resposta: 5ª reabertura.
