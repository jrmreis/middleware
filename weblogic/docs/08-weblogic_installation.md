# WebLogic Installation - Documentation

## Java Installation (Prerequisite)

### Major Java Providers

| Provider | Usage |
|----------|-------|
| **Sun JDK** | WebLogic 12c, 14c & Tomcat |
| **IBM JDK** | WebSphere |
| **JRockit JDK** | WebLogic 8x, 9x, 10x, 11x (Oracle) |
| **Open JDK** | RedHat JBOSS |

### Java Installation Process

#### 1. Download and Extract
```bash
cd /opt/software/
tar -zxvf jdk-8u202-linux-x64.tar.gz
```

#### 2. Install Java
```bash
mv /opt/software/jdk1.8.0_202 /u01/apps/java/
```

#### 3. Verify Installation
```bash
/u01/apps/java/bin/java -version
```

**Expected Output**:
```
java version "1.8.0_202"
Java(TM) SE Runtime Environment (build 1.8.0_202-b08)
Java HotSpot(TM) 64-Bit Server VM (build 25.202-b08, mixed mode)
```

#### 4. Set Environment Variables
```bash
# Temporary setting
export PATH=/u01/apps/java/bin/:$PATH

# Permanent setting - Add to /etc/bashrc
vi /etc/bashrc
```

**Add to /etc/bashrc**:
```bash
export PATH=/u01/apps/java/bin/:$PATH
export JAVA_HOME=/u01/apps/java/
```

#### 5. Uninstallation (if needed)
```bash
rm -rf /u01/apps/java/
```

## WebLogic Server Installation

### System Requirements

| Component | Requirement |
|-----------|-------------|
| **Platform** | Supported OS, JDK, and database configuration |
| **Processor** | 1-GHz CPU minimum |
| **Hard Disk** | 3.9 GB for complete installation |
| **Memory** | 1 GB RAM minimum, 2 GB recommended |
| **Display** | 8-bit color depth (256 colors) for GUI mode |
| **JDK** | Appropriate version required |

### Pre-Installation Requirements

#### System Resources
- **RAM**: 1GB minimum (2GB for virtual machines)
- **CPU**: Dual Core 2.0 GHz+
- **GPU**: Not required
- **OS**: 64-bit or 32-bit (download accordingly)

#### Software Formats
- **Windows**: .exe, .zip, .msi
- **Unix/Linux**: .rpm, .bin, .tar.gz, .tar.bz, .sh, .deb
- **Java**: .jar

### Installation Methods

## GUI Installation

### Prerequisites
- X Windows or VNC server running on Linux
- XServer for Windows (for tunneling)

### Directory Structure (Post 12c)
```
/u01/apps/Oracle/Middleware/Oracle_Home/
├── Oracle_Home/     # Main installation directory
└── wlserver/        # WebLogic Server specific files
```

### GUI Installation Steps

#### 1. Start Installation
```bash
cd /opt/software/
/u01/apps/java/bin/java -jar fmw_14.1.1.0.0_wls_lite_generic.jar
```

#### 2. Installation Location
**Oracle Home**: `/u01/apps/Oracle/Middleware/Oracle_Home/`

#### 3. Installation Type
- **Complete**: Full installation with all components
- **Custom**: Select specific components

#### 4. Prerequisite Checks
- System requirements validation
- Available disk space verification
- Java version compatibility

#### 5. Installation Progress
- Extract and install files
- Configure components
- Register with inventory

#### 6. Installation Summary
- Review installed components
- Note installation location
- Installation completion confirmation

## Silent Installation

### 1. Create Inventory Location
```bash
mkdir -p /u01/apps/Oracle/oraInventory/
vi /u01/apps/Oracle/oraInventory/oraInst.loc
```

**oraInst.loc Content**:
```
inventory_loc=/u01/apps/Oracle/oraInventory/
inst_group=weblogic
```

### 2. Create Response File
Create `/opt/software/scripts/fmw_14.1.1.0.0_wls_lite_generic.txt` with installation parameters.

### 3. Execute Silent Installation
```bash
/u01/apps/java/bin/java -jar fmw_14.1.1.0.0_wls_lite_generic.jar \
  -silent \
  -responseFile /opt/software/scripts/fmw_14.1.1.0.0_wls_lite_generic.txt \
  -invPtrLoc /u01/apps/Oracle/oraInventory/oraInst.loc
```

## Post-Installation Configuration

### Network Configuration

#### Check IP Address
```bash
ifconfig
```

#### Update /etc/hosts (as root)
```bash
vi /etc/hosts
```

**Add entry**:
```
192.168.224.140 wls-node40
```

### Verification Steps

#### 1. Check Directory Structure
```bash
ls -la /u01/apps/Oracle/Middleware/Oracle_Home/
```

**Expected directories**:
- `wlserver/`
- `oracle_common/`
- `inventory/`
- `oui/`

#### 2. Verify Installation Registry
```bash
cat /u01/apps/Oracle/oraInventory/ContentsXML/inventory.xml
```

#### 3. Test WebLogic Components
```bash
cd /u01/apps/Oracle/Middleware/Oracle_Home/wlserver/common/bin
./wlst.sh
```

## Environment Variables

### Required Variables
```bash
# WebLogic Installation Paths
export MW_HOME=/u01/apps/Oracle/Middleware/
export ORACLE_HOME=/u01/apps/Oracle/Middleware/Oracle_Home/
export WLS_HOME=/u01/apps/Oracle/Middleware/Oracle_Home/wlserver/

# Java Configuration  
export JAVA_HOME=/u01/apps/java/
export PATH=/u01/apps/java/bin/:$PATH

# Domain Path (set after domain creation)
export DOMAIN_HOME=/u01/apps/<domain_name>/
```

### Permanent Environment Setup
Add to `/etc/bashrc` or user profile:
```bash
vi ~/.bashrc
# or
vi /etc/bashrc
```

## Uninstallation

### Complete Removal Process

#### 1. Stop All Services
```bash
# Stop all WebLogic domains
# Stop Node Managers
# Stop any running processes
```

#### 2. Remove WebLogic Installation
```bash
rm -rf /u01/apps/Oracle/Middleware/
```

#### 3. Remove Oracle Inventory
```bash
rm -rf /u01/apps/Oracle/oraInventory/
```

#### 4. Clean Environment Variables
Remove WebLogic-related exports from:
- `/etc/bashrc`
- `~/.bashrc`
- `~/.profile`

## Troubleshooting

### Common Installation Issues

#### Permission Problems
```bash
# Ensure proper ownership
chown -R weblogic:weblogic /u01/apps/Oracle/
chmod -R 755 /u01/apps/Oracle/
```

#### Java Path Issues
```bash
# Verify Java installation
which java
java -version
echo $JAVA_HOME
```

#### Disk Space Issues
```bash
# Check available space
df -h /u01/apps/
```

#### Network Issues
```bash
# Verify hostname resolution
hostname
ping $(hostname)
```

### Installation Logs
**Location**: `/tmp/OraInstall<timestamp>/`
- Review logs for error details
- Check for dependency issues
- Verify system requirements

## Best Practices

### Planning
- Plan directory structure before installation
- Ensure adequate disk space (minimum 5GB free)
- Verify system requirements thoroughly
- Plan for multiple environments

### Security
- Use dedicated user account for WebLogic
- Set appropriate file permissions
- Secure installation directories
- Change default passwords

### Performance
- Allocate sufficient memory
- Configure appropriate JVM settings
- Plan for concurrent installations
- Monitor system resources during installation

### Maintenance
- Document installation parameters
- Keep installation media accessible
- Plan for patches and updates
- Implement backup strategies for installations