# Run Modes

Four slash commands that change how the next turn (or every turn) runs: `/loop`, `/background`, `/force`, `/fast`. They compose — `/loop` + `/background` is the standard "let it cook overnight" recipe.

---

## Loop Mode — `/loop [count|duration]`

Re-submits the same prompt after every yield automatically, until a limit hits or you cancel it.

```bash
/loop            # unlimited; runs until you cancel
/loop 10         # cap at 10 iterations
/loop 30m        # wall-clock cap (30 minutes)
/loop 2h         # wall-clock cap (2 hours)
```

Accepted units: `s`, `m`/`min`, `h`/`hr`, and their plurals. Mixing forms (`/loop 10 5m`) is rejected.  
`Escape` cancels current iteration without disabling loop mode.  
Running `/loop` again disables it. Duration form ends on its own when deadline passes.

---

## Background Mode — `/background` / `/bg`

Detaches the TUI from a running session. The session process stays alive; the terminal is freed.

```bash
/background      # detach (only works while a turn is streaming)
omp -c           # reattach from any shell
```

Only works while a turn is actively streaming. Interactive tools switch to non-UI mode; loaders and status line stop. When the run ends, omp posts a desktop notification and shuts down.

Peek at background sessions with `/jobs` from another live session. Pairs naturally with `/loop` for long autonomous runs.

---

## Force Mode — `/force <tool> [prompt]`

Pins the next turn to a specific tool. Scope is exactly one turn.

```bash
/force write src/server/auth.ts: stub a JWT verifier
/force task                       # pins next message you send
```

If you provide a prompt after the tool name, it's submitted in the same turn. With just `/force <tool>`, the pin attaches to whatever you type next. `/force:<tool>` also accepted.

Use when the model keeps reaching for the wrong tool: calling `edit` on a file that doesn't exist, refusing `write` on a fresh scaffold, talking instead of dispatching a subagent.

---

## Fast Mode — `/fast [on|off|status]`

Toggles OpenAI's `service_tier: "priority"` on outgoing requests.

```bash
/fast            # toggle
/fast on
/fast off
/fast status
```

On supported OpenAI models, priority traffic routes ahead of default-tier at higher per-token cost. Session-persisted (survives reloads via `service_tier_change` log entries). Shows as a badge in the status line. On non-OpenAI providers the flag is silently dropped.

---

## Plan Mode — `/plan [prompt]`

Routes the next prompt to a plan-role model with read-only tool access (no `edit`, `write`, `bash`). Nothing touches code until you approve. Toggle with `/plan`, `Alt+Shift+P`, or by passing the initial goal inline:

```bash
/plan refactor src/importer.ts to stream rows instead of buffering
```

### The Plan Loop

1. **State the goal** — plan-mode banner appears at top of editor
2. **Iterate** — planner drafts; you reply with corrections (read-only tools still available)
3. **Approve** — planner calls `resolve` with `action: "apply"`

### Approval Choices on Exit

| Option | What happens |
|---|---|
| Approve and execute | Planning discussion purged; fresh execution starting with the plan |
| Approve and keep context | Full planning history stays in transcript |
| Approve and compact context | Planning summarised into one entry; execution continues |
| Escape | Cancel; return to plan-mode iteration |

### Plan-Role Model

Override per-run with `--plan <model-id>`, per-shell with `PI_PLAN_MODEL`, or persistently with `modelRoles.plan` in `config.yml`.

### When to Reach for It

- Changes touching more than one file
- Refactors with non-obvious sequencing
- Designs the planner should justify before implementing

Skip for one-file edits and trivial changes. Pairs naturally with session branching: plan on a side branch, throw away if design doesn't land.

---

## Goal Mode — `/goal <subcommand>`

Persistent autonomous objective that pairs with `/loop`. Subcommands: `set`, `show`, `pause`, `resume`, `drop`, `budget`. The agent works toward the goal across turns without needing the prompt re-sent.

---

## Which Mode for Which Goal

| Goal | Recipe |
|---|---|
| Same prompt against a queue until a check passes | `/loop` with count or duration cap |
| Long run you walk away from | `/loop` first, then `/background`; reattach with `omp -c` |
| Model keeps picking the wrong tool | `/force <tool>` for one turn |
| Latency-critical on OpenAI | `/fast on`, accept the higher cost |
| Draft-before-execute for harder changes | `/plan` |
