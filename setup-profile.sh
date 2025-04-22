#!/bin/bash

set -euo pipefail

# Env vars:
# - NF_FONT_FAMILY: Comma-separated list of Nerd Font families to install (only
#   applicable on Linux, MacOS installs all).
# - NF_RELEASE: Nerd Font Github release tag

NF_FONT_FAMILY="${NF_FONT_FAMILY:-Meslo}"
NF_RELEASE="${NF_RELEASE:-v3.3.0}"

main () {
    if grep -wq "/usr/bin/zsh" /etc/shells; then
        echo "~~ Greg's Profile Setup Script ~~"
        echo "WARNING! This will overwrite many dotfiles including .zshrc"
        echo "If any configuration should be preserved, please copy before running this script."
        echo "About to overwrite files in $HOME."
        read -p "Continue? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
    else
        echo "Please install zsh first"
        exit 1
    fi

    echo
    if [ -d "$HOME/.oh-my-zsh" ]; then
        if echo $SHELL | grep -q zsh ; then
            echo "Shell is already zsh and oh-my-zsh is present. Not reinstalling oh-my-zsh. Continuing to update plugins."
            echo "If your install is corrupted, run the following then rerun this script: rm -rf ~/.oh-my-zsh"
        else
            echo "oh-my-zsh is installed but the user's shell is not zsh. Running chsh, expect a password prompt."
            chsh -s $(which zsh)
        fi
    else
        # zsh is installed, now install oh-my-zsh
        # RUN_ZSH=no prevents the install script from running zsh as its last command, which never exits
        RUN_ZSH=no sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    fi

    echo
    echo "Installing zsh plugins and themes..."
    checkout_latest_zsh https://github.com/romkatv/powerlevel10k.git "themes/powerlevel10k"
    checkout_latest_zsh https://github.com/marlonrichert/zsh-autocomplete.git plugins/zsh-autocomplete
    checkout_latest_zsh https://github.com/zdharma-continuum/fast-syntax-highlighting.git plugins/fast-syntax-highlighting
    checkout_latest_zsh https://github.com/zsh-users/zsh-completions.git plugins/zsh-completions
    checkout_latest_zsh https://github.com/zsh-users/zsh-syntax-highlighting.git plugins/zsh-syntax-highlighting

    echo
    echo "Installing fonts: ${NF_FONT_FAMILY}"
    install_nerd_fonts

    echo
    echo "Install vim pathogen plugins..."
    install_pathogen

    echo
    echo "Copying profile from working directory..."
    find "$PWD/dotfiles" -type f | xargs -I {} cp -v {} $HOME
    cp -r scripts "$HOME"
    mkdir -pv "$HOME/.ssh/controlmasters"
    cp -v ssh/* "$HOME/.ssh"

    echo
    echo "Creating toolchain and development directories..."
    mkdir -pv "$(go env GOPATH)/bin"
    mkdir -pv "$HOME/projects"

    echo
    echo "Done. Log out and back in to use zsh"
    echo "If prompt symbols are not displaying, ensure $NF_FONT_FAMILY is set as your terminal font and/or run p10k configure"
}

install_linux_nerd_font () {
    # Installs a Nerd Font to working dir (typically .local/share/fonts)
    # Args:
    # - $1: Font family name
    # Env vars:
    # - NF_RELEASE

    font_archive="$1.tar.xz"
    wget -P . "https://github.com/ryanoasis/nerd-fonts/releases/download/$NF_RELEASE/$font_archive"
    tar -xf "$font_archive"
    rm "$font_archive"
}

install_linux_listed_nerd_fonts () {
    prev_pwd="$PWD"
    font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    cd "$font_dir"

    marker_file=./nerd_font_version.txt
    # Check if we need to re-download the fonts
    if grep -qF "NF_FONT_FAMILY=$NF_FONT_FAMILY" "$marker_file" && \
        grep -qF "NF_RELEASE=$NF_RELEASE" "$marker_file"; then
        echo "Fonts are at latest version ($NF_RELEASE), not re-downloading"
        cd "$prev_pwd"
        return
    fi

    # download and extract all font families
    IFS=', ' read -r -a font_families <<< "$NF_FONT_FAMILY"
    for font in "${font_families[@]}"; do
        install_linux_nerd_font "$font"
    done
    # refresh font cache for this dir
    fc-cache -fv .
    # clean up extraneous files
    rm -f LICENCE.txt LICENSE.txt README.md
    # add a marker to avoid redundant downloads
    echo "NF_FONT_FAMILY=$NF_FONT_FAMILY" > nerd_font_version.txt
    echo "NF_RELEASE=$NF_RELEASE" >> nerd_font_version.txt
    # reset wd
    cd "$prev_pwd"
}

install_nerd_fonts () {
    if [[ $(uname -s) == "Darwin" ]]; then
      brew install font-hack-nerd-font
    else
      install_linux_listed_nerd_fonts
    fi
}

checkout_latest () {
    # destructively updates a shallow clone of a git repo
    # args:
    # - git repo to clone
    # - destination dir (absolute path)

    if [ -d "$2" ]; then
        # Git doesn't print what repo you're pulling. Make the message more informative.
        echo "Pulling updates for $2..."
        git pull
        return
    fi

    # Treeless clones only fetch reachable commit history and data at HEAD.
    # These allow for cheaper fetches than the older "shallow clone" feature.
    git clone --filter=tree:0 $1 "$2"
}

checkout_latest_zsh () {
    # destructively updates a zsh custom asset (plugin, theme)
    # args:
    # - git repo to clone
    # - destination dir relative to $ZSH_CUSTOM

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    DST="$ZSH_CUSTOM/$2"

    checkout_latest $1 "$DST"
}

install_pathogen () {
    # installs the pathogen plugin manager plus manually-added Vim plugins.
    if [ -f "$HOME/.vim/autoload/pathogen.vim" ]; then
        echo "Pathogen is already installed. Installing plugins..."
    else
        checkout_latest https://github.com/tpope/vim-pathogen.git "$HOME/.vim/vim-pathogen"
        mkdir -pv ~/.vim/autoload ~/.vim/bundle
        ln -vs "$HOME/.vim/vim-pathogen/autoload/pathogen.vim" "$HOME/.vim/autoload/pathogen.vim"
    fi
    checkout_latest https://github.com/ntpeters/vim-better-whitespace.git "$HOME/.vim/bundle/vim-better-whitespace"
}

main
