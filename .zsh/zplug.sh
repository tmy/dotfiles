# -*- sh -*-

if [ -e ~/.zplug/init.zsh ] ; then

    source ~/.zplug/init.zsh

    zplug "zsh-users/zsh-syntax-highlighting", defer:2
    zplug "zsh-users/zsh-completions"
    zplug "zsh-users/zsh-autosuggestions"
    zplug "docker/cli", as:command, use:contrib/completion/zsh/_docker
    zplug "docker/compose", as:command, use:contrib/completion/zsh/_docker-compose

    # 未インストール項目をインストールする
    if ! zplug check; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi

    # コマンドをリンクして、PATH に追加し、プラグインは読み込む
    zplug load

fi
