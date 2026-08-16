#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+$')]
    [string]$Version = '1.0.0',

    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$OutputDirectory = if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    Join-Path $repoRoot 'dist'
} else {
    $OutputDirectory
}
$localeRoot = Join-Path $repoRoot 'locales\zh-CN'
$packageRootName = "WakeSoundbar-v$Version-CN"
$outputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
$archivePath = Join-Path $outputDirectory "$packageRootName.zip"
$stageDirectory = Join-Path ([IO.Path]::GetTempPath()) ("WakeSoundbar-cn-" + [guid]::NewGuid().ToString('N'))
$stageRoot = Join-Path $stageDirectory $packageRootName

$localeFiles = @('WakeSoundbar.ps1', 'install.bat', 'uninstall.bat', 'README.md')
$packageFiles = @($localeFiles + 'LICENSE')

function Assert-FileExists {
    param([Parameter(Mandatory)] [string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file not found: $Path"
    }
}

function Test-AsciiBatchFile {
    param([Parameter(Mandatory)] [string]$Path)

    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 3) {
        throw "Batch file is empty: $Path"
    }
    if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        throw "Batch file must not have a UTF-8 BOM: $Path"
    }
    if (@($bytes | Where-Object { $_ -gt 0x7F }).Count -ne 0) {
        throw "Batch file must contain ASCII command text only: $Path"
    }
    for ($index = 0; $index -lt $bytes.Length; $index++) {
        if ($bytes[$index] -eq 0x0A -and ($index -eq 0 -or $bytes[$index - 1] -ne 0x0D)) {
            throw "Batch file must use CRLF line endings: $Path"
        }
    }
}

function Test-Utf8BomFile {
    param([Parameter(Mandatory)] [string]$Path)

    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
        throw "File must use UTF-8 with BOM: $Path"
    }
}

function Test-WindowsPowerShellSyntax {
    param([Parameter(Mandatory)] [string]$Path)

    $quotedPath = "'" + $Path.Replace("'", "''") + "'"
    $parseCode = @"
`$tokens = `$null
`$errors = `$null
[System.Management.Automation.Language.Parser]::ParseFile($quotedPath, [ref]`$tokens, [ref]`$errors) | Out-Null
if (`$errors.Count -gt 0) {
    `$errors | ForEach-Object { Write-Error `$_.Message }
    exit 1
}
"@
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($parseCode))
    & powershell.exe -NoProfile -EncodedCommand $encoded
    if ($LASTEXITCODE -ne 0) {
        throw "Windows PowerShell syntax check failed: $Path"
    }
}

foreach ($name in $localeFiles) {
    Assert-FileExists (Join-Path $localeRoot $name)
}
Assert-FileExists (Join-Path $repoRoot 'LICENSE')

$cnScript = Join-Path $localeRoot 'WakeSoundbar.ps1'
Test-Utf8BomFile $cnScript
Test-Utf8BomFile (Join-Path $localeRoot 'README.md')
Test-WindowsPowerShellSyntax $cnScript
Test-AsciiBatchFile (Join-Path $localeRoot 'install.bat')
Test-AsciiBatchFile (Join-Path $localeRoot 'uninstall.bat')

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $stageRoot -Force | Out-Null

try {
    foreach ($name in $localeFiles) {
        Copy-Item -LiteralPath (Join-Path $localeRoot $name) -Destination (Join-Path $stageRoot $name)
    }
    Copy-Item -LiteralPath (Join-Path $repoRoot 'LICENSE') -Destination (Join-Path $stageRoot 'LICENSE')

    Compress-Archive -LiteralPath $stageRoot -DestinationPath $archivePath -CompressionLevel Optimal -Force

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead($archivePath)
    try {
        $entries = @($archive.Entries | ForEach-Object { $_.FullName.Replace('\', '/') })
        $expectedEntries = @($packageFiles | ForEach-Object { "$packageRootName/$_" })
        if (@(Compare-Object -ReferenceObject $expectedEntries -DifferenceObject $entries).Count -ne 0) {
            throw 'CN archive contents do not match the expected five files.'
        }
    } finally {
        $archive.Dispose()
    }
} finally {
    if (Test-Path -LiteralPath $stageDirectory) {
        Remove-Item -LiteralPath $stageDirectory -Recurse -Force
    }
}

$hash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash
Write-Host "Built $archivePath"
Write-Host "SHA256 $hash"
