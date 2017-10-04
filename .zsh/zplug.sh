# -*- sh -*-

if [ -e ~/.zplug/init.zsh ] ; then

    source ~/.zplug/init.zsh

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
