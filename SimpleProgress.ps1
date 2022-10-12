
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Write-ConsoleExtended{

<#
.SYNOPSIS
    Write a string in the console
.DESCRIPTION
    Write a string in the console at specific position and color
.PARAMETER Message
    Message to be printed
.PARAMETER PosX
   Cursor X position where message is to be printed
.PARAMETER PosY
    Cursor Y position where message is to be printed
.PARAMETER ForegroundColor
    Foreground color for the message
.PARAMETER BackgroundColor
    Background color for the message
.PARAMETER Clear
   Clear whatever is typed on this line currently
.PARAMETER NoNewline
    After printing the message, return the cursor back to its initial position
.EXAMPLE
    Write-ConsoleExtended "MY TITLE" -x ([System.Console]::get_BufferWidth()/2) -f Red
    Write a string in the center of screen in red
.NOTES
    Author: Guillaume Plante
    Last Updated: October 2022
#>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0, HelpMessage="Message to be printed")] 
        [Alias('m')]
        [string]$Message,
        [Parameter(Mandatory = $False, HelpMessage="Cursor X position where message is to be printed")] 
        [Alias('x')]
        [int] $PosX = -1,
        [Parameter(Mandatory = $False, HelpMessage="Cursor Y position where message is to be printed")] 
        [Alias('y')]
        [int] $PosY = -1,
        [Parameter(Mandatory = $False, HelpMessage="Foreground color for the message")] 
        [Alias('f')]
        [System.ConsoleColor] $ForegroundColor = [System.Console]::ForegroundColor,
        [Parameter(Mandatory = $False, HelpMessage="Background color for the message")] 
        [Alias('b')]
        [System.ConsoleColor] $BackgroundColor = [System.Console]::BackgroundColor,
        [Parameter(Mandatory = $False, HelpMessage="Clear whatever is typed on this line currently")] 
        [Alias('c')]
        [switch] $Clear,
        [Parameter(Mandatory = $False, HelpMessage="After printing the message, return the cursor back to its initial position.")] 
        [Alias('n')]
        [switch] $NoNewline
    ) 

    $fg_color            = [System.Console]::ForegroundColor
    $bg_color            = [System.Console]::BackgroundColor
    $cursor_top          = [System.Console]::get_CursorTop()
    $cursor_left         = [System.Console]::get_CursorLeft()

    $new_cursor_x = $cursor_left
    if ($PosX -ge 0) { $new_cursor_x = $PosX }
   
    $new_cursor_y = $cursor_top
    if ($PosY -ge 0) { $new_cursor_y = $PosY } 
    
    if ( $Clear ) { 
        [int]$len = ([System.Console]::WindowWidth - 1)  
        # use the string constructor for init a string with character 32 (space), len times
        [string]$empty = [string]::new([char]32,$len)                       
        
        [System.Console]::SetCursorPosition(0, $new_cursor_y)
        [System.Console]::Write($empty)            
    }
    [System.Console]::ForegroundColor = $ForegroundColor
    [System.Console]::BackgroundColor = $BackgroundColor
    
    [System.Console]::SetCursorPosition($new_cursor_x, $new_cursor_y)

    # Write the message, if NoNewline, go ack to beginning
    [System.Console]::Write($Message)
    if ( $NoNewline ) { 
        [System.Console]::SetCursorPosition($cursor_left, $cursor_top)
    }

    # back to previous colors
    [System.Console]::ForegroundColor = $fg_color
    [System.Console]::BackgroundColor = $bg_color
}


[System.Diagnostics.Stopwatch]$Script:progressSw = [System.Diagnostics.Stopwatch]::new()

function Stop-AsciiProgressBar{
    #restore scrolling region
    $e = "$([char]27)"
    Write-Host "$e[s$($e)[r$($e)[u" -NoNewline
    #show the cursor
    Write-Host "$e[?25h" 
}

