    
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


# Include the custom write command script.

$WriteExtScript = "$PSScriptRoot\Dependencies\Write-ConsoleExtended.ps1"
. "$WriteExtScript"


# Two simple functions to show/hide the cursor while our loop is running

function Start-ProgressNotifier{
    $e = "$([char]27)"
    #hide the cursor
    Write-Host "$e[?25l"  -NoNewline  
}


function Stop-ProgressNotifier{
    #restore scrolling region
    $e = "$([char]27)"
    Write-Host "$e[s$($e)[r$($e)[u" -NoNewline
    #show the cursor
    Write-Host "$e[?25h" 
}


function Invoke-ProgressNotifier{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, position = 0)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [int]$Delay=5,
        [Parameter(Mandatory = $false)]
        [string]$FgColor="DarkRed",
        [Parameter(Mandatory = $false)]
        [string]$SpinnerName="aesthetic"
    )
    # Local Variables

    # hide cursor
    Start-ProgressNotifier

    $SpinnersJson = "$PSScriptRoot\Spinners\SpinnersList.json"
    $MySpinners = Get-Content $SpinnersJson -Encoding utf8 | ConvertFrom-Json
    $CurrentSpinner =  $MySpinners | Where Name -eq "$SpinnerName"
    if($CurrentSpinner -eq $Null){
        throw "spinner not found `"$SpinnerName`""
    }
    $Index =0
    $Max = $CurrentSpinner.frames.Count
    # Create a simple loop running for 10 seconds..

    [Datetime]$StopTime = [Datetime]::Now.AddSeconds($Delay)
    While(([Datetime]::Now -lt $StopTime)){

        if($Index -ge $Max){$Index=1}
        $FrameStr = $CurrentSpinner.frames.Get($Index)
        if($False -eq [string]::IsNullOrEmpty($FrameStr)){
            $OutString = $Message + $FrameStr
            Write-ConsoleExtended "$OutString"  -ForegroundColor "$FgColor"   -Clear -NoNewline
        }
        $Index++
        Start-Sleep -Milliseconds $CurrentSpinner.interval
    }

    # hide cursor
    Stop-ProgressNotifier
}



CLear-Host
Write-Host "################################################################################################" -ForegroundColor DarkGray
Write-Host "                              TESTING PROGRESS NOTIFIERS SPINNERS                               " -ForegroundColor Gray
Write-Host "################################################################################################" -ForegroundColor DarkGray


Invoke-ProgressNotifier -Message "Testing Connection Special " -FgColor "DarkCyan" -SpinnerName "aesthetic" -Delay 5

Invoke-ProgressNotifier -Message "Testing Fist Bumps " -FgColor "DarkYellow" -SpinnerName "fistBump" -Delay 5

Invoke-ProgressNotifier -Message "Progressing in time " -FgColor "Blue" -SpinnerName "clock" -Delay 5
Invoke-ProgressNotifier -Message "Ascii progress is fun " -FgColor "Magenta" -SpinnerName "material" -Delay 5
Invoke-ProgressNotifier -Message "Last one " -FgColor "Magenta" -SpinnerName "soccerHeader" -Delay 5
Invoke-ProgressNotifier -Message "Mind blown " -FgColor "Yellow" -SpinnerName "mindblown" -Delay 5
