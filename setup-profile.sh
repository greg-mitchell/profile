#!/bin/bash

set -euo pipefail

# Env vars:
# - NF_FONT_FAMILY: Comma-separated list of Nerd Font families to install (only
#   applicable on Linux, MacOS installs all).
# - NF_RELEASE: Nerd Font Github release tag

NF_FONT_FAMILY="${NF_FONT_FAMILY:-Meslo}"
NF_RELEASE="${NF_RELEASE:-v3.3.0}"

install_linux_nerd_font () {
  # Installs a Nerd Font to .local/share/fonts
  # Args:
  # - $1: Font family name
  # Env vars:
  # - NF_RELEASE

  prev_pwd="$PWD"
  font_archive="$1.zip"
  wget -P "$HOME/.local/share/fonts" "https://github.com/ryanoasis/nerd-fonts/releases/download/$NF_RELEASE/$font_archive"
  cd "$HOME/.local/share/fonts"
  unzip -f "$font_archive"
  rm "$font_archive"
  fc-cache -fv
  cd "$prev_pwd"
}

install_linux_listed_nerd_fonts () {
  IFS=', ' read -r -a font_families <<< "$NF_FONT_FAMILY"
  for font in "${font_families[@]}"; do
    install_linux_nerd_font "$font"
  done
}

install_nerd_fonts () {
  if [[ $(uname -s) == "Darwin" ]]; then
    brew install font-hack-nerd-font
  else
    install_linux_listed_nerd_fonts
  fi
}

checkout_latest () {
  # destructively updates a plugin
  # args:
  # - git repo to clone
  # - destination dir relative to $ZSH_CUSTOM

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  DST="$ZSH_CUSTOM/$2"
  if [ -d "$DST" ]; then
    # since git shallow copies can't cheaply be updated to latest, instead wipe
    # away the plugin and redownload.
    rm -rf "$DST"
  fi

  git clone --depth=1 $1 "$DST"
}

cp_checked () {
  # Copies a file $1 from cwd to $2, checking first that it exists
  # If the file doesn't exist, prints a message and exits.

  if ! [ -f "./$1" ]; then
  	echo "$1 was not found in working directory, run this script from backup dir"
  	exit 1
  fi

  cp "$1" "$2"
}

if grep -wq "/usr/bin/zsh" /etc/shells; then
	echo "Zsh installed. Going to destroy previous .zshrc and install a new profile."
	read -p "Continue? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
else
	echo "Please install zsh first"
	exit 1
fi

if echo $SHELL | grep -v zsh ; then
  echo "Removing old oh-my-zsh install, chsh to zsh..."
  rm -rf "$HOME/.oh-my-zsh"
  # RUN_ZSH=no prevents the install script from running zsh as its last command, which never exits
  RUN_ZSH=no sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
fi

echo "Installing plugin and themes..."
checkout_latest https://github.com/romkatv/powerlevel10k.git "themes/powerlevel10k"
checkout_latest https://github.com/marlonrichert/zsh-autocomplete.git plugins/zsh-autocomplete
checkout_latest https://github.com/zdharma-continuum/fast-syntax-highlighting.git plugins/fast-syntax-highlighting
checkout_latest https://github.com/zsh-users/zsh-completions.git plugins/zsh-completions
checkout_latest https://github.com/zsh-users/zsh-syntax-highlighting.git plugins/zsh-syntax-highlighting

echo "Installing fonts: ${NF_FONT_FAMILY}"
install_nerd_fonts

echo "Copying profile from working directory..."
read -p "Destination? ($HOME) " dest
if [[ -z $dest ]]; then
  dest="$HOME"
fi

cp_checked .zshrc "$dest"
cp_checked .p10k.zsh "$dest"
cp_checked .zsh_aliases "$dest"
cp_checked .vimrc "$dest"
cp_checked .gitconfig "$dest"

echo "Creating toolchain and development directories..."
mkdir -pv "$(go env GOPATH)/bin"
mkdir -pv "$HOME/projects"

echo "Done. Log out and back in to use zsh"
echo "If prompt symbols are not displaying, ensure $NF_FONT_FAMILY is set as your terminal font and/or run p10k configure"
