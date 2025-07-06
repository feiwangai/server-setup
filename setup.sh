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
  apt install -y git curl zsh build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev \
  xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  software-properties-common apt-transport-https ca-certificates \
  gnupg lsb-release

  echo "🐍 Installing UV (Python package manager)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh

  echo "⚙️ Setting up Git configuration..."
  git config --global user.name "Fei Wang"
  git config --global user.email "feiwang.ai@gmail.com"

  echo "🔑 Generating SSH key..."
  ssh-keygen -t ed25519 -C "fei.wang@iu.org" -f /root/.ssh/id_ed25519 -N ""

  echo "🐚 Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL
  https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo "🔧 Setting default shell to zsh..."
  chsh -s $(which zsh)

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

  Next steps:
  1. Copy the SSH key above to GitHub
  2. Test: ssh -T git@github.com
  3. Clone your repositories

  EOF

  echo "✅ Setup complete! Check /root/setup_complete.txt for details."
  echo ""
  echo "🔑 Your SSH public key:"
  cat /root/.ssh/id_ed25519.pub
  echo ""
  echo "📋 Copy this key to GitHub and you're ready to go!"
