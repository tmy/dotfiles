.DEFAULT_GOAL := all

DOTFILES := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

all: zsh git vim ruby misc
.PHONY: all zsh git vim ruby misc

zsh:
	@if [ -d "${HOME}/.zsh" -a ! -L "${HOME}/.zsh" ] ; then \
		echo mv "${HOME}/.zsh" "${HOME}/.zsh.bak" ; \
		mv "${HOME}/.zsh" "${HOME}/.zsh.bak" ; \
	fi
	ln -sfn "$(DOTFILES)/.zsh" "${HOME}/.zsh"
	ln -sf "$(DOTFILES)/.zshenv" "${HOME}/.zshenv"
	ln -sf "$(DOTFILES)/.zshrc" "${HOME}/.zshrc"

git:
	ln -sf "$(DOTFILES)/.gitconfig" "${HOME}/.gitconfig"
	ln -sf "$(DOTFILES)/.gitignore_global" "${HOME}/.gitignore_global"

vim:
	ln -sf "$(DOTFILES)/.vimrc" "${HOME}/.vimrc"

ruby:
	ln -sf "$(DOTFILES)/.irbrc" "${HOME}/.irbrc"

misc:
	ln -sf "$(DOTFILES)/.dircolors" "${HOME}/.dircolors"
	ln -sf "$(DOTFILES)/.screenrc" "${HOME}/.screenrc"
