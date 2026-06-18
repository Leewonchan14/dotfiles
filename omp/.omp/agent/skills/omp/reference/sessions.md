# Sessions

Sessions are append-only trees on disk under `~/.omp/agent/sessions/<cwd-hash>/`. Every turn is a node with a parent pointer. Session IDs are Snowflake-style hex (time-sortable; a 6-char prefix like `1f9d2a` is enough to identify one).

---

## Resume

```bash
omp -c                       # continue most recent in this cwd
omp -r                       # open picker scoped to this project
omp -r 1f9d2a                # resume by id prefix
omp --resume ./session.jsonl # resume explicit file
omp --no-session             # ephemeral; nothing on disk
```

`-c` prefers a per-terminal breadcrumb (split panes and tmux windows don't conflict).  

`--fork <id|path>` resumes a session into a brand-new file with a `parentSession` lineage marker, leaving the original untouched:

```bash
omp --fork 1f9d2a             # fork by id prefix
omp --fork ./session.jsonl    # fork from explicit file
```

`--no-session` runs ephemerally: nothing persisted, `/fork`, `/export`, `/share` disabled.

---

## Tree Navigation (`/tree`)

Moves the leaf pointer to any earlier message in the current file. No new file, no fork.

```
● 1f9d2a  user      "rewrite the importer to stream"
└─● 1f9d2b  assistant tool: read src/importer.ts
  ├─● 1f9d2c  assistant edit src/importer.ts          ← current leaf
  │ └─● 1f9d2d  user      "add a test for the stream path"
  └─● 1f9d2e  assistant edit src/importer.ts (alt)    ← branch B
    └─◆ 1f9d2f  [labeled: pre-refactor checkpoint]
```

- Type to fuzzy-search across messages
- `←`/`→` page through results
- `Ctrl+O` cycles filter: default → no-tools → user-only → labeled-only → all
- `Shift+L` labels the highlighted entry (survives compaction)

---

## Branch vs Fork

| Action | What happens | File | When to use |
|---|---|---|---|
| `/branch` | New thread from a previous message, same id space, new leaf | Same `.jsonl` file | Canonical record of an exploration |
| `/fork` | Clone history into new file with `parentSession` marker | New `.jsonl` file | Alternative that might be abandoned |

```bash
/branch                       # message selector opens; pick where to branch
/fork                         # pick a message; opens a new file
```

---

## Session Commands

| Command | What it does |
|---|---|
| `/session [info\|delete]` | Print id, path, parent lineage, stats / delete current file |
| `/resume` | Open session picker for current project |
| `/new` | Start a fresh session without touching current one |
| `/drop` | Delete current session and start a new one |
| `/rename <title>` | Set the human label shown in pickers |
| `/move <path>` | Rebind session to a different working directory |

---

## Compact (`/compact [focus]`)

Summarises the older half of the active branch into a single summary entry. Recent turns stay verbatim. Pass a focus to bias the summary:

```bash
/compact Focus on the API changes
```

The file on disk is untouched — `/tree` still walks back into pre-compaction history. Auto-triggered on context overflow.

---

## Export

```bash
/export [path]            # renders session to HTML, opens in browser
omp --export <session.jsonl> [output]  # headless batch render
/dump                     # copies plaintext transcript to clipboard
/copy [last|code|all|cmd] # targeted slices: last agent message / code block(s) / command
```

---

## Share

`/share` exports to a temp HTML, then runs a custom share handler at `~/.omp/agent/share.{ts,js,mjs}` if one exists. With no handler it falls back to a secret GitHub gist via `gh`.

### Custom Share Handler

```typescript
// ~/.omp/agent/share.ts
export type CustomShareFn = (
  htmlPath: string,
) => Promise<{ url?: string; message?: string } | string | undefined>;
```

Return a string or `{ url }` — omp opens it and copies to clipboard.  
Return `undefined` — omp assumes your handler did its own UX.

```typescript
// Example: upload to S3
import { execFileSync } from "node:child_process";
import { basename } from "node:path";

const BUCKET = "s3://my-team-omp-shares";
const PUBLIC_BASE = "https://shares.my-team.dev";

export default async function share(htmlPath: string) {
  const key = `${Date.now()}-${basename(htmlPath)}`;
  execFileSync("aws", ["s3", "cp", htmlPath, `${BUCKET}/${key}`, "--acl", "public-read"], {
    stdio: "inherit",
  });
  return { url: `${PUBLIC_BASE}/${key}`, message: `Uploaded ${key} (${BUCKET})` };
}
```

---

## Handoff (`/handoff [focus]`)

Writes a structured wrap-up summarising state, open threads, and next steps. The receiver reads that entry first and knows where you left off without scrolling the full transcript.

Three transport options:

| Transport | How |
|---|---|
| Gist (default) | `/share` renders to HTML, uploads as secret gist via `gh` |
| Custom handler | Drop default export at `~/.omp/agent/share.{ts,js,mjs}` |
| Raw JSONL | Send `~/.omp/agent/sessions/<cwd-hash>/<id>.jsonl` directly |

For editable hand-offs send the JSONL file. HTML is for read-only review.

---

## Recipes

### Reattach after disconnect

```bash
ssh box
cd ~/work/api
omp -c          # streams in-flight assistant turn from where it left off
```

### Snapshot before a refactor

```bash
/tree                       # navigator at current leaf
# highlight last user turn, press Shift+L
> pre-refactor              # label the bookmark
# Esc back to prompt; do risky work.
# Later:
/tree                       # filter to labeled-only, find "pre-refactor"
/branch                     # branches from bookmark, original timeline preserved
```

### Fork to try a different approach

```bash
/fork                       # pick last user turn; new file
/model                      # switch to model to evaluate
> redo this using streams instead of buffers
# If it works:  /handoff and /share the new file.
# If it doesn't: omp -r → pick original session, keep going.
```

### Force focused compact before handoff

```bash
/compact Focus on the importer streaming bug and the fix in src/importer.ts
/handoff The streaming importer now copes with empty rows; remaining work
  is the test for the partial-flush path.
```
