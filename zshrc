# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="spaceship"
SPACESHIP_KUBECTL_SHOW=true
# SPACESHIP_KUBECTL_VERSION_SHOW=false

autoload -Uz compinit; compinit

autoload -U select-word-style; select-word-style bash


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

# OLD ZSH CONFIG FOR HISTORY
HIST_STAMPS="yyyy-mm-dd"
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt appendhistory
setopt INC_APPEND_HISTORY
setopt APPEND_HISTORY        # append to history file (Default)
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.
HISTORY_IGNORE="(ls|cd|pwd|exit|cd)*"
## New history search config
export MCFLY_FUZZY=1
export MCFLY_RESULTS=20
export MCFLY_DELETE_WITHOUT_CONFIRM=true
export MCFLY_RESULTS_SORT=LAST_RUN



# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
zstyle ':autocomplete:*' default-context history-incremental-search-backward
zstyle ':z4h:autosuggestions' forward-char 'accept'

plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

## Aliases
alias k=kubectl
alias ktx=kubectx
alias kns=kubens
alias dc="docker compose"
alias d=docker
alias dk="docker kill $(docker ps -q)"
alias drm="docker rm $(docker ps -aq)"
alias copy="xclip -selection clipboard"
alias bctl=bluetoothctl
alias giphon="/usr/bin/env python3 -m giphon"
alias deploy='eval glab ci run -b $(git rev-parse --abbrev-ref HEAD) --variables-env deploy_only:t'
alias who-did-it='baraddur scan -j who-did-it -w 30'
alias code='code --password-store=gnome-libsecret'
alias bfg='java -jar $HOME/.local/jar/bfg.jar'
alias ktest="kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot"

## Completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source <(kubectl completion zsh)
source <(k completion zsh)
source <(glab completion -s zsh 2&> /dev/null)
compdef _glab glab
source <(stern --completion=zsh)

## Functions
# Open Heka platform as an admin
function heka-open-admin() {
  protocol=$(kubectl $([ ! -z "$2" ] && echo "--context heka-asterix-$2") get secrets project-environment $([ ! -z "$1" ] && echo "--namespace heka-$1") -o yaml | yq '.data.PROJECT_CONFIG' | base64 -d | yq '.project.protocol')
  hostname=$(kubectl $([ ! -z "$2" ] && echo "--context heka-asterix-$2") get secrets project-environment $([ ! -z "$1" ] && echo "--namespace heka-$1") -o yaml | yq '.data.PROJECT_CONFIG' | base64 -d | yq '.project.hostname')
  prefix_path=$(kubectl $([ ! -z "$2" ] && echo "--context heka-asterix-$2") get secrets project-environment $([ ! -z "$1" ] && echo "--namespace heka-$1") -o yaml | yq '.data.PROJECT_CONFIG' | base64 -d | yq '.network."prefix-path"')
  kubectl $([ ! -z "$2" ] && echo "--context heka-asterix-$2") get secrets project-environment $([ ! -z "$1" ] && echo "--namespace heka-$1") -o yaml | yq '.data.PROJECT_CONFIG' | base64 -d | yq '.authentication.inhouse.administrator.password' | copy
  echo "${protocol}://${hostname}${prefix_path}admin"
  /opt/google/chrome/chrome "${protocol}://${hostname}${prefix_path}admin"
}
function tard {
    tar -czvf ./$1.tar.gz $1
}

