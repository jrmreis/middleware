# WAR Test — Packaging and Deployment on WebLogic 14c

Guide for packaging, deploying, and validating WAR (Web Application Archive) files on Oracle WebLogic Server 14c.

---

## 📋 Prerequisites

- JDK 8 or JDK 11 installed
- `$WL_HOME` and `$DOMAIN_HOME` set
- WebLogic Admin Server running
- A Maven or manually built WAR file ready

---

## 📦 Building the WAR

### Using Maven
```bash
mvn clean package -DskipTests
# Output: target/myapp.war
```

### Manual packaging
```bash
jar -cvf myapp.war -C WebContent/ .
```

Expected WAR structure:
```
myapp.war
├── WEB-INF/
│   ├── web.xml
│   └── weblogic.xml       # WebLogic-specific descriptor
├── index.jsp
└── META-INF/
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

## 🚀 Deploying via WLST

```python
connect('weblogic', 'password', 't3://localhost:7001')
deploy(
    appName='myapp',
    path='/u01/deployments/myapp.war',
    targets='myManagedServer',
    stageMode='nostage'
)
```

---

## 🚀 Deploying via `weblogic.Deployer` (CLI)

```bash
java weblogic.Deployer \
  -adminurl t3://localhost:7001 \
  -username weblogic \
  -password password \
  -deploy \
  -name myapp \
  -source /u01/deployments/myapp.war \
  -targets myManagedServer
```

---

## ✅ Validating the Deployment

### Check via browser
```
http://<host>:<port>/myapp
```

### Check via curl
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:7001/myapp
# Expected: 200
```

### Check deployment state via WLST
```python
connect('weblogic', 'password', 't3://localhost:7001')
domainRuntime()
cd('AppRuntimeStateRuntime/AppRuntimeStateRuntime')
state = cmo.getCurrentState('myapp', 'myManagedServer')
print(state)   # Expected: STATE_ACTIVE
```

---

## 🔁 Redeployment / Update

```bash
java weblogic.Deployer \
  -adminurl t3://localhost:7001 \
  -username weblogic \
  -password password \
  -redeploy \
  -name myapp \
  -source /u01/deployments/myapp.war
```

---

## 🛠️ Troubleshooting

| Symptom | Check |
|---|---|
| 404 after deploy | Verify `context-root` in `weblogic.xml` |
| Deploy fails with classloading error | Check shared libraries and classpath |
| App stuck in `STATE_NEW` | Check server logs for deployment errors |
| Session issues | Review `session-descriptor` in `weblogic.xml` |

---

## 📌 Notes

- Always test WAR in a dev/staging domain before deploying to production
- Use `nostage` mode for large WARs to avoid copying files to managed servers
- WebLogic 14c supports Servlet 4.0 and Java EE 8
