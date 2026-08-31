# audora-commander

**English** | [Português (Brasil)](README.pt-BR.md)

A Claude Code plugin: an AI-assisted software development framework guided by
5 principles:

1. **Dynamic Memory** — MEMORY.md is the product's living memory
   (requirements, decisions, learnings); Graphify indexes the code
   underneath. A requirement that is not written down does not exist.
2. **Just-in-Time Planning** — a plan is born by reading the current code,
   covers one demand, and dies after it.
3. **"What" separated from "How"** — scope is closed in a written artifact
   before any code.
4. **Process proportional to risk** — LIGHT, MEDIUM, HIGH and HOTFIX
   demands pay different ceremonies; approval gates never scale down.
5. **AI executes, human decides** — explicit gates, fresh evidence before any
   "done".

## What it's for

`audora-commander` turns Claude Code into a guided development process, not
just a powerful autocomplete. It attacks a common problem of coding with AI
without structure: requirements lost between conversations, plans that become
code without anyone approving the scope first, and "done" that nobody
actually verified.

Installed in a project, the plugin adds 9 chained skills — from risk
classification of the demand to the final validation gate — that keep a
living memory of the product (`MEMORY.md`), turn scope into a written
artifact before any code, and demand real evidence (tests actually run, e2e
actually exercised) before anything is considered complete.

Target audience: solo devs or small teams building web/mobile/api with Claude
Code, who want process rigor without the bureaucracy of a heavy process.

Full foundations: [docs/fundamentos.md](docs/fundamentos.md) (in Portuguese).

## Prerequisites