# Archive buckets for heka platforms
function archive-buckets() {
  (gsutil label get gs://heka-$2-$1-backups | grep -q archived_since) && echo "Bucket is already labelled" || gsutil label ch -l archived_since:$(date +%s) gs://heka-$2-$1-backups
  (gsutil label get gs://heka-$2-$1-storage | grep -q archived_since) && echo "Bucket is already labelled" || gsutil label ch -l archived_since:$(date +%s) gs://heka-$2-$1-storage

  echo -e "\033[1;36mlatest backups by date:"
  gsutil ls -lah gs://heka-$2-$1-backups/ | sort -k 2
  echo -e "\033[0m\n\n"

  echo "Changing default storage class"
  gsutil defstorageclass set ARCHIVE gs://heka-$2-$1-backups
  gsutil defstorageclass set ARCHIVE gs://heka-$2-$1-storage

  echo "Archiving all files..."
  gsutil -m rewrite -Ors ARCHIVE "gs://heka-$2-$1-storage/"
  gsutil -m rewrite -Ors ARCHIVE "gs://heka-$2-$1-backups/"

  echo "Removing users from $2-$1-backups Bucket's permission..."
  users=$(gsutil iam get gs://heka-$2-$1-backups  | jq -r '.bindings[].members[] ' | sort | uniq | grep "user:")
  echo "${users}"
  echo "${users}" | xargs -r -I % gsutil iam ch -d % gs://heka-$2-$1-backups
  echo "Removing users from $2-$1-storage Bucket's permission..."
  users=$(gsutil iam get gs://heka-$2-$1-storage  | jq -r '.bindings[].members[] ' | sort | uniq | grep "user:")
  echo "${users}"
  echo "${users}" | xargs -r -I % gsutil iam ch -d % gs://heka-$2-$1-storage

}

function edit_state {
  PROJECT_ID=${2:-:id}
  TEMP=$(mktemp)
  glab api "/projects/${PROJECT_ID}/terraform/state/$1" > $TEMP
  sh -c "$EDITOR $TEMP"
  glab api -X POST --input $TEMP "/projects/${PROJECT_ID}/terraform/state/$1"
  rm $TEMP
}

function rollback_state {

    CURRENT_VERSION=$(curl -ssX GET -H 'accept:application/json' -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_URL}/api/v4/projects/$1/terraform/state/env-$3" | jq -r '.serial')
    curl -ssX GET -H 'accept:application/json' -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_URL}/api/v4/projects/$1/terraform/state/env-$3/versions/$2" | jq ".serial=$((CURRENT_VERSION + 1))" > /tmp/rbstt
    curl -X POST -H 'content-type:application/json' -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
      --data @/tmp/rbstt "${GITLAB_URL}/api/v4/projects/$1/terraform/state/env-$3"
}

function use_common_cluster {
  gcloud beta compute ssh common-tooling-bastion \
    --project=sia-devops \
    --zone=europe-west1-b \
    -- -4 -L8888:localhost:8888 -N -q -f &
  export HTTPS_PROXY=localhost:8888
}

function disable_common_cluster {
  unset HTTPS_PROXY
  netstat -lnpt | grep 8888 | awk '{print $7}' | grep -o '[0-9]\+' | sort -u | xargs sudo kill
}

function tfswitch {
  /usr/local/bin/tfswitch -b $HOME/.bin/terraform "$@"
}

function bridge {
  nohup gcloud compute start-iap-tunnel  --quiet \
    shared-platforms-bastion 5432 \
    --project heka-asterix-$1 \
    --zone europe-west1-b \
    --local-host-port=0.0.0.0:5432 & disown
}

function update_cost_center {
  gsutil cp $HOME/Documents/finops/project_cost_center.csv gs://finops_constants_ingest/project_cost_center.csv
}

function totp {
  keepassxc-cli clip --totp $HOME/.secrets/PasswordsPerso.kdbx $1
}

function color_grep {
  COLOR=$1
  shift;
  GREP_COLORS="mt=${COLOR}" grep "$@"
}

function carbonyl {
  docker run -ti fathyb/carbonyl "$@"
}

function mount_disk {
  sudo cryptsetup open /dev/sda external
  sudo mount /dev/mapper/external /mnt/external
}

function unmount_disk {
  sudo umount /mnt/external
  sudo cryptsetup close external
}

time_buffered_echo () {
   delay=$1
   while read line; do
       printf "%d %s\n" "$(date +%s)" "$line"
   done | while read ts line; do
       now=$(date +%s)
       if (( now - ts < delay)); then
           sleep $(( now - ts ))
       fi
       echo -e "$line"
   done
}


function openai {

curl -N "https://api.openai.com/v1/chat/completions" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" -d '{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "system",
      "content": [
        {
          "type": "text",
          "text": "You are a CLI terminal assistant."
        }
      ]
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "'"$1"'"
        }
      ]
    }

  ],
  "temperature": 0.1,
  "max_tokens": 1000,
  "top_p": 1,
  "frequency_penalty": 0,
  "presence_penalty": 0,
  "stream": true
}' \
 | sed -u 's%data: %%g' \
 | jq --unbuffered -jr '.choices[0].delta.content // empty' 2> /dev/null \
 | time_buffered_echo 1
}

## Exports

export EDITOR="nano"
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export MODULAR_HOME="$HOME/.modular"
export PATH="$PATH:/usr/local/go/bin:$HOME/.go/bin:$HOME/.local/bin:$HOME/.bin:$HOME/.cargo/bin:$MODULAR_HOME/pkg/packages.modular.com_mojo/bin:$HOME/.pyenv/bin:${KREW_ROOT:-$HOME/.krew}/bin"
export GOROOT=$HOME/.go
export NVM_DIR="$HOME/.nvm"

### Some colors for grep
export RED="01;31"
export GREEN="01;32"
export YELLOW="01;33"
export BLUE="01;34"
export TEAL="01;36"


## Sources
source ~/.secrets/credentials.sh
source ~/.secrets/uris.sh

# NVM
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(starship init zsh)"
eval "$(mcfly init zsh)"

zstyle ':completion:*' menu select
fpath+=~/.zfunc

# bun completions
[ -s "/home/gcreti/.oh-my-zsh/completions/_bun" ] && source "/home/gcreti/.oh-my-zsh/completions/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
. "$HOME/.cargo/env"

# grit
export GRIT_INSTALL="$HOME/.grit"
export PATH="$GRIT_INSTALL/bin:$PATH"

# glab
export GH_NO_UPDATE_NOTIFIER=1

# golang
export GOPATH="${HOME}/.go"
export GOROOT="/usr/local/go"
