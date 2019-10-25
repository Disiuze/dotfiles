HISTFILE=~/.histfile
HISTSIZE=2500
SAVEHIST=10000
setopt appendhistory autocd extendedglob notify
unsetopt beep nomatch
bindkey -e

if [ -f ~/.config/zsh/colors ]; then
. ~/.config/zsh/colors
fi

HOSTNAME=$(cat /etc/hostname)

PS1="${BLACK}[${RED}$USER${BLACK}::${GREEN}$HOSTNAME${BLACK}]${CLEAR}# "

FUPATH=$ZDOTDIR/functions

autoload -Uz $FUPATH/*

autoload -Uz compinit promptinit

if [ -f $ZDOTDIR/.zsh_aliases ]; then
. $ZDOTDIR/.zsh_aliases
fi

if [ -f ~/.localrc ]; then
. ~/.localrc
fi

compinit
promptinit

cd

clear
