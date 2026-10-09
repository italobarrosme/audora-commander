#!/usr/bin/env bash
# Projeto-base das fixtures de eval: um projeto bash mínimo COM MEMORY, criado
# no diretório corrente (workspace vazio). NÃO commita — o fixture.sh de cada
# caso faz `source` deste arquivo, acrescenta o específico e commita.
# O MEMORY nasce aqui por heredoc: nenhum MEMORY.md real mora dentro do repo
# do plugin (hooks e cleanup não o enxergam).
_tpl="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../templates" && pwd)"

mkdir -p docs/audora/memory tests

cat > MEMORY.md <<'EOF'
memory-schema: 1

# MEMORY — calc

> Memória do produto: o que ele faz, regras inegociáveis, o que aprendemos e
> o estado de cada demanda. Requisito não escrito aqui é requisito que não
> existe. Este arquivo é o ÍNDICE MESTRE; o corpo de cada nó vive em
> `docs/audora/memory/<id>.md`.

## Propósito [carga: sempre]

Biblioteca de cálculo em bash (`lib.sh`) para scripts de linha de comando de
um time pequeno: funções aritméticas simples, com erro claro em entrada
inválida.

## Constituição [carga: sempre]

- **stack**: bash (sem dependências externas)
- **restricoes**: só bash e coreutils; nada de python, node ou bc
- **padroes**: uma função por operação em `lib.sh`; cada função tem teste em
  `tests/test-<função>.sh`; erro vai para o stderr com exit 1
- **como-rodar**: `bash tests/run.sh` (suíte; exit 1 se algum teste falha)
- **gate**: recusado

## Aprendizados [carga: sempre]

Aprendizados vivem em `docs/audora/aprendizados.md` (1 linha cada, só por grep — skill memory, registrar-aprendizado).

## Índice de nós [carga: sempre]

Uma linha rica por nó. Formato:
`- <id> | <estado> | <título curto> | <resumo 1 frase> | <keywords> | <arquivos-chave>`

EOF

cp "$_tpl/aprendizados-template.md" docs/audora/aprendizados.md

cat > lib.sh <<'EOF'
#!/usr/bin/env bash
# Biblioteca de cálculo. Uso: source lib.sh

# soma <a> <b> — imprime a + b
soma() {
  echo $(( $1 + $2 ))
}
EOF

cat > tests/run.sh <<'EOF'
#!/usr/bin/env bash
# Roda todos os tests/test-*.sh. Exit 1 se algum falha.
cd "$(dirname "$0")/.." || exit 1
falhas=0
for t in tests/test-*.sh; do
  if bash "$t"; then echo "ok: $t"; else echo "FALHOU: $t"; falhas=$((falhas+1)); fi
done
echo "$falhas teste(s) falhando"
[ "$falhas" -eq 0 ]
EOF

cat > tests/test-soma.sh <<'EOF'
#!/usr/bin/env bash
source "$(dirname "$0")/../lib.sh"
[ "$(soma 2 3)" = 5 ] || { echo "soma 2 3 deveria ser 5"; exit 1; }
EOF
