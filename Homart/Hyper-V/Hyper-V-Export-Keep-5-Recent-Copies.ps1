# Define source and destination paths
$source1 = "\\h15-upjohn2\Hyper-V\Exported VM"
$source2 = "\\h15-upjohn2\Hyper-V\Exported VM"
$destinationPath = "D:\Hyper-V\Exported VM"

# Check if source directories are empty and use robocopy to copy their contents to destination
if ((Get-ChildItem $source1 | Measure-Object).Count -ne 0) {
    robocopy $source1 $destinationPath /E /XO /W:5 /R:5
}
if ((Get-ChildItem $source2 | Measure-Object).Count -ne 0) {
    robocopy $source2 $destinationPath /E /XO /W:5 /R:5
}

# Get all folders in destination path
$folders = Get-ChildItem $destinationPath | Where-Object {$_.PSIsContainer}

# For each folder, sort its subfolders by creation time and keep only the latest 5
foreach ($folder in $folders) {
    $subFolders = Get-ChildItem $folder.FullName | Where-Object {$_.PSIsContainer} | Sort-Object CreationTime -Descending
    if ($subFolders.Count -gt 5) {
        $subFolders[5..($subFolders.Count - 1)] | Remove-Item -Recurse -Force
    }
}

# Get total and free space of D drive
$drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='D:'"
$totalSpace = $drive.Size
$freeSpace = $drive.FreeSpace

# Calculate used space percentage
$usedSpacePercentage = [Math]::Round((($totalSpace - $freeSpace) / $totalSpace) * 100)

# Empty Recycle Bin if D drive is more than 90% full
if ($usedSpacePercentage -ge 90) {
    Clear-RecycleBin -Force
    Write-Output "Recycle Bin emptied because D drive is $usedSpacePercentage% full"
} else {
    Write-Output "D drive is not 90% full, no need to empty Recycle Bin"
}
