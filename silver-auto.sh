#!/bin/bash
# =============================================================================
# SILVER C2 - SCRIPT MAÎTRE D'AUTOMATISATION  
# =============================================================================
# Description: Script principal pour automatiser toutes les opérations Silver C2
# Usage: bash silver-auto.sh
# =============================================================================

SCRIPT_DIR="/project/workspace"
cd "$SCRIPT_DIR"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Variables globales
KALI_IP=""
SILVER_SERVER_PID=""

# Fonction d'affichage du menu
show_menu() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════╗
║                                                      ║
║           SILVER C2 - AUTOMATISATION MAÎTRE         ║
║                                                      ║
║              🚀 Tous vos outils en 1               ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${WHITE}📦 INSTALLATION & CONFIGURATION${NC}"
    echo "  1. 📥 Installation complète Silver C2"
    echo "  2. 🖥️  Configuration laboratoire VMs"
    echo ""
    echo -e "${WHITE}🚀 UTILISATION SILVER C2${NC}"
    echo "  3. ⚡ Démarrage serveur + client"
    echo "  4. 💾 Génération automatique payloads"
    echo "  5. 📖 Guide interactif pas à pas"
    echo ""
    echo -e "${WHITE}🔧 AUTOMATISATION COMPLÈTE${NC}"
    echo "  6. 🎯 Installation + Configuration + Démarrage"
    echo "  7. 🏃 Démarrage rapide (si déjà installé)"
    echo ""
    echo -e "${WHITE}🛠️ UTILITAIRES${NC}"
    echo "  8. 📊 État du système"
    echo "  9. 🧹 Nettoyage et arrêt"
    echo "  10. ❓ Aide et documentation"
    echo ""
    echo -e "${RED}  0. ❌ Quitter${NC}"
    echo ""
    echo -n -e "${YELLOW}Choisissez une option (0-10): ${NC}"
}

# Détection IP automatique
detect_ip() {
    KALI_IP=$(ip route get 1.1.1.1 | awk '{print $7}' | head -1 2>/dev/null)
    if [[ -z "$KALI_IP" ]]; then
        KALI_IP=$(hostname -I | awk '{print $1}')
    fi
    if [[ -z "$KALI_IP" ]]; then
        KALI_IP="192.168.1.100"
    fi
}

# Vérification des prérequis
check_prerequisites() {
    echo -e "${BLUE}Vérification des prérequis...${NC}"
    
    # Vérifier les scripts
    local scripts=("install_sliver_kali.sh" "guide_interactif.sh" "generate_payloads.sh" "setup_silver_lab.sh")
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            chmod +x "$script"
            echo -e "${GREEN}✅ $script trouvé${NC}"
        else
            echo -e "${RED}❌ $script manquant${NC}"
        fi
    done
    
    detect_ip
    echo -e "${GREEN}✅ IP détectée: $KALI_IP${NC}"
}

# Installation complète
install_silver() {
    echo -e "${GREEN}🔧 Installation de Silver C2...${NC}"
    
    if [[ -f "install_sliver_kali.sh" ]]; then
        echo -e "${BLUE}Lancement de l'installation automatique...${NC}"
        sudo bash install_sliver_kali.sh
        
        if command -v sliver-server &> /dev/null; then
            echo -e "${GREEN}✅ Silver C2 installé avec succès !${NC}"
        else
            echo -e "${RED}❌ Échec de l'installation${NC}"
        fi
    else
        echo -e "${RED}❌ Script d'installation non trouvé${NC}"
    fi
}

# Démarrage de Silver C2
start_silver() {
    echo -e "${GREEN}🚀 Démarrage de Silver C2...${NC}"
    
    # Vérifier si le serveur tourne déjà
    if pgrep -f "sliver-server" > /dev/null; then
        echo -e "${YELLOW}⚠️ Silver serveur déjà en cours${NC}"
        SILVER_SERVER_PID=$(pgrep -f "sliver-server")
    else
        echo -e "${BLUE}Démarrage du serveur Silver C2...${NC}"
        
        # Démarrer le serveur en arrière-plan
        sudo sliver-server --daemon &
        SILVER_SERVER_PID=$!
        
        # Sauvegarder le PID
        echo $SILVER_SERVER_PID > ~/.silver-server.pid
        
        echo -e "${GREEN}✅ Serveur démarré (PID: $SILVER_SERVER_PID)${NC}"
        
        # Attendre que le serveur soit prêt
        echo -e "${YELLOW}Attente du démarrage du serveur...${NC}"
        sleep 5
    fi
    
    # Démarrer le client dans un nouveau terminal
    echo -e "${BLUE}Ouverture du client Silver C2...${NC}"
    
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal --title="Silver C2 Client" -- bash -c "
            echo -e '${GREEN}Connexion au serveur Silver C2...${NC}'
            echo 'IP du serveur: $KALI_IP'
            echo 'Tapez \"help\" pour l\aide'
            echo ''
            sleep 2
            sliver-client || (echo 'Erreur de connexion au client' && bash)
        "
    elif command -v xterm &> /dev/null; then
        xterm -title "Silver C2 Client" -e "
            echo 'Connexion Silver C2 Client...'
            sleep 2
            sliver-client || bash
        " &
    else
        echo -e "${YELLOW}⚠️ Ouvrez un nouveau terminal et tapez: sliver-client${NC}"
    fi
    
    echo -e "${GREEN}✅ Silver C2 démarré !${NC}"
}

