# Domain Creation in CLI - WebLogic Documentation

## Overview
This document covers creating WebLogic domains using command-line interface and scripting methods.

## Scripting Mode Domain Creation

### Create WLST Script File
**Location**: `/opt/software/SCRIPTS/domain_new.xml`

### Script Content
```python
# Read the base WebLogic template
readTemplate('/u01/apps/Oracle/Middleware/Oracle_Home/wlserver/common/templates/wls/wls.jar')

# Configure Admin Server
cd('Servers/AdminServer')
cmo.setListenAddress('')
set('ListenPort', 8001)

# Configure SSL for Admin Server  
create('AdminServer','SSL')
cd('SSL/AdminServer')
set('Enabled', 'True')
set('ListenPort', 8002)

# Configure Admin User Security
cd('/')
cd('Security/base_domain/User/weblogic')
cmo.setPassword('weblogic1')

# Set Domain Options
setOption('ServerStartMode','prod')
setOption('OverwriteDomain', 'true')

# Write Domain to Filesystem
writeDomain('/opt/Oracle/Middleware/Oracle_Home/user_projects/domains/PROD_LAC_domain')

# Cleanup and Exit
closeTemplate()
exit()
```

### Execute WLST Script
```bash
cd /opt/Oracle/Middleware/Oracle_Home/wlserver/common/bin
./wlst.sh /opt/software/SCRIPTS/domain_new.xml
```

## Script Components Explained

### Template Reading
```python
readTemplate('/path/to/wls.jar')
```
- Loads the base WebLogic Server template
- Provides foundation for domain creation
- Contains default configurations

### Admin Server Configuration
```python
cd('Servers/AdminServer')
cmo.setListenAddress('')  # Listen on all interfaces
set('ListenPort', 8001)   # HTTP port
```

### SSL Configuration
```python
create('AdminServer','SSL')
cd('SSL/AdminServer')
set('Enabled', 'True')
set('ListenPort', 8002)   # HTTPS port
```

### Security Configuration
```python
cd('Security/base_domain/User/weblogic')
cmo.setPassword('weblogic1')  # Set admin password
```

### Domain Options
```python
setOption('ServerStartMode','prod')        # Production mode
setOption('OverwriteDomain', 'true')       # Overwrite if exists
```

### Domain Creation
```python
writeDomain('/target/domain/path')
closeTemplate()
exit()
```

## Advanced WLST Script Example

### Enhanced Domain Script
```python
# Load template
readTemplate('/u01/apps/Oracle/Middleware/Oracle_Home/wlserver/common/templates/wls/wls.jar')

# Configure domain name
cd('/')
cmo.setName('ADVANCED_DOMAIN')

# Configure Admin Server
cd('Servers/AdminServer')
set('Name', 'AdminServer')
set('ListenAddress', 'localhost')
set('ListenPort', 7001)

# Configure SSL
create('AdminServer','SSL')
cd('SSL/AdminServer')
set('Enabled', 'True')
set('ListenPort', 7002)
set('HostnameVerifier', 'None')
set('TwoWaySSLEnabled', 'False')

# Create Managed Server
cd('/')
create('ManagedServer1', 'Server')
cd('Servers/ManagedServer1')
set('ListenAddress', 'localhost')
set('ListenPort', 8001)

# Configure Machine
cd('/')
create('Machine1', 'Machine')
cd('Machines/Machine1')
set('Name', 'Machine1')

# Create Node Manager
create('Machine1', 'NodeManager')
cd('NodeManager/Machine1')
set('ListenAddress', 'localhost')
set('ListenPort', 5556)
set('NMType', 'SSL')

# Assign server to machine
cd('/')
assign('Server', 'ManagedServer1', 'Machine', 'Machine1')

# Configure security
cd('Security/base_domain/User/weblogic')
cmo.setPassword('weblogic123')

# Set options
setOption('ServerStartMode', 'dev')
setOption('OverwriteDomain', 'true')

# Write domain
writeDomain('/u01/apps/Oracle/Middleware/Oracle_Home/user_projects/domains/ADVANCED_DOMAIN')

# Cleanup
closeTemplate()
exit()
```

## Execution Methods

### Method 1: Direct WLST Execution
```bash
cd /opt/Oracle/Middleware/Oracle_Home/wlserver/common/bin
./wlst.sh /path/to/script.py
```

### Method 2: Java Command
```bash
java -cp /path/to/weblogic.jar weblogic.WLST /path/to/script.py
```

## Verification Steps

### Check Domain Creation
```bash
ls -la /u01/apps/Oracle/Middleware/Oracle_Home/user_projects/domains/
```

### Verify Domain Structure
```bash
ls -la /u01/apps/Oracle/Middleware/Oracle_Home/user_projects/domains/DOMAIN_NAME/
```

Expected directories:
- `bin/` - Scripts
- `config/` - Configuration files
- `console-ext/` - Console extensions
- `lib/` - Libraries
- `security/` - Security files
- `servers/` - Server directories

### Start Admin Server
```bash
cd /u01/apps/Oracle/Middleware/Oracle_Home/user_projects/domains/DOMAIN_NAME/bin
./startWebLogic.sh
```

## Template Customization

### Custom Template Creation
```python
# Read existing domain
readDomain('/existing/domain/path')

# Make modifications
cd('Servers/AdminServer')
set('ListenPort', 9001)

# Write as template
writeTemplate('/path/to/custom_template.jar')
closeTemplate()
```

### Using Custom Templates
```python
readTemplate('/path/to/custom_template.jar')
# Configure as needed
writeDomain('/new/domain/path')
closeTemplate()
```

## Error Handling

### Common Script Issues
1. **Path Problems**: Verify all paths exist and are accessible
2. **Permission Issues**: Ensure write permissions to target directory
3. **Port Conflicts**: Check port availability before assignment
4. **Template Issues**: Verify template file integrity

### Debugging Scripts
```python
# Add debugging output
print 'Starting domain creation...'
print 'Current location: ' + pwd()
print 'Available servers: ' + ls('/Servers')
```

## Best Practices

### Script Organization
- Use comments to document script sections
- Implement error handling where possible
- Version control your domain creation scripts
- Test scripts in development environments first

### Security Considerations
- Never hardcode production passwords in scripts
- Use secure methods for password handling
- Implement proper file permissions on scripts

### Maintenance
- Keep scripts updated with WebLogic version changes
- Document script parameters and usage
- Create reusable script templates

## Automation Examples

### Batch Domain Creation
```bash
#!/bin/bash
DOMAINS=("DOMAIN1" "DOMAIN2" "DOMAIN3")
BASE_PORT=7000

for i in "${!DOMAINS[@]}"; do
    DOMAIN_NAME=${DOMAINS[$i]}
    PORT=$((BASE_PORT + i * 10))
    
    # Generate script dynamically
    sed "s/DOMAIN_NAME/$DOMAIN_NAME/g; s/PORT_NUMBER/$PORT/g" template_script.py > temp_script.py
    
    # Execute
    ./wlst.sh temp_script.py
    
    # Cleanup
    rm temp_script.py
done
```

This approach enables automated, scripted domain creation for consistent WebLogic environments.