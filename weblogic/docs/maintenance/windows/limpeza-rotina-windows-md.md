# Limpeza de Rotina — WebLogic 14c Routine Cleanup (Windows)

Step-by-step procedures for log rotation, temp file cleanup, and server health maintenance on Windows Server.

---

## 📋 Prerequisites

- Access to Windows Server with WebLogic installed
- `%DOMAIN_HOME%` variable set
- Scheduled maintenance window (recommended for production)
- PowerShell 5.1+ or CMD available

---

## 🗂️ Directory Reference

```
%DOMAIN_HOME%\
├── logs\                        # Domain-level logs
├── servers\
│   └── <server_name>\
│       ├── logs\                # Server logs
│       ├── tmp\                 # Temp files
│       ├── cache\               # Cache files
│       └── stage\               # Staged deployments
└── config\                      # ⚠️ Never delete
```

---

## 🧹 Step-by-Step Cleanup (PowerShell)

### 1. Stop the Managed Server
```bat
cd %DOMAIN_HOME%\bin
stopManagedWebLogic.cmd <server_name> t3://localhost:7001
```

### 2. Archive and rotate logs
```powershell
$date = Get-Date -Format "yyyy-MM-dd"
$backupDir = "C:\backup\weblogic\logs\$date"
New-Item -ItemType Directory -Force -Path $backupDir

# Move server logs
Move-Item "$env:DOMAIN_HOME\servers\<server_name>\logs\*.log*" $backupDir

# Move domain logs
Move-Item "$env:DOMAIN_HOME\logs\*.log*" $backupDir
```

### 3. Delete temp and cache files
```powershell
Remove-Item "$env:DOMAIN_HOME\servers\<server_name>\tmp\*" -Recurse -Force
Remove-Item "$env:DOMAIN_HOME\servers\<server_name>\cache\*" -Recurse -Force
```

### 4. Clear stage directory
```powershell
Remove-Item "$env:DOMAIN_HOME\servers\<server_name>\stage\*" -Recurse -Force
```

> ⚠️ Clearing `stage\` causes WebLogic to redeploy apps on next start — expected behavior.

### 5. Compress logs older than 7 days
```powershell
Get-ChildItem "C:\backup\weblogic\logs\" -Recurse -Filter "*.log" |
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
  ForEach-Object {
    Compress-Archive -Path $_.FullName -DestinationPath "$($_.FullName).zip" -Force
    Remove-Item $_.FullName
  }
```

### 6. Delete archives older than 30 days
```powershell
Get-ChildItem "C:\backup\weblogic\logs\" -Recurse -Filter "*.zip" |
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
  Remove-Item -Force
```

### 7. Restart Managed Server
```bat
cd %DOMAIN_HOME%\bin
startManagedWebLogic.cmd <server_name> http://localhost:7001
```

---

## ⏰ Automation with Windows Task Scheduler

Create a PowerShell cleanup script at `C:\scripts\weblogic\cleanup.ps1`, then schedule it:

```powershell
# Register weekly task (Sundays at 2:00 AM)
$action = New-ScheduledTaskAction `
  -Execute "PowerShell.exe" `
  -Argument "-NonInteractive -File C:\scripts\weblogic\cleanup.ps1"

$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am

Register-ScheduledTask `
  -TaskName "WebLogic_WeeklyCleanup" `
  -Action $action `
  -Trigger $trigger `
  -RunLevel Highest `
  -Description "WebLogic 14c weekly log rotation and cleanup"
```

> ✅ Best Practice: Run the task under the same service account used by WebLogic.

---

## 🔍 Health Check After Cleanup

```powershell
# Check HTTP response
$r = Invoke-WebRequest -Uri "http://localhost:7001/weblogic/ready" -UseBasicParsing
Write-Host "Status: $($r.StatusCode)"

# Check for errors in log after restart
Select-String -Path "$env:DOMAIN_HOME\servers\<server_name>\logs\<server_name>.log" `
  -Pattern "ERROR|CRITICAL" | Select-Object -Last 20
```

---

## 📌 Notes

- Never delete `%DOMAIN_HOME%\config\` — it holds domain configuration
- Always check disk space before and after: `Get-PSDrive C`
- Log rotation can also be configured in Admin Console under **Server → Logging**
- Enable **Windows Event Log** integration for centralized monitoring via SCOM or similar
