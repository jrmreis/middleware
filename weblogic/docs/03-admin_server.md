# Admin Server - WebLogic Documentation

## Overview
Admin Server is a JVM Process that serves as the central management component for WebLogic domains.

## Key Characteristics
- **Created automatically** with every domain
- **First JVM process** to start in any domain
- **Manages entire domain/domains**
- Uses unique port numbers (HTTP & HTTPS)

## Management Methods

### Admin Console
- Web-based interface
- Accessible via browser
- Full administrative capabilities

### WebLogic Scripting Tool (WLST)
- Command-line interface
- Scriptable administration
- Programmatic domain management

## Administrative Functions

### Configuration Changes
- Creating Managed Servers
- Configuring port numbers
- SSL configuration
- Creating clusters
- General domain configuration

### Control Changes
- Stopping/Starting/Restarting servers
- Admin mode transitions
- Service management

## Configuration Location

### Config File Path
```bash
/opt/Oracle/Middleware/Oracle_Home/user_projects/domains/Dev_Phonebanking/config/config.xml
```

### Sample Configuration
```xml
<server>
    <name>AdminServer</name>
    <ssl>
        <name>AdminServer</name>
        <enabled>true</enabled>
        <listen-port>8002</listen-port>
    </ssl>
    <listen-port>8001</listen-port>
    <listen-address/>
</server>
```

**Note**: If no listen-port is defined, default port 7001 is used.

## Starting Admin Server

### Command Line Startup
```bash
cd /opt/Oracle/Middleware/Oracle_Home/user_projects/domains/Dev_Phonebanking/bin
nohup ./startWebLogic.sh &
```

### Monitoring Startup
```bash
tail -f nohup.out
# OR
tail -f Domain_Home/servers/AdminServer/logs/AdminServer.log
```

### Startup Confirmation
Look for these messages:
```
<Notice> <WebLogicServer> <BEA-000331> <Started the WebLogic Server Administration Server "AdminServer" for domain "DEV_IVR" running in development mode.>
<Notice> <WebLogicServer> <BEA-000360> <The server started in RUNNING mode.>
<Notice> <WebLogicServer> <BEA-000365> <Server state changed to RUNNING.>
```

### Process Verification
```bash
ps -ef | grep java
```

## Stopping Admin Server

### Command Line Shutdown
```bash
./stopWebLogic.sh
```

## Accessing Admin Console

### URL Format
```
<Protocol>://<ServerName/HostName/DomainName>:<Port>/<Context Root>
```

### Example URLs
```
http://wls-node40:8001/console
http://wls-node40:7001/console
http://localhost:7001/console
```

### Default Credentials
- **Username**: weblogic
- **Password**: As configured during domain creation

## Domain Modes

### Development Mode
- **boot.properties**: Created by default
- **No security**: For starting/stopping JVM processes
- **Auto Deploy**: Enabled
- **Environment**: Dev, QA

### Production Mode  
- **boot.properties**: Must be created manually
- **Lock & Edit**: Required for changes
- **Activate Changes**: Required after modifications
- **Auto Deploy**: Disabled
- **Environment**: Prod, Pre-Prod, Stage

## Important Notes

### Multi-Domain Considerations
- Each domain requires unique Admin Server port
- Default port conflicts occur with multiple domains
- Change port from 7001 to avoid conflicts (e.g., 8001)

### Security Considerations
- Production mode provides enhanced security
- Development mode is for testing only
- Always change default passwords in production

### High Availability
- Admin Server is single point of management
- Consider backup and recovery procedures
- Managed servers can run independently with MSI mode

## Best Practices
- Use production mode for non-development environments
- Implement proper backup strategies for domain configurations
- Monitor Admin Server logs regularly
- Use unique ports for multiple domains
- Secure access to Admin Console in production environments