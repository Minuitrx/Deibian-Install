#!/bin/bash
#===============================================================================
# Script post-installation Debian Server Baseline
# Auteur: Adam
# Date: Décembre 2025
# Description: Automatise la configuration post-install d'un serveur Debian
#===============================================================================

set -e  # Stop on error

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de log
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Vérification root
if [ "$EUID" -ne 0 ]; then
    log_error "Ce script doit être exécuté en root"
    exit 1
fi

#===============================================================================
# CONFIGURATION - Modifier selon vos besoins
#===============================================================================
HOSTNAME="debian-srv"
IP_ADDRESS="192.168.1.100"
NETMASK="24"
GATEWAY="192.168.1.1"
DNS_SERVER="8.8.8.8"
DNS_SEARCH="localdomain"
INTERFACE="ens33"  # Adapter selon votre interface (ip a pour vérifier)

#===============================================================================
# 1. MISE À JOUR DU SYSTÈME
#===============================================================================
log_info "Mise à jour du système..."
apt update && apt upgrade -y

#===============================================================================
# 2. INSTALLATION DES OUTILS ESSENTIELS (BinUtils)
#===============================================================================
log_info "Installation des outils essentiels..."
apt install -y \
    ssh \
    zip \
    unzip \
    nmap \
    locate \
    ncdu \
    curl \
    wget \
    git \
    screen \
    tmux \
    dnsutils \
    net-tools \
    sudo \
    lynx \
    htop \
    vim \
    nano

# Mise à jour de la base de données locate
log_info "Indexation des fichiers pour locate..."
updatedb

#===============================================================================
# 3. INSTALLATION NETBIOS/SAMBA (résolution noms Windows)
#===============================================================================
log_info "Installation de Samba et Winbind..."
apt install -y winbind samba

# Configuration nsswitch.conf pour wins
log_info "Configuration de nsswitch.conf..."
if ! grep -q "wins" /etc/nsswitch.conf; then
    sed -i 's/^hosts:.*/hosts:          files dns wins/' /etc/nsswitch.conf
    log_info "wins ajouté à nsswitch.conf"
else
    log_warn "wins déjà présent dans nsswitch.conf"
fi

#===============================================================================
# 4. PERSONNALISATION DU BASH
#===============================================================================
log_info "Configuration du .bashrc pour root..."
cat > /root/.bashrc << 'EOF'
# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are set in /etc/profile
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# Colorized ls
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Aliases utiles
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='ss -tulnp'

# Historique amélioré
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Prompt personnalisé avec couleurs
PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF

# Appliquer aussi pour les nouveaux users
cp /root/.bashrc /etc/skel/.bashrc

#===============================================================================
# 5. CONFIGURATION RÉSEAU (IP FIXE)
#===============================================================================
log_info "Configuration réseau en IP fixe..."

# Backup de la config actuelle
cp /etc/network/interfaces /etc/network/interfaces.bak

cat > /etc/network/interfaces << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto ${INTERFACE}
iface ${INTERFACE} inet static
    address ${IP_ADDRESS}/${NETMASK}
    gateway ${GATEWAY}
EOF

#===============================================================================
# 6. CONFIGURATION DNS
#===============================================================================
log_info "Configuration DNS..."
cat > /etc/resolv.conf << EOF
search ${DNS_SEARCH}
nameserver ${DNS_SERVER}
nameserver 1.1.1.1
EOF

# Empêcher la modification automatique de resolv.conf
chattr +i /etc/resolv.conf 2>/dev/null || log_warn "Impossible de verrouiller resolv.conf"

#===============================================================================
# 7. CONFIGURATION HOSTNAME
#===============================================================================
log_info "Configuration du hostname..."
echo "${HOSTNAME}" > /etc/hostname
hostname "${HOSTNAME}"

# Mise à jour /etc/hosts
if ! grep -q "${HOSTNAME}" /etc/hosts; then
    echo "127.0.1.1    ${HOSTNAME}" >> /etc/hosts
fi

#===============================================================================
# 8. INSTALLATION WEBMIN
#===============================================================================
log_info "Installation de Webmin..."
curl -fsSL -o /tmp/webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sh /tmp/webmin-setup-repo.sh <<< "y"
apt install -y webmin --install-recommends
rm /tmp/webmin-setup-repo.sh

#===============================================================================
# 9. CONFIGURATION SSH SÉCURISÉE
#===============================================================================
log_info "Sécurisation SSH..."
# Backup config SSH
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Désactiver le login root par mot de passe (garder par clé)
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

systemctl restart sshd

#===============================================================================
# 10. BONUS - JEUX BSD
#===============================================================================
log_info "Installation des jeux BSD (bonus fun)..."
apt install -y bsdgames

#===============================================================================
# RÉSUMÉ FINAL
#===============================================================================
echo ""
echo "=============================================="
echo -e "${GREEN}  INSTALLATION TERMINÉE AVEC SUCCÈS !${NC}"
echo "=============================================="
echo ""
echo "Configuration appliquée :"
echo "  - Hostname    : ${HOSTNAME}"
echo "  - IP          : ${IP_ADDRESS}/${NETMASK}"
echo "  - Gateway     : ${GATEWAY}"
echo "  - DNS         : ${DNS_SERVER}"
echo ""
echo "Services installés :"
echo "  - SSH         : Port 22"
echo "  - Webmin      : https://${IP_ADDRESS}:10000"
echo ""
echo "Commandes utiles :"
echo "  - ll          : Liste détaillée colorée"
echo "  - ports       : Voir les ports ouverts"
echo "  - ncdu        : Analyser l'espace disque"
echo "  - htop        : Monitoring système"
echo ""
echo -e "${YELLOW}⚠️  REDÉMARREZ pour appliquer la config réseau :${NC}"
echo "    reboot"
echo ""
