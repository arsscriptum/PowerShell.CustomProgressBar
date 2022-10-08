



function Write-ConsoleExtended{
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

    # Save the current positions. If NoNewline switch is supplied, we should go back to these.
    $cursor_left         = [System.Console]::get_CursorLeft()
    $cursor_top          = [System.Console]::get_CursorTop()
    $fg_color            = [System.Console]::ForegroundColor
    $bg_color            = [System.Console]::BackgroundColor

    
    # Get the passed values of foreground and backgroun colors, and left and top cursor positions
    $new_fg_color = $ForegroundColor
    $new_bg_color = $BackgroundColor

    if ($PosX -ge 0) {
        $NewCursorLeft = $PosX
    } else {
        $NewCursorLeft = $cursor_left
    }

    if ($PosY -ge 0) {
        $NewCursorTop = $PosY
    } else {
        $NewCursorTop = $cursor_top
    }

    # if Clear switch is present, clear the current line on the console by writing " "
    if ( $Clear ) {                        
        $clearmsg = " " * ([System.Console]::WindowWidth - 1)  
        [System.Console]::SetCursorPosition(0, $NewCursorTop)
        [System.Console]::Write($clearmsg)            
    }

    # Update the console with the message.
    [System.Console]::ForegroundColor = $new_fg_color
    [System.Console]::BackgroundColor = $new_bg_color    
    [System.Console]::SetCursorPosition($NewCursorLeft, $NewCursorTop)
    if ( $NoNewline ) { 
        # Dont print newline at the end, set cursor back to original position
        [System.Console]::Write($Message)
        [System.Console]::SetCursorPosition($cursor_left, $cursor_top)
    } else {
        [System.Console]::WriteLine($Message)
    }    

    # Set foreground and backgroun colors back to original values.
    [System.Console]::ForegroundColor = $fg_color
    [System.Console]::BackgroundColor = $bg_color
}


[System.Diagnostics.Stopwatch]$Script:progressSw = [System.Diagnostics.Stopwatch]::new()

function Initialize-AsciiProgressBar{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position=0, HelpMessage="The estimated time the process will take")]
        [int]$EstimatedSeconds=0,
        [Parameter(Mandatory = $False,Position=1, HelpMessage="The size of the progress bar")] 
        [int]$Size=30
    )

    $Script:Max = $Size
    $Script:Half = $Size/2
    $Script:Index = 0
    $Script:Pos=0
    $Script:EstimatedSeconds = $EstimatedSeconds
    $Script:progressSw.Start()
    
    $e = "$([char]27)"
    #hide the cursor
    Write-Host "$e[?25l"  -NoNewline  
}

function Update-AsciiProgressBar{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position=0, HelpMessage="The interval at which the progress will update.")]
        [int]$UpdateDelay=100,
        [Parameter(Mandatory = $False,Position=1, HelpMessage="The delay this function will sleep for, in ms. Used to replace the sleed in calling job")] 
        [int]$ProgressDelay=5,
        [Parameter(Mandatory = $False, HelpMessage="Empty char in the ascii progress bar")]
        [char]$EmptyChar = '-',
        [Parameter(Mandatory = $False, HelpMessage="Full char in the ascii progress bar")]
        [char]$FullChar = 'O'
    )
 
    $ms = $Script:progressSw.Elapsed.TotalMilliseconds
    if($ms -lt $UpdateDelay){
        return
    }
    
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
        $str += "$EmptyChar"
    }
    $str += "$FullChar"
    For($a = $Half ; $a -gt $Script:Pos ; $a--){
        $str += "$EmptyChar"
    }
    $ElapsedTimeStr = ''
    $ts =  [timespan]::fromseconds($Script:ElapsedSeconds)
    if($ts.Ticks -gt 0){
        $ElapsedTimeStr = "{0:mm:ss}" -f ([datetime]$ts.Ticks)
    }
    $ProgressMessage = "Progress: [{0}] {1}" -f $str, $ElapsedTimeStr
    Write-ConsoleExtended "$ProgressMessage" -ForegroundColor "Gray"  -Clear -NoNewline
    Start-Sleep -Milliseconds $ProgressDelay
}
