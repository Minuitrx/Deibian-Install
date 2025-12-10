#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Erreur : execute en root"
    exit 1
fi

apt update && apt upgrade -y

apt install -y ssh zip unzip nmap locate ncdu curl wget git screen dnsutils net-tools sudo lynx htop vim nano

updatedb

apt install -y winbind samba

grep -q "wins" /etc/nsswitch.conf || sed -i 's/^hosts:.*/hosts:          files dns wins/' /etc/nsswitch.conf

cat > /root/.bashrc << 'EOF'
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias ports='ss -tulnp'
EOF

cp /root/.bashrc /etc/skel/.bashrc

curl -fsSL -o /tmp/webmin-setup.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sh /tmp/webmin-setup.sh <<< "y"
apt install -y webmin --install-recommends
rm /tmp/webmin-setup.sh

apt install -y bsdgames

echo "Installation terminee"
