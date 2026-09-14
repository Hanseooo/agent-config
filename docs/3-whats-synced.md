# 3. What's synced

## Synced

| What | How it gets onto a machine |
|---|---|
| Claude global instructions | `~\.claude\CLAUDE.md` imports `claude/CLAUDE.md` |
| Codex global instructions | `codex/AGENTS.md` is copied to `~\.codex\AGENTS.md` |
| Custom skills and commands | Folder links (junctions) into `~\.claude` and `~\.codex` |
| `project-init.md` shared procedure | `~\.agent-shared` links to `shared/` |
| Third-party skills | Installed fresh from their GitHub source, listed in `skills.json` |
| Plugins and marketplaces | Installed with the `claude` and `codex` CLIs, listed in `plugins.json` |
| Model, effort, permissions, status line, theme, plugin on/off | Merged from the `*.shared.*` files |

Third-party skills and plugins install at their **latest** version, not a pinned one.

## Not synced, on purpose

| What | Why |
|---|---|
| Logins (`.credentials.json`, `auth.json`, `secrets\`) | Secrets never go in git. Log in on each machine. |
| History, sessions, logs, caches, sqlite files | Personal and large. Useless on another machine. |
| Codex `[projects.*]` trust and `[hooks.state]` | Paths and hashes that only match one machine. |
| Hooks (`herdr-agent-state.ps1`) | Kept local to this machine. |
| MCP servers (figma, node_repl) | Hold tokens and machine paths. Add per machine. |
| Codex bundled plugins (browser, documents, etc.) | Ship with the Codex app itself. |
| Codex `notify` | Points at a folder that differs per install. |

## Why links and not copies

Links mean an edit in the repo is live on that machine immediately, and `git status`
shows it. A copy would let the machine and the repo drift apart silently.

Windows needs admin rights for file symlinks, so the installer uses folder junctions,
which don't. Single files (`CLAUDE.md`, `AGENTS.md`) use an import or a copy instead.
