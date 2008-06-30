# -*- sh -*-

for i in base local environments ; do
    [ -f ~/.zsh/${i}.sh ] && source ~/.zsh/${i}.sh
done

case "${OSTYPE}" in
darwin*)
    source ~/.zsh/darwin.sh
    ;;
linux*)
    source ~/.zsh/linux.sh
    ;;
solaris*)
    source ~/.zsh/solaris.sh
    ;;
esac
