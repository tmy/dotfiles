for i in options zinit applications ; do
    [ -f ~/.zsh/${i}.sh ] && source ~/.zsh/${i}.sh
done
