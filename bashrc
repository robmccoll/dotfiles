# Source global definitions
[ -z "$PS1" ] && return
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


Blue='\[\e[01;34m\]'
White='\[\e[01;37m\]'
Red='\[\e[01;31m\]'
Green='\[\e[01;32m\]'
Reset='\[\e[00m\]'
FancyX='\342\234\227'
Checkmark='\342\234\223'

parse_git_branch() {
  b=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [[ $? == 0 ]]; then
    echo -n "$Blue[$Red$b"
    if [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]]; then
      echo -n "$Blue] [${Red}$FancyX"
    else
      echo -n "$Blue] [${Green}$Checkmark"
    fi
    echo "$Blue]"
  fi
}

git_blame_stat() {
  find . -name "*.$1" | grep -v vendor -v dependencies | xargs -n 1 git blame -w | \
    sed -e 's/[^(]* (//' -e 's/ *20.*//'  |  tr '[:upper:]' '[:lower:]' | \
    sort | uniq -c
}

# User specific aliases and functions


# stolen from
# https://stackoverflow.com/questions/1862510/how-can-the-last-commands-wall-time-be-put-in-the-bash-prompt
function timer_now {
    date +%s%N
}

function timer_start {
    timer_start=${timer_start:-$(timer_now)}
}

function timer_stop {
    local delta_us=$((($(timer_now) - $timer_start) / 1000))
    local us=$((delta_us % 1000))
    local ms=$(((delta_us / 1000) % 1000))
    local s=$(((delta_us / 1000000) % 60))
    local m=$(((delta_us / 60000000) % 60))
    local h=$((delta_us / 3600000000))
    # Goal: always show around 3 digits of accuracy
    if ((h > 0)); then timer_show=${h}h${m}m
    elif ((m > 0)); then timer_show=${m}m${s}s
    elif ((s >= 10)); then timer_show=${s}.$((ms / 100))s
    elif ((s > 0)); then timer_show=${s}.$(printf %03d $ms)s
    elif ((ms >= 100)); then timer_show=${ms}ms
    elif ((ms > 0)); then timer_show=${ms}.$((us / 100))ms
    else timer_show=${us}us
    fi
    unset timer_start
}


set_prompt () {
    Last_Command=$? # Must come first!

    # Add a bright white exit status for the last command
    PS1=''
    # If it was successful, print a green check mark. Otherwise, print
    # a red X.
    if [[ $Last_Command == 0 ]]; then
        PS1+="$Green[$Checkmark "
    else
        PS1+="$Red[$FancyX "
    fi

    # Add the ellapsed time and current date
    timer_stop
    PS1+="$Last_Command $timer_show] 
"

    # If root, just print the host in red. Otherwise, print the current user
    # and host in green.
    if [[ $EUID == 0 ]]; then
        PS1+="$Red[$White\\u$Red@\\h$Red] "
    else
        PS1+="$Blue[$Red\\u@\\h$Blue] "
    fi
    PS1+="$Blue[$Red\\t$Blue] "
    # Print the working directory and prompt marker in blue, and reset
    # the text color to the default.
    PS1+="$Blue[$Red\\w$Blue] $(parse_git_branch)
$Blue"'\[\033k\033\\\]'"\\\$$Reset"
    history -a; history -c; history -r
}

# unified bash history
export HISTSIZE=""
shopt -s histappend

trap 'timer_start' DEBUG
PROMPT_COMMAND='set_prompt'

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
    dest=''
    while [ "$count" != "$1" ]; do
      dest="$dest../"
      count=`expr $count + 1`
      if [ "$count" == "100" ]; then
        echo "Recursion limit reached"
        break
      fi
    done
    cd $dest
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
      grep -in  "$2" `find . -name "*.$1"` | grep -v Godeps | grep -v vendor | less -F --no-init
    elif [ "$1" = "js" ]; then
      grep -in  "$2" `find . -name "*.$1" | grep -v node_modules | grep -v .chunk.js` | less -F --no-init
    else
      grep -in  "$2" `find . -name "*.$1"` | less -F --no-init
    fi
  else
    echo "usage: gerp <filextension> <pattern>"
  fi
}

gerpf() {
  gerp $@ | sed -e 's/:.*//' | sort | uniq | less -F --no-init
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

docker_kill() {
  INSTANCES=$(docker ps -a -q)
  if [ "$INSTANCES" != "" ]; then
    docker rm -f $INSTANCES
  fi
}

swp() {
  FILES=$(find . -name ".*.sw[po]")
  if [ "$FILES" == "" ]; then
    echo "No swap files found."
    return
  fi
  echo $FILES
  echo "Delete? (y/n)"
  read YN
  if [ "$YN" == "y" ] || [ "$YN" == "Y" ]; then
    rm `find . -name ".*.sw[po]"`
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

play_result() {
  if [ $? -eq 0 ]; then
    aplay /usr/share/sounds/sound-icons/xylofon.wav
    aplay /usr/share/sounds/sound-icons/xylofon.wav
    aplay /usr/share/sounds/sound-icons/xylofon.wav
  else
    aplay /usr/share/sounds/sound-icons/klavichord-4.wav
    aplay /usr/share/sounds/sound-icons/klavichord-4.wav
    aplay /usr/share/sounds/sound-icons/klavichord-4.wav
  fi
}

urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

base64pad() {
  read DATA
  REM=$(expr ${#DATA} % 4)
  if [ "$REM" == "2" ]; then 
    echo "$DATA=="
  elif [ "$REM" == "3" ]; then 
    echo "$DATA="
  else 
    echo "$DATA"
  fi
}

jwsq() {
  IFS='.' read PROTECTED PAYLOAD SIG
  PROTECTED=$(echo $PROTECTED | base64pad | base64 -d)
  PAYLOAD=$(echo $PAYLOAD | base64pad | base64 -d)
  echo $PAYLOAD
  echo '{"protected":'"$(echo $PROTECTED)"', "payload":'"$(echo $PAYLOAD)"', "signature":"'"$(echo $SIG)"'"}' | jq $@
}

jwesq() {
  IFS='.' read ENCHEAD SIGHEAD SIG IV CIPHER TAG
  ENCHEAD=$(echo $ENCHEAD | base64pad | base64 -d)
  SIGHEAD=$(echo $SIGHEAD | base64pad | base64 -d)
  echo '{"encHead":'$(echo $ENCHEAD)', "sigHead":'$(echo $SIGHEAD)',"sig":"'"$(echo $SIG)"'", "iv":"'"$(echo $IV)"'", "cipher":"'$(echo $CIPHER)'", "tag":"'$(echo $TAG)'"}' | jq $@
}

if [ -f $HOME/.dotfiles/bash/git-completion.bash ]; then
    . $HOME/.dotfiles/bash/git-completion.bash
fi

if [ -f $HOME/.dotfiles/bash/kubectl-completion.bash ]; then
    . $HOME/.dotfiles/bash/kubectl-completion.bash
fi

complete -W "\`grep -oE '^[a-zA-Z0-9_.-]+:([^=]|$)' ?akefile | sed 's/[^a-zA-Z0-9_.-]*$//'\`" make

if [ -f $HOME/.bashrc_local ]; then
	. $HOME/.bashrc_local
fi

export SASS_PATH=./node_modules
