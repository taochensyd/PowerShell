# Set the path to the WeChat folder
$WeChatFolder = "$env:AppData\Tencent\WeChat"

# Check if the WeChat folder exists
if (Test-Path $WeChatFolder) {
    Write-Host "The WeChat folder exists at $WeChatFolder"
    # Prompt user for confirmation before deleting the WeChat folder
    $confirmation = Read-Host "Are you sure you want to delete the WeChat folder? (y/n)"
    if ($confirmation -eq "y") {
        # Delete the WeChat folder
        try {
            Remove-Item $WeChatFolder -Recurse -Force -ErrorAction Stop
            Write-Host "The WeChat folder has been deleted"
        } catch {
            Write-Host "An error occurred while trying to delete the WeChat folder: $($_.Exception.Message)"
        }
    } else {
        Write-Host "Deletion of the WeChat folder has been cancelled"
    }
} else {
    Write-Host "The WeChat folder does not exist at $WeChatFolder"
}

# Open WeChat.exe
try {
    Start-Process "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe" -ErrorAction Stop
    Write-Host "WeChat has been successfully opened"
} catch {
    Write-Host "An error occurred while trying to open WeChat: $($_.Exception.Message)"
}

exit
