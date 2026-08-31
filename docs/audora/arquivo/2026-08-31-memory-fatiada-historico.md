# memory-fatiada — histórico frio

> Decisões do portão de escopo e da execução, movidas do nó em 2026-08-31
> pelo teto de ~100 linhas (`memory-guard`). O nó aponta para cá.

## decisoes

- 2026-08-30 (humano): estratégia híbrida — quentes e pequenas inline
  (carregar-contexto, registrar-delta, registrar-aprendizado), grandes ou
  frias em reference (bootstrap, registrar-no, compactar, consultar-codigo).
  Máximo (7 references) foi descartado: toda chamada de fase pagaria um Read.
- 2026-08-30 (humano): reference ausente avisa e degrada, mesmo padrão do
  Graphify — índice é atalho, não portão.
- 2026-08-30 (humano): reference segue o mesmo teto de 250 linhas do SKILL.md,
  um número só para lembrar.
- 2026-08-30 (IA): medição antes/depois vira critério (/9) por causa da
  decisão viva de 2026-08-25 (grafo-v2) que mandou medir se a travessia
  voltasse a doer. Voltou.
- 2026-08-31 (IA): teto auto-imposto do plano (roteador ≤ 7600 bytes) foi
  estourado — deu 7979. Tabela de roteamento e regra de degradação (/3 e /4)
  custam ~700 bytes não previstos. Não aparei conteúdo normativo por número
  auto-imposto; teto real aceito 8000.

## medicao (/9) — tabela por sessão de fase

| sessão | operações usadas | antes | depois |
|---|---|---|---|
| S1 commander+scope | carregar-contexto, registrar-no, registrar-aprendizado | 13.331 | 9.308 |
| S2 plan | carregar-contexto, consultar-codigo | 13.331 | 9.888 |
| S3 execute | consultar-codigo, registrar-delta, registrar-aprendizado | 13.331 | 9.888 |
| S4 e2e | carregar-contexto, registrar-aprendizado | 13.331 | 7.979 |
| S5 validate | compactar, registrar-delta | 13.331 | 9.778 |
| **total** | | **66.655** | **46.841** |
