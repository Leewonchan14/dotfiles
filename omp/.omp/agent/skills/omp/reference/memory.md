# Memory & Compaction

Knowledge that carries across sessions. Two mechanisms: compaction (in-session) and memory (cross-session).

---

## When Each Fires

| Mechanism | Scope | What triggers it | What the model sees |
|---|---|---|---|
| Compaction | Single session | Context overflow, threshold maintenance after turn, or manual `/compact` | Summary entry in place of older turns + recent tail verbatim |
| Local memory | One project (cwd) | Startup, or `/memory enqueue` | Static Memory Guidance block in system prompt |
| Hindsight | Global/project/tagged | First-turn auto-recall + on-demand retain/recall/reflect tools | Growing remote bank agent can write to and query |

---

## Compaction

Summarises older messages on the active branch when the window fills up. The file on disk is untouched — `/tree` still walks back into pre-compaction history.

```bash
/compact                          # manual compaction
/compact Focus on the API changes # biased summary
```

### Plan Mode Context Effects

| Approval path | What happens |
|---|---|
| Approve and execute | Planning discussion purged from context |
| Approve and keep context | Full planning history stays |
| Approve and compact context | Planning summarised into one entry |

---

## Memory Backends

Selected via `memory.backend` in `config.yml`.

### Off (default)

Nothing extracted, nothing injected.

### Local Backend

Past sessions for the current project are summarised into a compact memory document and injected into the system prompt as a **Memory Guidance** block at session start. Isolated per project (working directory), stored under `~/.omp/agent/memories/`.

```bash
/memory view            # show current injection payload
/memory clear           # delete all memory and artifacts for this project
/memory enqueue         # force consolidation at next startup
```

Agent-readable `memory://` URLs:

```
read memory://root                    # static guidance block in system prompt
read memory://root/MEMORY.md          # full long-term memory document
read memory://root/skills/<name>/SKILL.md  # generated skill playbook
```

### Hindsight Backend

Opt-in remote backend (Cloud or self-hosted). Surfaces three tools to the agent:
- **retain** — stores a durable fact
- **recall** — searches prior memories
- **reflect** — synthesises an answer across many memories

Auto-recall fires on the first turn of every session. Subagents reuse the parent's bank.

```yaml
# ~/.omp/agent/config.yml
memory:
  backend: hindsight
hindsight:
  apiUrl: https://api.hindsight.vectorize.io
  apiToken: hs_live_REPLACE_ME
  bankId: my-team-bank          # optional; auto-allocated when omitted
  scoping: per-project-tagged   # global | per-project | per-project-tagged
```

#### Scoping

| Value | Layout |
|---|---|
| `global` | One shared bank across every project |
| `per-project` | Separate bank per working directory |
| `per-project-tagged` (default) | One shared bank with `project:<cwd>` tags |

Use `per-project-tagged` when global facts and project-scoped facts should merge on recall. Switch to `per-project` when projects must not see each other's memories (e.g. client work under NDA).

#### Self-hosted

```yaml
hindsight:
  apiUrl: http://hindsight.internal:8888
  apiToken: REPLACE_ME
  bankId: null          # per-project bucket allocated on first use
  scoping: per-project
```

---

## Mental Models

Long-running curated summaries (user preferences, project conventions, architectural decisions) seeded once per bank and refreshed after consolidations. Spliced into the system prompt as a `<mental_models>` block.

| Subcommand | What it does |
|---|---|
| `/memory mm list` | List mental models in active bank |
| `/memory mm show <id>` | Print one model's text |
| `/memory mm refresh [id]` | Re-synthesise from current memories |
| `/memory mm history <id>` | View revision history as line diff |
| `/memory mm seed` | Create built-in mental models missing on this bank |
| `/memory mm delete <id>` | Remove a mental model |
| `/memory mm reload` | Re-pull cached `<mental_models>` block |

---

## Privacy & Storage

| What | Where |
|---|---|
| Session transcripts | `~/.omp/agent/sessions/<cwd-hash>/` (local by default) |
| Local memory | `~/.omp/agent/memories/<cwd-hash>/MEMORY.md` + SQLite index |
| Hindsight data | External bank at `hindsight.apiUrl` (config + bank id on your machine) |

Only retain payloads and recall/reflect queries go to Hindsight. The stored session transcript has retain calls, recall responses, and `<mental_models>` blocks stripped out — curated memory never re-feeds the bank as conversation noise.

### Recipes

| Scenario | Commands |
|---|---|
| Rebuild local memory after refactor | `/memory clear` → `/memory enqueue` |
| Seed mental models on fresh bank | `/memory mm seed` → `/memory mm list` |
| Switch local → Hindsight | `/memory clear`, set `memory.backend: hindsight`, restart |

### Auditing

```bash
omp -p 'read memory://root'               # injected payload
omp -p 'read memory://root/MEMORY.md'     # long-term document
```
