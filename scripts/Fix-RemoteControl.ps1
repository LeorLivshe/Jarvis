<#
.SYNOPSIS
    Diagnose why the Remote Control session dropped on 2026-10-22, then harden
    this desktop so a Remote Control session stays reachable while you're away.

.DESCRIPTION
    Run from an elevated (Run as administrator) PowerShell window:

        powershell -ExecutionPolicy Bypass -File .\Fix-RemoteControl.ps1

    Steps (each one reports what it did; a failed step does not stop the rest):
      1. Diagnose  - writes RemoteControl-Diagnosis.txt to your Desktop
      2. Power     - never sleep or hibernate on AC power
      3. Network   - stop Windows powering down the network adapters
      4. Updates   - widen Active Hours, no auto-restart while signed in
      5. Console   - turn off QuickEdit (a stray click pauses console apps)
      6. Optional  - -RegisterRemoteControlTask starts `claude remote-control`
                     at logon and restarts it if it exits

    -DiagnoseOnly runs step 1 and changes nothing.
#>
[CmdletBinding()]
param(
    [switch]$DiagnoseOnly,
    [switch]$RegisterRemoteControlTask,
    [string]$WorkDir = "$env:USERPROFILE\Desktop\Claude",
    [int]$ActiveHoursStart = 7,
    [int]$ActiveHoursEnd = 1
)

$ErrorActionPreference = 'Stop'

function Write-Step($text) { Write-Host ""; Write-Host "== $text ==" -ForegroundColor Cyan }
function Write-Ok($text)   { Write-Host "  [ok]   $text" -ForegroundColor Green }
function Write-Warn2($text){ Write-Host "  [warn] $text" -ForegroundColor Yellow }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run this from PowerShell opened with 'Run as administrator'." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# 1. Diagnose
# ---------------------------------------------------------------------------
Write-Step "1. Diagnose the 2026-10-22 disconnect"

# The session hung at 16:40:54 UTC (browser screenshot), lost its connection at
# 16:48 UTC and failed to reconnect at 16:49 UTC. Look at 16:30-17:30 UTC.
$fromUtc = [DateTime]::SpecifyKind([DateTime]'2026-10-22 16:30:00', 'Utc')
$toUtc   = [DateTime]::SpecifyKind([DateTime]'2026-10-22 17:30:00', 'Utc')
$from = $fromUtc.ToLocalTime()
$to   = $toUtc.ToLocalTime()
$report = Join-Path ([Environment]::GetFolderPath('Desktop')) 'RemoteControl-Diagnosis.txt'

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("Remote Control disconnect diagnosis - generated $(Get-Date)")
$lines.Add("Window checked (local time): $from  to  $to")
$lines.Add("")
$lines.Add("How to read the event IDs:")
$lines.Add("  42 = went to sleep        1 (Power-Troubleshooter) = woke up")
$lines.Add("  1074 = restart/shutdown requested (TrustedInstaller/MoUsoCoreWorker = Windows Update)")
$lines.Add("  41 / 6008 = unexpected shutdown (power cut or crash)   6006 = clean shutdown")
$lines.Add("  27 / 4202 / 10400 = network link went down")
$lines.Add("  Application 1000 = an app crashed   1002 = an app hung (look for Claude)")
$lines.Add("")

try {
    $sys = Get-WinEvent -FilterHashtable @{ LogName = 'System'; StartTime = $from; EndTime = $to } -ErrorAction SilentlyContinue |
        Where-Object { $_.Id -in 1, 27, 41, 42, 107, 1074, 4202, 6006, 6008, 10400 }
    $lines.Add("---- System log ----")
    if ($sys) {
        foreach ($e in $sys) { $lines.Add("$($e.TimeCreated)  id=$($e.Id)  $($e.ProviderName)  $($e.Message -replace '\s+', ' ')") }
    } else { $lines.Add("(no sleep, restart, shutdown or network events in this window)") }

    $app = Get-WinEvent -FilterHashtable @{ LogName = 'Application'; StartTime = $from; EndTime = $to } -ErrorAction SilentlyContinue |
        Where-Object { $_.Id -in 1000, 1002 }
    $lines.Add("")
    $lines.Add("---- Application crashes / hangs ----")
    if ($app) {
        foreach ($e in $app) { $lines.Add("$($e.TimeCreated)  id=$($e.Id)  $($e.Message -replace '\s+', ' ')") }
    } else { $lines.Add("(no app crashes or hangs in this window)") }

    $lines.Add("")
    $lines.Add("---- powercfg /lastwake ----")
    (powercfg /lastwake) | ForEach-Object { $lines.Add($_) }
    $lines.Add("")
    $lines.Add("---- powercfg /requests (what is keeping the PC awake right now) ----")
    (powercfg /requests) | ForEach-Object { $lines.Add($_) }

    $lines | Set-Content -Path $report -Encoding UTF8
    Write-Ok "Wrote $report"
} catch {
    Write-Warn2 "Diagnosis failed: $($_.Exception.Message)"
}

if ($DiagnoseOnly) { Write-Host ""; Write-Host "DiagnoseOnly: nothing changed."; exit 0 }

