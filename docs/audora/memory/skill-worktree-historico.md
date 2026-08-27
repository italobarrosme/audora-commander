# skill-worktree — histórico

> Frio movido do nó ativo (skill memory, operação compactar).

## decisoes

- 2026-08-27 (humano): fluxo derivado de pesquisa na internet (estado da arte
  de git worktree + uso com agentes de IA), não de conhecimento prévio.
- 2026-08-27 (humano): gatilho é pedido explícito do humano — nenhuma categoria
  de risco isola sozinha. Alinha com a própria ferramenta nativa, que só age
  "when explicitly instructed by the user or project instructions".
- 2026-08-27 (humano): alcance inclui fan-out de N agentes, integração em
  série. Ressalva da IA sobre o teto de 250 linhas não se materializou (175).
- 2026-08-27 (IA): a skill orquestra o worktree nativo do harness, não embarca
  plumbing de git — decorre da Constituição (executável só em `hooks/` e
  `tests/`) e de `EnterWorktree` só reconhecer `.claude/worktrees/`.

