#!/usr/bin/env bash
# Fixture do caso tdd: projeto-base + nó LIGHT `dobro` in-progress, com
# critérios e sem código — o run faz "execute de dobro".
. "$(dirname "${BASH_SOURCE[0]}")/../_lib/projeto-base.sh"

cat > docs/audora/memory/dobro.md <<'EOF'
---
id: dobro
estado: in-progress
origem: humano
depende-de: []
arquivos: []
keywords: [dobro, lib]
resumo: Função dobro na lib, com erro para argumento não numérico.
atualizado-em: 2026-10-09
---

# dobro

## objetivo

Acrescentar à `lib.sh` a função `dobro`, que imprime o dobro do número
recebido. Categoria: LIGHT (1 função, 1 arquivo de código).

## criterios-aceite

- **dobro/1** — QUANDO `dobro 4` é chamado O SISTEMA DEVE imprimir 8
- **dobro/2** — QUANDO o argumento não é numérico O SISTEMA DEVE imprimir
  "erro: não numérico" no stderr e sair 1

## fora-de-escopo

números decimais.

## decisoes

## delta

## e2e

pendente

## feedback-reprovacao
EOF

echo '- dobro | in-progress | Função dobro | Função dobro na lib, com erro para argumento não numérico. | dobro, lib | lib.sh' >> MEMORY.md

git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm fixture
