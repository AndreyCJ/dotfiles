export ZSH="$HOME/.oh-my-zsh"
export PATH="/opt/homebrew/bin:$PATH"
# export PATH="$HOME/Dotfiles/bin:$PATH"
export PATH="$(go env GOPATH)/bin:$PATH"

ZSH_THEME="geoffgarside"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(
  git
  macos
  fzf
)

source $ZSH/oh-my-zsh.sh

# Bindings
# bindkey -r '^R'

# Aliases
alias reload="source ~/.zshrc"
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"

alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"
alias c="clear"

# Load personal environment variables
if [[ -f "$HOME/Dotfiles/.env" ]]; then
    source "$HOME/Dotfiles/.env"
fi

# modern ls
alias ls="eza"
# detailed list
alias ll="eza -lah --group-directories-first"
# tree view
alias lt="eza --tree --level=2 --icons"
# git status in files
alias lg="eza -lah --git"

setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS

# Brew plugins 
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(mise activate zsh)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
