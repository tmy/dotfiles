# -*- zsh -*-

export LC_TIME=C

# PATH
if [ -d "/usr/local/bin" ] ; then
    export PATH="/usr/local/bin:$PATH"
fi

local zsh_dir=$(cd "$(dirname "$0")"; pwd)
if [ -L "$zsh_dir" ] ; then
    zsh_dir=$(readlink "$zsh_dir")
fi
local dotfiles_bin=$(cd "$zsh_dir/../bin"; pwd)
export PATH="$dotfiles_bin:$PATH"

if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/bin/local" ] ; then
    export PATH="$HOME/bin/local:$PATH"
fi
if [ "${UID}" = "0" ] ; then
    export PATH="/usr/sbin:/sbin:$PATH"
    if [ -d "/usr/local/sbin" ] ; then
        export PATH="/usr/local/sbin:$PATH"
    fi
fi

# environment variables
export AUTHOR='Akinori Tomita'
