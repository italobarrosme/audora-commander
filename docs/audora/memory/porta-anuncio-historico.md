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

## delta

- ADICIONADO (2026-10-12): /7–/11, hook (debug: texto não basta, sonnet e opus)
- MODIFICADO (2026-10-12): /2, /7, /8 e /10 — "bloco de texto do assistente"
  → "bloco de texto ou de narração do assistente" (debug T9: o servidor troca
  a prosa entre ferramentas por narração; o modelo escreve o anúncio)
