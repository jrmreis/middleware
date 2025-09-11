# COPEC Hunter PowerShell Script

PowerShell script for evidence collection and process termination. This script will search for processes with "COPEC" in the command line, collect information before and after termination.

A complete PowerShell script was created to investigate and terminate processes containing "COPEC". Here are the main functionalities:

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
