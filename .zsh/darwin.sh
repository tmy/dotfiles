# -*- sh -*-
#
# Darwin 
#

if [ -d "$HOME/bin/darwin" ] ; then
    export PATH="$HOME/bin/darwin:$PATH"
fi

if [ -z "${LANG}" ] ; then
    export LANG=ja_JP.UTF-8
fi

# BSD colorls
export CLICOLOR=1
alias ls='ls -Fv'
alias ll='ls -lav'
alias la='ls -av'

# less
export LESS="-RM"

# escape sequences
alias dock='printf "\033[2t"'
alias lower='printf "\033[6t"'
alias raise='printf "\033[5t"'
alias 80x36='printf "\033[8;36;80t"'
alias maxh='printf "\033[8;0;80t"'
alias maxw='printf "\033[8;24;0t"'
alias zoom='printf "\033[3;0;t\033[8;0;0t"'

export COPYFILE_DISABLE=1
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1
alias tar-with-resource-fork='env COPYFILE_DISABLE=0 COPY_EXTENDED_ATTRIBUTES_DISABLE=0 /usr/bin/tar'

if [ -n "${JAVA_VERSION}" ] ; then
    export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/${JAVA_VERSION}/Home
else
    export JAVA_HOME=/Library/Java/Home
fi
if [ "${LANG}" = "ja_JP.UTF-8" ] ; then
    export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'
#    alias java='java -Dfile.encoding=UTF-8'
#    alias javac='javac -J-Dfile.encoding=UTF-8'
#    alias javadoc='javadoc -J-Dfile.encoding=UTF-8'
#    alias jar='jar -J-Dfile.encoding=UTF-8'
#    alias native2ascii='native2ascii -J-Dfile.encoding=UTF-8'
elif [ "${LANG}" = "ja_JP.eucJP" ] ; then
    export _JAVA_OPTIONS=-Dfile.encoding=EUC-JP
#    alias java='java -Dfile.encoding=EUC-JP'
#    alias javac='javac -J-Dfile.encoding=EUC-JP'
#    alias javadoc='javadoc -J-Dfile.encoding=EUC-JP'
#    alias jar='jar -J-Dfile.encoding=EUC-JP'
#    alias native2ascii='native2ascii -J-Dfile.encoding=EUC-JP'
fi

# Ant
if [ -d /Developer/Java/Ant ] ; then
    export ANT_HOME=/Developer/Java/Ant
fi

# Developer Tools
if [ -d /Developer/Tools ] ; then
    export PATH=/Developer/Tools:${PATH}
fi

# X11
if [ -d /usr/X11R6/bin ] ; then
    export PATH=/usr/X11R6/bin:${PATH}
fi

alias top='top -ocpu'

# Fink
[ -r /sw/bin/init.sh ] && source /sw/bin/init.sh

# MacPorts
if [ -d /opt/local ] ; then
    export PATH=/opt/local/bin:/opt/local/sbin:$PATH
    export MANPATH=/opt/local/man:$MANPATH
fi

# TextMate
if [ -x "${HOME}/bin/mate_wait" ] ; then
    export EDITOR='mate_wait'
fi
