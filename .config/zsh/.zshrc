HISTFILE=~/.histfile
HISTSIZE=2500
SAVEHIST=10000
setopt appendhistory autocd extendedglob notify
unsetopt beep nomatch
bindkey -e

autoload -Uz colors && colors

if [ -f ~/.config/zsh/colors ]; then
. ~/.config/zsh/colors
fi

HOSTNAME=$(cat /etc/hostname)
STATCOL="%(?.%F{green}.%F{red})"
NEWLINE=$'\n'

PS1="[${STATCOL}PWD:%/${CLEAR}]${NEWLINE}${CLEAR}[${RED}$USER${CLEAR}::${BLUE}$HOSTNAME${CLEAR}]# "

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

clear