# ---------------------------------------------------------------------------
# 2. Power: never sleep or hibernate on AC power
# ---------------------------------------------------------------------------
Write-Step "2. Power settings"
try {
    powercfg /change standby-timeout-ac 0   | Out-Null
    powercfg /change hibernate-timeout-ac 0 | Out-Null
    powercfg /hibernate off                 | Out-Null
    Write-Ok "Sleep and hibernate disabled on AC power (the screen can still turn off)."
} catch { Write-Warn2 "Power settings failed: $($_.Exception.Message)" }

# ---------------------------------------------------------------------------
# 3. Network adapters: don't let Windows power them down
# ---------------------------------------------------------------------------
Write-Step "3. Network adapter power management"
try {
    $adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
    $wmi = Get-CimInstance -Namespace root\wmi -ClassName MSPower_DeviceEnable -ErrorAction SilentlyContinue
    foreach ($a in $adapters) {
        $match = $wmi | Where-Object { $_.InstanceName -like "$($a.PnPDeviceID)*" }
        if ($match) {
            $match | Set-CimInstance -Property @{ Enable = $false }
            Write-Ok "$($a.Name): 'Allow the computer to turn off this device' is now off."
        } else {
            Write-Warn2 "$($a.Name): no power-management switch exposed; check Device Manager > Power Management."
        }
    }
    if (-not $adapters) { Write-Warn2 "No connected physical network adapter found." }
} catch { Write-Warn2 "Network step failed: $($_.Exception.Message)" }

# ---------------------------------------------------------------------------
# 4. Windows Update: wide Active Hours and no auto-restart while signed in
# ---------------------------------------------------------------------------
Write-Step "4. Windows Update restarts"
try {
    $ux = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
    if (-not (Test-Path $ux)) { New-Item -Path $ux -Force | Out-Null }
    Set-ItemProperty -Path $ux -Name SmartActiveHoursState -Value 0 -Type DWord
    Set-ItemProperty -Path $ux -Name ActiveHoursStart -Value $ActiveHoursStart -Type DWord
    Set-ItemProperty -Path $ux -Name ActiveHoursEnd   -Value $ActiveHoursEnd   -Type DWord
    Write-Ok "Active Hours set to ${ActiveHoursStart}:00 - ${ActiveHoursEnd}:00 (Windows allows at most 18 hours)."

    $au = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    if (-not (Test-Path $au)) { New-Item -Path $au -Force | Out-Null }
    Set-ItemProperty -Path $au -Name NoAutoRebootWithLoggedOnUsers -Value 1 -Type DWord
    Write-Ok "No automatic restart while you're signed in (fully honoured on Pro; best effort on Home)."
} catch { Write-Warn2 "Windows Update step failed: $($_.Exception.Message)" }

# ---------------------------------------------------------------------------
# 5. Console QuickEdit off (a click in a console window pauses the program)
# ---------------------------------------------------------------------------
Write-Step "5. Console QuickEdit"
try {
    Set-ItemProperty -Path 'HKCU:\Console' -Name QuickEdit -Value 0 -Type DWord
    Write-Ok "QuickEdit off for new console windows. Windows Terminal is unaffected and also safe."
} catch { Write-Warn2 "QuickEdit step failed: $($_.Exception.Message)" }

# ---------------------------------------------------------------------------
# 6. Optional: start `claude remote-control` at logon and restart it if it exits
# ---------------------------------------------------------------------------
if ($RegisterRemoteControlTask) {
    Write-Step "6. Scheduled task for claude remote-control"
    try {
        $claude = (Get-Command claude -ErrorAction Stop).Source
        if (-not (Test-Path $WorkDir)) { throw "Work folder not found: $WorkDir" }
        $action    = New-ScheduledTaskAction -Execute 'powershell.exe' `
                        -Argument "-NoExit -NoProfile -Command `"& '$claude' remote-control`"" `
                        -WorkingDirectory $WorkDir
        $trigger   = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
        $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
                        -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) `
                        -ExecutionTimeLimit ([TimeSpan]::Zero) -StartWhenAvailable
        $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited
        Register-ScheduledTask -TaskName 'Claude Remote Control' -Action $action -Trigger $trigger `
            -Settings $settings -Principal $principal -Force | Out-Null
        Write-Ok "Task 'Claude Remote Control' registered (runs in $WorkDir at logon)."
        Write-Warn2 "Test it once by hand first: Start-ScheduledTask 'Claude Remote Control'"
    } catch { Write-Warn2 "Scheduled task step failed: $($_.Exception.Message)" }
} else {
    Write-Host ""
    Write-Host "Skipped step 6. You used the Claude desktop app for Remote Control, so instead"
    Write-Host "turn on its launch-at-login setting. Re-run with -RegisterRemoteControlTask if you"
    Write-Host "switch to running 'claude remote-control' in a terminal."
}

# ---------------------------------------------------------------------------
# Manual follow-ups this script can't do for you
# ---------------------------------------------------------------------------
Write-Step "Still to do by hand"
Write-Host "  - Remote access for when you're out: set up Chrome Remote Desktop (opening the page now)."
Write-Host "  - Wake-on-LAN (optional): enable it in the BIOS/UEFI and in the adapter's Advanced tab."
Write-Host "  - Read $report and tell Claude what it found."
try { Start-Process 'https://remotedesktop.google.com/access' } catch { }
Write-Host ""
Write-Host "Done." -ForegroundColor Green
