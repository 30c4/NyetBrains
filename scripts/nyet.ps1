# Create Shortcut tutorial: http://powershellblogger.com/2016/01/create-shortcuts-lnk-or-url-files-with-powershell/
# For Self Update with elevated permissions: Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File {file}" -Verb RunAs

$HomeDir = "C:"+$env:HOMEPATH+"\.nyet"
$HelpText = "
This is the NyetBrains help screen
Check out the options below to see what's possible!

Usage:
    nyet [options] [instance]/[variant]

Arguments:
    -h  --help              This page
    -n  --name              Set the name of the instance
    -ns --no-shortcut       Don't generate a shortcut
    -l  --list              List all available variants
    -i  --installed         List all installed variants
    -e  --extensions        List all the extensions of a given instance

Examples:
    nyet -n js-instance javascript
    nyet --ns --name rust-instance rust
    nyet -l
"

function Get-Variants {
    $VariantText = ((New-Object System.Net.WebClient).DownloadString('https://nyetbrains.net/variants/list.txt') -split "\n")
    return $VariantText
}

function Get-Random {
    # Random word generator for folder names
    return ((invoke-webrequest -Uri "https://random-word-api.herokuapp.com/word?number=1&swear=0").content | convertfrom-json)
}

function Get-Installed {
    return Get-ChildItem $HomeDir"\variants" | Where-Object {$_.PSIsContainer} | Foreach-Object {$_.Name}
}

function Set-Name {
    param ($NewName)

    if (-not ($NewName[0] -match "[a-zA-Z]")) {
        Write-Output "A name must begin with a letter!"
        exit
    }

    return $NewName
}

function Show-Text {
    Write-Output $HelpText
    exit
}

function Show-Variants {
    Write-Output "Available variants:"
    foreach ($i in $VariantList) {
        Write-Output ("- "+$i)
    }
    exit
}

function Show-Installed {
    # Gets all folders in the home folder and stores it as an array 
    $InstalledVariants = Get-Installed

    Write-Output "Variant`t`tName"
    Write-Output "--------------------------"
    foreach ($Var in $InstalledVariants) {
        $Split = $Var.split("-")

        # Handling for non-standard names
        if (($Split.count) -gt 1 -and $VariantList -contains $Split[0]) {
            Write-Output "$($Split[0])`t`t$($Split[0..-1] -join "-")"
        } else {
            Write-Output "???`t`t$($Split -join "-")"
        }
        
    }
    exit
}

function Show-Extensions {
    param($DirName)

    if (-not $DirName) {
        Write-Output "No instance name was given"
        exit
    }

    if ((Get-Installed) -contains $DirName) {
        Write-Output (code --extensions-dir="$HomeDir\variants\$DirName\Extensions" --list-extensions)
    } else {
        Write-Output "Could not find instance $DirName"
    }
    
    exit
}

function Create-Shortcut {

    if (-not (Test-Path -Path "$HomeDir\icons\$Variant.ico" -PathType Leaf)) {
        (New-Object System.Net.WebClient).DownloadFile("https://nyetbrains.net/icons/$Variant.ico", "$HomeDir\icons\$Variant.ico")
    }

    $Shell = New-Object -ComObject ("WScript.Shell")
    $ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\Desktop\$Name.lnk")
    $ShortCut.TargetPath = "code"
    $ShortCut.Arguments = " --user-data-dir=$HomeDir\variants\$DirName --extensions-dir=$HomeDir\variants\$DirName\Extensions | exit"
    $ShortCut.IconLocation = "$HomeDir\icons\$Variant.ico"
    $ShortCut.Save()
    exit
}

function Create-Variant {
    $DirName = $Variant + "-" + (Get-Random)
    if (-not ($Name -eq "")) {
        $DirName = $Variant + "-" +$Name
    }

    try {
        New-Item -Path "$HomeDir\variants\$DirName" -ItemType Directory -ErrorAction Stop | Out-Null
        New-Item -Path "$HomeDir\variants\$DirName\Extensions" -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Error -Message "Unable to create directories. Error was: $_" -ErrorAction Stop
    }

    if ($Variant -ne "blank") {
        try {
            New-Item -Path "$HomeDir\variants\$DirName\User" -ItemType Directory -ErrorAction Stop | Out-Null
            (New-Object System.Net.WebClient).DownloadFile("https://nyetbrains.net/variants/$Variant/settings.json", "$HomeDir\variants\$DirName\User\settings.json")
            (New-Object System.Net.WebClient).DownloadFile("https://nyetbrains.net/variants/$Variant/keybindings.json", "$HomeDir\variants\$DirName\User\keybindings.json")

            $BaseCommand = "code --extensions-dir=$HomeDir\variants\$DirName\Extensions"
            foreach ($Ext in ((New-Object System.Net.WebClient).DownloadString("https://nyetbrains.net/variants/$Variant/extensions.txt") -split "\n")) {
                $BaseCommand += " --install-extension $Ext"
            }

            (Invoke-Expression $BaseCommand)

        } catch {
            Write-Error -Message "Unable to download files. Error was: $_" -ErrorAction Stop
        }
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
        "-h\b|--help\b" {Show-Text}
        "-n\b|--name\b" {$Name = (Set-Name $args[$i+1])}
        "-ns\b|--no-shortcut\b" {$NoShortcut = $true}
        "-l\b|--list\b" {Show-Variants}
        "-i\b|--installed\b" {Show-Installed}
        "-e\b|--extensions\b" {Show-Extensions $args[$i+1]}
        default {
            if ($args[$i][0] -eq "-") {
                Write-Output "Argument not found: "$args[$i]
                exit
            } elseif ($i -eq ($args.count-1)) {
                if (-not ($VariantList -contains $args[$i])) {
                    Write-Output "Could not find variant: "$args[$i]
                } else {
                    $Variant = $args[$i]
                    Create-Variant
                }   
            } 
        }
    }
}