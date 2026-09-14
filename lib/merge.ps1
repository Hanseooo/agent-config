# Merges shared settings into a machine's settings without dropping machine-only keys.

# Objects merge key by key. Lists of plain values combine, shared entries first.
# Anything else from $Shared replaces the $Target value.
function Merge-JsonValue($Target, $Shared) {
    if ($Target -is [System.Management.Automation.PSCustomObject] -and $Shared -is [System.Management.Automation.PSCustomObject]) {
        foreach ($property in $Shared.PSObject.Properties) {
            $existing = $Target.PSObject.Properties[$property.Name]
            $value = if ($existing) { Merge-JsonValue $existing.Value $property.Value } else { $property.Value }
            $Target | Add-Member -NotePropertyName $property.Name -NotePropertyValue $value -Force
        }
        return $Target
    }
    $isPlainList = $Target -is [array] -and $Shared -is [array] -and
        -not (@($Target) + @($Shared) | Where-Object { $_ -is [System.Management.Automation.PSCustomObject] -or $_ -is [array] })
    if ($isPlainList) {
        return , @(@($Shared) + @($Target | Where-Object { $Shared -notcontains $_ }))
    }
    , $Shared
}

# Merges shared settings into a machine's settings.json text. Settings only on the machine stay.
function Merge-JsonSettings([string]$Target, [string]$Shared) {
    $result = if ($Target.Trim()) { ConvertFrom-Json $Target } else { [pscustomobject]@{} }
    ConvertTo-Json -InputObject (Merge-JsonValue $result (ConvertFrom-Json $Shared)) -Depth 50
}

# Splits TOML text into blocks: the preamble (Header '') and one block per [table] header.
function Split-TomlBlocks([string]$Text) {
    $current = @{ Header = ''; Lines = New-Object System.Collections.ArrayList }
    $blocks = New-Object System.Collections.ArrayList
    [void]$blocks.Add($current)
    foreach ($line in (($Text -replace "`r`n", "`n") -split "`n")) {
        if ($line -match '^\[') {
            $current = @{ Header = $line.Trim(); Lines = New-Object System.Collections.ArrayList }
            [void]$blocks.Add($current)
        } else {
            [void]$current.Lines.Add($line)
        }
    }
    , $blocks
}

# Replaces the key's line (and any multi-line array body) in $Lines, or appends it.
function Set-TomlKey($Lines, [string]$Line) {
    $key = ($Line -split '=', 2)[0].Trim()
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -notmatch '=' -or ($Lines[$i] -split '=', 2)[0].Trim() -ne $key) { continue }
        $end = $i
        if ($Lines[$i] -match '=\s*\[' -and $Lines[$i] -notmatch '\]\s*(#.*)?$') {
            while ($end + 1 -lt $Lines.Count -and $Lines[$end] -notmatch '^\s*\]') { $end++ }
        }
        $Lines.RemoveRange($i, $end - $i + 1)
        $Lines.Insert($i, $Line)
        return
    }
    $at = $Lines.Count
    while ($at -gt 0 -and -not $Lines[$at - 1].Trim()) { $at-- }
    $Lines.Insert($at, $Line)
}

# Key-level merge: shared keys replace or join the matching table. Local tables and keys stay.
function Merge-TomlSettings([string]$Target, [string]$Shared) {
    $blocks = Split-TomlBlocks $Target
    foreach ($sharedBlock in (Split-TomlBlocks $Shared)) {
        $keyLines = @($sharedBlock.Lines | Where-Object { $_ -match '^\s*[^#\s\[][^=]*=' })
        if ($keyLines.Count -eq 0) { continue }

        $block = $blocks | Where-Object { $_.Header -eq $sharedBlock.Header } | Select-Object -First 1
        if (-not $block) {
            $last = $blocks[$blocks.Count - 1].Lines
            while ($last.Count -gt 0 -and -not $last[$last.Count - 1].Trim()) { $last.RemoveAt($last.Count - 1) }
            [void]$last.Add('')
            $block = @{ Header = $sharedBlock.Header; Lines = New-Object System.Collections.ArrayList }
            [void]$blocks.Add($block)
        }
        foreach ($line in $keyLines) { Set-TomlKey $block.Lines $line }
    }

    $out = foreach ($block in $blocks) {
        if ($block.Header) { $block.Header }
        $block.Lines
    }
    ($out -join "`n").TrimEnd()
}