function Start-AsciiProgressBar{
<#
.SYNOPSIS
    Initialize the Ascii Progress Bar
.DESCRIPTION
    Initialize the Ascii Progress Bar by seting the size of the bar in characters. If you set the EstimatedSeconds
    value, there will e a countdown timer in the progress bar.
.PARAMETER EstimatedSeconds
    The estimated time of the job that will be refreshing the progress bar. If this is set there will be a countdown
    timer in the progress message
.PARAMETER Size
    The size of the progress bar in characters
.PARAMETER EmptyChar
    The character used in the progress bar
.PARAMETER FullChar
    The character used in the progress bar
.EXAMPLE
    Initialize-AsciiProgressBar 30 
    Initialize the progress bar with default settings, no countdown timer sizr of 30 character
.EXAMPLE
    Initialize-AsciiProgressBar 30 30
    Initialize the progress bar so that it will diaplay a countdown timer for 30 seconds

.NOTES
    Author: Guillaume Plante
    Last Updated: October 2022
#>


    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position=0, HelpMessage="The estimated time the process will take")]
        [int]$EstimatedSeconds=0,
        [Parameter(Mandatory = $False,Position=1, HelpMessage="The size of the progress bar")] 
        [int]$Size=30,
        [Parameter(Mandatory = $False,Position=2, HelpMessage="Empty char in the ascii progress bar")]
        [char]$EmptyChar = '-',
        [Parameter(Mandatory = $False,Position=3, HelpMessage="Full char in the ascii progress bar")]
        [char]$FullChar = 'O'
    )

    $Script:CurrentSpinnerIndex = 0
    $Script:Max = $Size
    $Script:Half = $Size/2
    $Script:Index = 0
    $Script:Pos=0
    $Script:EstimatedSeconds = $EstimatedSeconds
    $Script:EmptyChar = $EmptyChar
    $Script:FullChar = $FullChar
    $Script:progressSw.Start()
    [Datetime]$Script:StartTime = [Datetime]::Now
    $e = "$([char]27)"
    #hide the cursor
    Write-Host "$e[?25l"  -NoNewline  
}

New-Alias -Name Initialize-AsciiProgressBar -Value Start-AsciiProgressBar -Force -ErrorAction Ignore | Out-Null


function Show-ActivityIndicatorBar{

<#
.SYNOPSIS
    Displays the completion status for a running task.
.DESCRIPTION
    Show-ActivityIndicatorBar displays the progress of a long-running activity, task, 
    operation, etc. It is displayed as a progress bar, along with the 
    completed percentage of the task. It displays on a single line (where 
    the cursor is located). As opposed to Write-Progress, it doesn't hide 
    the upper block of text in the PowerShell console.
.PARAMETER UpdateDelay
    The 'refresh' interval for the update of the progress bar. This will **not** sleep.
    If the function is called 100 times per seconds and the UpdateDelay is 100, the progress bar will be
    refreshed once every 100 milliseconds, **not** 100*seconds 
.PARAMETER ProgressDelay
    Amount of time between two 'refreshes' of the percentage complete and update
    of the progress bar. This is a sleep in the function. Default is 5 ms
.PARAMETER ForegroundColor
    Foreground color for the message
.PARAMETER BackgroundColor
    Background color for the message
.PARAMETER EmptyChar
    The character used in the progress bar
.PARAMETER FullChar
    The character used in the progress bar
.EXAMPLE
    Show-ActivityIndicatorBar
    Without any arguments, Show-ActivityIndicatorBar displays a progress bar refreshing at every 100 milliseconds.
    If no value is provided for the Activity parameter, it will simply say 
    "Current Task" and the completion percentage.
.EXAMPLE
    Show-ActivityIndicatorBar 50 5 "Yellow"
    Displays a progress bar refreshing at every 50 milliseconds in Yellow color
.NOTES
    Author: Guillaume Plante
    Last Updated: October 2022
#>


    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position=0, HelpMessage="The interval at which the progress will update.")]
        [int]$UpdateDelay=100,
        [Parameter(Mandatory = $False,Position=1, HelpMessage="The delay this function will sleep for, in ms. Used to replace the sleed in calling job")] 
        [int]$ProgressDelay=5,
        [Parameter(Mandatory = $False,Position=2, HelpMessage="Foreground color for the message")] 
        [Alias('f')]
        [System.ConsoleColor] $ForegroundColor = [System.Console]::ForegroundColor,
        [Parameter(Mandatory = $False,Position=3, HelpMessage="Background color for the message")] 
        [Alias('b')]
        [System.ConsoleColor] $BackgroundColor = [System.Console]::BackgroundColor
    )
 
    $ms = $Script:progressSw.Elapsed.TotalMilliseconds
    if($ms -lt $UpdateDelay){
        return
    }
    $ElapsedSeconds = [Datetime]::Now - $Script:StartTime
    $Script:progressSw.Restart()
    $Script:Index++
    $Half = $Max / 2
    if($Index -ge $Max){ 
        $Script:Pos=0
        $Script:Index=0
    }elseif($Index -ge $Half){ 
        $Script:Pos = $Max-$Index
    }else{
        $Script:Pos++
    }

    $str = ''
    For($a = 0 ; $a -lt $Script:Pos ; $a++){
        $str += "$Script:EmptyChar"
    }
    $str += "$Script:FullChar"
    For($a = $Half ; $a -gt $Script:Pos ; $a--){
        $str += "$Script:EmptyChar"
    }
    $ElapsedTimeStr = ''

    $secsofar =  $Script:EstimatedSeconds - $ElapsedSeconds.TotalSeconds
    $ts =  [timespan]::fromseconds($secsofar)
    if($ts.Ticks -gt 0){
        $ElapsedTimeStr = "{0:mm:ss}" -f ([datetime]$ts.Ticks)
    }
    $ProgressMessage = "Progress: [{0}] {1}" -f $str, $ElapsedTimeStr
    Write-ConsoleExtended "$ProgressMessage" -ForegroundColor "$ForegroundColor" -BackgroundColor "$BackgroundColor"  -Clear -NoNewline
    Start-Sleep -Milliseconds $ProgressDelay
}


