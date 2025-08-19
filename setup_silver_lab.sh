#!/bin/bash

# =============================================================================
# SCRIPT DE CONFIGURATION VMs POUR MSI GT73VR - SILVER C2 LAB
# =============================================================================
# Description: Configure automatiquement l'environnement de test Silver C2
# Usage: bash setup_silver_lab.sh
# Compatible: VirtualBox (recommandé)
# =============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Variables de configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_DIR="$HOME/VirtualBox VMs"
ISO_DIR="$HOME/ISO"
LAB_NETWORK="192.168.56"

# Détection des ressources système
detect_system_resources() {
    echo -e "${BLUE}Détection des ressources système...${NC}"
    
    # RAM totale
    TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
    TOTAL_RAM_GB=$((TOTAL_RAM / 1024))
    
    # CPU cores
    CPU_CORES=$(nproc)
    
    # Espace disque disponible
    DISK_SPACE=$(df -h "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    
    echo -e "${GREEN}✅ RAM détectée: ${TOTAL_RAM_GB}GB${NC}"
    echo -e "${GREEN}✅ CPU cores: ${CPU_CORES}${NC}"
    echo -e "${GREEN}✅ Espace disque: ${DISK_SPACE}GB${NC}"
}

# Configuration recommandée selon la RAM
get_vm_config() {
    if [ "$TOTAL_RAM_GB" -ge 32 ]; then
        echo -e "${GREEN}Configuration OPTIMALE détectée (32GB+)${NC}"
        VM_CONFIG="optimal"
        WIN10_COUNT=2
        SERVER_RAM=6144
        CLIENT_RAM=4096
        UBUNTU_RAM=2048
    elif [ "$TOTAL_RAM_GB" -ge 16 ]; then
        echo -e "${YELLOW}Configuration STANDARD détectée (16GB)${NC}"
        VM_CONFIG="standard" 
        WIN10_COUNT=1
        SERVER_RAM=4096
        CLIENT_RAM=4096
        UBUNTU_RAM=0
    else
        echo -e "${RED}❌ RAM insuffisante (minimum 16GB requis)${NC}"
        exit 1
    fi
}

# Vérification VirtualBox
check_virtualbox() {
    echo -e "${BLUE}Vérification de VirtualBox...${NC}"
    
    if ! command -v VBoxManage &> /dev/null; then
        echo -e "${RED}❌ VirtualBox non installé${NC}"
        echo -e "${YELLOW}Installation:${NC}"
        echo "sudo apt update && sudo apt install virtualbox virtualbox-ext-pack -y"
        exit 1
    fi
    
    VB_VERSION=$(VBoxManage --version 2>/dev/null | cut -d'r' -f1)
    echo -e "${GREEN}✅ VirtualBox $VB_VERSION installé${NC}"
}

# Création du réseau host-only
create_host_network() {
    echo -e "${BLUE}Configuration du réseau isolé...${NC}"
    
    # Vérifier si le réseau existe déjà
    if VBoxManage list hostonlyifs | grep -q "vboxnet0"; then
        echo -e "${GREEN}✅ Réseau host-only existe déjà${NC}"
    else
        echo -e "${YELLOW}Création du réseau host-only...${NC}"
        VBoxManage hostonlyif create
        VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
    fi
    
    # Configuration DHCP
    VBoxManage dhcpserver modify --ifname vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0 --lowerip 192.168.56.100 --upperip 192.168.56.200 2>/dev/null || {
        VBoxManage dhcpserver add --ifname vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0 --lowerip 192.168.56.100 --upperip 192.168.56.200
    }
    VBoxManage dhcpserver modify --ifname vboxnet0 --enable
}

# Fonction de création de VM
create_vm() {
    local vm_name="$1"
    local os_type="$2"
    local ram_mb="$3"
    local cpu_count="$4"
    local disk_gb="$5"
    local description="$6"
    
    echo -e "${CYAN}Création de la VM: $vm_name${NC}"
    
    # Supprimer la VM si elle existe
    if VBoxManage list vms | grep -q "\"$vm_name\""; then
        echo -e "${YELLOW}VM existante trouvée, suppression...${NC}"
        VBoxManage controlvm "$vm_name" poweroff 2>/dev/null || true
        sleep 2
        VBoxManage unregistervm "$vm_name" --delete 2>/dev/null || true
    fi
    
    # Création de la VM
    VBoxManage createvm --name "$vm_name" --ostype "$os_type" --register
    VBoxManage modifyvm "$vm_name" --description "$description"
    VBoxManage modifyvm "$vm_name" --memory "$ram_mb" --cpus "$cpu_count"
    VBoxManage modifyvm "$vm_name" --vram 128
    VBoxManage modifyvm "$vm_name" --graphicscontroller vboxsvga
    VBoxManage modifyvm "$vm_name" --accelerate3d on
    VBoxManage modifyvm "$vm_name" --boot1 dvd --boot2 disk --boot3 none --boot4 none
    VBoxManage modifyvm "$vm_name" --acpi on --ioapic on
    VBoxManage modifyvm "$vm_name" --rtcuseutc on
    
    # Réseau
    VBoxManage modifyvm "$vm_name" --nic1 hostonly --hostonlyadapter1 vboxnet0
    
    # Création du disque dur
    local disk_path="$VM_DIR/$vm_name/$vm_name.vdi"
    VBoxManage createmedium disk --filename "$disk_path" --size $((disk_gb * 1024)) --format VDI
    
    # Contrôleurs de stockage
    VBoxManage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAHCI
    VBoxManage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$disk_path"
    
    VBoxManage storagectl "$vm_name" --name "IDE Controller" --add ide
    
    echo -e "${GREEN}✅ VM $vm_name créée avec succès${NC}"
}

# Création des VMs Silver C2 Lab
create_silver_lab_vms() {
    echo -e "${WHITE}=== CRÉATION DES VMs SILVER C2 LAB ===${NC}"
    
    # Windows Server 2019 (Contrôleur de domaine)
    create_vm "Silver-DC" "Windows2019_64" "$SERVER_RAM" 2 60 "Windows Server 2019 - Contrôleur de domaine pour tests Silver C2"
    
    # Windows 10 Client 1
    create_vm "Silver-Win10-1" "Windows10_64" "$CLIENT_RAM" 2 50 "Windows 10 Client 1 - Cible principale Silver C2"
    
    # Windows 10 Client 2 (si configuration optimale)
    if [ "$WIN10_COUNT" -eq 2 ]; then
        create_vm "Silver-Win10-2" "Windows10_64" "$CLIENT_RAM" 2 50 "Windows 10 Client 2 - Cible secondaire Silver C2"
    fi
    
    # Ubuntu Server (si RAM suffisante)
    if [ "$UBUNTU_RAM" -gt 0 ]; then
        create_vm "Silver-Ubuntu" "Ubuntu_64" "$UBUNTU_RAM" 1 20 "Ubuntu Server - Services web pour tests Silver C2"
    fi
}

# Génération de la documentation de lab
generate_lab_documentation() {
    cat > "$SCRIPT_DIR/Silver_Lab_Info.md" << EOF
# Silver C2 Lab - Informations de Configuration

## Configuration Générée

**Date de création**: $(date)
**Configuration système**: ${VM_CONFIG}
**RAM totale**: ${TOTAL_RAM_GB}GB
**CPU cores**: ${CPU_CORES}

## VMs Créées

### Silver-DC (Windows Server 2019)
- **RAM**: ${SERVER_RAM}MB ($(($SERVER_RAM / 1024))GB)
- **CPU**: 2 cores
- **Disque**: 60GB
- **Rôle**: Contrôleur de domaine Active Directory
- **IP recommandée**: 192.168.56.100
- **Domaine**: silverlab.local

### Silver-Win10-1 (Windows 10)
- **RAM**: ${CLIENT_RAM}MB ($(($CLIENT_RAM / 1024))GB)
- **CPU**: 2 cores
- **Disque**: 50GB
- **Rôle**: Cible principale Silver C2
- **IP recommandée**: 192.168.56.101
- **Utilisateur test**: testuser

EOF

if [ "$WIN10_COUNT" -eq 2 ]; then
cat >> "$SCRIPT_DIR/Silver_Lab_Info.md" << EOF
### Silver-Win10-2 (Windows 10)
- **RAM**: ${CLIENT_RAM}MB ($(($CLIENT_RAM / 1024))GB)
- **CPU**: 2 cores
- **Disque**: 50GB
- **Rôle**: Cible secondaire Silver C2
- **IP recommandée**: 192.168.56.102
- **Utilisateur test**: alice

EOF
fi

if [ "$UBUNTU_RAM" -gt 0 ]; then
cat >> "$SCRIPT_DIR/Silver_Lab_Info.md" << EOF
### Silver-Ubuntu (Ubuntu Server)
- **RAM**: ${UBUNTU_RAM}MB ($(($UBUNTU_RAM / 1024))GB)
- **CPU**: 1 core
- **Disque**: 20GB
- **Rôle**: Serveur web/base de données
- **IP recommandée**: 192.168.56.103

EOF
fi

cat >> "$SCRIPT_DIR/Silver_Lab_Info.md" << EOF

## Réseau Lab

- **Réseau**: 192.168.56.0/24
- **Type**: Host-Only (vboxnet0)
- **Gateway**: 192.168.56.1 (Host Kali)
- **DHCP**: 192.168.56.100-200
- **DNS**: 192.168.56.100 (Silver-DC)

## Prochaines Étapes

### 1. Installation des OS
- Téléchargez les ISO Windows 10 et Server 2019
- Placez-les dans le répertoire: $ISO_DIR
- Attachez les ISO aux VMs via VirtualBox

### 2. Configuration initiale
- **Silver-DC**: Configurer en contrôleur de domaine
- **Silver-Win10-x**: Joindre au domaine silverlab.local
- **Silver-Ubuntu**: Installation LAMP stack

### 3. Configuration Silver C2
- Host Kali: IP 192.168.56.1
- Génération payloads: \`generate --mtls 192.168.56.1:443 ...\`
- Tests de connectivité depuis les VMs cibles

## Commandes VirtualBox Utiles

\`\`\`bash
# Lister les VMs
VBoxManage list vms

# Démarrer une VM
VBoxManage startvm "Silver-DC" --type gui

# État des VMs
VBoxManage list runningvms

# Arrêter une VM
VBoxManage controlvm "Silver-DC" poweroff

# Créer un snapshot
VBoxManage snapshot "Silver-DC" take "Initial-Clean-State"

# Restaurer un snapshot
VBoxManage snapshot "Silver-DC" restore "Initial-Clean-State"
\`\`\`

## Tests Silver C2 Recommandés

1. **Tests basiques**: Silver-Win10-1 uniquement
2. **Mouvement latéral**: Silver-Win10-1 → Silver-Win10-2
3. **Escalade domaine**: Clients → Silver-DC
4. **Persistence**: Tests sur tous les clients
5. **Collecte données**: Énumération domaine AD

## Snapshots Recommandés

- **Initial**: Après installation OS
- **Configured**: Après configuration domaine
- **Pre-Test**: Avant chaque série de tests
- **Compromised**: État après compromission pour analyse

---

**⚠️ Rappel**: Utilisez cet environnement uniquement pour des tests autorisés !
EOF

    echo -e "${GREEN}✅ Documentation générée: Silver_Lab_Info.md${NC}"
}

# Script principal
main() {
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║      CONFIGURATEUR SILVER C2 LAB - MSI GT73VR        ║
║                                                       ║
║     Environnement de test automatisé                 ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Vérifications et détection
    detect_system_resources
    get_vm_config
    check_virtualbox
    
    echo -e "\n${WHITE}=== CONFIGURATION SÉLECTIONNÉE ===${NC}"
    echo -e "${CYAN}• RAM totale: ${TOTAL_RAM_GB}GB${NC}"
    echo -e "${CYAN}• Configuration: ${VM_CONFIG}${NC}"
    echo -e "${CYAN}• VMs Windows 10: ${WIN10_COUNT}${NC}"
    echo -e "${CYAN}• RAM Server: ${SERVER_RAM}MB${NC}"
    echo -e "${CYAN}• RAM Clients: ${CLIENT_RAM}MB${NC}"
    if [ "$UBUNTU_RAM" -gt 0 ]; then
        echo -e "${CYAN}• RAM Ubuntu: ${UBUNTU_RAM}MB${NC}"
    fi
    
    echo -e "\n${YELLOW}Continuer avec cette configuration ? [y/N]${NC}"
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Configuration annulée${NC}"
        exit 1
    fi
    
    # Création des répertoires
    mkdir -p "$VM_DIR" "$ISO_DIR"
    
    # Configuration du lab
    create_host_network
    create_silver_lab_vms
    generate_lab_documentation
    
    echo -e "\n${GREEN}🎉 LAB SILVER C2 CRÉÉ AVEC SUCCÈS !${NC}"
    echo -e "\n${WHITE}=== INFORMATIONS IMPORTANTES ===${NC}"
    echo -e "${CYAN}• Documentation complète: Silver_Lab_Info.md${NC}"
    echo -e "${CYAN}• Réseau lab: 192.168.56.0/24${NC}"
    echo -e "${CYAN}• Host Kali IP: 192.168.56.1${NC}"
    
    echo -e "\n${WHITE}=== PROCHAINES ÉTAPES ===${NC}"
    echo -e "${YELLOW}1. Téléchargez les ISO Windows dans: $ISO_DIR${NC}"
    echo -e "${YELLOW}2. Installez les OS sur chaque VM${NC}"
    echo -e "${YELLOW}3. Configurez le domaine Active Directory${NC}"
    echo -e "${YELLOW}4. Lancez vos tests Silver C2 !${NC}"
    
    echo -e "\n${WHITE}=== DÉMARRAGE RAPIDE ===${NC}"
    echo -e "${CYAN}VBoxManage startvm \"Silver-DC\" --type gui${NC}"
    echo -e "${CYAN}VBoxManage startvm \"Silver-Win10-1\" --type gui${NC}"
    
    if [ "$WIN10_COUNT" -eq 2 ]; then
        echo -e "${CYAN}VBoxManage startvm \"Silver-Win10-2\" --type gui${NC}"
    fi
    
    echo -e "\n${GREEN}Bon apprentissage avec Silver C2 ! 🚀${NC}"
}

# Exécution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi