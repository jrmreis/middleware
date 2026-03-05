# WAR Test — Packaging and Deployment on WebLogic 14c (Windows)

Guide for packaging, deploying, and validating WAR files on Oracle WebLogic Server 14c running on Windows Server.

---

## 📋 Prerequisites

- JDK 8 or JDK 11 (64-bit) installed
- `%WL_HOME%` and `%DOMAIN_HOME%` set
- WebLogic Admin Server running
- Maven or manually built WAR file ready

---

## 📦 Building the WAR

### Using Maven (CMD)
```bat
cd C:\projects\myapp
mvn clean package -DskipTests
:: Output: target\myapp.war
```

### Manual packaging
```bat
jar -cvf myapp.war -C WebContent .
```

Expected WAR structure:
```
myapp.war
├── WEB-INF\
│   ├── web.xml
│   └── weblogic.xml       # WebLogic-specific descriptor
├── index.jsp
└── META-INF\
    └── MANIFEST.MF
```

---

## 📄 weblogic.xml Descriptor (Minimal)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<weblogic-web-app
  xmlns="http://xmlns.oracle.com/weblogic/weblogic-web-app"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <weblogic-version>14.1.1</weblogic-version>
  <context-root>/myapp</context-root>

  <session-descriptor>
    <timeout-secs>3600</timeout-secs>
  </session-descriptor>

</weblogic-web-app>
```

---

## 🚀 Deploying via Admin Console

1. Access `http://<host>:7001/console`
2. Navigate to **Deployments → Install**
3. Upload or specify path to `myapp.war`
4. Select target server(s)
5. Set deployment type: **Install and start deployment**
6. Confirm and finish

---

## 🚀 Deploying via WLST (Windows)

```bat
cd %WL_HOME%\common\bin
wlst.cmd
```

```python
connect('weblogic', 'password', 't3://localhost:7001')
deploy(
    appName='myapp',
    path='C:\\deployments\\myapp.war',
    targets='myManagedServer',
    stageMode='nostage'
)
```

> ✅ Best Practice: Always use double backslashes `\\` in WLST paths on Windows.

---

## 🚀 Deploying via weblogic.Deployer (CMD)

```bat
java weblogic.Deployer ^
  -adminurl t3://localhost:7001 ^
  -username weblogic ^
  -password password ^
  -deploy ^
  -name myapp ^
  -source C:\deployments\myapp.war ^
  -targets myManagedServer
```

---

## 🚀 Deploying via PowerShell Script

```powershell
$javaArgs = @(
  "weblogic.Deployer",
  "-adminurl", "t3://localhost:7001",
  "-username", "weblogic",
  "-password", "password",
  "-deploy",
  "-name", "myapp",
  "-source", "C:\deployments\myapp.war",
  "-targets", "myManagedServer"
)
& java $javaArgs
```

---

## ✅ Validating the Deployment

### Check via browser
```
http://<host>:<port>/myapp
```

### Check via PowerShell
```powershell
$r = Invoke-WebRequest -Uri "http://localhost:7001/myapp" -UseBasicParsing
Write-Host "HTTP Status: $($r.StatusCode)"
# Expected: 200
```

### Check deployment state via WLST
```python
connect('weblogic', 'password', 't3://localhost:7001')
domainRuntime()
cd('AppRuntimeStateRuntime/AppRuntimeStateRuntime')
print(cmo.getCurrentState('myapp', 'myManagedServer'))
# Expected: STATE_ACTIVE
```

---

## 🔁 Redeployment / Update

```bat
java weblogic.Deployer ^
  -adminurl t3://localhost:7001 ^
  -username weblogic ^
  -password password ^
  -redeploy ^
  -name myapp ^
  -source C:\deployments\myapp.war
```

---

## 🛠️ Troubleshooting

| Symptom | Check |
|---|---|
| 404 after deploy | Verify `context-root` in `weblogic.xml` |
| Deploy fails with classloading error | Check shared libraries and classpath |
| App stuck in `STATE_NEW` | Check `%DOMAIN_HOME%\servers\<name>\logs\` for errors |
| Path not found error | Use double backslashes `\\` or forward slashes `/` in paths |
| Access denied on WAR file | Check NTFS permissions for the WebLogic service account |

---

## 🔒 Security Best Practices (Windows)

- Grant the WebLogic service account **read-only** access to WAR source directories
- Store deployment credentials in an **encrypted `boot.properties`** file instead of plain text
- Use **SSL (t3s://)** for deployer connections in production
- Enable **deployment auditing** in Admin Console under Security → Audit

---

## 📌 Notes

- WebLogic 14c on Windows supports Servlet 4.0 and Java EE 8
- Use `nostage` mode for large WARs on Windows to avoid copying overhead
- Avoid placing WAR files under paths with spaces (e.g., `C:\Program Files\`)
- Test WAR in dev/staging domain before deploying to production
