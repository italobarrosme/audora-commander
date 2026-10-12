---
type: regex
arm: both
target: trace
flags: i
pattern: '^(?:(?!"name"\s*:\s*"(?:Write|Edit)"\s*,\s*"input"\s*:\s*\{(?:[^"}]|"(?:[^"\\]|\\.)*")*?"file_path"\s*:\s*"[^"]*(?:MEMORY\.md|docs(?:\\\\|/)audora(?:\\\\|/)memory(?:\\\\|/)))[\s\S])*?"type"\s*:\s*"assistant"(?:(?!"name"\s*:\s*"(?:Write|Edit)"\s*,\s*"input"\s*:\s*\{(?:[^"}]|"(?:[^"\\]|\\.)*")*?"file_path"\s*:\s*"[^"]*(?:MEMORY\.md|docs(?:\\\\|/)audora(?:\\\\|/)memory(?:\\\\|/)))[^\n])*?"type"\s*:\s*"text"\s*,\s*"text"\s*:\s*"(?:[^"\\\n]|\\.)*?classificada como \**MEDIUM\b(?:[^"\\\n]|\\.)*?porque(?:[^"\\\n]|\\.)*?me corrija'
---

A porta anuncia ao humano, num bloco de texto do assistente, "Demanda
classificada como MEDIUM porque … — me corrija se discordar", antes da 1ª
escrita (Write/Edit) no `MEMORY.md` ou em `docs/audora/memory/`. O modelo do
anúncio no corpo da skill carregada (evento `user`) e o texto dentro de
input de ferramenta não contam (porta-anuncio/2,3).
