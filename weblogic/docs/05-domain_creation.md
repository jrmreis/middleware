# Domain Creation - WebLogic Documentation

## Overview
A domain is a logical administrative unit that separates different applications and their configurations in WebLogic Server.

## Domain Concept
Domains provide isolated environments for different websites/applications, separating:
- Configuration files
- Log files  
- Executable/binary files
- Deployed content
- Staging areas

### Example Scenario
For three websites: `ivr.com`, `phonebanking.com`, `lac.com`

## Domain Possibilities

### Option 1: Single Domain, Single Managed Server
- One Managed Server under one domain
- Deploy all applications (ivr, lac, pb) to one server
- Shared resources and configuration

### Option 2: Single Domain, Multiple Managed Servers  
- Three Managed Servers under one domain
- Deploy ivr to 1st managed server
- Deploy lac to 2nd managed server  
- Deploy pb to 3rd managed server

### Option 3: Multiple Domains
- Separate domains for each application:
  - One domain for ivr application
  - One domain for lac application  
  - One domain for pb application
- Complete isolation between applications

### Option 4: Distributed Architecture
Three domains across multiple servers:
```
Server 1: IVR_DOMAIN → Admin Server (192.168.224.140:7001) → IVR_MS01 (192.168.224.140:8080)
Server 2: IVR_DOMAIN → Admin Server (192.168.224.141:7001) → IVR_MS02 (192.168.224.141:8080)  
Server 3: IVR_DOMAIN → Admin Server (192.168.224.142:7001) → IVR_MS03 (192.168.224.142:8080)
```

## Domain Features

### Configuration Management
- Domains configured via `config.sh` located at `$WLS_HOME/common/bin/config.sh`
- Each domain has dedicated managed servers reporting to one Admin Server
- Creation methods: GUI, Script-based

### Directory Structure
```
/ORACLE_HOME/user_projects/domains/<domain_name>/
├── bin/           # Domain-specific scripts
├── config/        # Configuration files
├── logs/          # Log files  
├── servers/       # Server-specific directories
├── stage/         # Staging area
└── temp/          # Temporary files
```

### Self-Contained Environment
- Independent bin directory
- Separate config directory
- Isolated logs directory
- Functions without WLS_HOME dependency

## Domain Creation Process

### Prerequisites
- WebLogic Server installation completed
- Admin Server must be started first after domain creation
- Only then Admin Console/WLST access is possible

### Multiple Domain Considerations
**Port Conflict Issue**:
- Default Admin Server port: 7001
- Second domain creation will attempt same port
- **Solution**: Change port number (e.g., 7001 → 8001)

### GUI-Based Creation
```bash
cd /opt/Oracle/Middleware/Oracle_Home/wlserver/common/bin/
./config.sh
```

#### Configuration Steps
1. **Domain Location**: `/u01/apps/DEV_PB_Domain`
2. **Admin Credentials**: 
   - Username: weblogic
   - Password: weblogic123
3. **Domain Mode Selection**:

#### Production vs Development Mode

| Feature | Production Mode | Development Mode |
|---------|----------------|------------------|
| boot.properties | Not created by default | Created by default |
| Security | Lock & Edit required | No such feature |
| Changes | Activate Changes required | No such feature |
| Auto Deploy | Disabled | Enabled |
| Environment | Prod, Pre-Prod, Stage | Dev, QA |

#### Advanced Configuration
- **Administration Server**: Configure name and ports
- **Node Manager**: Configure if needed  
- **Managed Servers**: Add during creation or later
- **Clusters**: Configure if needed

### Template-Based Creation
- Use existing templates for standardization
- Custom templates can be created
- Domain Template Builder tool available

## Script-Based Domain Creation

### WLST Script Example
```python
readTemplate('/u01/apps/Oracle/Middleware/Oracle_Home/wlserver/common/templates/wls/wls.jar')
cd('Servers/AdminServer')
cmo.setListenAddress('')
set('ListenPort', 8001)
create('AdminServer','SSL')
cd('SSL/AdminServer')
set('Enabled', 'True')
set('ListenPort', 8002)
cd('/')
cd('Security/base_domain/User/weblogic')
cmo.setPassword('weblogic1')
setOption('ServerStartMode','prod')
setOption('OverwriteDomain', 'true')
writeDomain('/opt/Oracle/Middleware/Oracle_Home/user_projects/domains/PROD_LAC_domain')
closeTemplate()
exit()
```

### Execution
```bash
cd /opt/Oracle/Middleware/Oracle_Home/wlserver/common/bin
./wlst.sh /opt/software/SCRIPTS/domain_new.xml
```

## Post-Creation Tasks

### First Steps
1. **Start Admin Server**:
   ```bash
   cd /u01/apps/DEV_PB_Domain/bin
   nohup ./startWebLogic.sh &
   ```

2. **Access Admin Console**:
   ```
   http://localhost:7001/console
   ```

3. **Create Managed Servers** (if not done during domain creation)

4. **Configure Additional Components**:
   - Node Manager setup
   - Cluster configuration
   - Application deployments

## Best Practices

### Planning
- Plan domain architecture based on application isolation needs
- Consider resource requirements for each domain
- Plan port allocation to avoid conflicts

### Security  
- Use production mode for non-development environments
- Change default passwords
- Implement proper authentication mechanisms

### Naming Conventions
- Use descriptive domain names
- Follow organizational standards
- Include environment indicators (DEV, TEST, PROD)

### Configuration Management
- Document domain configurations
- Use version control for custom templates
- Maintain configuration backups

## Troubleshooting

### Common Issues
- Port conflicts with multiple domains
- Insufficient permissions for domain directory
- Java path and environment variable issues
- Template corruption or incompatibility

### Resolution Steps
- Verify port availability before creation
- Ensure proper directory permissions
- Validate Java installation and PATH variables
- Use official Oracle templates when possible