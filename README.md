# Post-Install Debian Server

Script de configuration post-installation pour Debian 12/13.

## Utilisation

```bash
wget https://raw.githubusercontent.com/Minuitrx/Deibian-Install/main/post_install.sh
chmod +x post_install.sh
./post_install.sh
```

## Paquets installés

- ssh, zip, unzip, nmap, locate, ncdu
- curl, wget, git, screen
- dnsutils, net-tools, sudo
- lynx, htop, vim, nano
- winbind, samba
- webmin
- bsdgames

## Alias configurés

| Alias | Commande |
|-------|----------|
| ll | ls -l en couleur |
| l | ls -lA en couleur |
| ports | ss -tulnp |

## Webmin

```
https://IP_SERVEUR:10000
```

Login : root / mot de passe root

## Auteur

Adam - TSSR CEFIM 2025
