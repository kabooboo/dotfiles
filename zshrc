# Path to your Oh My Zsh installation.
export LC_ALL=fr_FR.UTF-8

export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# init stuff

# auto-complete stuff
source <(yak completion zsh)
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
source "$(gcloud info --format='value(installation.sdk_root)')/path.zsh.inc"
source "$(gcloud info --format='value(installation.sdk_root)')/completion.zsh.inc"
source <(fzf --zsh)
source <(kubectl completion zsh)
source <(k completion zsh)
source <(k9s completion zsh)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/gcreti/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/gcreti/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/gcreti/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/gcreti/Downloads/google-cloud-sdk/completion.zsh.inc'; fi


eval "$(starship init zsh)"

# aliases
alias python="uv run python"
alias ktx="kubectl ctx"
alias kns="kubectl ns"
alias k=kubectl
alias dc="docker compose"
alias d=docker
alias copy=pbcopy

# public variables
export EDITOR="nano"

# functions
yoink() {
  # Display help if no arguments provided
  if [[ $# -eq 0 ]]; then
    echo "Usage: yoink <source> [target_name]"
    echo "  <source>     : File or folder to move to ~/.dotfiles"
    echo "  [target_name]: Name to use in ~/.dotfiles (optional)"
    echo "                 If not provided, basename of source will be used"
    return 1
  fi

  local source="$1"
  local dotfiles_dir="$HOME/.dotfiles"

  # Check if source exists
  if [[ ! -e "$source" ]]; then
    echo "Error: Source '$source' does not exist."
    return 1
  fi

  # Create .dotfiles directory if it doesn't exist
  if [[ ! -d "$dotfiles_dir" ]]; then
    mkdir -p "$dotfiles_dir"
    echo "Created directory: $dotfiles_dir"
  fi

  # Determine target name
  local target_name
  if [[ -n "$2" ]]; then
    target_name="$2"
  else
    # Extract filename from path and remove leading dots: ${source:t} gets the basename, ##*. strips everything up to the last dot
    target_name=${${source:t}##*.}
  fi

  local target_path="$dotfiles_dir/$target_name"

  # Check if target already exists
  if [[ -e "$target_path" ]]; then
    echo "Error: Target '$target_path' already exists."
    return 1
  fi

  # Move the source to target
  mv "$source" "$target_path"

  if [[ $? -eq 0 ]]; then
    echo "Successfully moved '$source' to '$target_path'"
  else
    echo "Error: Failed to move '$source' to '$target_path'"
    return 1
  fi

  $HOME/.dotfiles/install

}

aws-profile() {
  eval $(grep -E '^\[profile [a-zA-Z][a-zA-Z_-]+\]' "${HOME}/.aws/config" | awk -F"[][]" '{print $2}' |while read a p ; do echo "export AWS_PROFILE=$p" ; done  |
  fzf +s --tac )
}

# A function to visually change directories with lstr
lcd() {
    # Run lstr and capture the selected path into a variable.
    # The TUI will draw on stderr, and the final path will be on stdout.
    local selected_dir
    selected_dir="$(lstr interactive -gG --icons -s -p)"

    # If the user selected a path (and didn't just quit), `cd` into it.
    # Check if the selection is a directory.
    if [[ -n "$selected_dir" && -d "$selected_dir" ]]; then
        cd "$selected_dir"
    fi
}
