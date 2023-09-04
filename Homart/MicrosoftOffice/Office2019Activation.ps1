try {
    # Open PowerShell as an administrator and change directory
    Start-Process PowerShell -Verb RunAs -ArgumentList '-NoExit', 'cd "C:\Program Files\Microsoft Office\Office16"'

    # Run the commands one by one to activate Microsoft Office
    cscript ospp.vbs /setprt:1688
    cscript ospp.vbs /unpkey:6MWKP >nul
    cscript ospp.vbs /inpkey:NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP
    cscript ospp.vbs /sethst:10.59.0.11
    cscript ospp.vbs /act

    # Keep the PowerShell window open until the user closes it manually
    cmd /c pause | out-null
} catch {
    # Display an error message if an error occurs while executing the script
    Write-Output "An error occurred: $($_.Exception.Message)"
}
