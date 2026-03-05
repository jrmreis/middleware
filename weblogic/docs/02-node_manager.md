# Node Manager - WebLogic Documentation

## Overview
Node Manager is a JVM Process designed to manage physical machines (nodes) in a WebLogic environment.

## Key Characteristics
- Available when creating each domain
- Can be configured for all domains or domain-specific
- Registered with domain during creation (configurable)

## Uses of Node Manager

### Primary Functions
1. **Admin Console Integration**: Required for starting Managed Servers from Admin Console
2. **Automatic Recovery**: Restarts managed server processes if they crash or die
3. **Enhanced Logging**: Creates additional `.out` log files with detailed managed server information

### Important Notes
- **NOT required** for command line managed server startup
- Provides fault tolerance and automatic recovery
- Essential for centralized management

## Types of Node Managers

### Java-Based Node Manager (Recommended)
- **SSL** (Recommended)
- **PLAIN**

### Script-Based Node Manager (NOT RECOMMENDED)
- **SSH**
- **RSH**

## Control Architecture

### Admin Server Startup
```bash
CLI Mode → DOMAIN_HOME/bin/startWebLogic.sh
```
*Note: Node Manager not required*

### Node Manager Startup  
```bash
CLI Mode → DOMAIN_HOME/bin/startNodeManager.sh
```
*Note: Admin Server not required*

### Managed Server from Admin Console
```
Admin Console → start MS1 → Node Manager → startup of MS1
```

**Prerequisites**:
1. Machine is configured
2. Machine is mapped to MS1
3. Node Manager is running

### Stopping Managed Server from Admin Console

**Three-step process**:
1. **Step 1**: Admin Console → stop MS1 → Direct stop of MS1
2. **Step 2** (if Step 1 fails): Admin Console → stop MS1 → Node Manager → stop of MS1  
3. **Step 3** (if Step 2 fails): Admin Console → stop MS1 → O/S → Kill the MS1 process

## Directory Structure

### Control Home Path
```
/Domain_HOME/bin/
```

**Scripts**:
- `startNodeManager.sh` - Start Node Manager
- `stopNodeManager.sh` - Stop Node Manager

### Configuration Home Path
```
/Domain_HOME/nodemanager/
```

## Configuration Files

### nodemanager.properties
- Contains port number and directory structure
- Main configuration file for Node Manager

### nodemanager.domains  
- Contains information about all domains in the WebLogic Application Server
- Maps domain names to their locations

### nodemanager.log
- Logs all Node Manager activity
- Essential for troubleshooting

## Starting Node Manager

### Command Line Startup
```bash
cd /u01/apps/DEV_PB_Domain/bin/
nohup ./startNodeManager.sh &
tail -f nohup.out
```

### Verification
Look for this confirmation line:
```
<Dec 29, 2015 12:33:29 PM IST> <INFO> <Secure socket listener started on port 5556, host wls-node40/192.168.224.140>
```

**Log Locations**:
- `nohup.out`
- `DOMAIN_HOME/nodemanager/nodemanager.log`

## Admin Console Configuration

### Setting up Node Manager
1. Go to Admin Console
2. Expand Environment
3. Configure Machine settings
4. Add Node Manager to Managed Servers

### Machine Configuration Steps
1. Create and configure machines
2. Set Node Manager properties:
   - **Type**: SSL
   - **Listen Address**: Server IP/hostname
   - **Listen Port**: 5556 (default)

### Adding Managed Servers to Node Manager
1. Navigate to managed server configuration
2. Select the appropriate machine
3. Configure Node Manager settings

## Best Practices
- Use SSL-based Java Node Manager for security
- Ensure Node Manager is running before starting managed servers from Admin Console  
- Monitor Node Manager logs for troubleshooting
- Configure proper machine mappings for managed servers
- Use dedicated ports to avoid conflicts

## Troubleshooting
- Check Node Manager logs for startup issues
- Verify port availability (default 5556)
- Ensure proper machine configuration in Admin Console
- Confirm managed server to machine mappings