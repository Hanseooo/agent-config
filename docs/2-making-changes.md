# 2. Make a change

Rule of thumb: **edit the repo, never the files in `~\.claude` or `~\.codex`.**
Then commit, push, and on each other machine run `git pull` and `.\install.ps1`.

Not sure what a machine changed on its own? Run `.\install.ps1 -Check` first. It lists every
difference from the repo and changes nothing.

Jump to what you're changing:

- [Global instructions](#global-instructions)
- [Your own skills and commands](#your-own-skills-and-commands)
- [Third-party skills](#third-party-skills)
- [Plugins](#plugins)
- [Settings](#settings)

## Global instructions

| Tool | Edit | Takes effect |
|---|---|---|
| Claude Code | `claude/CLAUDE.md` | Next session. `~\.claude\CLAUDE.md` only imports this file. |
| Codex | `codex/AGENTS.md` | After you re-run `.\install.ps1`. Codex can't import, so it gets a copy. |

## Your own skills and commands

Edit files in `claude/skills/`, `claude/commands/`, `codex/skills/`, or `shared/`.
The tools read these folders through links, so edits apply right away.

**Adding a new skill folder?** Re-run `.\install.ps1` so it gets linked.
New command files in `claude/commands/` need nothing, the whole folder is linked.

## Third-party skills

**Add one:**

```powershell
npx skills add owner/repo -g -s skill-name -a claude-code codex
```

Then add it to `skills.json` so other machines get it. Use `-a codex` alone for a
Codex-only skill, and match that in `skills.json`. Forgot one? `.\install.ps1 -Check` lists
installed skills missing from `skills.json`.

**Remove one:**

```powershell
npx skills remove skill-name -g
```

Then delete it from `skills.json`. The installer only adds skills, so run the remove
command on each machine too.

## Plugins

1. Add the plugin (and its marketplace, if new) to `plugins.json`.
2. Turn it on or off in `claude/settings.shared.json` (`enabledPlugins`) or
   `codex/config.shared.toml` (`[plugins."name@marketplace"]`).
3. Re-run `.\install.ps1`.

## Settings

Edit `claude/settings.shared.json` or `codex/config.shared.toml`, then re-run the installer.

- A value here wins over the machine's value for the same setting.
- Nested settings merge one key at a time, and lists like `permissions.allow` combine. A
  permission you allowed on one machine stays on that machine.
- Settings only on the machine are left alone.
- **Deleting a key or list entry here does not delete it on machines.** Remove it there by
  hand.

Put only settings every machine should share here. Paths, project trust, and hooks stay
local. See [3. What's synced](3-whats-synced.md).

## Changed `lib/merge.ps1`?

Run the tests:

```powershell
Invoke-Pester .\tests
```
