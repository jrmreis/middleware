# Script to locate, collect evidence and terminate cmd_line process
# Author: Joel R M Reis (ABI - Middleware Team)
# Date: sept-2025
# Version: 2.1 - With dynamic configuration via PID

# IMPORTANT: param block must be first executable statement
param(
    [switch]$config
)

# ===== DIRECTORY SETUP =====
# Check if logs directory exists, create if not
$script:logDirectory = ".\logs"
if (-not (Test-Path -Path $script:logDirectory)) {
    Write-Host "Creating logs directory: $script:logDirectory" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $script:logDirectory -Force | Out-Null
    Write-Host "Logs directory created successfully." -ForegroundColor Green
} else {
    Write-Host "Logs directory already exists: $script:logDirectory" -ForegroundColor Green
}
$script:confDirectory = ".\config"
if (-not (Test-Path -Path $script:confDirectory)) {
    Write-Host "Creating cofig directory: $script:confDirectory" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $script:confDirectory -Force | Out-Null
    Write-Host "Config directory created successfully." -ForegroundColor Green
} else {
    Write-Host "Config directory already exists: $script:confDirectory" -ForegroundColor Green
}

# Configuration file
$configFile = "$script:confDirectory\process_config.json"

# Configuration Process Target
$processTarget = "xfmdatasource.exe"

