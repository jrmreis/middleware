# Managed Servers - WebLogic Documentation

## Overview
Managed Server is a JVM Process that processes Java-based applications deployed over it (WAR or EAR files).

## Key Characteristics
- **Memory Allocation**: 256 MB to 512 MB typically
- **Dedicated Port Numbers**: Each managed server has dedicated ports for browsing executed code
- **Thread Management**: Handles requests as threads
- **RAM Consideration**: Assign appropriate RAM based on application complexity

## Naming Convention
**Format**: `{ENV}_{APP}_ms{NUMBER}`

**Example**: `PRD_yahoo_ms1`
- `PRD` = Production environment
- `yahoo` = Application name  
- `ms` = Managed Server
- `1` = First server in series

## Configuration Requirements
1. **Port Numbers**: Must check availability before assigning
   ```bash
   telnet localhost 7001
   ```
2. **Memory**: Default memory parameters apply initially
3. **Node Manager**: Required for starting from Admin Console

## Managed Server States
Servers progress through specific stages:

### Normal Startup Flow
```
Shutdown → Starting → Standby → Started → Admin → Resuming → Running
```

### Shutdown Flow  
```
Running → Admin → Standby → Stopping → Stopped
```

### Administration Mode
```
Starting → Standby → Started → Admin
```

## Administration Mode Details
- Starts all deployed applications
- Initializes security SSL and subsystems
- **Does NOT establish port numbers**
- Clients cannot browse applications
- Use "Resume" button to transition to Running mode

## Starting Managed Servers

### From Admin Console
**Prerequisites**:
1. Machine is configured
2. Machine is mapped to the Managed Server
3. Node Manager is running

### From Command Line (MSI Mode)
```bash
nohup ./startManagedWebLogic.sh prod_IVR_server01 http://localhost:7001 &
```

**Note**: Requires `boot.properties` file:
```bash
vi /u01/apps/DEV_PB_Domain/servers/<JVM>/security/boot.properties
```

## MSI Mode (Managed Server Independent Mode)
- Allows starting managed servers even when Admin Server is down
- Enabled by default
- Can be disabled through managed server configuration
- Running servers continue unaffected if Admin Server goes down

### Starting in CLI (MSI Mode)
```bash
./startManagedWebLogic.sh Prod_IVR_MS01 http://localhost:7001
```

### Stopping Managed Server
```bash
./stopManagedWebLogic.sh Prod_IVR_MS01 t3://localhost:7001 weblogic weblogic1
```

**Note**: Admin server must be running when stopping managed servers.

## Key Points
- Each managed server operates independently when Admin Server is unavailable
- MSI mode ensures high availability
- Proper naming conventions are essential for management
- Port conflicts must be avoided during configuration