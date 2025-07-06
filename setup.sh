#!/bin/bash

# Update system

export DEBIAN_FRONTEND=noninteractive

# Wait for any existing apt processes to finish
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "Waiting for other apt processes to finish..."
    sleep 5
done

apt update && apt upgrade -y

# Install essential packages
apt install -y git curl zsh build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev \
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Set up Git
git config --global user.name "Fei Wang"
git config --global user.email "feiwang.ai@gmail.com"

# Generate SSH key
ssh-keygen -t ed25519 -C "feiwang.ai@gmail.com" -f /root/.ssh/id_ed25519 -N ""

# Install Oh My Zsh (non-interactive)
RUNZSH=no CHSH=no sh -c "$(curl -fsSL
https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set default shell to zsh
chsh -s $(which zsh)

# Create marker file
echo "Setup completed at $(date)" > /root/setup_complete.txt
echo "=== SSH PUBLIC KEY ===" >> /root/setup_complete.txt
cat /root/.ssh/id_ed25519.pub >> /root/setup_complete.txt

echo "✅ Server setup complete! SSH key saved to /root/setup_complete.txt"
