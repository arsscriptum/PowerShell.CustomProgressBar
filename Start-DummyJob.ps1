
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false, HelpMessage="Run for x seconds")] 
    [int]$Seconds=5
)

$FatalError = $False
try{
. "$PSScriptRoot\SimpleProgress.ps1"  
}catch [Exception]{
    Write-Error $_ 
    $FatalError = $True
}
if($FatalError){
    return
}

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
        [int]$Update=100,
        [Parameter(Mandatory = $False,Position=4)] 
        [switch]$ProgressIndicator
    )
    try{

        if($ProgressIndicator){
            Initialize-AsciiProgressBar $EstimatedSeconds $Size ' ' '.'
        }else{
            Initialize-AsciiProgressBar $EstimatedSeconds $Size
        }
        
        $Script:LatestPercentage = 0
        [regex]$pattern = [regex]::new('([\[]+)(?<percent>[\d]+)([\%\ \]]+)')
        $JobName = "DummyJob"
        $Working = $True
        $jobby = Start-Job -Name $JobName -ScriptBlock $DummyJobScriptBlock -ArgumentList ($Seconds)
        while($Working){
            try{
            
                if($ProgressIndicator){
                   
                    $Data = Receive-Job -Name $JobName | Select -Last 1
                    if($Data -match $pattern){
                        [int]$percent = $Matches.percent
                        [int]$percent = 100 -$percent
                        $Script:LatestPercentage = $percent
                    }
                     $ProgressMessage = "Completed {0} %" -f $percent
                     Show-AsciiProgressBar $Script:LatestPercentage $ProgressMessage 50 2 "Gray" "Black"
                }else{
                    Show-ActivityIndicatorBar $Update 5 "Yellow"
                }
                $JobState = (Get-Job -Name $JobName).State

                Write-verbose "JobState: $JobState"
                if($JobState -eq 'Completed'){
                    $Working = $False
                }

            }catch{
                Write-Error $_
            }
        }
        Write-ConsoleExtended "Both tests completed successfully" -ForegroundColor "DarkGreen" -Clear
        $Data = Receive-Job -Name $JobName
        Get-Job $JobName | Remove-Job
        #$Data 
     }catch{
        Show-ExceptionDetails $_ -ShowStack 
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

$JobCount = (Get-Job).Count
Write-Host "Removing $JobCount thread jobs" -n
Get-Job | % { $n = $_.Name ;  Write-Host "$n " -n -f Red;Remove-Job $_ -Force ; }

Write-Title "TEST 1 - Actvity Indicator"
Invoke-DummyJob $Seconds $Seconds 40 50 

Write-Title "TEST 2 - Progress Indicator"
Invoke-DummyJob $Seconds $Seconds 40 50 -ProgressIndicator
