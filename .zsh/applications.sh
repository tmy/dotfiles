# -*- sh -*-

# CentOS の設定を上書き
umask 002

# Pressing "x" and enter exits.
alias x='exit'
# Quite handy, type "ff test.c" to find "test.c". 
# Keep in mind that there is also "locate test.c" whence -p is faster.
#alias ff='find . -name $*'
# Alias for "." and ".."
# Shows current directory
alias .='pwd'
# Goes back one directory
alias ..='cd ..'
alias ../='cd ../'
# Goes back two directories
alias ...='cd ../..'
alias .../='cd ../../'
# Goes to previous directory
#alias '-'='cd -'
# Goes to the root directory
alias '/'='cd /'

# sudo の後のコマンドでも alias が効くようにする謎設定
alias sudo='sudo '

autoload zmv
alias zmv='noglob zmv'

alias eng='env LC_ALL=C'

# MacPorts
if [ -d /opt/local ] ; then
    export PATH=/opt/local/bin:/opt/local/sbin:$PATH
    export MANPATH=/opt/local/man:$MANPATH
fi

# nkf
if [ `whence -p nkf` ] ; then
    if [ "${LANG}" = "ja_JP.UTF-8" ] ; then
        alias nkf='nkf -w'
    elif [ "${LANG}" = "ja_JP.eucJP" ] ; then
        alias nkf='nkf -e'
    fi
fi

if [ `whence -p nkf` ] ; then
    alias e2u='nkf -E -w'
    alias s2u='nkf -S -w'
    alias j2u='nkf -J -w'
    alias u2e='nkf -W -e'
    alias s2e='nkf -S -e'
    alias j2e='nkf -J -e'
elif [ `whence -p iconv` ] ; then
    alias e2u='iconv -f euc-jp -t utf-8'
    alias s2u='iconv -f shift_jis -t utf-8'
    alias j2u='iconv -f iso-2022-jp -t utf-8'
    alias u2e='iconv -f utf-8 -t euc-jp'
    alias s2e='iconv -f shift_jis -t euc-jp'
    alias j2e='iconv -f iso-2022-jp -t euc-jp'
fi

# less
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --RAW-CONTROL-CHARS --quit-if-one-screen'
if [ "${LANG}" = "ja_JP.UTF-8" ] ; then
    export LESSCHARSET='utf-8'
    export LESSUTFBINFMT='*n%lc'
fi
if [ `whence -p jless` ] ; then
    which jless
    alias less='jless'
fi

nless() { nl $* | less }

if [ `whence -p gnutar` ] ; then
    alias tar='gnutar'
fi

# vim
if [ `whence -p vim` ] ; then
    export EDITOR=vim
    alias vi=vim
    alias view='vim -R'
fi

# GNU grep
export GREP_OPTIONS='--color=auto'

alias gpg='eng gpg'

# Mac OS X
alias console='open -a Console'
alias calc='open -a Calculator'
alias emacs='env XMODIFIERS=@im=no emacs'

# GNU screen
alias s=screen
alias ss='screen ssh'

# dig
alias digq='dig +noall +answer'

# rvm
if [ -d "$HOME/.rvm/bin" ] ; then
    PATH=$PATH:$HOME/.rvm/bin
fi

# rbenv
if [ `whence -p rbenv` ] ; then
    eval "$(rbenv init - zsh)"
fi

# refe
if [ "${LANG}" = "ja_JP.UTF-8" ] ; then
    refe() { command refe $* | e2u }
fi

# Perl
export PERLDB_OPTS='f g '
export PERL_BADLANG=0

# Go
if [ `whence -p go` ] ; then
    export GOPATH="$HOME/Projects/go"
    export PATH="$GOPATH/bin:$PATH"
fi

# PostgreSQL
if [ -z "$PGSQL_HOME" ] ; then
    if [ -d "/usr/local/pgsql" ] ; then
        export PGSQL_HOME="/usr/local/pgsql"
    fi
fi
if [ -n "$PGSQL_HOME" ] ; then
    export PATH="$PGSQL_HOME/bin:$PATH"
fi

# MySQL
if [ -z "$MYSQL_HOME" ] ; then
    if [ -d "/usr/local/mysql" ] ; then
        export MYSQL_HOME="/usr/local/mysql"
    fi
fi
if [ -n "$MYSQL_HOME" ] ; then
    export PATH="$MYSQL_HOME/bin:$PATH"
fi
if [ `whence -p mysql` ] ; then
    if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] ; then
        export MYSQL_PS1="["$(hostname -s)"] \u@\h:\d mysql> "
    else
        export MYSQL_PS1='\u@\h:\d mysql> '
    fi
fi

if [ -n "${__CF_USER_TEXT_ENCODING}" ] ; then
    eval `perl -e 'for(@ARGV){s|.*/(.+)\.app$|$1|;$app=$_;s|\s+||g;print qq(alias \x27$_.app\x27="open -a \x27$app\x27"\n)}' /Applications/*.app /Applications/*/*.app ~/Applications/*.app ~/Applications/*/*.app`
fi

# Mercurial
export HGENCODING="utf-8"

alias yuno='echo -e "\033[43m\033[30mX\033[47m \033[30m/ \033[31m_ \033[30m/ \033[43m\033[30mX\033[00m"'

# Heroku Toolbelt
if [ -d "/usr/local/heroku/bin" ] ; then
    export PATH="/usr/local/heroku/bin:$PATH"
fi

# Vagrant
if [ `whence -p prlctl` ] ; then
    export VAGRANT_DEFAULT_PROVIDER=parallels
fi

# Docker Machine
if [ `whence -p docker-machine` ] ; then
    docker_machine_main=`docker-machine ls -q | head -1`
    if [ -n "$docker_machine_main" ] ; then
        eval "$(docker-machine env "$docker_machine_main")"
    fi
fi

# AWS CLI
if [ `whence -p aws_zsh_completer.sh` ] ; then
    source `whence -p aws_zsh_completer.sh`
fi
