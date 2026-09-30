# audora-commander

**English** | [Português (Brasil)](README.pt-BR.md)

A Claude Code plugin: an AI-assisted software development framework guided by
5 principles:

1. **Dynamic Memory** — MEMORY.md is the product's living memory
   (requirements, decisions, learnings). A requirement that is not written
   down does not exist.
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
| `memory` | Creates and maintains MEMORY.md (bootstrap, nodes, deltas, learnings, compaction). Router: hot ops inline, the rest in `skills/memory/references/`, read one per operation. Hooks `memory-guard` and `memory-validate` check every write to the MEMORY |
| `scope` | The "What" phase: EARS criteria, [PRECISA-CLARIFICAR] marker, scope gate |
| `plan` | The just-in-time "How" phase: a plan file with self-sufficient tasks |
| `execute` | Red-green TDD with real evidence; commit per green step |
| `e2e` | Boots the project and exercises the demand end to end (optional, strongly recommended) |
| `validate` | Final human gate: evidence mapped 1:1 to criteria, MEMORY → PRD sync |
| `debug` | Debugging with demonstrated root cause (symptom mode) or defect hunting by classes (hunt mode) |
| `worktree` | On-demand isolation in a git worktree: lifecycle of one demand, fan-out of N agents, serial integration, human gate on removal |

