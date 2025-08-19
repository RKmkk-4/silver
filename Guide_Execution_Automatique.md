# 🚀 Guide d'Exécution Automatique - Scripts Silver C2

## 📋 SCRIPTS DISPONIBLES

Voici les scripts que vous pouvez exécuter automatiquement :

1. **`install_sliver_kali.sh`** - Installation complète Silver C2
2. **`guide_interactif.sh`** - Guide pas à pas interactif  
3. **`generate_payloads.sh`** - Génération automatique de payloads
4. **`setup_silver_lab.sh`** - Configuration automatique des VMs

---

## ⚡ MÉTHODES D'EXÉCUTION AUTOMATIQUE

### **🔧 MÉTHODE 1 : Exécution Simple**

```bash
# Aller dans le répertoire
cd /project/workspace

# Rendre les scripts exécutables (une seule fois)
chmod +x *.sh

# Exécuter le script de votre choix
./install_sliver_kali.sh
./guide_interactif.sh
./generate_payloads.sh
./setup_silver_lab.sh
```

### **🔧 MÉTHODE 2 : Avec Bash**

```bash
# Si problème de permissions
bash install_sliver_kali.sh
bash guide_interactif.sh  
bash generate_payloads.sh
bash setup_silver_lab.sh
```

### **🔧 MÉTHODE 3 : Depuis n'importe où**

```bash
# Chemin absolu
bash /project/workspace/install_sliver_kali.sh
bash /project/workspace/guide_interactif.sh
```

---

## 🎯 SÉQUENCES D'AUTOMATISATION COMPLÈTE

### **📦 INSTALLATION COMPLÈTE AUTOMATIQUE**

Script tout-en-un qui fait tout automatiquement :

```bash
#!/bin/bash
# Script principal d'automatisation

cd /project/workspace

echo "=== INSTALLATION SILVER C2 ==="
sudo bash install_sliver_kali.sh

echo "=== CONFIGURATION LAB VMS ==="
bash setup_silver_lab.sh

echo "=== GÉNÉRATION PAYLOADS ==="
bash generate_payloads.sh 192.168.1.100

echo "=== LANCEMENT GUIDE INTERACTIF ==="
bash guide_interactif.sh
```

### **⚡ DÉMARRAGE RAPIDE SILVER C2**

Script pour démarrer Silver C2 automatiquement :

```bash
#!/bin/bash
# Démarrage automatique Silver C2

# Terminal 1 : Serveur en arrière-plan
sudo sliver-server --daemon &
SERVER_PID=$!

# Attendre que le serveur démarre
sleep 5

# Terminal 2 : Client
gnome-terminal -- bash -c "
echo 'Connexion au serveur Silver C2...'
sleep 2
sliver-client
"

echo "Serveur PID: $SERVER_PID"
echo "Pour arrêter: kill $SERVER_PID"
```

---

## 📱 CRÉATION D'UN SCRIPT MAÎTRE

### **🎮 Script "Silver-Auto" Complet**

