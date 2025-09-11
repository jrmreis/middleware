# Script to locate, collect evidence and terminate COPEC process
# Author: Joel R M Reis (ABI - Middleware Team)
# Date: july-2025

# Function to log entries with timestamp
function Write-Log {
    param($Message, $Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    Write-Host $logEntry
    $logEntry | Out-File -FilePath ".\log\copec_investigation.log" -Append -Encoding UTF8
}

# Function to collect detailed process information
function Get-ProcessEvidence {
    param($ProcessInfo)
    
    $evidence = @{
        PID = $ProcessInfo.ProcessId
        ProcessName = $ProcessInfo.Name
        CommandLine = $ProcessInfo.CommandLine
        WorkingSetSize = [math]::Round($ProcessInfo.WorkingSetSize / 1MB, 2)
        VirtualSize = [math]::Round($ProcessInfo.VirtualSize / 1MB, 2)
        PageFileUsage = [math]::Round($ProcessInfo.PageFileUsage / 1MB, 2)
        CreationDate = $ProcessInfo.CreationDate
        ParentProcessId = $ProcessInfo.ParentProcessId
        ExecutablePath = $ProcessInfo.ExecutablePath
        Handle = $ProcessInfo.Handle
    }
    
    return $evidence
}

# Function to display formatted evidence
function Show-Evidence {
    param($Evidence, $Phase)
    
    Write-Log "=== EVIDENCE COLLECTED - $Phase ===" "EVIDENCE"
    Write-Log "PID: $($Evidence.PID)" "EVIDENCE"
    Write-Log "Process Name: $($Evidence.ProcessName)" "EVIDENCE"
    Write-Log "Command Line: $($Evidence.CommandLine)" "EVIDENCE"
    Write-Log "Working Set Memory: $($Evidence.WorkingSetSize) MB" "EVIDENCE"
    Write-Log "Virtual Memory: $($Evidence.VirtualSize) MB" "EVIDENCE"
    Write-Log "Page File Usage: $($Evidence.PageFileUsage) MB" "EVIDENCE"
    Write-Log "Creation Date: $($Evidence.CreationDate)" "EVIDENCE"
    Write-Log "Parent Process PID: $($Evidence.ParentProcessId)" "EVIDENCE"
    Write-Log "Executable Path: $($Evidence.ExecutablePath)" "EVIDENCE"
    Write-Log "Handle: $($Evidence.Handle)" "EVIDENCE"
    Write-Log "=====================================`n" "EVIDENCE"
}

# Script start
Write-Log "Starting COPEC process investigation..." "START"
Write-Log "Running as: $env:USERNAME on $env:COMPUTERNAME" "INFO"

try {
    # Search for processes containing "COPEC" in command line
    Write-Log "Searching for processes with 'COPEC' in command line..." "SEARCH"
    
    $copecProcesses = Get-CimInstance -ClassName Win32_Process | Where-Object {
        $_.CommandLine -like "*COPEC*"
    }
    
    if ($copecProcesses.Count -eq 0) {
        Write-Log "No processes found with 'COPEC' in command line." "WARNING"
        Write-Log "Checking if process exists with similar name..." "SEARCH"
        
        # Alternative search by process name
        $alternativeSearch = Get-Process | Where-Object {
            $_.ProcessName -like "*COPEC*"
        }
        
        if ($alternativeSearch.Count -eq 0) {
            Write-Log "No processes found with 'COPEC' in name." "WARNING"
            exit 1
        } else {
            Write-Log "Found $($alternativeSearch.Count) process(es) with 'COPEC' in name." "INFO"
            # Convert to WMI format to have complete information
            $copecProcesses = $alternativeSearch | ForEach-Object {
                Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($_.Id)"
            }
        }
    } else {
        Write-Log "Found $($copecProcesses.Count) process(es) with 'COPEC' in command line." "INFO"
    }
    
    foreach ($process in $copecProcesses) {
        Write-Log "Processing PID: $($process.ProcessId)" "PROCESS"
        
        # ===== PHASE 1: PRE-TERMINATION EVIDENCE COLLECTION =====
        Write-Log "Collecting PRE-TERMINATION evidence..." "COLLECT"
        $preTerminationEvidence = Get-ProcessEvidence -ProcessInfo $process
        Show-Evidence -Evidence $preTerminationEvidence -Phase "PRE-TERMINATION"
        
        # Save evidence to JSON file for later analysis
        $evidenceFile = ".\log\copec_evidence_PID_$($process.ProcessId)_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        $preTerminationEvidence | ConvertTo-Json -Depth 3 | Out-File -FilePath $evidenceFile -Encoding UTF8
        Write-Log "Evidence saved to: $evidenceFile" "SAVE"
        
        # ===== PHASE 2: PROCESS TERMINATION =====
        Write-Log "Attempting to terminate process PID: $($process.ProcessId)..." "TERMINATE"
        
        try {
            # Try graceful termination first
            $targetProcess = Get-Process -Id $process.ProcessId -ErrorAction SilentlyContinue
            if ($targetProcess) {
                $targetProcess.CloseMainWindow()
                Start-Sleep -Seconds 3
                
                # Check if still running
                $stillRunning = Get-Process -Id $process.ProcessId -ErrorAction SilentlyContinue
                if ($stillRunning) {
                    Write-Log "Graceful termination failed. Forcing termination..." "WARNING"
                    Stop-Process -Id $process.ProcessId -Force
                    Start-Sleep -Seconds 2
                }
            }
            
            Write-Log "Process PID $($process.ProcessId) has been terminated." "SUCCESS"
            
        } catch {
            Write-Log "Error terminating process PID $($process.ProcessId): $($_.Exception.Message)" "ERROR"
            continue
        }
        
        # ===== PHASE 3: POST-TERMINATION VERIFICATION =====
        Write-Log "Verifying POST-TERMINATION status..." "VERIFY"
        
        Start-Sleep -Seconds 2
        $postProcess = Get-Process -Id $process.ProcessId -ErrorAction SilentlyContinue
        
        if ($postProcess) {
            Write-Log "WARNING: Process PID $($process.ProcessId) is still running!" "WARNING"
            
            # Collect evidence after termination attempt
            $postWmiProcess = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($process.ProcessId)" -ErrorAction SilentlyContinue
            if ($postWmiProcess) {
                $postTerminationEvidence = Get-ProcessEvidence -ProcessInfo $postWmiProcess
                Show-Evidence -Evidence $postTerminationEvidence -Phase "POST-TERMINATION ATTEMPT"
            }
        } else {
            Write-Log "CONFIRMED: Process PID $($process.ProcessId) was successfully terminated." "SUCCESS"
            
            # Termination evidence
            $terminationEvidence = @{
                PID = $process.ProcessId
                ProcessName = $process.Name
                TerminationTime = Get-Date
                Status = "TERMINATED"
                Method = "PowerShell Script"
            }
            
            Write-Log "=== POST-TERMINATION EVIDENCE ===" "EVIDENCE"
            Write-Log "PID: $($terminationEvidence.PID)" "EVIDENCE"
            Write-Log "Name: $($terminationEvidence.ProcessName)" "EVIDENCE"
            Write-Log "Termination Time: $($terminationEvidence.TerminationTime)" "EVIDENCE"
            Write-Log "Status: $($terminationEvidence.Status)" "EVIDENCE"
            Write-Log "Method: $($terminationEvidence.Method)" "EVIDENCE"
            Write-Log "====================================`n" "EVIDENCE"
            
            # Save termination evidence
            $terminationFile = ".\log\copec_termination_PID_$($process.ProcessId)_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
            $terminationEvidence | ConvertTo-Json -Depth 3 | Out-File -FilePath $terminationFile -Encoding UTF8
            Write-Log "Termination evidence saved to: $terminationFile" "SAVE"
        }
        
        Write-Log "Processing of PID $($process.ProcessId) completed.`n" "COMPLETE"
    }
    
} catch {
    Write-Log "Error during execution: $($_.Exception.Message)" "ERROR"
    Write-Log "Stack Trace: $($_.Exception.StackTrace)" "ERROR"
} finally {
    Write-Log "Investigation completed." "END"
    Write-Log "Logs saved to: .\log\copec_investigation.log" "INFO"
    Write-Log "Evidence saved to JSON files in current directory." "INFO"
}

# Final summary
Write-Host "`n=== OPERATION SUMMARY ===" -ForegroundColor Yellow
Write-Host "Date/Time: $(Get-Date)" -ForegroundColor White
Write-Host "User: $env:USERNAME" -ForegroundColor White
Write-Host "Computer: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "Complete log: .\log\copec_investigation.log" -ForegroundColor White
Write-Host "Evidence: JSON files in current directory" -ForegroundColor White
Write-Host "============================" -ForegroundColor Yellow