# Function to log entries with timestamp
function Write-Log {
    param($Message, $Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logEntry = "[$timestamp] [$Type] $Message"
    Write-Host $logEntry
    $logEntry | Out-File -FilePath "$script:logDirectory\process_monitor.log" -Append -Encoding UTF8
}

# Function to configure target process via PID
function Set-ProcessConfiguration {
    Write-Host "`n=== TARGET PROCESS CONFIGURATION ===" -ForegroundColor Yellow
    Write-Host "This mode allows you to configure which process to monitor based on an existing PID." -ForegroundColor White
    Write-Host "The script will extract the CommandLine from the provided PID and use it as search pattern." -ForegroundColor White
    Write-Host "=========================================" -ForegroundColor Yellow
    
    do {
        $pidInput = Read-Host "`nEnter the PID of the process you want to monitor"
        
        if ([string]::IsNullOrWhiteSpace($pidInput)) {
            Write-Host "PID cannot be empty. Please try again." -ForegroundColor Red
            continue
        }
        
        if (-not ($pidInput -match '^\d+$')) {
            Write-Host "PID must be a valid number. Please try again." -ForegroundColor Red
            continue
        }
        
        $targetPid = [int]$pidInput
        
        try {
            Write-Host "Searching for process with PID: $targetPid..." -ForegroundColor Cyan
            
            # Get process information via PID
            $processInfo = Get-CimInstance Win32_Process -Filter "ProcessId = $targetPid" -ErrorAction Stop
            
            if (-not $processInfo) {
                Write-Host "Process with PID $targetPid not found. Please try again." -ForegroundColor Red
                continue
            }
            
            # Extract process information
            $commandLine = $processInfo.CommandLine
            $processName = $processInfo.Name
            $executablePath = $processInfo.ExecutablePath

            if (($processName -eq $processTarget)) {
                Write-Host "Checking Process Name... ${processName}, allowed." -ForegroundColor Green
            } else {
                Write-Host "Look out! The Process Name ${processName} is not allowed to continue!" -ForegroundColor Red
                exit 1
            }

            # Display process information
            
            Write-Host "`n=== FOUND PROCESS INFORMATION ===" -ForegroundColor Green
            Write-Host "PID: $targetPid" -ForegroundColor White
            Write-Host "Name: $processName" -ForegroundColor White
            Write-Host "Executable: $executablePath" -ForegroundColor White
            Write-Host "Command Line:" -ForegroundColor White
            Write-Host "  $commandLine" -ForegroundColor Gray
            Write-Host "=============================================" -ForegroundColor Green
            
            if ([string]::IsNullOrWhiteSpace($commandLine)) {
                Write-Host "`nWARNING: The process does not have a detectable CommandLine." -ForegroundColor Yellow
                Write-Host "This can happen with system processes or those with restricted permissions." -ForegroundColor Yellow
                
                $useProcessName = Read-Host "Do you want to use the process name ($processName) as search pattern? (Y/N)"
                if ($useProcessName -match '^[Yy]') {
                    $commandLine = $processName
                    Write-Host "Configuration set to search by process name: $processName" -ForegroundColor Green
                } else {
                    Write-Host "Configuration cancelled by user." -ForegroundColor Red
                    continue
                }
            }
            
            # Confirm configuration
            Write-Host "`nThis pattern will be used to find the process during monitoring." -ForegroundColor Cyan
            $confirm = Read-Host "Confirm this configuration? (Y/N)"
            
            if ($confirm -match '^[Yy]') {
                # Save configuration
                $config = @{
                    ConfiguredAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
                    ConfiguredBy = $env:USERNAME
                    Computer = $env:COMPUTERNAME
                    SourcePID = $targetPid
                    ProcessName = $processName
                    ExecutablePath = $executablePath
                    CommandLinePattern = $commandLine
                    SearchMethod = if ([string]::IsNullOrWhiteSpace($processInfo.CommandLine)) { "ProcessName" } else { "CommandLine" }
                }
                
                $config | ConvertTo-Json -Depth 2 | Out-File -FilePath $configFile -Encoding UTF8
                
                Write-Host "`n=== CONFIGURATION SAVED SUCCESSFULLY ===" -ForegroundColor Green
                Write-Host "File: $configFile" -ForegroundColor White
                Write-Host "Search pattern: $commandLine" -ForegroundColor White
                Write-Host "Method: $($config.SearchMethod)" -ForegroundColor White
                Write-Host "====================================" -ForegroundColor Green
                
                Write-Host "`nNow you can run the script normally to monitor this type of process." -ForegroundColor Cyan
                Write-Host "Example: .\cmd_line_hunter.ps1" -ForegroundColor White
                
                return $true
            } else {
                Write-Host "Configuration cancelled by user." -ForegroundColor Yellow
                continue
            }
            
        } catch {
            Write-Host "Error accessing process PID $targetPid : $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Check if the PID exists and if you have adequate permissions." -ForegroundColor Yellow
            continue
        }
        
    } while ($true)
    
    return $false
}

# Function to load configuration
function Get-ProcessConfiguration {
    if (-not (Test-Path $configFile)) {
        Write-Host "Configuration file not found: $configFile" -ForegroundColor Red
        Write-Host "Run the script with -config parameter to configure the target process." -ForegroundColor Yellow
        Write-Host "Example: .\cmd_line_hunter.ps1 -config" -ForegroundColor White
        return $null
    }
    
    try {
        $config = Get-Content $configFile -Raw | ConvertFrom-Json
        Write-Log "Configuration loaded: $configFile" "CONFIG"
        Write-Log "Search pattern: $($config.CommandLinePattern)" "CONFIG"
        Write-Log "Search method: $($config.SearchMethod)" "CONFIG"
        return $config
    } catch {
        Write-Log "Error loading configuration: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

# Function to find target process based on configuration
function Find-TargetProcess {
    param($Config)
    
    if (-not $Config) {
        return $null
    }
    
    try {
        # Special handling for xfmdatasource.exe - search by command line pattern
        if ($Config.ProcessName -eq $processTarget -or $Config.CommandLinePattern -like "*xfmdatasource.exe*") {
            Write-Log "Searching for xfmdatasource.exe by command line pattern: $($Config.CommandLinePattern)" "INFO"
            $targetProcess = Get-CimInstance -ClassName Win32_Process | Where-Object {
                $_.Name -eq $processTarget -and 
                $_.CommandLine -like "*$($Config.CommandLinePattern)*"
            }
        }
        
        return $targetProcess
        
    } catch {
        Write-Log "Error searching for process: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

# Function to collect CPU and Memory information
function Get-ProcessPerformance {
    param($ProcessInfo)
    
    try {
        # Get process information via Get-Process for CPU
        $process = Get-Process -Id $ProcessInfo.ProcessId -ErrorAction SilentlyContinue
        
        if ($process) {
            # Calculate CPU usage (requires two measurements)
            $cpu1 = $process.CPU
            Start-Sleep -Milliseconds 500
            $process = Get-Process -Id $ProcessInfo.ProcessId -ErrorAction SilentlyContinue
            $cpu2 = $process.CPU
            $cpuUsage = if ($cpu2 -gt $cpu1) { [math]::Round(($cpu2 - $cpu1) * 2, 2) } else { 0 }
            
            $performance = @{
                # CPU Information
                CPUUsagePercent = $cpuUsage
                TotalProcessorTime = [math]::Round($process.TotalProcessorTime.TotalSeconds, 2)
                
                # Memory Information (in MB)
                WorkingSetMB = [math]::Round($process.WorkingSet / 1MB, 2)
                VirtualMemoryMB = [math]::Round($ProcessInfo.VirtualSize / 1MB, 2)
                PagedMemoryMB = [math]::Round($process.PagedMemorySize / 1MB, 2)
                NonPagedMemoryMB = [math]::Round($process.NonpagedSystemMemorySize / 1MB, 2)
                PrivateMemoryMB = [math]::Round($process.PrivateMemorySize / 1MB, 2)
                PageFileUsageMB = [math]::Round($ProcessInfo.PageFileUsage / 1MB, 2)
                
                # Additional Info
                HandleCount = $process.HandleCount
                ThreadCount = $process.Threads.Count
                PriorityClass = $process.PriorityClass
            }
        } else {
            $performance = @{
                CPUUsagePercent = "N/A"
                TotalProcessorTime = "N/A"
                WorkingSetMB = [math]::Round($ProcessInfo.WorkingSetSize / 1MB, 2)
                VirtualMemoryMB = [math]::Round($ProcessInfo.VirtualSize / 1MB, 2)
                PagedMemoryMB = "N/A"
                NonPagedMemoryMB = "N/A"
                PrivateMemoryMB = "N/A"
                PageFileUsageMB = [math]::Round($ProcessInfo.PageFileUsage / 1MB, 2)
                HandleCount = "N/A"
                ThreadCount = "N/A"
                PriorityClass = "N/A"
            }
        }
        
        return $performance
    } catch {
        Write-Log "Error collecting performance information: $($_.Exception.Message)" "WARNING"
        return @{
            CPUUsagePercent = "ERROR"
            WorkingSetMB = "ERROR"
            VirtualMemoryMB = "ERROR"
        }
    }
}

# Function to display performance information in logs
function Show-Performance {
    param($Performance, $Phase)
    
    Write-Log "=== CPU AND MEMORY INFORMATION - $Phase ===" "PERFORMANCE"
    Write-Log "CPU Usage: $($Performance.CPUUsagePercent)%" "PERFORMANCE"
    Write-Log "Total CPU Time: $($Performance.TotalProcessorTime)s" "PERFORMANCE"
    Write-Log "Working Set (RAM): $($Performance.WorkingSetMB) MB" "PERFORMANCE"
    Write-Log "Virtual Memory: $($Performance.VirtualMemoryMB) MB" "PERFORMANCE"
    Write-Log "Paged Memory: $($Performance.PagedMemoryMB) MB" "PERFORMANCE"
    Write-Log "Non-Paged Memory: $($Performance.NonPagedMemoryMB) MB" "PERFORMANCE"
    Write-Log "Private Memory: $($Performance.PrivateMemoryMB) MB" "PERFORMANCE"
    Write-Log "Page File Usage: $($Performance.PageFileUsageMB) MB" "PERFORMANCE"
    Write-Log "Handle Count: $($Performance.HandleCount)" "PERFORMANCE"
    Write-Log "Thread Count: $($Performance.ThreadCount)" "PERFORMANCE"
    Write-Log "Priority Class: $($Performance.PriorityClass)" "PERFORMANCE"
    Write-Log "===============================================" "PERFORMANCE"
}

# ===== MAIN EXECUTION =====

# Check if in configuration mode
if ($config) {
    Write-Host "CONFIGURATION MODE ACTIVATED" -ForegroundColor Cyan
    $configResult = Set-ProcessConfiguration
    if (-not $configResult) {
        Write-Host "Configuration was not completed." -ForegroundColor Red
        exit 1
    }
    exit 0
}

# Start of monitoring script
Write-Log "=== STARTING PROCESS MONITORING ===" "START"
Write-Log "User: $env:USERNAME | Computer: $env:COMPUTERNAME" "INFO"

try {
    # Load configuration
    $processConfig = Get-ProcessConfiguration
    if (-not $processConfig) {
        Write-Log "Could not load configuration. Run with -config first." "ERROR"
        exit 1
    }
    
    Write-Log "Configuration loaded - Pattern: $($processConfig.CommandLinePattern)" "CONFIG"
    
    # ===== PHASE 1: FIND PROCESS BEFORE TASKKILL =====
    Write-Log "Searching for target process..." "SEARCH"
    
    $processBeforeKill = Find-TargetProcess -Config $processConfig
    
    if (-not $processBeforeKill) {
        Write-Log "Target process not found. Ending monitoring." "ERROR"
        Write-Log "Search pattern: $($processConfig.CommandLinePattern)" "ERROR"
        exit 1
    }
    
    # Record evidence BEFORE taskkill
    $pidBefore = $processBeforeKill.ProcessId
    $commandLine = $processBeforeKill.CommandLine
    $creationTime = $processBeforeKill.CreationDate
    
    Write-Log "=== PID RECORDED BEFORE TASKKILL ===" "CRITICAL"
    Write-Log "PID: $pidBefore" "CRITICAL"
    Write-Log "Command: $commandLine" "CRITICAL"
    Write-Log "Created at: $creationTime" "CRITICAL"
    Write-Log "============================================" "CRITICAL"
    
    # Collect CPU and Memory information BEFORE taskkill
    Write-Log "Collecting performance information..." "COLLECT"
    $performanceBefore = Get-ProcessPerformance -ProcessInfo $processBeforeKill
    Show-Performance -Performance $performanceBefore -Phase "BEFORE TASKKILL"
    
    # Save pre-taskkill evidence
    $evidenceBefore = @{
        Phase = "BEFORE_TASKKILL"
        Configuration = $processConfig
        PID = $pidBefore
        ProcessName = $processBeforeKill.Name
        CommandLine = $commandLine
        CreationDate = $creationTime
        ParentPID = $processBeforeKill.ParentProcessId
        ExecutablePath = $processBeforeKill.ExecutablePath
        Performance = $performanceBefore
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    }
    
    $evidenceFile = "$script:logDirectory\process_pid_before_taskkill_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $evidenceBefore | ConvertTo-Json -Depth 4 | Out-File -FilePath $evidenceFile -Encoding UTF8
    Write-Log "PRE-TASKKILL evidence saved: $evidenceFile" "SAVE"
    
    # ===== PHASE 2: EXECUTE TASKKILL =====
    Write-Log "Executing taskkill on PID: $pidBefore" "TASKKILL"
    
    $taskkillTime = Get-Date
    $taskkillResult = taskkill /F /PID $pidBefore 2>&1
    
    Write-Log "Command executed: taskkill /F /PID $pidBefore" "TASKKILL"
    Write-Log "Result: $taskkillResult" "TASKKILL"
    Write-Log "Taskkill time: $($taskkillTime.ToString('yyyy-MM-dd HH:mm:ss.fff'))" "TASKKILL"
    
    # ===== PHASE 3: WAIT 20 SECONDS AND MONITOR =====
    Write-Log "Waiting 20 seconds to check for respawn..." "MONITOR"
    
    for ($i = 1; $i -le 20; $i++) {
        Start-Sleep -Seconds 1
        Write-Log "Monitoring: $i/20 seconds" "MONITOR"
    }
    
    # ===== PHASE 4: CHECK IF PROCESS RESPAWNED =====
    Write-Log "Checking if process respawned..." "SEARCH"
    
    $processAfterKill = Find-TargetProcess -Config $processConfig
    
    if ($processAfterKill) {
        $pidAfter = $processAfterKill.ProcessId
        $newCreationTime = $processAfterKill.CreationDate
        
        Write-Log "=== PROCESS RESPAWNED - NEW PID DETECTED ===" "CRITICAL"
        Write-Log "Original PID: $pidBefore" "CRITICAL"
        Write-Log "NEW PID: $pidAfter" "CRITICAL"
        Write-Log "New creation: $newCreationTime" "CRITICAL"
        Write-Log "Command: $($processAfterKill.CommandLine)" "CRITICAL"
        Write-Log "===============================================" "CRITICAL"
        
        # Collect CPU and Memory information of respawned process
        Write-Log "Collecting performance of respawned process..." "COLLECT"
        $performanceAfter = Get-ProcessPerformance -ProcessInfo $processAfterKill
        Show-Performance -Performance $performanceAfter -Phase "AFTER RESPAWN"
        
        # Save post-taskkill evidence (respawn detected)
        $evidenceAfter = @{
            Phase = "AFTER_TASKKILL_RESPAWN"
            Configuration = $processConfig
            OriginalPID = $pidBefore
            NewPID = $pidAfter
            ProcessName = $processAfterKill.Name
            CommandLine = $processAfterKill.CommandLine
            OriginalCreationDate = $creationTime
            NewCreationDate = $newCreationTime
            ParentPID = $processAfterKill.ParentProcessId
            ExecutablePath = $processAfterKill.ExecutablePath
            PerformanceBefore = $performanceBefore
            PerformanceAfter = $performanceAfter
            TaskkillTime = $taskkillTime.ToString('yyyy-MM-dd HH:mm:ss.fff')
            RespawnDetectedTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            MonitoringDuration = "20 seconds"
        }
        
        $respawnFile = "$script:logDirectory\process_pid_after_respawn_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        $evidenceAfter | ConvertTo-Json -Depth 4 | Out-File -FilePath $respawnFile -Encoding UTF8
        Write-Log "POST-TASKKILL evidence (RESPAWN) saved: $respawnFile" "SAVE"
        
    } else {
        Write-Log "=== PROCESS DID NOT RESPAWN ===" "SUCCESS"
        Write-Log "Original PID: $pidBefore was successfully terminated" "SUCCESS"
        Write-Log "No new process detected after 20 seconds" "SUCCESS"
        Write-Log "=============================" "SUCCESS"
        
        # Save post-taskkill evidence (no respawn)
        $evidenceAfter = @{
            Phase = "AFTER_TASKKILL_NO_RESPAWN"
            Configuration = $processConfig
            OriginalPID = $pidBefore
            NewPID = "N/A"
            ProcessName = $processBeforeKill.Name
            CommandLine = $commandLine
            OriginalCreationDate = $creationTime
            PerformanceBefore = $performanceBefore
            PerformanceAfter = "N/A - Process did not respawn"
            TaskkillTime = $taskkillTime.ToString('yyyy-MM-dd HH:mm:ss.fff')
            VerificationTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            MonitoringDuration = "20 seconds"
            Status = "PROCESS_TERMINATED_PERMANENTLY"
        }
        
        $noRespawnFile = "$script:logDirectory\process_pid_no_respawn_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        $evidenceAfter | ConvertTo-Json -Depth 4 | Out-File -FilePath $noRespawnFile -Encoding UTF8
        Write-Log "POST-TASKKILL evidence (NO RESPAWN) saved: $noRespawnFile" "SAVE"
    }
    
} catch {
    Write-Log "Error during execution: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.Exception.StackTrace)" "ERROR"
} finally {
    Write-Log "=== MONITORING COMPLETED ===" "END"
    Write-Log "Complete log: $script:logDirectory\process_monitor.log" "INFO"
}

# Final summary
Write-Host "`n=== MONITORING SUMMARY ===" -ForegroundColor Yellow
Write-Host "Date/Time: $(Get-Date)" -ForegroundColor White
Write-Host "User: $env:USERNAME" -ForegroundColor White
Write-Host "Computer: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "Configuration: $configFile" -ForegroundColor White
Write-Host "Main log: $script:logDirectory\process_monitor.log" -ForegroundColor White
Write-Host "Evidence: JSON files in directory $script:logDirectory" -ForegroundColor White
Write-Host "===============================" -ForegroundColor Yellow
