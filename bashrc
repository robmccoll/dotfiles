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

# aliases
alias gp='grep -rin '
alias ll='ls -hl --color '
alias vs='vim -S .session.vim'
alias mkae='make'
alias maek='make'
alias mke='make'
alias atp-get='apt-get'
alias cd..='cd ..'
alias ..='cd ..'

# Delete duplicate blank lines, style via astyle
function style() {
  sed -i '/^[ \t]*/{N; /^[ \t]*\n$/d}' $@
  astyle $@
}

# down - find subdir, cd to it
down() {
  dest=`find . -name "$1" -type d -print -quit 2>/dev/null`
  if [ "$dest" != "" ]; then
    echo $dest
    cd $dest
  else
    echo "$1 not found" 
  fi
}

# up - cd up some number of dirs
up() {
  if [ "$#" != "0" ]; then
    count=0
    while [ "$count" != "$1" ]; do
      cd ..
      count=`expr $count + 1`
      if [ "$count" == "100" ]; then
        echo "Recursion limit reached"
        break
      fi
    done
  else
    cd ..
  fi
}

# upto - cd up to a dir in your path
upto() {
  OIFS=$IFS
  IFS='/'
  found=0
  for d in $(pwd); do
    if [ "$d" = "$1" ]; then
      found=1
    fi
  done
  if [ "$found" == "1" ]; then
    while [ "${PWD##*/}" != "$1" ]; do
      cd ..
    done
  else
    echo "Directory $1 not in path: $(pwd)"
  fi
  IFS=$OIFS
}

md() {
  date '+%Y.%m.%d'
}


histogram() {
  if [ $# -lt 1 ]
  then
    echo "Usage: histogram [file] [field] [precision]"
    return 0
  fi

  field=1
  if [ $# -gt 1 ]
  then
    field=$2
  fi

  if [ $# -gt 2 ]
  then
    precision="."
    for i in `seq 1 1 $3`
    do
      precision=$precision.
    done

    cat $1 | sort -k $field -n -t ',' | cut -d ',' -f $field | sed -e "s/\($precision\).*/\1/" | uniq -c
  else
    cat $1 | sort -k $field -n -t ',' | cut -d ',' -f $field | uniq -c
  fi
}

if [ -f $HOME/.bashrc_local ]; then
	. $HOME/.bashrc_local
fi
