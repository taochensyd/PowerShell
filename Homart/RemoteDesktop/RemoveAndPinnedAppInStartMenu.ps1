# Create a new shell object
$shell = New-Object -ComObject Shell.Application
# Get the folder object for the Start Menu
$folder = $shell.NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}')
# Get the items in the Start Menu folder
$items = $folder.Items()

# Unpin all items from the Start Menu
foreach ($item in $items) {
    # Get the 'Unpin from Start' verb for the item
    $verb = $item.Verbs() | Where-Object { $_.Name.replace('&', '') -eq 'Unpin from Start' }
    # If the verb exists, unpin the item from the Start Menu
    if ($verb) {
        $verb.DoIt()
        Write-Output "Unpinned '$($item.Name)' from Start"
    }
}

# Define a function to pin or unpin an app to/from the Start Menu
function Pin-App {
    param(
        [string]$appname,
        [switch]$unpin
    )
    try{
        # If the -unpin switch is present, unpin the app from the Start Menu
        if ($unpin.IsPresent){
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $appname}).Verbs() | Where-Object {$_.Name.replace('&','') -match 'Von "Start" lösen|Unpin from Start'} | ForEach-Object {$_.DoIt()}
            Write-Output "App '$appname' unpinned from Start"
        }else{
            # Otherwise, pin the app to the Start Menu
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object {$_.Name -eq $appname}).Verbs() | Where-Object {$_.Name.replace('&','') -match 'An "Start" anheften|Pin to Start'} | ForEach-Object {$_.DoIt()}
            Write-Output "App '$appname' pinned to Start"
        }
    }catch{
        Write-Error "Error Pinning/Unpinning App! (App Name correct?)"
    }
}

# Define an array of app names to pin to the Start Menu
$appNames = @("Word", "Excel", "Outlook", "Google Chrome", "SAP Business One Client (64-bit)", "File Explorer", "TIM", "WeChat", "Control Panel")
# Pin each app in the array to the Start Menu
foreach ($appName in $appNames) {
    Pin-App $appName -pin
}
# Unpin TIM and WeChat from the Start Menu
Pin-App "TIM" -unpin
Pin-App "WeChat" -unpin
