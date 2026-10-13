---
type: regex
arm: both
target: trace
flags: i
pattern: '^(?:"id"\s*:\s*"([^"\\]+)"\s*,\s*"name"\s*:\s*"(?:Write|Edit)"\s*,\s*"input"\s*:\s*\{(?:[^"}]|"(?:[^"\\]|\\.)*")*?"file_path"\s*:\s*"[^"]*(?:MEMORY\.md|docs(?:\\\\|/)audora(?:\\\\|/)memory(?:\\\\|/))(?:(?!"name"\s*:\s*"(?:Write|Edit)"\s*,\s*"input"\s*:\s*\{(?:[^"}]|"(?:[^"\\]|\\.)*")*?"file_path"\s*:\s*"[^"]*(?:MEMORY\.md|docs(?:\\\\|/)audora(?:\\\\|/)memory(?:\\\\|/)))[\s\S])*?"type"\s*:\s*"tool_result"\s*,\s*"content"\s*:\s*"PreToolUse:(?:Write|Edit) hook error:(?:[^"\\]|\\.)*"\s*,\s*"is_error"\s*:\s*true\s*,\s*"tool_use_id"\s*:\s*"\1"|(?!"name"\s*:\s*"(?:Write|Edit)"\s*,\s*"input"\s*:\s*\{(?:[^"}]|"(?:[^"\\]|\\.)*")*?"file_path"\s*:\s*"[^"]*(?:MEMORY\.md|docs(?:\\\\|/)audora(?:\\\\|/)memory(?:\\\\|/)))[\s\S])*?"type"\s*:\s*"assistant"(?:(?!"name"\s*:\s*"(?:Write|Edit)"\s*,\s*"input"\s*:\s*\{(?:[^"}]|"(?:[^"\\]|\\.)*")*?"file_path"\s*:\s*"[^"]*(?:MEMORY\.md|docs(?:\\\\|/)audora(?:\\\\|/)memory(?:\\\\|/)))[^\n])*?(?:"type"\s*:\s*"text"\s*,\s*"text"\s*:\s*"(?:[^"\\\n]|\\.)*?classificada como \**MEDIUM\b(?:[^"\\\n]|\\.)*?porque(?:[^"\\\n]|\\.)*?me corrija|"type"\s*:\s*"thinking"\s*,\s*"thinking"\s*:\s*"(?:[^"\\\n]|\\.)*?classifi(?:c|qu)(?:[^"\\\n]|\\.)*?como \**MEDIUM\b(?:[^"\\\n]|\\.)*?(?:me corrija|me avise)(?:[^"\\\n]|\\.)*?discordar(?:[^"\\\n]|\\.)*"\s*,\s*"signature"\s*:\s*"[^"]*?(?:QgluYXJyYXRp|IJbmFycmF0aW9u|CCW5hcnJhdGlv))'
---

A porta anuncia ao humano, num bloco de texto do assistente, "Demanda
classificada como MEDIUM porque … — me corrija se discordar", antes da 1ª
escrita (Write/Edit) no `MEMORY.md` ou em `docs/audora/memory/`. Também vale,
por sentido, a narração do servidor (bloco `thinking` com `narration` na
assinatura, que resume a prosa entre ferramentas): `classifi…` + `como MEDIUM`
+ `me corrija`/`me avise` + `discordar`, sem exigir `porque`. O modelo do
anúncio no corpo da skill carregada (evento `user`), o raciocínio sem a marca
e o texto dentro de input de ferramenta não contam (porta-anuncio/2,3).
Write/Edit recusado por hook PreToolUse (tool_result com "PreToolUse:… hook
error:", is_error true e o mesmo id) não conta como 1ª escrita
(porta-anuncio/14).
