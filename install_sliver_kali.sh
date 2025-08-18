#!/bin/bash

# =============================================================================
# SCRIPT D'INSTALLATION AUTOMATIQUE - SLIVER C2 SUR KALI LINUX
# =============================================================================
# Description: Installation et configuration automatique de Sliver C2
# Auteur: Guide Silver C2
# Usage: sudo bash install_sliver_kali.sh
# =============================================================================

set -e  # Arrêt en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions d'affichage
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_banner() {
    echo -e "${BLUE}"
    echo "=============================================="
    echo "     INSTALLATION SLIVER C2 - KALI LINUX    "
    echo "=============================================="
    echo -e "${NC}"
}

# Vérification des privilèges root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Ce script doit être exécuté avec des privilèges sudo/root"
        print_status "Usage: sudo bash $0"
        exit 1
    fi
}

# Mise à jour du système
update_system() {
    print_status "Mise à jour du système..."
    apt update -y
    apt upgrade -y
    print_success "Système mis à jour"
}

# Installation des dépendances
install_dependencies() {
    print_status "Installation des dépendances..."
    
    # Dépendances de base
    apt install -y \
        curl \
        wget \
        git \
        build-essential \
        mingw-w64 \
        python3 \
        python3-pip \
        nmap \
        netcat \
        ca-certificates \
        gnupg \
        lsb-release
    
    # Installation de Go si pas déjà installé
    if ! command -v go &> /dev/null; then
        print_status "Installation de Go..."
        wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
        rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
        export PATH=$PATH:/usr/local/go/bin
        rm go1.21.0.linux-amd64.tar.gz
        print_success "Go installé"
    else
        print_success "Go déjà installé"
    fi
}

# Installation de Sliver via APT
install_sliver_apt() {
    print_status "Installation de Sliver via APT..."
    
    if apt list --installed 2>/dev/null | grep -q sliver; then
        print_warning "Sliver est déjà installé via APT"
        return 0
    fi
    
    apt install -y sliver
    
    if command -v sliver-server &> /dev/null && command -v sliver-client &> /dev/null; then
        print_success "Sliver installé avec succès via APT"
        return 0
    else
        print_error "Échec de l'installation via APT"
        return 1
    fi
}

# Installation de Sliver depuis les sources (fallback)
install_sliver_source() {
    print_status "Installation de Sliver depuis les sources..."
    
    # Clone du repository
    cd /opt
    if [ -d "sliver" ]; then
        print_status "Repository Sliver déjà présent, mise à jour..."
        cd sliver
        git pull
    else
        git clone https://github.com/BishopFox/sliver.git
        cd sliver
    fi
    
    # Compilation
    print_status "Compilation en cours... (cela peut prendre plusieurs minutes)"
    make clean
    make
    
    # Installation des binaires
    cp sliver-server /usr/local/bin/
    cp sliver-client /usr/local/bin/
    chmod +x /usr/local/bin/sliver-server
    chmod +x /usr/local/bin/sliver-client
    
    # Création des liens symboliques
    ln -sf /usr/local/bin/sliver-server /usr/bin/sliver-server
    ln -sf /usr/local/bin/sliver-client /usr/bin/sliver-client
    
    print_success "Sliver compilé et installé depuis les sources"
}

# Vérification de l'installation
verify_installation() {
    print_status "Vérification de l'installation..."
    
    if command -v sliver-server &> /dev/null; then
        VERSION=$(sliver-server version 2>/dev/null | head -1 || echo "Version inconnue")
        print_success "sliver-server installé : $VERSION"
    else
        print_error "sliver-server non trouvé"
        return 1
    fi
    
    if command -v sliver-client &> /dev/null; then
        print_success "sliver-client installé"
    else
        print_error "sliver-client non trouvé"
        return 1
    fi
}

