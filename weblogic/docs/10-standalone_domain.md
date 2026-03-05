# Standalone Domain - WebLogic Documentation

## Overview
This document covers the complete process of setting up and managing a standalone WebLogic domain, from checking configuration to deploying applications.

## Domain Architecture
```
Standalone Domain
├── Admin Server (Port 7001/7002)
├── Managed Servers (Configurable ports)
├── Applications (WAR/EAR deployments)
└── Configuration (config.xml)
```

## Configuration Management

### Checking Admin Server Port
```bash
cd /config
less config.xml
```

**Note**: If using default port (7001 & 7002), configuration may not be visible in config.xml.

### Sample Configuration
```xml
<server>
    <name>AdminServer</name>
    <ssl>
        <name>AdminServer</name>
        <enabled>true</enabled>
        <listen-port>7002</listen-port>
    </ssl>
    <listen-port>7001</listen-port>
    <listen-address/>
</server>
```

## Admin Server Management

### Starting Admin Server
```bash
cd /u01/apps/DEV_PB_Domain/bin
nohup ./startWebLogic.sh &
```

### Monitoring Startup
```bash
# Monitor startup process
tail -f nohup.out

# Alternative: Check detailed logs
tail -f /u01/apps/DEV_PB_Domain/servers/AdminServer/logs/AdminServer.log
```

### Startup Confirmation Messages
Look for these key messages:
```
<Notice> <WebLogicServer> <BEA-000331> <Started the WebLogic Server Administration Server "AdminServer" for domain "DEV_IVR" running in development mode.>
<Notice> <WebLogicServer> <BEA-000360> <The server started in RUNNING mode.>
<Notice> <WebLogicServer> <BEA-000365> <Server state changed to RUNNING.>
```

### Process Verification
```bash
ps -ef | grep java
```

**Expected Output**: Java process with WebLogic-specific parameters including:
- Server name (AdminServer)
- Domain path
- WebLogic policy files
- Memory settings

## Accessing Admin Console

### URL Format
```
http://<hostname>:<port>/console/
```

### Examples
```
http://wls-node40:7001/console/
http://localhost:7001/console/
```

### Default Credentials
- **Username**: weblogic
- **Password**: As configured during domain creation

## Application Deployment

### Deployment Process
1. **Access Deployments**: Domain Structure → Deployments
2. **Install Application**: Click "Install" button
3. **Select Source**: Choose application file location
4. **Configure Target**: Select managed servers or clusters
5. **Configure Options**: Set deployment parameters
6. **Activate**: Complete deployment process

### Deployment Sources

#### Local Server File
- Application located on WebLogic server
- Browse server filesystem
- Direct server access

#### Remote Client File
- Upload from client machine
- File transfer during deployment
- Network-based deployment

### Deployment Configuration Options

#### Install Types
- **Install as application**: Standard application deployment
- **Install as library**: Shared library installation

#### Staging Options
- **Use defaults**: Automatic staging configuration
- **Copy application**: Stage mode with file copying
- **Make accessible from location**: No-stage mode

#### Target Selection
- **Managed Servers**: Individual server targeting
- **Clusters**: Cluster-wide deployment
- **All Servers**: Domain-wide deployment

## Application Management

### Browsing Deployed Applications
After successful deployment, access applications via:

```
http://<hostname>:<port>/<application-context>/
```

### Examples
```
http://192.168.224.140:7001/Calendar_1.0/
http://wls-node40:7001/Calendar_1.0/
http://localhost:7001/Calendar_1.0/
```

### Application States
- **Prepared**: Application staged but not active
- **Active**: Application running and accessible
- **Failed**: Deployment or runtime failure

### Application Control
- **Start**: Activate prepared applications
- **Stop**: Temporarily disable applications
- **Restart**: Restart running applications
- **Undeploy**: Remove applications completely

## Admin Server Control

### GUI Shutdown
1. Access Admin Console
2. Navigate to Domain → Summary of Servers
3. Select AdminServer
4. Choose shutdown options
5. Confirm shutdown

### CLI Shutdown
```bash
cd /u01/apps/DEV_PB_Domain/bin/
./stopWebLogic.sh
```

## Deployment Examples

### Sample WAR Deployment
```
Application: Calendar_1.0.war
Target: AdminServer (development)
Staging: Default staging mode
Access URL: http://localhost:7001/Calendar_1.0/
```

### Deployment Verification Steps
1. **Check Deployment Status**: Verify "Active" state
2. **Test Application URL**: Access application in browser  
3. **Review Logs**: Check for deployment errors
4. **Monitor Performance**: Verify application functionality

## Troubleshooting

### Common Issues

#### Port Conflicts
- **Problem**: Admin Server fails to start due to port conflicts
- **Solution**: Check port availability with `telnet localhost 7001`
- **Resolution**: Change port in domain configuration

#### Deployment Failures
- **Problem**: Applications fail to deploy
- **Symptoms**: Deployment remains in "Prepared" state
- **Resolution**: Check application dependencies and configuration

#### Access Issues
- **Problem**: Cannot access Admin Console
- **Causes**: Firewall, network configuration, server not running
- **Resolution**: Verify server status and network connectivity

### Log Locations
- **Admin Server**: `DOMAIN_HOME/servers/AdminServer/logs/AdminServer.log`
- **Domain**: `DOMAIN_HOME/servers/AdminServer/logs/`
- **Deployment**: Admin Console → Deployments → Messages

## Best Practices

### Security
- Change default administrative passwords
- Configure SSL for production environments
- Implement proper authentication mechanisms
- Restrict Admin Console access

### Performance
- Monitor JVM memory usage
- Configure appropriate heap sizes
- Implement connection pooling for databases
- Monitor application performance

### Management
- Regular backup of domain configuration
- Document deployment procedures
- Implement change management processes
- Monitor server and application logs

### Development
- Use development mode for testing
- Test deployments in staging environments
- Implement proper error handling
- Follow application deployment standards

## Configuration Files

### Key Configuration Files
- **config.xml**: Domain configuration
- **boot.properties**: Server startup credentials
- **nodemanager.properties**: Node Manager settings
- **startup.properties**: Server startup parameters

### Backup Recommendations
- Regular backup of DOMAIN_HOME/config/
- Version control for configuration changes
- Document configuration modifications
- Test backup restoration procedures

This standalone domain setup provides a foundation for WebLogic development and testing environments, with options to scale to more complex multi-server configurations as needed.