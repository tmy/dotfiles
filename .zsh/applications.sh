# -*- sh -*-


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

alias eng='env LC_ALL=C'

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
if [ "${LANG}" = "ja_JP.UTF-8" ] ; then
    export LESSCHARSET='utf-8'
fi
if [ `whence -p jless` ] ; then
    which jless
    alias less='jless'
fi

nless() { nl $* | less }

if [ `whence -p gnutar` ] ; then
    alias tar='gnutar'
fi

alias gpg='eng gpg'

# Mac OS X
alias console='open -a Console'
alias calc='open -a Calculator'
alias emacs='env XMODIFIERS=@im=no emacs'

# GNU screen
alias s=screen
alias ss='screen ssh'

# refe
if [ "${LANG}" = "ja_JP.UTF-8" ] ; then
    refe() { command refe $* | e2u }
fi

# Perl
export PERLDB_OPTS='f g '
export PERL_BADLANG=0

# Ant
if [ -z "$ANT_HOME" ] ; then
    for i in ~/src/ant ~/src/apache-ant /usr/local/ant ; do
        if [ -d "$i" ] ; then
            export ANT_HOME="$i"
        fi
    done
fi
if [ -n "$ANT_HOME" ] ; then
    export PATH="$ANT_HOME/bin:$PATH"
    alias ant='eng ant'
fi

# Maven
if [ -z "$MAVEN_HOME" ] ; then
    for i in ~/src/maven /usr/local/maven ; do
        if [ -d "$i" ] ; then
            export MAVEN_HOME="$i"
        fi
    done
fi
if [ -n "$MAVEN_HOME" ] ; then
    export PATH="$MAVEN_HOME/bin:$PATH"
    alias maven="eng maven -Dmaven.username=${USER}"
fi

# Tomcat
if [ -z "$CATALINA_HOME" ] ; then
    for i  in ~/src/tomcat ~/src/jakarta-tomcat /usr/local/tomcat /usr/local/jakarta-tomcat ; do
        if [ -d "$i" ] ; then
            export CATALINA_HOME="$i"
        fi
    done
fi
if [ -n "$CATALINA_HOME" ] ; then
    if [ -x "$CATALINA_HOME/bin/catalina.sh" ] ; then
        alias catalina.sh="$CATALINA_HOME/bin/catalina.sh"
    fi
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

if [ -n "${__CF_USER_TEXT_ENCODING}" ] ; then
    eval `perl -e 'for(@ARGV){s|.*/(.+)\.app$|$1|;$app=$_;s|\s+||g;print qq(alias $_.app="open -a \x27$app\x27"\n)}' /Applications/*.app /Applications/*/*.app ~/Applications/*.app ~/Applications/*/*.app`
fi

# Mercurial
export HGENCODING="utf-8"

function google() {
    local str opt 
    if [ $# != 0 ]; then # 引数が存在すれば
        for i in $*; do
            str="$str+$i"
        done
        str=`echo $str | sed 's/^\+//'` #先頭の「+」を削除
        opt='search?num=50&hl=ja&ie=utf-8&oe=utf-8&lr=lang_ja'
        opt="${opt}&q=${str}"
    fi
    w3m http://www.google.co.jp/$opt #引数がなければ $opt は空になる
}

function wiki() {
    local str
    if [ $# = 0 ]; then # 引数が存在すれば
        str="特別:Random"
        else
        str=$*
    fi
    w3m http://ja.wikipedia.org/wiki/`echo $str | nkf -w` # utf-8 に変換
}
