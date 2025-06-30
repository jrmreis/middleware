### Como Funciona:

#### Script 1: `use-virtualbox`
- **Descarrega** módulos KVM da memória
- **Libera** as extensões de virtualização para o VirtualBox
- Você pode então usar VirtualBox normalmente

#### Script 2: `use-kvm`
- **Fecha** qualquer processo do VirtualBox
- **Carrega** módulos KVM
- **Libera** as extensões para KVM/QEMU

### Instalação Completa:

```bash
# 1. Criar o script para VirtualBox
cat << 'EOF' | sudo tee /usr/local/bin/use-virtualbox
#!/bin/bash
echo "=== Alternando para VirtualBox ==="

# Fechar processos KVM/libvirt se estiverem rodando
sudo systemctl stop libvirtd 2>/dev/null
sudo pkill -f "qemu" 2>/dev/null

# Descarregar módulos KVM
echo "Descarregando módulos KVM..."
sudo modprobe -r kvm_intel 2>/dev/null
sudo modprobe -r kvm_amd 2>/dev/null  
sudo modprobe -r kvm 2>/dev/null

# Verificar se KVM foi removido
if ! lsmod | grep -q kvm; then
    echo "✅ KVM desabilitado com sucesso"
    echo "✅ VirtualBox pronto para uso"
    echo ""
    echo "Para iniciar VirtualBox: virtualbox"
else
    echo "❌ Erro: KVM ainda está carregado"
    echo "Módulos KVM ativos:"
    lsmod | grep kvm
fi
EOF

# 2. Criar o script para KVM
cat << 'EOF' | sudo tee /usr/local/bin/use-kvm
#!/bin/bash
echo "=== Alternando para KVM ==="

# Fechar VirtualBox se estiver rodando
echo "Fechando VirtualBox..."
sudo pkill -f "VirtualBox" 2>/dev/null
sudo pkill -f "VBoxHeadless" 2>/dev/null
sudo pkill -f "VBoxManage" 2>/dev/null

# Aguardar um momento
sleep 2

# Carregar módulos KVM
echo "Carregando módulos KVM..."
sudo modprobe kvm
sudo modprobe kvm_intel  # Para Intel
# sudo modprobe kvm_amd   # Descomente se for AMD

# Iniciar serviços libvirt
sudo systemctl start libvirtd

# Verificar se KVM foi carregado
if lsmod | grep -q kvm; then
    echo "✅ KVM habilitado com sucesso"
    echo "✅ Virt-manager pronto para uso"
    echo ""
    echo "Para iniciar interface gráfica: virt-manager"
    echo "Para linha de comando: virsh"
else
    echo "❌ Erro: KVM não foi carregado"
fi
EOF

# 3. Tornar os scripts executáveis
sudo chmod +x /usr/local/bin/use-virtualbox
sudo chmod +x /usr/local/bin/use-kvm

# 4. Instalar KVM (se não estiver instalado)
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

# 5. Adicionar usuário aos grupos necessários
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

echo "✅ Scripts instalados com sucesso!"
```

### Como Usar:

#### Para usar VirtualBox:
```bash
# 1. Alternar para VirtualBox
use-virtualbox

# 2. Aguardar confirmação de sucesso

# 3. Abrir VirtualBox
virtualbox

# 4. Usar normalmente suas VMs
```

#### Para usar KVM:
```bash
# 1. Alternar para KVM
use-kvm

# 2. Aguardar confirmação de sucesso

# 3. Abrir virt-manager (interface gráfica)
virt-manager

# OU usar linha de comando
virsh list --all
```

### Scripts Auxiliares Extras:

```bash
# Script para verificar status atual
cat << 'EOF' | sudo tee /usr/local/bin/vm-status
#!/bin/bash
echo "=== Status de Virtualização ==="
echo ""

# Verificar KVM
if lsmod | grep -q kvm; then
    echo "🟢 KVM: Ativo"
    lsmod | grep kvm
else
    echo "🔴 KVM: Inativo"
fi

echo ""

# Verificar VirtualBox
if pgrep -f "VirtualBox" > /dev/null; then
    echo "🟢 VirtualBox: Rodando"
    pgrep -f "VirtualBox"
else
    echo "🔴 VirtualBox: Parado"
fi

echo ""

# Verificar libvirt
if systemctl is-active --quiet libvirtd; then
    echo "🟢 libvirtd: Ativo"
else
    echo "🔴 libvirtd: Inativo"
fi
EOF

sudo chmod +x /usr/local/bin/vm-status
```

### Uso do script de status:
```bash
vm-status
```

### Vantagens da Opção C:
- ✅ **Flexibilidade total** - use qualquer hypervisor
- ✅ **Não perde configurações** de nenhum dos dois
- ✅ **Rápida alternância** (poucos segundos)
- ✅ **Controle total** sobre qual está ativo

### Desvantagens:
- ❌ **Não simultâneo** - apenas um por vez
- ❌ **Requer comando manual** para alternar
- ❌ **Mais complexo** que escolher apenas um

### Workflows Típicos:

**Para desenvolvimento/testes rápidos:**
```bash
use-virtualbox
virtualbox
# Trabalhar com VMs Windows, etc.
```

**Para servidores/produção:**
```bash
use-kvm  
virt-manager
# Configurar VMs Linux para servidores
```

Quer que eu instale os scripts para você testar?
