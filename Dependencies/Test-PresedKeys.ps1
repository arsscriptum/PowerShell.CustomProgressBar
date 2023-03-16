<#
#̷𝓍    𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍    🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


function Test-PresedKeys {

    $converter = @{
        Shift = 16
        Space = 32
        LeftArrow = 37
        RightArrow = 39
        Backspace = 8
        MouseRight = 2
        MouseKeft = 1
      }


    $list = [System.Collections.Generic.List[int]]::new()
    $converter.GetEnumerator() | % {
        $list.Add($_.Value)
    }
      # this is the c# definition of a static Windows API method:
    $Signature = @'
        [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
        public static extern short GetAsyncKeyState(int virtualKeyCode); 
'@


    if (!("KeyApi.Keyboard" -as [type])) {
        Write-Host "Registering KeyApi... " 
        try{ 
            Add-Type -MemberDefinition $Signature -Name Keyboard -Namespace KeyApi 
        } catch {
            Write-Warning "Registration Error"
        }
    }

    $keypressed = ''
    foreach ($keyid in $list){
        
        $pressed = [bool]([KeyApi.Keyboard]::GetAsyncKeyState($keyid) -eq -32767)
            if ($pressed) { 
            $converter.GetEnumerator() | % {
                if($_.value -eq $keyid){
                    $keypressed = $_.key
                    $keypressed = $keypressed.Trim()
                    return "$keypressed"
                }
            }
        }
    }

    return $Null
}

