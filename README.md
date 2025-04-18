# Profile

This repo contains my configured profile dotfiles, plus setup scripts.

## Supported Environments

- Debian-based Linux distros (Ubuntu and Mint have been tested)
- MacOS

## Installing

From repo root, run the following commands.

On Linux:

```sh
sudo ./install-toolchain.sh
./setup-profile.sh
```

On Mac:

```sh
./install-toolchain.sh
./setup-profile.sh
```

## Configured Tools

### Toolchains

- Go: installs and adds to path

### Shell

- Installs and `chsh` to Zsh
- Uses [Oh my zsh](https://ohmyz.sh/)
- Sets the theme to [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- Installs a [Nerd Font](https://github.com/ryanoasis/nerd-fonts) to show the nifty
  symbols used by P10k

### Configs

- **Git** config with commonly-used aliases
- **Vim** config and a small number of plugins
