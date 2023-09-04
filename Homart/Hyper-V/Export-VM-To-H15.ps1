$Servers = @("SERVER24", "SERVER25", "H02", "H04", "H05", "H10", "H11", "H12", "H16")
$ExportDate = (Get-Date).ToString("yyyyMMdd")
$ExportTimestamp = (Get-Date).ToString("yyyyMMddHHmm")
$username = Read-Host -Prompt "Enter your username"
$password = Read-Host -Prompt "Enter your password"
$currentDate = Get-Date
$password = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential $username, $password
Enable-WSManCredSSP -Role Client -DelegateComputer $Servers -Force
$ScriptStartTime = Get-Date
$ServerName = "h15-upjohn2"
Write-Host "Script start time: $ScriptStartTime"
if ($currentDate -eq [DateTime]::ParseExact("2023-09-04", "yyyy-MM-dd", $null)) {
    $VMNames = @("Ubuntu", "RDSIS", "RDSApp01", "MYOB2", "HPS1", "ClockOn App Server", "AD02 - Do NOT Turn Off", "RDS01")
    Write-Host "Initial export VMs"
    Exit
} elseif ($currentDate.Hour -ge 12) {
    if ($currentDate.Day -eq [DateTime]::DaysInMonth($currentDate.Year, $currentDate.Month)) {
        $VMNames = @("ClockOn", "RDS Gold Disk", "MYOB3", "MYOB", "SERVER17 (SEP)", "HCController", "AD01", "SAP01")
    } elseif ($currentDate.DayOfWeek -eq [DayOfWeek]::Friday) {
        $VMNames = @("RDSApp01", "MYOB2", "HPS1", "ClockOn App Server", "AD02 - Do NOT Turn Off", "RDS01")
    } else {
        $VMNames = @("MYOB2", "HPS1", "ClockOn App Server", "AD02 - Do NOT Turn Off")
    }
} else {
    $VMNames = @("HPS1", "MYOB2", "ClockOn App Server")
}
Write-Output $VMNames
foreach ($Server in $Servers) {
    Invoke-Command -ComputerName $Server -ScriptBlock { Enable-WSManCredSSP -Role Server -Force } -Credential $cred
    $VMs = Invoke-Command -ComputerName $Server -ScriptBlock { Get-VM } -Credential $cred -Authentication Credssp
    $VMs = $VMs | Where-Object { $VMNames -contains $_.Name }
    foreach ($VM in $VMs) {
        $VMName = $VM.Name
        $ExportPath = "\\$ServerName\Hyper-V\Exported VM\$VMName\$ExportTimestamp"
        if (!(Test-Path $ExportPath)) {
            New-Item -ItemType Directory -Force -Path $ExportPath
        }
        try {
            Invoke-Command -ComputerName $Server -ScriptBlock {
                param($VMName, $ExportPath)
                Export-VM -Name $VMName -Path $ExportPath -ErrorAction Stop
            } -ArgumentList $VMName, "$ExportPath" -Credential $cred -Authentication Credssp
            $dir = "\\$ServerName\Hyper-V\Exported VM\$VMName"
            Write-Output "Searching for files in directory: $dir"
            $files = Get-ChildItem -Path $dir | Where-Object { $_.PSIsContainer }
            Write-Output "Found $($files.Count) folders"
            if ($files.Count -gt 5) {
                Write-Output "More than 5 folders found, keeping the newest 5 and removing the rest."
                $foldersToRemove = Get-ChildItem -Path $dir | Sort-Object Name -Descending | Select-Object -Skip 5
                $foldersToRemove | Remove-Item -Force -Recurse
            }
            $availableSpace = (Get-PSDrive D).Free
            $threshold = 3TB
            if ($availableSpace -lt $threshold) {
                Clear-RecycleBin -Force
                Write-Output "Recycle Bin has been emptied because the available space on the D: drive was less than 3TB."
            } else {
    
                Write-Output "Recycle Bin was not emptied because the available space on the D: drive was greater than or equal to 3TB."
            }
        }
        catch {
            $errorMessage = "Failed to export $VMName. Error: $_"
            Write-Host $errorMessage
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logMessage = "$timestamp - $errorMessage`r`n-------------`r`n"
            Add-Content -Path "D:\Hyper-V\Exported VM\FailExportVMsLogs.txt" -Value $logMessage -Force
            continue
        }
    }
}
$ScriptEndTime = Get-Date
Write-Host "Script end time: $ScriptEndTime"
Write-Host "Total time taken: $(($ScriptEndTime-$ScriptStartTime).TotalSeconds) seconds"