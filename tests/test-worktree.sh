#!/usr/bin/env bash
# skill-worktree/1..14 — contratos de conteúdo da skill worktree.
source "$(dirname "$0")/lib.sh"
cd "$ROOT" || exit 1
f="skills/worktree/SKILL.md"
assert_file "$f" "skill worktree existe"
[ -f "$f" ] || { report; exit; }
w="$(cat "$f")"
[ "$(wc -l < "$f")" -le 250 ] && ok || ko "worktree > 250 linhas"
grep -q "^name: worktree\$" "$f" && ok || ko "worktree name:"
grep -q "^description: 'Use quando" "$f" && ok || ko "worktree description entre aspas simples"
assert_contains "$w" 'LEI DE FERRO' "worktree Lei de Ferro"
assert_contains "$w" 'Anuncie ao começar' "worktree Anuncie"
assert_contains "$w" '## PRÓXIMA SKILL' "worktree PRÓXIMA SKILL"
assert_not_contains "$w" 'grafo' "worktree sem grafo"
# /1 gatilho é pedido explícito — nunca iniciativa própria
assert_contains "$w" 'pedido explícito' "/1 worktree exige pedido explícito"
# /2 nomeação pelo id do nó
assert_contains "$w" 'id do nó' "/2 nome derivado do id do nó"
# /4 arquivos ignorados pelo git
assert_contains "$w" '.worktreeinclude' "/4 cita .worktreeinclude"
# /5 hooks compartilhados
assert_contains "$w" 'hooks são compartilhados' "/5 avisa hooks compartilhados"
# /7 e /8 fan-out
assert_contains "$w" 'não-sobrepostos' "/7 domínios de arquivo não-sobrepostos"
assert_contains "$w" 'em série' "/8 e /9 criação e integração em série"
# /10 e /11 remoção
assert_contains "$w" 'discard_changes' "/10 cita a trava da ferramenta nativa"
# /12 órfãos
assert_contains "$w" 'git worktree prune' "/12 limpeza de órfãos"
# /15 junction/symlink: `git worktree remove` apaga o ALVO (verificado, Git 2.52 Windows)
assert_contains "$w" 'junction' "/15 avisa sobre junction"
assert_contains "$w" 'desconect' "/15 manda desconectar o link antes de remover"
# /16 arquivo ignorado nao bloqueia a remocao e nao aparece em status --porcelain
assert_contains "$w" 'ls-files --others --ignored' "/16 checa ignorados antes de remover"
# /6 e /10: deteccao de commit nao integrado sem depender de upstream
assert_contains "$w" 'rev-list --count HEAD --not --remotes' "/6 /10 unpushed sem upstream"
# /13 degradação
assert_contains "$w" 'degrada' "/13 degrada sem travar"
# ferramentas nativas orquestradas, não plumbing próprio
for s in 'EnterWorktree' 'ExitWorktree' 'git worktree list --porcelain'; do
  assert_contains "$w" "$s" "worktree cita '$s'"
done
# registra aprendizado como as demais fases
assert_contains "$w" 'registrar-aprendizado' "worktree registra aprendizado"
report