# Génération de payloads
generate_payloads() {
    echo -e "${GREEN}💾 Génération automatique de payloads...${NC}"
    
    if [[ -f "generate_payloads.sh" ]]; then
        echo -e "${BLUE}IP utilisée: $KALI_IP${NC}"
        echo -n -e "${YELLOW}Utiliser cette IP ? [Y/n]: ${NC}"
        read -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo -n -e "${YELLOW}Entrez votre IP Kali: ${NC}"
            read CUSTOM_IP
            KALI_IP=$CUSTOM_IP
        fi
        
        echo -e "${BLUE}Génération avec IP: $KALI_IP${NC}"
        bash generate_payloads.sh "$KALI_IP"
    else
        echo -e "${RED}❌ Script de génération non trouvé${NC}"
    fi
}

# Configuration du laboratoire
setup_lab() {
    echo -e "${GREEN}🖥️ Configuration du laboratoire VMs...${NC}"
    
    if [[ -f "setup_silver_lab.sh" ]]; then
        bash setup_silver_lab.sh
    else
        echo -e "${RED}❌ Script de configuration lab non trouvé${NC}"
    fi
}

# Guide interactif
interactive_guide() {
    echo -e "${GREEN}📖 Lancement du guide interactif...${NC}"
    
    if [[ -f "guide_interactif.sh" ]]; then
        bash guide_interactif.sh
    else
        echo -e "${RED}❌ Guide interactif non trouvé${NC}"
    fi
}

# Automatisation complète
auto_complete() {
    echo -e "${GREEN}🎯 Automatisation complète - Installation + Configuration + Démarrage${NC}"
    echo -e "${BLUE}Cette opération va:${NC}"
    echo "  1. Installer Silver C2"
    echo "  2. Configurer le laboratoire VMs"
    echo "  3. Générer des payloads"
    echo "  4. Démarrer Silver C2"
    echo ""
    echo -n -e "${YELLOW}Continuer ? [y/N]: ${NC}"
    read -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}🚀 Début de l'automatisation complète...${NC}"
        
        install_silver
        sleep 3
        
        setup_lab
        sleep 3
        
        generate_payloads
        sleep 3
        
        start_silver
        sleep 3
        
        echo -e "${GREEN}✅ Automatisation complète terminée !${NC}"
        echo -e "${BLUE}Vous pouvez maintenant utiliser Silver C2${NC}"
    fi
}

# Démarrage rapide
quick_start() {
    echo -e "${GREEN}🏃 Démarrage rapide...${NC}"
    
    # Vérifier si Silver est installé
    if ! command -v sliver-server &> /dev/null; then
        echo -e "${RED}❌ Silver C2 non installé. Utilisez l'option 1 d'abord.${NC}"
        return 1
    fi
    
    start_silver
    
    echo -e "${YELLOW}Générer des payloads ? [y/N]: ${NC}"
    read -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        generate_payloads
    fi
}

