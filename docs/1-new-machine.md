# 1. Set up a new machine

About 15 minutes. Windows only.

## Step 1: Install the tools

Open PowerShell and install what's missing:

```powershell
winget install Git.Git
winget install GitHub.cli
winget install OpenJS.NodeJS.LTS
```

Then install **Claude Code** and **Codex** with their official installers:

- Claude Code: https://docs.claude.com/en/docs/claude-code/setup
- Codex: https://developers.openai.com/codex

And the Claude status line:

```powershell
npm install -g ccstatusline
```

Close and reopen PowerShell so the new commands are found.

## Step 2: Log in

The installer never logs in for you. Do each of these yourself:

```powershell
gh auth login      # GitHub, needed to clone this private repo
claude             # opens Claude Code, follow the login prompt, then exit
codex login        # Codex
```

## Step 3: Clone this repo

```powershell
gh repo clone Hanseooo/agent-config $HOME\agent-config
cd $HOME\agent-config
```

Keep it at `$HOME\agent-config`. Other folders work, but that's the tested path.

## Step 4: Preview, then install

See what would change, without changing anything:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -WhatIf
```

Looks right? Run it:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Anything it replaces is moved to `.backup\<date-time>\` first, so nothing is lost.

## Step 5: Check it worked

Restart Claude Code and Codex, then:

- In Claude Code, type `/project-init`. It should show up in the command list.
- In Codex, type `$project-init`. It should show up too.

Warnings at the end of the install? See [4. Troubleshooting](4-troubleshooting.md).
