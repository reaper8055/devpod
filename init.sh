#!/usr/bin/env bash

sudo apt update && sudo apt dist-upgrade -y

function install_eza() {
  [ -f "$(which eza)" ] && return 0
  sudo apt update
  sudo apt install -y gpg
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update
  sudo apt install -y eza
}

function install_os_deps() {
  [ -f "$(which fzf)" ] && return 0
  sudo apt install fzf ripgrep
}

function install_nvim() {
  sudo apt purge neovim
  sudo apt install ninja-build gettext cmake unzip curl
  [ -d /home/user/neovim ] && rm -rf /home/user/neovim
  git clone https://github.com/neovim/neovim
  cd neovim || exit 1
  git checkout stable
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  cd /home/user/ || exit 1
  [ -d /home/user/neovim ] && rm -rf /home/user/neovim
  git clone https://github.com/reaper8055/nvim-config /home/user/.config/nvim/
}

function install_starship() {
  [ -f "$(which starship)" ] && return 0
  curl -sS https://starship.rs/install.sh | sh
}

function init_starship() {
  git clone https://github.com/reaper8055/starship-config /home/user/.config/starship/
}

function init_zshrc_config() {
zap version || zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
cat > /home/user/jsahu2_zshrc <<EOF
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && \\
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

#default editor
export EDITOR=nvim

# Plugins
plug "hlissner/zsh-autopair"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "jeffreytse/zsh-vi-mode"
plug "zap-zsh/supercharge"
plug "zap-zsh/exa" # this plugin needs to be after zap-zsh/supercharge as per https://github.com/zap-zsh/exa/issues/3
plug "Aloxaf/fzf-tab"
plug "zap-zsh/fzf"
plug "lljbash/zsh-renew-tmux-env"

# fzf_init
function fzf_init() {
  [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && \\
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  [ -f /usr/share/doc/fzf/examples/completion.zsh ] && \\
    source /usr/share/doc/fzf/examples/completion.zsh
}
function autosuggestions_init() {
  [ -f "$HOME/.local/share/zap/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \\
    source "$HOME/.local/share/zap/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
}
function autopair_init() {
  [ -f "$HOME/.local/share/zap/plugins/zsh-autopair/autopair.zsh" ] && \\
    source "$HOME/.local/share/zap/plugins/zsh-autopair/autopair.zsh"
}
zvm_after_init_commands+=(
  fzf_init
  autopair_init
  autosuggestions_init
)

# starship.rs
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
eval "$(starship init zsh)"

# fzf
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
 --color=fg:#cbccc6,bg:#1f2430,hl:#707a8c
 --color=fg+:#707a8c,bg+:#191e2a,hl+:#ffcc66
 --color=info:#73d0ff,prompt:#707a8c,pointer:#cbccc6
 --color=marker:#73d0ff,spinner:#73d0ff,header:#d4bfff
 --border'
EOF

cmp --silent /home/user/jsahu2_zshrc /home/user/.zshrc || mv /home/user/jsahu2_zshrc /home/user/.zshrc
}

install_eza
install_nvim
install_os_deps
install_starship
init_starship
init_zshrc_config
