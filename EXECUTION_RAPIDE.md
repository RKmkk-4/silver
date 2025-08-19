# ⚡ EXÉCUTION AUTOMATIQUE RAPIDE - Silver C2

## 🚀 **1 COMMANDE = TOUT AUTOMATIQUE**

### **Option 1 : Script Maître (RECOMMANDÉ)**
```bash
cd /project/workspace
./silver-auto.sh
```
**→ Menu interactif avec toutes les options**

### **Option 2 : Scripts Individuels**
```bash
# Installation automatique
./install_sliver_kali.sh

# Génération payloads automatique  
./generate_payloads.sh 192.168.1.100

# Configuration VMs automatique
./setup_silver_lab.sh

# Guide pas à pas interactif
./guide_interactif.sh
```

---

## 🎮 **UTILISATION DU MENU AUTOMATIQUE**

Après avoir lancé `./silver-auto.sh`, vous verrez :

```
╔══════════════════════════════════════════════════════╗
║           SILVER C2 - AUTOMATISATION MAÎTRE         ║
╚══════════════════════════════════════════════════════╝

📦 INSTALLATION & CONFIGURATION
  1. 📥 Installation complète Silver C2
  2. 🖥️ Configuration laboratoire VMs

🚀 UTILISATION SILVER C2  
  3. ⚡ Démarrage serveur + client
  4. 💾 Génération automatique payloads
  5. 📖 Guide interactif pas à pas

🔧 AUTOMATISATION COMPLÈTE
  6. 🎯 Installation + Configuration + Démarrage
  7. 🏃 Démarrage rapide (si déjà installé)

Choisissez une option (0-10):
```

---

## ⚡ **SCÉNARIOS D'UTILISATION RAPIDE**

### **🆕 PREMIÈRE UTILISATION (tout automatique)**
```bash
./silver-auto.sh
# Choisir option 6 → Fait TOUT automatiquement
```

### **📅 UTILISATION QUOTIDIENNE**
```bash  
./silver-auto.sh
# Choisir option 7 → Démarrage rapide
```

### **💾 GÉNÉRATION PAYLOADS SEULEMENT**
```bash
./generate_payloads.sh 192.168.1.100
# OU via menu : option 4
```

### **🖥️ CONFIGURATION VMs SEULEMENT**
```bash
./setup_silver_lab.sh  
# OU via menu : option 2
```

---

## 🔧 **RÉSOLUTION PROBLÈMES**

### **Permission denied**
```bash
chmod +x /project/workspace/*.sh
```

### **Script non trouvé**  
```bash
cd /project/workspace
ls -la *.sh  # Vérifier présence
```

### **Erreur sudo**
```bash
# Exécuter avec bash si problème
bash silver-auto.sh
```

---

## 📋 **COMMANDES EXPRESS**

```bash
# Tout faire d'un coup (première fois)
cd /project/workspace && ./silver-auto.sh

# Dans le menu, taper : 6

# OU directement sans menu :
./install_sliver_kali.sh && ./generate_payloads.sh 192.168.1.100
```

---

## 🎯 **WORKFLOW RECOMMANDÉ**

### **Jour 1 - Installation**
1. `./silver-auto.sh` → Option 6 (Tout automatique)
2. Attendre fin d'installation
3. Tester avec quelques payloads

### **Jour 2+ - Utilisation**  
1. `./silver-auto.sh` → Option 7 (Démarrage rapide)
2. Silver C2 prêt en quelques secondes !

---

**🚀 Plus simple que ça, impossible ! Une seule commande lance tout.**