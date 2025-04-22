# PATH

export PYENV_ROOT="$HOME/.pyenv"

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.go/bin
export PATH=$PATH:PYENV_ROOT/bin
export GOPATH=$HOME/.go

if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
       Hyprland 
fi
