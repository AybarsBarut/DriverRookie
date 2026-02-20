function Get-DriverUpdates {
    [CmdletBinding()]
    param (
        [string]$Language = "tr"
    )

    # Check if a global Lang variable was set before running via iex
    if ($global:Lang -eq "en" -or $global:Lang -eq "EN" -or $Lang -eq "en" -or $Lang -eq "EN" -or $env:Lang -eq "en") {
        $Language = "en"
    }

    $dict = @{}

    if ($Language -eq "en") {
        $dict = @{
            "Title"            = "      System & Driver Diagnostic Tool          "
            "ReportTitle"      = "      Driver Update Report                     "
            "Date"             = "      Date: "
            "SysInfo"          = "`n[+] Gathering System Information..."
            "SysInfoFile"      = "System Information:"
            "OS"               = "Operating System : "
            "CPU"              = "Processor        : "
            "RAM"              = "Total RAM        : "
            "GPU"              = "Graphics Card    : "
            "InstalledVer"     = "Installed Version: "
            "QuickLinks"       = "Quick Official Driver Pages (Especially for GPUs):"
            "CustomDrivers"    = "List of Installed Third-Party (Custom) Drivers:"
            "Scanning"         = "`n[+] Scanning Installed Drivers (filtering out Windows generic drivers)..."
            "Unknown"          = "Unknown"
            "DeviceName"       = "Device Name      : "
            "Manufacturer"     = "Manufacturer     : "
            "CurrentVer"       = "Current Version  : "
            "VersionDate"      = "Version Date     : "
            "SearchToDL"       = "Search to Dwnld  : "
            "FoundMsg"         = "`n[!] Found {0} custom driver(s) on your system."
            "DesktopRpt1"      = " A detailed report has been created on your desktop:"
            "DesktopRpt2"      = " File Path: "
            "DesktopRpt3"      = " (This file contains your current driver versions and one-click Google search links to download them.)"
            "Col_Device"       = "Hardware (Device)"
            "Col_Manufacturer" = "Manufacturer"
            "Col_Version"      = "Current Version"
            "Col_Date"         = "Date"
        }
    }
    else {
        $dict = @{
            "Title"            = "      Sistem & Surucu Teshis Araci             "
            "ReportTitle"      = "      Surucu Guncelleme Raporu                 "
            "Date"             = "      Tarih: "
            "SysInfo"          = "`n[+] Sistem Bilgileri Cekiliyor..."
            "SysInfoFile"      = "Sistem Bilgileri:"
            "OS"               = "Isletim Sistemi : "
            "CPU"              = "Islemci         : "
            "RAM"              = "Toplam Bellek   : "
            "GPU"              = "Ekran Karti     : "
            "InstalledVer"     = "Kurulu Surum: "
            "QuickLinks"       = "Hizli Resmi Surucu Sayfalari (Ozellikle Ekran Kartlari Icin):"
            "CustomDrivers"    = "Kurulu Ucuncu Parti (Ozel) Suruculerin Listesi:"
            "Scanning"         = "`n[+] Kurulu Suruculer Taraniyor (Windows jenerik suruculeri filtreleniyor)..."
            "Unknown"          = "Bilinmiyor"
            "DeviceName"       = "Aygit Adi        : "
            "Manufacturer"     = "Uretici          : "
            "CurrentVer"       = "Mevcut Surum     : "
            "VersionDate"      = "Surum Tarihi     : "
            "SearchToDL"       = "Indirmek Icin Ara: "
            "FoundMsg"         = "`n[!] Sistemde {0} adet ozel surucu bulundu."
            "DesktopRpt1"      = " Masaustune detayli bir rapor olusturuldu:"
            "DesktopRpt2"      = " Dosya Yolu: "
            "DesktopRpt3"      = " (Bu dosyada suruculerinizin mevcut surumleri ve tek tiklamayla Google'da aratip`n indirebileceginiz linkler mevcuttur.)"
            "Col_Device"       = "Donanim (Aygit)"
            "Col_Manufacturer" = "Uretici"
            "Col_Version"      = "Mevcut Surum"
            "Col_Date"         = "Tarih"
        }
    }

    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host $dict["Title"] -ForegroundColor Cyan

    # Masaustu yolunu bul ve update.txt dosyasini hazirla
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $updateReportPath = Join-Path -Path $desktopPath -ChildPath "update.txt"

    # Rapor dosyasini olustur (varsa uzerine yazar)
    "_______________________________________________" | Out-File -FilePath $updateReportPath -Encoding utf8
    $dict["ReportTitle"] | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    "$($dict['Date'])$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    "_______________________________________________" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    "" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append

    Write-Host $dict["SysInfo"] -ForegroundColor Green
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $os = Get-CimInstance Win32_OperatingSystem
    $ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $gpus = Get-CimInstance Win32_VideoController
    
    # Sistemin temel ozelliklerini rapora ekle
    $dict["SysInfoFile"] | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    "-----------------" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    "$($dict['OS'])$($os.Caption) ($($os.OSArchitecture))" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    "$($dict['CPU'])$($cpu.Name)" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    "$($dict['RAM'])$ram GB" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    
    foreach ($gpu in $gpus) {
        "$($dict['GPU'])$($gpu.Name) ($($dict['InstalledVer'])$($gpu.DriverVersion))" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    }
    
    "" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    $dict["QuickLinks"] | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    "_______________________________________________" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    
    $hasNvidia = $false
    $hasAmd = $false
    $hasIntel = $false

    foreach ($gpu in $gpus) {
        if ($gpu.Name -match "(?i)NVIDIA") { $hasNvidia = $true }
        if ($gpu.Name -match "(?i)AMD|Radeon") { $hasAmd = $true }
        if ($gpu.Name -match "(?i)Intel") { $hasIntel = $true }
    }

    if ($hasNvidia) { "NVIDIA : https://www.nvidia.com/Download/index.aspx" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append }
    if ($hasAmd) { "AMD    : https://www.amd.com/en/support" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append }
    if ($hasIntel) { "Intel  : https://www.intel.com/content/www/us/en/download-center/home.html" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append }
    if (-not $hasNvidia -and -not $hasAmd -and -not $hasIntel) {
        "NVIDIA : https://www.nvidia.com/Download/index.aspx" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
        "AMD    : https://www.amd.com/en/support" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
        "Intel  : https://www.intel.com/content/www/us/en/download-center/home.html" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    }
    "" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    
    $dict["CustomDrivers"] | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    "_______________________________________________" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append

    Write-Host $dict["Scanning"] -ForegroundColor Green
    
    # İstenmeyen donanim adlari veya kelimeleri (kara liste)
    $blacklist = @(
        "Virtual", "Standard", "Generic", "ACPI", "Bluetooth", "Event Filter", "HID-compliant", "USB Input Device",
        "PCI Express Root Complex", "Programmable interrupt controller", "Motherboard resources",
        "Sleep Button", "Power Button", "High precision event timer", "System timer", "Processor", "Disk drive",
        "Charge Arbitration Driver", "Plug-in", "Extensible Framework", "SMBus", "Management Engine", "Intel(R) Host Bridge",
        "LPC Controller", "Root Port", "SRAM", "SPI (flash)", "Host Controller", "Keyboard", "Touch pad",
        "Steam Streaming", "xHCI Compliant", "USB Composite", "Root Hub", "Serial IO", "Platform Monitoring Technology",
        "Software Device Enumerator", "Basic Display Driver", "Meta"
    )

    $drivers = Get-CimInstance Win32_PnPSignedDriver | Where-Object { 
        $null -ne $_.DeviceName -and
        $null -ne $_.Manufacturer -and
        $_.Manufacturer -notmatch "Microsoft" -and 
        $_.Manufacturer -notmatch "\(Standard" -and 
        $null -ne $_.DriverVersion 
    } | Where-Object {
        $name = $_.DeviceName
        # Eğer cihaz adı kara listedeki kelimelerden herhangi birini içeriyorsa ele (filtrele)
        $keep = $true
        foreach ($badWord in $blacklist) {
            if ($name -match "(?i)$badWord") {
                $keep = $false
                break
            }
        }
        $keep
    } | Sort-Object DeviceClass

    $outdatedDrivers = @()

    foreach ($driver in $drivers) {
        $driverDateFormatted = $dict["Unknown"]
        if ($driver.DriverDate) {
            $driverDateFormatted = $driver.DriverDate.ToString("yyyy-MM-dd")
        }

        $hwSearchString = [uri]::EscapeDataString("$($driver.DeviceName) driver $($driver.DriverVersion)")
        $googleSearchUrl = "https://www.google.com/search?q=$hwSearchString"

        $row = New-Object PSObject
        $row | Add-Member -MemberType NoteProperty -Name $dict["Col_Device"] -Value $driver.DeviceName
        $row | Add-Member -MemberType NoteProperty -Name $dict["Col_Manufacturer"] -Value $driver.Manufacturer
        $row | Add-Member -MemberType NoteProperty -Name $dict["Col_Version"] -Value $driver.DriverVersion
        $row | Add-Member -MemberType NoteProperty -Name $dict["Col_Date"] -Value $driverDateFormatted
        
        $outdatedDrivers += $row

        # Dosyaya driver bilgilerini ve arama linkini yazdir
        "$($dict['DeviceName'])$($driver.DeviceName)" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
        "$($dict['Manufacturer'])$($driver.Manufacturer)" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
        "$($dict['CurrentVer'])$($driver.DriverVersion)" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
        "$($dict['VersionDate'])$driverDateFormatted" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
        "$($dict['SearchToDL'])$googleSearchUrl" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
        "--------------------------------------------------" | Out-File -FilePath $updateReportPath -Encoding utf8 -Append
    }

    $foundStr = $dict["FoundMsg"] -f $outdatedDrivers.Count
    Write-Host $foundStr -ForegroundColor Yellow
    Write-Host "`n===============================================" -ForegroundColor Cyan
    Write-Host $dict["DesktopRpt1"] -ForegroundColor Green
    Write-Host "$($dict['DesktopRpt2'])$updateReportPath" -ForegroundColor White
    Write-Host $dict["DesktopRpt3"] -ForegroundColor Gray
    Write-Host "===============================================`n" -ForegroundColor Cyan

    # Ekrana da tablo olarak goster
    $outdatedDrivers | Format-Table -AutoSize
}

Get-DriverUpdates
