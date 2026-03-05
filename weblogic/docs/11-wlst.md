# WLST (WebLogic Scripting Tool) - Documentation

## Overview
WLST (WebLogic Scripting Tool) is a command-line interface for WebLogic Server administration, designed with Jython and providing an alternative to the Admin Console.

## WLST Characteristics
- **Based on**: Jython (Python for Java)
- **Purpose**: Admin Server configuration and control
- **Location**: `/u01/apps/Oracle/Middleware/Oracle_Home/wlserver/common/bin/`

## Access Methods

### Interactive Mode
Students and teacher style - enter CLI console for real-time interaction.

#### Method 1: Direct Script
```bash
cd /u01/apps/Oracle/Middleware/Oracle_Home/wlserver/common/bin/
./wlst.sh
```

#### Method 2: Java Command
```bash
java -cp /u01/apps/Oracle/Middleware/Oracle_Home/wlserver/server/lib/weblogic.jar weblogic.WLST
```

### Non-Interactive Mode
Execute pre-written scripts without user interaction.

```bash
cd <WLS_HOME>/common/bin
./wlst.sh <script_filename>
```

## WLST Modes

### OFFLINE Mode (Default)
- **Connection**: No domain connection
- **Activities**: Public activities only
- **Functions**: 
  - Creating domains
  - Creating domain templates  
  - Starting Admin Server
  - Starting Node Manager

### ONLINE Mode
- **Connection**: Connected to specific domain
- **Access**: Same capabilities as Admin Console
- **Connection Command**:
```python
connect('weblogic','weblogic123','t3://192.168.243.161:7001')
```

## Core WLST Operations

### Getting Help
```python
wls:/offline> help()
wls:/offline> help('all')          # List all commands
wls:/offline> help('browse')       # Browse commands
wls:/offline> help('control')      # Control commands
wls:/offline> help('deployment')   # Deployment commands
```

### Navigation
```python
ls()                              # List current directory contents
cd('Servers/AdminServer')         # Change directory
pwd()                            # Print working directory
```

## Server Management

### Starting Admin Server
```python
wls:/offline> startServer('AdminServer','DEV_PB_Domain','t3://PRD-NODE1:7001','weblogic','weblogic123','/u01/apps/DEV_PB_Domain/',jvmArgs='-XX:MaxPermSize=125m, -Xmx512m, -XX:+UseParallelGC')
```

#### StartServer Parameters
- **adminServerName**: Server name (optional, defaults to 'myserver')
- **domainName**: Domain name (optional, defaults to 'mydomain')  
- **url**: Admin Server URL (optional, defaults to 't3://localhost:7001')
- **username**: Admin username (optional, defaults to 'weblogic')
- **password**: Admin password (optional, defaults to 'weblogic')
- **domainDir**: Domain directory path
- **jvmArgs**: JVM arguments for performance tuning

### Node Manager Operations
```python
# Start Node Manager
startNodeManager(NodeManagerHome='/u01/apps/DEV_PB_Domain/nodemanager',ListenPort='5556',ListenAddress='PRD-NODE1')

# Get help for Node Manager
help('startNodeManager')
```

### Connecting to Admin Server
```python
connect('weblogic','weblogic123','t3://PRD-NODE1:7001')
```

**Result**: Transitions from OFFLINE to ONLINE mode.

## Configuration Management

### Server State Operations
```python
# Check server state
state('Prod_Yahoo_MS1','Server')

# Check cluster state  
state('mycluster','Cluster')
```

### Server Control
```python
# Start managed server
start('Prod_Yahoo_MS1','Server')

# Stop managed server
shutdown('google_ms1','Server')
```

### Configuration Changes
```python
# Enter edit mode
edit()
startEdit()

# Navigate to server configuration
cd('Servers/google_ms2')

# Change configuration
set('ListenPort',9090)

# Save and activate changes
save()
activate()

# Exit edit mode
stopEdit()
```

## Deployment Management

### View Deployments
```python
cd('AppDeployments')
ls()
```

### Undeploy Applications
```python
undeploy('SwiffChartJSPSamples')
```

