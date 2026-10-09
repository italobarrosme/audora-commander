#!/usr/bin/env bash
# Fixture do caso porta: só o projeto-base com MEMORY, commitado.
. "$(dirname "${BASH_SOURCE[0]}")/../_lib/projeto-base.sh"
git init -q && git add -A && git -c user.name=eval -c user.email=eval@local commit -qm fixture
