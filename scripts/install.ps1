# How to run: iex (New-Object System.Net.WebClient).DownloadString('https://nyetbrains.net/scripts/install.ps1')

if (-not ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')) {
    echo "This script should run as administrator!"
    return
}

if (-not (Get-Command code)) {
    echo "VSCode could not be found, make sure to install it or put it in your PATH"
    return
}

echo "Setting up NyetBrains"
echo "Initializing folders"

function Make-Directory {
    param (
        $DirPath
    )

    if (Test-Path -Path $DirPath) {
        echo "'$DirPath' folder already exists"
    } else {
    try {
        
        New-Item -Path $DirPath -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$DirPath'. Error was: $_" -ErrorAction Stop
    }
}

}

$NyetHome = $env:HOMEPATH+"\.nyet"
$NyetFolders = Write-Output $NyetHome $env:HOMEPATH"\.nyet\icons" $env:HOMEPATH"\.nyet\variants"

foreach ($Folder in $NyetFolders) {
    Make-Directory $Folder
}
echo "Folders Initialized"
echo "Downloading NyetBrains"
$TempPath = $env:TEMP + "\nyet.ps1"
(New-Object System.Net.WebClient).DownloadFile("https://nyetbrains.net/scripts/nyet.ps1", $TempPath)
echo "NyetBrains Downloaded"

echo "Converting NyetBrains to executable"
try {
    Install-Module ps2exe
    Import-Module ps2exe
    ps2exe $TempPath $NyetHome"\nyet.exe"
} catch {
    Write-Error -Message "Could not use ps2exe needed for script conversion"
    return
}
echo "Conversion compeleted"


$PathSplit = Write-Output $env:Path.Split(";")
$NyetFound = $false

foreach ($CurrentPath in $PathSplit) {
    if ($CurrentPath -like "*"+$NyetHome) {
        $NyetFound = $true
    }
}

if (!$NyetFound) {
    try {
        echo "Adding NyetBrains to Path (Might take a couple of seconds)"
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";$NyetHome", "User")
    } catch {
        Write-Error -Message "Unable to add '$NyetHome' to PATH, you might still run it in the folder"
    }
}

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "| Installation of NyetBrains is complete, please continue in an unprivileged terminal |"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

return