# Configuration post-installation
post_install_config() {
    print_status "Configuration post-installation..."
    
    # Création du répertoire de travail
    mkdir -p /home/$SUDO_USER/sliver-workspace
    chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/sliver-workspace
    
    # Création d'un script de démarrage rapide
    cat > /home/$SUDO_USER/sliver-workspace/start_sliver.sh << 'EOF'
#!/bin/bash
echo "Démarrage de Sliver C2..."
echo "Serveur: sudo sliver-server"
echo "Client: sliver-client (dans un autre terminal)"
echo ""
echo "Répertoire de travail: $PWD"
echo "Guide disponible: Guide_Silver_C2_Kali_Linux.md"
echo "Référence rapide: commandes_sliver_reference.sh"
EOF
    
    chmod +x /home/$SUDO_USER/sliver-workspace/start_sliver.sh
    chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/sliver-workspace/start_sliver.sh
    
    print_success "Configuration terminée"
}

# Installation d'outils complémentaires
install_additional_tools() {
    print_status "Installation d'outils complémentaires..."
    
    # Metasploit (si pas déjà installé)
    if ! command -v msfconsole &> /dev/null; then
        print_status "Installation de Metasploit..."
        curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
        chmod 755 msfinstall
        ./msfinstall
        rm msfinstall
    fi
    
    # Empire (optionnel)
    if [ ! -d "/opt/Empire" ]; then
        print_status "Installation d'Empire C2 (optionnel)..."
        cd /opt
        git clone https://github.com/EmpireProject/Empire.git
        cd Empire
        ./setup/install.sh
    fi
    
    print_success "Outils complémentaires installés"
}

# Création de la documentation locale
create_documentation() {
    print_status "Création de la documentation locale..."
    
    # Copie des guides vers le répertoire de travail
    if [ -f "/project/workspace/Guide_Silver_C2_Kali_Linux.md" ]; then
        cp /project/workspace/Guide_Silver_C2_Kali_Linux.md /home/$SUDO_USER/sliver-workspace/
        chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/sliver-workspace/Guide_Silver_C2_Kali_Linux.md
    fi
    
    if [ -f "/project/workspace/commandes_sliver_reference.sh" ]; then
        cp /project/workspace/commandes_sliver_reference.sh /home/$SUDO_USER/sliver-workspace/
        chmod +x /home/$SUDO_USER/sliver-workspace/commandes_sliver_reference.sh
        chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/sliver-workspace/commandes_sliver_reference.sh
    fi
    
    print_success "Documentation copiée dans /home/$SUDO_USER/sliver-workspace/"
}

# Affichage des informations finales
show_final_info() {
    print_success "Installation terminée avec succès!"
    echo ""
    echo -e "${BLUE}=== INFORMATIONS IMPORTANTES ===${NC}"
    echo "• Répertoire de travail: /home/$SUDO_USER/sliver-workspace/"
    echo "• Guide complet: Guide_Silver_C2_Kali_Linux.md"
    echo "• Référence rapide: commandes_sliver_reference.sh"
    echo ""
    echo -e "${BLUE}=== DÉMARRAGE RAPIDE ===${NC}"
    echo "1. Démarrer le serveur: sudo sliver-server"
    echo "2. Dans un autre terminal: sliver-client"
    echo "3. Générer un implant: generate --mtls <IP>:443 --os windows --format exe --save /tmp/implant.exe"
    echo ""
    echo -e "${YELLOW}⚠️ RAPPEL DE SÉCURITÉ ⚠️${NC}"
    echo "Utilisez uniquement dans un environnement de test autorisé"
    echo "Respectez les lois locales et internationales"
    echo ""
}

# Fonction principale
main() {
    print_banner
    
    check_root
    update_system
    install_dependencies
    
    # Tentative d'installation via APT d'abord
    if ! install_sliver_apt; then
        print_warning "Installation via APT échouée, tentative depuis les sources..."
        install_sliver_source
    fi
    
    verify_installation
    post_install_config
    create_documentation
    
    # Installation d'outils complémentaires (optionnel)
    read -p "Voulez-vous installer des outils complémentaires (Metasploit, Empire)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_additional_tools
    fi
    
    show_final_info
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi