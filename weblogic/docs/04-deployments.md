# Deployments - WebLogic Documentation

## Overview
Deployment is the process of installing Java applications (WAR/EAR files) to WebLogic managed servers or clusters for customer access.

## Deployment Sources

### Local Deployment
- Content located on the same server as Admin Console

### Remote Deployment  
- Content located on client desktop accessing Admin Console

## Deployment Targets
- **Managed Servers**: Individual server instances
- **Clusters**: Groups of managed servers
- **Requirement**: Targets should be stopped during deployment (though hot deployment is possible for complex applications)

## Staging Modes

### Stage Mode (Default)
- Content copied to target managed server directories
- **Location**: `Domain_Home/servers/<managed_server_name>/stage/<deployed_file_location>/`
- **Automatic**: Content automatically staged during deployment

### No Stage Mode  
- Content accessed from original deployment location
- **Risk**: If source files are deleted, application becomes unavailable
- **Use Case**: Temporary or development deployments
- **Option**: "Make this deployment available from this location"

### External Stage Mode
- Similar to Stage Mode but requires manual copying
- Cannot be enabled during deployment
- Must be configured at managed server level
- **Manual Process**: Administrator must copy files manually

## Deployment States

Applications progress through these states:

1. **DISTRIBUTED** → Initial deployment completion
2. **NEW** → After few seconds  
3. **PREPARED** → Application preparation phase
4. **ACTIVE** → After starting the deployed application
5. **SHUTDOWN/STOPPED** → When application is stopped

## Deployment Operations

### Three Main Operations

#### Install
- Deploy new applications
- Fresh installation of WAR/EAR files

#### Update
- Update existing deployments
- Modify files within existing applications

#### Delete  
- Remove applications from targets
- Complete uninstallation

## Deployable File Types

### Standard Archives
- **.war** → Web Archive
- **.ear** → Enterprise Archive  
- **.jar** → Java Archive (can be deployed as library)
- **.sar** → Web Service Archive

### Complex Deployments
Some EAR files contain multiple components:
```
.ear
├── .war
├── .jar  
├── .jar
└── .war
```
**Requirement**: Deploy as both library and application

## Deployment Process

### Through Admin Console

#### 1. Access Deployments
- Navigate to Domain Structure → Deployments
- Click "Install" button

#### 2. Select Source
**Options**:
- **Admin Server's drive**: Upload from server filesystem  
- **Remote System File**: Upload from client machine

#### 3. Choose Deployment Method
- **Install as application**: Standard deployment
- **Install as library**: For shared components

#### 4. Configure Staging
- **Use defaults defined by deployment's targets**: Stage mode
- **Copy application onto target**: Stage mode with manual location
- **Make deployment accessible from location**: No Stage mode

#### 5. Select Targets
- Choose managed servers or clusters
- Configure security settings

#### 6. Configure Advanced Options
- Set startup mode (Running/Administration)
- Configure deployment order
- Set health settings

### Example Deployment
```
Domain → PB Dev → pb.war
Target → Managed Server or Cluster
```

## Deployment States Management

### Starting Applications
- Applications must be started after deployment
- Transition from PREPARED to ACTIVE state

### Stopping Applications  
- Use stop/start options for maintenance
- Applications can be stopped without undeployment

## Staging Directory Configuration

### Changing Default Staging Location
Can modify staging directory for Stage or External Stage modes:
- Navigate to managed server configuration
- Modify staging directory settings
- Apply changes

### Stage Mode Selection
Available options in managed server configuration:
- **stage** (default)
- **nostage**  
- **external_stage**

## Best Practices

### Planning
- Stop target servers during complex deployments
- Test deployments in development environments first
- Plan staging mode based on deployment frequency

### Security
- Use appropriate security roles
- Restrict deployment permissions
- Monitor deployment activities

### Performance
- Consider staging mode impact on disk space
- Plan for high availability during deployments
- Use clusters for zero-downtime deployments

### Troubleshooting
- Monitor deployment logs
- Verify target server states
- Check staging directory permissions
- Validate application dependencies

## Common Deployment Scenarios

### Development Environment
- Use No Stage mode for rapid development cycles
- Hot deployment for testing changes

### Production Environment  
- Use Stage mode for consistency
- Plan maintenance windows for deployments
- Implement proper backup and rollback procedures