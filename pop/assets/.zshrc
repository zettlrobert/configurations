[ -f "$HOME/.local/share/zap/zap.zsh" ] && source "$HOME/.local/share/zap/zap.zsh"

# zsh plugins
plug "zap-zsh/supercharge"
plug "zap-zsh/fzf"
plug "Aloxaf/fzf-tab"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"

# Example install completion
plug "esc/conda-zsh-completion"

# My Prompt
plug "zettlrobert/simple-prompt"

# Defaults
export EDITOR=code

# User configuration
alias bat='batcat'
alias lexa='exa --icons --long -a --group --header --bytes'
alias ll=lexa

# Copy current path to clipboard (xclip) required
alias ypp='pwd | xclip -selection clipboard'

# Fzf with preview
alias fzfp="fzf --preview 'bat --color=always {}'"

######################################################################################################################
# Git Aliases
######################################################################################################################
alias pgl='git log --pretty=oneline --graph --decorate --all'
alias gdiff='git diff | batcat'

#######################################################################################################################
# NVIM - NODE
#######################################################################################################################
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