function Show-AsciiProgressBar{

<#
.SYNOPSIS
    Displays the completion status for a running task.
.DESCRIPTION
    Show-AsciiProgressBar displays the progress of a long-running activity, task, 
    operation, etc. It is displayed as a progress bar, along with the 
    completed percentage of the task. It displays on a single line (where 
    the cursor is located). As opposed to Write-Progress, it doesn't hide 
    the upper block of text in the PowerShell console.
.PARAMETER Percentage
    Completion percentage
.PARAMETER UpdateDelay
    The 'refresh' interval for the update of the progress bar. This will **not** sleep.
    If the function is called 100 times per seconds and the UpdateDelay is 100, the progress bar will be
    refreshed once every 100 milliseconds, **not** 100*seconds 
.PARAMETER ProgressDelay
    Amount of time between two 'refreshes' of the percentage complete and update
    of the progress bar. This is a sleep in the function. Default is 5 ms
.PARAMETER ForegroundColor
    Foreground color for the message
.PARAMETER BackgroundColor
    Background color for the message

.EXAMPLE
    Show-AsciiProgressBar
    Without any arguments, Show-AsciiProgressBar displays a progress bar refreshing at every 100 milliseconds.
    If no value is provided for the Activity parameter, it will simply say 
    "Current Task" and the completion percentage.
.EXAMPLE
    Show-AsciiProgressBar 50 5 "Yellow"
    Displays a progress bar refreshing at every 50 milliseconds in Yellow color
.NOTES
    Author: Guillaume Plante
    Last Updated: October 2022
#>


    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True,Position=0, HelpMessage="Completion percentage.")]
        [ValidateRange(0, 100)]
        [int]$Percentage,
        [Parameter(Mandatory = $false,Position=1, HelpMessage="Completion percentage.")]
        [string]$Message="",
        [Parameter(Mandatory = $false,Position=2, HelpMessage="The interval at which the progress will update.")]
        [int]$UpdateDelay=100,
        [Parameter(Mandatory = $False,Position=3, HelpMessage="The delay this function will sleep for, in ms. Used to replace the sleed in calling job")] 
        [int]$ProgressDelay=5,
        [Parameter(Mandatory = $False,Position=4, HelpMessage="Foreground color for the message")] 
        [Alias('f')]
        [System.ConsoleColor] $ForegroundColor = [System.Console]::ForegroundColor,
        [Parameter(Mandatory = $False,Position=5, HelpMessage="Background color for the message")] 
        [Alias('b')]
        [System.ConsoleColor] $BackgroundColor = [System.Console]::BackgroundColor
    )

    $ms = $Script:progressSw.Elapsed.TotalMilliseconds
    if($ms -lt $UpdateDelay){
        return
    }

    $spinners = @( "-","\","|","/")
    $Script:CurrentSpinnerIndex++
    if($Script:CurrentSpinnerIndex -ge $spinners.Count){
        $Script:CurrentSpinnerIndex = 0
    }
    $CurrentSpinner = $spinners[$Script:CurrentSpinnerIndex]

    $ElapsedSeconds = [Datetime]::Now - $Script:StartTime
    $Script:progressSw.Restart()
   
    $Script:Pos = [math]::Round(($Script:Max / 100) * $Percentage)
    

    $str = ''
    For($a = 0 ; $a -lt $Script:Pos ; $a++){
        $str += "$Script:FullChar"
    }
    $str += $CurrentSpinner
    For($a = $Script:Pos ; $a -lt $Script:Max ; $a++){
        $str += "$Script:EmptyChar"
    }

    $ElapsedTimeStr = ''

    $secsofar =  $Script:EstimatedSeconds - $ElapsedSeconds.TotalSeconds
    $ts =  [timespan]::fromseconds($secsofar)
    if($ts.Ticks -gt 0){
        $ElapsedTimeStr = "{0:mm:ss}" -f ([datetime]$ts.Ticks)
    }
    $ProgressMessage = "Progress: [{0}] {1} {2}" -f $str, $ElapsedTimeStr, $Message
    Write-ConsoleExtended "$ProgressMessage" -ForegroundColor "$ForegroundColor" -BackgroundColor "$BackgroundColor"  -Clear -NoNewline
    Start-Sleep -Milliseconds $ProgressDelay
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
