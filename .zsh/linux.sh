# -*- sh -*-
#
# Linux
#

if [ -z "$LANG" ] ; then
    export LANG=ja_JP.UTF-8
fi

# GNU ls
alias ls='ls -F --color'
alias ll='ls -laF --color'
alias la='ls -aF --color'
