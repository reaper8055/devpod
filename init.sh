#!/usr/bin/env bash

function install_pkgs() {
  sudo apt-get update && sudo apt-get dist-upgrade -y
  sudo apt-get install -y ripgrep
}

function install_tmux() {
  yes | sudo apt-get remove --purge tmux
  sudo apt-get install -y libevent-dev ncurses-dev build-essential bison pkg-config
  curl -LsO https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz
  tar -zxf tmux-3.3a.tar.gz
  cd tmux-3.3a || exit 1
  ./configure || exit 1
  make && sudo make install
}

function install_eza() {
  [ -f "$(which eza)" ] && return 0
  sudo apt-get update
  sudo apt-get install -y gpg
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt-get update
  sudo apt-get install -y eza
}

function install_fzf() {
  yes | sudo apt-get remove --purge fzf
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
  yes | $HOME/.fzf/install
}

function install_nvim() {
  yes | sudo apt-get remove --purge neovim
  sudo apt-get install -y ninja-build gettext cmake unzip curl
  [ -d /home/user/neovim ] && rm -rf /home/user/neovim
  git clone https://github.com/neovim/neovim
  cd neovim || exit 1
  git checkout stable
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  cd /home/user/ || exit 1
  [ -d /home/user/neovim ] && rm -rf /home/user/neovim
  [ ! -d /home/user/.config/nvim ] && git clone https://github.com/reaper8055/nvim-config /home/user/.config/nvim/
}

function install_starship() {
  [ -f "$(which starship)" ] && return 0
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  git clone https://github.com/reaper8055/starship-config /home/user/.config/starship/
}

function install_zap() {
  yes | zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
}

function init_zshrc() {
  mv /home/user/.zshrc /home/user/zshrc_old_"$(date +%s)"
  curl -s https://raw.githubusercontent.com/reaper8055/devpod/main/zshrc > $HOME/.zshrc
  builtin source $HOME/.zshrc
  yes | zap clean
}

install_pkgs
install_eza
install_fzf
install_starship
install_nvim
install_zap
install_tmux
init_zshrc
