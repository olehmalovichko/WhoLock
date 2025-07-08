<#

.SYNOPSIS
    Prompts for a file path, then shows which users have that file open (using Sysinternals handle.exe).

.DESCRIPTION
    1. Ensures script is running as administrator (re-launches itself elevated if needed).
    2. Asks the user to enter the full path to the file.
    3. Runs handle.exe (embedded or installed in C:\Sysinternals) to find open handles.
    4. Parses out each PID, then uses CIM to get the process owner.
    5. Prints a list of “PID – User – ProcessName” entries.

.NOTES
    • You must have handle.exe from Sysinternals in C:\Sysinternals\handle.exe
    • ExecutionPolicy should allow running scripts (you can bypass with –ExecutionPolicy Bypass).
#>

param (
    [string]$filePath
)

Write-Host "=================================================="
Write-Host "WhoLock"
Write-Host "The utility shows who locked the file."
Write-Host "2025 Oleh Malovichko"
Write-Host "=================================================="

if (-not $filePath) {
    Write-Host "No file path was provided as a parameter."
    Write-Host "Usage: lockedfile.ps1 -FilePath 'C:\Path\To\File.txt'"
 ##   exit 1
}

#if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
#    Write-Host " File to check: $FilePath"
###    exit 1
#}

Write-Host "File exists: $FilePath"



# ——————————————————————————————————————
# 1) Self-elevation to Administrator
# ——————————————————————————————————————
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Re-launching script as Administrator..."
    Start-Process -FilePath PowerShell.exe `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
                  -Verb RunAs
    exit
}

# ——————————————————————————————————————
# 2) Prompt for file path
# ——————————————————————————————————————
#####$filePath = Read-Host "Enter the full path to the file you want to check"


if (-not $filePath) {
 Write-Host "`nSelect the file you want to check...:`n"

 Add-Type -AssemblyName System.Windows.Forms

 $dialog = New-Object System.Windows.Forms.OpenFileDialog
 $dialog.Title = "Select a file to check"
 $dialog.Filter = "All files (*.*)|*.*"

 if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $filePath = $dialog.FileName
     Write-Host "`nCheck: $filePath`n"
 } else {
    Write-Host "No file selected. Exiting."
    exit
 }

}

 

# ——————————————————————————————————————
# 3) Verify handle.exe location
# ——————————————————————————————————————
$handleExe = "D:\ARHIV\ASUP04SHADOW\Sysinternals\handle.exe"
if (-not (Test-Path $handleExe)) {
    Write-Error "handle.exe not found at path: $handleExe"
    Write-Error "Download it from https://learn.microsoft.com/en-us/sysinternals/downloads/handle and place it in C:\Sysinternals"
    exit 1
}

# ——————————————————————————————————————
# 4) Check the file itself
# ——————————————————————————————————————
if (-not (Test-Path $filePath)) {
    Write-Error "File not found: $filePath"
    exit 1
}

# ——————————————————————————————————————
# 5) Run handle.exe and capture output
# ——————————————————————————————————————
$raw = & $handleExe $filePath 2>$null

if ([string]::IsNullOrWhiteSpace($raw)) {
    Write-Host "No one is holding the file open."
    exit 0
}

Write-Host "`nOpen handles found:`n"

# ——————————————————————————————————————
# 6) Parse each PID, lookup owner & process name
# ——————————————————————————————————————
$raw | ForEach-Object {
    if ($_ -match 'pid:\s*(\d+)') {
        $processId = $matches[1]

        # Get the CIM instance for the process
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $processId"

        # Invoke the GetOwner method
        $ownerInfo = Invoke-CimMethod -InputObject $proc -MethodName GetOwner
        $userName  = "$($ownerInfo.Domain)\$($ownerInfo.User)"

        # Output
        Write-Host ("PID: {0,-6} User: {1,-20} Process: {2}" -f `
            $processId, $userName, $proc.Name)
    }
}


Write-Host "`nDone."
Write-Host "Press any key to exit..."
[System.Console]::ReadKey($true) | Out-Null
