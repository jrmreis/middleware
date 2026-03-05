# wsadmin — WebLogic Administration Scripts and Commands

Reference guide for administering Oracle WebLogic Server 14c via command line and admin console.

---

## 📋 Prerequisites

- WebLogic Server 14c (14.1.1) installed
- `$ORACLE_HOME` and `$WL_HOME` environment variables set
- Admin Server running

---

## 🔧 Environment Variables

```bash
export ORACLE_HOME=/u01/oracle
export WL_HOME=$ORACLE_HOME/wlserver
export DOMAIN_HOME=$ORACLE_HOME/user_projects/domains/base_domain
export PATH=$WL_HOME/server/bin:$PATH
```

---

## 🚀 Starting and Stopping Servers

### Start Admin Server
```bash
cd $DOMAIN_HOME/bin
./startWebLogic.sh
```

### Start Managed Server
```bash
cd $DOMAIN_HOME/bin
./startManagedWebLogic.sh <server_name> http://<admin_host>:7001
```

### Stop Admin Server
```bash
cd $DOMAIN_HOME/bin
./stopWebLogic.sh
```

### Stop Managed Server
```bash
cd $DOMAIN_HOME/bin
./stopManagedWebLogic.sh <server_name> t3://<admin_host>:7001
```

---

## 🖥️ Admin Console

Access the WebLogic Admin Console at:

```
http://<host>:7001/console
```

Default credentials:
| Field | Value |
|---|---|
| Username | `weblogic` |
| Password | *(defined at domain creation)* |

---

## 📜 WLST (WebLogic Scripting Tool)

### Connect to running server
```python
connect('weblogic', 'password', 't3://localhost:7001')
```

### List all servers
```python
domainRuntime()
cd('ServerRuntimes')
ls()
```

### Check server state
```python
serverRuntime()
state = cmo.getState()
print(state)
```

### Graceful shutdown via WLST
```python
connect('weblogic', 'password', 't3://localhost:7001')
shutdown('myServer', 'Server', graceful=true, timeOut=60)
```

---

## 🔍 Useful Log Paths

```bash
# Admin Server log
$DOMAIN_HOME/servers/AdminServer/logs/AdminServer.log

# Managed Server log
$DOMAIN_HOME/servers/<server_name>/logs/<server_name>.log

# Domain log
$DOMAIN_HOME/logs/<domain_name>.log
```

---

## ⚙️ JVM Tuning (setDomainEnv)

Edit `$DOMAIN_HOME/bin/setDomainEnv.sh`:

```bash
USER_MEM_ARGS="-Xms512m -Xmx1024m -XX:MaxMetaspaceSize=256m"
export USER_MEM_ARGS
```

---

## 📌 Notes

- Always back up `$DOMAIN_HOME/config/config.xml` before making changes
- Use WLST offline for domain creation scripting
- WebLogic 14c requires JDK 8 or JDK 11
