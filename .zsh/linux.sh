# -*- sh -*-
#
# Linux
#

if [ -z "$LANG" ] ; then
    export LANG=ja_JP.UTF-8
fi

# GNU ls
if [ -n "$TERM" ] ; then
    if [ -f ~/.dircolors ] ; then
        eval `dircolors -b ~/.dircolors`
    fi
    if [ -z "$LS_COLORS" ] ; then
        eval `dircolors -b`
    fi
    alias ls='ls -F --color'
    alias ll='ls -laF --color'
    alias la='ls -aF --color'
fi
