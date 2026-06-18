# Interactive Session & Editor

---

## Anatomy of an Interactive Session

Bare `omp` opens an interactive TUI with four regions:

1. **Header** — omp logo (first launch), then compact session header: title, branch, mode banners (plan/loop/background)
2. **Messages** — user prompts, assistant turns, tool-call cards. `Ctrl+O` expands/collapses tool output
3. **Editor** — multi-line input with file references, path completion, image paste, shell escapes, external editor
4. **Footer** — working directory, git branch, token counters, cost, context usage, active model

---

## Editor Features

| Feature | Trigger | What it does |
|---|---|---|
| File reference | `@` | Fuzzy-search project files (respects .gitignore). Inlines content at send. |
| Path completion | `Tab` | Completes relative paths, `../`, `~/` |
| Multi-line | `Shift+Enter` / `Alt+Enter` | Newline (Win: `Ctrl+Enter`) |
| Image attach | `Ctrl+V`, drag-and-drop, `@image.png` | Paste/drop images. Model must accept image input. |
| Shell escape (visible) | `!` | Execute as shell, include output in context. `Escape` cancels. |
| Shell escape (hidden) | `!!` | Execute as shell, exclude output from context. |
| Python escape | `$` / `$$` | Run in shared Python kernel. `$$` hides output. |
| External editor | `Ctrl+G` | Open draft in `$VISUAL` / `$EDITOR` |
| Prompt actions | `#` | Opens prompt-actions menu over current draft |

---

## Message Queue

Type while the agent is working — nothing is dropped.

| Chord | Lane | Delivered |
|---|---|---|
| `Enter` | Steering message | After current turn finishes tool calls. Course-correct in flight. |
| `Alt+Enter` | Follow-up | After agent finishes all queued work and yields. "And then this". |
| `Escape` | — | Aborts active turn. Queued messages restored to editor. |
| `Alt+Up` | — | Dequeue most recent queued message back into editor. |

### Configuration

```yaml
# ~/.omp/agent/config.yml
steeringMode:  one-at-a-time   # or: all
followUpMode:  one-at-a-time   # or: all
interruptMode: immediate       # or: wait
```

---

## Keybindings

### Editor — Navigation

| Key | Action |
|---|---|
| Arrow keys | Move cursor; up on empty editor browses history |
| `Option+←/→` | Move by word |
| `Ctrl+A` / `Home` / `Cmd+←` | Start of line |
| `Ctrl+E` / `End` / `Cmd+→` | End of line |

### Editor — Editing

| Key | Action |
|---|---|
| `Enter` | Send (queue as steering while agent works) |
| `Shift+Enter` / `Alt+Enter` | Newline |
| `Ctrl+Enter` | Queue as follow-up message |
| `Ctrl+W` / `Option+Backspace` | Delete word backwards |
| `Ctrl+U` | Delete to start of line |
| `Ctrl+K` | Delete to end of line |
| `Alt+Shift+L` | Copy current line |
| `Alt+Shift+C` | Copy whole prompt |
| `Ctrl+G` | Edit draft in `$VISUAL` / `$EDITOR` |
| `Alt+Up` | Dequeue queued message back into editor |

### Editor — Control

| Key | Action |
|---|---|
| `Tab` | Path completion / accept autocomplete |
| `Escape` | Cancel autocomplete / interrupt active turn |
| `Ctrl+C` | Clear editor (first press) / exit (second press) |
| `Ctrl+D` | Exit (when editor is empty) |
| `Ctrl+Z` | Suspend to background; `fg` resumes |
| `Ctrl+R` | Search prompt history |
| `Ctrl+O` | Toggle tool-output expansion (+ filter cycle in `/tree`) |
| `Ctrl+T` | Toggle thinking-block visibility |
| `Alt+H` | Toggle speech-to-text recording |
| `Shift+Tab` | Cycle thinking level |

### Models

| Key | Action |
|---|---|
| `Ctrl+P` | Cycle role models forward (slow / default / smol) |
| `Shift+Ctrl+P` | Cycle role models backward |
| `Alt+P` | Pick model temporarily for this session |
| `Ctrl+L` | Open model selector (sets roles) |
| `Alt+Shift+P` | Toggle plan mode |

### Dashboard Navigators

`/tree`, `/extensions`, and `/agents` share a common navigator:

| Key | Action |
|---|---|
| `Tab` / `Shift+Tab` | Cycle tabs |
| `Up/Down` or `j/k` | Move highlight |
| `Space` | Toggle selected item |
| `Enter` | Open inspector / save edit |
| `N` | New-agent flow in `/agents` |
| `R` | Regenerate during new-agent flow |
| `Ctrl+R` | Reload from disk (`/agents`) |

### Customizing Keybindings

Remaps live in `~/.omp/agent/keybindings.json` (separate from `config.yml`):

```json
{
  "app.model.cycleForward": "ctrl+p",
  "app.plan.toggle": "alt+shift+p",
  "app.clipboard.copyPrompt": ["alt+shift+c", "ctrl+shift+c"]
}
```

Action IDs are namespaced (e.g. `app.model.cycleForward`, `tui.editor.undo`). Run `/hotkeys` inside a session to see all available actions and their current chords. Chord notation: lowercase, `+`-joined (`ctrl+p`, `alt+shift+p`, `alt+up`).

Legacy short names from older configs are auto-migrated on load.
