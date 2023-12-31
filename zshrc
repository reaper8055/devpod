[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && \
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# tmux backspace fix
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

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

# Aliases
alias .="builtin source $HOME/.zshrc"
alias zshrc="nvim $HOME/.zshrc"

function update-zshrc() {
  curl -s https://raw.githubusercontent.com/reaper8055/devpod/main/zshrc > $HOME/.zshrc
  builtin source $HOME/.zshrc
}

function autosuggestions_init() {
  [ -f "$HOME/.local/share/zap/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$HOME/.local/share/zap/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
}
function autopair_init() {
  [ -f "$HOME/.local/share/zap/plugins/zsh-autopair/autopair.zsh" ] && \
    source "$HOME/.local/share/zap/plugins/zsh-autopair/autopair.zsh"
}
zvm_after_init_commands+=(
  autopair_init
  autosuggestions_init
)

# starship.rs
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# fzf
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=dark
  --color=hl:#5fff87,fg:-1,bg:-1,fg+:-1,bg+:-1,hl+:#ffaf5f
  --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
  --border'

# fzf-tab config
zstyle ':fzf-tab:*' fzf-min-height 10

[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
