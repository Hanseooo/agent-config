<#
.SYNOPSIS
Puts this repo's Claude Code and Codex setup on the current Windows user account.

.DESCRIPTION
Safe to re-run. Anything it replaces is moved to .backup\<timestamp> first.
-WhatIf shows what would change. -Check also shows how the machine differs from the repo,
changes nothing, and exits 1 when anything differs.

.EXAMPLE
.\install.ps1 -Check
.\install.ps1 -WhatIf
.\install.ps1
.\install.ps1 -SkipSkills -SkipPlugins
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$Check,
    [switch]$SkipSkills,
    [switch]$SkipPlugins
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\merge.ps1')

# Pinned because the installer depends on this version's `add` flags. Bump it deliberately.
$SkillsCli = 'skills@1.5.23'

$Repo = $PSScriptRoot
$UserHome = $env:USERPROFILE
$ClaudeHome = Join-Path $UserHome '.claude'
$CodexHome = Join-Path $UserHome '.codex'
$BackupRoot = Join-Path $Repo ('.backup\' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false
$script:Cmdlet = $PSCmdlet
$script:Warnings = New-Object System.Collections.ArrayList
$script:Drift = New-Object System.Collections.ArrayList

function Add-Warning([string]$Message) {
    [void]$script:Warnings.Add($Message)
    Write-Warning $Message
}

function Add-Drift([string]$Message) {
    [void]$script:Drift.Add($Message)
    Write-Host "  drift: $Message"
}

# -Check records the change and skips it. Otherwise -WhatIf decides.
function Confirm-Change([string]$Target, [string]$Action) {
    if ($Check) {
        Add-Drift "$Action $Target"
        return $false
    }
    $script:Cmdlet.ShouldProcess($Target, $Action)
}

function Test-Tool([string]$Name) { [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

function Read-Text([string]$Path) {
    if (Test-Path -LiteralPath $Path) { [IO.File]::ReadAllText($Path) } else { '' }
}

# Moves a file or folder into .backup\<timestamp>, keeping its path relative to the home folder.
function Backup-Item([string]$Path) {
    $dest = Join-Path $BackupRoot ($Path.Substring($UserHome.Length).TrimStart('\'))
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    Move-Item -LiteralPath $Path -Destination $dest
    Write-Host "  backed up $Path -> $dest"
}

function Set-Junction([string]$Link, [string]$Target) {
    $existing = Get-Item -LiteralPath $Link -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType -eq 'Junction' -and @($existing.Target)[0] -eq $Target) {
        Write-Host "  ok $Link"
        return
    }
    if (-not (Confirm-Change $Link "link to $Target")) { return }
    if ($existing) { Backup-Item $Link }
    New-Item -ItemType Directory -Force (Split-Path $Link) | Out-Null
    New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    Write-Host "  linked $Link -> $Target"
}

# $Current overrides what the file is compared against, so -Check can ignore formatting-only differences.
function Set-FileContent([string]$Path, [string]$Content, $Current = $null) {
    if ($null -eq $Current) { $Current = Read-Text $Path }
    if ((Test-Path -LiteralPath $Path) -and $Current -eq $Content) {
        Write-Host "  ok $Path"
        return
    }
    if ($Check) {
        Compare-Object (($Current -replace "`r`n", "`n") -split "`n") (($Content -replace "`r`n", "`n") -split "`n") |
            ForEach-Object {
                $side = if ($_.SideIndicator -eq '=>') { 'repo   ' } else { 'machine' }
                Write-Host "    $side | $($_.InputObject)"
            }
    }
    if (-not (Confirm-Change $Path 'write')) { return }
    if (Test-Path -LiteralPath $Path) { Backup-Item $Path }
    New-Item -ItemType Directory -Force (Split-Path $Path) | Out-Null
    [IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
    Write-Host "  wrote $Path"
}

# Runs a native command. A non-zero exit becomes a warning so one failure does not stop the rest.
function Invoke-Native([string]$Description, [scriptblock]$Command) {
    if (-not $script:Cmdlet.ShouldProcess($Description, 'run')) { return }
    Write-Host "  $Description"
    $ErrorActionPreference = 'Continue'
    & $Command | Out-Host
    if ($LASTEXITCODE -ne 0) { Add-Warning "$Description failed (exit $LASTEXITCODE)" }
}

$hasClaude = Test-Tool 'claude'
$hasCodex = Test-Tool 'codex'
if (-not $hasClaude) { Add-Warning 'claude not found. Claude Code plugins will not be installed.' }
if (-not $hasCodex) { Add-Warning 'codex not found. Codex plugins will not be installed.' }
if (-not $Check -and -not $SkipSkills -and -not (Test-Tool 'npx')) {
    Add-Warning 'npx not found. Install Node.js to install third-party skills.'
    $SkipSkills = $true
}
if (-not (Test-Tool 'ccstatusline')) {
    Add-Warning 'ccstatusline not found. The Claude status line stays empty until you run: npm install -g ccstatusline'
}

$repoRef = if ($Repo.StartsWith($UserHome, [StringComparison]::OrdinalIgnoreCase)) { '~' + $Repo.Substring($UserHome.Length) } else { $Repo }
$repoRef = $repoRef -replace '\\', '/'
$skillGroups = Get-Content (Join-Path $Repo 'skills.json') -Raw | ConvertFrom-Json

Write-Host "`n[1/5] Third-party skills (skills.json)"
if ($Check) {
    $manifest = @($skillGroups | ForEach-Object { $_.skills })
    $installed = @(Get-ChildItem (Join-Path $UserHome '.agents\skills') -Directory -ErrorAction SilentlyContinue | ForEach-Object Name)
    $installed | Where-Object { $manifest -notcontains $_ } | ForEach-Object { Add-Drift "skill $_ is installed but not in skills.json" }
    $manifest | Where-Object { $installed -notcontains $_ } | ForEach-Object { Add-Drift "skill $_ is in skills.json but not installed" }
    Get-ChildItem (Join-Path $ClaudeHome 'skills') -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.LinkType -and -not (Test-Path -LiteralPath @($_.Target)[0]) } |
        ForEach-Object { Add-Drift "broken link $($_.FullName)" }
} elseif ($SkipSkills) {
    Write-Host '  skipped'
} else {
    foreach ($group in $skillGroups) {
        $skillArgs = @('-y', $SkillsCli, 'add', $group.source, '-g', '-y', '-s') + $group.skills + @('-a') + $group.agents
        Invoke-Native "skills add $($group.source): $($group.skills -join ', ')" { npx @skillArgs }
    }
}

Write-Host "`n[2/5] Plugins (plugins.json)"
$plugins = Get-Content (Join-Path $Repo 'plugins.json') -Raw | ConvertFrom-Json
if ($Check) {
    Write-Host '  not checked. Plugin on/off differences show under Settings.'
} elseif ($SkipPlugins) {
    Write-Host '  skipped'
} else {
    if ($hasClaude) {
        $known = (claude plugin marketplace list | Out-String)
        foreach ($source in $plugins.claude.marketplaces) {
            if ($known -match [regex]::Escape($source)) { Write-Host "  ok marketplace $source"; continue }
            Invoke-Native "claude marketplace add $source" { claude plugin marketplace add $source }
        }
        foreach ($plugin in $plugins.claude.plugins) {
            Invoke-Native "claude plugin install $plugin" { claude plugin install $plugin }
        }
    }
    if ($hasCodex) {
        $known = (codex plugin marketplace list | Out-String)
        foreach ($source in $plugins.codex.marketplaces) {
            $name = ($source -split '/')[-1]
            if ($known -match "(?m)^$([regex]::Escape($name))\s") { Write-Host "  ok marketplace $source"; continue }
            Invoke-Native "codex marketplace add $source" { codex plugin marketplace add $source }
        }
        # Re-adding an installed Codex plugin updates it in place, which fails while Codex is open.
        $installed = (codex plugin list | Out-String)
        foreach ($plugin in $plugins.codex.plugins) {
            if ($installed -match "(?m)^$([regex]::Escape($plugin))\s+installed") { Write-Host "  ok plugin $plugin"; continue }
            Invoke-Native "codex plugin add $plugin" { codex plugin add $plugin }
        }
    }
}

# Settings come after plugins: installing a plugin rewrites its enabled flag, and the shared value should win.
Write-Host "`n[3/5] Settings"
$claudeSettings = Join-Path $ClaudeHome 'settings.json'
$currentJson = Read-Text $claudeSettings
$mergedJson = (Merge-JsonSettings $currentJson (Read-Text (Join-Path $Repo 'claude\settings.shared.json'))) + "`n"
# Re-serialize the machine file the same way, so -Check shows only real differences.
$compareJson = if ($Check -and $currentJson.Trim()) { (Merge-JsonSettings $currentJson '{}') + "`n" } else { $null }
Set-FileContent $claudeSettings $mergedJson $compareJson
$codexConfig = Join-Path $CodexHome 'config.toml'
Set-FileContent $codexConfig ((Merge-TomlSettings (Read-Text $codexConfig) (Read-Text (Join-Path $Repo 'codex\config.shared.toml'))) + "`n")

Write-Host "`n[4/5] Global instructions"
# Claude follows @imports, so ~/.claude/CLAUDE.md points at the repo and edits there apply live.
Set-FileContent (Join-Path $ClaudeHome 'CLAUDE.md') ("<!-- Managed by agent-config. Edit $repoRef/claude/CLAUDE.md instead. This file only imports it. -->`n@$repoRef/claude/CLAUDE.md`n")
# Codex has no import, so AGENTS.md is a copy. Edit the repo file and re-run.
Set-FileContent (Join-Path $CodexHome 'AGENTS.md') ("<!-- Managed by agent-config. Edit $repoRef/codex/AGENTS.md and re-run install.ps1. Edits made here get replaced. -->`n`n" + (Read-Text (Join-Path $Repo 'codex\AGENTS.md')))

Write-Host "`n[5/5] Custom skills and commands"
Set-Junction (Join-Path $UserHome '.agent-shared') (Join-Path $Repo 'shared')
Set-Junction (Join-Path $ClaudeHome 'commands') (Join-Path $Repo 'claude\commands')
foreach ($dir in Get-ChildItem (Join-Path $Repo 'claude\skills') -Directory) {
    Set-Junction (Join-Path $ClaudeHome "skills\$($dir.Name)") $dir.FullName
}
foreach ($dir in Get-ChildItem (Join-Path $Repo 'codex\skills') -Directory) {
    Set-Junction (Join-Path $CodexHome "skills\$($dir.Name)") $dir.FullName
}

Write-Host ''
if ($Check) {
    if ($script:Drift.Count -eq 0) {
        Write-Host 'No drift. This machine matches the repo.'
        exit 0
    }
    Write-Host "$($script:Drift.Count) difference(s). To keep a machine-side change, copy it into the repo before running install.ps1."
    Write-Host 'Install adds but never removes: skills and settings missing from the repo stay on the machine.'
    exit 1
}
if ($script:Warnings.Count -eq 0) {
    Write-Host 'Done. Restart Claude Code and Codex to load the changes.'
} else {
    Write-Host "Done with $($script:Warnings.Count) warning(s). See docs\4-troubleshooting.md:"
    $script:Warnings | ForEach-Object { Write-Host "  - $_" }
}
