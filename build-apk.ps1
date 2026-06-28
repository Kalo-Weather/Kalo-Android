param(
  [switch]$Release,
  [switch]$TagAndUpload,
  [switch]$Bump
)

$ErrorActionPreference = 'Stop'

$raw = & { Select-String -Path pubspec.yaml -Pattern '^version:\s*(\S+)' | ForEach-Object { $_.Matches.Groups[1].Value } }
$version = $raw -replace '\+.*', ''
$build = $raw -replace '.*\+', ''
Write-Host "Version: $version (build $build)"

if ($Bump) {
  Write-Host "=== Bumping patch version ===" -ForegroundColor Cyan
  $parts = $version -split '\.'
  $parts[2] = [int]$parts[2] + 1
  $newVersion = $parts -join '.'
  $newBuild = [int]$build + 1
  $newRaw = "$newVersion+$newBuild"
  $rawPath = Resolve-Path pubspec.yaml
  (Get-Content $rawPath) -replace "^version:\s*\S+", "version: $newRaw" | Set-Content $rawPath -Encoding UTF8
  $version = $newVersion
  $build = $newBuild
  Write-Host "Bumped to $newRaw" -ForegroundColor Green
}

if ($TagAndUpload) {
  $remote = git remote get-url origin
  if (-not ($remote -match 'github\.com')) {
    Write-Host "Remote is not GitHub - skipping tag/upload." -ForegroundColor Yellow
    $TagAndUpload = $false
  }
}

$apkDir = 'build\app\outputs\flutter-apk'

function Build-Apk($mode) {
  Write-Host "=== Building $mode APK ===" -ForegroundColor Cyan
  flutter build apk --$mode
  if ($LASTEXITCODE -ne 0) { throw "Build failed ($mode)" }
}

function Sign-Apk($path) {
  $jks = 'upload-keystore.jks'
  if (-not (Test-Path $jks)) {
    Write-Host "No keystore found at $jks - skipping signing." -ForegroundColor Yellow
    return $path
  }
  $signed = $path -replace '\.apk$', '-signed.apk'
  & jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore $jks $path upload
  if ($LASTEXITCODE -ne 0) { throw "Signing failed" }
  Move-Item -LiteralPath $path -Destination $signed -Force
  return $signed
}

function Upload-Release($apkPath, $tag) {
  Write-Host "=== Creating GitHub release v$tag ===" -ForegroundColor Cyan
  $title = "v$tag"
  gh release create "v$tag" "$apkPath" --title "$title" --generate-notes
  if ($LASTEXITCODE -ne 0) { throw "gh release create failed" }
  Write-Host "Release v$tag created." -ForegroundColor Green
}

if ($Release) {
  $debugApk = "$apkDir\app-debug.apk"
  $releaseApk = "$apkDir\app-release.apk"

  Build-Apk debug
  Build-Apk release
  $signed = Sign-Apk $releaseApk

  if ($TagAndUpload) {
    $tag = "v$version"
    git add pubspec.yaml
    git commit -m "Bump version to $version+$build"
    git tag -f "$tag"
    git push origin "$tag"
    git push origin
    Upload-Release $signed $version
    Write-Host "Done - debug APK at $debugApk, release APK at $signed" -ForegroundColor Green
  } else {
    Write-Host "Done - debug APK at $debugApk, release APK at $signed" -ForegroundColor Green
    Write-Host "Run with -TagAndUpload to also push a tag and upload to GitHub Releases." -ForegroundColor DarkYellow
  }
} else {
  Build-Apk debug
  Write-Host "Done - debug APK at $apkDir\app-debug.apk" -ForegroundColor Green
  Write-Host "Run with -Release to also build a release APK." -ForegroundColor DarkYellow
}
