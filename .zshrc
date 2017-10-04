for i in options zplug applications ; do
    [ -f ~/.zsh/${i}.sh ] && source ~/.zsh/${i}.sh
done
