autoload -U is-at-least

# add-zsh-hook
autoload -Uz add-zsh-hook

#
# set prompt
#
autoload colors
colors
# プロンプト変数内の変数展開を表示時に行う($の前に\をつけておく)
setopt prompt_subst

PROMPT_HOST="%m"
case "${OSTYPE}" in
linux*)
    PROMPT_ALIAS=`hostname -a | sed -r \
        -e "s/\\b${HOST}\\b/ /" \
        -e 's/\blocalhost\.localdomain\b/ /' \
        -e 's/\blocalhost\b/ /' \
        -e 's/\s+/ /' \
        -e 's/(^\s+|\s+$)//'`
    if [ -n "$PROMPT_ALIAS" ] ; then
        PROMPT_HOST="${PROMPT_HOST} ${PROMPT_ALIAS}"
    fi
    ;;
esac

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
    MESSAGE_SPROMPT_PREFIX="💁 💬 「"
    MESSAGE_SPROMPT_SUFFIX="」であってる?"
    MESSAGE_RETURN_CODE=" 💀  %{${fg[red]}%}%?%{${reset_color}%}"
    MESSAGE_SHELL_LEVEL=" 🐚  %L"
    MESSAGE_JOBS=" 🏃  %j"
    YUNO="${bg[yellow]}${fg[black]}X${bg[white]} ${fg[black]}/ ${fg[red]}_ ${fg[black]}/ ${bg[yellow]}${fg[black]}X${reset_color} < "
    PROMPT="%{${fg[red]}%}%*%{${reset_color}%} %B[${PROMPT_USER}%B@${PROMPT_HOST}%B]%b %U%{${fg[green]}%}%~%{${reset_color}%}%u"$'\n'"%# "
    PROMPT2="%_> "
    SPROMPT="${MESSAGE_SPROMPT_PREFIX}%{${fg[red]}%}%r%{${reset_color}%}${MESSAGE_SPROMPT_SUFFIX} %{${fg[green]}%}[n,y,a,e]%{${reset_color}%}: "
    RPROMPT="\${vcs_info_msg_0_}%(0?..${MESSAGE_RETURN_CODE})%(2L.${MESSAGE_SHELL_LEVEL}.)%(1j.${MESSAGE_JOBS}.)"
    ;;
esac

# ターミナルウインドウのタイトル設定
function _set_terminal_title () {
    if [ -n "${TERM_PROGRAM}" ] ; then
        echo -ne "\033]7;${PWD}\007\033]2;\007"
    else
        echo -ne "\033]7;${PWD}\007\033]2;🌐 ${HOST%%.*}: $1\007"
    fi
}
function _preexec_set_terminal_title () {
    _set_terminal_title "${1%% *}"
}
function _precmd_set_terminal_title () {
    _set_terminal_title "${PWD}"
}
case "${TERM}" in
kterm*|xterm*|dtterm*)
    add-zsh-hook preexec _preexec_set_terminal_title
    add-zsh-hook precmd _precmd_set_terminal_title
    ;;
esac

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
autoload -Uz vcs_info
local -A vcs_info_replacements
local vcs_info_formats
local vcs_info_actionformats
vcs_info_replacements=(
    vcs "%s"
    branch "%{${fg[green]}%}%b%{${reset_color}%}"
    action "%{${fg[red]}%}%a%{${reset_color}%}"
    stagedstr "%{${fg[cyan]}%}%c%{${reset_color}%}"
    unstagedstr "%{${fg[magenta]}%}%u%{${reset_color}%}"
    base "%R"
    name "%{${fg[blue]}%}%r%{${reset_color}%}"
    subdir "%S"
    misc "%m"
)
vcs_info_formats="${vcs_info_replacements[vcs]}:${vcs_info_replacements[name]}:${vcs_info_replacements[branch]}"
vcs_info_actionformats="${vcs_info_replacements[action]}"
echo "${vcs_info_params[vcs]} ${vcs_info_params[action]}"
# enable check-for-changes
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "🔹 "
zstyle ':vcs_info:git:*' unstagedstr "🔸 "
vcs_info_formats="${vcs_info_formats}${vcs_info_replacements[stagedstr]}${vcs_info_replacements[unstagedstr]}"
zstyle ':vcs_info:*' formats "[${vcs_info_formats}] "
zstyle ':vcs_info:*' actionformats "[${vcs_info_formats}|${vcs_info_actionformats}] "
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b:%r'

function _precmd_vcs_info () {
    LANG=en_US.UTF-8 vcs_info
}
add-zsh-hook precmd _precmd_vcs_info

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
