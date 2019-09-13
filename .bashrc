#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# Get aliases
if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

function scrshot() {
	import ~/Screenshots/`date '+%Y%m%d%M%S'`.png
}

alias scr=scrshot

export -f scrshot

clear
