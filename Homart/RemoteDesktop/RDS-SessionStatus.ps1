# Define a function to disconnect a user session from a server
function Disconnect-UserSession {
    param(
        [string]$Server,
        [string]$SessionName
    )

    # Use the logoff command to disconnect the user session from the server
    try {
        logoff $SessionName /server:$Server
        Write-Output "Disconnected session '$SessionName' from server '$Server'"
    } catch {
        Write-Error "Error disconnecting session '$SessionName' from server '$Server'"
    }
}

# Define an array of server names
$servers = @("rds01", "rds02", "rds03", "rds04", "rds05", "rds06", "rds07", "rds08", "RDSApp01", "RDSApp02", "RDSApp03", "RDSApp04", "RDSApp05")

# Display the user sessions on each server
foreach ($server in $servers) {
    # Check if the server is reachable
    if (Test-Connection $server -Quiet -Count 1) {
        Write-Output ""
        Write-Output $server
        qwinsta /server:$server
    } else {
        Write-Warning "Server '$server' is not reachable"
    }
}

# Ask the user what they want to do
$action = Read-Host -Prompt "`nWhat would you like to do?`n[1] Find the username corresponding to a server`n[2] Disconnect a user by username and server`nPlease enter 1 or 2"

# If the user wants to find the username corresponding to a server
if ($action -eq 1) {
    $serverToFind = Read-Host -Prompt "`nEnter the server name"
    # Check if the server is reachable
    if (Test-Connection $serverToFind -Quiet -Count 1) {
        Write-Output ""
        Write-Output $serverToFind
        qwinsta /server:$serverToFind

        # Ask if the user wants to disconnect a user again
        $disconnectAgain = Read-Host -Prompt "`nDo you want to disconnect a user again? (yes/no)"
        if ($disconnectAgain -eq "yes") {
            $serverToDisconnect = Read-Host -Prompt "`nEnter the server name"
            $sessionToDisconnect = Read-Host -Prompt "`nEnter the session name"

            # Disconnect the specified user session from the specified server
            Disconnect-UserSession -Server $serverToDisconnect -SessionName $sessionToDisconnect
        }
    } else {
        Write-Warning "Server '$serverToFind' is not reachable"
    }
}
# If the user wants to disconnect a user by username and server
elseif ($action -eq 2) {
    $serverToDisconnect = Read-Host -Prompt "`nEnter the server name"
    $sessionToDisconnect = Read-Host -Prompt "`nEnter the session name"

    # Disconnect the specified user session from the specified server
    Disconnect-UserSession -Server $serverToDisconnect -SessionName $sessionToDisconnect
}

# Wait for the user to press Enter before exiting
Read-Host -Prompt "`nPress Enter to exit"
