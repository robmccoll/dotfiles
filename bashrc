# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo "] [dirty"
}
function parse_git_branch {
  git branch  2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}

# User specific aliases and functions

export PS1='\[\033[01;34m\][\[\033[01;31m\]\u@\h\[\033[01;34m\]] [\[\033[01;31m\]\t\[\033[01;34m\]] [\[\033[01;31m\]\w\[\033[01;34m\]] $(parse_git_branch)
$\[\033[00m\]'

export SVN_EDITOR=vim
export EDITOR=vim

export PATH=$PATH:$HOME/.local/bin

# Delete duplicate blank lines, style via astyle
function style() {
  sed -i '/^[ \t]*/{N; /^[ \t]*\n$/d}' $@
  astyle $@
}

if [ -f $HOME/.bashrc_local ]; then
	. $HOME/.bashrc_local
fi
