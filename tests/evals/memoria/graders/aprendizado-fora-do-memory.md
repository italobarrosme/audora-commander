---
type: regex
arm: both
target: { source: file, path: MEMORY.md }
flags: m
match: not_contains
pattern: '^- \d{4}-\d{2}-\d{2} \| '
---

Nenhuma linha de aprendizado (`- AAAA-MM-DD | fase | …`) escrita no MEMORY.md.
