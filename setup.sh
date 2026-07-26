#!/usr/bin/env bash

set -e

HOST="server.vendore.tech"
USER="semmozhiyan"

echo "========================================="
echo " Vendore Remote SSH Installer"
echo "========================================="
echo

# Detect OS
OS="$(uname)"

install_cloudflared_linux() {

    if command -v cloudflared >/dev/null 2>&1; then
        echo "✓ cloudflared already installed"
        return
    fi

    echo "Installing Cloudflare Tunnel..."

    if command -v apt >/dev/null 2>&1; then

        curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
        | sudo gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg

        echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" \
        | sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null

        sudo apt update
        sudo apt install -y cloudflared

    elif command -v dnf >/dev/null 2>&1; then

        sudo dnf install -y cloudflared

    elif command -v pacman >/dev/null 2>&1; then

        sudo pacman -Sy --noconfirm cloudflared

    else
        echo "Unsupported Linux distribution."
        exit 1
    fi
}

install_cloudflared_macos() {

    if command -v cloudflared >/dev/null 2>&1; then
        echo "✓ cloudflared already installed"
        return
    fi

    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required."
        exit 1
    fi

    brew install cloudflared
}

case "$OS" in
    Linux)
        install_cloudflared_linux
        ;;
    Darwin)
        install_cloudflared_macos
        ;;
    *)
        echo "Unsupported OS."
        exit 1
        ;;
esac

mkdir -p ~/.ssh
chmod 700 ~/.ssh

touch ~/.ssh/config
chmod 600 ~/.ssh/config

if ! grep -q "Host $HOST" ~/.ssh/config; then

cat >> ~/.ssh/config <<EOF

Host $HOST
    HostName $HOST
    User $USER
    ProxyCommand cloudflared access ssh --hostname %h

EOF

fi

echo
echo "========================================="
echo " Installation Complete"
echo "========================================="
echo
echo "Connect using:"
echo
echo "ssh $USER@$HOST"
echo
