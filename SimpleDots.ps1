    
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


# Include the custom write command script.

$WriteExtScript = "$PSScriptRoot\Write-ConsoleExtended.ps1"
. "$WriteExtScript"


# Two simple functions to show/hide the cursor while our loop is running

function Start-Dots{
    $e = "$([char]27)"
    #hide the cursor
    Write-Host "$e[?25l"  -NoNewline  
}


function Stop-Dots{
    #restore scrolling region
    $e = "$([char]27)"
    Write-Host "$e[s$($e)[r$($e)[u" -NoNewline
    #show the cursor
    Write-Host "$e[?25h" 
}




$Script:Seconds = 10


$ForegroundColor = "Yellow"

$NumDots = 0



Start-Dots

[Datetime]$StopTime = [Datetime]::Now.AddSeconds($Script:Seconds)
While(([Datetime]::Now -lt $StopTime)){
   
    if($NumDots -lt 3){
        $DotsStr = '' 
        0 .. $NumDots | % { $DotsStr += "." }
        Write-ConsoleExtended "$DotsStr"  -ForegroundColor "$ForegroundColor"   -Clear -NoNewline
        $NumDots++
    }else{
        $NumDots = 0
        Write-ConsoleExtended " "  -NoNewline -Clear
    }

    Start-Sleep 1
}

Stop-Dots

