# Recommandations VM pour MSI GT73VR - Environnement Silver C2

## 🖥️ SPÉCIFICATIONS TYPIQUES MSI GT73VR

### **Configuration Standard :**
- **CPU** : Intel Core i7-6700HQ/7700HQ (4 cœurs, 8 threads)
- **RAM** : 16-32GB DDR4
- **GPU** : NVIDIA GTX 1060/1070/1080
- **Stockage** : SSD 256GB + HDD 1TB

---

## 🎯 RECOMMANDATIONS SELON VOTRE CONFIGURATION

### **POUR 16GB RAM - Configuration Minimale**
```
🖥️ Host (Kali Linux natif) : 4-6GB RAM
└── VM 1 : Windows 10 (4GB RAM, 2 CPU)
└── VM 2 : Windows Server 2019 (4GB RAM, 2 CPU)
└── Réserve système : 2-4GB

TOTAL : 2 VMs maximum
```

### **POUR 32GB RAM - Configuration Optimale**
```
🖥️ Host (Kali Linux natif) : 6-8GB RAM
├── VM 1 : Windows 10 Client (4GB RAM, 2 CPU)
├── VM 2 : Windows 10 Client 2 (4GB RAM, 2 CPU)
├── VM 3 : Windows Server 2019 DC (6GB RAM, 2 CPU)
├── VM 4 : Ubuntu Server (2GB RAM, 1 CPU)
└── Réserve système : 6-8GB

TOTAL : 4 VMs confortablement
```

---

## 🛠️ CONFIGURATION RECOMMANDÉE POUR SILVER C2

### **Setup Idéal (32GB RAM)**

#### **Machine Host (Kali Linux)**
- **Utilisation** : Attaquant avec Silver C2
- **Installation** : Native (dual boot recommandé)
- **Ressources** : Accès total aux ressources restantes

#### **VM 1 - Windows 10 Cible Principale**
- **RAM** : 4GB
- **CPU** : 2 cœurs
- **Disque** : 50GB
- **Rôle** : Cible principale pour tests Silver C2
- **Config** : Antivirus désactivé, utilisateur standard

#### **VM 2 - Windows 10 Cible Secondaire**
- **RAM** : 4GB
- **CPU** : 2 cœurs
- **Disque** : 50GB
- **Rôle** : Test de mouvement latéral
- **Config** : Différent utilisateur, fichiers sensibles

#### **VM 3 - Windows Server 2019 (Contrôleur de Domaine)**
- **RAM** : 6GB
- **CPU** : 2 cœurs
- **Disque** : 60GB
- **Rôle** : Domaine Active Directory pour tests avancés
- **Config** : DC avec plusieurs utilisateurs

#### **VM 4 - Ubuntu Server (Optionnel)**
- **RAM** : 2GB
- **CPU** : 1 cœur
- **Disque** : 20GB
- **Rôle** : Serveur web, base de données pour scénarios

---

## 📊 CONFIGURATIONS PAR SCÉNARIO

### **SCÉNARIO 1 : Tests Basiques (16GB RAM)**
```
Objectif : Apprendre Silver C2
┌─────────────────────────────────────┐
│ Host Kali (6GB) - Silver C2 Server  │
├─────────────────────────────────────┤
│ VM Windows 10 (4GB) - Cible        │
│ VM Windows Server (4GB) - DC       │
│ Réserve (2GB)                      │
└─────────────────────────────────────┘
```

### **SCÉNARIO 2 : Tests Avancés (32GB RAM)**
```
Objectif : Mouvement latéral, domaine AD
┌─────────────────────────────────────┐
│ Host Kali (8GB) - Silver C2        │
├─────────────────────────────────────┤
│ VM Win10-Client1 (4GB)             │
│ VM Win10-Client2 (4GB)             │  
│ VM WinServer-DC (6GB)              │
│ VM Ubuntu-Web (2GB)               │
│ Réserve (8GB)                     │
└─────────────────────────────────────┘
```

### **SCÉNARIO 3 : Tests de Performance (32GB RAM)**
```
Objectif : Stress test, multiple sessions
┌─────────────────────────────────────┐
│ Host Kali (6GB) - Silver C2        │
├─────────────────────────────────────┤
│ VM Win10-1 (6GB) - Cible riche     │
│ VM Win10-2 (6GB) - Cible riche     │
│ VM WinServer (8GB) - Infrastructure│
│ Réserve (6GB)                      │
└─────────────────────────────────────┘
```

---

## ⚡ OPTIMISATIONS PERFORMANCES

### **Paramètres VirtualBox/VMware**
```bash
# VirtualBox optimisations
VBoxManage modifyvm "Windows10" --memory 4096 --cpus 2
VBoxManage modifyvm "Windows10" --vram 128
VBoxManage modifyvm "Windows10" --accelerate3d on
VBoxManage modifyvm "Windows10" --acpi on
VBoxManage modifyvm "Windows10" --ioapic on
```

