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

## A skill doesn't show up

1. Restart the tool. Neither reloads skills mid-session.
2. Check it's installed:
   ```powershell
   Get-Item $HOME\.agents\skills\project-init
   ```
   Missing? Re-run `.\install.ps1`.

## `/project-init` runs an old version or fails on a missing file

This machine still has links from when agent-config held its own copy. Install never removes
them, so delete them once. This removes only the links:

```powershell
foreach ($p in "$HOME\.agent-shared", "$HOME\.claude\commands", "$HOME\.codex\skills\project-init") {
    if ((Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue).LinkType) { [IO.Directory]::Delete($p, $false) }
}
```

## Claude ignores my instructions

Open `~\.claude\CLAUDE.md`. It should be a comment plus one line like
`@~/agent-config/claude/CLAUDE.md`. If the repo moved, re-run the installer from the new
folder to rewrite that line.

## A setting or skill is different on this machine and I don't know why

```powershell
.\install.ps1 -Check
```

It lists every file, link, setting, and skill that differs from the repo, and changes nothing.
Copy anything worth keeping into the repo before running the installer.

## I need something the installer replaced

It's in `.backup\<date-time>\`, at the same path it had under your home folder. Copy back
what you need.

## Undo everything

1. Delete the links: the custom skill folders
   under `~\.claude\skills` and `~\.codex\skills`. Deleting a junction doesn't touch the repo.
2. Copy your files back from the oldest folder in `.backup\`.
