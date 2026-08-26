#!/usr/bin/env bash
# memory-graphify/10,/12,/13,/15 — graphify-status classifica o estado do índice de código.
source "$(dirname "$0")/lib.sh"
gs="$ROOT/hooks/graphify-status"
d="$SP/proj"; mkdir -p "$d/graphify-out"
assert_eq "ausente"    "$(PATH=/usr/bin:/bin bash "$gs" "$d")" "/10 sem graphify no PATH"
command -v graphify >/dev/null || { echo "graphify não instalado — casos seguintes pulados"; report; exit; }
rm -f "$d/graphify-out/graph.json"
assert_eq "sem-indice" "$(bash "$gs" "$d")" "/15 graph.json ausente"
echo '{nao json' > "$d/graphify-out/graph.json"
assert_eq "sem-indice" "$(bash "$gs" "$d")" "/15 graph.json corrompido"
echo '{"nodes":[{"label":"README.md","file_type":"document"},{"label":"h","file_type":"document"}],"links":[]}' > "$d/graphify-out/graph.json"
assert_eq "sem-codigo" "$(bash "$gs" "$d")" "/13 só documentos"
echo '{"nodes":[{"label":"README.md","file_type":"document"},{"label":"login()","file_type":"code","source_file":"src/a.py"}],"links":[]}' > "$d/graphify-out/graph.json"
assert_eq "ativo"      "$(bash "$gs" "$d")" "/12 nó de código"
echo '{"nodes":[],"links":[]}' > "$d/graphify-out/graph.json"
assert_eq "sem-codigo" "$(bash "$gs" "$d")" "/13 índice vazio"
report