### **Allocation RAM Dynamique**
```
Windows 10 : 2GB minimum, 4GB maximum
Windows Server : 2GB minimum, 6GB maximum
Ubuntu : 1GB minimum, 2GB maximum
```

### **Disques SSD Recommandés**
- **Host OS** : SSD principal
- **VMs actives** : SSD si possible
- **VMs stockage** : HDD acceptable

---

## 🔥 CONFIGURATIONS DE TEST SPÉCIALISÉES

### **Test 1 : Environnement Minimal (16GB)**
```
Kali Linux (Host) : 6GB
├── Windows 10 Pro (4GB, 2 CPU)
│   ├── Utilisateur : testuser
│   ├── Antivirus : Windows Defender désactivé
│   ├── Réseau : 192.168.56.101
│   └── Fichiers : Documents sensibles simulés
│
├── Windows Server 2019 (4GB, 2 CPU)
│   ├── Rôle : Contrôleur de domaine
│   ├── Domaine : testlab.local
│   ├── Réseau : 192.168.56.100
│   └── Utilisateurs : admin, user1, user2
│
└── Réserve système : 2GB
```

### **Test 2 : Environnement Complet (32GB)**
```
Kali Linux (Host) : 8GB
├── Win10-Workstation1 (4GB, 2 CPU)
│   ├── Membre du domaine testlab.local
│   ├── Utilisateur : alice
│   └── IP : 192.168.56.101
│
├── Win10-Workstation2 (4GB, 2 CPU)
│   ├── Membre du domaine testlab.local
│   ├── Utilisateur : bob
│   └── IP : 192.168.56.102
│
├── WinServer-DC (6GB, 2 CPU)
│   ├── Contrôleur de domaine
│   ├── DNS, DHCP activés
│   └── IP : 192.168.56.100
│
├── Ubuntu-WebServer (2GB, 1 CPU)
│   ├── Apache, MySQL
│   ├── Applications web vulnérables
│   └── IP : 192.168.56.103
│
└── Réserve : 8GB
```

---

## 🛡️ SÉCURITÉ ET ISOLATION

### **Réseau Isolé**
```bash
# Configuration réseau isolé
Type réseau : Host-Only ou Internal
Plage IP : 192.168.56.0/24
Passerelle : 192.168.56.1 (Host)
DNS : 192.168.56.100 (Windows Server)
```

### **Snapshots Recommandés**
```
Snapshot 1 : État propre initial
Snapshot 2 : Après installation/config
Snapshot 3 : Avant chaque test
Snapshot 4 : État compromis pour analyse
```

---

## 📈 MONITORING PERFORMANCES

### **Surveillance Host**
```bash
# Monitoring CPU/RAM
htop
free -h
iostat -x 1

# Monitoring VMs
VBoxManage list runningvms
VBoxManage showvminfo "Windows10" | grep Memory
```

### **Indicateurs Critiques**
- **RAM Host** : < 80% utilisation
- **CPU Host** : < 70% utilisation moyenne
- **Swap** : Éviter l'utilisation du swap
- **I/O Disque** : < 80% utilisation

---

## 🎯 RECOMMANDATION FINALE

### **Pour votre MSI GT73VR :**

#### **Si 16GB RAM :**
```
✅ 2 VMs (1 Windows 10 + 1 Windows Server)
✅ Tests Silver C2 basiques à avancés
✅ Apprentissage complet du framework
⚠️ Pas de tests multi-cibles simultanés
```

#### **Si 32GB RAM :**
```
✅ 4 VMs (2 Windows 10 + 1 Server + 1 Linux)
✅ Tous types de tests Silver C2
✅ Simulation d'environnement entreprise
✅ Tests de mouvement latéral complets
✅ Multiple sessions simultanées
```

#### **Upgrade recommandé :**
- **RAM** : 32GB si possible (maximum supporté)
- **Stockage** : SSD 1TB pour les VMs
- **Refroidissement** : Support ventilé pour sessions longues

---

## 💡 CONSEILS PRATIQUES

### **Gestion Ressources**
- Démarrez les VMs une par une selon le besoin
- Utilisez la pause/suspension entre les tests
- Fermez les applications inutiles sur l'host
- Surveillez la température du laptop

### **Organisation Tests**
1. **Phase 1** : Tests avec 1 VM (apprentissage)
2. **Phase 2** : Tests avec 2 VMs (mouvement latéral)
3. **Phase 3** : Tests avec 3-4 VMs (scénarios complets)

### **Sauvegarde**
- Snapshots avant chaque série de tests
- Export des VMs importantes
- Sauvegarde des configurations Silver C2

---

**🎯 Résumé : Votre MSI GT73VR peut gérer 2-4 VMs selon la RAM, parfait pour un apprentissage complet de Silver C2 !**