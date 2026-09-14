# 4. Troubleshooting

Find the message you saw.

## "running scripts is disabled on this system"

Windows blocks `.ps1` files by default. Run it this way instead:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

## "claude not found" / "codex not found" / "npx not found"

The tool isn't installed, or PowerShell was open before you installed it.
Install it ([guide 1](1-new-machine.md)), open a new PowerShell window, and re-run.

## "ccstatusline not found"

```powershell
npm install -g ccstatusline
```

## "skills add ... failed" or "plugin install ... failed"

Usually the network, or GitHub rate limits. Scroll up to the command's own error, then
re-run the installer. It skips what's already done.

If one skill keeps failing, its source repo may have renamed or removed it. Check the repo
on GitHub and update `skills.json`.

## "codex plugin add ... failed" with "Access is denied (os error 5)"

Codex is open and has the plugin's files in use. Close the Codex app and every Codex
terminal, then re-run the installer.

## A skill or command doesn't show up

1. Restart the tool. Neither reloads skills mid-session.
2. Check the link exists:
   ```powershell
   Get-Item $HOME\.claude\skills\feature-workflow | Select-Object LinkType, Target
   ```
   No `Junction`? Re-run `.\install.ps1`.

## Claude ignores my instructions

Open `~\.claude\CLAUDE.md`. It should be one line, like `@~/agent-config/claude/CLAUDE.md`.
If the repo moved, re-run the installer from the new folder to rewrite that line.

## I need something the installer replaced

It's in `.backup\<date-time>\`, at the same path it had under your home folder. Copy back
what you need.

## Undo everything

1. Delete the links: `~\.agent-shared`, `~\.claude\commands`, and the custom skill folders
   under `~\.claude\skills` and `~\.codex\skills`. Deleting a junction doesn't touch the repo.
2. Copy your files back from the oldest folder in `.backup\`.
