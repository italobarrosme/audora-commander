# E2E — cleanup-link-preciso (2026-10-03)

Infra: plugin não-web, sem docker. O "produto rodando" é o plugin 0.16.0 da
`main` em `6253833`, reinstalado com `claude plugin uninstall
audora-commander@audora-commander-dev && ./install.sh`. `diff -r` de
`skills/`, `hooks/` e `templates/` contra `<cache>/0.16.0` → vazio. As
sessões chamaram `hooks/cleanup` pelo caminho do repo (marketplace dev aponta
para o repo; cache = repo). Ferramenta: `claude -p` (CLI 2.1.284,
Constituição `ferramenta-e2e`).

Caminhos de fixture só aparecem dentro de bloco de código: este relatório
mora em docs/audora e é varrido pela própria cleanup.

## Receita (regressão)

1. **Fixture** — `fixture.sh <dir> <loja|typo|semcommit>` (no scratchpad):

```bash
#!/usr/bin/env bash
# fixture.sh <dir> <loja|typo|semcommit> — fixtures do e2e cleanup-link-preciso
set -euo pipefail
d="$1"; tipo="$2"
rm -rf "$d"; mkdir -p "$d"; cd "$d"
git init -q -b main
git config user.email e2e@test; git config user.name e2e
git config core.autocrlf false; git config core.excludesFile "$d/.nao-existe"
memory() { # memory <linha de aprendizado ou vazio>
  printf 'memory-schema: 1\n\n## Propósito [carga: sempre]\n\nLoja de teste.\n\n## Constituição [carga: sempre]\n\n- **stack**: markdown\n\n## Aprendizados [carga: sempre]\n\n%s\n## Índice de nós [carga: sempre]\n\n- d | delivered | Carrinho → docs/audora/arquivo/2026-01-01-d.md\n' "$1" > MEMORY.md
}
no_d() { # no_d <corpo>
  mkdir -p docs/audora/arquivo docs/audora/memory
  printf -- '---\nid: d\nestado: delivered\norigem: humano\ndepende-de: []\narquivos: []\nkeywords: []\nresumo: carrinho\natualizado-em: 2026-01-01\n---\n# d\n\n%s\n' "$1" > docs/audora/arquivo/2026-01-01-d.md
}
case "$tipo" in
  loja)   # spec de d no lote; link para e2e-velho (versionado e removido); link de rascunho nunca versionado;
          # aprendizado que cita os três tipos de caminho (inexistente, removido, que sai no lote)
    memory '- 2026-01-01 | execute | fixture antiga citava `docs/audora/arquivo/2026-01-01-x.md`, o relatório `docs/audora/e2e/e2e-velho.md` e a spec `docs/audora/specs/d-escopo.md`
'
    no_d 'Spec: `docs/audora/specs/d-escopo.md`

Relatório antigo: [rel](../e2e/e2e-velho.md)

Rascunho: [t](../specs/d-escopo-tipo.md)'
    mkdir -p docs/audora/specs docs/audora/e2e
    printf '# spec d\n' > docs/audora/specs/d-escopo.md
    printf '# e2e velho\n' > docs/audora/e2e/e2e-velho.md
    printf '# Decisões vivas\n' > docs/audora/decisoes-vivas.md
    printf '# loja\n' > README.md
    git add -A; git commit -qm init
    git rm -q docs/audora/e2e/e2e-velho.md; git commit -qm 'remove e2e velho' ;;
  typo)   # só um link nunca versionado
    memory ''; no_d 'Rascunho: [t](../specs/d-escopo-tipo.md)'
    printf '# Decisões vivas\n' > docs/audora/decisoes-vivas.md; printf '# loja\n' > README.md
    git add -A; git commit -qm init ;;
  semcommit)  # git init sem commit
    memory ''; no_d 'Relatório: [rel](../e2e/e2e-velho.md)' ;;
esac
```

2. **Sessão** — `claude.exe -p "<prompt>" --permission-mode acceptEdits
   --allowedTools "Bash Read Grep Glob Skill Write Edit" --output-format
   stream-json --verbose`, turno 2 com `--resume <session_id>`.
   - Turno 1 (`loja` e `typo`): "Faz uma faxina nas sobras do processo
     deste projeto (nós órfãos, arquivo morto, link quebrado). Me mostra o
     que sairia antes de mexer em qualquer coisa."
   - Turno 2 (`loja`): "Aprovo o lote inteiro. Pode aplicar."
3. **CLI direta** (o script é o produto da parte mecânica): `varrer`/`contar`
   nas 3 fixtures; `aplicar` de lote montado à mão numa cópia da `loja`
   (`loja6`); `contar`/`varrer` neste repo.

## Resultado

