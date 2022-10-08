# A Custom PowerShell ProgressBar / Animation

---------------------------------------------------------------------------------------------------------

### RATIONALE

To provides a nice, compact way to display the progress of longer-running tasks in PowerShell. Show that the jobs are active and provide time remaining.

You can use it as a replacement for Write-Progress. While this has the advantage of being a "native" cmdlet with a few options to customize the progress of tasks, it occupies a bit of real estate in the PowerShell window (the upper portion of the console), sometimes hiding interesting information. 

The ```Show-AsciiProgressBar``` function is only a single line of text, at the current cursor position, and does not hide any output or status messages from other commands.

---------------------------------------------------------------------------------------------------------


### HOW TO USE

```Initialize-AsciiProgressBar```

Called once, before the job is started

```Show-AsciiProgressBar```

Called at every iteration of the loop

---------------------------------------------------------------------------------------------------------
### EXAMPLE

