# -*- zsh -*-
#
# Darwin 
#

if [ -d "$HOME/bin/darwin" ] ; then
    export PATH="$HOME/bin/darwin:$PATH"
fi

if [ -z "${LANG}" ] ; then
    export LANG=ja_JP.UTF-8
fi

# ファイル名の結合文字を正しく扱う
setopt COMBINING_CHARS

# BSD colorls
export CLICOLOR=1
alias ls='ls -Fv'
alias ll='ls -lav'
alias la='ls -av'

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

alias sha256sum='shasum -a 256'

if [ -n "${JAVA_VERSION}" ] ; then
    export JAVA_HOME=$(/usr/libexec/java_home -v "${JAVA_VERSION}" 2> /dev/null)
else
    export JAVA_HOME=$(/usr/libexec/java_home 2> /dev/null)
fi

# X11
if [ -d /usr/X11R6/bin ] ; then
    export PATH=/usr/X11R6/bin:${PATH}
fi

alias top='top -ocpu'
