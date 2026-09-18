<#
.SYNOPSIS
    Scaffold a new project from a ProjectSetups template.

.DESCRIPTION
    Order of operations:
      1. template.json "scaffold" steps (official generators, e.g. composer create-project)
      2. templates/<Type>/ files are copied in (overwrite, unless -Existing)
      3. common/ defaults are copied in, filling gaps only (never overwrite existing files)
      4. template.json "install" steps (skipped with -NoInstall)
      5. git init + first commit (skipped with -NoGit or if .git already exists)

    .gitignore files are always merged (missing lines appended), never overwritten.
    Tokens replaced in file contents and paths:
      {{NAME}} {{SLUG}} {{PKG}} {{YEAR}} {{AUTHOR}} {{DESCRIPTION}}
    {{RULES}} expands to shared/security-and-speed.md (the universal security + speed rules).

.EXAMPLE
    .\New-Project.ps1 -List

.EXAMPLE
    .\New-Project.ps1 -Type node-bot -Name MyBot -Description "Twitch chat bot"

.EXAMPLE
    # Apply defaults onto a project that already exists (never overwrites your files)
    .\New-Project.ps1 -Type node-bot -Name MyBot -Destination D:\GitHub\MyBot -Existing
#>
[CmdletBinding()]
param(
    [string]$Type,
    [string]$Name,
    [string]$Description,
    [string]$Destination,
    [switch]$Existing,
    [switch]$NoInstall,
    [switch]$NoGit,
    [switch]$List
)

$ErrorActionPreference = 'Stop'
$templatesDir = Join-Path $PSScriptRoot 'templates'
$commonDir = Join-Path $PSScriptRoot 'common'
$rulesFile = Join-Path (Join-Path $PSScriptRoot 'shared') 'security-and-speed.md'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-TemplateManifest([string]$Dir) {
    [IO.File]::ReadAllText((Join-Path $Dir 'template.json')) | ConvertFrom-Json
}

if ($List -or -not $Type) {
    Get-ChildItem -LiteralPath $templatesDir -Directory | ForEach-Object {
        '{0,-18} {1}' -f $_.Name, (Get-TemplateManifest $_.FullName).description
    }
    if (-not $List) { Write-Host "`nUsage: .\New-Project.ps1 -Type <type> -Name <name> [-Description ...]" }
    return
}

$templateDir = Join-Path $templatesDir $Type
if (-not (Test-Path -LiteralPath (Join-Path $templateDir 'template.json'))) {
    throw "Unknown template '$Type'. Run .\New-Project.ps1 -List."
}
if ($Name -notmatch '^[A-Za-z][A-Za-z0-9._-]*$') {
    throw "-Name must start with a letter and contain only letters, digits, '.', '_' or '-'."
}
$manifest = Get-TemplateManifest $templateDir

if (-not $Destination) { $Destination = Join-Path (Split-Path $PSScriptRoot -Parent) $Name }
$Destination = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)
$destExists = Test-Path -LiteralPath $Destination
if ($Existing -and -not $destExists) { throw "-Existing was given but '$Destination' does not exist." }
if (-not $Existing -and $destExists -and (Get-ChildItem -LiteralPath $Destination -Force | Select-Object -First 1)) {
    throw "'$Destination' already exists and is not empty. Use -Existing to apply defaults onto it."
}

if (-not ($Existing -and $NoInstall)) {
    $missing = @($manifest.requires | Where-Object { $_ -and -not (Get-Command $_ -ErrorAction SilentlyContinue) })
    if ($missing.Count) { throw "Missing required tools: $($missing -join ', ')" }
}

