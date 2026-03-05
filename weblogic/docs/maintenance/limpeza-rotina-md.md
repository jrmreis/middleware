# Limpeza de Rotina — WebLogic 14c Routine Cleanup

Step-by-step procedures for routine log rotation, temp file cleanup, and server health maintenance on WebLogic 14c.

---

## 📋 Prerequisites

- Access to the server with the WebLogic installation
- `$DOMAIN_HOME` variable set
- Scheduled maintenance window (recommended for production)

---

## 🗂️ Directory Reference

```
$DOMAIN_HOME/
├── logs/                          # Domain-level logs
├── servers/
│   └── <server_name>/
│       ├── logs/                  # Server logs
│       └── tmp/                   # Server temp files
└── config/                        # Domain config (do NOT delete)
```

---

## 🧹 Step-by-Step Cleanup

### 1. Stop the Managed Server (if safe to do so)
```bash
cd $DOMAIN_HOME/bin
./stopManagedWebLogic.sh <server_name> t3://localhost:7001
```

### 2. Archive and rotate server logs
```bash
# Create archive directory
mkdir -p /backup/weblogic/logs/$(date +%Y-%m-%d)

# Move old logs
mv $DOMAIN_HOME/servers/<server_name>/logs/*.log* \
   /backup/weblogic/logs/$(date +%Y-%m-%d)/

# Move domain logs
mv $DOMAIN_HOME/logs/*.log* \
   /backup/weblogic/logs/$(date +%Y-%m-%d)/
```

### 3. Delete temp files
```bash
rm -rf $DOMAIN_HOME/servers/<server_name>/tmp/*
rm -rf $DOMAIN_HOME/servers/<server_name>/cache/*
```

### 4. Clear application-level temp/work directories
```bash
rm -rf $DOMAIN_HOME/servers/<server_name>/stage/*
```

> ⚠️ After clearing `stage/`, WebLogic will redeploy apps on next start — expected behavior.

### 5. Compress archived logs older than 7 days
```bash
find /backup/weblogic/logs/ -name "*.log" -mtime +7 -exec gzip {} \;
```

### 6. Delete compressed archives older than 30 days
```bash
find /backup/weblogic/logs/ -name "*.gz" -mtime +30 -delete
```

### 7. Restart the Managed Server
```bash
cd $DOMAIN_HOME/bin
./startManagedWebLogic.sh <server_name> http://localhost:7001
```

---

## ⏰ Automation with Cron

Add to crontab (`crontab -e`) to run weekly on Sundays at 2am:

```bash
0 2 * * 0 /bin/bash /u01/scripts/weblogic-cleanup.sh >> /var/log/wl-cleanup.log 2>&1
```

---

## 🔍 Health Check After Cleanup

```bash
# Confirm server is running
curl -s http://localhost:7001/weblogic/ready

# Check log for errors after restart
tail -100 $DOMAIN_HOME/servers/<server_name>/logs/<server_name>.log | grep -i error
```

---

## 📌 Notes

- Never delete files inside `$DOMAIN_HOME/config/` — this holds your domain configuration
- Always validate free disk space before and after: `df -h`
- Log rotation can also be configured natively in the Admin Console under **Server → Logging**
