# -*- zsh -*-

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

function install-zinit() {
  [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
  [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
}

if [ -e "${ZINIT_HOME}/zinit.zsh" ] ; then
  source "${ZINIT_HOME}/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

  # Load a few important annexes, without Turbo
  # (this is currently required for annexes)
  zinit light-mode for \
      zdharma-continuum/z-a-rust \
      zdharma-continuum/z-a-as-monitor \
      zdharma-continuum/z-a-patch-dl \
      zdharma-continuum/z-a-bin-gem-node \
      zsh-users/zsh-autosuggestions \
      zsh-users/zsh-syntax-highlighting \
      zsh-users/zsh-completions
fi
