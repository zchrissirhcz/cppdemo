# Universal script to create Windows Start Menu shortcuts for documentation
# Usage: create-doc-shortcuts.ps1 -DocDir "cppreference-doc-en" -ShortcutName "CppReference" -Description "C++ Reference"

param(
    [Parameter(Mandatory=$true)]
    [string]$DocDir,
    
    [Parameter(Mandatory=$true)]
    [string]$ShortcutName,
    
    [string]$Description = "",
    
    [string]$ZzpkgRoot = "$env:USERPROFILE\.zzpkg",
    
    [string]$StartMenuFolder = "cppdoc"
)

$StartMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$StartMenuFolder"

# Create folder if not exists
if (-not (Test-Path $StartMenuPath)) {
    New-Item -Path $StartMenuPath -ItemType Directory -Force | Out-Null
    Write-Host "[INFO] Created folder: $StartMenuPath" -ForegroundColor Cyan
}

# Find installed documentation
$DocPath = $null
$VersionName = "latest"
$BaseDir = Join-Path $ZzpkgRoot $DocDir

if (Test-Path $BaseDir) {
    # Try to find version directories first
    $versions = Get-ChildItem -Path $BaseDir -Directory | Sort-Object Name -Descending
    
    if ($versions.Count -gt 0) {
        # Check version directories for index.html
        foreach ($ver in $versions) {
            $indexPath = Join-Path $ver.FullName "index.html"
            if (Test-Path $indexPath) {
                $DocPath = $indexPath
                $VersionName = $ver.Name
                break
            }
        }
    } else {
        # No version subdirectories, check root
        $indexPath = Join-Path $BaseDir "index.html"
        if (Test-Path $indexPath) {
            $DocPath = $indexPath
        }
    }
}

if ($DocPath) {
    $WshShell = New-Object -ComObject WScript.Shell
    $ShortcutPath = "$StartMenuPath\$ShortcutName.lnk"
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $DocPath
    
    if ($Description) {
        $Shortcut.Description = "$Description $VersionName"
    } else {
        $Shortcut.Description = "$ShortcutName $VersionName Documentation"
    }
    
    $Shortcut.IconLocation = "$env:SystemRoot\system32\shell32.dll,71"
    $Shortcut.Save()
    
    Write-Host "[OK] Created shortcut: $ShortcutName" -ForegroundColor Green
    Write-Host "     Version: $VersionName" -ForegroundColor Gray
    Write-Host "     Path: $DocPath" -ForegroundColor Gray
} else {
    Write-Host "[SKIP] Documentation not found: $DocDir" -ForegroundColor Yellow
    Write-Host "     Expected location: $BaseDir" -ForegroundColor Gray
}
