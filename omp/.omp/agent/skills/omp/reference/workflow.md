# Workflows & Recipes

---

## Common Workflow Patterns

### Daily Interactive Session

```bash
omp                          # start interactive session
# work...
omp -c                       # resume after disconnect
```

### One-Shot Scripting

```bash
omp -p "find all TODO comments in src/"     # quick question
omp -p "summarise the last 10 commits"      # analysis
omp --mode json -p "list .ts files"         # structured output for piping
```

### Long Autonomous Run

```bash
/loop 20m                    # iterate for 20 minutes
/background                  # detach and let it cook
# later:
omp -c                       # reattach to see results
```

### Draft-Then-Execute for Complex Changes

```bash
/plan refactor src/importer.ts to stream rows
# iterate on the plan...
# approve (execute mode — planning context purged)
```

### Try an Alternative Approach

```bash
/fork                        # fork current session into new file
/model                       # swap to a different model
> redo this using streams    # prompt
# evaluate...
# if it works: /handoff and /share
# if not: omp -r → pick original
```

### Snapshot Before Risky Change

```bash
/tree                        # open navigator at current leaf
# highlight last user turn → Shift+L → label "pre-refactor"
> refactor the entire auth module      # risky work
# if it goes wrong:
/tree                        # filter to labeled, find "pre-refactor"
/branch                      # branch from bookmark
```

### Handoff to a Teammate

```bash
/compact Focus on the streaming bug
/handoff The importer now handles empty rows; next is the partial-flush test
/share                       # upload as gist
```

---

## Editor Escape Sequences

### Shell from Prompt

```bash
!git log --oneline -5       # show git log, include output in context
!!brew install postgresql   # run silently, exclude from context
```

### Python from Prompt

```bash
$import json; print(json.dumps(data, indent=2))   # run in shared Python kernel
$$import os; print(os.environ)                     # run silently, exclude from context
```

### File References

```
@src/main.ts                 # fuzzy-search, inlines content at send
@README.md                   # reference project docs
@path/to/config.ts           # direct path also works
```

---

## Plan Mode Recipes

### Architecture Review

```bash
/plan Review the src/ directory structure and suggest a module reorganisation
```

The planner reads the codebase, proposes a structure, and iterates on feedback. Approve when the plan is solid.

### Migration Planning

```bash
/plan Plan the migration from Express to Hono in the api/ directory
```

Planner checks all files that would need changes, proposes sequencing, and documents migration steps.

---

## Session Recovery

### Reattach After SSH Disconnect

```bash
ssh box
cd ~/work/api
omp -c          # streams the in-flight assistant turn from where it left off
```

### Retry After Context Overflow

```bash
/retry          # resubmits same user input; uses compacted context
```

Only works on a failed turn (429, context-length overflow, socket reset). Completed turns with bad answers should use a steering message or `/branch`.

### Ephemeral Side Question

```bash
/btw what does the regex on line 47 actually match?
```

The model sees current context but the exchange is not persisted — doesn't show in `/tree` and isn't part of memory consolidation.

---

## Force Mode Recipes

### Scaffold a New File

```bash
/force write src/config.ts           # model writes file, no "let me check first"
```

### Probe with a Specific Tool

```bash
/force grep "deprecated" src/        # force search, skip the planning preamble
```

### Dispatch a Subagent

```bash
/force task "analyze the parser module for security issues"
```

---

## MCP Management

```bash
/mcp list                       # show configured servers
/mcp add my-server npx -y @org/server
/mcp test my-server             # verify connectivity
/mcp smithery-search postgres   # find in registry
/mcp enable my-server
```

See `skill://omp/reference/extensibility.md` for detailed MCP authoring.
