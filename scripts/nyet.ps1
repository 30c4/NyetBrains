# Create Shortcut tutorial: http://powershellblogger.com/2016/01/create-shortcuts-lnk-or-url-files-with-powershell/
# How to run: Invoke-Expression(GC .\scripts\nyet.ps1 -Raw)

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
    return
}

function Show-Text {
    Write-Output $HelpText
    return
}

function Set-Name {
    param ($NewName)

    if (-not ($NewName[0] -match "[a-zA-Z]")) {
        throw "A name must begin with a letter!"
    }

    $Name = $NewName
}

function Show-Variants {
    return
}

function Show-Installed {
    return
}


$VariantList
$Variant = ""
$Name = ""
$NoShortcut = $false


if ($args.count -eq 0) {
    Show-Text
}

for ($i = 0; $i -lt $args.count; $i++) {
    if ($args[$args.count-1] in $VariantList) {
        $Variant = $args[$args.count-1]
    } else {
        throw "Could not find variant"
    }
    switch -Regex ($args[$i]) {
        "(-h|--help)\b" {Show-Text}
        "(-n|--name)\b" {Set-Name $args[$i+1]}
        "(-ns|--no-shortcut)\b" {$NoShortcut = $true}
        "(-l|--list)\b" {Show-Variants}
        "(-i|--installed)\b" {Show-Installed}
        default {continue}
    }
}