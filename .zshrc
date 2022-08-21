# Set up the prompt
autoload -Uz promptinit
promptinit

if [ -f /usr/lib/git-core/git-sh-prompt ]; then
  source /usr/lib/git-core/git-sh-prompt
elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  source /usr/share/git-core/contrib/completion/git-prompt.sh
elif [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh ]; then
  source /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
fi

setopt prompt_subst

export PS1='\
%B%F{green}%n %b%f\
%B%F{yellow}@ %b%f\
%B%F{blue}%~ %b%f\
%B%F{yellow}$(__git_ps1 "(%s) ")%b%f\
%B%F{green}%(1j.* .)%b%f\
%B%F{%(?.black.red)}%# %b%f\
'

export EDITOR=nvim

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Configure history
setopt histignorealldups sharehistory

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
HISTORY_IGNORE="(clear|bg|fg|cd|cd -|cd ..|exit|date|w|ls|l|ll|lll)"

# Use modern completion system
autoload -Uz compinit
compinit

# Configure completion. See https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Control-Functions
zstyle ':completion:*' completer _expand _complete _correct _approximate

# Match case insensitively
# Also match "c.s.u" with "comp.source.unix"
# See https://zsh.sourceforge.io/Doc/Release/Completion-Widgets.html#Completion-Matching-Control
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'

# Place items under their group description
zstyle ':completion:*' group-name ''

# Highlight currently selected item in completion list
zstyle ':completion:*' menu yes select

# Show these messages when completion list is too long
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# Show description for items in completion list
zstyle ':completion:*' verbose true

# Color kill command output
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Remove package-lock.json from completion items
zstyle ':completion:*' ignored-patterns package-lock.json

# Colored ls output
if uname | grep -iq darwin; then
  export CLICOLOR=1
  zstyle ':completion:*:default' list-colors ''
else
  eval "$(dircolors -b)"
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
fi

# Use pip installed Python packages in macOS
if [ -d "$HOME/Library/Python/3.8/bin" ]; then
  export PATH="$PATH:$HOME/Library/Python/3.8/bin"
fi

# Do not use colors in other commands
zstyle ':completion:*' list-colors ''

# Some obscure setting I'm not removing
zstyle ':completion:*' use-compctl false

# Set up zsh so that terminfo is not empty when configuring Zsh Line Editor
# (ZSE). See https://gist.github.com/AbigailBuccaneer/1fcf12edf13e03e45030
typeset -A key

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
function zle-line-init () {
  echoti smkx
}

function zle-line-finish () {
  echoti rmkx
}

zle -N zle-line-init
zle -N zle-line-finish

# Enable history search with up and down arrows
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

if [[ -n "${key[Up]}" ]]; then
  bindkey -- "${key[Up]}" up-line-or-beginning-search
fi

if [[ -n "${key[Down]}" ]]; then
  bindkey -- "${key[Down]}" down-line-or-beginning-search
fi

if [[ -n "${key[Control-Left]}"  ]]; then
  bindkey -- "${key[Control-Left]}" backward-word
fi

if [[ -n "${key[Control-Right]}" ]]; then
  bindkey -- "${key[Control-Right]}" forward-word
fi

# Add Shift+Tab to move through completion menu backwards
if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete
fi

# Enable Ctrl-X + Ctrl-E to edit command in $EDITOR
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

export _JAVA_AWT_WM_NONREPARENTING=1 # Needed for Android Studio to work in DWM

# Configure fzf

# file generated by fzf install script
export PATH="$HOME/.fzf/bin:$PATH"
source "$HOME/.fzf/shell/completion.zsh"
source "$HOME/.fzf/shell/key-bindings.zsh"

export FZF_DEFAULT_COMMAND='rg --files --hidden --color=never'
export FZF_ALT_C_COMMAND='fd --color=never --type d'

function _fzf_compgen_path {
  rg --files --hidden --color=never
}

function _fzf_compgen_dir {
  fdfind --color=never --type d
}

# enable zsh-autosuggestions
source ~/zsh-autosuggestions/zsh-autosuggestions.zsh

source "$HOME/.profile"
