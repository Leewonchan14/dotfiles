---
name: omp
description: Using, configuring, and extending omp (Oh My Pi) — the coding agent for the terminal. Covers installation, authentication, interactive usage, slash commands, sessions, plan mode, memory, MCP, and extensibility.
condition: User asks about omp, Oh My Pi, pi-coding-agent, coding agent setup or usage.
---

# omp — Oh My Pi

omp is a Rust-based coding agent for the terminal: subagents, plan mode, LSP, DAP, hindsight memory, hashline edits, and time-traveling rules.

For detailed reference content, see the `skill://omp/reference/` files listed below.

---

## Quick Reference

| Topic | Reference |
|---|---|
| Installation & authentication | `skill://omp/reference/installation.md` |
| Interactive session, editor, keybindings | `skill://omp/reference/interactive.md` |
| Slash commands reference | `skill://omp/reference/commands.md` |
| Run modes (/loop, /background, /force, /fast, plan mode, goal mode) | `skill://omp/reference/run-modes.md` |
| Session management, tree, branch/fork, export, share, handoff | `skill://omp/reference/sessions.md` |
| config.yml, model roles, themes | `skill://omp/reference/configuration.md` |
| Providers, authentication methods, credential resolution | `skill://omp/reference/providers.md` |
| Memory (local, Hindsight), compaction, mental models | `skill://omp/reference/memory.md` |
| Common workflows & recipes | `skill://omp/reference/workflow.md` |
| Skills authoring, MCP, plugins, extensions, hooks, prompt templates | `skill://omp/reference/extensibility.md` |
| CLI flags, environment variables | `skill://omp/reference/configuration.md` |


## Official Documentation

| Topic | Official Link |
|---|---|
| Overview & Quickstart | <https://omp.sh/docs/quickstart> |
| Using omp (editor, message queue, modes) | <https://omp.sh/docs/using> |
| Slash commands | <https://omp.sh/docs/slash> |
| Keybindings | <https://omp.sh/docs/keybindings> |
| Settings (config.yml) | <https://omp.sh/docs/settings> |
| Run modes | <https://omp.sh/docs/run-modes> |
| Sessions & session tree | <https://omp.sh/docs/sessions> |
| Memory & compaction | <https://omp.sh/docs/memory> |
| Plan mode | <https://omp.sh/docs/plan-mode> |
| Goal mode | <https://omp.sh/docs/goal-mode> |
| Handoff | <https://omp.sh/docs/handoff> |
| Working with files | <https://omp.sh/docs/files> |
| Code intelligence (LSP) | <https://omp.sh/docs/code-intelligence> |
| Debugging (DAP) | <https://omp.sh/docs/debugging> |
| Structural edits | <https://omp.sh/docs/structural-edits> |
| Subagents & IRC | <https://omp.sh/docs/subagents> |
| Web & browser | <https://omp.sh/docs/web> |
| GitHub | <https://omp.sh/docs/github> |
| Providers & authentication | <https://omp.sh/docs/providers> |
| Model roles | <https://omp.sh/docs/model-roles> |
| Custom models & providers | <https://omp.sh/docs/custom-models> |
| Context files | <https://omp.sh/docs/context-files> |
| Skills | <https://omp.sh/docs/skills> |
| Prompt templates | <https://omp.sh/docs/prompt-templates> |
| Hooks | <https://omp.sh/docs/hooks> |
| Custom tools | <https://omp.sh/docs/custom-tools> |
| Authoring subagents | <https://omp.sh/docs/authoring-subagents> |
| MCP | <https://omp.sh/docs/mcp> |
| Authoring MCP servers | <https://omp.sh/docs/authoring-mcp> |
| Themes | <https://omp.sh/docs/themes> |
| TTSR rules | <https://omp.sh/docs/ttsr> |
| Plugins | <https://omp.sh/docs/plugins> |
| Authoring extensions | <https://omp.sh/docs/extensions> |
| Marketplaces | <https://omp.sh/docs/marketplaces> |
| SDK | <https://omp.sh/docs/sdk> |
| RPC mode | <https://omp.sh/docs/rpc> |
| ACP | <https://omp.sh/docs/acp> |
| CLI reference | <https://omp.sh/docs/cli> |
| Environment variables | <https://omp.sh/docs/environment-variables> |
| Secrets and auth | <https://omp.sh/docs/secrets> |
| Session format | <https://omp.sh/docs/session-format> |
| Tools index | <https://omp.sh/docs/tools> |

---

## Key Architecture

```
~/.omp/agent/
├── config.yml              # Persistent settings (YAML)
├── keybindings.json         # Keybinding remaps
├── agent.db                 # Credentials (OAuth tokens, API keys)
├── skills/                  # On-demand skill playbooks
│   └── omp/SKILL.md         # ← this file
├── sessions/<cwd-hash>/     # Session JSONL files
├── memories/<cwd-hash>/     # Local memory artifacts
├── extensions/*.ts          # Custom TypeScript extensions
├── commands/*.md            # Custom slash command templates
├── share.{ts,js,mjs}        # Custom share handler
└── mcp.json                 # MCP server configuration
```

### Precedence (highest → lowest)

1. CLI flag (`--slow`, `--no-pty`, `--api-key`)
2. Environment variable (`PI_SLOW_MODEL`, `ANTHROPIC_API_KEY`)
3. `~/.omp/agent/config.yml`
4. Built-in default

### Credential Resolution

1. `--api-key` runtime override
2. Stored API key in `agent.db` (round-robins across multiple keys)
3. Stored OAuth credential in `agent.db` (refreshed on demand)
4. Provider env var (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, etc.)
5. `apiKey` field in `models.yml`

---

## Quickstart Snippets

```bash
# Install
curl -fsSL https://raw.githubusercontent.com/can1357/oh-my-pi/main/scripts/install.sh | sh

# Authenticate
export ANTHROPIC_API_KEY=sk-ant-...
omp

# First prompt
summarise src/main.ts

# One-shot mode
omp -p "list .ts files in src/"

# Continue last session
omp -c

# Resume by id prefix
omp -r 1f9d2a
```
