param(
  [switch]$SkipBuild,
  [switch]$Draft,
  [string]$Notes
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

# read version
$yaml = Get-Content pubspec.yaml -Raw
$version = if ($yaml -match '^version:\s*(\S+)') { $Matches[1] } else { throw "Could not parse version from pubspec.yaml" }
$tag = "v$version"
Write-Host "==> Version: $version  Tag: $tag" -ForegroundColor Cyan

# check for uncommitted changes
$status = git status --porcelain
if ($status) {
  Write-Host "==> Uncommitted changes detected:" -ForegroundColor Yellow
  $status | ForEach-Object { Write-Host "    $_" }
  $answer = Read-Host "Stage and commit all? [Y/n]"
  if ($answer -ne 'n') {
    git add -A
    git commit -m "Bump version to $version"
    Write-Host "    committed" -ForegroundColor Green
  }
}

# build
if (-not $SkipBuild) {
  Write-Host "==> Building APK..." -ForegroundColor Cyan
  flutter build apk --release
  if (-not $?) { throw "Build failed" }
  Write-Host "    OK" -ForegroundColor Green
} else {
  Write-Host "==> Skipping build (--SkipBuild)" -ForegroundColor Yellow
}

$apk = "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apk)) { throw "APK not found at $apk" }

# tag
Write-Host "==> Creating tag $tag..." -ForegroundColor Cyan
git tag -a $tag -m $tag
Write-Host "    OK" -ForegroundColor Green

# push
Write-Host "==> Pushing commit and tag..." -ForegroundColor Cyan
git push origin HEAD --tags
Write-Host "    OK" -ForegroundColor Green

# release notes
if (-not $Notes) {
  $log = git log --oneline "v$(($version -split '\.')[0]).$([int]($version -split '\.')[1] - 1).0..HEAD" 2>$null
  if (-not $log) { $log = "Bug fixes and improvements" }
  $Notes = $log
}

Write-Host "==> Creating GitHub release..." -ForegroundColor Cyan
$asset = "$($apk)#Kalo-Weather-$tag.apk"
$url = gh release create $tag $asset --title $tag --notes $Notes --draft:$Draft 2>&1
if (-not $?) { throw "Release failed: $url" }
Write-Host "    $url" -ForegroundColor Green
Write-Host "==> Done!" -ForegroundColor Green
