try {
    # Prompt the user to enter the delay time
    $delay = Read-Host -Prompt 'Enter the delay time (e.g. 10s, 5m, 1h)'
    # Validate the user's input using a regular expression
    if ($delay -match '^\d+[smh]$') {
        # Extract the time unit and value from the user's input
        $unit = $delay.Substring($delay.Length - 1)
        $time = [int]$delay.Substring(0, $delay.Length - 1)

        # Convert the time value to seconds based on the time unit
        switch ($unit) {
            's' { $seconds = $time }
            'm' { $seconds = $time * 60 }
            'h' { $seconds = $time * 3600 }
            default { Write-Output "Invalid time unit"; exit }
        }

        # Display a message indicating the shutdown time and how to cancel it
        Write-Output "Shutting down in $seconds seconds. Press any key to cancel shutdown."
        # Countdown from the specified time and update the display every second
        for ($i = $seconds; $i -gt 0; $i--) {
            Write-Host "`rTime remaining: $i seconds" -NoNewline
            Start-Sleep -Seconds 1
            # Check if a key has been pressed to cancel the shutdown
            if ($host.UI.RawUI.KeyAvailable) {
                $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                Write-Host "`nShutdown cancelled"
                exit
            }
        }
        # Shutdown the computer if the countdown completes
        Stop-Computer
    } else {
        # Display an error message if the user's input is not in the correct format
        Write-Output "Invalid delay time format"
    }
} catch {
    # Display an error message if an error occurs while executing the script
    Write-Output "An error occurred: $($_.Exception.Message)"
}
