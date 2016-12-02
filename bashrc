# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

parse_git_dirty() {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo "] [dirty"
}

parse_git_branch() {
  git branch  2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}

git_blame_stat() {
  find . -name "*.$1" | grep -v vendor | xargs -n 1 git blame -w | \
    sed -e 's/[^(]* (//' -e 's/ *20.*//'  |  tr '[:upper:]' '[:lower:]' | \
    sort | uniq -c
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
alias la='ls -hal --color '

alias vs='vim -S .session.vim'

alias clera='clear'
alias claer='clear'

alias atp-get='apt-get'

alias cd..='cd ..'
alias ..='cd ..'

alias mkae='make'
alias maek='make'
alias mke='make'

alias git_tree='git log --all --graph --decorate --oneline --simplify-by-decoration'
alias gtree='git_tree'
alias gpull='git pull'
alias gpsh='git push'
alias gst='git status'
alias gdiff='git diff'
alias gco='git checkout'
alias gmerge='git merge'
alias gd='git diff'

bind "set completion-ignore-case on"

# Delete duplicate blank lines, style via astyle
style() {
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
  if [ $# -lt 1 ]; then
    date '+%Y.%m.%d'
  else
    vim `date '+%Y.%m.%d'`$1
  fi
}

mdt() {
  if [ $# -lt 1 ]; then
    date '+%Y.%m.%d.%H:%M:%S'
  else
    vim `date '+%Y.%m.%d.%H:%M:%S'`$1
  fi
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

hex() {
  xxd -ps
}

fromhex() {
  xxd -r -p
}

rand64() {
  if [ $# -lt 1 ]; then
    head -c 10 /dev/urandom | base64 -w 0 | sed -e 's/=//g'
  else
    head -c $1 /dev/urandom | base64 -w 0 | sed -e 's/=//g'
  fi
}

tmpl() {
  if [ "$#" = "0" ]; then
    echo "usage: template <file>      print all templates in file"
    echo "usage: template <key> <val> replace key with val. template stdin to stdout"
  elif [ "$#" = "1" ]; then
    cat $1 | sed -e 's/}}"/}}"\n/' | grep "{{[^}]*}}" | sed -e 's/[^{}]*{{ *//' -e 's/ *}}[^{}]*//' | sort | uniq
  elif [ "$#" = "2" ]; then
    sed -e "s/{{ *$1 *}}/$2/g"
  else
    echo "incorrect number of args"
  fi
}

gerp() {
  if [ "$#" = "2" ]; then
    if [ "$1" = "go" ]; then
      grep -in  "$2" `find . -name "*.$1"` | grep -v Godeps | grep -v vendor
    elif [ "$1" = "js" ]; then
      grep -in  "$2" `find . -name "*.$1" | grep -v node_modules`
    else
      grep -in  "$2" `find . -name "*.$1"`
    fi
  else
    echo "usage: gerp <filextension> <pattern>"
  fi
}

docker_ip() {
  if [ $# -lt 2 ]; then
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1
  else
    HOST=$2
    IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $2)
    cat /etc/hosts | grep -v $HOST > newhosts
    echo $IP $HOST >> newhosts
    sudo mv newhosts /etc/hosts
  fi
}

docker_cleanup() {
  DEADINSTANCES=$(docker ps -a -q -f status=exited)
  if [ "$DEADINSTANCES" != "" ]; then
    docker rm $DEADINSTANCES
  fi

  DANGLINGIMAGES=$(docker images | grep "^<none>" | awk "{print $3}")
  if [ "$DANGLINGIMAGES" != "" ]; then
    docker rmi $DANGLINGIMAGES
  fi
}

zoom_in() {
  SIZE=`grep 'FontName' ~/.config/xfce4/terminal/terminalrc | cut -d' ' -f 2`
  NEWSIZE=$((SIZE + 2))
  echo $NEWSIZE
  REGEXPR='s/FontName.*/FontName=Monospace '$NEWSIZE'/g'
  sed -i "$REGEXPR" ~/.config/xfce4/terminal/terminalrc
}

zoom_set() {
  SIZE=`grep 'FontName' ~/.config/xfce4/terminal/terminalrc | cut -d' ' -f 2`
  NEWSIZE=$1
  echo $NEWSIZE
  REGEXPR='s/FontName.*/FontName=Monospace '$NEWSIZE'/g'
  sed -i "$REGEXPR" ~/.config/xfce4/terminal/terminalrc
}

zoom_out() {
  SIZE=`grep 'FontName' ~/.config/xfce4/terminal/terminalrc | cut -d' ' -f 2`
  NEWSIZE=$((SIZE - 2))
  if [ $NEWSIZE -lt 6 ]; then
    NEWSIZE=6
  fi
  echo $NEWSIZE
  REGEXPR='s/FontName.*/FontName=Monospace '$NEWSIZE'/g'
  sed -i "$REGEXPR" ~/.config/xfce4/terminal/terminalrc
}

# unified bash history
export HISTSIZE=""
shopt -s histappend
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

if [ -f $HOME/.bashrc_local ]; then
	. $HOME/.bashrc_local
fi
