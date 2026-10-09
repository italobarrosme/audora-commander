---
type: tool_used
arm: both
tool: Edit
min: 0
max: 0
input_match: '"file_path"\s*:\s*"(?![^"]*(?:MEMORY\.md|docs(?:\\\\|/)audora(?:\\\\|/)))[^"]*"'
---

Nenhum Edit fora de `MEMORY.md` e `docs/audora/` no run: num run não
interativo o escopo nunca é aprovado, então o nó nunca tem critérios aprovados
e qualquer escrita de código ou teste fura a Lei de Ferro do scope.
