# audora-commander

**English** | [Português (Brasil)](README.pt-BR.md)

A Claude Code plugin: an AI-assisted software development framework guided by
5 principles:

1. **Dynamic Map** — GRAFO.md is the product's living memory; a requirement
   that is not written down does not exist.
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

Installed in a project, the plugin adds 8 chained skills — from risk
classification of the demand to the final validation gate — that keep a
living map of the product (`GRAFO.md`), turn scope into a written artifact
before any code, and demand real evidence (tests actually run, e2e actually
exercised) before anything is considered complete.

Target audience: solo devs or small teams building web/mobile/api with Claude
Code, who want process rigor without the bureaucracy of a heavy process.

Full foundations: [docs/fundamentos.md](docs/fundamentos.md) (in Portuguese).

## Prerequisites

- Claude Code CLI installed (the `claude` command available on PATH).
- Git, to clone the repository. On Windows, use
  [Git for Windows](https://git-scm.com/download/win) — it provides the bash
  used by the installer and by the plugin's hooks.

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

## The 8 skills

| Skill | Role |
|---|---|
| `audora-commander` | Entry point: classifies the demand by risk (LIGHT/MEDIUM/HIGH/HOTFIX) and routes it |
| `graph` | Creates and maintains GRAFO.md (bootstrap, nodes, deltas, compaction) |
| `scope` | The "What" phase: EARS criteria, [PRECISA-CLARIFICAR] marker, scope gate |
| `plan` | The just-in-time "How" phase: a plan file with self-sufficient tasks |
| `execute` | Red-green TDD with real evidence; commit per green step |
| `e2e` | Boots the project and exercises the demand end to end (optional, strongly recommended) |
| `validate` | Final human gate: evidence mapped 1:1 to criteria, GRAFO → PRD sync |
| `debug` | Debugging with demonstrated root cause (symptom mode) or defect hunting by classes (hunt mode) |

## Usage flow (example: a MEDIUM demand)

1. You ask: "add a date filter to the orders list".
2. `audora-commander` classifies it: MEDIUM (new logic; no data/auth/contract).
3. `scope` asks what is missing, closes the EARS criteria, you approve (gate).
4. `plan` reads the current code and generates `docs/audora/planos/plano-<id>.md`.
5. `execute` implements via TDD, committing at each green step.
6. `validate` offers `e2e` (recommended): the project boots, the criteria are
   exercised for real, and a report lands in `docs/audora/e2e/`.
7. Final gate: a validation script with evidence per criterion. You approve;
   the GRAFO syncs and PRD.md receives the summary.

## Artifacts in projects using the framework

- `GRAFO.md` — project root: master index of the living memory (schema v2).
- `docs/audora/nos/` — one file per node (requirements, numbered EARS
  criteria, decisions, delta).
- `docs/audora/decisoes-vivas.md` — durable decisions promoted from
  delivered nodes.
- `docs/audora/arquivo/` — delivered nodes, archived by move.
- `docs/audora/planos/` — active plans; `arquivo/` for closed ones.
- `docs/audora/e2e/` — E2E reports per demand.
- `docs/audora/specs/` — scope specs for HIGH demands.
- `docs/audora/depuracao/` — defect hunt reports (debug skill).

Projects on schema v1 (single-file GRAFO.md + GRAFO-ARQUIVO.md) remain fully
supported — schema migration happens on touch, never as a forced big bang.
Node states, however, are converted in full on the first write (see
"Renamed in 0.3.0").

## Installation validation checklist

Run in the interactive session after installing:

- [ ] 1. WHEN the marketplace is added and the plugin installed, Claude Code
  MUST list the 8 skills with the `audora-commander:` prefix (check the
  session's skill listing).
- [ ] 2. WHEN a new session starts, the context MUST contain the
  "Framework audora-commander ativo" pointer (ask Claude what the hook
  injected).
- [ ] 3. WHEN the `audora-commander` skill is invoked in a project without
  GRAFO.md, it MUST offer a bootstrap instead of stalling or inventing
  content.
- [ ] 4. WHEN each skill is invoked in isolation, it MUST load without errors
  and without placeholders.
- [ ] 5. WHEN a LIGHT and a MEDIUM demand are simulated in a sample project,
  the flow MUST produce the expected artifacts (node in the GRAFO; plan file
  for the MEDIUM; validation script).

## Renamed in 0.3.0 (breaking)

Commands, risk categories and node states are now in English. The old
command names no longer exist (no aliases). Existing GRAFOs are migrated in
full by the `graph` skill on the first write in each project — until then,
`grafo-validate` reports "fora do enum" (state outside the EN enum).
`docs/fundamentos.md` still
uses the pre-0.3.0 names.

| Command (before) | Command (after) |
|---|---|
| grafo | `graph` |
| escopo | `scope` |
| plano | `plan` |
| executar | `execute` |
| validar | `validate` |
| depurar | `debug` |
| audora-commander, e2e | unchanged |

| Risk category (before) | After |
|---|---|
| LEVE / MÉDIA / ALTA / HOTFIX | LIGHT / MEDIUM / HIGH / HOTFIX |

| Node state (before) | After |
|---|---|
| planejada | `planned` |
| em-curso | `in-progress` |
| bloqueada | `blocked` |
| entregue | `delivered` |
| descartada | `discarded` |
| hotfix-pendente-registro | `hotfix-pending-record` |

## Development

This repository uses its own framework (dogfooding): see `GRAFO.md`,
`docs/audora/planos/` and the spec in `docs/specs/`.
