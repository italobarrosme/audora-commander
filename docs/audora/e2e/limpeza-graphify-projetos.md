# Limpeza do Graphify nos projetos locais — corte-sem-uso/1–4

Rodada em 2026-09-30 pelo `hooks/graphify-limpeza --remover` do plugin no
HEAD `ab68deb`, chamado por um script de sessão (não versionado) com PATH
sem `uv`/`pipx` — o pacote `graphifyy` não foi detectado nem desinstalado.
15 projetos com `MEMORY.md` `memory-schema: 1` na raiz de um repo git; 13
com resto, 2 já limpos. Nenhum commit nos projetos: HEAD de todos igual ao
de antes, mudanças ficam no working tree. Backup dos hooks de git e dos
arquivos alteráveis em `$SCRATCH/backup/<projeto>/` (scratchpad da sessão);
`graphify-out/` apagado sem backup (saída derivada, ~330 MB). Detecção
seguinte: vazia nos 15 (exit 0). Notas: em `MESA/vibra-reseller-panel` o
`MEMORY.md` é ignorado pelo `.gitignore` do projeto (limpo, mas não aparece
no `git status`); em `VTURBO/vturbo-bipa` o `MEMORY.md` já estava modificado
antes, então o `git status` não muda de linha. Fora do alcance do detector
e deixado como está (spec: nada além dos restos): a linha de cabeçalho
"Graphify em `graphify-out/` … consultado pela skill memory" no `MEMORY.md`
de 12 projetos e aprendizados antigos que citam o Graphify.

## KN8X PRODUCTS/capibaracash

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## KN8X PRODUCTS/kn8

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## KN8X PRODUCTS/trip-trip-trip

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## MESA/vibra-reseller-panel

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- git status alterado: .gitignore
- fora dos restos: nenhum
- detecção depois: vazia

## VTURBO/SellInfoTurbo

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore;settings .claude/settings.json;claude-md CLAUDE.md;claude-md .claude/CLAUDE.md;skill .claude/skills/graphify/
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- removido settings .claude/settings.json
- removido claude-md CLAUDE.md
- versionado .claude/settings.json
- versionado .gitignore
- versionado CLAUDE.md
- versionado MEMORY.md
- removido claude-md .claude/CLAUDE.md
- removido skill .claude/skills/graphify/
- git status alterado: .claude/CLAUDE.md .claude/settings.json .claude/skills/graphify/.graphify_version .claude/skills/graphify/SKILL.md .claude/skills/graphify/references/add-watch.md .claude/skills/graphify/references/exports.md .claude/skills/graphify/references/extraction-spec.md .claude/skills/graphify/references/github-and-merge.md .claude/skills/graphify/references/hooks.md .claude/skills/graphify/references/query.md .claude/skills/graphify/references/transcribe.md .claude/skills/graphify/references/update.md .gitignore CLAUDE.md MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## VTURBO/catch-promotion

- detectado: nada
- git status alterado: nenhum
- fora dos restos: nenhum
- detecção depois: vazia

## VTURBO/legal-verify

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## VTURBO/promolinked

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## VTURBO/vturbo-bipa

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore
- fora dos restos: nenhum
- detecção depois: vazia

## audora-commander

- detectado: nada
- git status alterado: nenhum
- fora dos restos: nenhum
- detecção depois: vazia

## boardboard

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## esfera-3d

- detectado: constituicao MEMORY.md;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## esfera-bench/claude-opus-5-5/C-r1

- detectado: constituicao MEMORY.md;gitignore .gitignore
- removido constituicao MEMORY.md
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## esfera-bench/claude-opus-5-5/D-r1

- detectado: constituicao MEMORY.md;gitignore .gitignore
- removido constituicao MEMORY.md
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia

## pepity

- detectado: constituicao MEMORY.md;git-hook .git/hooks/post-commit;git-hook .git/hooks/post-checkout;pasta graphify-out/;gitignore .gitignore
- removido constituicao MEMORY.md
- removido git-hook .git/hooks/post-commit
- removido git-hook .git/hooks/post-checkout
- removido pasta graphify-out/
- removido gitignore .gitignore
- versionado .gitignore
- versionado MEMORY.md
- git status alterado: .gitignore MEMORY.md
- fora dos restos: nenhum
- detecção depois: vazia
