#
# set prompt
#
autoload colors
colors

PROMPT_HOST="%m"

_update_prompt()
{
    case ${TERM} in
    dumb*|emacs*)
        ;;
    *)
        if [ "${UID}" = "0" ] ; then
            PROMPT_USER="%{${bg[blue]}%}%n%{${reset_color}%}"
        else
            PROMPT_USER="%n"
        fi
        if [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] ; then
            PROMPT_HOST="%{${bg[blue]}%}${PROMPT_HOST}%{${reset_color}%}"
        fi
        YUNO="${bg[yellow]}${fg[black]}X${bg[white]} ${fg[black]}/ ${fg[red]}_ ${fg[black]}/ ${bg[yellow]}${fg[black]}X${reset_color} < "
        PROMPT="%{${fg[red]}%}%*%{${reset_color}%} %B[${PROMPT_USER}@${PROMPT_HOST}]%b %U%{${fg[green]}%}%~%{${reset_color}%}%u"$'\n'"%# "
        PROMPT2="%_> "
        SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
        RPROMPT="$GIT_CURRENT_BRANCH%(0?..[Return code:%{${fg[red]}%}%?%{${reset_color}%}])%(2L.[Shell level:%L].)%(1j.[Jobs:%j].)"
        ;;
    esac
}

_set_env_git_current_branch() {
    GIT_CURRENT_BRANCH=$( git branch &> /dev/null | grep '^\*' | cut -b 3- )
    if [ -n "$GIT_CURRENT_BRANCH" ] ; then
        GIT_CURRENT_BRANCH="[git:%{${fg[green]}%}$GIT_CURRENT_BRANCH%{${reset_color}%}]"
    fi
    
}

precmd() {
    case "${TERM}" in
    kterm*|xterm*|dtterm*)
        # set terminal title including current directory
        #
        echo -ne "\033]0;${USER}@${HOST%%.*}\007"
        ;;
    esac
    _set_env_git_current_branch
    _update_prompt
}

chpwd()
{
    _set_env_git_current_branch
    _update_prompt
}
_update_prompt

# auto change directory
setopt auto_cd
# auto directory pushd that you can get dirs list by cd -[tab]
setopt auto_pushd
# command correct edition before each completion attempt
setopt correct
# compacked complete list display
setopt list_packed
# no remove postfix slash of command line
setopt noautoremoveslash
# no beep sound when complete list displayed
setopt nolistbeep
# 8 ビット目を通すようになり、日本語のファイル名などを見れるようになる
setopt print_eightbit
# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst

## Keybind configuration
# emacs like keybind (e.x. Ctrl-a goes to head of a line and Ctrl-e goes 
# to end of it)
bindkey -e

# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end

## Command history configuration
if [ "${UID}" != "0" ] ; then
    HISTFILE=~/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt hist_ignore_dups # ignore duplication command history list
    setopt share_history # share command history data
fi

fpath=(~/.zsh/functions $fpath)

## Completion configuration
autoload -U compinit
compinit

## 補完時に大小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=1

# expand aliases before completing
setopt complete_aliases # aliased ls needs if file/dir completions work

## terminal configuration
unset LSCOLORS
case "${TERM}" in
xterm)
    export TERM=xterm-color
    ;;
kterm)
    export TERM=kterm-color
    # set BackSpace control character
    stty erase
    ;;
cons25)
    unset LANG
    export LSCOLORS=ExFxCxdxBxegedabagacad
    export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors \
        'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
esac

case "${TERM}" in
kterm*|xterm*|dtterm*)
    zstyle ':completion:*' list-colors \
        'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
esac

#### time
REPORTTIME=8                    # CPUを8秒以上使った時は time を表示
TIMEFMT="\
    The name of this job.             :%J
    CPU seconds spent in user mode.   :%U
    CPU seconds spent in kernel mode. :%S
    Elapsed time in seconds.          :%E
    The  CPU percentage.              :%P"
