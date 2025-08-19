# 🔧 RÉSOLUTION : Erreur "No config files found" - Silver C2

## ❌ **PROBLÈME IDENTIFIÉ**

L'erreur `No config files found at /home/kali/.sliver-client/configs` indique que :
- Le serveur Silver C2 n'a **pas encore été démarré**
- Aucun fichier de configuration client n'existe
- Il faut démarrer le **serveur en premier**

---

## ✅ **SOLUTION ÉTAPE PAR ÉTAPE**

### **ÉTAPE 1 : Démarrer le serveur Silver C2**

Dans votre terminal actuel :
```bash
sudo sliver-server
```

**✅ Résultat attendu** :
```
[*] Loaded 20 aliases from disk
[*] Loaded 104 extension(s) from disk

.------..------..------..------..------..------.
|S.--. ||L.--. ||I.--. ||V.--. ||E.--. ||R.--. |
| :/\: || :/\: || (\/) || :(): || (\/) || :(): |
| :\/: || (__) || :\/: || ()() || :\/: || ()() |
| '--'S|| '--'L|| '--'I|| '--'V|| '--'E|| '--'R|
`------'`------'`------'`------'`------'`------'

All hackers gain exalt
[*] Server v1.5.41 - f2a3915c79b31ab31c0c2f0428bbd53275eca0b9
[*] Welcome to the sliver shell, please type 'help' for options

[server] sliver >
```

**🔴 IMPORTANT** : Laissez ce terminal ouvert !

### **ÉTAPE 2 : Ouvrir un NOUVEAU terminal**

- **Méthode 1** : Clic droit sur le terminal → "Ouvrir un terminal"
- **Méthode 2** : Raccourci `Ctrl+Shift+T`
- **Méthode 3** : Ouvrir une nouvelle fenêtre de terminal

### **ÉTAPE 3 : Connecter le client**

Dans le **NOUVEAU** terminal :
```bash
sliver-client
```

**✅ Résultat attendu** :
```
Connecting to localhost:31337 ...
[*] Successfully connected to server
[*] Session 12345 authenticated

[*] Server v1.5.41 - f2a3915c79b31ab31c0c2f0428bbd53275eca0b9
[*] Client v1.5.41 - f2a3915c79b31ab31c0c2f0428bbd53275eca0b9

sliver >
```

---

## 🚀 **COMMANDES DE VÉRIFICATION**

### **Vérifier que tout fonctionne :**
```bash
# Dans le client Silver (sliver >)
help
jobs
sessions
```

### **Première configuration :**
```bash
# Créer un listener de test
mtls --lport 443

# Vérifier qu'il est actif
jobs
```

---

## 📋 **RÉSUMÉ DE LA SÉQUENCE CORRECTE**

```bash
# Terminal 1 (doit rester ouvert)
sudo sliver-server
# ↳ Affiche [server] sliver >

# Terminal 2 (nouveau terminal)
sliver-client
# ↳ Affiche sliver >
```

---

## 🔧 **SI VOUS AVEZ ENCORE DES PROBLÈMES**

### **Problème : Permission denied**
```bash
# Solution
sudo chown -R $USER:$USER ~/.sliver-client/
```

### **Problème : Port déjà utilisé**
```bash
# Tuer les processus Silver existants
sudo pkill -f sliver
sudo killall sliver-server
sudo killall sliver-client

# Puis redémarrer
sudo sliver-server
```

### **Problème : Connexion échouée**
```bash
# Vérifier que le serveur tourne
ps aux | grep sliver

# Vérifier les ports
sudo netstat -tlpn | grep 31337
```

---

## 📱 **ORGANISATION DE VOS TERMINAUX**

Pour une utilisation optimale :

```
┌─────────────────┬─────────────────┐
│  TERMINAL 1     │  TERMINAL 2     │
│                 │                 │
│ sudo sliver-    │ sliver-client   │
│ server          │                 │
│                 │                 │
│ [server]        │ sliver >        │
│ sliver >        │                 │
│                 │ Commandes ici   │
└─────────────────┴─────────────────┘
```

---

## 🎯 **COMMANDES DE TEST APRÈS CONNEXION**

Une fois connecté, testez avec :

```bash
# Aide générale
help

# Créer un listener
mtls --lport 443

# Vérifier les listeners
jobs

# Générer votre premier payload (remplacez l'IP)
generate --mtls 192.168.1.100:443 --os windows --format exe --save /tmp/test.exe

# Voir les implants générés
implants
```

---

## ✅ **CHECKLIST DE VÉRIFICATION**

- [ ] Terminal 1 : `sudo sliver-server` démarré
- [ ] Affichage du banner Silver C2 
- [ ] Terminal 2 : `sliver-client` connecté
- [ ] Prompt `sliver >` affiché
- [ ] Commande `help` fonctionne
- [ ] Listener créé avec `mtls --lport 443`
- [ ] Commande `jobs` montre le listener actif

---

**🎯 Maintenant vous pouvez continuer avec le guide étape par étape !**

Passez à l'**ÉTAPE 7** du guide détaillé pour créer votre premier listener.