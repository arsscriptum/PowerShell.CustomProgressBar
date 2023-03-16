$SpinnerNames = "$PSScriptRoot\Spinners\SpinnerNames.ps1"
. "$SpinnerNames"

$MySpinners = Get-Content "F:\Scripts\PowerShell.Reddit.Support\Progress.Spinners\Spinners\CustomSpinners.json" -Encoding utf8 | ConvertFrom-Json
$List = [System.Collections.ArrayList]::new()
 ForEach($name in $Script:SpinnerNames){
     $spin = $MySpinners."$name"
     [PsCustomObject]$NewObject = [PsCustomObject]@{
        interval = $spin.interval
        frames = $spin.frames
        name  = $name
     }

     [void]$List.Add($NewObject)
 }


ConvertTo-Json -InputObject  $List | Set-Content "F:\Scripts\PowerShell.Reddit.Support\Progress.Spinners\Spinners\SpinnersList.json"


