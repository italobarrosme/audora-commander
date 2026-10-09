---
type: regex
arm: both
target: { source: file, path: docs/audora/aprendizados.md }
flags: m
pattern: '^- \d{4}-\d{2}-\d{2} \| [^\n]*LC_ALL=C'
---

A dica do prompt (LC_ALL=C) virou linha de aprendizado em
docs/audora/aprendizados.md — sem este grader o caso passaria vazio quando nada
é escrito.
