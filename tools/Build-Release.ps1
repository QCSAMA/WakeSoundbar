#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidatePattern('^[0-9]+\.[0-9]+\.[0-9]+$')]
    [string]$Version = '1.1.0',
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { $OutputDirectory = Join-Path $root 'dist' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
& (Join-Path $PSScriptRoot 'Build-CNRelease.ps1') -Version $Version -OutputDirectory $OutputDirectory
$name = "WakeSoundbar-v$Version"
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$stage = Join-Path $tempRoot ('WakeSoundbar-release-' + [guid]::NewGuid().ToString('N'))
$package = Join-Path $stage $name
$archivePath = Join-Path $OutputDirectory "$name.zip"
New-Item -ItemType Directory -Path $package -Force | Out-Null
try {
    $files = @('WakeSoundbar.ps1', 'Setup-WakeSoundbar.ps1', 'install.bat', 'uninstall.bat', 'README.md', 'LICENSE', 'SECURITY.md', 'CONTRIBUTING.md', 'CHANGELOG.md')
    $files += @(Get-ChildItem -LiteralPath $root -Filter 'README.*.md' -File | Select-Object -ExpandProperty Name)
    foreach ($file in $files) { Copy-Item -LiteralPath (Join-Path $root $file) -Destination (Join-Path $package $file) }
    foreach ($folder in @('docs', 'openspec')) { Copy-Item -LiteralPath (Join-Path $root $folder) -Destination $package -Recurse }
    Compress-Archive -LiteralPath $package -DestinationPath $archivePath -Force
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($archivePath)
    try {
        $expected = @(Get-ChildItem -LiteralPath $package -File -Recurse | ForEach-Object {
            "$name/" + $_.FullName.Substring($package.Length + 1).Replace('\', '/')
        })
        $actual = @($zip.Entries | Where-Object { $_.Length -gt 0 } | ForEach-Object { $_.FullName.Replace('\', '/') })
        if (@(Compare-Object $expected $actual).Count) { throw 'Generic release ZIP contents mismatch.' }
    } finally { $zip.Dispose() }
} finally {
    if ([IO.Path]::GetFullPath($stage).StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) {
        Remove-Item -LiteralPath $stage -Force -Recurse
    }
}
$archives = @($archivePath, (Join-Path $OutputDirectory "$name-CN.zip"))
$sums = foreach ($archive in $archives) { (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() + '  ' + [IO.Path]::GetFileName($archive) }
$sums | Set-Content -LiteralPath (Join-Path $OutputDirectory 'SHA256SUMS.txt') -Encoding ASCII
Write-Host "Built $archivePath and SHA256SUMS.txt"
