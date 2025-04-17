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

install_ubuntu () {
  check_root

  apt install -y zsh
  snap install --classic go
  exit 0
}

install_mint () {
  check_root

  apt install -y golang zsh
  exit 0
}

install_macos () {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew install go zsh
  exit 0
}

# Test OS for which package manager to use
if [[ $(uname -s) == "Darwin" ]]; then
  install_macos
fi

if grep -q Ubuntu /etc/lsb-release; then
  install_ubuntu
fi

if grep -q Mint /etc/lsb-release; then
  install_mint
fi

echo "Unsupported OS: $(uname -s). Must be a Debian flavor or MacOS."
exit 1