| Critério | Passo executado | Evidência | Veredito |
|---|---|---|---|
| cleanup-link-preciso/1 — link para caminho nunca versionado → `## nunca existiu`, fora do lote, com `arquivo:linha` e caminho | `loja` turno 1 (sessão real rodou `varrer`) | relatório da sessão, bloco A abaixo: link de rascunho em `## nunca existiu` com `:17` e o caminho | passou |
| cleanup-link-preciso/2 — link para caminho versionado e removido → `## link quebrado`, no lote | `loja` turno 1 | bloco A: `:15 \| aponta ../e2e/e2e-velho.md inexistente` em `## link quebrado`, contado no total | passou |
| cleanup-link-preciso/3 — `contar` = total do lote, sem `## nunca existiu` | CLI nas 3 fixtures | `loja`: total 2 / `contar=2`; `typo` e `semcommit`: `nada a limpar` / `contar=0` | passou |
| cleanup-link-preciso/4 — lote vazio só com `## nunca existiu` → avisos + `cleanup: nada a limpar` | `typo` turno 1 + CLI | bloco B; a sessão disse "Não precisa limpar nada" e mostrou o aviso | passou |
| cleanup-link-preciso/5 — `aplicar` ignora `## nunca existiu` do lote aprovado | `loja` turno 2 | o lote gravado pela sessão traz `## nunca existiu`; commit só com spec + nó arquivado; linha 17 intacta (bloco C) | passou |
| cleanup-link-preciso/6 — link quebrado de alvo nunca versionado (lote à mão) → recusa na pré-checagem, nada muda | CLI `aplicar` em `loja6` com spec válida + item do rascunho | bloco D: `falhou em: … — link para caminho nunca versionado: …`, exit 1, HEAD/status/md5 iguais | passou |
| cleanup-link-preciso/7 — link quebrado vira "já não existia … (link limpo pela cleanup)" | `loja` turno 2 | bloco C, linha "Relatório antigo" | passou |
| cleanup-link-preciso/8 — arquivo apagado mantém a nota "removido … pela cleanup" | `loja` turno 2 | bloco C, linha "Spec" | passou |
| cleanup-link-preciso/9 — linha de Aprendizados fora do relatório inteiro | `loja` turno 1 | o aprendizado cita um caminho inexistente e um removido; bloco A não tem nenhuma linha `MEMORY.md:` | passou |
| cleanup-link-preciso/10 — arquivo do lote citado em Aprendizados: linha intacta, demais citadores trocados | `loja` turno 2 | `git diff HEAD~1 -- MEMORY.md` vazio; MEMORY.md fora do commit; nó d com a nota (bloco C) | passou |
| cleanup-link-preciso/11 — repo sem commit → todo link inexistente em `## nunca existiu`, sem erro | CLI `varrer`/`contar` em `semcommit` | bloco E, exit 0, `contar=0` | passou |
| cleanup-link-preciso/12 — skill explica `## nunca existiu` como aviso fora do lote (typo/exemplo/fixture), humano corrige à mão | turnos 1 de `loja` e `typo` | `loja`: "Link que nunca existiu … nunca entrou no git. Parece erro de digitação ou exemplo. A cleanup não mexe nele; se quiser, corrija à mão." `typo`: "Parece erro de digitação ou rascunho … só corrige à mão se quiser." | passou |
| cleanup-link-preciso/13 — `contar` neste repo → 0 | CLI na raiz do repo, `main` em `6253833` | `contar` → `0`; `varrer` → `cleanup: nada a limpar` (o falso positivo `MEMORY.md:94` sumiu) | passou |

### Evidência crua

```
A — loja, turno 1, saída do varrer na sessão:
cleanup: relatório — nada foi alterado
## spec de nó entregue
- docs/audora/specs/d-escopo.md | nó d delivered
## link quebrado
- docs/audora/arquivo/2026-01-01-d.md:15 | aponta ../e2e/e2e-velho.md inexistente
## nunca existiu
- docs/audora/arquivo/2026-01-01-d.md:17 | aponta ../specs/d-escopo-tipo.md nunca versionado
total: 2 item(ns) no lote

B — typo, turno 1 (e CLI):
## nunca existiu
- docs/audora/arquivo/2026-01-01-d.md:13 | aponta ../specs/d-escopo-tipo.md nunca versionado
cleanup: nada a limpar

C — loja, turno 2: "cleanup: commit 09517b3 — 2 item(ns) removido(s)"
commit: chore(cleanup): remove 2 sobra(s) do processo
  spec de nó entregue: docs/audora/specs/d-escopo.md
  link quebrado: docs/audora/arquivo/2026-01-01-d.md:15
  arquivos: docs/audora/arquivo/2026-01-01-d.md, docs/audora/specs/d-escopo.md
nó d depois:
  Spec: `docs/audora/specs/d-escopo.md` removido em 2026-10-03 pela cleanup — recuperável no git
  Relatório antigo: `docs/audora/e2e/e2e-velho.md` já não existia em 2026-10-03 (link limpo pela cleanup) — recuperável no git
  Rascunho: [t](../specs/d-escopo-tipo.md)
varrer logo após: só '## nunca existiu' (a linha 17) + 'cleanup: nada a limpar'; contar=0

D — loja6, aplicar de lote à mão:
cleanup: falhou em: - docs/audora/arquivo/2026-01-01-d.md:17 | aponta ../specs/d-escopo-tipo.md inexistente — link para caminho nunca versionado: docs/audora/specs/d-escopo-tipo.md
cleanup: lote desfeito, nada commitado
exit=1 ; estado igual (HEAD 1885fb6, status, md5)

E — semcommit:
## nunca existiu
- docs/audora/arquivo/2026-01-01-d.md:13 | aponta ../e2e/e2e-velho.md nunca versionado
cleanup: nada a limpar
exit=0 ; contar=0
```

## Observações (fora dos critérios)

- `loja` turno 1: a sessão tentou gravar o relatório num arquivo temporário
  antes da aprovação, e o harness bloqueou (nada mudou). No turno 2 ela
  gravou o lote no scratchpad da sessão, como a skill manda.
- As duas sessões apontaram a falta de `PRD.md` na fixture (regra global do
  usuário, não da skill) e não criaram nada sem pedir.
- Custo: `loja` US$ 0,57 na sessão inteira (o `total_cost_usd` do `--resume` acumula; turno 1 = 0,49); `typo` US$ 0,47.
- Teardown: nada levantado (sem servidor nem container); fixtures no
  scratchpad da sessão.
