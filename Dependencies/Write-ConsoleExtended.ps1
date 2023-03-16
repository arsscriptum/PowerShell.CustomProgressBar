    
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