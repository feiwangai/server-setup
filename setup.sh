#!/bin/bash
# Set non-interactive mode to avoid prompts
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
echo "🚀 Starting server setup..."
# Function to wait for apt lock to be released
wait_for_apt() {
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "⏳ Waiting for other apt processes to finish..."
        sleep 5
    done
}
# Kill any stuck apt processes
echo "🔧 Cleaning up any stuck processes..."
sudo killall -9 apt 2>/dev/null || true
sudo killall -9 dpkg 2>/dev/null || true
# Remove lock files if they exist
sudo rm -f /var/lib/dpkg/lock-frontend
sudo rm -f /var/lib/dpkg/lock
sudo rm -f /var/cache/apt/archives/lock
# Clean up any interrupted package installations
sudo dpkg --configure -a
# Wait for any remaining processes
wait_for_apt
echo "📦 Updating package lists..."
apt update
echo "⬆️ Upgrading system packages..."
apt upgrade -y

echo "🛠️ Installing essential packages..."
sudo apt install -y git curl build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev \
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
software-properties-common apt-transport-https ca-certificates \
gnupg lsb-release

echo "🌐 Installing Playwright/Browser Automation dependencies..."
echo "⚠️  CRITICAL: Without these, Playwright scrapers will process batches but collect 0 data!"
# Install ALL dependencies for headless Chrome/Chromium
# Missing even one of these will cause "BrowserType.launch: Host system is missing dependencies" errors
sudo apt install -y \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libatspi2.0-0 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libxcb1 \
    libxkbcommon0 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libxkbcommon-x11-0 \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    fonts-liberation \
    libvulkan1 \
    xvfb

# Additional dependencies that playwright install-deps would add
sudo apt install -y \
    libglib2.0-0 \
    libxshmfence1 \
    libglvnd0 \
    libglx0 \
    libgl1 \
    libegl1 \
    libgles2 \
    libicu74 \
    libwebp7 \
    libharfbuzz0b

echo "📊 Installing monitoring tools..."
sudo apt install -y htop iotop nethogs iftop ncdu tmux

echo "☁️ Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/
# Verify installation
aws --version

echo "🐍 Installing UV (Python package manager)..."
curl -LsSf https://astral.sh/uv/install.sh | sh

source $HOME/.local/bin/env

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"
# Download and install Node.js:
nvm install 22
# Verify the Node.js version:
node -v # Should print "v22.17.0".
nvm current # Should print "v22.17.0".
# Verify npm version:
npm -v # Should print "10.9.2".

echo "🐚 Installing Zsh and Oh My Zsh..."
# Install Zsh
sudo apt install zsh -y
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Git, Zsh, Oh My Zsh, all development packages, UV installation complete!"
echo "🔧 Setting default shell to zsh..."
chsh -s $(which zsh)

echo "⚙️ Setting up Git configuration..."
git config --global user.name "Fei Wang"
git config --global user.email "feiwang.ai@gmail.com"
echo "🔑 Generating SSH key..."
ssh-keygen -t ed25519 -C "feiwang.ai@gmail.com" -f /root/.ssh/id_ed25519 -N ""

echo "📁 Creating project directories..."
mkdir -p /root/projects/active
mkdir -p /root/projects/archive
echo "Project directories created: /root/projects/active and /root/projects/archive"

echo "🎭 Installing Playwright browsers (optional - for testing)..."
echo "Note: This is optional. Workers will install browsers when needed."
# Create a temporary Python environment to install playwright
cd /tmp
/root/.local/bin/uv venv temp-env
source temp-env/bin/activate
/root/.local/bin/uv pip install playwright
# Install browsers (this downloads Chromium, Firefox, WebKit)
playwright install chromium
deactivate
rm -rf temp-env
echo "Playwright browsers installed for testing purposes"

echo "📝 Creating setup completion marker..."
cat > /root/setup_complete.txt << EOF
=== SERVER SETUP COMPLETE ===
Completed at: $(date)
SSH Public Key (add this to GitHub):
$(cat /root/.ssh/id_ed25519.pub)
Installed packages:
- Git, Zsh, Oh My Zsh
- Python development tools
- UV package manager
- Build essentials
- Playwright/Browser Automation dependencies (COMPLETE SET)
  ⚠️  All system deps installed - no need for 'playwright install-deps'
- Playwright Chromium browser (for testing)
- Monitoring tools (htop, iotop, nethogs, iftop, ncdu, tmux)
- Node.js v22 (via nvm)
- AWS CLI v2

Project structure created:
- /root/projects/active/   (for current projects)
- /root/projects/archive/  (for completed projects)

Next steps:
1. Copy the SSH key above to GitHub
2. Test: ssh -T git@github.com
3. Clone your repositories
4. Configure AWS CLI: aws configure
EOF
echo "✅ Setup complete! Check /root/setup_complete.txt for details."
echo ""
echo "🔑 Your SSH public key:"
cat /root/.ssh/id_ed25519.pub
echo ""
echo "📋 Copy this key to GitHub and you're ready to go!"
