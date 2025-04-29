#!/bin/bash

## Script to install required toolchain and shell dependencies.
# Portable with Debian-based Linux and MacOS
#

check_root () {
  if ! [ $(id -u) = 0 ]; then
    echo "This script must be run as root!"
    exit 1
  fi
}

check_nonroot () {
  if [ $(id -u) = 0 ]; then
    echo "This script must not be run as root!"
    exit 1
  fi
}

install_ubuntu () {
  check_root

  apt install -y vim zsh
  snap install --classic go
  curl -LsSf https://astral.sh/uv/install.sh | sh
  exit 0
}

install_non_snap_debian () {
  check_root

  apt install -y golang vim zsh
  curl -LsSf https://astral.sh/uv/install.sh | sh
  exit 0
}

install_macos () {
  check_nonroot

  if [ -z $(which brew) ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install go uv vim wget zsh
  exit 0
}

# Test OS for which package manager to use
if [[ $(uname -s) == "Darwin" ]]; then
  install_macos
elif [ -f /etc/lsb-release ]; then
    # This applies for most Debian-based distros
    if grep -q Ubuntu /etc/lsb-release; then
      install_ubuntu
    elif grep -q Mint /etc/lsb-release; then
      install_non_snap_debian
    fi
elif [ -f /etc/debian_version ]; then
    # Fallback for other Debian versions like Raspbian
    install_non_snap_debian
fi

echo "Unsupported OS: $(uname -s). Must be a Debian flavor or MacOS."
exit 1
