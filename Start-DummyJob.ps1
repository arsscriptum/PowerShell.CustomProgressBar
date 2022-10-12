
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $True, Position = 0, HelpMessage="Run for x seconds")] 
    [int]$Seconds
)


. "$PSScriptRoot\SimpleProgress.ps1"


$DummyJobScript = {
      param($RunForSeconds)
  
    try{
        Write-Output "=============== JOB STARTED ==============="
        [Datetime]$StopTime = [Datetime]::Now.AddSeconds($RunForSeconds)
        $Running = $True
        While($Running){
            $tspan = new-timespan ([Datetime]::Now) ($StopTime)
            $RemainingSeconds = $tspan.Seconds
            [int]$PercentComplete = [math]::Round( 100 * ( $RemainingSeconds /  $RunForSeconds) )
            $strout = "[{0:d2} %] .... .... .... .... .... .... [{1:d2} %]" -f $PercentComplete,$PercentComplete
            Write-Output $strout
            Start-Sleep 1
            if([Datetime]::Now -gt $StopTime){
                Write-Output "============== JOB COMPLETED =============="
                $Running = $False
            }
        }
    }catch{
        Write-Error $_ 
    }finally{
        Write-Verbose "============== JOB COMPLETED =============="
}}.GetNewClosure()

[scriptblock]$DummyJobScriptBlock = [scriptblock]::create($DummyJobScript) 



function Invoke-DummyJob{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0, HelpMessage="Run for x seconds")] 
        [int]$Seconds,
        [Parameter(Mandatory = $false,Position=1, HelpMessage="The estimated time the process will take")]
        [int]$EstimatedSeconds=0,
        [Parameter(Mandatory = $False,Position=2, HelpMessage="The size of the progress bar")] 
        [int]$Size=30,
        [Parameter(Mandatory = $False,Position=3, HelpMessage="Update delay")] 
        [int]$Update=100
    )
    try{

        # Default
        #Initialize-AsciiProgressBar

        Initialize-AsciiProgressBar $EstimatedSeconds $Size
        
        $JobName = "DummyJob"
        $Working = $True
        $jobby = Start-Job -Name $JobName -ScriptBlock $DummyJobScriptBlock -ArgumentList ($Seconds)
        while($Working){
            try{
              
                # Default
                # Show-AsciiProgressBar

                Show-AsciiProgressBar $Update 5 "Yellow"

                $JobState = (Get-Job -Name $JobName).State

                Write-verbose "JobState: $JobState"
                if($JobState -eq 'Completed'){
                    $Working = $False
                }

            }catch{
                Write-Error $_
            }
        }
        
        $Data = Receive-Job -Name $JobName
        Get-Job $JobName | Remove-Job
        #$Data 
     }catch{
        Write-Error $_ 
    }
}


function Write-Title($Title){
    [int]$len = ([System.Console]::WindowWidth - 1)
    [string]$empty = [string]::new("=",$len)

    cls
    $TitleLen = $Title.Length
    $posx = ([System.Console]::get_BufferWidth()/2) - ($TitleLen/2)
    Write-ConsoleExtended $empty -f Yellow 
    Write-ConsoleExtended "$Title" -x $posx -y ([System.Console]::get_CursorTop()+1) -f Red
    Write-ConsoleExtended "`n$empty`n" -f Yellow ;
}


Write-Title "TEST 1 - Invoke-DummyJob"
Invoke-DummyJob $Seconds

Write-Title "TEST 2 - Invoke-DummyJob $Seconds $Seconds 40 50"
Invoke-DummyJob $Seconds $Seconds 40 50

# $Seconds $Seconds 90 50
