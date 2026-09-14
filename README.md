# agent-config

My global Claude Code and Codex setup: instructions, custom skills, third-party skills,
plugins, and shared settings. One script puts it on any Windows machine.

## Quickstart

Already have Git, GitHub CLI, Node.js, Claude Code, and Codex installed and logged in?

```powershell
gh repo clone Hanseooo/agent-config $HOME\agent-config
cd $HOME\agent-config
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Restart Claude Code and Codex. That's it.

Missing a tool, or first time? Start with guide 1.

## Guides

Read only the one you need.

| Guide | Read it when |
|---|---|
| [1. Set up a new machine](docs/1-new-machine.md) | You're on a machine that doesn't have this yet |
| [2. Make a change](docs/2-making-changes.md) | You want to edit instructions, add a skill, or change a setting |
| [3. What's synced](docs/3-whats-synced.md) | Something didn't carry over and you want to know why |
| [4. Troubleshooting](docs/4-troubleshooting.md) | The installer printed a warning or something looks wrong |

## What's in here

```
AGENTS.md                 rules for agents working on this repo (CLAUDE.md imports it)
claude/
  CLAUDE.md               global instructions for Claude Code
  commands/               slash commands (/project-init)
  skills/                 Claude-only custom skills (feature-workflow)
  settings.shared.json    the parts of settings.json every machine should share
codex/
  AGENTS.md               global instructions for Codex
  skills/                 Codex-only custom skills (project-init)
  config.shared.toml      the parts of config.toml every machine should share
shared/                   files both tools read (project-init.md)
skills.json               third-party skills to install, and for which tool
plugins.json              plugins and marketplaces to install
install.ps1               the installer
lib/, tests/              settings-merge code and its tests
```
