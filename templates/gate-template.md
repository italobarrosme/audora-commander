# Template — gate mecânico (skills memory/execute)

Esqueleto canônico do gate: UM comando por projeto que responde passou/não
passou — suíte, lint, typecheck e anti-fraude de teste. Gerado pela oferta do
bootstrap (ou do início de demanda) quando a Constituição não tem `gate:`;
vive no projeto-alvo (neste repo: `hooks/gate` — executável só em `hooks/` e
`tests/`), e a escolha é registrada na Constituição do `MEMORY.md`:
`gate: <comando>` (ex.: `gate: bash hooks/gate <id-da-demanda>`) ou
`gate: recusado` — recusado fica recusado.

Contrato: exit 0 imprime `GATE: passou`; exit 1 imprime `GATE: reprovado` com
TODOS os motivos acumulados. Anti-fraude examina o diff NÃO COMMITADO
(`git diff HEAD` = working tree + staged) — a volta atual. Queda na contagem
de asserts só passa com justificativa registrada no nó da demanda: linha
`gate-asserts: <motivo>` em `docs/audora/memory/<id>.md` (o id chega como
argumento). Etapa sem ferramenta na stack (lint/typecheck vazios) é `pulado`
com aviso — nunca falha por ausência.

## gate (script bash no projeto-alvo)

```bash
#!/usr/bin/env bash
# Gate mecânico (audora-commander) — passou/não passou em um comando.
# Uso: gate [<id-da-demanda>]   (id habilita a válvula gate-asserts: do nó)
# Config: defaults abaixo saem da Constituição do MEMORY (como-rodar/stack);
# env GATE_* sobrepõe qualquer default (é assim que a suíte testa o gate).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1   # raiz do projeto (gate em subpasta)

SUITE_CMD="${GATE_SUITE_CMD:-npm test}"   # como-rodar da Constituição
LINT_CMD="${GATE_LINT_CMD:-}"             # vazio = pulado com aviso
TYPECHECK_CMD="${GATE_TYPECHECK_CMD:-}"   # vazio = pulado com aviso
TEST_ERE="${GATE_TEST_ERE:-(^|/)(tests?|__tests__)/|\.(test|spec)\.[a-z]+$}"
SKIP_ERE="${GATE_SKIP_ERE:-\.only\(|\.skip\(|xit\(|xdescribe\(|fit\(|fdescribe\(|@skip}"
ASSERT_ERE="${GATE_ASSERT_ERE:-expect\(|assert}"
NODE_DIR="${GATE_NODE_DIR:-docs/audora/memory}"

id="${1:-}"; falhas=()

# --- anti-fraude 1: arquivo de teste apagado (nomeia o arquivo) ---
while IFS= read -r f; do
  [ -n "$f" ] && falhas+=("arquivo de teste apagado: $f")
done < <(git diff HEAD --name-only --diff-filter=D | grep -E "$TEST_ERE" || true)

# --- anti-fraude 2: skip/only adicionado (nomeia arquivo e linha) ---
while IFS= read -r f; do
  [ -f "$f" ] || continue
  while IFS= read -r hit; do
    [ -n "$hit" ] && falhas+=("skip/only adicionado: $f:$hit")
  done < <(git diff HEAD -U0 -- "$f" | awk -v ere="$SKIP_ERE" '
    /^@@/ { split($3, a, ","); ln = substr(a[1], 2) + 0; next }
    /^\+\+\+/ { next }
    /^\+/ { if (substr($0, 2) ~ ere) print ln ": " substr($0, 2); ln++ }')
done < <(git diff HEAD --name-only --diff-filter=d | grep -E "$TEST_ERE" || true)

# --- anti-fraude 3: contagem de asserts caiu (válvula: gate-asserts: no nó) ---
antes=0; depois=0
while IFS= read -r f; do
  a="$(git show "HEAD:$f" 2>/dev/null | grep -cE "$ASSERT_ERE")" || true
  b=0; [ -f "$f" ] && { b="$(grep -cE "$ASSERT_ERE" "$f")" || true; }
  antes=$((antes + ${a:-0})); depois=$((depois + ${b:-0}))
done < <( { git ls-tree -r --name-only HEAD | grep -E "$TEST_ERE";
            git diff HEAD --name-only --diff-filter=A | grep -E "$TEST_ERE"; } | sort -u )
if [ "$depois" -lt "$antes" ]; then
  just=""
  [ -n "$id" ] && [ -f "$NODE_DIR/$id.md" ] && \
    just="$(grep -m1 'gate-asserts:' "$NODE_DIR/$id.md" || true)"
  if [ -n "$just" ]; then
    echo "GATE: asserts $antes → $depois com justificativa no nó: $just"
  else
    falhas+=("contagem de asserts caiu: $antes → $depois (sem gate-asserts: no nó da demanda)")
  fi
fi

# --- etapas de ferramenta: lint → typecheck → suíte ---
etapa() {
  local nome="$1" cmd="$2"
  if [ -z "$cmd" ]; then echo "GATE: $nome pulado (sem ferramenta na stack)"; return; fi
  echo "GATE: rodando $nome ($cmd)"
  bash -c "$cmd" || falhas+=("$nome falhou: $cmd")
}
etapa lint "$LINT_CMD"
etapa typecheck "$TYPECHECK_CMD"
etapa suite "$SUITE_CMD"

if [ "${#falhas[@]}" -eq 0 ]; then echo "GATE: passou"; exit 0; fi
echo "GATE: reprovado — ${#falhas[@]} motivo(s):"
printf '  - %s\n' "${falhas[@]}"
exit 1
```

<!-- Regras de preenchimento (skill memory, etapa gate):
1. Defaults saem da Constituição (como-rodar → SUITE_CMD; stack → LINT_CMD,
   TYPECHECK_CMD, TEST_ERE, SKIP_ERE, ASSERT_ERE) — não inventar ferramenta
   que o projeto não tem; sem lint/typecheck, deixar vazio (pulado + aviso).
2. Env GATE_* sobrepõe defaults — obrigatório manter: é o que permite testar
   o gate na suíte do próprio projeto sem recursão.
3. A anti-fraude acumula TODOS os motivos antes do exit 1 — não parar no
   primeiro.
4. O gate NÃO commita, NÃO marca checkbox, NÃO edita nó — só responde
   passou/não passou. Quem age sobre o veredito é a execute (ou o humano).
5. Registrar na Constituição: `gate: <comando>` ou `gate: recusado`.
   Recusado fica recusado — só reofertar se o humano pedir. -->
