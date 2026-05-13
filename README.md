# Nvidia GPU Monitoring for PRTG

Monitor GPU with Nvidia-SMI and send data to PRTG.
Monitor usage, vram usage and temperature for one gpu system.

## Tested on
- Windows Server 2022 (built-in powershell)
- Windows 11 Pro (built-in powershell)

## Setup 

Create a **HTTP Push Data Advanced** sensor in your PRTG and grab the **Identification Token**.

Download the script:
```powershell
$sourceUrl = "https://raw.githubusercontent.com/stylersnico/prtg-nvidia-monitoring-push/refs/heads/main/gpu_monitor.ps1"
$destinationPath = "C:\_Scripts\gpu_monitor.ps1"
if (-Not (Test-Path -Path ([System.IO.Path]::GetDirectoryName($destinationPath)))) {
    New-Item -ItemType Directory -Force -Path ([System.IO.Path]::GetDirectoryName($destinationPath))
}
Invoke-WebRequest -Uri $sourceUrl -OutFile $destinationPath
```

Edit it to put your **PRTG IP** and **Identification token** at the end.

Create a scheduled task that send the data every minute:
```powershell
$taskName = "GPU_Monitor"
$scriptPath = "C:\_Scripts\gpu_monitor.ps1"
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration (New-TimeSpan -Days 365)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "GPU Monitor Script" -User "SYSTEM"
```

When the data is in PRTG, edit the alerting depending on your GPU.

## Screenshots
<img width="1940" height="768" alt="gpu-usage" src="https://github.com/user-attachments/assets/5774662f-6ea9-4ac1-b083-c47d665d0563" />