- Claude Code CLI installed (the `claude` command available on PATH).
- Git, to clone the repository. On Windows, use
  [Git for Windows](https://git-scm.com/download/win) — it provides the bash
  used by the installer and by the plugin's hooks.
- Optional but recommended:
  [Graphify](https://github.com/safishamsi/graphify)
  (`uv tool install graphifyy`, Python 3.10+) — a local code graph, no API
  key. The `memory` skill offers to install it on the first demand and
  degrades to grep/Read if you decline.

## Installation

### Option A — install script (recommended)

Clone the repository and run the installer from inside the cloned folder:

```bash
git clone https://github.com/italobarrosme/audora-commander.git
cd audora-commander
./install.sh
```

On Windows, without opening Git Bash manually, you can run `install.cmd`
directly (it finds Git Bash by itself and delegates to `install.sh`):

```
install.cmd
```

The script adds this folder as a local marketplace (`audora-commander-dev`)
and installs the `audora-commander` plugin, all through the non-interactive
CLI — no need to open a Claude Code session first. Running it again after it
is already installed is safe (idempotent).

### Option B — manual (interactive Claude Code session)

```bash
claude
```

Inside the session:

```
/plugin marketplace add <folder-where-you-cloned-the-repo>
/plugin install audora-commander@audora-commander-dev
```

### After installing

Restart the session (or run `/clear`) — the SessionStart hook starts
injecting the framework pointer. Then run the "Installation validation
checklist" further down in this README.

## The 9 skills

| Skill | Role |
|---|---|
| `audora-commander` | Entry point: classifies the demand by risk (LIGHT/MEDIUM/HIGH/HOTFIX) and routes it |
| `memory` | Creates and maintains MEMORY.md (bootstrap, nodes, deltas, learnings, compaction) and drives Graphify: install offer, code graph, `consultar-codigo` for plan/debug/execute. Router: hot ops inline, the rest in `skills/memory/references/`, read one per operation |
| `scope` | The "What" phase: EARS criteria, [PRECISA-CLARIFICAR] marker, scope gate |
| `plan` | The just-in-time "How" phase: a plan file with self-sufficient tasks |
| `execute` | Red-green TDD with real evidence; commit per green step |
| `e2e` | Boots the project and exercises the demand end to end (optional, strongly recommended) |
| `validate` | Final human gate: evidence mapped 1:1 to criteria, MEMORY → PRD sync |
| `debug` | Debugging with demonstrated root cause (symptom mode) or defect hunting by classes (hunt mode) |
| `worktree` | On-demand isolation in a git worktree: lifecycle of one demand, fan-out of N agents, serial integration, human gate on removal |

## Usage flow (example: a MEDIUM demand)

1. You ask: "add a date filter to the orders list".
2. `audora-commander` classifies it: MEDIUM (new logic; no data/auth/contract).
3. `scope` asks what is missing, closes the EARS criteria, you approve (gate).
4. `plan` queries the code graph (Graphify), reads only the files it points
   to, and generates `docs/audora/planos/plano-<id>.md`.
5. `execute` implements via TDD, committing at each green step.
6. `validate` offers `e2e` (recommended): the project boots, the criteria are
   exercised for real, and a report lands in `docs/audora/e2e/`.
7. Final gate: a validation script with evidence per criterion. You approve;
   the MEMORY syncs (decisions, learnings, archive) and PRD.md receives the
   summary.

## Artifacts in projects using the framework

- `MEMORY.md` — project root: master index of the living memory (purpose,
  constitution, learnings, one rich line per node).
- `docs/audora/memory/` — one file per node (requirements, numbered EARS
  criteria, decisions, delta).
- `docs/audora/decisoes-vivas.md` — durable decisions promoted from
  delivered nodes.
- `docs/audora/arquivo/` — delivered nodes, archived by move.
- `docs/audora/planos/` — active plans; `arquivo/` for closed ones.
- `docs/audora/e2e/` — E2E reports per demand.
- `docs/audora/specs/` — scope specs for HIGH demands.
- `docs/audora/depuracao/` — defect hunt reports (debug skill).
- `graphify-out/` — the Graphify code graph (gitignored, regenerable with
  `graphify update .`; a post-commit hook keeps it fresh).

## Installation validation checklist

Run in the interactive session after installing:

- [ ] 1. WHEN the marketplace is added and the plugin installed, Claude Code
  MUST list the 9 skills with the `audora-commander:` prefix (check the
  session's skill listing).
- [ ] 2. WHEN a new session starts, the context MUST contain the
  "Framework audora-commander ativo" pointer (ask Claude what the hook
  injected).
- [ ] 3. WHEN the `audora-commander` skill is invoked in a project without
  MEMORY.md, it MUST offer a bootstrap instead of stalling or inventing
  content.
- [ ] 4. WHEN each skill is invoked in isolation, it MUST load without errors
  and without placeholders.
- [ ] 5. WHEN a LIGHT and a MEDIUM demand are simulated in a sample project,
  the flow MUST produce the expected artifacts (node in the MEMORY; plan file
  for the MEDIUM; validation script).

## Renamed in 0.4.0 (breaking)

The product memory is now called MEMORY, and Graphify indexes the code
underneath it. No migration: a project that still has the old memory file
gets a warning from the entry point and a fresh bootstrap — what to do with
the old file is up to you.

| Before | After |
|---|---|
| `graph` skill | `memory` skill |
| `GRAFO.md` | `MEMORY.md` (line 1: `memory-schema: 1`; new `## Aprendizados` section) |
| `docs/audora/nos/` | `docs/audora/memory/` |
| `GRAFO-ARQUIVO.md` | dropped — history lives in `docs/audora/arquivo/` |
| hooks `grafo-guard`, `grafo-validate` | `memory-guard`, `memory-validate` |
| schema v1 / v2, PT→EN state migration | gone — single schema, EN states only |

0.3.0 already moved commands, risk categories and node states to English
(`scope`, `plan`, `execute`, `validate`, `debug`; LIGHT/MEDIUM/HIGH/HOTFIX;
`planned | in-progress | blocked | delivered | discarded`) — see the git
history for the old names. `docs/fundamentos.md` still uses pre-0.3.0 names.

## Development

This repository uses its own framework (dogfooding): see `MEMORY.md`,
`docs/audora/planos/` and the spec in `docs/specs/`. Regression suite:
`bash tests/run.sh` (pure bash, fixtures in `mktemp -d`).
