#!/usr/bin/env bash

sudo apt-get update && sudo apt-get dist-upgrade -y

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

function install_os_deps() {
  [ -f "$(which fzf)" ] && return 0
  sudo apt-get install -y fzf ripgrep
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
  yes | curl -sS https://starship.rs/install.sh | sh
}

function init_starship() {
  git clone https://github.com/reaper8055/starship-config /home/user/.config/starship/
}

function init_zshrc_config() {
  yes | zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
  mv /home/user/.zshrc /home/user/zshrc_old_"$(date +%s)"
  curl -s https://raw.githubusercontent.com/reaper8055/devpod/main/zshrc > $HOME/.zshrc
}

install_eza
install_nvim
install_os_deps
install_starship
init_starship
init_zshrc_config
