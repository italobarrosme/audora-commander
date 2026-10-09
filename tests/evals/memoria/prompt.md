---
max_turns: 40
timeout_seconds: 600
tags: [comportamento]
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, AskUserQuestion, TodoWrite]
---

Demanda dobro-negativo: a função dobro da lib deve aceitar números negativos
(hoje recusa). E fica a dica para sempre neste projeto: a suíte só passa com
LC_ALL=C bash tests/run.sh.
