#!/bin/bash

add_to_home() {
  if [ -f ~/.$1 ]; then
    mv -n ~/.$1 ~/.old_dotfiles
  fi
  if [ ! -f ~/.$1 ]; then
    ln $1 ~/.$1
  fi
}

add_dir_to_home() {
  if [ -d ~/.$1 ]; then
    mv -n ~/.$1 ~/.old_dotfiles
  fi
  if [ ! -d ~/.$1 ]; then
    if [ ! -L ~/.$1 ]; then
      ln -s $PWD/$1 ~/.$1
    fi
  fi
}


mkdir -p ~/.old_dotfiles

add_to_home "bashrc"
add_to_home "vimrc"
add_dir_to_home "vim"
add_to_home "screenrc"
add_to_home "astylerc"

. ~/.bashrc
