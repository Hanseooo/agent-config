. "$PSScriptRoot\..\lib\merge.ps1"

Describe 'Merge-JsonSettings' {
    It 'overwrites shared top-level keys and keeps local-only keys' {
        $target = '{"model":"sonnet","hooks":{"SessionStart":[]},"theme":"light"}'
        $shared = '{"model":"opus","theme":"dark","permissions":{"allow":["Read"]}}'

        $result = Merge-JsonSettings -Target $target -Shared $shared | ConvertFrom-Json

        $result.model | Should Be 'opus'
        $result.theme | Should Be 'dark'
        ($result.hooks.PSObject.Properties.Name -contains 'SessionStart') | Should Be $true
        # A one-element array must stay an array, not collapse to a string.
        (Merge-JsonSettings -Target $target -Shared $shared) | Should Match '"allow":\s*\[\s*"Read"\s*\]'
    }

    It 'merges nested objects and combines string lists instead of replacing them' {
        $target = '{"permissions":{"allow":["Bash(git:*)","Read"],"deny":["Read(.env)"]},"enabledPlugins":{"local@m":true,"shared@m":true}}'
        $shared = '{"permissions":{"allow":["Read","Edit"]},"enabledPlugins":{"shared@m":false}}'

        $result = Merge-JsonSettings -Target $target -Shared $shared | ConvertFrom-Json

        ($result.permissions.allow -join ',') | Should Be 'Read,Edit,Bash(git:*)'
        ($result.permissions.deny -join ',') | Should Be 'Read(.env)'
        $result.enabledPlugins.'local@m' | Should Be $true
        $result.enabledPlugins.'shared@m' | Should Be $false
    }

    It 'treats a missing target file as empty' {
        $result = Merge-JsonSettings -Target '' -Shared '{"model":"opus"}' | ConvertFrom-Json

        $result.model | Should Be 'opus'
    }
}

Describe 'Merge-TomlSettings' {
    It 'replaces shared keys, keeps local keys and sections, appends new sections' {
        $target = @'
model = "old"
notify = ["a.exe"]

[features]
hooks = false
local_only = true

[projects.'c:\work']
trust_level = "trusted"
'@
        $shared = @'
model = "new"

[features]
hooks = true

[tui]
status_line_use_colors = true
'@
        $expected = @'
model = "new"
notify = ["a.exe"]

[features]
hooks = true
local_only = true

[projects.'c:\work']
trust_level = "trusted"

[tui]
status_line_use_colors = true
'@

        (Merge-TomlSettings -Target $target -Shared $shared) | Should Be ($expected -replace "`r`n", "`n")
    }

    It 'replaces a multi-line array value without leaving its old lines behind' {
        $target = @'
[tui]
status_line = [
  "model",
  "git-branch",
]
other = 1
'@
        $shared = @'
[tui]
status_line = ["model"]
'@
        $expected = @'
[tui]
status_line = ["model"]
other = 1
'@

        (Merge-TomlSettings -Target $target -Shared $shared) | Should Be ($expected -replace "`r`n", "`n")
    }
}
