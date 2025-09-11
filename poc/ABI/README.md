# COPEC Hunter PowerShell Script

PowerShell script for evidence collection and process termination. This script will search for processes with "COPEC" in the command line, collect information before and after termination.

## Configuration

Run the script with `-config` parameter to configure the target process.

**Example:** 
```powershell
.\copec_hunter.ps1 -config
```
```shell-session
CONFIGURATION MODE ACTIVATED

=== TARGET PROCESS CONFIGURATION ===
This mode allows you to configure which process to monitor based on an existing PID.
The script will extract the CommandLine from the provided PID and use it as search pattern.
=========================================

Enter the PID of the process you want to monitor: 10756
Searching for process with PID: 10756...

=== FOUND PROCESS INFORMATION ===
PID: 10756
Name: powershell.exe
Executable: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
Command Line:
  "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -WindowStyle Minimized -ExecutionPolicy Bypass -File "C:\inetpub\wwwroot\COPEC\copec_worker.ps1"
=============================================
```



## **Script Features:**

### **1. Intelligent Search**
- Searches for processes with "COPEC" in the command line
- If not found, also searches in the process name
- Provides detailed feedback about what was found

### **2. PRE-Termination Evidence Collection**
- **Process PID**
- **Memory usage** (Working Set, Virtual, Page File)
- **Complete command line**
- **Executable path**
- **Creation date**
- **Parent process PID**
- **Process handle**

### **3. Controlled Termination**
- Attempts graceful termination first
- If it fails, forces termination
- Records the method used

### **4. POST-Termination Verification**
- Confirms if the process was actually terminated
- Collects termination evidence with timestamp
- Alerts if the process is still running

### **5. Complete Documentation**
- Detailed log with timestamps (`copec_investigation.log`)
- Evidence saved in JSON files
- Final operation summary

## **How to Use:**

1. **Save the script** as `copec_hunter.ps1`
2. **Run as administrator** in PowerShell:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\copec_hunter.ps1
   ```

## **Generated Files:**
- `copec_investigation.log` - Complete operation log
- `copec_evidence_PID_[number]_[timestamp].json` - Pre-termination evidence
- `copec_termination_PID_[number]_[timestamp].json` - Post-termination evidence

The script is safe and provides complete documentation for auditing or subsequent forensic analysis.