# État du système
system_status() {
    echo -e "${GREEN}📊 État du système Silver C2${NC}"
    echo ""
    
    # Vérifier l'installation
    echo -e "${WHITE}🔧 Installation:${NC}"
    if command -v sliver-server &> /dev/null; then
        echo -e "${GREEN}  ✅ sliver-server installé${NC}"
    else
        echo -e "${RED}  ❌ sliver-server non installé${NC}"
    fi
    
    if command -v sliver-client &> /dev/null; then
        echo -e "${GREEN}  ✅ sliver-client installé${NC}"
    else
        echo -e "${RED}  ❌ sliver-client non installé${NC}"
    fi
    
    # Vérifier les processus
    echo -e "\n${WHITE}🔄 Processus actifs:${NC}"
    if pgrep -f "sliver-server" > /dev/null; then
        local server_pid=$(pgrep -f "sliver-server")
        echo -e "${GREEN}  ✅ sliver-server en cours (PID: $server_pid)${NC}"
    else
        echo -e "${YELLOW}  ⚠️ sliver-server arrêté${NC}"
    fi
    
    if pgrep -f "sliver-client" > /dev/null; then
        local client_pid=$(pgrep -f "sliver-client")
        echo -e "${GREEN}  ✅ sliver-client en cours (PID: $client_pid)${NC}"
    else
        echo -e "${YELLOW}  ⚠️ sliver-client arrêté${NC}"
    fi
    
    # Informations système
    echo -e "\n${WHITE}💻 Système:${NC}"
    echo -e "${CYAN}  IP: $KALI_IP${NC}"
    echo -e "${CYAN}  RAM: $(free -h | awk 'NR==2{print $3 "/" $2}')${NC}"
    echo -e "${CYAN}  Disque: $(df -h . | awk 'NR==2{print $3 "/" $2 " (" $5 ")"}')${NC}"
    
    # Vérifier les payloads
    echo -e "\n${WHITE}💾 Payloads générés:${NC}"
    if [[ -d "silver_payloads_"* ]] 2>/dev/null; then
        local payload_dir=$(ls -d silver_payloads_* | head -1)
        local payload_count=$(ls "$payload_dir"/*.exe 2>/dev/null | wc -l)
        echo -e "${GREEN}  ✅ $payload_count payloads dans $payload_dir${NC}"
    else
        echo -e "${YELLOW}  ⚠️ Aucun payload généré${NC}"
    fi
}

# Nettoyage
cleanup() {
    echo -e "${GREEN}🧹 Nettoyage du système...${NC}"
    
    # Arrêter les processus Silver
    echo -e "${BLUE}Arrêt des processus Silver C2...${NC}"
    
    if [[ -f ~/.silver-server.pid ]]; then
        local pid=$(cat ~/.silver-server.pid)
        sudo kill $pid 2>/dev/null && echo -e "${GREEN}✅ Serveur arrêté (PID: $pid)${NC}"
        rm ~/.silver-server.pid
    fi
    
    # Forcer l'arrêt
    sudo pkill -f sliver-server 2>/dev/null && echo -e "${GREEN}✅ Tous les serveurs Silver arrêtés${NC}"
    sudo pkill -f sliver-client 2>/dev/null && echo -e "${GREEN}✅ Tous les clients Silver arrêtés${NC}"
    
    # Nettoyer les fichiers temporaires
    echo -e "${BLUE}Nettoyage des fichiers temporaires...${NC}"
    rm -f /tmp/silver_* 2>/dev/null
    rm -f ~/.silver-*.pid 2>/dev/null
    
    echo -e "${GREEN}✅ Nettoyage terminé${NC}"
}

# Aide et documentation
show_help() {
    echo -e "${GREEN}❓ Aide Silver C2 Automatisation${NC}"
    echo ""
    echo -e "${WHITE}📚 Documentation disponible:${NC}"
    
    local docs=(
        "Guide_Silver_C2_Kali_Linux.md:Guide complet Silver C2"
        "Etapes_Detaillees_Silver_C2.md:Étapes détaillées pas à pas"
        "Guide_Payloads_Silver_C2.md:Guide des payloads"
        "Recommandations_VMs_MSI_GT73VR.md:Configuration VMs"
        "Guide_Execution_Automatique.md:Ce guide d'automatisation"
    )
    
    for doc in "${docs[@]}"; do
        local file="${doc%%:*}"
        local desc="${doc##*:}"
        
        if [[ -f "$file" ]]; then
            echo -e "${GREEN}  ✅ $file${NC} - $desc"
        else
            echo -e "${RED}  ❌ $file${NC} - $desc (manquant)"
        fi
    done
    
    echo ""
    echo -e "${WHITE}🔧 Scripts disponibles:${NC}"
    local scripts=(
        "install_sliver_kali.sh:Installation automatique"
        "guide_interactif.sh:Guide pas à pas"
        "generate_payloads.sh:Génération payloads"
        "setup_silver_lab.sh:Configuration VMs"
    )
    
    for script in "${scripts[@]}"; do
        local file="${script%%:*}"
        local desc="${script##*:}"
        
        if [[ -f "$file" ]]; then
            echo -e "${GREEN}  ✅ $file${NC} - $desc"
        else
            echo -e "${RED}  ❌ $file${NC} - $desc (manquant)"
        fi
    done
    
    echo ""
    echo -e "${WHITE}🎯 Utilisation recommandée:${NC}"
    echo "  1. Commencer par l'option 1 (Installation)"
    echo "  2. Puis option 2 (Configuration lab) si besoin de VMs"
    echo "  3. Option 7 pour usage quotidien (Démarrage rapide)"
    echo ""
    echo -e "${WHITE}❓ Support:${NC}"
    echo "  • Consultez la documentation (.md files)"
    echo "  • Vérifiez l'état avec l'option 8"
    echo "  • Utilisez l'option 9 pour nettoyer en cas de problème"
}

# Fonction principale
main() {
    # Vérification initiale
    check_prerequisites
    
    while true; do
        show_menu
        read choice
        echo
        
        case $choice in
            1) install_silver ;;
            2) setup_lab ;;
            3) start_silver ;;
            4) generate_payloads ;;
            5) interactive_guide ;;
            6) auto_complete ;;
            7) quick_start ;;
            8) system_status ;;
            9) cleanup ;;
            10) show_help ;;
            0) 
                echo -e "${GREEN}Au revoir ! 👋${NC}"
                exit 0 
                ;;
            *) 
                echo -e "${RED}❌ Option invalide. Choisissez entre 0-10.${NC}"
                ;;
        esac
        
        echo -e "\n${YELLOW}Appuyez sur ENTRÉE pour revenir au menu...${NC}"
        read
    done
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi