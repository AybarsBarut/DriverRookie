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
            "Title"            = "System & Driver Diagnostic Tool (Advanced)"
            "SysInfoFile"      = "System Information:"
            "OS"               = "OS: "
            "CPU"              = "CPU: "
            "RAM"              = "RAM: "
            "GPU"              = "GPU: "
            "InstalledVer"     = "Version: "
            "Scanning"         = "Scanning Installed Drivers..."
            "Unknown"          = "Unknown"
            "Col_Device"       = "Hardware (Device)"
            "Col_Manufacturer" = "Manufacturer"
            "Col_Version"      = "Current Version"
            "Col_Date"         = "Date"
            "Col_Update"       = "Update Action"
            "UpdateBtnText"    = "Find Update"
            "BackupBtn"        = "Backup Current Drivers"
            "BackupWait"       = "Backing up drivers... This may take a few minutes."
            "BackupSuccess"    = "Drivers successfully backed up to:"
            "BackupFail"       = "Failed to backup drivers."
            "NeedsAdmin"       = "Driver backup requires Administrator privileges. Restart as Admin to backup?"
        }
    }
    else {
        $dict = @{
            "Title"            = "Sistem & Surucu Teshis Araci (Gelistirilmis)"
            "SysInfoFile"      = "Sistem Bilgileri:"
            "OS"               = "Isletim Sistemi: "
            "CPU"              = "Islemci: "
            "RAM"              = "Bellek: "
            "GPU"              = "Ekran Karti: "
            "InstalledVer"     = "Surum: "
            "Scanning"         = "Kurulu Suruculer Taraniyor..."
            "Unknown"          = "Bilinmiyor"
            "Col_Device"       = "Donanim (Aygit)"
            "Col_Manufacturer" = "Uretici"
            "Col_Version"      = "Mevcut Surum"
            "Col_Date"         = "Tarih"
            "Col_Update"       = "Guncelleme"
            "UpdateBtnText"    = "Guncelleme Ara"
            "BackupBtn"        = "Mevcut Suruculeri Yedekle"
            "BackupWait"       = "Suruculer yedekleniyor... Bu islem birkac dakika surebilir."
            "BackupSuccess"    = "Suruculer basariyla su konuma yedeklendi:"
            "BackupFail"       = "Suruculer yedeklenemedi."
            "NeedsAdmin"       = "Surucu yedeklemek Yonetici Haklari gerektirir. Izin vermek icin onayliyor musunuz?"
        }
    }

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    [System.Windows.Forms.Application]::EnableVisualStyles()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $dict["Title"]
    $form.Size = New-Object System.Drawing.Size(1000, 700)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $form.ForeColor = [System.Drawing.Color]::White
    $form.MinimizeBox = $false
    $form.MaximizeBox = $false
    $form.FormBorderStyle = 'FixedDialog'

    # Sysinfo Panel
    $panelTop = New-Object System.Windows.Forms.Panel
    $panelTop.Size = New-Object System.Drawing.Size(960, 100)
    $panelTop.Location = New-Object System.Drawing.Point(10, 10)
    $panelTop.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $form.Controls.Add($panelTop)

    # Info Text
    $lblInfo = New-Object System.Windows.Forms.Label
    $lblInfo.Size = New-Object System.Drawing.Size(940, 90)
    $lblInfo.Location = New-Object System.Drawing.Point(10, 5)
    $lblInfo.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $os = Get-CimInstance Win32_OperatingSystem
    $ram = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $gpus = Get-CimInstance Win32_VideoController
    
    $sysText = "$($dict['OS'])$($os.Caption) ($($os.OSArchitecture))`n$($dict['CPU'])$($cpu.Name)`n$($dict['RAM'])$ram GB"
    foreach ($gpu in $gpus) {
        $sysText += "`n$($dict['GPU'])$($gpu.Name) ($($dict['InstalledVer'])$($gpu.DriverVersion))"
    }
    $lblInfo.Text = $sysText
    $panelTop.Controls.Add($lblInfo)

    # DataGridView
    $grid = New-Object System.Windows.Forms.DataGridView
    $grid.Size = New-Object System.Drawing.Size(960, 480)
    $grid.Location = New-Object System.Drawing.Point(10, 120)
    $grid.BackgroundColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $grid.AllowUserToAddRows = $false
    $grid.AllowUserToDeleteRows = $false
    $grid.ReadOnly = $true
    $grid.RowHeadersVisible = $false
    $grid.SelectionMode = 'FullRowSelect'
    $grid.AutoSizeColumnsMode = 'Fill'
    $grid.EnableHeadersVisualStyles = $false
    $grid.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 65)
    $grid.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::White
    $grid.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $grid.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
    $grid.DefaultCellStyle.ForeColor = [System.Drawing.Color]::White
    $grid.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(75, 75, 80)
    
    $form.Controls.Add($grid)

    $col1 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $col1.Name = "DeviceName"
    $col1.HeaderText = $dict["Col_Device"]

    $col2 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $col2.Name = "Manufacturer"
    $col2.HeaderText = $dict["Col_Manufacturer"]

    $col3 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $col3.Name = "Version"
    $col3.HeaderText = $dict["Col_Version"]

    $col4 = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
    $col4.Name = "Date"
    $col4.HeaderText = $dict["Col_Date"]

    $col5 = New-Object System.Windows.Forms.DataGridViewButtonColumn
    $col5.Name = "Update"
    $col5.HeaderText = $dict["Col_Update"]
    $col5.Text = $dict["UpdateBtnText"]
    $col5.UseColumnTextForButtonValue = $true
    $col5.FlatStyle = 'Flat'
    $col5.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
    $col5.DefaultCellStyle.ForeColor = [System.Drawing.Color]::White

    $grid.Columns.AddRange($col1, $col2, $col3, $col4, $col5)

    # Filtering Drivers
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
        $keep = $true
        foreach ($badWord in $blacklist) {
            if ($name -match "(?i)$badWord") {
                $keep = $false
                break
            }
        }
        $keep
    } | Sort-Object DeviceClass

    # Win32_PnPEntity to grab precise HWID
    $pnpEntities = Get-CimInstance Win32_PnPEntity

    foreach ($driver in $drivers) {
        $driverDateFormatted = $dict["Unknown"]
        if ($driver.DriverDate) {
            $driverDateFormatted = $driver.DriverDate.ToString("yyyy-MM-dd")
        }
        
        $hwid = ""
        if ($driver.DeviceID) {
            $matchedEntity = $pnpEntities | Where-Object { $_.DeviceID -eq $driver.DeviceID }
            if ($null -ne $matchedEntity -and $null -ne $matchedEntity.HardwareID -and $matchedEntity.HardwareID.Count -gt 0) {
                # Just take the first viable HWID
                $hwid = $matchedEntity.HardwareID[0]
            }
        }

        $rowIndex = $grid.Rows.Add($driver.DeviceName, $driver.Manufacturer, $driver.DriverVersion, $driverDateFormatted)
        $grid.Rows[$rowIndex].Tag = $hwid
    }

    $btnBackup = New-Object System.Windows.Forms.Button
    $btnBackup.Size = New-Object System.Drawing.Size(250, 40)
    $btnBackup.Location = New-Object System.Drawing.Point(375, 610)
    $btnBackup.Text = $dict["BackupBtn"]
    $btnBackup.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btnBackup.BackColor = [System.Drawing.Color]::FromArgb(40, 167, 69)
    $btnBackup.ForeColor = [System.Drawing.Color]::White
    $btnBackup.FlatStyle = 'Flat'
    
    $btnBackup.Add_Click({
            $backupPath = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath "DriverBackups"
        
            $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

            if (-not $isAdmin) {
                $res = [System.Windows.Forms.MessageBox]::Show($dict["NeedsAdmin"], $dict["Title"], [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
                if ($res -eq 'Yes') {
                    if (-not (Test-Path $backupPath)) { New-Item -ItemType Directory -Path $backupPath | Out-Null }
                
                    $scriptArg = "Add-Type -AssemblyName System.Windows.Forms; try { Export-WindowsDriver -Online -Destination '$backupPath' -ErrorAction Stop | Out-Null; [System.Windows.Forms.MessageBox]::Show('Backup Success: $backupPath', 'Backup', 'OK', 'Information') } catch { [System.Windows.Forms.MessageBox]::Show('Backup Failed', 'Error', 'OK', 'Error') }"
                    Start-Process powershell -ArgumentList "-WindowStyle Hidden -NoProfile -Command `"$scriptArg`"" -Verb RunAs
                }
            }
            else {
                $btnBackup.Enabled = $false
                $btnBackup.Text = $dict["BackupWait"]
                [System.Windows.Forms.Application]::DoEvents()
            
                if (-not (Test-Path $backupPath)) { New-Item -ItemType Directory -Path $backupPath | Out-Null }
            
                try {
                    Export-WindowsDriver -Online -Destination $backupPath | Out-Null
                    [System.Windows.Forms.MessageBox]::Show("$($dict['BackupSuccess']) `n`n$backupPath", $dict["Title"], [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                }
                catch {
                    [System.Windows.Forms.MessageBox]::Show($dict["BackupFail"], $dict["Title"], [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            
                $btnBackup.Text = $dict["BackupBtn"]
                $btnBackup.Enabled = $true
            }
        })
    $form.Controls.Add($btnBackup)

    $grid.Add_CellContentClick({
            param([object]$sender, [System.Windows.Forms.DataGridViewCellEventArgs]$e)
            if ($e.ColumnIndex -eq 4 -and $e.RowIndex -ge 0) {
                $row = $grid.Rows[$e.RowIndex]
                $deviceName = $row.Cells["DeviceName"].Value
                $version = $row.Cells["Version"].Value
                $hwid = $row.Tag
                $manufacturer = $row.Cells["Manufacturer"].Value

                if ($manufacturer -match "NVIDIA" -or $deviceName -match "NVIDIA") {
                    $url = "https://www.nvidia.com/Download/index.aspx"
                }
                elseif ($manufacturer -match "AMD|Advanced Micro Devices" -or $deviceName -match "AMD|Radeon") {
                    $url = "https://www.amd.com/en/support"
                }
                elseif ($manufacturer -match "Intel" -or $deviceName -match "Intel") {
                    $url = "https://www.intel.com/content/www/us/en/download-center/home.html"
                }
                elseif ($manufacturer -match "Realtek" -or $deviceName -match "Realtek") {
                    $url = "https://www.realtek.com/Download/List"
                }
                elseif ($manufacturer -match "Lenovo" -or $deviceName -match "Lenovo") {
                    $url = "https://pcsupport.lenovo.com/us/en/"
                }
                elseif ($manufacturer -match "Dell" -or $deviceName -match "Dell") {
                    $url = "https://www.dell.com/support/home/en-us?app=drivers"
                }
                elseif ($manufacturer -match "HP|Hewlett-Packard|Hewlett Packard") {
                    $url = "https://support.hp.com/us-en/drivers"
                }
                elseif ($manufacturer -match "ASUS|ASUSTeK" -or $deviceName -match "ASUS") {
                    $url = "https://www.asus.com/support/Download-Center/"
                }
                else {
                    if ([string]::IsNullOrWhiteSpace($hwid)) {
                        $searchQuery = [uri]::EscapeDataString("$deviceName driver $version")
                        $url = "https://www.google.com/search?q=$searchQuery"
                    }
                    else {
                        $shortHwid = $hwid
                        if ($hwid -match "^(.*?&DEV_[A-Z0-9]+)") {
                            $shortHwid = $matches[1]
                        }
                        $searchQuery = [uri]::EscapeDataString($shortHwid)
                        $url = "https://www.catalog.update.microsoft.com/Search.aspx?q=$searchQuery"
                    }
                }

                Start-Process $url
            }
        })

    $form.ShowDialog() | Out-Null
}

Get-DriverUpdates
