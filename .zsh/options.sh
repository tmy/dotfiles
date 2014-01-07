autoload -U is-at-least

# add-zsh-hook
if is-at-least 4.3.4; then
    autoload -Uz add-zsh-hook
else
    # 標準添付されていないので、自前バージョンを使う
    fpath=($fpath ~/.zsh/functions/fallbacks/add-zsh-hook)
    autoload -U add-zsh-hook
fi

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
        PROMPT="%{${fg[red]}%}%*%{${reset_color}%} %B[${PROMPT_USER}%B@${PROMPT_HOST}%B]%b %U%{${fg[green]}%}%~%{${reset_color}%}%u"$'\n'"%# "
        PROMPT2="%_> "
        SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
        RPROMPT="${vcs_info_msg_0_}%(0?..[Return code:%{${fg[red]}%}%?%{${reset_color}%}])%(2L.[Shell level:%L].)%(1j.[Jobs:%j].)"
        ;;
    esac
}

preexec() {
    case "${TERM}" in
    kterm*|xterm*|dtterm*)
        # set terminal title
        if [ -n "${TERM_PROGRAM}" ] ; then
            echo -ne "\033]0;${1%% *}/ (${USER})\007"
        else
            echo -ne "\033]0;${HOST%%.*}: ${1%% *}/ (${USER})\007"
        fi
        ;;
    esac
}

precmd() {
    case "${TERM}" in
    kterm*|xterm*|dtterm*)
        # set terminal title
        if [ -n "${TERM_PROGRAM}" ] ; then
            echo -ne "\033]0;${PWD}/ (${USER})\007"
        else
            echo -ne "\033]0;${HOST%%.*}: ${PWD}/ (${USER})\007"
        fi
        ;;
    esac

    old_lang=$LANG
    export LANG=en_US.UTF-8
    vcs_info
    export LANG=$old_lang
    unset old_lang

    _update_prompt
}

_update_prompt

# auto change directory
setopt auto_cd
# auto directory pushd that you can get dirs list by cd -[tab]
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups
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
# フローコントロールを無効にする
setopt no_flow_control
# シェルが終了しても裏ジョブに HUP シグナルを送らないようにする
setopt no_hup
# {a-c} を a b c に展開する機能を使えるようにする
setopt brace_ccl
#コピペの時rpromptを非表示する
setopt transient_rprompt
# リダイレクトで上書きする事を許可しない。
setopt no_clobber
# バックグラウンドジョブが終了したらすぐに知らせる。
#setopt no_tify

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
    # 履歴ファイルに時刻を記録
    setopt extended_history
    # 履歴をインクリメンタルに追加
    setopt inc_append_history
    # 履歴の共有
    setopt share_history
    # ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
    setopt hist_ignore_all_dups
    # 直前と同じコマンドラインはヒストリに追加しない
    setopt hist_ignore_dups
    # スペースで始まるコマンド行はヒストリリストから削除
    setopt hist_ignore_space
    # ヒストリを呼び出してから実行する間に一旦編集可能
    setopt hist_verify
fi

fpath=(~/.zsh/functions ~/.zsh/functions/zsh-completions/src $fpath)

## Completion configuration
autoload -U compinit
compinit -u

## 補完時に大小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=1
## sudo でも補完の対象
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# expand aliases before completing
setopt complete_aliases # aliased ls needs if file/dir completions work

## vcs_info
if is-at-least 4.2.1; then
    if is-at-least 4.3.7; then
    else
        # 標準添付されていないので、自前バージョンを使う
        fpath=($fpath ~/.zsh/functions/fallbacks/vcs_info)
    fi
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' actionformats \
        "[%s:%{${fg[blue]}%}%r%{${reset_color}%}:%{${fg[green]}%}%b%{${reset_color}%}|%{${fg[red]}%}%a%{${reset_color}%}] "
    zstyle ':vcs_info:*' formats \
        "[%s:%{${fg[blue]}%}%r%{${reset_color}%}:%{${fg[green]}%}%b%{${reset_color}%}] "
    zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b:%r'
else
    # 古くて vcs_info がロードできない
    vcs_info() {
        vcs_info_msg_0_=$( git branch &> /dev/null | grep '^\*' | cut -b 3- )
        if [ -n "$vcs_info_msg_0_" ] ; then
            vcs_info_msg_0_="[git:%{${fg[green]}%}$vcs_info_msg_0_%{${reset_color}%}]"
        fi
    }
fi

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
    if [ -n "$LS_COLORS" ] ; then
        zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    else
        zstyle ':completion:*' list-colors \
            'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    fi
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

## syntax highlighiting
if is-at-least 4.3.9; then
	source ~/.zsh/functions/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
