# WebLogic

Documentation and operational guides for Oracle WebLogic Server administration, deployment, and maintenance.

---

## 📁 Repository Structure

```
weblogic/
├── README.md
└── docs/
    ├── admin/
    │   ├── wsadmin.md                    # Admin scripts and commands (Linux)
    │   ├── xclock.md                     # X11 display config for GUI tools (Linux)
    │   └── windows/
    │       └── wsadmin-windows.md        # Admin scripts and commands (Windows)
    ├── maintenance/
    │   ├── limpeza-rotina.md             # Routine cleanup procedures (Linux)
    │   └── windows/
    │       └── limpeza-rotina-windows.md # Routine cleanup procedures (Windows)
    └── war-deployment/
        ├── war-test.md                   # WAR packaging and deployment (Linux)
        └── windows/
            └── war-test-windows.md       # WAR packaging and deployment (Windows)
```

---

## 📋 Contents

### 🔧 Administration
- **wsadmin** — Scripts and commands for WebLogic Server administration via `wsadmin` tool
- **xclock / X11** — Setting up graphical display for WebLogic console access on headless servers

### 🧹 Maintenance
- **Routine Cleanup** (`limpeza-rotina`) — Step-by-step procedures for log rotation, temp file cleanup, and server health checks

### 🚀 WAR Deployment
- **WAR Test** — Guidelines for packaging, deploying, and validating WAR files on WebLogic

---

## 🚀 Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/jrmreis/middleware.git
   cd middleware/weblogic
   ```

2. Navigate to the relevant guide inside `docs/`

3. Follow the steps in each `.md` file for your use case

---

## ⚙️ Environment

| Item | Details |
|---|---|
| Server | Oracle WebLogic Server 14c (14.1.1) |
| OS | Linux / Windows Server 2016/2019/2022 |
| Tools | wsadmin, xclock, X11, PowerShell, Task Scheduler |
| Deploy | WAR files |

---

## 📌 Notes

- PDF versions of these docs are available offline but are **not versioned in this repo**
- All scripts should be reviewed before running in production
- For issues or suggestions, open a GitHub Issue

---

## 👤 Author

**jrmreis** — [github.com/jrmreis](https://github.com/jrmreis)
