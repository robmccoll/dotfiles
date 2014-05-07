# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ -f $HOME/.bashrc_local ]; then
	. $HOME/.bashrc_local
fi

# User specific aliases and functions

PS1="\[\033[01;34m\][\[\033[01;31m\]\u@\h\[\033[01;34m\]] [\[\033[01;31m\]\t\[\033[01;34m\]] [\[\033[01;31m\]\w\[\033[01;34m\]]
$\[\033[00m\]"

export SVN_EDITOR=vim
export EDITOR=vim
