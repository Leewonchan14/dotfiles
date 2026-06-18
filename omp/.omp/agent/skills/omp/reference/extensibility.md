# Extensibility

Skills, MCP, plugins, extensions, hooks, prompt templates, custom tools, and subagent authoring.

---

## Skills — Authoring

Skills are Markdown playbooks under a named directory. Only the frontmatter `description` stays in the system prompt. The body loads when the model matches the current task against that description, or when invoked with `/skill:<name>`.

### Layout

```
~/.omp/agent/skills/<name>/SKILL.md      # global
.omp/skills/<name>/SKILL.md              # project
~/.claude/skills/, .claude/skills/       # also discovered
~/.codex/skills/,  .codex/skills/        # also discovered
```

One skill per directory, directly under `skills/`. Sibling files inside the skill directory are addressable as `skill://<name>/path/to/file.md`.

### Frontmatter

| Field | Required | Effect |
|---|---|---|
| `name` | Yes | Identifier for `/skill:<name>` and `skill://<name>` URL |
| `description` | Yes | The only part the model sees until the skill loads. Specific verbs + nouns + scope. |
| `condition` | No | Optional extra trigger hint when description alone is too broad |

### Writing Good Descriptions

The model picks skills the same way it picks tools: by matching the task against the description text.

```
BAD:  "HELPS WITH DATABASE STUFF."
Good: "Writing, reviewing, or optimizing Postgres queries, schemas, or configs."
BAD:  "TESTS."
Good: "Adding or extending Vitest tests for the importer module; covers fixtures, snapshot tests, and integration setup."
```

### Scoping & Disabling

| Flag / Setting | Effect |
|---|---|
| `--skills <p1,p2,…>` | Comma-separated glob patterns; only matching skills kept |
| `--no-skills` | Disable skill discovery entirely for this run |
| `skills.enabled: false` | Same, persisted in config.yml |
| `ignoredSkills: [name, …]` | Block individual skills by name |
| `includeSkills: [name, …]` | Allowlist — only these load |
| `skills.enableSkillCommands: false` | Disable `/skill:<name>` invocations while keeping discovery on |

Run `omp -p '/extensions'` to see which skills loaded and from where.

---

## MCP (Model Context Protocol)

### Server Config

MCP servers configured in `~/.omp/agent/mcp.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-name"],
      "env": { "API_KEY": "..." }
    }
  }
}
```

### MCP Slash Commands

| Command | What it does |
|---|---|
| `/mcp add <name> <command> [args...]` | Add a new MCP server |
| `/mcp list` | List configured servers |
| `/mcp remove <name>` | Remove a server |
| `/mcp test <name>` | Test server connectivity |
| `/mcp enable <name>` | Enable a server |
| `/mcp disable <name>` | Disable a server |
| `/mcp reconnect <name>` | Reconnect |
| `/mcp reload` | Reload all servers |
| `/mcp resources [name]` | List server resources |
| `/mcp prompts [name]` | List server prompts |
| `/mcp smithery-search <query>` | Search Smithery registry |
| `/mcp smithery-login` | Log into Smithery |
| `/mcp smithery-logout` | Log out of Smithery |
| `/mcp reauth <name>` | Re-authenticate server |
| `/mcp unauth <name>` | Remove stored auth |
| `/mcp notifications [on\|off]` | Toggle notifications |

### Authoring MCP Servers

MCP servers expose tools, resources, and prompts to the agent. Standard `@modelcontextprotocol/server-*` packages or custom implementations. The agent discovers available tools from connected servers.

---

## Plugins

### Plugin Sources

Plugins load from two sources in `settings.json`:

```json
{
  "packages": [
    "npm:omp-subagents",
    "git:github.com/leblancfg/omp-ansi-themes"
  ]
}
```

- `npm:<package>` — installed under `~/.omp/agent/npm/`
- `git:<url>` — cloned under `~/.omp/agent/git/<host>/<owner>/<repo>/`

### Selective Extension Loading

```json
{
  "source": "npm:omp-superpowers-plus",
  "extensions": [
    "extensions/plan-tracker.ts",
    "extensions/workflow-monitor.ts",
    "!extensions/subagent/index.ts"
  ]
}
```

`!` prefix excludes an extension from loading.

### Plugin Management Commands

| Command | What it does |
|---|---|
| `/plugins [list\|enable\|disable]` | View and manage installed plugins |
| `/marketplace add <name> <source> [type]` | Add a marketplace source |
| `/marketplace remove <name>` | Remove a source |
| `/marketplace update [name]` | Update source(s) |
| `/marketplace list` | List sources |
| `/marketplace discover` | Discover available plugins |
| `/marketplace install <pkg>` | Install a plugin |
| `/marketplace uninstall <pkg>` | Uninstall a plugin |
| `/marketplace installed` | List installed plugins |
| `/marketplace upgrade` | Upgrade all plugins |
| `/reload-plugins` | Reload skills, commands, hooks, tools, agents, and MCP |

---

## Prompt Templates

Any markdown file under `~/.omp/agent/commands/<name>.md` (user) or `<cwd>/.omp/commands/<name>.md` (project) becomes `/<name>`:

```markdown
---
description: Code-review a file or diff
argument-hint: <path-or-diff>
---
Review the following for correctness, edge cases, and style:

$@
```

### Template Variables

| Variable | What it expands to |
|---|---|
| `$@` | All arguments |
| `$1`, `$2`, … | Positional arguments |
| `$@[1:2]` | Slice of arguments |
| `$ARGUMENTS` | Raw argument string |

Supports TypeScript handler API for programmatic templates.

---

## Custom Tools

TypeScript extensions at `~/.omp/agent/extensions/*.ts` can register custom tools visible to the agent. Explicit paths listed under `extensions` in `config.yml`.

---

## Authoring Subagents

Subagents are defined in extension code or through the `/agents` UI. They:
- Run in their own turn with a separate model
- Can communicate with the parent and sibling agents via IRC
- Support parallel task execution

Configure subagent models in `config.yml` or override per-call. Managed via `/agents` dashboard.

---

## Hooks

Hooks fire on session lifecycle events. Drop a TypeScript file at `~/.omp/agent/hooks/`:

| Hook | When it fires |
|---|---|
| `onStartup` | Session starts |
| `onTurn` | After each turn completes |
| `onRender` | Before UI renders |
| `onShutdown` | Session ends |

---

## Context Files

Files discovered from the project root or `~/.omp/` that inject context:

- `AGENTS.md`, `CLAUDE.md`, `.cursorrules`
- `.claude/`, `.codex/`, `.windsurfrules` directories

```bash
--context-files <glob>     # scope discovery to a pattern
--no-context-files         # disable entirely
ignoredContextFilePatterns # in config.yml to exclude
```

Agent-readable via `context://` URLs: `read context://AGENTS.md`.

---

## Custom Share Handler

See `skill://omp/reference/sessions.md` for the custom share handler API.
