# A Custom PowerShell ProgressBar / Animation

---------------------------------------------------------------------------------------------------------

### RATIONALE

To provides a nice, compact way to display the progress of longer-running tasks in PowerShell. Show that the jobs are active and provide time remaining.

You can use it as a replacement for Write-Progress. While this has the advantage of being a "native" cmdlet with a few options to customize the progress of tasks, it occupies a bit of real estate in the PowerShell window (the upper portion of the console), sometimes hiding interesting information. 

Both ```Show-ActivityIndicatorBar``` and ```Show-AsciiProgressBar```  function is only a single line of text, at the current cursor position, and does not hide any output or status messages from other commands.

The ```Show-ActivityIndicatorBar``` function shows an animation to represent activity in the job

The ```Show-AsciiProgressBar``` displays a progress bar with completion percentage

---------------------------------------------------------------------------------------------------------


### HOW TO USE

```Initialize-AsciiProgressBar```

Called once, before the job is started. Initialize the progress bar with default settings, no countdown timer sizr of 30 character

```Initialize-AsciiProgressBar 30 30```
Initialize the progress bar so that it will diaplay a countdown timer for 30 seconds


```Show-ActivityIndicatorBar```
Called at every iteration of the loop
Shows an animation to represent activity in the job

```Show-AsciiProgressBar```

Called at every iteration of the loop
Without any arguments, Show-AsciiProgressBar displays a progress bar refreshing at every 100 milliseconds.
If no value is provided for the Activity parameter, it will simply say "Current Task" and the completion percentage.

```Show-AsciiProgressBar 50 5 "Yellow"```
Displays a progress bar refreshing at every 50 milliseconds in Yellow color


---------------------------------------------------------------------------------------------------------
### EXAMPLE

You can use Get-Help to view the help for the function or use the switch -Examples to see some usage examples from the function's native help. Of course, the best way to test and understand Show-Progress is to put it to work. Let's look at a few usage scenarios.

Use the provided dummy job code for example
```
    Get-Help Show-AsciiProgressBar -Examples
```

Start a dummy job with ASCII progress bar

```

	. .\Start-DummyJob.ps1 10

```

### Activity Indicator
![Activity Indicator](https://arsscriptum.github.io/assets/img/posts/custom-progressbar/ActivityIndicator.gif)

### Progress Bar
![Progress Wheel](https://arsscriptum.github.io/assets/img/posts/custom-progressbar/ProgressWheel.gif)

### Progress Bar Demo
![Progress Wheel Demo](https://arsscriptum.github.io/assets/img/posts/custom-progressbar/ProgressWheelDemo.gif)
