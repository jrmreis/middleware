# wsadmin — WebLogic 14c Administration on Windows

Reference guide for administering Oracle WebLogic Server 14c on Windows Server environments.

---

## 📋 Prerequisites

- Oracle WebLogic Server 14c (14.1.1) installed
- JDK 8 or JDK 11 (64-bit) installed
- `ORACLE_HOME`, `WL_HOME`, `JAVA_HOME` set as System Environment Variables
- Admin Server running

---

## 🔧 Environment Variables (System)

Set via **Control Panel → System → Advanced → Environment Variables**:

```bat
JAVA_HOME=C:\Java\jdk1.8.0_xxx
ORACLE_HOME=C:\Oracle\Middleware\Oracle_Home
WL_HOME=%ORACLE_HOME%\wlserver
DOMAIN_HOME=%ORACLE_HOME%\user_projects\domains\base_domain
PATH=%PATH%;%JAVA_HOME%\bin;%WL_HOME%\server\bin
```

Or set temporarily in CMD:
```bat
set JAVA_HOME=C:\Java\jdk1.8.0_xxx
set ORACLE_HOME=C:\Oracle\Middleware\Oracle_Home
set WL_HOME=%ORACLE_HOME%\wlserver
set DOMAIN_HOME=%ORACLE_HOME%\user_projects\domains\base_domain
```

---

## 🚀 Starting and Stopping Servers

### Start Admin Server
```bat
cd %DOMAIN_HOME%\bin
startWebLogic.cmd
```

### Start Managed Server
```bat
cd %DOMAIN_HOME%\bin
startManagedWebLogic.cmd <server_name> http://<admin_host>:7001
```

### Stop Admin Server
```bat
cd %DOMAIN_HOME%\bin
stopWebLogic.cmd
```

### Stop Managed Server
```bat
cd %DOMAIN_HOME%\bin
stopManagedWebLogic.cmd <server_name> t3://<admin_host>:7001
```

---

## 🖥️ Admin Console

```
http://<host>:7001/console
```

| Field | Value |
|---|---|
| Username | `weblogic` |
| Password | *(defined at domain creation)* |

---

## 🪟 Install as Windows Service

WebLogic can be registered as a Windows Service using the `beasvc` utility:

```bat
cd %WL_HOME%\server\bin

:: Install AdminServer as a service
beasvc install /service:WLS_AdminServer ^
  /javahome:%JAVA_HOME% ^
  /domain:%DOMAIN_HOME% ^
  /server:AdminServer ^
  /password:weblogic_password

:: Start the service
net start WLS_AdminServer

:: Stop the service
net stop WLS_AdminServer

:: Remove the service
beasvc uninstall /service:WLS_AdminServer
```

> ✅ Best Practice: Run services under a dedicated service account (not Administrator).

---

## 📜 WLST on Windows

### Launch WLST
```bat
cd %WL_HOME%\common\bin
wlst.cmd
```

### Connect and basic commands
```python
connect('weblogic', 'password', 't3://localhost:7001')

# List servers
domainRuntime()
cd('ServerRuntimes')
ls()

# Check server state
serverRuntime()
print(cmo.getState())

# Graceful shutdown
shutdown('myServer', 'Server', graceful='true', timeOut=60)
```

### Run a WLST script
```bat
wlst.cmd C:\scripts\weblogic\check_servers.py
```

---

## 🔍 Log File Paths (Windows)

```
%DOMAIN_HOME%\servers\AdminServer\logs\AdminServer.log
%DOMAIN_HOME%\servers\<server_name>\logs\<server_name>.log
%DOMAIN_HOME%\logs\<domain_name>.log
```

---

## ⚙️ JVM Tuning (setDomainEnv.cmd)

Edit `%DOMAIN_HOME%\bin\setDomainEnv.cmd`:

```bat
set USER_MEM_ARGS=-Xms512m -Xmx1024m -XX:MaxMetaspaceSize=256m
```

> ✅ Best Practice: Do not edit `setDomainEnv.cmd` directly — override via `setUserOverrides.cmd` if available, to survive patches.

---

## 🔒 Security Best Practices (Windows)

- Run WebLogic service under a **dedicated low-privilege Windows account**
- Store domain credentials using **WebLogic Boot Identity file** (`boot.properties`)
- Enable **SSL (port 7002)** for Admin Console access in production
- Use **Windows Firewall** to restrict ports 7001/7002 to admin networks only

---

## 📌 Notes

- WebLogic 14c supports JDK 8 and JDK 11 on Windows Server 2016/2019/2022
- Always use 64-bit JDK on Windows Server
- Avoid spaces in `ORACLE_HOME` path (e.g., avoid `C:\Program Files\`)
