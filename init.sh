#!/usr/bin/env bash

function install_pkgs() {
  sudo apt-get update && sudo apt-get dist-upgrade -y
  sudo apt-get install -y ripgrep xsel
}

function install_tmux() {
  yes | sudo apt-get remove --purge tmux
  sudo apt-get install -y libevent-dev ncurses-dev build-essential bison pkg-config
  curl -LsO https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz
  tar -zxf tmux-3.3a.tar.gz
  cd tmux-3.3a || exit 1
  ./configure || exit 1
  make && sudo make install
  [ -d /home/user/.config/tmux ] && rm -rf /home/user/.config/tmux
  git clone https://github.com/reaper8055/tmux-config /home/user/.config/tmux
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
  rm /home/user/zshrc_old_*
  mv /home/user/.zshrc /home/user/zshrc_old_"$(date +%s)"
  curl -s https://raw.githubusercontent.com/reaper8055/devpod/main/zshrc > $HOME/.zshrc
  builtin source $HOME/.zshrc
  yes | zap clean
}

function install_nerd_fonts() {
  VERSION="v3.0.2"
  FONTS=("FiraCode" "FiraMono" "Hack" "Inconsolata" "NerdFontsSymbolsOnly" "JetBrainsMono")
  DIR="nerd-fonts-tmp"
  mkdir -p ./$DIR

  for FONT in "${FONTS[@]}"; do
    URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/${FONT}.zip"
    wget -P $DIR $URL -q --show-progress
  done

  for zipFile in $(ls ./nerd-fonts-tmp/*.zip); do
    baseName=$(basename -- "$zipFile")
    # extension="${filename##*.}"
    fontDirName="${baseName%.*}"
    [ ! -d "/usr/share/fonts/$fontDirName" ] && sudo mkdir -p /usr/share/fonts/$fontDirName
    sudo unzip $zipFile -d /usr/share/fonts/$fontDirName
    [ ! -d "$HOME/.local/share/fonts/$fontDirName" ] && mkdir -p $HOME/.local/share/fonts/$fontDirName
    unzip -d $zipFile -d $HOME/.local/share/fonts/$fontDirName
  done

  fc-cache -fv
  sudo fc-cache -fv
}

function cleanup() {
  cd /home/user
  yes | rm tmux-3.3a.tar.gz
  yes | rm -rf tmux-3.3a
}

install_pkgs
install_eza
install_fzf
install_starship
install_nvim
install_zap
install_tmux
install_nerd_fonts
init_zshrc
cleanup
