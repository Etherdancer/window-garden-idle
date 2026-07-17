$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
$subKeys = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "\d{4}$" }
$found = $false

foreach ($key in $subKeys) {
    $desc = (Get-ItemProperty -Path $key.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
    $matchingId = (Get-ItemProperty -Path $key.PSPath -Name "MatchingDeviceId" -ErrorAction SilentlyContinue).MatchingDeviceId
    
    if ($desc -match "Tesla P4" -or $matchingId -match "VEN_10DE&DEV_1BB3") {
        Write-Host "Found Tesla P4 at: $($key.PSPath)"
        
        Write-Host "Injecting WDDM registry keys..."
        New-ItemProperty -Path $key.PSPath -Name "AdapterType" -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $key.PSPath -Name "EnableMsHybrid" -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $key.PSPath -Name "FeatureScore" -Value 209 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $key.PSPath -Name "GridLicensedFeatures" -Value 7 -PropertyType DWORD -Force | Out-Null
        
        $found = $true
        Write-Host "WDDM registry hack injected successfully!"
    }
}

if (-not $found) {
    Write-Host "Tesla P4 not found in the registry. Ensure the Nvidia driver is fully installed."
} else {
    Write-Host "You must restart your computer for these changes to take effect."
}
