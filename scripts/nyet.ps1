# Create Shortcut tutorial: http://powershellblogger.com/2016/01/create-shortcuts-lnk-or-url-files-with-powershell/
# For Self Update with elevated permissions: Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File {file}" -Verb RunAs
# How to run: Invoke-Expression(GC .\scripts\nyet.ps1 -Raw)`

$HomeDir = "C:"+$env:HOMEPATH+"\.nyet"
$HelpText = "
This is the NyetBrains help screen
Check out the options below to see what's possible!

Usage:
    nyet [options] [variant]

Arguments:
    -h  --help              This page
    -n  --name              Set the name of the instance
    -ns --no-shortcut       Don't generate a shortcut
    -l  --list              List all available variants
    -i  --installed         List all installed variants

Examples:
    nyet -n js-instance javascript
    nyet --ns --name rust-instance rust
    nyet -l
"

function Get-Variants {
    $VariantText = ((New-Object System.Net.WebClient).DownloadString('https://nyetbrains.net/variants/list.txt') -split "\n").Trim()
    return $VariantText
}

function Get-Random {
    return ((invoke-webrequest -Uri "https://random-word-api.herokuapp.com/word?number=1&swear=0").content | convertfrom-json)
}

function Show-Text {
    Write-Output $HelpText
    exit
}

function Set-Name {
    param ($NewName)

    if (-not ($NewName[0] -match "[a-zA-Z]")) {
        Write-Output "A name must begin with a letter!"
        exit
    }

    return $NewName
}

function Show-Variants {
    Write-Output "Available variants:"
    foreach ($i in $VariantList) {
        Write-Output ("- "+$i)
    }
    exit
}

function Show-Installed {
    exit
}

function Create-Shortcut {

    if (-not (Test-Path -Path "$HomeDir\icons\$Variant.ico" -PathType Leaf)) {
        (New-Object System.Net.WebClient).DownloadFile("https://nyetbrains.net/icons/$Variant.ico", "$HomeDir\icons\$Variant.ico")
    }

    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\$DirName.lnk")
    $ShortCut.TargetPath = "code"
    $ShortCut.Arguments = " --user-data-dir=$HomeDir\variants\$DirName --extensions-dir=$HomeDir\variants\$DirName\extensions"
    $ShortCut.IconLocation = "$HomeDir\icons\$Variant.ico"
    $ShortCut.Save()
    exit
}

function Create-Variant {
    $DirName = $Variant + "-" + (Get-Random)
    if (-not ($Name -eq "")) {
        $DirName = $Name
    }

    try {
        New-Item -Path $HomeDir"\variants\"$DirName -ItemType Directory -ErrorAction Stop | Out-Null
        New-Item -Path $HomeDir"\variants\"$DirName"\extensions" -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Error -Message "Unable to create directories. Error was: $_" -ErrorAction Stop
    }

    if (-not $NoShortcut) {
        Create-Shortcut
    }

}

$VariantList = Get-Variants
$Name = ""
$DirName = ""
$Variant = ""
$NoShortcut = $false


if ($args.count -eq 0) {
    Show-Text
}

for ($i = 0; $i -lt $args.count; $i++) {
    switch -Regex ($args[$i]) {
        "(-h|--help)\b" {Show-Text}
        "(-n|--name)\b" {$Name = (Set-Name $args[$i+1])}
        "(-ns|--no-shortcut)\b" {$NoShortcut = $true}
        "(-l|--list)\b" {Show-Variants}
        "(-i|--installed)\b" {Show-Installed}
        default {
            if ($args[$i][0] -eq "-") {
                Write-Output "Argument not found: "$args[$i]
                exit
            } elseif ($i -eq ($args.count-1)) {
                if (-not ($VariantList -contains $args[$i])) {
                    Write-Output "Could not find variant: "$args[$i]
                } else {
                    $Variant = $args[$i]
                    (Create-Variant)
                }   
            } 
        }
    }
}