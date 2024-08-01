$ytDlpPath = Join-Path $PSScriptRoot "yt-dlp.exe"

function Invoke-YtDlp {
    param (
        [string]$Arguments
    )
    $ytDlpBaseCommand = "& `"$ytDlpPath`" --cookies-from-browser firefox"
    Invoke-Expression "$ytDlpBaseCommand $Arguments"
}

function Get-VideoResolutions {
    param (
        [string]$Output
    )
    $Output | Select-String -Pattern "(\d+)\s+(mp4\s+\d+x\d+)" -AllMatches | 
    ForEach-Object { $_.Matches } | 
    ForEach-Object { ,@($_.Groups[1].Value, $_.Groups[2].Value) }
}

function Show-ResolutionOptions {
    param (
        [array]$Resolutions
    )
    Write-Host "Available resolutions:"
    for ($i = 0; $i -lt $Resolutions.Count; $i++) {
        Write-Host "$($i + 1). $($Resolutions[$i][1])"
    }
}

function Download-PatreonVideo {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PostId
    )

    $URL = "https://www.patreon.com/posts/$PostId"
    $output = Invoke-YtDlp "-F $URL"

    $videoResolutions = Get-VideoResolutions $output
    Show-ResolutionOptions $videoResolutions

    $choice = Read-Host "Select resolution"
    $resolutionId = $videoResolutions[$choice - 1][0]

    $outputPath = Join-Path $PSScriptRoot "patreon\%(title)s.%(ext)s"
    Invoke-YtDlp "-f $resolutionId -o `"$outputPath`" $URL"
}

$postId = Read-Host "Enter post id"
Download-PatreonVideo -PostId $postId