$author = ''
try { $author = "$(& git config user.name)" } catch { }
$onWindows = [Environment]::OSVersion.Platform -eq 'Win32NT'
$tokens = @{
    NAME        = $Name
    SLUG        = ($Name.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
    PKG         = ($Name.ToLower() -replace '[^a-z0-9]+', '_').Trim('_')
    YEAR        = "$((Get-Date).Year)"
    AUTHOR      = $author
    DESCRIPTION = $(if ($Description) { $Description } else { "TODO: describe $Name." })
    VENV_PY     = Join-Path $Destination $(if ($onWindows) { '.venv\Scripts\python.exe' } else { '.venv/bin/python' })
    RULES       = ([IO.File]::ReadAllText($rulesFile)).TrimEnd()
}

function Expand-Tokens([string]$Text) {
    $evaluator = [System.Text.RegularExpressions.MatchEvaluator] { param($m) [string]$tokens[$m.Groups[1].Value] }
    [regex]::Replace($Text, '\{\{(NAME|SLUG|PKG|YEAR|AUTHOR|DESCRIPTION|VENV_PY|RULES)\}\}', $evaluator)
}

# Appends lines from $Incoming that aren't already in $TargetPath. Returns $true if anything was added.
function Merge-GitIgnore([string]$TargetPath, [string]$Incoming, [string]$Label) {
    $existing = [IO.File]::ReadAllText($TargetPath)
    $have = @{}
    foreach ($line in ($existing -split "\r?\n")) { if ($line.Trim()) { $have[$line.Trim()] = $true } }

    $add = New-Object System.Collections.Generic.List[string]
    foreach ($line in ($Incoming -split "\r?\n")) {
        $t = $line.Trim()
        if ($t -and $have.ContainsKey($t)) { continue }
        if (-not $t -and ($add.Count -eq 0 -or -not $add[$add.Count - 1].Trim())) { continue }
        $add.Add($line)
    }
    while ($add.Count -and -not $add[$add.Count - 1].Trim()) { $add.RemoveAt($add.Count - 1) }
    if (-not ($add | Where-Object { $_.Trim() -and -not $_.Trim().StartsWith('#') })) { return $false }

    $body = $existing.TrimEnd() + "`n`n# --- $Label ---`n" + ($add -join "`n") + "`n"
    [IO.File]::WriteAllText($TargetPath, $body, $utf8)
    return $true
}

function Copy-Overlay([string]$Source, [string]$Label, [bool]$KeepExisting) {
    $created = 0
    foreach ($file in Get-ChildItem -LiteralPath $Source -Recurse -File -Force) {
        $rel = $file.FullName.Substring($Source.Length).TrimStart('\', '/')
        if ($rel -eq 'template.json') { continue }
        $rel = Expand-Tokens $rel
        $target = Join-Path $Destination $rel
        $bytes = [IO.File]::ReadAllBytes($file.FullName)
        $isText = [Array]::IndexOf($bytes, [byte]0) -lt 0
        $isIgnore = $file.Name -eq '.gitignore'
        $exists = [IO.File]::Exists($target)

        if ($exists -and $isIgnore) {
            if (Merge-GitIgnore $target (Expand-Tokens $utf8.GetString($bytes)) $Label) { Write-Host "  ~ $rel (merged)" }
            continue
        }
        if ($exists -and $KeepExisting) { Write-Host "  = $rel (kept existing)" -ForegroundColor DarkGray; continue }

        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($target))
        if ($isText) { [IO.File]::WriteAllText($target, (Expand-Tokens $utf8.GetString($bytes)), $utf8) }
        else { [IO.File]::WriteAllBytes($target, $bytes) }
        $created++
    }
    Write-Host "  + $created file(s) from $Label"
}

function Invoke-Steps($Steps) {
    # Native tools write progress/warnings to stderr; judge success by exit code only.
    $ErrorActionPreference = 'Continue'
    foreach ($step in $Steps) {
        $cmd = Expand-Tokens $step
        Write-Host "  > $cmd" -ForegroundColor Cyan
        $global:LASTEXITCODE = 0
        Invoke-Expression $cmd
        if ($LASTEXITCODE -ne 0) { throw "Step failed (exit $LASTEXITCODE): $cmd" }
    }
}

function Initialize-GitRepo {
    $ErrorActionPreference = 'Continue'
    git init -b main --quiet
    git -c core.safecrlf=false add -A
    git commit --quiet -m "Initial commit from ProjectSetups ($Type)"
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed (is user.name / user.email configured?)' }
    Write-Host '  + git repo initialised with first commit'
}

Write-Host "Creating '$Name' ($Type) in $Destination" -ForegroundColor Green
[void][IO.Directory]::CreateDirectory($Destination)
Push-Location -LiteralPath $Destination
try {
    if (-not $Existing) { Invoke-Steps $manifest.scaffold }
    # Template first so its specific files win; common/ then only fills in what's still missing.
    Copy-Overlay $templateDir $Type ([bool]$Existing)
    Copy-Overlay $commonDir 'common' $true
    if (-not $NoInstall) { Invoke-Steps $manifest.install }

    if (-not $NoGit -and -not (Test-Path -LiteralPath (Join-Path $Destination '.git'))) { Initialize-GitRepo }
}
finally { Pop-Location }

Write-Host "`nDone: $Destination" -ForegroundColor Green
foreach ($note in $manifest.notes) { Write-Host "  * $(Expand-Tokens $note)" }
