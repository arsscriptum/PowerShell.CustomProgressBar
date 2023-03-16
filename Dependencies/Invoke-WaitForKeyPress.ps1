
function Invoke-WaitForKeyPress{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0, HelpMessage="Run for x seconds")] 
        [int]$Seconds
    )

    $ProgressMessage = "Waiting for keypress..."
    $keypressed = $Null

    Initialize-AsciiProgressBar -EmptyChar ' ' -FullChar '=' -Size $Seconds
    [Datetime]$StopTime = [Datetime]::Now.AddSeconds($Seconds)
    While(([Datetime]::Now -lt $StopTime)){

        $tspan = new-timespan ([Datetime]::Now) ($StopTime)
        $RemainingSeconds = $tspan.Seconds
        [int]$PercentComplete = [math]::Round( 100 * ( $RemainingSeconds /  $Seconds) )
        Show-AsciiProgressBar $PercentComplete $ProgressMessage -Clean

        $keypressed = Test-PresedKeys
        if([string]::IsNullOrEmpty($keypressed) -eq $False){
            Show-AsciiProgressBar 100 "Done"  -Clean
             Start-Sleep -Milliseconds 200
            break;
        }
      
        Start-Sleep -Milliseconds 200
    }

    if([string]::IsNullOrEmpty($keypressed) -eq $False){
        Write-ConsoleExtended "[$keypressed] " -f DarkCyan -c
    }else{
        Write-ConsoleExtended "TIMEOUT" -f DarkRed -c
    }
}