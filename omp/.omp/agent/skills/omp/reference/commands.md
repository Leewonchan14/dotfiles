# Slash Commands Reference

Type `/` inside the editor to open completion menus. Skills appear as `/skill:<name>`. Custom command templates expand under their own `/<template>` name.

---

## Top 10 Commands

| Command | What it does |
|---|---|
| `/plan [prompt]` | Toggle plan mode; agent drafts before executing |
| `/model` | Open model selector; pick a role and provider |
| `/compact [focus]` | Manually summarise older context |
| `/tree` | In-place session navigator; jump to any prior message |
| `/branch` | Start a new thread from a previous message (same file) |
| `/extensions` | Extension Control Center for skills, hooks, custom tools, MCP, plugins |
| `/agents` | Agent Control Center; spawn, observe, steer subagents |
| `/login` | OAuth into a provider; `/logout` revokes |
| `/share` | Render session and upload (custom handler, then gist fallback) |
| `/handoff [focus]` | Write structured wrap-up and end turn |

---

## Full Command Tables

### Session

| Command | Description |
|---|---|
| `/session [info\|delete]` | Show session info or delete current session |
| `/resume` | Open session picker |
| `/new` | Start a fresh session |
| `/drop` | Delete current session and start a new one |
| `/rename <title>` | Rename current session |
| `/move <path>` | Move session to different working directory |
| `/tree` | Navigate session tree (switch branches) |
| `/branch` | Branch from a previous message (same file, new leaf) |
| `/fork` | Fork from a previous message into a new file |
| `/compact [focus]` | Manually compact session context |
| `/handoff [focus]` | Write structured wrap-up and end turn |
| `/btw <question>` | Ephemeral side question using current context |
| `/retry` | Retry last failed agent turn |
| `/background` (`/bg`) | Detach UI and continue running in background |
| `/export [path]` | Export session to HTML |
| `/dump` | Copy session transcript to clipboard |
| `/share` | Upload session (custom handler, then secret gist) |
| `/copy [last\|code\|all\|cmd]` | Copy agent message / code blocks / command |
| `/goal <subcommand>` | Persistent autonomous objective |
| `/todo <subcommand>` | View/edit todo list |

### Model

| Command | Description |
|---|---|
| `/model` (`/models`) | Open model selector |
| `/fast [on\|off\|status]` | Toggle OpenAI service-tier fast mode |
| `/loop [count\|duration]` | Toggle loop mode |
| `/force <tool> [prompt]` | Force next turn to use a specific tool |
| `/browser [headless\|visible]` | Toggle browser headless/visible mode |

### Plan

| Command | Description |
|---|---|
| `/plan [prompt]` | Toggle plan mode; routes next prompt to plan-role model |

### Extensions

| Command | Description |
|---|---|
| `/mcp <subcommand>` | Manage MCP servers (add, list, remove, test, reauth, enable, disable, smithery-search, reconnect, reload, resources, prompts, notifications) |
| `/ssh <subcommand>` | Manage SSH hosts (add, list, remove) |
| `/memory <subcommand>` | Inspect, clear, rebuild memory (view, clear/reset, enqueue/rebuild, mm list\|show\|refresh\|history\|seed\|delete\|reload) |
| `/marketplace <subcommand>` | Manage marketplace sources and plugins (add, remove, update, list, discover, install, uninstall, installed, upgrade) |
| `/plugins [list\|enable\|disable]` | View and manage installed plugins |
| `/reload-plugins` | Reload skills, commands, hooks, tools, agents, and MCP |

### Info

| Command | Description |
|---|---|
| `/usage` | Provider usage and rate-limit headroom |
| `/context` | Token-budget breakdown for current turn |
| `/jobs` | Async background jobs status |
| `/tools` | Tools currently visible to the agent |
| `/extensions` (`/status`) | Extension Control Center dashboard |
| `/agents` | Agent Control Center dashboard |
| `/debug` | Debug tools selector |
| `/changelog [full]` | Show changelog entries |
| `/hotkeys` | Live keyboard-shortcut list |

### Misc

| Command | Description |
|---|---|
| `/settings` | Open settings menu |
| `/login` / `/logout` | OAuth login / revoke |
| `/exit` (`/quit`) | Exit interactive mode |

---

## Custom Slash Commands

Any markdown file under `~/.omp/agent/commands/<name>.md` (user) or `<cwd>/.omp/commands/<name>.md` (project) becomes `/<name>`.

```markdown
---
description: Code-review a file or diff
argument-hint: <path-or-diff>
---
Review the following for correctness, edge cases, and style:

$@
```

- `$@` — all arguments
- `$1`, `$2` — positional
- `$@[1:2]` — slice
- `$ARGUMENTS` — raw string

Supports TypeScript handler API for programmatic templates. See `skill://omp/reference/extensibility.md` for authoring details.
