HISTFILE=~/.histfile
HISTSIZE=2500
SAVEHIST=10000
setopt appendhistory autocd extendedglob notify
unsetopt beep nomatch
bindkey -e

zstyle :compinstall filename ~/.zshrc
autoload -Uz compinit
compinit

if [ -f ~/.zsh_aliases ]; then
. ~/.zsh_aliases
fi

function scrshot() {
	import ~/Screenshots/`date '+%Y%m%d%M%S'`.png
}

alias scr=scrshot

export -f scrshot

function bookmark() {
	export $1="`pwd`"
	echo "$1 bookmarked"
}

function umark() {
	export $1=''
	echo "$1 unmarked."
}

alias mark=bookmark
alias bmark=bookmark

export -f bookmark

function vcd() {
	cd $1
	echo "Current directory: $(pwd)"
}

export -f vcd

clear
