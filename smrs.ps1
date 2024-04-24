param ( [string]$SourceExe, [string]$ArgumentsToSourceExe, [string]$DestinationPath )

$SHELLSENDTO = [System.Environment]::GetFolderPath('SendTo') #shell:sendto
echo $SHELLSENDTO
$shortcutPath = "$SHELLSENDTO\Smoothie-RS.lnk"
if (Get-Command -Name "ffmpeg" -ErrorAction SilentlyContinue) { #check whether ffmpeg is installed or not
    Write-Host "FFmpeg is installed"
} else {
    Write-Warning -Message "FFmpeg isn't installed, Trying to install FFmpeg"
    powershell -noe "iex(irm tl.ctt.cx); Get FFmpeg" #install ffmpeg if it doesn't exist
    
    if (Get-Command -Name "ffmpeg" -ErrorAction SilentlyContinue) { #check whether ffmpeg is installed
    Write-Host "FFmpeg is installed."
    } else {
        Write-Error -Message "Couldn't install FFmpeg"
        exit
    }
}


$TEMP = $env:TEMP
mkdir "$TEMP\smoothie-rs"
cd "$TEMP\smoothie-rs"

$latestRelease = (Invoke-WebRequest -Uri "https://api.github.com/repos/couleur-tweak-tips/smoothie-rs/releases/latest" | ConvertFrom-Json).assets | Where-Object { $_.browser_download_url -like "*nightly.zip" }
Invoke-WebRequest -Uri $latestRelease.browser_download_url -OutFile "smrs.zip" #Download the latest build of smoothie

$SMOOTHIE_DIR = "$HOME\.smoothie-rs"
mkdir $SMOOTHIE_DIR
Expand-Archive -LiteralPath 'smrs.zip' -DestinationPath $SMOOTHIE_DIR

cd $SMOOTHIE_DIR
$SMOOTHIE_EXE = "$HOME\.smoothie-rs\smoothie-rs\bin\smoothie-rs.exe"

if (!$SourceExe) { $SourceExe = $SMOOTHIE_EXE }
if (!$ArgumentsToSourceExe) { $ArgumentsToSourceExe = "-v -i" }
if (!$DestinationPath) { $DestinationPath = $shortcutPath }

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($DestinationPath)
$Shortcut.TargetPath = $SourceExe
$Shortcut.Arguments = $ArgumentsToSourceExe
$Shortcut.Save()