### Deploy Applications
```python
deploy('SwiffChartJSPSamples','/opt/software/EAR/SwiffChartJSPSamples.ear',targets="Prod_IVR_Cluster01")

# With deployment plan
deploy('SwiffChartJSPSamples','/opt/software/EAR/SwiffChartJSPSamples.ear',targets="Prod_IVR_Cluster01",planPath="/opt/Oracle/Middleware/user_projects/domains/Google_domain/Plan.xml")
```

## Security Operations

### Decrypt Node Manager Password
```python
domain = "/u01/apps/DEV_PB_Domain"
service = weblogic.security.internal.SerializedSystemIni.getEncryptionService(domain)
encryption = weblogic.security.internal.encryption.ClearOrEncryptedService(service)
print encryption.decrypt("{AES}WDhZb5/IP95P4eM8jwYITiZs01kawSeliV59aFog1jE=")
```

## Advanced Scripting

### Non-Interactive Script Example
Create `/tmp/execute.py`:
```python
# Start servers and deploy applications
startServer('AdminServer','DEV_PB_Domain','t3://PRD-NODE1:7001','weblogic','weblogic123','/u01/apps/DEV_PB_Domain/',jvmArgs='-XX:MaxPermSize=125m, -Xmx512m, -XX:+UseParallelGC')
print 'Admin server started'

startNodeManager(NodeManagerHome='/u01/apps/DEV_PB_Domain/nodemanager',ListenPort='5556',ListenAddress='PRD-NODE1')
print 'Node Manager started'

connect('weblogic','weblogic123','t3://PRD-NODE1:7001')
print 'Connected to Admin Server'

# Application management
undeploy('PB')
print 'Undeployment completed'

deploy('PB','/opt/software/ear/PB.war',targets="DEV_PB_Cluster01")
print 'Deployment completed'

# Start cluster
start('DEV_PB_Cluster01','Cluster')
print 'Cluster started'

print 'Job Completed'
```

### Execute Script
```bash
./wlst.sh /tmp/execute.py
```

## Best Practices

### Script Development
- **Comments**: Document script sections thoroughly
- **Error Handling**: Implement try-catch blocks where appropriate
- **Modularity**: Create reusable script components
- **Testing**: Test scripts in development environments

### Security
- **Credentials**: Never hardcode production passwords
- **Scripts**: Secure script files with appropriate permissions
- **Connections**: Use secure connection protocols (t3s)

### Performance
- **Batch Operations**: Group related operations together
- **Connection Management**: Minimize connection overhead
- **Resource Cleanup**: Properly disconnect when finished

## Common WLST Commands Reference

### Navigation and Information
```python
ls()                    # List contents
cd('path')             # Change directory  
pwd()                  # Print working directory
find('name','type')    # Find objects
get('attribute')       # Get attribute value
```

### Server Operations
```python
start('server','Server')        # Start server
shutdown('server','Server')     # Stop server
suspend('server','Server')      # Suspend server  
resume('server','Server')       # Resume server
state('server','Server')        # Check server state
```

### Configuration
```python
edit()                 # Enter edit tree
startEdit()            # Start edit session
save()                 # Save changes
activate()             # Activate changes
stopEdit()             # Stop edit session
cancelEdit()           # Cancel changes
```

### Deployment
```python
deploy('app','path')              # Deploy application
undeploy('app')                   # Undeploy application
redeploy('app')                   # Redeploy application
listApplications()                # List deployed applications
```

## Troubleshooting

### Common Issues
- **Connection Failures**: Verify Admin Server status and network connectivity
- **Authentication Errors**: Check username/password and account status
- **Script Errors**: Review Jython syntax and WebLogic object references
- **Permission Issues**: Verify user privileges for administrative operations

### Debug Techniques
- **Verbose Output**: Add print statements for debugging
- **Try-Catch**: Implement error handling in scripts
- **Log Review**: Check WebLogic logs for detailed error information
- **Interactive Testing**: Test commands interactively before scripting

### Exit Commands
```python
disconnect()           # Disconnect from server
exit()                # Exit WLST (DO NOT use Ctrl+C)
```

WLST provides powerful command-line administration capabilities, essential for automation, scripting, and advanced WebLogic Server management tasks.