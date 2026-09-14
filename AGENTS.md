# agent-config Agents Configuration

Last reviewed: 2026-09-13

## Project Context

- The user's global Claude Code and Codex setup. `install.ps1` puts it on a Windows machine.
  Agents manage this repo for the user. The repo is **public**.
- This file governs work on the repo. `codex/AGENTS.md` and `claude/CLAUDE.md` are content:
  the user's own global rules for each tool.
- The repo is live on the user's machine. `~/.claude/CLAUDE.md` imports `claude/CLAUDE.md`,
  and `shared/`, `claude/commands/`, and each custom skill folder are junctioned in. An edit
  reaches the user's next session before any commit.
- Critical paths: `install.ps1` and `lib/merge.ps1` rewrite the user's real settings files.

## Documentation Map

- Always read: `README.md` for layout and the guide index.
- Adding or changing a skill, plugin, setting, or how install behaves →
  `docs/2-making-changes.md`. Update it in the same change.
- Deciding whether something belongs in the repo → `docs/3-whats-synced.md`.

## Commands (Use Exactly)

Windows PowerShell 5.1, from the repo root.

- Tests: `Invoke-Pester .\tests`
  Pester is 3.4: write `Should Be`. The `Should -Be` form errors on this version.
- Drift check: `.\install.ps1 -Check`
  Changes nothing. Lists every difference between the repo and this machine, exits 1 on any.
  Report drift to the user and resolve only what they ask.
- Preview: `.\install.ps1 -WhatIf`
- Apply: `.\install.ps1`
  Rewrites the user's live config, backing up replaced files to `.backup\`. Run it when the
  user asks.

## Project Invariants

- **Public repo.** Commit only what anyone may read. Tokens, MCP server configs, machine
  paths, project names, and client details stay on the machine.
- **Two instruction files, on purpose.** `claude/CLAUDE.md` and `codex/AGENTS.md` hold mostly
  the same rules in different words, and the user chose to keep them separate. A rule change
  meant for both tools goes into both files in the same change.
- **Windows PowerShell 5.1 syntax.** Chain with `;` and `if ($?)`, and use `if/else` for
  conditionals. Write files as UTF-8 without BOM through `[IO.File]::WriteAllText`.
- **Links without admin.** File symlinks need admin rights, so folders use junctions,
  `~/.claude/CLAUDE.md` uses Claude's `@import`, and `~/.codex/AGENTS.md` is a copy with a
  header.
- **`skills.json` is hand-maintained** from the folders in `~/.agents/skills`. The skills
  CLI's `~/.agents/.skill-lock.json` still lists removed skills, so read the folders, not the
  lock. Agent ids: `claude-code`, `codex`.
- **Skills CLI is pinned** in `$SkillsCli` in `install.ps1`. After a bump, re-check that `add`
  still takes space-separated lists after `-s` and `-a`.
- **Plugins install before settings merge.** Installing a Claude plugin turns it on, and the
  shared `enabledPlugins` value must win.
- **Merge semantics** (`lib/merge.ps1`): the shared value wins, JSON objects merge per key,
  lists of plain values union with shared entries first, TOML merges per key within each
  table. Install only adds, so removals are manual on each machine. A change here starts with
  a failing test in `tests/merge.Tests.ps1`.
- **Codex plugin quirks.** Re-adding an installed plugin updates it in place and fails with
  "Access is denied" while Codex is open, so install skips plugins `codex plugin list` shows
  as installed. `superpowers@openai-curated` never appears in that list, so it is re-added
  each run. Marketplace detection assumes the marketplace name equals the repo name.
- **`.backup/` holds the user's replaced config files** and is gitignored. Clean with
  `git clean -fd`, since `-x` deletes it.

## Known Gaps

Open and unfixed. Ask the user before fixing one, and delete its line in the same change.

- A step that fails midway can leave a file moved to `.backup\` with nothing in its place
  until the next run.
- The TOML merge splits wrongly on a multi-line `"""` string containing a line that starts
  with `[`.
- `CLAUDE_CONFIG_DIR` and `CODEX_HOME` are ignored. Install always targets `~/.claude` and
  `~/.codex`.
- Model names in the shared settings depend on the user's accounts and plans.
- Every install reinstalls the disabled Claude plugins (`frontend-design`, `ponytail`) and
  rewrites `settings.json` with a new backup.

## Definition of Done

- `Invoke-Pester .\tests` passes, output shown.
- `.\install.ps1 -Check` run, output shown, any new drift explained.
- README and `docs/` updated wherever layout or behavior changed.
- Commit messages carry no co-author or generated-by trailer.