```bash
#!/bin/bash
# =============================================================================
# SILVER C2 - SCRIPT MAÎTRE D'AUTOMATISATION  
# =============================================================================

SCRIPT_DIR="/project/workspace"
cd "$SCRIPT_DIR"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_menu() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════╗"
    echo "║        SILVER C2 - AUTO MENU          ║"  
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
    echo "1. 📦 Installation complète Silver C2"
    echo "2. 🚀 Démarrage serveur + client"
    echo "3. 💾 Génération automatique de payloads"
    echo "4. 🖥️  Configuration laboratoire VMs"
    echo "5. 📖 Guide interactif pas à pas"
    echo "6. 🔄 Tout faire automatiquement"
    echo "7. 🧹 Nettoyage et arrêt"
    echo "0. ❌ Quitter"
    echo ""
    echo -n "Choisissez une option: "
}

install_silver() {
    echo -e "${GREEN}Installation de Silver C2...${NC}"
    sudo bash install_sliver_kali.sh
}

start_silver() {
    echo -e "${GREEN}Démarrage de Silver C2...${NC}"
    
    # Vérifier si déjà en cours
    if pgrep -f "sliver-server" > /dev/null; then
        echo -e "${YELLOW}Silver serveur déjà en cours${NC}"
    else
        # Démarrer le serveur
        sudo sliver-server --daemon &
        SERVER_PID=$!
        echo "Serveur démarré (PID: $SERVER_PID)"
        
        # Sauvegarder le PID
        echo $SERVER_PID > ~/.silver-server.pid
        
        sleep 3
    fi
    
    # Démarrer le client dans un nouveau terminal
    gnome-terminal -- bash -c "
        echo 'Connexion Silver C2 Client...'
        sleep 2
        sliver-client
        exec bash
    "
}

generate_payloads() {
    echo -e "${GREEN}Génération de payloads...${NC}"
    
    # Demander l'IP
    echo -n "IP de votre Kali (ou ENTRÉE pour auto-détection): "
    read KALI_IP
    
    if [[ -z "$KALI_IP" ]]; then
        KALI_IP=$(ip route get 1.1.1.1 | awk '{print $7}' | head -1)
        echo "IP détectée: $KALI_IP"
    fi
    
    bash generate_payloads.sh "$KALI_IP"
}

setup_lab() {
    echo -e "${GREEN}Configuration du laboratoire...${NC}"
    bash setup_silver_lab.sh
}

interactive_guide() {
    echo -e "${GREEN}Lancement du guide interactif...${NC}"
    bash guide_interactif.sh
}

auto_all() {
    echo -e "${GREEN}Automatisation complète...${NC}"
    
    install_silver
    sleep 2
    
    setup_lab  
    sleep 2
    
    generate_payloads
    sleep 2
    
    start_silver
    sleep 2
    
    interactive_guide
}

cleanup() {
    echo -e "${GREEN}Nettoyage...${NC}"
    
    # Arrêter Silver
    if [[ -f ~/.silver-server.pid ]]; then
        PID=$(cat ~/.silver-server.pid)
        kill $PID 2>/dev/null
        rm ~/.silver-server.pid
        echo "Serveur Silver arrêté"
    fi
    
    # Tuer tous les processus Silver
    sudo pkill -f sliver-server
    sudo pkill -f sliver-client
    
    echo "Nettoyage terminé"
}

# Menu principal
while true; do
    show_menu
    read choice
    
    case $choice in
        1) install_silver ;;
        2) start_silver ;;
        3) generate_payloads ;;
        4) setup_lab ;;
        5) interactive_guide ;;
        6) auto_all ;;
        7) cleanup ;;
        0) echo "Au revoir !"; exit 0 ;;
        *) echo -e "${RED}Option invalide${NC}" ;;
    esac
    
    echo -e "\n${YELLOW}Appuyez sur ENTRÉE pour continuer...${NC}"
    read
    clear
done
```

---

## 🔧 INSTALLATION ET UTILISATION

### **ÉTAPE 1 : Créer le script maître**

```bash
# Aller dans le répertoire
cd /project/workspace

# Créer le script principal
cat > silver-auto.sh << 'EOF'
[Coller le contenu du script maître ci-dessus]
EOF

# Rendre exécutable
chmod +x silver-auto.sh
```

### **ÉTAPE 2 : Créer un alias global**

```bash
# Ajouter à votre .bashrc
echo 'alias silver-auto="/project/workspace/silver-auto.sh"' >> ~/.bashrc

# Recharger
source ~/.bashrc
```

### **ÉTAPE 3 : Utilisation**

```bash
# Depuis n'importe où
silver-auto

# OU directement
./silver-auto.sh
```

---

## 🚀 AUTOMATISATION AVANCÉE

### **⏰ Exécution Planifiée (Crontab)**

```bash
# Exemple : Démarrer Silver C2 tous les jours à 9h
crontab -e

# Ajouter cette ligne :
0 9 * * * /project/workspace/silver-auto.sh auto_all
```

### **🔄 Script de Démarrage Système**

```bash
# Créer un service systemd
sudo nano /etc/systemd/system/silver-auto.service

# Contenu :
[Unit]
Description=Silver C2 Auto Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/project/workspace/silver-auto.sh auto_all
Restart=always

[Install]
WantedBy=multi-user.target

# Activer
sudo systemctl enable silver-auto.service
sudo systemctl start silver-auto.service
```

### **📱 Raccourci Bureau**

```bash
# Créer un raccourci sur le bureau
cat > ~/Desktop/Silver-C2-Auto.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Silver C2 Auto
Comment=Automatisation Silver C2
Exec=/project/workspace/silver-auto.sh
Icon=applications-security
Terminal=true
Categories=Security;
EOF

chmod +x ~/Desktop/Silver-C2-Auto.desktop
```

---

## 🎯 EXEMPLES D'UTILISATION RAPIDE

### **Installation Complète Automatique**
```bash
bash /project/workspace/install_sliver_kali.sh
```

### **Génération Rapide de Payloads**
```bash
bash /project/workspace/generate_payloads.sh 192.168.1.100
```

### **Démarrage Express**
```bash
# Terminal 1
sudo sliver-server &

# Terminal 2 (après 3 secondes)
sliver-client
```

---

## 📋 CHECKLIST D'AUTOMATISATION

- [ ] Scripts rendus exécutables (`chmod +x *.sh`)
- [ ] Chemins corrects vers `/project/workspace`
- [ ] Permissions sudo configurées
- [ ] Alias créé dans `.bashrc`
- [ ] Script maître `silver-auto.sh` créé
- [ ] Test d'exécution réussi

---

**🎯 Maintenant vous pouvez exécuter tout automatiquement avec une seule commande !**