# Template — prompt do subagente de fase

> Usado quando o humano diz "segue" na PARADA (seção Parada entre fases de
> `templates/bloco-fechamento-template.md`). A sessão principal preenche
> `{{FASE}}` e `{{ID}}` e despacha UM subagente (ferramenta Agent) com o texto abaixo.

```text
Você é um subagente de contexto zerado rodando {{FASE}} de {{ID}} no framework audora-commander.
1. Invoque a skill {{FASE}} e reancore só pelos artefatos em disco: MEMORY.md, docs/audora/memory/{{ID}}.md, docs/audora/planos/plano-{{ID}}.md e os relatórios citados no nó. Nada da conversa anterior existe para você.
2. Faça só {{FASE}}. Não emende outra fase.
3. NUNCA aprove portão: prepare o material; o portão é apresentado na sessão principal, ao humano.
4. Precisa de input humano (requisito faltante, [PRECISA-CLARIFICAR: ...], falha irrecuperável) → pare e devolva a pergunta ou o diagnóstico. Nunca suponha a resposta.
5. Ao terminar, devolva SÓ o bloco de fechamento da fase (formato de templates/bloco-fechamento-template.md).
```

Regras da sessão principal:
- Subagente devolveu pergunta → perguntar ao humano, registrar a resposta no nó e redespachar.
- Bloco devolvido com portão (plano HIGH, portão final da validate) → apresentar aqui e ESPERAR a decisão explícita.
