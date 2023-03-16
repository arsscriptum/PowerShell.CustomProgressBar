<#
#̷𝓍    𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍    🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

$SpinnersJson = (Resolve-Path "$PSScriptRoot\..\Spinners\SpinnersList.json").Path

# Include the custom write command script.

$WriteExtScript = (Resolve-Path "$PSScriptRoot\..\Dependencies\Write-ConsoleExtended.ps1").Path
. "$WriteExtScript"

$PresedKeyscript = (Resolve-Path "$PSScriptRoot\..\Dependencies\Test-PresedKeys.ps1").Path
. "$PresedKeyscript"

$Script:OldEncoding = [Console]::OutputEncoding

# Two simple functions to show/hide the cursor while our loop is running

function Start-CustomProgress{
    $e = "$([char]27)"
    #hide the cursor
    Write-Host "$e[?25l"  -NoNewline  
    $OldEncoding = [Console]::OutputEncoding
    # Create a simple loop running for 10 seconds..
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}


function Stop-CustomProgress{
    #restore scrolling region
    $e = "$([char]27)"
    Write-Host "$e[s$($e)[r$($e)[u" -NoNewline
    #show the cursor
    Write-Host "$e[?25h" 


    [Console]::OutputEncoding = $Script:OldEncoding
}

function Set-PreviousSpinner{
    $Script:CurrentIndex--
    if($Script:CurrentIndex -le 0){
        $Script:CurrentIndex = 0
    }elseif($Script:CurrentIndex -ge $Script:MaxSpinnerIndex){
        $Script:CurrentIndex = $Script:MaxSpinnerIndex
    }
}

function Set-NextSpinner{
    $Script:CurrentIndex++
    if($Script:CurrentIndex -le 0){
        $Script:CurrentIndex = 0
    }elseif($Script:CurrentIndex -ge $Script:MaxSpinnerIndex){
        $Script:CurrentIndex = $Script:MaxSpinnerIndex
    }
}

CLear-Host
Write-Host "################################################################################################" -ForegroundColor DarkGray
Write-Host "                              TESTING PROGRESS NOTIFIERS SPINNERS                               " -ForegroundColor Gray
Write-Host "################################################################################################" -ForegroundColor DarkGray
Write-Host "`nUse LeftArrow / RightArrow to go through spinners...`n" -f DarkCyan
# hide cursor
Start-CustomProgress

# Local Variables

$BaseMsg = "Testing Connections "
$FgColor = "Yellow"
$Seconds = 5
$NumDots = 0



$MySpinners = Get-Content $SpinnersJson -Encoding utf8 | ConvertFrom-Json

$Script:MaxSpinnerIndex = $MySpinners.Count - 1 
$Script:CurrentIndex = 0

while($true){
    
    $CurrentSpinner = $MySpinners.Get($Script:CurrentIndex)
    if(( $Null -eq $CurrentSpinner) -Or ($CurrentSpinner.frames -eq $Null) -Or ($CurrentSpinner.interval -eq $Null) ){
        Write-Warning "INVALID WIDGET $Script:CurrentIndex"
        Set-NextSpinner
        continue;
    }
    $BaseString = "Testing Spinner `"$($CurrentSpinner.name)`" : "
    $Index =0
    $Max = $CurrentSpinner.frames.Count

    [Datetime]$StopTime = [Datetime]::Now.AddSeconds($Seconds)
    While(([Datetime]::Now -lt $StopTime)){
       
       if($Index -ge $Max){$Index=1}
        $FrameStr = $CurrentSpinner.frames.Get($Index)
        if($False -eq [string]::IsNullOrEmpty($FrameStr)){
            $OutString = $BaseString + $FrameStr
            Write-ConsoleExtended "$OutString"  -ForegroundColor "$FgColor"   -Clear -NoNewline
        }
        $Index++
        Start-Sleep -Milliseconds $CurrentSpinner.interval

        $pressedkeynow = Test-PresedKeys
        if( $False -eq [string]::IsNullOrEmpty($pressedkeynow) ){
            switch($pressedkeynow){
                "RightArrow" { 
                    Set-NextSpinner
                }
                "LeftArrow" { 
                    Set-PreviousSpinner
                }
            }

            
            break;
        }
    }
    Set-NextSpinner
}


# hide cursor
Stop-CustomProgress

$key  = [Byte][Char]'K' ## Letter