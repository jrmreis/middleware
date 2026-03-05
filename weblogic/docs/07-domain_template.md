# Domain Template - WebLogic Documentation

## Overview
Domain templates provide a foundation for creating standardized WebLogic domains with predefined configurations and components.

## Domain Template Builder

### Accessing Template Builder
```bash
cd /u01/apps/Oracle/Middleware/Oracle_Home/wlserver/common/bin
./config_builder.sh
```

## Template Types

### 1. Create Domain Template
- Build new templates from scratch
- Define custom configurations
- Include specific components and settings

### 2. Create Extension Template  
- Extend existing domain templates
- Add additional functionality
- Enhance base configurations

## Template Sources

### Use Domain as a Source
- Create template from existing domain
- Capture current domain configuration
- **Source Location**: Browse to existing domain directory
- Example: `/Middleware/Oracle_Home/user_projects/domains/PROD_LAC_domain`

### Use Template as a Source
- Base new template on existing template
- **Template Location**: `/oracle/Middleware/Oracle_Home/user_projects/templates/template.jar`
- Allows for template inheritance and extension

## Template Builder Process

### Step 1: Template Type Selection
Choose between:
- **Create Domain Template**: New template creation
- **Create Extension Template**: Extend existing template

### Step 2: Source Selection  
Choose data source:
- **Use Domain as a Source**: From existing domain
- **Use Template as a Source**: From template file

### Step 3: Template Configuration
- Define template metadata
- Select components to include
- Configure template-specific settings

### Step 4: Template Information
- **Name**: Template identifier
- **Description**: Template purpose and contents
- **Version**: Template version information
- **Author**: Template creator information

### Step 5: Domain Content Selection
Choose what to include:
- Applications and libraries
- Security configurations  
- Server configurations
- Cluster definitions
- Data sources
- JMS configurations

### Step 6: Scripts and Files
- Startup/shutdown scripts
- Custom libraries
- Configuration files
- Documentation

### Step 7: Template Summary
- Review selected components
- Verify configuration settings
- Confirm template details

### Step 8: End of Configuration
- Specify output location
- Generate template file
- Complete template creation

## Template Usage

### Creating Domains from Templates

#### GUI Method
1. Launch Configuration Wizard
2. Select "Create a new domain"
3. Choose custom template from list
4. Follow domain creation process

#### WLST Method
```python
# Read custom template
readTemplate('/path/to/custom_template.jar')

# Configure domain-specific settings
cd('Servers/AdminServer')
set('ListenPort', 7001)

# Write domain
writeDomain('/target/domain/path')
closeTemplate()
```

## Template Components

### Configuration Elements
- **Server Definitions**: Admin and Managed servers
- **Machine Definitions**: Physical/virtual machine mappings  
- **Cluster Configurations**: Load balancing and failover
- **Security Realms**: Authentication and authorization
- **Data Sources**: Database connection pools
- **JMS Resources**: Messaging configurations

### Application Components
- **Deployed Applications**: WAR/EAR files
- **Shared Libraries**: Common components
- **Custom Classes**: Extended functionality

### Scripts and Resources
- **Startup Scripts**: Domain initialization
- **Custom Scripts**: Administrative automation
- **Configuration Files**: External configurations
- **Documentation**: Template usage guides

## Template Management

### Template Storage
**Default Location**: 
```
/Oracle_Home/user_projects/templates/
```

### Template Naming Convention
```
<organization>_<purpose>_<version>.jar
```
Example: `company_web_app_v1.0.jar`

### Template Versioning
- Include version information in template metadata
- Maintain backward compatibility
- Document changes between versions

## Advanced Template Features

### Variable Substitution
Templates can include placeholders for dynamic values:
- Domain names
- Port numbers  
- Server names
- File paths

### Conditional Components
- Include/exclude components based on conditions
- Environment-specific configurations
- Optional feature sets

### Template Inheritance
- Base templates with common configurations
- Specialized templates extending base templates
- Layered configuration approach

## Best Practices

### Template Design
- **Modular Approach**: Create focused, reusable templates
- **Documentation**: Include comprehensive usage instructions
- **Testing**: Validate templates in test environments
- **Versioning**: Maintain proper version control

### Template Organization
- **Categorization**: Group templates by purpose/environment
- **Naming Standards**: Use consistent naming conventions
- **Storage**: Centralized template repository
- **Access Control**: Manage template access permissions

### Maintenance
- **Regular Updates**: Keep templates current with WebLogic versions
- **Security**: Update security configurations regularly
- **Performance**: Optimize template configurations
- **Cleanup**: Remove obsolete templates

## Template Creation Example

### Custom Web Application Template
```bash
# 1. Start with existing web domain
# 2. Launch config_builder.sh
# 3. Select "Create Domain Template"
# 4. Choose "Use Domain as a Source"
# 5. Select web application domain
# 6. Include components:
#    - Web application deployments
#    - Data source configurations
#    - Security realm settings
#    - Cluster configuration
# 7. Name: "WebApp_Template_v1.0"
# 8. Generate template
```

### Using the Template
```python
# WLST script to use custom template
readTemplate('/templates/WebApp_Template_v1.0.jar')

# Customize for specific environment
cd('Servers/AdminServer')
set('ListenPort', 8001)

cd('/')
cd('JDBCSystemResources/MyDataSource/JDBCResource/MyDataSource/JDBCDriverParams/MyDataSource')
set('Url', 'jdbc:oracle:thin:@prod-db:1521:ORCL')

# Create production domain
writeDomain('/domains/PROD_WebApp')
closeTemplate()
```

## Troubleshooting

### Common Issues
- **Missing Dependencies**: Ensure all required components are included
- **Path Problems**: Verify template file locations and permissions
- **Version Conflicts**: Check WebLogic version compatibility
- **Configuration Errors**: Validate template configurations

### Resolution Steps
- Review template creation logs
- Verify source domain functionality
- Test template in isolated environment
- Check WebLogic compatibility matrices

Templates provide a powerful mechanism for standardizing and automating WebLogic domain creation across different environments.