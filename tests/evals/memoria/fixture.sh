#!/usr/bin/env bash
# Fixture do caso memoria: projeto-base + uma `dobro` que recusa negativo
# (a demanda do prompt é aceitar), commitado.
. "$(dirname "${BASH_SOURCE[0]}")/../_lib/projeto-base.sh"

cat >> lib.sh <<'EOF'

# dobro <n> — imprime 2n; só aceita inteiro não negativo
dobro() {
  [[ "$1" =~ ^[0-9]+$ ]] || { echo "erro: não numérico ou negativo" >&2; return 1; }
  echo $(( $1 * 2 ))
}
EOF

cat > tests/test-dobro.sh <<'EOF'
#!/usr/bin/env bash
source "$(dirname "$0")/../lib.sh"
[ "$(dobro 4)" = 8 ] || { echo "dobro 4 deveria ser 8"; exit 1; }
dobro abc 2>/dev/null && { echo "dobro abc deveria falhar"; exit 1; }
exit 0
EOF

git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm fixture
