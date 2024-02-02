#!/usr/bin/env bash

function install_pkgs() {
  date +%Y-%m-%d > "$HOME/${FUNCNAME}_last_run.txt"
  sudo apt-get update && sudo apt-get dist-upgrade -y
  sudo apt-get install -y xsel fd-find
}

function install_stylua() {
  [ -f "$(which stylua)" ] && return 0
  wget -q https://github.com/JohnnyMorganz/StyLua/releases/download/v0.19.1/stylua-linux-x86_64.zip
  sudo unzip -d stylua-linux-x86_64.zip /usr/local/bin && return 0
}

function install_rg() {
  [ -f "$(which rg)" ] && return 0
  cd /home/user || return 1
  RG_VERSION="$(rg --version | awk 'NR==1 {print $2}')"
  [[ "$RG_VERSION" = "13.0.0" ]] && return 0
  curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
  sudo apt install ./ripgrep_13.0.0_amd64.deb && rm "$HOME/ripgrep_13.0.0_amd64.deb"
}

function install_tmux() {
  [[ "$(tmux -V)" = "tmux 3.3a" ]] && return 0
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
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt-get update
  sudo apt-get install -y eza
}

function install_fzf() {
  FZF_VERSION="$(fzf --version | awk '{print $1}')"
  [[ "$FZF_VERSION" = "0.44.1" ]] && return 0
  yes | sudo apt-get remove --purge fzf
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  yes | "$HOME/.fzf/install"
}

function install_nvim() {
  NVIM_VERSION="$(nvim -v | awk 'NR==1 {print $2}')"
  [[ "$NVIM_VERSION" = "v0.9.5" ]] && return 0
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
  [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && return 0
  yes | zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
}

function init_zshrc() {
  rm /home/user/zshrc_old_*
  mv /home/user/.zshrc /home/user/zshrc_old_"$(date +%s)"
  curl -s https://raw.githubusercontent.com/reaper8055/devpod/main/zshrc > "$HOME/.zshrc"
  builtin source "$HOME/.zshrc"
  yes | zap clean
}

function init_envrc_local() {
  if [[ $(hostname) = "jsahu2-go" ]]; then
  [ -f "$HOME/go-code/.envrc.local" ] && mv "$HOME/go-code/.envrc.local" "$HOME/envrc.local_$(date +%s).bak"
  curl -s https://raw.githubusercontent.com/reaper8055/devpod/main/envrc.local > "$HOME/go-code/.envrc.local"
  fi
}

function install_nerd_fonts() {
  VERSION="v3.1.1"
  FONTS=("FiraCode" "FiraMono" "Hack" "Inconsolata" "NerdFontsSymbolsOnly" "JetBrainsMono")
  DIR="nerd-fonts-tmp"
  mkdir "$HOME/$DIR"

  for FONT in "${FONTS[@]}"; do
    URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/${FONT}.zip"
    wget -P "$DIR" "$URL" -q
  done

  for zipFile in ./nerd-fonts-tmp/*.zip; do
    baseName=$(basename -- "$zipFile")
    # extension="${filename##*.}"
    fontDirName="${baseName%.*}"
    [ -d "/usr/share/fonts/$fontDirName" ] && sudo rm -rf "/usr/share/fonts/$fontDirName"
    [ ! -d "/usr/share/fonts/$fontDirName" ] && sudo mkdir -p "/usr/share/fonts/$fontDirName"
    sudo unzip "$zipFile" -d "/usr/share/fonts/$fontDirName"
    [ -d "$HOME/.local/share/fonts/$fontDirName" ] && rm -rf "$HOME/.local/share/fonts/$fontDirName"
    [ ! -d "$HOME/.local/share/fonts/$fontDirName" ] && mkdir -p "$HOME/.local/share/fonts/$fontDirName"
    unzip "$zipFile" -d "$HOME/.local/share/fonts/$fontDirName"
  done

  fc-cache -fv
  sudo fc-cache -fv
}

function update-initsh() {
  curl -sSL https://raw.githubusercontent.com/reaper8055/devpod/main/init.sh > "$HOME/init.sh"
}

function cleanup() {
  find /home/user -name "envrc.*.bak" -type f -delete
  find /home/user -name "tmux-3.3a.tar.gz" -type f -delete
  find /home/user -name "stylua-linux-x86_64.zip*" -type f -delete
  find /home/user -name "nerd-fonts-tmp" -type d -exec rm -rf {} +
}

if [ -f "$HOME/install_pkgs_last_run.txt" ]; then
  LAST_RUN=$(cat "$HOME/install_pkgs_last_run.txt")
  THREE_DAYS_AGO=$(date -d '3 days ago' + %Y%m%d)
  if [ "$(date -d "$LAST_RUN" +%Y%m%d)" -ge "$THREE_DAYS_AGO" ]; then
    print "function has run in last 3 days... skipping\n"
  else
    install_pkgs
  fi
else
  install_pkgs
fi

install_rg
install_stylua
install_eza
install_fzf
install_starship
install_nvim
install_zap
install_tmux
install_nerd_fonts
init_envrc_local
init_zshrc
cleanup
