#!/usr/bin/env bash
# One-time setup for a fresh Ubuntu VPS that will host the research-db stack.
# Run this on the VPS itself (over SSH), as a user with sudo access:
#
#   chmod +x server_setup.sh
#   ./server_setup.sh
#
set -euo pipefail

echo "==> Updating system packages"
sudo apt-get update -y
sudo apt-get upgrade -y

echo "==> Installing Docker"
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"

echo "==> Installing Tailscale"
curl -fsSL https://tailscale.com/install.sh | sh
echo "    Starting Tailscale — this will print a URL. Open it in a browser on"
echo "    any device to authenticate this VPS to your Tailscale account."
sudo tailscale up

echo "==> Installing and configuring the firewall (UFW)"
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on tailscale0
sudo ufw allow 22/tcp
sudo ufw --force enable

TS_IP="$(tailscale ip -4 || echo 'run: tailscale ip -4')"

cat <<EOF

==> Done.

This machine's Tailscale address: ${TS_IP}
(Port 5432 is only reachable over the tailscale0 interface — not from the
open internet — so use this address, not the VPS's public IP, in DBeaver.)

One more thing: your docker group membership won't take effect in this
shell session. Either log out and back in, or run:

    newgrp docker

before your first 'docker compose up -d'.
EOF