Details per skill: [Skills in detail](#skills-in-detail).

## Skills in detail

### `audora-commander`

- **When it fires**: at the start of any software demand (create, change,
  fix, refactor) — the SessionStart hook points here.
- **What it does**: loads the context (skill `memory`: Constitution,
  Learnings and node index; no `MEMORY.md` → offers a bootstrap first);
  with 3 or more nodes `in-progress`, asks what to pause before taking a new
  one; classifies the demand with four binary risk questions — persisted
  data or migration? public API/contract? auth, security or payment?
  irreversible effect outside the repo? Any yes → HIGH; several files or new
  logic → MEDIUM; otherwise LIGHT. HOTFIX only when you declare it. Announces
  the category (you can correct it), registers the node and routes. Accepts
  "autopilot" / "roda até o validate" for LIGHT and MEDIUM (HIGH refuses).
  One-way ratchet: raises the category on its own mid-way, lowers it only
  with your approval. Oversized demands are split into smaller ones.
- **What it leaves on disk**: the node `docs/audora/memory/<id>.md`
  (`in-progress`) and its line in `MEMORY.md`; LIGHT/HOTFIX nodes already get
  numbered EARS criteria.
- **Human gates**: none of its own — you can correct the classification.
- **Next**: LIGHT/HOTFIX → `execute`; MEDIUM/HIGH → `scope`; no MEMORY →
  `memory` (bootstrap).

### `memory`

- **When it fires**: called by the other skills (load context, register a
  node, delta or learning), or directly by you.
- **What it does**: owns the MEMORY — the master index `MEMORY.md` (Purpose,
  Constitution, Learnings, one rich line per node) plus one file per node.
  Six operations: `carregar-contexto`, `bootstrap`, `registrar-no`,
  `registrar-delta`, `registrar-aprendizado`, `compactar`.
  Router: hot operations inline, the rest in
  `skills/memory/references/`, read one per operation. Selective reading
  (index + only the nodes the demand touches; grep for structural queries);
  whatever is already loaded in the session is not read again. The bootstrap
  offers to generate the mechanical gate — once; a refusal sticks. Hooks
  `memory-guard` (line ceilings) and `memory-validate` (schema, index ↔
  folder, enum, cycles, state in each node file) block broken writes.
- **What it leaves on disk**: `MEMORY.md`, `docs/audora/memory/<id>.md`,
  `docs/audora/decisoes-vivas.md`, archived nodes in `docs/audora/arquivo/`
  and, if accepted, the project's `gate` script.
- **Human gates**: generating the gate is your call; MEMORY merge conflicts
  outside the demand's own nodes are yours.
- **Next**: back to the phase that called it; invoked directly → offers to
  classify a demand.

### `scope`

- **When it fires**: MEDIUM/HIGH demand right after classification, or when
  a later phase reopens the scope.
- **What it does**: talks only about observable behavior (no files, no
  libraries). Asks in batches of up to 4 independent questions — dependent
  ones go in series, layout choices come with previews. A gap becomes
  `[PRECISA-CLARIFICAR: …]`, never a guess. Writes the objective, numbered
  EARS criteria (`<id>/<n>`, "WHEN … THE SYSTEM SHALL …", error and edge
  cases included) and an explicit out-of-scope, then self-reviews (no open
  marker, everything testable, no clash with the Constitution). Under
  autopilot it records whether every criterion is automatable.
- **What it leaves on disk**: MEDIUM → the three fields in the node; HIGH →
  a dedicated spec `docs/audora/specs/<id>-escopo.md`; one line per answered
  decision in the node.
- **Human gates**: the scope gate — waits for your explicit approval
  (skipped only under eligible autopilot, ratified at the final gate).
- **Next**: `plan`, after a STOP — you run `/clear` and type `plan de <id>`;
  saying "segue" runs it in a clean-context subagent instead.

### `plan`

- **When it fires**: after the scope is approved (MEDIUM/HIGH).
- **What it does**: two passes — locate and then read
  the files the plan will touch, listed in the
  header. A MEMORY vs code conflict stops and goes to you. Writes
  self-sufficient tasks: EARS criteria copied verbatim, relevant decisions,
  interfaces with exact signatures, exact paths, `depende-de`, and 2–5
  minute steps (red → verify → implement → green → commit). Steps carry the
  full TEST code, exact signatures and commands; implementation code only
  when it is not obvious (algorithm, regex, SQL, exact format). No
  placeholders. Complex tasks marked `expandir: sim` are detailed only when
  their turn comes.
- **What it leaves on disk**: `docs/audora/planos/plano-<id>.md`.
- **Human gates**: HIGH → plan gate; MEDIUM goes straight on.
- **Next**: `execute`, after a STOP (`execute de <id>`).

### `execute`

- **When it fires**: approved plan (MEDIUM/HIGH) or a LIGHT/HOTFIX demand
  ready for code.
- **What it does**: re-reads the plan and the node at the start of every
  session; the next task is the first one whose dependencies are done. Per
  task: RED — one minimal test
  citing `<id>/<n>`, seen failing for the right reason; GREEN — the minimum,
  with the whole suite green (or the Constitution's `gate:` exiting 0);
  REFACTOR; COMMIT citing the criterion. Tests must cover real integrations
  and error/edge paths. Micro-decisions go to the plan, learnings to the
  MEMORY on the spot. HOTFIX: reproduction test before the fix. Unknown
  failure → `debug`; dead end → node `blocked` and you decide. As a lap of
  the loop engine (`hooks/loop`) it does ONE task and never commits — the
  engine runs the gate, commits green laps and keeps red ones as patches.
- **What it leaves on disk**: code and tests, one commit per green step,
  the "Decisões tomadas pela IA" list in the plan.
- **Human gates**: none mid-way; you decide on a `blocked` node.
- **Next**: `validate`, which offers the e2e — after a STOP in MEDIUM/HIGH;
  LIGHT/HOTFIX go straight on.

### `e2e`

- **When it fires**: offered by `validate` once execution is green —
  optional, strongly recommended.
- **What it does**: boots the real product. docker compose is the default:
  it uses the project's compose or generates `docker-compose.e2e.yml` from
  the stack; without Docker it falls back to the Constitution's
  `como-rodar`. Waits for healthy and never tests on partial infra. Web →
  Playwright specs in `e2e/`; non-web → asks you which tool and records it
  in the Constitution. Every EARS criterion, error ones included, becomes an
  executed step with real evidence. Teardown always.
- **What it leaves on disk**: `docs/audora/e2e/e2e-<id>.md` (criterion →
  step → evidence → verdict); the compose and specs, versioned as
  accumulated regression.
- **Human gates**: running it is your call (a skip is recorded as
  `e2e: pulado-pelo-humano`); the non-web tool is your choice.
- **Next**: `validate` with the report; a failed criterion → `debug`.

### `validate`

- **When it fires**: execution (and e2e, if run) is finished.
- **What it does**: offers the e2e; demands 1:1 evidence per criterion — a
  command run now with its output, or an explicit item for human check;
  builds the validation script: behavior, test diff shown separately,
  autopilot premises, loop round report, proposed durable decisions (entry
  filter in `references/decisoes-vivas.md`), and for HIGH a per-file summary
  plus an adversarial review by a clean-context subagent. Irreversible
  effects outside the repo are never fired by the AI. After approval, when
  the work lands on main, runs the sync in `references/sync.md`: consolidate
  the delta, promote durable decisions and learnings, node → `delivered`,
  `git mv` to the archive, `arquivos:` from the real diff, summary promoted
  to `PRD.md`. LIGHT closes through the short path in
  `references/fechamento-light.md`. A missing reference keeps the gate and
  skips the sync.
- **What it leaves on disk**: archived node
  `docs/audora/arquivo/AAAA-MM-DD-<id>.md`, archived plan,
  `docs/audora/decisoes-vivas.md`, updated `PRD.md`.
- **Human gates**: the final gate — never anticipated, in every category
  (approve, reject or approve in part).
- **Next**: none — the demand ends; a new one starts at `audora-commander`.

### `debug`

- **When it fires**: a bug, a test failing for an unknown reason,
  unexpected behavior or a failed e2e criterion; with no symptom at all, as
  a defect hunt.
- **What it does**: symptom mode — deterministic reproduction (ideally a
  failing test), full evidence (whole error, the failing
  path, recent diff), one hypothesis at a time tested by the cheapest
  distinguishing experiment, a root cause that explains every symptom, fix
  via TDD. Three refuted hypotheses → stops and escalates to you. Hunt mode
  — sweeps defect classes (cross references, contracts and schemas, living
  docs and counts, error edges, configuration and execution) and verifies
  every finding before reporting it.
- **What it leaves on disk**: a permanent reproduction test; hunt reports in
  `docs/audora/depuracao/cacada-<AAAA-MM-DD>.md`; deltas and learnings in the
  MEMORY.
- **Human gates**: escalation after 3 refuted hypotheses; in hunt mode,
  which improvements become nodes is up to you.
- **Next**: `execute` (fix via TDD), `validate`, or your decision.

### `worktree`

- **When it fires**: only when you explicitly ask to isolate a demand, list
  worktrees, fan out agents, integrate or clean up — never on its own.
- **What it does**: isolates a demand with the harness's native worktree
  (`EnterWorktree` / `ExitWorktree`), named after the node id; prepares the
  environment (ignored files via `.worktreeinclude`, dependencies, a warning
  that git hooks are shared — never copies secrets silently); lists every
  worktree with path, branch, node, clean? and unintegrated commits; fans out
  N agents over non-overlapping file domains, created and integrated one at
  a time; before removal checks dirty, unintegrated and ignored files and
  junctions pointing outside.
- **What it leaves on disk**: `.claude/worktrees/<id>/` and a branch per
  demand; path and branch recorded in the node.
- **Human gates**: discarding a worktree that still has work
  (`discard_changes`) is always yours; orphan cleanup is offered, never run.
- **Next**: the phase the demand needed (`execute`, or `scope`/`plan`);
  integrated work → `validate`.

## Usage flow (example: a MEDIUM demand)

1. You ask: "add a date filter to the orders list".
2. `audora-commander` classifies it: MEDIUM (new logic; no data/auth/contract).
3. `scope` asks what is missing, closes the EARS criteria, you approve (gate).
4. `plan` reads the current code the demand touches and generates `docs/audora/planos/plano-<id>.md`.
5. `execute` implements via TDD, committing at each green step.
6. `validate` offers `e2e` (recommended): the project boots, the criteria are
   exercised for real, and a report lands in `docs/audora/e2e/`.
7. Final gate: a validation script with evidence per criterion. You approve;
   the MEMORY syncs (decisions, learnings, archive) and PRD.md receives the
   summary.

## Reducing permission prompts

Permission prompts (Bash, Edit, Write) come from the Claude Code harness, not
from this framework — reducing them does not remove any human gate. Three
options, from safest to riskiest:

| Option | What it does | Risk |
|---|---|---|
| `permissions.allow` in `.claude/settings.json` | Allowlists specific tools and commands; everything else still prompts | **Low** — scoped to what you list |
| `claude --permission-mode acceptEdits` | File edits stop prompting; Bash still asks | **Medium** — the agent can rewrite any file in the project |
| `claude --permission-mode bypassPermissions` | Nothing prompts | **High** — only in a sandbox or a disposable worktree, never with production credentials in the environment |

Loop-engineering warning: a rule written in the prompt is a request;
the real block is permission plus sandbox. Configure the harness — don't
rely on prose to stop the agent.

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

## Development

This repository uses its own framework (dogfooding): see `MEMORY.md`,
`docs/audora/planos/` and the spec in `docs/specs/`. Regression suite:
`bash tests/run.sh` (pure bash, fixtures in `mktemp -d`).
