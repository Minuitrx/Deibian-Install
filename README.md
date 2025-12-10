# Baseline Debian Server - Post-Installation

Documentation du script de post-installation pour serveur Debian 12/13.

## Prérequis

- Debian 12 (Bookworm) ou Debian 13 (Trixie) fraîchement installé
- Accès root
- Connexion internet fonctionnelle

## Installation rapide

```bash
# Télécharger et exécuter le script
chmod +x post_install.sh
./post_install.sh
```

## Ce que fait le script

### 1. Mise à jour du système

```bash
apt update && apt upgrade -y
```

Met à jour les dépôts et installe les dernières versions des paquets.

### 2. Installation des outils essentiels

| Paquet | Description |
|--------|-------------|
| ssh | Serveur SSH pour l'accès distant |
| zip/unzip | Gestion des archives ZIP |
| nmap | Scanner de ports et services |
| locate | Recherche rapide de fichiers (indexés) |
| ncdu | Analyse de l'espace disque en TUI |
| curl/wget | Clients HTTP en ligne de commande |
| git | Client Git pour cloner des projets |
| screen/tmux | Terminaux virtuels persistants |
| dnsutils | Outils DNS (dig, nslookup) |
| net-tools | ifconfig, netstat (legacy) |
| sudo | Élévation de privilèges |
| lynx | Navigateur web en CLI |
| htop | Monitoring système interactif |
| vim/nano | Éditeurs de texte |

### 3. Couche NetBIOS/Samba

Permet la résolution des noms Windows sur le réseau local :

```bash
apt install winbind samba
```

Configuration de `/etc/nsswitch.conf` pour ajouter `wins` à la résolution DNS.

### 4. Personnalisation du BASH

Le script configure `.bashrc` avec :

- Aliases colorés (`ls`, `ll`, `l`)
- Aliases utiles (`..`, `grep`, `df`, `du`, `ports`)
- Historique étendu (10000 lignes)
- Prompt personnalisé avec couleurs

### 5. Configuration réseau

Configuration IP statique dans `/etc/network/interfaces` :

```
auto ens33
iface ens33 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1
```

### 6. Configuration DNS

Fichier `/etc/resolv.conf` :

```
search localdomain
nameserver 8.8.8.8
nameserver 1.1.1.1
```

### 7. Installation Webmin

Interface web d'administration accessible sur le port 10000 :

```
https://IP_SERVEUR:10000
```

Authentification avec les identifiants root Linux.

### 8. Sécurisation SSH

- Désactivation du login root par mot de passe
- Login root autorisé uniquement par clé SSH

## Configuration

Modifier les variables en début de script selon votre environnement :

```bash
HOSTNAME="debian-srv"
IP_ADDRESS="192.168.1.100"
NETMASK="24"
GATEWAY="192.168.1.1"
DNS_SERVER="8.8.8.8"
DNS_SEARCH="localdomain"
INTERFACE="ens33"
```

Pour trouver le nom de votre interface réseau :

```bash
ip a
```

## Après l'installation

### Redémarrer le serveur

```bash
reboot
```

### Vérifier la configuration

```bash
# Vérifier l'IP
ip a

# Vérifier le hostname
hostname

# Vérifier les services
systemctl status ssh
systemctl status webmin

# Tester les alias
ll
ports
```

### Accéder à Webmin

1. Ouvrir un navigateur
2. Aller sur `https://IP_SERVEUR:10000`
3. Accepter le certificat auto-signé
4. Se connecter avec root

## Commandes utiles post-install

| Commande | Description |
|----------|-------------|
| `ll` | Liste détaillée avec couleurs |
| `l` | Liste incluant fichiers cachés |
| `ports` | Affiche les ports ouverts |
| `ncdu` | Analyse espace disque |
| `htop` | Monitoring CPU/RAM |
| `locate fichier` | Recherche rapide |
| `updatedb` | Mettre à jour l'index locate |

## Bonus : Jeux BSD

```bash
ls /usr/games
/usr/games/tetris-bsd
/usr/games/trek
```

## Dépannage

### Le réseau ne fonctionne plus après reboot

Vérifier la configuration :

```bash
cat /etc/network/interfaces
ip a
```

Redémarrer le service réseau :

```bash
systemctl restart networking
```

### Webmin inaccessible

Vérifier que le service tourne :

```bash
systemctl status webmin
```

Vérifier le firewall :

```bash
ufw status
ufw allow 10000/tcp
```

### SSH refuse la connexion root

Le script désactive le login root par mot de passe. Options :

1. Se connecter avec un user normal puis `su -`
2. Ajouter une clé SSH pour root
3. Modifier `/etc/ssh/sshd_config` : `PermitRootLogin yes`

## Structure du projet

```
.
├── post_install.sh      # Script principal
└── README.md            # Cette documentation
```

## Auteur

Adam - TSSR CEFIM/SKOLAE Tours - Décembre 2025
