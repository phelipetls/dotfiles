# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$PATH:$HOME/.local/bin"
fi

# Add local scripts folder into PATH
if [ -d "$HOME/scripts" ]; then
  export PATH="$PATH:$HOME/scripts/"
fi

# Add Android SDK related PATH
if [ -d "$HOME/Android/Sdk" ]; then
  export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
elif [ -d "$HOME/Library/Android/sdk" ]; then
  export ANDROID_SDK_ROOT="$HOME/Library/Android/Sdk"
fi

if [ -d "$ANDROID_SDK_ROOT" ]; then
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
  export PATH="$ANDROID_SDK_ROOT/emulator:$PATH"
  export PATH="$ANDROID_SDK_ROOT/tools:$PATH"
  export PATH="$ANDROID_SDK_ROOT/tools/bin:$PATH"
  export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
fi

# Add Android SDK related PATH
if [ -d "$HOME/android-studio/bin" ]; then
  export PATH="$PATH:$HOME/android-studio/bin"
fi

if [ -x "/usr/lib/jvm/java-11-openjdk-amd64" ]; then
  export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
fi

# Add n related variables
export N_PREFIX="$HOME/.n"

if [ -d "$N_PREFIX" ]; then
  export PATH="$N_PREFIX/bin:$PATH"
fi

# Add npm related PATH
NPM_PACKAGES="$HOME/.npm-packages"

if [ -d "$NPM_PACKAGES" ]; then
  export PATH="$PATH:$NPM_PACKAGES/bin"
  export MANPATH="$MANPATH:$NPM_PACKAGES/share/man"
fi

# Add Python related PATH
if [ -d "$HOME/.poetry" ]; then
  export PATH="$PATH:$HOME/.poetry/bin"
fi

# Add Go related PATH
export GOPATH="$HOME/go"

if [ -d "$GOPATH" ]; then
  export PATH="$PATH:$GOPATH/bin"
fi

if [ -d "/usr/local/go/bin" ]; then
  export PATH="$PATH:/usr/local/go/bin"
fi

# Add Rust related PATH
if [ -d "$HOME/.cargo/env" ]; then
  export PATH="$PATH:$HOME/.cargo/env"
fi

# Add git-toolbelt
if [ -d "$HOME/git-toolbelt" ]; then
  export PATH="$PATH:$HOME/git-toolbelt"
fi

# Add Homebrew
if [ -d "/opt/homebrew/bin" ]; then
  export PATH="$PATH:/opt/homebrew/bin"
fi

# Add pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Add LuaLS language PATH
export PATH="$PATH:$HOME/.local/LuaLS/bin"

function is_linux() {
  uname | grep -iq linux
}

function is_wsl() {
  uname -a | grep -iq microsoft
}

# Persist ssh session across shells in WSL
if is_wsl && keychain --quiet; then
  eval "$(keychain --quiet --eval id_rsa)"
fi

# Add default less options
# -F to quit automatically if the file is shorter than the screen
# -X to not clear the screen after quitting
# -R to show only color escape sequences in raw form
# -M to show a more verbose prompt
export LESS="FXRM"

alias r='ranger'

if is_linux; then
  alias ls='ls -A --color=auto --group-directories-first --time-style=long-iso --human-readable -v'
  alias ll='ls -l'
fi

if is_linux; then
  if is_wsl; then
    alias open='wslview'
  else
    alias open='xdg-open'
  fi
fi

alias cat='bat'

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
  fi
fi
