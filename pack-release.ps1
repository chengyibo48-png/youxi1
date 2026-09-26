# Run from any directory with PowerShell 5.1+ and Node.js 20+.
$ErrorActionPreference = 'Stop'
Push-Location -LiteralPath $PSScriptRoot
try {
    & node check-release.js
    if ($LASTEXITCODE -ne 0) { throw 'Release validation failed.' }
    & node room-test.js
    if ($LASTEXITCODE -ne 0) { throw 'Game regression tests failed.' }
    $manifest = Get-Content -LiteralPath 'release-files.json' -Raw -Encoding UTF8 | ConvertFrom-Json
    $version = (Get-Content -LiteralPath 'package.json' -Raw -Encoding UTF8 | ConvertFrom-Json).version
    New-Item -ItemType Directory -Path 'dist' -Force | Out-Null
    $webFiles = @($manifest.runtime) + @('LICENSE')
    $sourceFiles = @($manifest.runtime) + @($manifest.development)
    $webZip = "dist/youxi1-$version-web.zip"
    $sourceZip = "dist/youxi1-$version-source.zip"
    Compress-Archive -LiteralPath $webFiles -DestinationPath $webZip -Force
    Compress-Archive -LiteralPath $sourceFiles -DestinationPath $sourceZip -Force
    @($webZip, $sourceZip) | ForEach-Object {
        $hash = Get-FileHash -LiteralPath $_ -Algorithm SHA256
        '{0}  {1}' -f $hash.Hash.ToLowerInvariant(), (Split-Path -Leaf $_)
    } | Set-Content -LiteralPath 'dist/SHA256SUMS.txt' -Encoding ASCII
    Write-Output 'Created web and source archives in dist/.'
} finally {
    Pop-Location
}
