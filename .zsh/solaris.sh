# -*- sh -*-
#
# Solaris
#

if [ -z "$LANG" ] ; then
    if [`locale -a | grep -c ja_JP.UTF-8` >= 1 ] ; then
        export LANG=ja_JP.UTF-8
    else
        export LANG=ja
    fi
fi

# POSIX ls
alias ls='ls -F'
alias ll='ls -la'
alias la='ls -a'

export PATH="/usr/X11R6/bin:/usr/local/bin:/usr/ccs/bin:/bin:/usr/sbin:/sbin:${PATH}"
