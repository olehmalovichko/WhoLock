# WhoLock GUI Tool with Admin Elevation (EXE-Compatible)
# MIT License | Ukraine 2025 | Oleh Malovichko

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==== Detect handle.exe path relative to script/exe ====
$scriptDir = Split-Path -Parent ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)
$handleExe = Join-Path $scriptDir "Sysinternals\handle.exe"

# ==== Read argument even inside compiled .exe ====
$global:filePath = $null
try {
    $cmdLine = [Environment]::GetCommandLineArgs()
    if ($cmdLine.Count -gt 1) {
        $global:filePath = $cmdLine[1]
    }
} catch {
    $global:filePath = $null
}

# ==== Ensure script is running as administrator ====
function Ensure-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $admin = [Security.Principal.WindowsBuiltInRole]::Administrator

    if (-not $principal.IsInRole($admin)) {
        $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName

        # Pass argument back after elevation
        $argLine = ""
        if ($global:filePath) {
            $argLine = "`"$global:filePath`""
        }

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $exePath
        $psi.Verb = "runas"
        $psi.Arguments = $argLine
        $psi.UseShellExecute = $true

        try {
            [System.Diagnostics.Process]::Start($psi) | Out-Null
        } catch {
            [System.Windows.Forms.MessageBox]::Show("This tool requires administrator privileges.", "Access Denied", "OK", "Error")
        }
        exit
    }
}

# ==== Show GUI with lock information ====
function Show-ResultWindow {
    param ([string]$FilePath)

    function Get-FileLocks {
        $raw = & $handleExe $FilePath 2>$null
        $results = @()

        $raw | ForEach-Object {
            if ($_ -match 'pid:\s*(\d+)') {
                $procId = $matches[1]
                $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $procId" -ErrorAction SilentlyContinue
                if ($proc) {
                    $owner = Invoke-CimMethod -InputObject $proc -MethodName GetOwner
                    $user = "$($owner.Domain)\\$($owner.User)"
                    $results += [PSCustomObject]@{
                        ProcID  = $procId
                        User    = $user
                        Process = $proc.Name
                    }
                }
            }
        }
        return $results
    }

    $form = New-Object Windows.Forms.Form
    $form.Text = "WhoLock – $([System.IO.Path]::GetFileName($FilePath))"
    $form.Size = New-Object Drawing.Size(650, 450)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$env:SystemRoot\\System32\\shell32.dll")

    $listView = New-Object Windows.Forms.ListView
    $listView.View = 'Details'
    $listView.FullRowSelect = $true
    $listView.GridLines = $true
    $listView.Dock = 'Top'
    $listView.Height = 350
    $listView.Columns.Add("ProcID", 80)
    $listView.Columns.Add("User", 220)
    $listView.Columns.Add("Process", 300)

    $btnRefresh = New-Object Windows.Forms.Button
    $btnRefresh.Text = "🔄 Refresh"
    $btnRefresh.Width = 100
    $btnRefresh.Top = 360
    $btnRefresh.Left = 10

    $btnClose = New-Object Windows.Forms.Button
    $btnClose.Text = "✖ Close"
    $btnClose.Width = 100
    $btnClose.Top = 360
    $btnClose.Left = 120
    $btnClose.Add_Click({ $form.Close() })

    $form.Controls.AddRange(@($listView, $btnRefresh, $btnClose))

    function Refresh-List {
        $listView.Items.Clear()
        $results = Get-FileLocks
        if ($results.Count -eq 0) {
            $form.Text = "WhoLock – $([System.IO.Path]::GetFileName($FilePath)) [not locked]"
        } else {
            foreach ($item in $results) {
                $lvItem = New-Object Windows.Forms.ListViewItem($item.ProcID)
                $lvItem.SubItems.Add($item.User)
                $lvItem.SubItems.Add($item.Process)
                $listView.Items.Add($lvItem)
            }
            $form.Text = "WhoLock – $([System.IO.Path]::GetFileName($FilePath)) [$($results.Count) lock(s)]"
        }
    }

    $btnRefresh.Add_Click({ Refresh-List })

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 60000
    $timer.Add_Tick({ Refresh-List })
    $timer.Start()




# Створюємо панель для прапора
$flagPanel = New-Object System.Windows.Forms.Panel
$flagPanel.Size = New-Object System.Drawing.Size(15, 2)
$flagPanel.Dock = "Left"
$flagPanel.Margin = '5,5,0,0'  # лівий, верхній, правий, нижній

# Порожній відступ (3 пікселів)
$spacer = New-Object System.Windows.Forms.Panel
$spacer.Width = 3
$spacer.Dock = "Left"

# Обробник події Paint для малювання прапора
$flagPanel.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $blueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::RoyalBlue)
    $yellowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Yellow)

    # Малюємо верхню синю половину
    $g.FillRectangle($blueBrush, 0, 4, 15,  7 )
    # Малюємо нижню жовту половину
    $g.FillRectangle($yellowBrush, 0, 9, 15, 5 )
})

# Створюємо Label з текстом
$copyright = New-Object System.Windows.Forms.Label
$copyright.Text = "MIT License | Ukraine 2025 | Oleh Malovichko"
$copyright.AutoSize = $false
$copyright.Height = 20
$copyright.Dock = "Fill"
$copyright.TextAlign = "MiddleLeft"
$copyright.Font = New-Object System.Drawing.Font("Courier New", 8, [System.Drawing.FontStyle]::Regular)
$copyright.ForeColor = [System.Drawing.Color]::Gray

# Створюємо контейнер (Panel) для прапора і тексту
$container = New-Object System.Windows.Forms.Panel
$container.Dock = "Bottom"
$container.Height = 20

# Додаємо в правильному порядку
$container.Controls.Add($copyright)
$container.Controls.Add($flagPanel)
$container.Controls.Add($spacer)


# Додаємо контейнер до форми
$form.Controls.Add($container)


    $form.Add_Shown({ Refresh-List })
    [void]$form.ShowDialog()
}

# ==== MAIN ENTRY POINT ====
Ensure-Admin

# If no file was provided — ask the user to select one
if (-not $global:filePath -or -not (Test-Path $global:filePath)) {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "Select file to check"
    $dialog.Filter = "All files (*.*)|*.*"

    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        return
    }

    $global:filePath = $dialog.FileName
}

# Check if handle.exe exists
if (-not (Test-Path $handleExe)) {
    [System.Windows.Forms.MessageBox]::Show("handle.exe not found at:`n$handleExe", "Error", 'OK', 'Error')
    exit
}

# Launch the GUI
Show-ResultWindow -FilePath $global:filePath

